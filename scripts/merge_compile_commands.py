#!/usr/bin/env python3
"""Merge per-package compile_commands.json files and optionally remap container paths."""
import argparse
import glob
import json
import sys
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(
        description="Merge per-package compile_commands.json and remap paths"
    )
    parser.add_argument(
        "--workspace", required=True, help="Path to catkin workspace root"
    )
    parser.add_argument(
        "--container-path",
        default=None,
        help="Container-side workspace path to remap from. If omitted, no remapping.",
    )
    parser.add_argument(
        "--host-path",
        default=None,
        help="Host-side workspace path to remap to. Defaults to --workspace value.",
    )
    args = parser.parse_args()

    workspace = Path(args.workspace).resolve()
    host_path = args.host_path or str(workspace)
    container_path = args.container_path
    do_remap = container_path is not None and container_path != host_path

    pattern = str(workspace / "build" / "*" / "compile_commands.json")
    files = sorted(glob.glob(pattern))

    if not files:
        print(f"No compile_commands.json found in {workspace}/build/*/", file=sys.stderr)
        sys.exit(1)

    all_entries = []
    for ccj in files:
        with open(ccj) as f:
            entries = json.load(f)
        for entry in entries:
            # Skip gtest/gmock entries (container-only, not project code)
            if entry.get("file", "").startswith("/usr/src/googletest"):
                continue
            if do_remap:
                for key in ("directory", "file", "command"):
                    if key in entry:
                        entry[key] = entry[key].replace(container_path, host_path)
            all_entries.append(entry)

    output = workspace / "compile_commands.json"
    with open(output, "w") as f:
        json.dump(all_entries, f, indent=2)

    print(f"Merged {len(files)} files -> {len(all_entries)} entries -> {output}")


if __name__ == "__main__":
    main()
