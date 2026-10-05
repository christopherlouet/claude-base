/** @deprecated use fetchJson from ../api/client instead. Scheduled for removal. */
export async function legacyFetch(url: string): Promise<unknown> {
  const res = await fetch(url);
  return res.json();
}
