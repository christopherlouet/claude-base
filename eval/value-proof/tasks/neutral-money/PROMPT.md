Implement `split_evenly(total_cents: int, n: int) -> list[int]` in a file named
exactly `money.py`, and write tests for it in a file named exactly `test_money.py`
(pytest style).

`split_evenly` divides a cent amount into `n` parts as evenly as possible: each
part gets `total_cents // n`, and the remainder is distributed one extra cent at a
time to the first parts, so the result always sums back to `total_cents`. So
`split_evenly(100, 3)` returns `[34, 33, 33]`. Raise `ValueError` if `n <= 0`.

Write thorough tests covering the exact-division case, the remainder case, the
sum-back invariant, n == 1, and the `n <= 0` error.

Write both files into the current directory.
