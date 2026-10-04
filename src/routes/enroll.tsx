import { createFileRoute, Link } from "@tanstack/react-router";
import { useEffect, useMemo, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { useLang } from "@/lib/language";
import { submitAccessRequest } from "@/lib/access.functions";

export const Route = createFileRoute("/enroll")({
  head: () => ({
    meta: [
      { title: "Enroll — Finix Academy" },
      { name: "description", content: "Choose a Finix Academy package and pay with InstaPay." },
    ],
  }),
  component: EnrollPage,
});

type Pkg = {
  id: string;
  code: string;
  name: string;
  name_ar: string;
  description: string;
  description_ar: string;
  price_egp: number;
  scope: "track" | "all";
  instructor_led: boolean;
  includes_labs: boolean;
};
type Track = { id: string; name: string; name_ar: string };
type Settings = {
  instapay_address: string;
  instapay_phone: string;
  account_name: string;
  instructions: string;
  instructions_ar: string;
  whatsapp: string;
};

const fmt = (n: number) => n.toLocaleString("en-US");

async function fileToBase64(file: File): Promise<string> {
  const buf = new Uint8Array(await file.arrayBuffer());
  let bin = "";
  for (let i = 0; i < buf.length; i += 0x8000) bin += String.fromCharCode(...buf.subarray(i, i + 0x8000));
  return btoa(bin);
}

function EnrollPage() {
  const { t } = useLang();
  const [pkgs, setPkgs] = useState<Pkg[]>([]);
  const [tracks, setTracks] = useState<Track[]>([]);
  const [settings, setSettings] = useState<Settings | null>(null);
  const [loadErr, setLoadErr] = useState<string | null>(null);

  const [pkgId, setPkgId] = useState<string>("");
  const [trackId, setTrackId] = useState<string>("");
  const [fullName, setFullName] = useState("");
  const [phone, setPhone] = useState("");
  const [email, setEmail] = useState("");
  const [reference, setReference] = useState("");
  const [senderName, setSenderName] = useState("");
  const [note, setNote] = useState("");
  const [proof, setProof] = useState<File | null>(null);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [done, setDone] = useState(false);

  useEffect(() => {
    const db = supabase as any;
    void Promise.all([
      db.from("course_packages").select("*").eq("active", true).order("position"),
      db.from("tracks").select("id,name,name_ar").order("position"),
      db.from("payment_settings").select("*").eq("id", 1).maybeSingle(),
    ]).then(([p, tr, s]: any[]) => {
      if (p.error || tr.error) {
        setLoadErr(t("Could not load packages. Please try again.", "مقدرناش نحمّل الباقات. جرّب تاني."));
        return;
      }
      setPkgs(p.data ?? []);
      setTracks(tr.data ?? []);
      setSettings(s.data ?? null);
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const pkg = useMemo(() => pkgs.find((p) => p.id === pkgId), [pkgs, pkgId]);
  const instapayReady = !!settings && (settings.instapay_address.trim() || settings.instapay_phone.trim());

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErr(null);
    if (!pkg) return setErr(t("Choose a package first.", "اختار باقة الأول."));
    if (pkg.scope === "track" && !trackId) return setErr(t("Choose a track.", "اختار المسار."));
    if (proof && proof.size > 4 * 1024 * 1024) return setErr(t("Screenshot must be under 4 MB.", "الصورة لازم تكون أقل من 4 ميجا."));
    setBusy(true);
    try {
      await submitAccessRequest({
        data: {
          fullName,
          phone,
          email,
          packageId: pkg.id,
          trackId: pkg.scope === "track" ? trackId : null,
          reference,
          senderName,
          note,
          proof: proof ? { base64: await fileToBase64(proof), type: proof.type as any } : null,
        },
      });
      setDone(true);
    } catch (e2) {
      const m = e2 instanceof Error ? e2.message : String(e2);
      setErr(m.includes("[") ? t("Please check the form fields.", "راجع البيانات اللي كتبتها.") : m);
    } finally {
      setBusy(false);
    }
  };

  if (done) {
    return (
      <div className="mx-auto max-w-lg px-6 py-20 text-center">
        <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-green-500/10 text-green-600">
          <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" aria-hidden>
            <path d="M20 6 9 17l-5-5" />
          </svg>
        </div>
        <h1 className="mt-6 text-2xl font-bold text-foreground">{t("Request received", "طلبك وصل")}</h1>
        <p className="mt-3 text-sm leading-relaxed text-muted-foreground">
          {t(
            "We will match your InstaPay transfer and contact you on WhatsApp with your sign-in code, usually within one working day.",
            "هنراجع التحويل على انستاباي ونبعتلك كود الدخول على واتساب، غالبًا خلال يوم عمل.",
          )}
        </p>
        <Link to="/" className="mt-8 inline-block text-sm font-medium text-primary hover:underline">
          {t("← Back to home", "← الرجوع للرئيسية")}
        </Link>
      </div>
    );
  }

  const input =
    "w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground outline-none focus:border-primary";

  return (
    <div className="mx-auto max-w-5xl px-6 py-14">
      <h1 className="text-3xl font-bold tracking-tight text-foreground">{t("Enroll in Finix Academy", "اشترك في أكاديمية فينيكس")}</h1>
      <p className="mt-2 text-muted-foreground">
        {t("Pick a package, pay with InstaPay, and send us the transfer reference.", "اختار الباقة، ادفع بانستاباي، وابعتلنا رقم العملية.")}
      </p>

      {loadErr && <p className="mt-6 rounded-lg bg-destructive/10 px-4 py-3 text-sm text-destructive">{loadErr}</p>}

      {/* Step 1: package */}
      <h2 className="mt-10 text-lg font-semibold text-foreground">1. {t("Choose a package", "اختار الباقة")}</h2>
      <div className="mt-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {pkgs.map((p) => {
          const sel = p.id === pkgId;
          return (
            <button
              type="button"
              key={p.id}
              onClick={() => setPkgId(p.id)}
              aria-pressed={sel}
              className={`flex flex-col rounded-xl border p-5 text-start transition-colors ${
                sel ? "border-primary bg-primary/5 ring-2 ring-primary/30" : "border-border bg-card hover:border-primary/50"
              }`}
            >
              <span className="font-semibold text-foreground">{t(p.name, p.name_ar)}</span>
              <span className="mt-2 text-2xl font-bold text-primary">
                <bdi>{fmt(p.price_egp)}</bdi> {t("EGP", "جنيه")}
              </span>
              <span className="mt-2 text-sm leading-relaxed text-muted-foreground">{t(p.description, p.description_ar)}</span>
              <span className="mt-3 flex flex-wrap gap-1.5">
                <span className="rounded-full bg-secondary px-2 py-0.5 text-[11px] text-muted-foreground">
                  {p.scope === "all" ? t("All 3 tracks", "المسارات الـ3") : t("1 track", "مسار واحد")}
                </span>
                {p.instructor_led && (
                  <span className="rounded-full bg-secondary px-2 py-0.5 text-[11px] text-muted-foreground">{t("Instructor-led", "مع مدرب")}</span>
                )}
                {p.includes_labs && (
                  <span className="rounded-full bg-secondary px-2 py-0.5 text-[11px] text-muted-foreground">{t("Hands-on labs", "معامل عملي")}</span>
                )}
              </span>
            </button>
          );
        })}
      </div>

      {pkg?.scope === "track" && (
        <div className="mt-4 max-w-sm">
          <label className="text-sm font-medium text-foreground" htmlFor="track">{t("Track", "المسار")}</label>
          <select id="track" className={`${input} mt-1`} value={trackId} onChange={(e) => setTrackId(e.target.value)}>
            <option value="">{t("— choose —", "— اختار —")}</option>
            {tracks.map((tr) => (
              <option key={tr.id} value={tr.id}>{t(tr.name, tr.name_ar)}</option>
            ))}
          </select>
        </div>
      )}

      {/* Step 2: pay */}
      <h2 className="mt-10 text-lg font-semibold text-foreground">2. {t("Pay with InstaPay", "ادفع بانستاباي")}</h2>
      <div className="mt-4 rounded-xl border border-border bg-card p-5">
        {!instapayReady ? (
          <p className="text-sm text-muted-foreground">
            {t("Payment details are being set up. Please contact us on WhatsApp.", "بيانات الدفع لسه بتتجهّز. كلّمنا على واتساب.")}
          </p>
        ) : (
          <div className="grid gap-3 text-sm sm:grid-cols-3">
            {settings!.instapay_address && (
              <div>
                <p className="text-muted-foreground">{t("InstaPay address", "عنوان انستاباي")}</p>
                <p className="mt-1 font-mono text-base font-semibold text-foreground" dir="ltr">{settings!.instapay_address}</p>
              </div>
            )}
            {settings!.instapay_phone && (
              <div>
                <p className="text-muted-foreground">{t("Mobile number", "رقم الموبايل")}</p>
                <p className="mt-1 font-mono text-base font-semibold text-foreground" dir="ltr">{settings!.instapay_phone}</p>
              </div>
            )}
            {settings!.account_name && (
              <div>
                <p className="text-muted-foreground">{t("Account name", "اسم الحساب")}</p>
                <p className="mt-1 font-semibold text-foreground">{settings!.account_name}</p>
              </div>
            )}
            <div className="sm:col-span-3">
              <p className="text-muted-foreground">{t("Amount", "المبلغ")}</p>
              <p className="mt-1 text-xl font-bold text-primary">
                {pkg ? <><bdi>{fmt(pkg.price_egp)}</bdi> {t("EGP", "جنيه")}</> : t("Choose a package above", "اختار باقة فوق")}
              </p>
            </div>
            {(settings!.instructions || settings!.instructions_ar) && (
              <p className="whitespace-pre-line text-muted-foreground sm:col-span-3">
                {t(settings!.instructions, settings!.instructions_ar)}
              </p>
            )}
          </div>
        )}
      </div>

      {/* Step 3: tell us */}
      <h2 className="mt-10 text-lg font-semibold text-foreground">3. {t("Send us the transfer details", "ابعتلنا بيانات التحويل")}</h2>
      <form onSubmit={submit} className="mt-4 grid gap-4 rounded-xl border border-border bg-card p-5 sm:grid-cols-2">
        <label className="text-sm">
          <span className="font-medium text-foreground">{t("Full name", "الاسم بالكامل")} *</span>
          <input className={`${input} mt-1`} value={fullName} onChange={(e) => setFullName(e.target.value)} required minLength={3} maxLength={120} />
        </label>
        <label className="text-sm">
          <span className="font-medium text-foreground">{t("Mobile (WhatsApp)", "الموبايل (واتساب)")} *</span>
          <input className={`${input} mt-1`} dir="ltr" inputMode="tel" placeholder="01xxxxxxxxx" value={phone} onChange={(e) => setPhone(e.target.value)} required />
        </label>
        <label className="text-sm">
          <span className="font-medium text-foreground">{t("E-mail", "الإيميل")} *</span>
          <input className={`${input} mt-1`} dir="ltr" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
        </label>
        <label className="text-sm">
          <span className="font-medium text-foreground">{t("InstaPay transaction reference", "رقم العملية في انستاباي")} *</span>
          <input className={`${input} mt-1`} dir="ltr" value={reference} onChange={(e) => setReference(e.target.value)} required minLength={4} maxLength={80} />
        </label>
        <label className="text-sm">
          <span className="font-medium text-foreground">{t("Name on the sending account", "اسم الحساب اللي حوّلت منه")}</span>
          <input className={`${input} mt-1`} value={senderName} onChange={(e) => setSenderName(e.target.value)} maxLength={120} />
        </label>
        <label className="text-sm">
          <span className="font-medium text-foreground">{t("Transfer screenshot (optional)", "صورة التحويل (اختياري)")}</span>
          <input
            className="mt-1 block w-full text-sm text-muted-foreground file:me-3 file:rounded-md file:border-0 file:bg-secondary file:px-3 file:py-1.5 file:text-foreground"
            type="file"
            accept="image/jpeg,image/png,image/webp"
            onChange={(e) => setProof(e.target.files?.[0] ?? null)}
          />
        </label>
        <label className="text-sm sm:col-span-2">
          <span className="font-medium text-foreground">{t("Note (optional)", "ملاحظة (اختياري)")}</span>
          <textarea className={`${input} mt-1`} rows={2} value={note} onChange={(e) => setNote(e.target.value)} maxLength={500} />
        </label>

        {err && <p className="rounded-lg bg-destructive/10 px-4 py-2 text-sm text-destructive sm:col-span-2">{err}</p>}

        <div className="flex flex-wrap items-center gap-3 sm:col-span-2">
          <button
            type="submit"
            disabled={busy || !pkg}
            className="rounded-lg bg-primary px-6 py-2.5 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
          >
            {busy ? t("Sending…", "جارٍ الإرسال…") : t("Submit payment", "إرسال بيانات الدفع")}
          </button>
          <p className="text-xs text-muted-foreground">
            {t("Your access opens after we confirm the transfer.", "الوصول بيتفتح بعد ما نأكد التحويل.")}
          </p>
        </div>
      </form>
    </div>
  );
}
