import { useEffect, useMemo, useState } from "react";
import { useLang } from "@/lib/language";
import { useCurriculum } from "@/hooks/use-curriculum";
import { createTrainer, deleteTrainer, listTrainers, setTrainerLessons } from "@/lib/trainers.functions";
import { CredentialsPanel } from "@/components/CredentialsPanel";

type Trainer = { userId: string; email: string; fullName: string | null; lessonIds: string[]; lastSignInAt: string | null };

const btn = "rounded-lg px-3 py-1.5 text-xs font-medium transition-colors disabled:opacity-50";
const input = "w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground outline-none focus:border-primary";

/** Admin: trainer accounts + which lessons each trainer can see and edit. */
export function TrainersTab() {
  const { t } = useLang();
  const { tracks, modules } = useCurriculum(true);
  const [trainers, setTrainers] = useState<Trainer[]>([]);
  const [sel, setSel] = useState<string>("");
  const [draft, setDraft] = useState<Set<string>>(new Set());
  const [dirty, setDirty] = useState(false);
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<{ kind: "ok" | "err"; text: string } | null>(null);
  const [form, setForm] = useState({ fullName: "", email: "", phone: "" });
  const [newCreds, setNewCreds] = useState<{ email: string; password: string } | null>(null);
  const [showCreds, setShowCreds] = useState(false);
  const [openMods, setOpenMods] = useState<Set<string>>(new Set());

  const load = async (keep?: string) => {
    setLoading(true);
    try {
      const res = await listTrainers();
      setTrainers(res.trainers);
      const pick = keep ?? res.trainers[0]?.userId ?? "";
      setSel(pick);
      setDraft(new Set(res.trainers.find((x: Trainer) => x.userId === pick)?.lessonIds ?? []));
      setDirty(false);
    } catch (e) {
      setMsg({ kind: "err", text: e instanceof Error ? e.message : String(e) });
    } finally {
      setLoading(false);
    }
  };
  useEffect(() => {
    void load();
  }, []);

  const current = trainers.find((x) => x.userId === sel);
  const select = (id: string) => {
    if (dirty && !confirm(t("Discard unsaved lesson changes?", "تلغي التغييرات اللي متحفظتش؟"))) return;
    setSel(id);
    setDraft(new Set(trainers.find((x) => x.userId === id)?.lessonIds ?? []));
    setDirty(false);
    setShowCreds(false);
    setMsg(null);
  };

  const toggle = (ids: string[], on: boolean) => {
    setDraft((d) => {
      const n = new Set(d);
      ids.forEach((id) => (on ? n.add(id) : n.delete(id)));
      return n;
    });
    setDirty(true);
  };

  const save = async () => {
    if (!current) return;
    setBusy(true);
    setMsg(null);
    try {
      const r = await setTrainerLessons({ data: { trainerId: current.userId, lessonIds: [...draft] } });
      setMsg({ kind: "ok", text: t(`Saved — ${r.total} lessons assigned.`, `اتحفظ — ${r.total} درس متاح للمدرب.`) });
      await load(current.userId);
    } catch (e) {
      setMsg({ kind: "err", text: e instanceof Error ? e.message : String(e) });
    } finally {
      setBusy(false);
    }
  };

  const create = async (e: React.FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setMsg(null);
    setNewCreds(null);
    try {
      const r = await createTrainer({ data: form });
      setNewCreds({ email: r.email, password: r.password });
      setForm({ fullName: "", email: "", phone: "" });
      await load(r.userId);
    } catch (e2) {
      setMsg({ kind: "err", text: e2 instanceof Error ? e2.message : String(e2) });
    } finally {
      setBusy(false);
    }
  };

  const remove = async () => {
    if (!current) return;
    if (!confirm(t(`Delete trainer ${current.email}? Their account and lesson list are removed.`, `تمسح المدرب ${current.email}؟ الحساب وقايمة دروسه هيتشالوا.`))) return;
    setBusy(true);
    try {
      await deleteTrainer({ data: { trainerId: current.userId } });
      await load();
    } catch (e) {
      setMsg({ kind: "err", text: e instanceof Error ? e.message : String(e) });
    } finally {
      setBusy(false);
    }
  };

  const totalLessons = useMemo(() => modules.reduce((n, m) => n + m.lessons.length, 0), [modules]);

  return (
    <div className="grid gap-6 lg:grid-cols-[300px_1fr]">
      {/* Left: create + list */}
      <div className="space-y-4">
        <form onSubmit={create} className="rounded-xl border border-border bg-card p-4">
          <p className="mb-3 text-sm font-semibold text-foreground">{t("New trainer", "مدرب جديد")}</p>
          <div className="space-y-2">
            <input className={input} placeholder={t("Full name", "الاسم بالكامل")} value={form.fullName} onChange={(e) => setForm({ ...form, fullName: e.target.value })} required minLength={2} />
            <input className={input} dir="ltr" type="email" placeholder={t("E-mail", "الإيميل")} value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} required />
            <input className={input} dir="ltr" inputMode="tel" placeholder={t("Mobile (optional)", "الموبايل (اختياري)")} value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} />
          </div>
          <button type="submit" disabled={busy} className={`${btn} mt-3 bg-primary text-primary-foreground hover:bg-primary/90`}>
            {t("Create trainer", "إنشاء مدرب")}
          </button>
        </form>

        {newCreds && (
          <div className="rounded-xl border-2 border-green-400 bg-green-50 p-4 text-sm text-green-900" data-testid="trainer-created">
            <p className="font-semibold">{t("Trainer created", "تم إنشاء المدرب")}</p>
            <p className="mt-2">
              {t("E-mail", "الإيميل")}: <span className="select-all font-mono" dir="ltr">{newCreds.email}</span>
            </p>
            <p className="mt-1">
              {t("Password", "كلمة السر")}: <span className="select-all font-mono text-base font-bold" dir="ltr" data-k="trainer-password">{newCreds.password}</span>
            </p>
            <p className="mt-2 text-xs text-amber-700">
              {t("Shown once. Send it to the trainer; they can change it from My account.", "بتظهر مرة واحدة. ابعتها للمدرب، ويقدر يغيّرها من «حسابي».")}
            </p>
            <button onClick={() => setNewCreds(null)} className="mt-2 text-xs underline">{t("Done — hide", "تمام — إخفاء")}</button>
          </div>
        )}

        <ul className="divide-y divide-border rounded-xl border border-border bg-card">
          {loading && trainers.length === 0 && <li className="p-4 text-sm text-muted-foreground">{t("Loading…", "جارٍ التحميل…")}</li>}
          {!loading && trainers.length === 0 && <li className="p-4 text-sm text-muted-foreground">{t("No trainers yet.", "مفيش مدربين لسه.")}</li>}
          {trainers.map((x) => (
            <li key={x.userId}>
              <button onClick={() => select(x.userId)} className={`block w-full px-4 py-3 text-start ${x.userId === sel ? "bg-primary/10" : "hover:bg-secondary"}`}>
                <span className="block truncate text-sm font-medium text-foreground">{x.fullName || x.email}</span>
                <span className="block truncate text-xs text-muted-foreground">
                  {x.lessonIds.length} {t("lessons", "درس")} · {x.email}
                </span>
              </button>
            </li>
          ))}
        </ul>
      </div>

      {/* Right: lesson picker */}
      <div>
        {msg && (
          <p className={`mb-4 rounded-lg px-4 py-2 text-sm ${msg.kind === "ok" ? "bg-green-50 text-green-800" : "bg-destructive/10 text-destructive"}`}>{msg.text}</p>
        )}
        {current ? (
          <>
            <div className="mb-4 flex flex-wrap items-center gap-2">
              <div className="me-auto min-w-0">
                <h3 className="truncate text-lg font-semibold text-foreground">{current.fullName || current.email}</h3>
                <p className="text-xs text-muted-foreground">
                  {t(
                    "Ticked lessons are the ONLY material this trainer can see and edit. They cannot create, delete or reorder lessons, or change quizzes.",
                    "الدروس المتعلّم عليها هي بس اللي المدرب يقدر يشوفها ويعدّلها. مينفعش يضيف أو يمسح أو يرتّب دروس، ولا يعدّل الاختبارات.",
                  )}
                </p>
              </div>
              <button onClick={() => setShowCreds((v) => !v)} className={`${btn} border border-primary/40 text-primary hover:bg-primary/10`}>
                {t("Login details", "بيانات الدخول")}
              </button>
              <button onClick={() => void remove()} disabled={busy} className={`${btn} border border-destructive/40 text-destructive hover:bg-destructive/10`}>
                {t("Delete trainer", "مسح المدرب")}
              </button>
            </div>
            {showCreds && <CredentialsPanel userId={current.userId} onClose={() => setShowCreds(false)} />}

            <div className="sticky top-0 z-10 my-3 flex flex-wrap items-center gap-3 rounded-xl border border-border bg-card/95 p-3 backdrop-blur">
              <span className="text-sm text-foreground">
                <b>{draft.size}</b> / {totalLessons} {t("lessons selected", "درس متعلّم عليه")}
              </span>
              <button onClick={() => toggle(modules.flatMap((m) => m.lessons.map((l) => l.id)), false)} className={`${btn} border border-border text-muted-foreground hover:bg-secondary`}>
                {t("Clear all", "شيل الكل")}
              </button>
              <button onClick={() => void save()} disabled={busy || !dirty} className={`${btn} ms-auto bg-primary text-primary-foreground hover:bg-primary/90`} data-testid="save-lessons">
                {busy ? t("Saving…", "جارٍ الحفظ…") : dirty ? t("Save changes", "حفظ التغييرات") : t("Saved", "محفوظ")}
              </button>
            </div>

            {tracks.map((tr) => {
              const mods = modules.filter((m) => m.track_id === tr.id && m.lessons.length > 0);
              if (mods.length === 0) return null;
              return (
                <section key={tr.id} className="mb-5">
                  <h4 className="mb-2 text-sm font-semibold text-foreground">{t(tr.name, tr.name_ar)}</h4>
                  <div className="divide-y divide-border rounded-xl border border-border bg-card">
                    {mods.map((m) => {
                      const ids = m.lessons.map((l) => l.id);
                      const n = ids.filter((id) => draft.has(id)).length;
                      const open = openMods.has(m.id) || (n > 0 && n < ids.length);
                      return (
                        <div key={m.id} className="px-4 py-2.5">
                          <div className="flex items-center gap-3">
                            <input
                              type="checkbox"
                              aria-label={m.code}
                              className="h-4 w-4"
                              checked={n === ids.length}
                              ref={(el) => {
                                if (el) el.indeterminate = n > 0 && n < ids.length;
                              }}
                              onChange={() => toggle(ids, n !== ids.length)}
                            />
                            <button
                              type="button"
                              onClick={() => setOpenMods((s) => { const x = new Set(s); x.has(m.id) ? x.delete(m.id) : x.add(m.id); return x; })}
                              className="flex flex-1 items-center gap-2 text-start text-sm"
                            >
                              <span className="font-mono text-xs text-muted-foreground">{m.code}</span>
                              <span className="flex-1 text-foreground">{t(m.title, m.title_ar)}</span>
                              <span className={`text-xs ${n ? "text-primary" : "text-muted-foreground"}`}>{n}/{ids.length}</span>
                              <span className="text-xs text-muted-foreground">{open ? "▾" : "▸"}</span>
                            </button>
                          </div>
                          {open && (
                            <ul className="mt-2 space-y-1 ps-7">
                              {m.lessons.map((l, i) => (
                                <li key={l.id}>
                                  <label className="flex cursor-pointer items-center gap-2 text-sm">
                                    <input type="checkbox" className="h-3.5 w-3.5" data-lesson={l.id} checked={draft.has(l.id)} onChange={() => toggle([l.id], !draft.has(l.id))} />
                                    <span className="font-mono text-[11px] text-muted-foreground">{String(i + 1).padStart(2, "0")}</span>
                                    <span className="text-foreground">{t(l.title, l.title_ar)}</span>
                                  </label>
                                </li>
                              ))}
                            </ul>
                          )}
                        </div>
                      );
                    })}
                  </div>
                </section>
              );
            })}
          </>
        ) : (
          !loading && <p className="text-sm text-muted-foreground">{t("Create a trainer to start.", "أنشئ مدرب علشان تبدأ.")}</p>
        )}
      </div>
    </div>
  );
}
