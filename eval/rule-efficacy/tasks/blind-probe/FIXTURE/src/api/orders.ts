import { fetchJson } from './client';

export interface Order { id: string; total: number }

export const listOrders = () => fetchJson<Order[]>('/api/orders');
