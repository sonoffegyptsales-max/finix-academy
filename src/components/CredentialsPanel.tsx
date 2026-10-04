import { useEffect, useState } from "react";
import { useLang } from "@/lib/language";
import { getTraineeCredentials, resetTraineePassword } from "@/lib/trainees.functions";
import { issueAccessCode } from "@/lib/device.functions";

type Creds = {
  email: string;
  fullName: string | null;
  phone: string | null;
  code: string | null;
  codeLastUsedAt: string | null;
  lastSignInAt: string | null;
};

const small = "rounded-lg px-3 py-1.5 text-xs font-medium transition-colors disabled:opacity-50";

function waUrl(phone: string | null, text: string) {
  const p = (phone ?? "").replace(/[^\d+]/g, "");
  const intl = p.startsWith("0") ? "2" + p : p.replace(/^\+/, "");
  return `https://wa.me/${intl}?text=${encodeURIComponent(text)}`;
}

export function credentialsMessage(name: string | null, email: string, code: string | null, password: string | null) {
  const site = typeof window !== "undefined" ? window.location.origin : "";
  const lines = [
    `أهلًا ${name ?? ""}، دي بيانات دخولك لأكاديمية فينيكس:`,
    `${site}/auth`,
    code ? `كود الدخول: ${code}` : null,
    password ? `أو الإيميل: ${email}\nكلمة السر: ${password}` : `الإيميل: ${email}`,
    "",
    "Your Finix Academy sign-in:",
    code ? `Access code: ${code}` : null,
    password ? `Or email ${email} / password ${password}` : null,
    "الحساب بيتربط بأول جهاز تدخل منه. / The account locks to the first device you use.",
  ];
  return lines.filter((l) => l !== null).join("\n");
}

/**
 * Admin-only panel: open a trainee's sign-in details.
 * The access code is shown as stored. Passwords are one-way hashed by
 * Supabase, so they cannot be displayed -- "New password" sets one and
 * shows it once.
 */
