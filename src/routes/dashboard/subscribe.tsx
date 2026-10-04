import { createFileRoute, Link } from "@tanstack/react-router";
import { useEffect, useMemo, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Protected } from "@/lib/auth";
import { useLang } from "@/lib/language";
import { useCurriculum } from "@/hooks/use-curriculum";
import { useModuleAccess } from "@/hooks/use-module-access";
import { listMyAccessRequests, submitMyAccessRequest } from "@/lib/access.functions";

export const Route = createFileRoute("/dashboard/subscribe")({
  head: () => ({ meta: [{ title: "Subscribe — Finix Academy" }] }),
  component: () => (
    <Protected>
      <SubscribePage />
    </Protected>
  ),
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

function SubscribePage() {
  const { t, lang } = useLang();
  const { tracks, modules, loading: curLoading } = useCurriculum();
  const { canOpen, loading: accLoading } = useModuleAccess();

  const [pkgs, setPkgs] = useState<Pkg[]>([]);
  const [settings, setSettings] = useState<Settings | null>(null);
  const [mine, setMine] = useState<any[]>([]);

  const [choice, setChoice] = useState<{ pkgId: string; trackId: string | null } | null>(null);
  const [phone, setPhone] = useState("");
  const [reference, setReference] = useState("");
  const [senderName, setSenderName] = useState("");
  const [note, setNote] = useState("");
  const [proof, setProof] = useState<File | null>(null);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [sent, setSent] = useState(false);

  const loadMine = () =>
    listMyAccessRequests()
      .then((r) => setMine(r.requests))
      .catch(() => setMine([]));

  useEffect(() => {
    const db = supabase as any;
    void Promise.all([
      db.from("course_packages").select("*").eq("active", true).order("position"),
      db.from("payment_settings").select("*").eq("id", 1).maybeSingle(),
    ]).then(([p, s]: any[]) => {
      setPkgs(p.data ?? []);
      setSettings(s.data ?? null);
    });
    void loadMine();
  }, []);
  // Preselect a track when arriving from a locked course (?track=...).
  const [preTrack] = useState<string | null>(() =>
    typeof window === "undefined" ? null : new URLSearchParams(window.location.search).get("track"),
  );

  // Ownership per track, from what the database says this student can open.
  const trackStatus = useMemo(
    () =>
      tracks.map((tr) => {
        const mods = modules.filter((m) => m.track_id === tr.id);
        const owned = mods.filter((m) => canOpen(m.id)).length;
        return { track: tr, total: mods.length, owned, complete: mods.length > 0 && owned === mods.length };
      }),
    [tracks, modules, canOpen],
  );
  const missingTracks = trackStatus.filter((x) => !x.complete && x.total > 0);
  const everything = missingTracks.length === 0;
  const pendingTrackIds = new Set(mine.filter((r) => r.status === "pending").map((r) => r.track_id ?? "__all__"));

  const trackPkgs = pkgs.filter((p) => p.scope === "track");
  const allPkgs = pkgs.filter((p) => p.scope === "all");
  const selPkg = choice ? pkgs.find((p) => p.id === choice.pkgId) : undefined;
  const instapayReady = !!settings && (settings.instapay_address.trim() || settings.instapay_phone.trim());

  // Default selection: the track the student came from, else the first missing one.
  useEffect(() => {
    if (choice || trackPkgs.length === 0 || missingTracks.length === 0) return;
    const target = missingTracks.find((x) => x.track.id === preTrack) ?? missingTracks[0];
    if (target && !pendingTrackIds.has(target.track.id)) setChoice({ pkgId: trackPkgs[0]!.id, trackId: target.track.id });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [preTrack, trackPkgs.length, missingTracks.length]);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErr(null);
    if (!selPkg || !choice) return setErr(t("Choose what you want to subscribe to.", "اختار عايز تشترك في إيه."));
    if (proof && proof.size > 4 * 1024 * 1024) return setErr(t("Screenshot must be under 4 MB.", "الصورة لازم تكون أقل من 4 ميجا."));
    setBusy(true);
    try {
      await submitMyAccessRequest({
        data: {
          phone,
          packageId: selPkg.id,
          trackId: selPkg.scope === "track" ? choice.trackId : null,
          reference,
          senderName,
          note,
          proof: proof ? { base64: await fileToBase64(proof), type: proof.type as any } : null,
        },
      });
      setSent(true);
      setReference("");
      setProof(null);
      setNote("");
      await loadMine();
    } catch (e2) {
      const m = e2 instanceof Error ? e2.message : String(e2);
      setErr(m.includes("[") ? t("Please check the form fields.", "راجع البيانات اللي كتبتها.") : m);
    } finally {
      setBusy(false);
    }
  };

  if (curLoading || accLoading) {
    return <div className="p-6 text-center text-sm text-muted-foreground">{t("Loading…", "جارٍ التحميل…")}</div>;
  }

  const input =
    "w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground outline-none focus:border-primary";
  const statusLabel = (s: string) =>
    ({ pending: t("Under review", "قيد المراجعة"), approved: t("Approved", "اتقبل"), rejected: t("Rejected", "اترفض") })[s] ?? s;
  const statusCls = (s: string) =>
    ({ pending: "bg-amber-100 text-amber-800", approved: "bg-green-100 text-green-800", rejected: "bg-red-100 text-red-800" })[s] ??
    "bg-secondary";

  const option = (pkg: Pkg, trackId: string | null, title: string, sub: string, pending: boolean) => {
    const sel = choice?.pkgId === pkg.id && choice?.trackId === trackId;
    return (
      <button
        type="button"
        key={pkg.id + (trackId ?? "")}
        aria-pressed={sel}
        disabled={pending}
        onClick={() => {
          setChoice({ pkgId: pkg.id, trackId });
          setSent(false);
        }}
        className={`flex flex-col rounded-xl border p-4 text-start transition-colors disabled:cursor-not-allowed disabled:opacity-60 ${
          sel ? "border-primary bg-primary/5 ring-2 ring-primary/30" : "border-border bg-card hover:border-primary/50"
        }`}
      >
        <span className="text-sm font-semibold text-foreground">{title}</span>
        <span className="mt-0.5 text-xs text-muted-foreground">{sub}</span>
        <span className="mt-2 text-xl font-bold text-primary">
          <bdi>{fmt(pkg.price_egp)}</bdi> {t("EGP", "جنيه")}
        </span>
        {pending && <span className="mt-1 text-xs font-medium text-amber-700">{t("Request under review", "فيه طلب تحت المراجعة")}</span>}
      </button>
    );
  };

  return (
    <div className="mx-auto max-w-5xl p-6">
      <h1 className="text-2xl font-bold text-foreground">{t("Subscribe to more courses", "اشترك في كورسات تانية")}</h1>
      <p className="mt-1 text-sm text-muted-foreground">
        {t(
          "Add the tracks you don't have yet. They open on this same account once your InstaPay payment is confirmed.",
          "ضيف المسارات اللي لسه مش عندك. بتتفتح على نفس حسابك أول ما الدفع بانستاباي يتأكد.",
        )}
      </p>

      {/* What I have */}
      <h2 className="mt-8 text-lg font-semibold text-foreground">{t("Your courses", "كورساتك")}</h2>
      <div className="mt-3 grid gap-3 sm:grid-cols-3">
        {trackStatus.map(({ track, total, owned, complete }) => (
          <div key={track.id} className="rounded-xl border border-border bg-card p-4">
            <p className="text-sm font-semibold text-foreground">{t(track.name, track.name_ar)}</p>
            <div className="mt-3 h-2 overflow-hidden rounded-full bg-secondary">
              <div className={`h-full ${complete ? "bg-green-500" : "bg-primary"}`} style={{ width: `${total ? (owned / total) * 100 : 0}%` }} />
            </div>
            <p className="mt-2 text-xs text-muted-foreground">
              {complete
                ? t("Enrolled — all modules open", "مشترك — كل الوحدات مفتوحة")
                : owned === 0
                  ? t("Not enrolled", "مش مشترك")
                  : t(`${owned} of ${total} modules open`, `${owned} من ${total} وحدة مفتوحة`)}
            </p>
          </div>
        ))}
      </div>

      {/* My requests */}
      {mine.length > 0 && (
        <>
          <h2 className="mt-8 text-lg font-semibold text-foreground">{t("Your payment requests", "طلبات الدفع بتاعتك")}</h2>
          <ul className="mt-3 divide-y divide-border rounded-xl border border-border bg-card">
            {mine.map((r) => {
              const trackName = r.track_id ? tracks.find((x) => x.id === r.track_id) : null;
              return (
                <li key={r.id} className="flex flex-wrap items-center justify-between gap-2 px-4 py-3 text-sm">
                  <span className="text-foreground">
                    {r.course_packages ? (lang === "ar" ? r.course_packages.name_ar : r.course_packages.name) : "—"}
                    {trackName ? ` · ${t(trackName.name, trackName.name_ar)}` : ""} · <bdi>{fmt(r.amount_egp)}</bdi> {t("EGP", "جنيه")}
                  </span>
                  <span className="flex items-center gap-2">
                    {r.status === "rejected" && r.admin_note && <span className="text-xs text-muted-foreground">{r.admin_note}</span>}
                    <span className={`rounded-full px-2 py-0.5 text-[11px] font-medium ${statusCls(r.status)}`}>{statusLabel(r.status)}</span>
                  </span>
                </li>
              );
            })}
          </ul>
        </>
      )}

      {everything ? (
        <div className="mt-8 rounded-xl border border-green-300 bg-green-50 p-5 text-sm text-green-900">
          <p className="font-semibold">{t("You have access to every course 🎉", "معاك كل الكورسات 🎉")}</p>
          <Link to="/dashboard/my-courses" className="mt-2 inline-block font-medium text-green-800 underline">
            {t("Go to My Courses", "روح لكورساتي")}
          </Link>
        </div>
      ) : (
        <>
          {/* Step 1 */}
          <h2 className="mt-8 text-lg font-semibold text-foreground">1. {t("Choose what to add", "اختار هتضيف إيه")}</h2>
          {trackPkgs.length > 0 && (
            <div className="mt-3 space-y-4">
              {missingTracks.map(({ track }) => (
                <div key={track.id}>
                  <p className="mb-2 text-sm font-medium text-foreground">{t(track.name, track.name_ar)}</p>
                  <div className="grid gap-3 sm:grid-cols-2">
                    {trackPkgs.map((p) =>
                      option(p, track.id, t(p.name, p.name_ar), t(p.description, p.description_ar), pendingTrackIds.has(track.id)),
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
          {allPkgs.length > 0 && missingTracks.length > 1 && (
            <div className="mt-5">
              <p className="mb-2 text-sm font-medium text-foreground">{t("Or get everything", "أو خد كل حاجة")}</p>
              <div className="grid gap-3 sm:grid-cols-3">
                {allPkgs.map((p) => option(p, null, t(p.name, p.name_ar), t(p.description, p.description_ar), pendingTrackIds.has("__all__")))}
              </div>
            </div>
          )}

          {/* Step 2 */}
          <h2 className="mt-8 text-lg font-semibold text-foreground">2. {t("Pay with InstaPay", "ادفع بانستاباي")}</h2>
          <div className="mt-3 rounded-xl border border-border bg-card p-5 text-sm">
            {!instapayReady ? (
              <p className="text-muted-foreground">
                {t("Payment details are being set up. Please contact the academy.", "بيانات الدفع لسه بتتجهّز. كلّم الأكاديمية.")}
              </p>
            ) : (
              <div className="grid gap-3 sm:grid-cols-3">
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
                    {selPkg ? <><bdi>{fmt(selPkg.price_egp)}</bdi> {t("EGP", "جنيه")}</> : t("Choose above", "اختار فوق")}
                  </p>
                </div>
              </div>
            )}
          </div>

          {/* Step 3 */}
          <h2 className="mt-8 text-lg font-semibold text-foreground">3. {t("Send the transfer details", "ابعت بيانات التحويل")}</h2>
          {sent ? (
            <div className="mt-3 rounded-xl border border-green-300 bg-green-50 p-5 text-sm text-green-900">
              <p className="font-semibold">{t("Request received", "طلبك وصل")}</p>
              <p className="mt-1">
                {t(
                  "We'll confirm the transfer and the course will open on your account — you'll get a notification. Your sign-in stays the same.",
                  "هنأكد التحويل والكورس هيتفتح على حسابك، وهيوصلك إشعار. بيانات الدخول بتاعتك زي ما هي.",
                )}
              </p>
            </div>
          ) : (
            <form onSubmit={submit} className="mt-3 grid gap-4 rounded-xl border border-border bg-card p-5 sm:grid-cols-2">
              <label className="text-sm">
                <span className="font-medium text-foreground">{t("InstaPay transaction reference", "رقم العملية في انستاباي")} *</span>
                <input className={`${input} mt-1`} dir="ltr" name="reference" value={reference} onChange={(e) => setReference(e.target.value)} required minLength={4} maxLength={80} />
              </label>
              <label className="text-sm">
                <span className="font-medium text-foreground">{t("Mobile (WhatsApp)", "الموبايل (واتساب)")} *</span>
                <input className={`${input} mt-1`} dir="ltr" inputMode="tel" name="phone" placeholder="01xxxxxxxxx" value={phone} onChange={(e) => setPhone(e.target.value)} required />
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
              <div className="sm:col-span-2">
                <button
                  type="submit"
                  disabled={busy || !selPkg}
                  className="rounded-lg bg-primary px-6 py-2.5 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
                >
                  {busy ? t("Sending…", "جارٍ الإرسال…") : t("Submit payment", "إرسال بيانات الدفع")}
                </button>
              </div>
            </form>
          )}
        </>
      )}
    </div>
  );
}
