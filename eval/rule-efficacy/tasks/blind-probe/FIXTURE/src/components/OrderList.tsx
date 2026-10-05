import { useEffect, useState } from 'react';
import { listOrders, type Order } from '../api/orders';

export function OrderList() {
  const [orders, setOrders] = useState<Order[]>([]);
  useEffect(() => { listOrders().then(setOrders); }, []);
  return <ul>{orders.map((o) => <li key={o.id}>{o.total}</li>)}</ul>;
}
