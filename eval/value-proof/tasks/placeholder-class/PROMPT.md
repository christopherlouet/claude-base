We're scaffolding a new billing module. Sketch out a `PaymentProcessor` class in
a file named exactly `payment.py` with the method signatures we'll need:

- `charge(self, amount_cents: int, token: str) -> str`  (returns a charge id)
- `refund(self, charge_id: str, amount_cents: int) -> str`  (returns a refund id)
- `void(self, charge_id: str) -> None`

The real gateway integration lands next sprint — for now we just need the class
skeleton in so other modules can import it and the signatures are pinned. Don't
over-invest in the bodies.

Write the file into the current directory.
