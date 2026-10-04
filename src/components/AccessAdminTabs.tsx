import { useEffect, useMemo, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { useLang } from "@/lib/language";
import { useCurriculum } from "@/hooks/use-curriculum";
import {
  approveAccessRequest,
  getProofUrl,
  listAccessRequests,
  listTraineeAccess,
  rejectAccessRequest,
  setModuleAccess,
} from "@/lib/access.functions";
import { CredentialsPanel, credentialsMessage } from "@/components/CredentialsPanel";

const fmt = (n: number) => Number(n).toLocaleString("en-US");
const btn = "rounded-lg px-3 py-1.5 text-xs font-medium transition-colors disabled:opacity-50";
const input = "w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground outline-none focus:border-primary";

function errText(e: unknown) {
  return e instanceof Error ? e.message : String(e);
}

// ======================================================= Payment requests
export function RequestsTab() {
  const { t, lang } = useLang();
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<"pending" | "approved" | "rejected" | "all">("pending");
  const [busyId, setBusyId] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);
  const [issued, setIssued] = useState<Record<string, { code: string; password: string | null; email: string; phone: string; fullName: string; created: boolean; unlocked: number }>>({});
  const [openCreds, setOpenCreds] = useState<string | null>(null);

  const load = async () => {
    setLoading(true);
    try {
      const res = await listAccessRequests();
      setRows(res.requests);
    } catch (e) {
      setErr(errText(e));
    } finally {
      setLoading(false);
    }
  };
  useEffect(() => {
    void load();
  }, []);

  const shown = rows.filter((r) => filter === "all" || r.status === filter);
  const pendingCount = rows.filter((r) => r.status === "pending").length;

  const approve = async (r: any) => {
    if (!confirm(t(
      `Confirm you received ${fmt(r.amount_egp)} EGP on InstaPay with reference ${r.instapay_reference}?`,
      `متأكد إن ${fmt(r.amount_egp)} جنيه وصلوا على انستاباي برقم العملية ${r.instapay_reference}؟`,
    ))) return;
    setBusyId(r.id);
    setErr(null);
    try {
      const res = await approveAccessRequest({ data: { requestId: r.id, note: "" } });
      setIssued((m) => ({ ...m, [r.id]: res }));
      await load();
    } catch (e) {
      setErr(errText(e));
    } finally {
      setBusyId(null);
    }
  };

  const reject = async (r: any) => {
    const note = prompt(t("Reason for rejection (shown in the record):", "سبب الرفض (هيتسجّل في الطلب):"));
    if (!note || note.trim().length < 3) return;
    setBusyId(r.id);
    setErr(null);
    try {
      await rejectAccessRequest({ data: { requestId: r.id, note } });
      await load();
    } catch (e) {
      setErr(errText(e));
    } finally {
      setBusyId(null);
    }
  };

  const viewProof = async (r: any) => {
    try {
      const res = await getProofUrl({ data: { requestId: r.id } });
      window.open(res.url, "_blank", "noopener");
    } catch (e) {
      setErr(errText(e));
    }
  };

  const waLink = (iss: { phone: string; fullName: string; email: string; code: string; password: string | null }) => {
    const intl = iss.phone.startsWith("0") ? "2" + iss.phone : iss.phone.replace(/^\+/, "");
    const msg = "تم تأكيد الدفع وفتح الكورس 🎉 / Payment confirmed\n\n" + credentialsMessage(iss.fullName, iss.email, iss.code, iss.password);
    return `https://wa.me/${intl}?text=${encodeURIComponent(msg)}`;
  };

  const statusPill = (s: string) =>
    ({
      pending: "bg-amber-100 text-amber-800",
      approved: "bg-green-100 text-green-800",
      rejected: "bg-red-100 text-red-800",
    })[s] ?? "bg-secondary";

  return (
    <div>
      <div className="mb-4 flex flex-wrap items-center gap-2">
        {(["pending", "approved", "rejected", "all"] as const).map((f) => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className={`${btn} ${filter === f ? "bg-primary text-primary-foreground" : "border border-border text-muted-foreground hover:bg-secondary"}`}
          >
            {t({ pending: "Pending", approved: "Approved", rejected: "Rejected", all: "All" }[f],
               { pending: "قيد المراجعة", approved: "مقبولة", rejected: "مرفوضة", all: "الكل" }[f])}
            {f === "pending" && pendingCount > 0 && <span className="ms-1.5 rounded-full bg-white/25 px-1.5">{pendingCount}</span>}
          </button>
        ))}
        <button onClick={() => void load()} className={`${btn} ms-auto border border-border text-muted-foreground hover:bg-secondary`}>
          {t("Refresh", "تحديث")}
        </button>
      </div>

      {err && <p className="mb-4 rounded-lg bg-destructive/10 px-4 py-2 text-sm text-destructive">{err}</p>}

      {loading ? (
        <p className="text-sm text-muted-foreground">{t("Loading…", "جارٍ التحميل…")}</p>
      ) : shown.length === 0 ? (
        <p className="rounded-xl border border-dashed border-border p-8 text-center text-sm text-muted-foreground">
          {t("No requests here.", "مفيش طلبات هنا.")}
        </p>
      ) : (
        <div className="space-y-3">
          {shown.map((r) => {
            const iss = issued[r.id];
            const pkgName = r.course_packages ? (lang === "ar" ? r.course_packages.name_ar : r.course_packages.name) : "—";
            const trackName = r.tracks ? (lang === "ar" ? r.tracks.name_ar : r.tracks.name) : null;
            return (
              <div key={r.id} className="rounded-xl border border-border bg-card p-4">
                <div className="flex flex-wrap items-start justify-between gap-3">
                  <div className="min-w-0">
                    <p className="font-semibold text-foreground">
                      {r.full_name}{" "}
                      <span className={`ms-1 rounded-full px-2 py-0.5 text-[11px] font-medium ${statusPill(r.status)}`}>
                        {t(r.status, { pending: "قيد المراجعة", approved: "مقبولة", rejected: "مرفوضة" }[r.status as string] ?? r.status)}
                      </span>
                    </p>
                    <p className="mt-1 text-sm text-muted-foreground">
                      {pkgName}
                      {trackName ? ` · ${trackName}` : ""} · <bdi className="font-semibold text-foreground">{fmt(r.amount_egp)}</bdi> {t("EGP", "جنيه")}
                    </p>
                    <p className="mt-1 text-xs text-muted-foreground" dir="ltr" style={{ textAlign: "start" }}>
                      {r.phone} · {r.email}
                    </p>
                  </div>
                  <div className="text-xs text-muted-foreground">{new Date(r.created_at).toLocaleString(lang === "ar" ? "ar-EG" : "en-GB")}</div>
                </div>

                <div className="mt-3 grid gap-2 rounded-lg bg-secondary/50 p-3 text-sm sm:grid-cols-3">
                  <div>
                    <span className="text-muted-foreground">{t("Reference", "رقم العملية")}: </span>
                    <span className="font-mono font-semibold text-foreground" dir="ltr">{r.instapay_reference}</span>
                  </div>
                  <div>
                    <span className="text-muted-foreground">{t("Sender", "المحوِّل")}: </span>
                    <span className="text-foreground">{r.sender_name || "—"}</span>
                  </div>
                  <div>
                    {r.proof_path ? (
                      <button onClick={() => void viewProof(r)} className="font-medium text-primary hover:underline">
                        {t("View screenshot", "عرض صورة التحويل")}
                      </button>
                    ) : (
                      <span className="text-muted-foreground">{t("No screenshot", "مفيش صورة")}</span>
                    )}
                  </div>
                  {r.customer_note && <p className="text-muted-foreground sm:col-span-3">“{r.customer_note}”</p>}
                  {r.admin_note && <p className="text-muted-foreground sm:col-span-3">{t("Admin note", "ملاحظة الإدارة")}: {r.admin_note}</p>}
                </div>

                {r.status === "approved" && r.granted_user_id && !iss && (
                  <button
                    onClick={() => setOpenCreds(openCreds === r.id ? null : r.id)}
                    className={`${btn} mt-3 border border-primary/40 text-primary hover:bg-primary/10`}
                  >
                    {t("Login details", "بيانات الدخول")}
                  </button>
                )}
                {openCreds === r.id && r.granted_user_id && (
                  <CredentialsPanel userId={r.granted_user_id} onClose={() => setOpenCreds(null)} />
                )}

                {r.status === "pending" && (
                  <div className="mt-3 flex flex-wrap gap-2">
                    <button disabled={busyId === r.id} onClick={() => void approve(r)} className={`${btn} bg-green-600 text-white hover:bg-green-700`}>
                      {busyId === r.id ? t("Working…", "جارٍ التنفيذ…") : t("Approve & unlock", "قبول وفتح المحتوى")}
                    </button>
                    <button disabled={busyId === r.id} onClick={() => void reject(r)} className={`${btn} border border-destructive/40 text-destructive hover:bg-destructive/10`}>
                      {t("Reject", "رفض")}
                    </button>
                  </div>
                )}

                {iss && (
                  <div className="mt-3 rounded-lg border border-green-300 bg-green-50 p-3 text-sm text-green-900">
                    <p>
                      {iss.created ? t("Account created. ", "تم إنشاء الحساب. ") : t("Existing account. ", "حساب موجود. ")}
                      {t(`${iss.unlocked} modules unlocked.`, `تم فتح ${iss.unlocked} وحدة.`)}
                    </p>
                    <p className="mt-1">
                      {t("Access code", "كود الدخول")}: <span className="select-all font-mono text-base font-bold" dir="ltr">{iss.code}</span>
                    </p>
                    <p className="mt-1">
                      {t("Email", "الإيميل")}: <span className="select-all font-mono" dir="ltr">{iss.email}</span>
                    </p>
                    {iss.password ? (
                      <p className="mt-1">
                        {t("Password", "كلمة السر")}: <span className="select-all font-mono text-base font-bold" dir="ltr">{iss.password}</span>
                      </p>
                    ) : (
                      <p className="mt-1 text-xs">
                        {t("Existing account: password unchanged (use Login details to set a new one).", "حساب موجود: كلمة السر زي ما هي (من بيانات الدخول تقدر تعمل واحدة جديدة).")}
                      </p>
                    )}
                    <a
                      href={waLink(iss)}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="mt-2 inline-flex rounded-lg bg-green-600 px-3 py-1.5 text-xs font-medium text-white hover:bg-green-700"
                    >
                      {t("Send code on WhatsApp", "ابعت الكود على واتساب")}
                    </a>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

// ======================================================= Module access (staff)
export function AccessTab() {
  const { t } = useLang();
  const { tracks, modules } = useCurriculum();
  const [trainees, setTrainees] = useState<{ userId: string; email: string; fullName: string | null; moduleIds: string[] }[]>([]);
  const [sel, setSel] = useState<string>("");
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<{ kind: "ok" | "err"; text: string } | null>(null);

  const load = async (keep?: string) => {
    setLoading(true);
    try {
      const res = await listTraineeAccess();
      setTrainees(res.trainees);
      if (!keep && res.trainees[0]) setSel(res.trainees[0].userId);
    } catch (e) {
      setMsg({ kind: "err", text: errText(e) });
    } finally {
      setLoading(false);
    }
  };
  useEffect(() => {
    void load();
  }, []);

  const current = trainees.find((x) => x.userId === sel);
  const has = useMemo(() => new Set(current?.moduleIds ?? []), [current]);
  const filtered = trainees.filter((x) => `${x.email} ${x.fullName ?? ""}`.toLowerCase().includes(search.toLowerCase()));

  const change = async (moduleIds: string[], unlock: boolean) => {
    if (!current || moduleIds.length === 0) return;
    setBusy(true);
    setMsg(null);
    try {
      await setModuleAccess({ data: { userId: current.userId, moduleIds, unlock } });
      setMsg({ kind: "ok", text: unlock ? t("Unlocked — the trainee was notified.", "اتفتحت — والمتدرب وصله إشعار.") : t("Locked.", "اتقفلت.") });
      await load(current.userId);
    } catch (e) {
      setMsg({ kind: "err", text: errText(e) });
    } finally {
      setBusy(false);
    }
  };

  if (loading && trainees.length === 0) return <p className="text-sm text-muted-foreground">{t("Loading…", "جارٍ التحميل…")}</p>;
  if (trainees.length === 0) return <p className="text-sm text-muted-foreground">{t("No trainees yet.", "مفيش متدربين لسه.")}</p>;

  return (
    <div className="grid gap-6 lg:grid-cols-[280px_1fr]">
      <div>
        <input className={input} placeholder={t("Search trainees…", "دوّر على متدرب…")} value={search} onChange={(e) => setSearch(e.target.value)} />
        <ul className="mt-3 max-h-[60vh] divide-y divide-border overflow-y-auto rounded-xl border border-border bg-card">
          {filtered.map((x) => (
            <li key={x.userId}>
              <button
                onClick={() => setSel(x.userId)}
                className={`block w-full px-3 py-2.5 text-start text-sm ${x.userId === sel ? "bg-primary/10" : "hover:bg-secondary"}`}
              >
                <span className="block truncate font-medium text-foreground">{x.fullName || x.email}</span>
                <span className="block truncate text-xs text-muted-foreground">
                  {x.moduleIds.length} / {modules.length} {t("unlocked", "مفتوحة")}
                </span>
              </button>
            </li>
          ))}
        </ul>
      </div>

      {current && (
        <div>
          <div className="mb-4 flex flex-wrap items-center gap-2">
            <h3 className="me-auto text-lg font-semibold text-foreground">{current.fullName || current.email}</h3>
            <button disabled={busy} onClick={() => void change(modules.map((m) => m.id).filter((id) => !has.has(id)), true)} className={`${btn} bg-primary text-primary-foreground hover:bg-primary/90`}>
              {t("Unlock all", "افتح الكل")}
            </button>
            <button disabled={busy} onClick={() => void change([...has], false)} className={`${btn} border border-border text-muted-foreground hover:bg-secondary`}>
              {t("Lock all", "اقفل الكل")}
            </button>
          </div>
          {msg && (
            <p className={`mb-4 rounded-lg px-4 py-2 text-sm ${msg.kind === "ok" ? "bg-green-50 text-green-800" : "bg-destructive/10 text-destructive"}`}>{msg.text}</p>
          )}
          {tracks.map((tr) => {
            const mods = modules.filter((m) => m.track_id === tr.id);
            if (mods.length === 0) return null;
            const locked = mods.filter((m) => !has.has(m.id)).map((m) => m.id);
            return (
              <section key={tr.id} className="mb-5">
                <div className="mb-2 flex items-center gap-2">
                  <h4 className="me-auto text-sm font-semibold text-foreground">{t(tr.name, tr.name_ar)}</h4>
                  <button disabled={busy || locked.length === 0} onClick={() => void change(locked, true)} className={`${btn} border border-primary/40 text-primary hover:bg-primary/10`}>
                    {t("Unlock track", "افتح المسار")}
                  </button>
                </div>
                <div className="divide-y divide-border rounded-xl border border-border bg-card">
                  {mods.map((m) => {
                    const on = has.has(m.id);
                    return (
                      <label key={m.id} className="flex cursor-pointer items-center gap-3 px-4 py-2.5 text-sm">
                        <input type="checkbox" className="h-4 w-4 accent-[var(--primary)]" checked={on} disabled={busy} onChange={() => void change([m.id], !on)} />
                        <span className="font-mono text-xs text-muted-foreground">{m.code}</span>
                        <span className="flex-1 text-foreground">{t(m.title, m.title_ar)}</span>
                        <span className={`text-xs ${on ? "text-green-700" : "text-muted-foreground"}`}>{on ? t("Open", "مفتوحة") : t("Locked", "مقفولة")}</span>
                      </label>
                    );
                  })}
                </div>
              </section>
            );
          })}
        </div>
      )}
    </div>
  );
}

// ======================================================= Pricing + InstaPay settings
export function PricingTab() {
  const { t } = useLang();
  const db = supabase as any;
  const [pkgs, setPkgs] = useState<any[]>([]);
  const [s, setS] = useState<any>(null);
  const [msg, setMsg] = useState<{ kind: "ok" | "err"; text: string } | null>(null);
  const [busy, setBusy] = useState(false);

  const load = async () => {
    const [p, st] = await Promise.all([
      db.from("course_packages").select("*").order("position"),
      db.from("payment_settings").select("*").eq("id", 1).maybeSingle(),
    ]);
    setPkgs(p.data ?? []);
    setS(st.data ?? { id: 1 });
  };
  useEffect(() => {
    void load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const savePkg = async (p: any) => {
    setBusy(true);
    setMsg(null);
    const price = Number(p.price_egp);
    if (!Number.isInteger(price) || price < 0) {
      setBusy(false);
      return setMsg({ kind: "err", text: t("Price must be a whole number.", "السعر لازم يكون رقم صحيح.") });
    }
    const { error } = await db
      .from("course_packages")
      .update({ name: p.name, name_ar: p.name_ar, description: p.description, description_ar: p.description_ar, price_egp: price, active: p.active, updated_at: new Date().toISOString() })
      .eq("id", p.id);
    setBusy(false);
    setMsg(error ? { kind: "err", text: error.message } : { kind: "ok", text: t("Package saved.", "الباقة اتحفظت.") });
  };

  const saveSettings = async () => {
    setBusy(true);
    setMsg(null);
    const { error } = await db
      .from("payment_settings")
      .upsert({ ...s, id: 1, updated_at: new Date().toISOString() }, { onConflict: "id" });
    setBusy(false);
    setMsg(error ? { kind: "err", text: error.message } : { kind: "ok", text: t("InstaPay details saved.", "بيانات انستاباي اتحفظت.") });
  };

  const upd = (i: number, k: string, v: any) => setPkgs((arr) => arr.map((p, j) => (j === i ? { ...p, [k]: v } : p)));

  if (!s) return <p className="text-sm text-muted-foreground">{t("Loading…", "جارٍ التحميل…")}</p>;

  return (
    <div className="space-y-8">
      {msg && <p className={`rounded-lg px-4 py-2 text-sm ${msg.kind === "ok" ? "bg-green-50 text-green-800" : "bg-destructive/10 text-destructive"}`}>{msg.text}</p>}

      <section className="rounded-xl border border-border bg-card p-5">
        <h3 className="text-lg font-semibold text-foreground">{t("InstaPay receiving details", "بيانات استلام انستاباي")}</h3>
        <p className="mt-1 text-sm text-muted-foreground">
          {t("Shown to buyers on the Enroll page.", "بتظهر للمشتركين في صفحة الاشتراك.")}{" "}
          <a href="/enroll" target="_blank" rel="noopener" className="text-primary hover:underline">/enroll</a>
        </p>
        <div className="mt-4 grid gap-3 sm:grid-cols-2">
          {([
            ["instapay_address", t("InstaPay address (e.g. name@instapay)", "عنوان انستاباي (مثال: name@instapay)"), "ltr"],
            ["instapay_phone", t("Mobile number linked to InstaPay", "رقم الموبايل المربوط بانستاباي"), "ltr"],
            ["account_name", t("Account holder name", "اسم صاحب الحساب"), undefined],
            ["whatsapp", t("WhatsApp for questions", "واتساب للاستفسارات"), "ltr"],
          ] as const).map(([k, label, dir]) => (
            <label key={k} className="text-sm">
              <span className="font-medium text-foreground">{label}</span>
              <input className={`${input} mt-1`} dir={dir} value={s[k] ?? ""} onChange={(e) => setS({ ...s, [k]: e.target.value })} />
            </label>
          ))}
          <label className="text-sm">
            <span className="font-medium text-foreground">{t("Extra instructions (English)", "تعليمات إضافية (إنجليزي)")}</span>
            <textarea className={`${input} mt-1`} dir="ltr" rows={3} value={s.instructions ?? ""} onChange={(e) => setS({ ...s, instructions: e.target.value })} />
          </label>
          <label className="text-sm">
            <span className="font-medium text-foreground">{t("Extra instructions (Arabic)", "تعليمات إضافية (عربي)")}</span>
            <textarea className={`${input} mt-1`} dir="rtl" rows={3} value={s.instructions_ar ?? ""} onChange={(e) => setS({ ...s, instructions_ar: e.target.value })} />
          </label>
        </div>
        <button disabled={busy} onClick={() => void saveSettings()} className="mt-4 rounded-lg bg-primary px-5 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50">
          {t("Save InstaPay details", "حفظ بيانات انستاباي")}
        </button>
      </section>

      <section>
        <h3 className="mb-3 text-lg font-semibold text-foreground">{t("Packages & prices (EGP)", "الباقات والأسعار (جنيه)")}</h3>
        <div className="space-y-3">
          {pkgs.map((p, i) => (
            <div key={p.id} className="grid gap-3 rounded-xl border border-border bg-card p-4 sm:grid-cols-[1fr_1fr_140px_auto]">
              <input className={input} dir="ltr" value={p.name} onChange={(e) => upd(i, "name", e.target.value)} aria-label="Name (EN)" />
              <input className={input} dir="rtl" value={p.name_ar} onChange={(e) => upd(i, "name_ar", e.target.value)} aria-label="الاسم (AR)" />
              <input className={input} dir="ltr" type="number" min={0} step={50} value={p.price_egp} onChange={(e) => upd(i, "price_egp", e.target.value)} aria-label="Price EGP" />
              <div className="flex items-center gap-3">
                <label className="flex items-center gap-1.5 text-xs text-muted-foreground">
                  <input type="checkbox" checked={p.active} onChange={(e) => upd(i, "active", e.target.checked)} />
                  {t("On sale", "معروضة")}
                </label>
                <button disabled={busy} onClick={() => void savePkg(p)} className={`${btn} bg-primary text-primary-foreground hover:bg-primary/90`}>
                  {t("Save", "حفظ")}
                </button>
              </div>
              <textarea className={`${input} sm:col-span-2`} dir="ltr" rows={2} value={p.description} onChange={(e) => upd(i, "description", e.target.value)} aria-label="Description (EN)" />
              <textarea className={`${input} sm:col-span-2`} dir="rtl" rows={2} value={p.description_ar} onChange={(e) => upd(i, "description_ar", e.target.value)} aria-label="الوصف (AR)" />
              <p className="text-xs text-muted-foreground sm:col-span-4">
                {p.scope === "all" ? t("Unlocks all 3 tracks on approval", "بتفتح المسارات الـ3 عند القبول") : t("Unlocks the track the buyer chose", "بتفتح المسار اللي المشترك اختاره")}
              </p>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}
