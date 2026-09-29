"""Generate and verify tests.json from each problem.md.

Tests = examples + edge() + random_case(rng) + perf(rng) from the `# Tests` block (or autogen when it's empty).
Expected outputs come from the reference solution. Every other solution is cross-checked against it,
fast solutions must pass the perf tests and slow ones should fail at least one.
"""
import json, multiprocessing, os, random, sys, types, zlib
from concurrent.futures import ProcessPoolExecutor

import autogen
from common import cli, problem_dirs, selected
import pyjudge

N_RANDOM, N_CROSS = 30, 300


def load_gen(p):
    if not p["gen"].strip():
        return autogen.make(p)
    m = types.ModuleType("gen_" + p["id"].replace("-", "_"))
    exec(p["gen"], m.__dict__)
    return m


def build(pdir, check):
    p = pyjudge.load_problem(pdir)
    if not p["solutions"]:
        return True, [f"skip {p['id']}: not authored yet"]
    entry, cmp = p["entry"], p["judge"]["compare"]
    sols = {s["id"]: (s, pyjudge.load_solution(p["code"][s["id"]], entry)) for s in p["solutions"]}
    refs = [cls for s, cls in sols.values() if s.get("reference")]
    assert len(refs) == 1, "exactly one solution must be reference"
    gen, hooks = load_gen(p), pyjudge.load_hooks(p)
    rng = random.Random(zlib.crc32(p["id"].encode()))

    def expect(args):
        got, err, _, _ = pyjudge.run_one(refs[0], entry, args, 20_000, hooks)
        assert not err, f"reference failed on {pyjudge.show(args)}: {err}"
        return got

    cases = [(pyjudge.parse_example(e, entry["params"]), "example") for e in p["examples"]]
    cases += [(a, "edge") for a in gen.edge()]
    cases += [(gen.random_case(rng), "random") for _ in range(N_RANDOM)]
    cases += [(a, "perf") for a in (gen.perf(rng) if hasattr(gen, "perf") else [])]
    tests = [{"args": a, "expected": expect(a), "kind": k} for a, k in cases]
    perf = [t for t in tests if t["kind"] == "perf"]

    cross = [(t["args"], t["expected"]) for t in tests if t["kind"] != "perf"]
    cross += [(a, expect(a)) for a in (gen.random_case(rng) for _ in range(N_CROSS))]
    problems = []
    for sid, (s, cls) in sols.items():
        for a, exp in cross:
            got, err, _, _ = pyjudge.run_one(cls, entry, a, 2_000 if s.get("slow") else 20_000, hooks)
            if err == "TLE" and s.get("slow"):
                continue  # the perf check below covers slow solutions
            if err or not pyjudge.same(got, exp, cmp, a, hooks):
                problems.append(f"{sid} disagrees with reference on {pyjudge.show(a)}: got {pyjudge.show(got)} {err or ''}")
                break
        if not perf:
            continue
        res = pyjudge.judge(p["code"][sid], p, perf, stop_on_fail=True)
        if s.get("slow") and res["verdict"] == "Accepted":
            problems.append(f"warning: slow solution '{sid}' passes perf tests; perf tests don't catch it")
        if not s.get("slow") and res["verdict"] != "Accepted":
            problems.append(f"{sid} fails perf tests: {res['verdict']} {res['results'][:1]}")

    ok = not any(not x.startswith("warning") for x in problems)
    if ok and not check:
        (pdir / "tests.json").write_text(json.dumps({"seed": "crc32(id)", "tests": tests}) + "\n")
    head = f"{'ok' if ok else 'FAIL':4} {p['id']}: {len(tests)} tests ({len(perf)} perf), {len(sols)} solutions"
    return ok, [head] + [f"      {x}" for x in problems]


def run(pdir, check):
    try:
        return build(pdir, check)
    except autogen.Manual as e:
        return False, [f"MANUAL {pdir.name}: {e}"]
    except Exception as e:
        return False, [f"FAIL {pdir.name}: {e!r}"]


def run_all(dirs, check, workers=None):
    with ProcessPoolExecutor(workers, mp_context=multiprocessing.get_context("spawn")) as pool:
        return dict(zip(dirs, pool.map(run, dirs, [check] * len(dirs))))


if __name__ == "__main__":
    args = cli(__doc__, ("--check", "verify only, don't write tests.json"))
    todo = selected(problem_dirs(args.dir), args.slugs)
    os.environ["PYTHONHASHSEED"] = "0"  # spawned workers inherit it: set order in generators stays stable
    results = run_all(todo, args.check)
    # perf timings are skewed under full load: retry failures one at a time
    results |= run_all([d for d, (ok, _) in results.items() if not ok], args.check, workers=1)
    for _, lines in results.values():
        print("\n".join(lines))
    sys.exit(0 if all(ok for ok, _ in results.values()) else 1)
