import { useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/lib/auth";
import { useLang } from "@/lib/language";

/**
 * Signed-in staff change their OWN password. The current password is checked
 * first so an unattended open session can't be used to take over the account.
 * The new password goes straight from this form to Supabase Auth; it is never
 * sent to our server functions or stored anywhere readable.
 */
export function ChangePasswordCard() {
  const { t } = useLang();
  const { user } = useAuth();
  const [current, setCurrent] = useState("");
  const [next, setNext] = useState("");
  const [confirm, setConfirm] = useState("");
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<{ kind: "ok" | "err"; text: string } | null>(null);

  const strength = (() => {
    let s = 0;
    if (next.length >= 12) s++;
    if (next.length >= 16) s++;
    if (/[a-z]/.test(next) && /[A-Z]/.test(next)) s++;
    if (/\d/.test(next)) s++;
    if (/[^A-Za-z0-9]/.test(next)) s++;
    if (/(19|20)\d\d/.test(next)) s--; // years are the first thing attackers try
    return Math.max(0, Math.min(4, s));
  })();
  const strengthLabel = [
    t("Very weak", "ضعيفة جدًا"),
    t("Weak", "ضعيفة"),
    t("Fair", "مقبولة"),
    t("Good", "كويسة"),
    t("Strong", "قوية"),
  ][strength];
  const strengthColor = ["bg-red-500", "bg-red-400", "bg-amber-500", "bg-green-500", "bg-green-600"][strength];

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setMsg(null);
    if (!user?.email) return setMsg({ kind: "err", text: t("No e-mail on this account.", "الحساب ده مالوش إيميل.") });
    if (next.length < 10)
      return setMsg({ kind: "err", text: t("Use at least 10 characters.", "استخدم 10 حروف على الأقل.") });
    if (next !== confirm) return setMsg({ kind: "err", text: t("The two new passwords don't match.", "كلمتين السر الجداد مش زي بعض.") });
    if (next === current) return setMsg({ kind: "err", text: t("Choose a different password.", "اختار كلمة سر مختلفة.") });

    setBusy(true);
    const { error: authErr } = await supabase.auth.signInWithPassword({ email: user.email, password: current });
    if (authErr) {
      setBusy(false);
      return setMsg({ kind: "err", text: t("Current password is wrong.", "كلمة السر الحالية غلط.") });
    }
    const { error } = await supabase.auth.updateUser({ password: next });
    setBusy(false);
    if (error) return setMsg({ kind: "err", text: error.message });
    setCurrent("");
    setNext("");
    setConfirm("");
    setMsg({ kind: "ok", text: t("Password changed. Use it next time you sign in.", "كلمة السر اتغيرت. استخدمها المرة الجاية وانت بتدخل.") });
  };

  const input =
    "w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground outline-none focus:border-primary";

  return (
    <div className="max-w-md rounded-xl border border-border bg-card p-5">
      <h2 className="text-lg font-semibold text-foreground">{t("Change my password", "تغيير كلمة السر بتاعتي")}</h2>
      <p className="mt-1 text-xs text-muted-foreground" dir="ltr" style={{ textAlign: "start" }}>
        {user?.email}
      </p>
      <form onSubmit={submit} className="mt-4 space-y-3">
        <label className="block text-sm">
          <span className="font-medium text-foreground">{t("Current password", "كلمة السر الحالية")}</span>
          <input className={`${input} mt-1`} type="password" autoComplete="current-password" value={current} onChange={(e) => setCurrent(e.target.value)} required />
        </label>
        <label className="block text-sm">
          <span className="font-medium text-foreground">{t("New password", "كلمة السر الجديدة")}</span>
          <input className={`${input} mt-1`} type="password" autoComplete="new-password" value={next} onChange={(e) => setNext(e.target.value)} required />
        </label>
        {next && (
          <div>
            <div className="h-1.5 overflow-hidden rounded-full bg-secondary">
              <div className={`h-full ${strengthColor}`} style={{ width: `${((strength + 1) / 5) * 100}%` }} />
            </div>
            <p className="mt-1 text-xs text-muted-foreground">
              {strengthLabel}
              {strength < 3 &&
                " — " +
                  t(
                    "a long phrase of 3–4 unrelated words is stronger and easier to remember",
                    "جملة طويلة من 3–4 كلمات ملهاش علاقة ببعض أقوى وأسهل في الحفظ",
                  )}
            </p>
          </div>
        )}
        <label className="block text-sm">
          <span className="font-medium text-foreground">{t("Repeat new password", "كرر كلمة السر الجديدة")}</span>
          <input className={`${input} mt-1`} type="password" autoComplete="new-password" value={confirm} onChange={(e) => setConfirm(e.target.value)} required />
        </label>
        {msg && (
          <p className={`rounded-lg px-3 py-2 text-sm ${msg.kind === "ok" ? "bg-green-50 text-green-800" : "bg-destructive/10 text-destructive"}`}>
            {msg.text}
          </p>
        )}
        <button
          type="submit"
          disabled={busy}
          className="rounded-lg bg-primary px-5 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
        >
          {busy ? t("Saving…", "جارٍ الحفظ…") : t("Change password", "تغيير كلمة السر")}
        </button>
      </form>
    </div>
  );
}
