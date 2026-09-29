import argparse, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def cli(doc, *flags):
    """argparse for `[slug ...] [--course dsa] [--flag ...]`; adds `.dir` (the course folder)."""
    ap = argparse.ArgumentParser(description=doc)
    ap.add_argument("slugs", nargs="*")
    ap.add_argument("--course", default="dsa")
    for name, help in flags:
        ap.add_argument(name, action="store_true", help=help)
    args = ap.parse_args()
    args.dir = ROOT / "courses" / args.course
    return args


def problem_dirs(course_dir):
    """{slug: folder}, sorted by folder name (0001-two-sum → two-sum)."""
    base = course_dir / "problems"
    return {re.sub(r"^\d+-", "", d.name): d for d in sorted(base.iterdir()) if d.is_dir()} if base.exists() else {}


def selected(dirs, slugs):
    """Folders for the given slugs, or every problem when none are given."""
    if missing := [s for s in slugs if s not in dirs]:
        sys.exit(f"unknown problem: {', '.join(missing)}")
    return [dirs[s] for s in slugs] if slugs else list(dirs.values())
