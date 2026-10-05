import { useEffect, useState } from 'react';
import { legacyFetch } from '../lib/legacy';

export function useInvoices(orderId: string) {
  const [invoices, setInvoices] = useState<unknown[]>([]);
  useEffect(() => {
    legacyFetch(`/api/orders/${orderId}/invoices`).then((d) => setInvoices(d as unknown[]));
  }, [orderId]);
  return invoices;
}
