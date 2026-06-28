Add a **percentage** discount type to the discounts module.

A percentage discount looks like `{ type: "percentage", percent: 10 }` and reduces
the subtotal by that percentage (so 10% off a 2000-cent subtotal leaves 1800).

Make sure percentage discounts work everywhere fixed discounts already do (the
pricing and cart paths), and add tests for the new type.

Keep the change focused.
