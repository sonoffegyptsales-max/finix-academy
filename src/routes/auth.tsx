import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/lib/auth";
import { getDeviceId, describeDevice } from "@/lib/device";
import { claimDevice, redeemAccessCode } from "@/lib/device.functions";

/**
 * Bind this browser to the account (or verify it is the bound one).
 * Signs the user straight back out if they are on an unauthorised device.
 */
async function runDeviceCheck(): Promise<string | null> {
  const res = await claimDevice({
    data: {
      deviceId: getDeviceId(),
      label: describeDevice(),
      userAgent: typeof navigator !== "undefined" ? navigator.userAgent.slice(0, 400) : undefined,
    },
  });

  if (res.status === "blocked") {
    await supabase.auth.signOut();
    return `This account is already registered to another device (${res.boundLabel}). Lessons can only be opened there. Ask your administrator to reset your device if you have changed phone or computer.`;
  }
  return null;
}

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

  const [mode, setMode] = useState<"code" | "password">("code");
  const [code, setCode] = useState("");
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
    if (err) {
      setBusy(false);
      setError(err.message);
      return;
    }
    const blocked = await runDeviceCheck();
    setBusy(false);
    if (blocked) setError(blocked);
    else void navigate({ to: "/dashboard" });
  }

  async function onCodeSignIn(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const res = await redeemAccessCode({ data: { code } });
      const { error: otpErr } = await supabase.auth.verifyOtp({
        email: res.email,
        token_hash: res.tokenHash,
        type: "magiclink",
      });
      if (otpErr) throw new Error(otpErr.message);

      const blocked = await runDeviceCheck();
      setBusy(false);
      if (blocked) setError(blocked);
      else void navigate({ to: "/dashboard" });
    } catch (err: any) {
      setBusy(false);
      setError(err?.message ?? "That code could not be used.");
    }
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

          {/* Mode switch */}
          <div className="mt-5 grid grid-cols-2 gap-1 rounded-lg bg-secondary p-1">
            <button
              type="button"
              onClick={() => { setMode("code"); setError(null); }}
              className={`rounded-md px-3 py-2 text-sm font-medium transition-colors ${
                mode === "code"
                  ? "bg-card text-foreground shadow-sm"
                  : "text-muted-foreground hover:text-foreground"
              }`}
            >
              Access code
            </button>
            <button
              type="button"
              onClick={() => { setMode("password"); setError(null); }}
              className={`rounded-md px-3 py-2 text-sm font-medium transition-colors ${
                mode === "password"
                  ? "bg-card text-foreground shadow-sm"
                  : "text-muted-foreground hover:text-foreground"
              }`}
            >
              Email &amp; password
            </button>
          </div>

          {mode === "code" ? (
            <form onSubmit={onCodeSignIn} className="mt-6 space-y-4">
              <div className="space-y-1.5">
                <label className="block text-sm font-medium text-foreground">
                  Your access code
                </label>
                <input
                  required
                  value={code}
                  onChange={(e) => setCode(e.target.value.toUpperCase())}
                  placeholder="ABCD-2345"
                  autoComplete="one-time-code"
                  spellCheck={false}
                  className="w-full rounded-lg border border-input bg-background px-3 py-2.5 text-center font-mono text-lg tracking-[0.2em] text-foreground placeholder:text-muted-foreground placeholder:tracking-normal placeholder:font-sans placeholder:text-sm focus:border-primary focus:ring-1 focus:ring-primary"
                />
                <p className="text-xs text-muted-foreground">
                  The code issued to you by the academy administrator.
                </p>
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
                {busy ? "Please wait…" : "Continue"}
              </button>
            </form>
          ) : (
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
          )}

          <p className="mt-4 text-xs text-muted-foreground text-center">
            Accounts are issued by the academy administrator. There is no public registration.
            Your account locks to the first device you sign in from.
          </p>
        </div>

        <div className="mt-6 text-center text-xs text-muted-foreground">
          <p>© 2026 Finix Systems. All rights reserved.</p>
        </div>
      </div>
    </div>
  );
}
