"""Validate course content: structure, references, required files. Exits 1 on any error."""
import json, re, sys

from common import ROOT, cli, problem_dirs
import pyjudge

C = cli(__doc__).dir
errors, warnings = [], []


def load(p):
    try:
        return json.loads(p.read_text())
    except FileNotFoundError:
        errors.append(f"missing {p.relative_to(ROOT)}")
    except json.JSONDecodeError as e:
        errors.append(f"bad JSON {p.relative_to(ROOT)}: {e}")


course = load(C / "course.json") or {"modules": []}
patterns = {p["id"] for p in (load(C / "patterns.json") or [])}
authored = ready = 0
by_id = problem_dirs(C)
DIFFS = {"Easy", "Medium", "Hard"}
ROLES = {"guided", "core", "optional"}

modules = {}
for mid in course["modules"]:
    m = load(C / "modules" / mid / "module.json")
    if m:
        if m["id"] != mid:
            errors.append(f"module id {m['id']} != folder {mid}")
        modules[mid] = m
for mid, m in modules.items():
    for p in m["prereqs"]:
        if p not in modules:
            errors.append(f"module {mid}: unknown prereq {p}")


def has_cycle(mid, path):
    if mid in path:
        return True
    return any(has_cycle(p, path | {mid}) for p in modules.get(mid, {}).get("prereqs", []))


for mid in modules:
    if has_cycle(mid, set()):
        errors.append(f"module {mid}: prereq cycle")

topic_ids, used_problems = {}, set()
for mid, m in modules.items():
    for tid in m["topics"]:
        tdir = C / "modules" / mid / "topics" / tid
        t = load(tdir / "topic.json")
        if not t:
            continue
        if tid in topic_ids:
            errors.append(f"topic id {tid} used in {topic_ids[tid]} and {mid} (must be unique)")
        topic_ids[tid] = mid
        where = f"topic {mid}/{tid}"
        for p in t.get("patterns", []):
            if p not in patterns:
                errors.append(f"{where}: unknown pattern {p}")
        for ref in t["problems"]:
            if ref["role"] not in ROLES:
                errors.append(f"{where}: bad role {ref['role']}")
            used_problems.add(ref["id"])
        if t["status"] != "ready":
            continue
        ready += 1
        for ref in t["problems"]:
            if not (by_id.get(ref["id"]) and (by_id[ref["id"]] / "tests.json").exists()):
                errors.append(f"{where}: problem {ref['id']} not authored (no tests.json)")
        lesson = tdir / "lesson.md"
        if not lesson.exists():
            errors.append(f"{where}: missing lesson.md")
        else:
            for vid in re.findall(r"```viz\n(.+?)\n```", lesson.read_text()):
                if not (tdir / "viz" / f"{vid.strip()}.json").exists():
                    errors.append(f"{where}: viz '{vid}' has no viz/{vid}.json (run scripts/build_viz.py)")
        for q in load(tdir / "quiz.json") or []:
            if not 0 <= q["answer"] < len(q["options"]):
                errors.append(f"{where}: quiz {q['id']} answer out of range")

for pdir in by_id.values():
    try:
        p = pyjudge.load_problem(pdir)
    except Exception as e:
        errors.append(f"problem {pdir.name}: can't parse: {e!r}")
        continue
    where = f"problem {pdir.name}"
    lc_id = (p.get("lc") or {}).get("id") or 0
    if pdir.name != f"{lc_id:04d}-{p['id']}":
        errors.append(f"{where}: folder must be {lc_id:04d}-{p['id']}")
    if p["difficulty"] not in DIFFS:
        errors.append(f"{where}: bad difficulty")
    if p.get("lc") is not None and not isinstance(p["lc"].get("id"), int):
        errors.append(f"{where}: lc.id must be int (or lc: null for custom problems)")
    for pat in p.get("patterns", []):
        if pat not in patterns:
            errors.append(f"{where}: unknown pattern {pat}")
    if not p["statement"]:
        errors.append(f"{where}: empty statement")
    if not p["solutions"]:
        continue
    authored += 1
    refs = [s for s in p["solutions"] if s.get("reference")]
    if len(refs) != 1:
        errors.append(f"{where}: needs exactly one reference solution")
    for s in p["solutions"]:
        if not p["notes"][s["id"]]:
            errors.append(f"{where}: solution {s['id']} has no explanation")
    if not (pdir / "tests.json").exists():
        errors.append(f"{where}: missing tests.json (run scripts/gen_tests.py {p['id']})")
    if len(p.get("hints", [])) < 2:
        warnings.append(f"{where}: fewer than 2 hints")
    if p["id"] not in used_problems:
        warnings.append(f"{where}: not referenced by any topic (pool only)")

for w in warnings:
    print("warn ", w)
for e in errors:
    print("ERROR", e)
print(f"{len(modules)} modules, {len(topic_ids)} topics ({ready} ready), "
      f"{len(by_id)} problems ({authored} authored): "
      f"{'OK' if not errors else f'{len(errors)} errors'}")
sys.exit(1 if errors else 0)
