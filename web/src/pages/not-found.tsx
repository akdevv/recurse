import { Link, useLocation } from "react-router";

export default function NotFound() {
  const { pathname } = useLocation();
  return (
    <div className="mx-auto flex max-w-3xl flex-col gap-2 p-8">
      <h1 className="text-2xl font-semibold">Page not found</h1>
      <p className="font-mono text-sm text-muted-foreground">{pathname}</p>
      <Link to="/" className="mt-2 text-sm text-primary hover:underline">
        Back to Home
      </Link>
    </div>
  );
}
