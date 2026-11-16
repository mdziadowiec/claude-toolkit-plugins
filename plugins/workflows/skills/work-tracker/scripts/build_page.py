"""Build a work-tracker page from the template.

Live page (database-backed):
    python -I build_page.py --title "Loader refactor tracker" --out page.html

Frozen page (state baked in, no database access), from the JSON files that
`ArtifactData list ... out_dir=<dir>` wrote for meta, phases, items and log:
    python -I build_page.py --title "Loader refactor tracker" --out page.html \
        --snapshot-dir <dir> --closed 2026-11-20
"""

import argparse
import html
import json
import pathlib
import sys

TEMPLATE = pathlib.Path(__file__).resolve().parent.parent / "assets" / "tracker.html"
EMPTY_SNAPSHOT = '<script type="application/json" id="snapshot">null</script>'


def document_body(path):
    """Return the document fields of one exported file and its id (the file name)."""
    raw = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(raw, dict) and isinstance(raw.get("data"), dict):
        raw = raw["data"]
    if not isinstance(raw, dict):
        sys.exit(f"{path}: expected a JSON object")
    return path.stem, raw


def collection(root, name):
    folder = root / name
    if not folder.is_dir():
        return []
    return [document_body(p) for p in sorted(folder.glob("*.json"))]


def snapshot(root, closed):
    meta = dict(next((body for doc_id, body in collection(root, "meta") if doc_id == "state"), {}))
    if closed:
        meta["closed"] = closed
    return {
        "meta": meta,
        "phases": [{"key": doc_id, **body} for doc_id, body in collection(root, "phases")],
        "items": [{"code": doc_id, **body} for doc_id, body in collection(root, "items")],
        "log": [{"id": doc_id, **body} for doc_id, body in collection(root, "log")],
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--title", required=True, help="page title; ends in 'tracker' so /work-tracker list finds it")
    parser.add_argument("--out", required=True, type=pathlib.Path)
    parser.add_argument("--snapshot-dir", type=pathlib.Path, help="ArtifactData out_dir holding meta/, phases/, items/, log/")
    parser.add_argument("--closed", help="closing date shown on a frozen page (YYYY-MM-DD)")
    args = parser.parse_args()

    page = TEMPLATE.read_text(encoding="utf-8")
    if EMPTY_SNAPSHOT not in page:
        sys.exit("template: snapshot block not found")
    page = page.replace("__TRACKER_TITLE__", html.escape(args.title, quote=False))

    if args.snapshot_dir:
        data = json.dumps(snapshot(args.snapshot_dir, args.closed), ensure_ascii=False)
        # "</" would end the script element early; "<" is the same character to JSON.parse.
        data = data.replace("<", "\\u003c")
        page = page.replace(EMPTY_SNAPSHOT, f'<script type="application/json" id="snapshot">{data}</script>')

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(page, encoding="utf-8", newline="\n")
    print(args.out)


if __name__ == "__main__":
    main()
