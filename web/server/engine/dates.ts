// Local calendar dates as 'YYYY-MM-DD' strings. Weeks start on Monday.

export function localDate(d = new Date()): string {
  const p = (n: number) => String(n).padStart(2, "0");
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}`;
}

export function parseDate(s: string): Date {
  const [y, m, d] = s.split("-").map(Number);
  return new Date(y, m - 1, d);
}

export function addDays(s: string, n: number): string {
  const d = parseDate(s);
  d.setDate(d.getDate() + n);
  return localDate(d);
}

export function weekStart(s: string): string {
  const day = (parseDate(s).getDay() + 6) % 7; // Mon = 0
  return addDays(s, -day);
}
