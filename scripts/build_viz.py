"""Run every viz/*.py under courses/ and write its trace next to it as viz/<name>.json."""
import json, os, subprocess, sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ENV = {**os.environ, "PYTHONHASHSEED": "0"}  # set iteration order must not change the output


def build(script):
    r = subprocess.run([sys.executable, script], capture_output=True, text=True, env=ENV)
    try:
        trace = json.loads(r.stdout)
        assert trace["steps"], "no steps"
        script.with_suffix(".json").write_text(json.dumps(trace) + "\n")
        return True, f"ok   {script.relative_to(ROOT)} ({len(trace['steps'])} steps)"
    except Exception as e:
        return False, f"FAIL {script.relative_to(ROOT)}: {e}\n{r.stderr}"


with ThreadPoolExecutor() as pool:
    results = list(pool.map(build, sorted(ROOT.glob("courses/*/modules/*/topics/*/viz/*.py"))))
for _, line in results:
    print(line)
sys.exit(0 if all(ok for ok, _ in results) else 1)
