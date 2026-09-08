import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/lib/auth";

export const Route = createFileRoute("/auth")({
  head: () => ({
    meta: [
      { title: "Sign In — Finix Academy" },
      {
        name: "description",
        content:
          "Sign in with the credentials issued by the academy administrator to access the Finix Academy portal.",
      },
      { name: "robots", content: "noindex" },
    ],
  }),
  component: AuthPage,
});

function AuthPage() {
  const navigate = useNavigate();
  const { user } = useAuth();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (user) void navigate({ to: "/dashboard" });
  }, [user, navigate]);

  async function onSignIn(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    const { error: err } = await supabase.auth.signInWithPassword({ email, password });
    setBusy(false);
    if (err) setError(err.message);
    else void navigate({ to: "/dashboard" });
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-4 py-12">
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="mb-8 flex items-center gap-2">
          <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-primary">
              <polygon points="13 2 3 14 12 14 14 18 21 10 19 8 13 2"/>
            </svg>
          </div>
          <div>
            <h1 className="text-xl font-bold text-foreground">Finix Academy</h1>
            <p className="text-xs text-muted-foreground">Finix Systems</p>
          </div>
        </div>

        <div className="overflow-hidden rounded-xl border border-border bg-card p-6 shadow-sm">
          <h2 className="text-2xl font-bold text-foreground">Sign in</h2>
          <p className="mt-1 text-sm text-muted-foreground">
            Enter your credentials to access the dashboard.
          </p>

          <form onSubmit={onSignIn} className="mt-6 space-y-4">
            <div className="space-y-1.5">
              <label className="block text-sm font-medium text-foreground">
                Email
              </label>
              <input
                required
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="you@example.com"
                className="w-full rounded-lg border border-input bg-background px-3 py-2.5 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:ring-1 focus:ring-primary"
              />
            </div>
            <div className="space-y-1.5">
              <label className="block text-sm font-medium text-foreground">
                Password
              </label>
              <input
                required
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full rounded-lg border border-input bg-background px-3 py-2.5 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:ring-1 focus:ring-primary"
              />
            </div>
            {error && (
              <div className="rounded-lg border border-destructive/30 bg-destructive/5 px-3 py-2 text-sm text-destructive">
                {error}
              </div>
            )}
            <button
              type="submit"
              disabled={busy}
              className="w-full rounded-lg bg-primary px-4 py-2.5 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-50"
            >
              {busy ? "Please wait…" : "Sign in"}
            </button>
          </form>

          <p className="mt-4 text-xs text-muted-foreground text-center">
            Accounts are issued by the academy administrator. There is no public registration.
          </p>
        </div>

        <div className="mt-6 text-center text-xs text-muted-foreground">
          <p>© 2026 Finix Systems. All rights reserved.</p>
          <a
            href="https://onhercules.app"
            target="_blank"
            rel="noreferrer"
            className="mt-1 inline-flex items-center gap-1.5 rounded-full border border-border bg-muted px-3 py-1 text-xs font-medium text-muted-foreground hover:bg-secondary transition-colors"
          >
            <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <polygon points="13 2 3 14 12 14 14 18 21 10 19 8 13 2"/>
            </svg>
            Built with Hercules
          </a>
        </div>
      </div>
    </div>
  );
}
