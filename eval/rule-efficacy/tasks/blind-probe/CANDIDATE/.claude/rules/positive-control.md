# Positive Control Before Trusting "Nothing"

WHEN a check answers nothing — no match, 0 findings, "OK", "clean", green, empty output —
THEN, before concluding, make that same check find a PLANTED or known-positive case, or
confirm with an independent method.

A blind check (a glob that skips a file type, a filtered path, a swallowed error, a pipe
that reports only its last stage) answers exactly like a true negative. Only a check that
has been seen to find something can be trusted when it finds nothing.
