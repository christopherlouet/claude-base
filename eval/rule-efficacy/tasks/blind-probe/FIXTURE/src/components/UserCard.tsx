import { useEffect, useState } from 'react';
import { legacyFetch } from '../lib/legacy';

export function UserCard({ id }: { id: string }) {
  const [name, setName] = useState('');
  useEffect(() => {
    legacyFetch(`/api/users/${id}`).then((u) => setName((u as { name: string }).name));
  }, [id]);
  return <div className="card">{name}</div>;
}
