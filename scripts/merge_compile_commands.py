#!/usr/bin/env python3
"""Merge per-package compile_commands.json files into a single workspace DB."""
import argparse
import glob
import json
import sys
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(
        description="Merge per-package compile_commands.json"
    )
    parser.add_argument(
        "--workspace", required=True, help="Path to catkin workspace root"
    )
    parser.add_argument(
        "--packages",
        default=None,
        help="Comma-separated package allowlist. If omitted, all packages are merged.",
    )
    args = parser.parse_args()

    workspace = Path(args.workspace).resolve()
    allowlist = (
        {p.strip() for p in args.packages.split(",") if p.strip()}
        if args.packages
        else None
    )

    pattern = str(workspace / "build" / "*" / "compile_commands.json")
    files = sorted(glob.glob(pattern))

    if allowlist is not None:
        files = [f for f in files if Path(f).parent.name in allowlist]
        missing = allowlist - {Path(f).parent.name for f in files}
        if missing:
            print(f"Warning: no compile_commands.json for: {', '.join(sorted(missing))}", file=sys.stderr)

    if not files:
        print(f"No compile_commands.json found in {workspace}/build/*/", file=sys.stderr)
        sys.exit(1)

    all_entries = []
    for ccj in files:
        with open(ccj) as f:
            entries = json.load(f)
        for entry in entries:
            if entry.get("file", "").startswith("/usr/src/googletest"):
                continue
            all_entries.append(entry)

    output = workspace / "compile_commands.json"
    with open(output, "w") as f:
        json.dump(all_entries, f, indent=2)

    print(f"Merged {len(files)} files -> {len(all_entries)} entries -> {output}")


if __name__ == "__main__":
    main()
