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
    if (user) void navigate({ to: "/finix" });
  }, [user, navigate]);

  async function onSignIn(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    const { error: err } = await supabase.auth.signInWithPassword({ email, password });
    setBusy(false);
    if (err) setError(err.message);
    else void navigate({ to: "/finix" });
  }

  return (
    <div className="mx-auto max-w-md px-6 py-20">
      <h1 className="text-3xl font-bold tracking-tight text-foreground">Sign in</h1>
      <p dir="rtl" className="mt-2 font-arabic text-lg text-muted-foreground">
        الدخول ببيانات الاعتماد الصادرة من إدارة الأكاديمية
      </p>
      <p className="mt-4 text-sm text-muted-foreground">
        Accounts are issued by the academy administrator. There is no public registration.
      </p>

      <form onSubmit={onSignIn} className="mt-8 space-y-4">
        <Field label="Email" value={email} onChange={setEmail} type="email" />
        <Field label="Password" value={password} onChange={setPassword} type="password" />
        {error && <p className="text-sm text-destructive">{error}</p>}
        <button
          type="submit"
          disabled={busy}
          className="w-full rounded-lg bg-primary px-4 py-2.5 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
        >
          {busy ? "Please wait…" : "Sign in"}
        </button>
      </form>
    </div>
  );
}

function Field({
  label,
  value,
  onChange,
  type,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  type: string;
}) {
  return (
    <label className="block">
      <span className="mb-1.5 block text-xs font-semibold uppercase tracking-widest text-foreground/70">
        {label}
      </span>
      <input
        required
        type={type}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-foreground outline-none focus:border-accent"
      />
    </label>
  );
}