export function CredentialsPanel({ userId, onClose }: { userId: string; onClose?: () => void }) {
  const { t, lang } = useLang();
  const [c, setC] = useState<Creds | null>(null);
  const [password, setPassword] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [copied, setCopied] = useState<string | null>(null);

  useEffect(() => {
    let active = true;
    setC(null);
    setPassword(null);
    void getTraineeCredentials({ data: { userId } })
      .then((r) => active && setC(r as Creds))
      .catch((e) => active && setErr(e instanceof Error ? e.message : String(e)));
    return () => {
      active = false;
    };
  }, [userId]);

  const run = async (fn: () => Promise<void>) => {
    setBusy(true);
    setErr(null);
    try {
      await fn();
    } catch (e) {
      setErr(e instanceof Error ? e.message : String(e));
    } finally {
      setBusy(false);
    }
  };

  const copy = async (key: string, text: string) => {
    try {
      await navigator.clipboard.writeText(text);
      setCopied(key);
      setTimeout(() => setCopied(null), 1500);
    } catch {
      /* clipboard blocked: the value is visible anyway */
    }
  };

  const when = (iso: string | null) => (iso ? new Date(iso).toLocaleString(lang === "ar" ? "ar-EG" : "en-GB") : t("never", "لسه"));

  return (
    <div className="mt-3 rounded-lg border border-primary/30 bg-primary/5 p-4 text-sm">
      <div className="mb-3 flex items-center justify-between">
        <p className="font-semibold text-foreground">{t("Sign-in details", "بيانات الدخول")}</p>
        {onClose && (
          <button onClick={onClose} className="text-xs text-muted-foreground hover:text-foreground">
            {t("Close", "إغلاق")} ✕
          </button>
        )}
      </div>

      {err && <p className="mb-3 rounded bg-destructive/10 px-3 py-2 text-destructive">{err}</p>}
      {!c && !err && <p className="text-muted-foreground">{t("Loading…", "جارٍ التحميل…")}</p>}

      {c && (
        <div className="space-y-3">
          <Row label={t("Email", "الإيميل")} value={c.email} mono onCopy={() => void copy("email", c.email)} copied={copied === "email"} />

          <div>
            <Row
              label={t("Access code", "كود الدخول")}
              value={c.code ?? t("none active", "مفيش كود فعّال")}
              mono={!!c.code}
              big={!!c.code}
              onCopy={c.code ? () => void copy("code", c.code!) : undefined}
              copied={copied === "code"}
            />
            <p className="mt-1 text-xs text-muted-foreground">
              {t("Last used", "آخر استخدام")}: {when(c.codeLastUsedAt)}
            </p>
            <button
              disabled={busy}
              onClick={() =>
                void run(async () => {
                  if (c.code && !confirm(t("Replace the current code? The old one stops working.", "تبدّل الكود الحالي؟ القديم هيبطل يشتغل."))) return;
                  const r = await issueAccessCode({ data: { userId } });
                  setC({ ...c, code: r.code, codeLastUsedAt: null });
                })
              }
              className={`${small} mt-2 border border-border text-foreground hover:bg-secondary`}
            >
              {c.code ? t("New code", "كود جديد") : t("Create code", "إصدار كود")}
            </button>
          </div>

          <div>
            <Row
              label={t("Password", "كلمة السر")}
              value={password ?? t("hidden — stored encrypted", "مخفية — متخزنة مشفّرة")}
              mono={!!password}
              big={!!password}
              onCopy={password ? () => void copy("pw", password) : undefined}
              copied={copied === "pw"}
            />
            {!password && (
              <p className="mt-1 text-xs text-muted-foreground">
                {t(
                  "Passwords can't be shown, even to admins. Set a new one to send it.",
                  "كلمة السر مينفعش تتعرض حتى للأدمن. اعمل واحدة جديدة عشان تبعتها.",
                )}
              </p>
            )}
            {password && (
              <p className="mt-1 text-xs text-amber-700">
                {t("Shown once — send it now. The old password no longer works.", "بتظهر مرة واحدة — ابعتها دلوقتي. القديمة بطّلت تشتغل.")}
              </p>
            )}
            <button
              disabled={busy}
              onClick={() =>
                void run(async () => {
                  if (!confirm(t("Set a new password? The current one stops working.", "تعمل كلمة سر جديدة؟ الحالية هتبطل تشتغل."))) return;
                  const r = await resetTraineePassword({ data: { userId } });
                  setPassword(r.password);
                })
              }
              className={`${small} mt-2 border border-border text-foreground hover:bg-secondary`}
            >
              {t("New password", "كلمة سر جديدة")}
            </button>
          </div>

          <p className="text-xs text-muted-foreground">
            {t("Last sign-in", "آخر دخول")}: {when(c.lastSignInAt)}
          </p>

          <div className="flex flex-wrap gap-2 border-t border-border pt-3">
            <button
              onClick={() => void copy("all", credentialsMessage(c.fullName, c.email, c.code, password))}
              className={`${small} bg-primary text-primary-foreground hover:bg-primary/90`}
            >
              {copied === "all" ? t("Copied ✓", "اتنسخ ✓") : t("Copy message", "نسخ الرسالة")}
            </button>
            {c.phone && (
              <a
                href={waUrl(c.phone, credentialsMessage(c.fullName, c.email, c.code, password))}
                target="_blank"
                rel="noopener noreferrer"
                className={`${small} bg-green-600 text-white hover:bg-green-700`}
              >
                {t("Send on WhatsApp", "ابعت على واتساب")}
              </a>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

function Row({
  label,
  value,
  mono,
  big,
  onCopy,
  copied,
}: {
  label: string;
  value: string;
  mono?: boolean | undefined;
  big?: boolean | undefined;
  onCopy?: (() => void) | undefined;
  copied?: boolean | undefined;
}) {
  const { t } = useLang();
  return (
    <div className="flex flex-wrap items-center gap-2">
      <span className="w-28 shrink-0 text-muted-foreground">{label}</span>
      <span
        dir={mono ? "ltr" : undefined}
        className={`${mono ? "font-mono" : "text-muted-foreground"} ${big ? "text-base font-bold tracking-wider text-primary" : "text-foreground"} select-all`}
      >
        {value}
      </span>
      {onCopy && (
        <button onClick={onCopy} className="text-xs text-primary hover:underline">
          {copied ? t("copied ✓", "اتنسخ ✓") : t("copy", "نسخ")}
        </button>
      )}
    </div>
  );
}
