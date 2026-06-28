Build an order-lifecycle state machine in TypeScript, split across modules:

- `states.ts` — the `OrderState` type (`"cart" | "placed" | "paid" | "shipped" |
  "delivered" | "cancelled"`) and the `OrderEvent` type (`"place" | "pay" |
  "ship" | "deliver" | "cancel"`).
- `transitions.ts` — `nextState(state: OrderState, event: OrderEvent):
  OrderState` returning the resulting state, and `canTransition(state, event):
  boolean`. The legal transitions are: cart→place→placed, placed→pay→paid,
  paid→ship→shipped, shipped→deliver→delivered; `cancel` is legal from cart,
  placed, and paid (→cancelled) but NOT from shipped or delivered. Any other
  pairing is illegal. `nextState` on an illegal transition throws an `Error`
  naming the state and event.
- `machine.ts` — an `OrderMachine` class holding the current state (starts at
  "cart"), with `apply(event)` (advances or throws), `current()`, and
  `history()` (the list of states it has been through).

Write tests — `transitions.test.ts` and `machine.test.ts` — covering every legal
transition, a representative set of illegal transitions (each rejected), the
cancel rules (legal early, illegal after shipping), and the machine's history
tracking.

Write all five files into the current directory. Make it correct and well-tested.
