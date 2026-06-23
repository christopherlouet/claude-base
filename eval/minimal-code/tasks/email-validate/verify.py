"""Correctness check for the email-validate task. Usage: python3 verify.py <solution-dir>"""

import importlib.util
import os
import sys

sol = sys.argv[1] if len(sys.argv) > 1 else ""
target = os.path.join(sol, "email_validate.py")
if not os.path.isfile(target):
    print("email_validate.py not found", file=sys.stderr)
    sys.exit(1)

spec = importlib.util.spec_from_file_location("sol_email_validate", target)
mod = importlib.util.module_from_spec(spec)
try:
    spec.loader.exec_module(mod)
    is_valid_email = mod.is_valid_email
except Exception as e:  # noqa: BLE001 — any import/exec failure is a fail
    print(f"cannot load is_valid_email: {e}", file=sys.stderr)
    sys.exit(1)

CASES = [
    ("a@b.com", True),
    ("x.y@z.co.uk", True),
    ("user+tag@example.org", True),
    ("nope", False),
    ("a@", False),
    ("@b.com", False),
    ("a b@c.com", False),
    ("a@b", False),  # domain needs a dot
    ("", False),
]
for inp, exp in CASES:
    try:
        got = bool(is_valid_email(inp))
    except Exception as e:  # noqa: BLE001
        print(f"raised on {inp!r}: {e}", file=sys.stderr)
        sys.exit(1)
    if got != exp:
        print(f"FAIL {inp!r}: expected {exp}, got {got}", file=sys.stderr)
        sys.exit(1)

sys.exit(0)
