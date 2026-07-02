#!/usr/bin/env python3
"""
Generate 1250 PPG signal values for Postman POST /patient/signals raw_data field.

Formula (index i = 0..1249):
  value = round(sin(2*pi*i/125) * 0.8 + sin(2*pi*i/25) * 0.2, 4)

Usage:
  python scripts/generate_ppg_raw_data.py
  python scripts/generate_ppg_raw_data.py --output storage/ppg_raw_data.json
"""

import argparse
import json
import math
import sys


def generate_ppg_signal(length: int = 1250) -> list[float]:
    return [
        round(math.sin(2 * math.pi * i / 125) * 0.8 + math.sin(2 * math.pi * i / 25) * 0.2, 4)
        for i in range(length)
    ]


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate PPG raw_data array for Postman")
    parser.add_argument(
        "--output",
        "-o",
        help="Write JSON array to file (default: print to stdout)",
    )
    parser.add_argument("--length", type=int, default=1250, help="Number of samples (default: 1250)")
    args = parser.parse_args()

    values = generate_ppg_signal(args.length)

    if len(values) != args.length:
        print(f"Error: expected {args.length} values, got {len(values)}", file=sys.stderr)
        return 1

    payload = json.dumps(values, separators=(",", ":"))

    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(payload)
        print(f"Wrote {len(values)} values to {args.output}")
        print(f"First 10: {values[:10]}")
        print(f"Last 10:  {values[-10:]}")
    else:
        print(payload)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
