#!/usr/bin/env python3
import argparse
import json
import os

def main():
	parser = argparse.ArgumentParser(description="Simulate model modification")
    parser.add_argument(
        "--model-dir",
        default="model",
        help="Directory containing downloaded model files"
    )
    args = parser.parse_args()

    cfg_path = os.path.join(args.model_dir, "config.json")
    if os.path.isfile(cfg_path):
        with open(cfg_path, "r") as f:
            cfg = json.load(f)
        cfg["modified_by_user"] = True
        with open(cfg_path, "w") as f:
            json.dump(cfg, f, indent=2)
        print(f"Updated '{cfg_path}' with modified_by_user flag.")
    else:
        print(f"Warning: '{cfg_path}' not found, skipping config update.")

    # add a dummy marker
    note_path = os.path.join(args.model_dir, "custom_note.txt")
    with open(note_path, "w") as f:
        f.write("User modification placeholder.\n")
    print(f"Added marker file '{note_path}'.")

if __name__ == "__main__":
    main()