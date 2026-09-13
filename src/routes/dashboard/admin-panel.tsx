import { createFileRoute } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { Protected, useAuth } from "@/lib/auth";
import { useLang } from "@/lib/language";
import { supabase } from "@/integrations/supabase/client";
import { useCurriculum } from "@/hooks/use-curriculum";
import { createTrainee, listTrainees, deleteTrainee } from "@/lib/trainees.functions";
import { sendPushToTrainees } from "@/lib/push.functions";

export const Route = createFileRoute("/dashboard/admin-panel")({
  head: () => ({
    meta: [{ title: "Admin Panel — Finix Academy" }],
  }),
  component: () => (
    <Protected staffOnly>
      <AdminPanelPage />
    </Protected>
  ),
});

interface UserRow {
  id: string;
  email: string;
  full_name: string | null;
  roles: string[];
}

type AdminTab = "overview" | "trainees" | "notify";

function AdminPanelPage() {
  const { t } = useLang();
  const { isAdmin } = useAuth();
  const { tracks, modules, loading: curriculumLoading } = useCurriculum();
  const [users, setUsers] = useState<UserRow[]>([]);
  const [usersLoading, setUsersLoading] = useState(true);
  const [certCount, setCertCount] = useState(0);
  const [attemptCount, setAttemptCount] = useState(0);
  const [tab, setTab] = useState<AdminTab>("overview");

  async function loadStats() {
    try {
      const [{ data: profiles }, { data: roles }, { count: certs }, { count: attempts }] =
        await Promise.all([
          supabase.from("profiles").select("id, email, full_name"),
          supabase.from("user_roles").select("user_id, role"),
          supabase.from("certificates").select("*", { count: "exact", head: true }),
          supabase.from("quiz_attempts").select("*", { count: "exact", head: true }),
        ]);

      const rolesByUser = new Map<string, string[]>();
      for (const r of roles ?? []) {
        const list = rolesByUser.get(r.user_id) ?? [];
        list.push(r.role);
        rolesByUser.set(r.user_id, list);
      }

      setUsers(
        (profiles ?? []).map((p) => ({
          id: p.id,
          email: p.email,
          full_name: p.full_name,
          roles: rolesByUser.get(p.id) ?? [],
        })),
      );
      setCertCount(certs ?? 0);
      setAttemptCount(attempts ?? 0);
    } catch {
      // Table not reachable yet — leave defaults.
    } finally {
      setUsersLoading(false);
    }
  }

  useEffect(() => {
    void loadStats();
  }, []);

  const statsCards = [
    {
      label: t("Total Users", "إجمالي المستخدمين"),
      value: `${users.length}`,
      sublabel: `${users.filter((u) => u.roles.includes("trainee") || u.roles.length === 0).length} ${t("trainees", "متدربين")} · ${users.filter((u) => u.roles.includes("trainer")).length} ${t("trainers", "مدربين")} · ${users.filter((u) => u.roles.includes("admin")).length} ${t("admins", "مدراء")}`,
      color: "text-sky-600 bg-sky-50",
    },
    {
      label: t("Modules Published", "الوحدات المنشورة"),
      value: `${modules.length}`,
      sublabel: `${modules.length} ${t("modules", "وحدات")} · ${tracks.length} ${t("tracks", "مسارات")}`,
      color: "text-green-600 bg-green-50",
    },
    {
      label: t("Total Quiz Attempts", "إجمالي محاولات الاختبار"),
      value: `${attemptCount}`,
      sublabel: attemptCount === 0 ? t("No attempts recorded", "لا توجد محاولات مسجلة") : "",
      color: "text-purple-600 bg-purple-50",
    },
    {
      label: t("Certificates Issued", "الاعتمادات الصادرة"),
      value: `${certCount}`,
      sublabel: certCount === 0 ? t("No certificates yet", "لا توجد اعتمادات بعد") : "",
      color: "text-yellow-600 bg-yellow-50",
    },
  ];

  const tabs: { id: AdminTab; label: string; adminOnly?: boolean }[] = [
    { id: "overview", label: t("Overview", "نظرة عامة") },
    { id: "trainees", label: t("Trainees", "المتدربون"), adminOnly: true },
    { id: "notify", label: t("Notifications", "الإشعارات"), adminOnly: true },
  ];

  return (
    <div className="p-6">
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">
            {isAdmin ? t("Admin Panel", "لوحة الإدارة") : t("Trainer Panel", "لوحة المدرب")}
          </h1>
          <p className="mt-1 text-sm text-muted-foreground">
            {t("Manage courses, users, and certifications", "إدارة الدورات والمستخدمين والاعتمادات")}
          </p>
        </div>
        <span className="rounded-full bg-destructive/10 px-3 py-1 text-xs font-medium text-destructive">
          {isAdmin ? "Admin" : "Trainer"}
        </span>
      </div>

      {/* Tab bar */}
      <div className="mb-6 flex gap-1 border-b border-border">
        {tabs
          .filter((tb) => !tb.adminOnly || isAdmin)
          .map((tb) => (
            <button
              key={tb.id}
              onClick={() => setTab(tb.id)}
              className={`-mb-px border-b-2 px-4 py-2 text-sm font-medium transition-colors ${
                tab === tb.id
                  ? "border-primary text-primary"
                  : "border-transparent text-muted-foreground hover:text-foreground"
              }`}
            >
              {tb.label}
            </button>
          ))}
      </div>

      {tab === "overview" && (
        <OverviewTab
          statsCards={statsCards}
          curriculumLoading={curriculumLoading}
          modules={modules}
          usersLoading={usersLoading}
          users={users}
        />
      )}

      {tab === "trainees" && isAdmin && <TraineesTab onChanged={loadStats} />}

      {tab === "notify" && isAdmin && <NotifyTab />}
    </div>
  );
}

function OverviewTab({
  statsCards,
  curriculumLoading,
  modules,
  usersLoading,
  users,
}: {
  statsCards: { label: string; value: string; sublabel: string; color: string }[];
  curriculumLoading: boolean;
  modules: any[];
  usersLoading: boolean;
  users: UserRow[];
}) {
  const { t } = useLang();
  return (
    <>
      <div className="mb-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {statsCards.map((stat) => (
          <div key={stat.label} className="overflow-hidden rounded-xl border border-border bg-card p-5 shadow-sm">
            <div className={`flex h-10 w-10 items-center justify-center rounded-lg ${stat.color}`}>
              <span className="text-lg font-bold">{stat.value.charAt(0)}</span>
            </div>
            <p className="mt-3 text-2xl font-bold text-foreground">{stat.value}</p>
            <p className="text-sm text-muted-foreground">{stat.label}</p>
            {stat.sublabel && <p className="text-xs text-muted-foreground/70">{stat.sublabel}</p>}
          </div>
        ))}
      </div>

      <h2 className="mb-4 text-lg font-semibold text-foreground">{t("Curriculum", "المنهج")}</h2>
      <div className="mb-8 overflow-hidden rounded-xl border border-border bg-card">
        {curriculumLoading ? (
          <p className="p-6 text-sm text-muted-foreground">{t("Loading…", "جارٍ التحميل…")}</p>
        ) : (
          <div className="divide-y divide-border">
            {modules.map((m) => (
              <div key={m.id} className="flex items-center justify-between gap-4 p-4">
                <div className="flex items-center gap-3">
                  <span className="font-mono text-xs text-muted-foreground">{m.code}</span>
                  <span className="text-sm font-medium text-foreground">{m.title}</span>
                  <span className="text-xs text-muted-foreground">
                    {m.lessons.length} {t("lessons", "دروس")}
                  </span>
                </div>
                <span
                  className={`rounded-full px-2.5 py-0.5 text-[11px] font-medium ${
                    m.published ? "bg-green-500/10 text-green-700" : "bg-secondary text-muted-foreground"
                  }`}
                >
                  {m.published ? t("Published", "منشورة") : t("Draft", "مسودة")}
                </span>
              </div>
            ))}
          </div>
        )}
      </div>

      <h2 className="mb-4 text-lg font-semibold text-foreground">{t("Users", "المستخدمون")}</h2>
      <div className="mb-8 overflow-hidden rounded-xl border border-border bg-card">
        {usersLoading ? (
          <p className="p-6 text-sm text-muted-foreground">{t("Loading…", "جارٍ التحميل…")}</p>
        ) : users.length === 0 ? (
          <p className="p-6 text-sm text-muted-foreground">
            {t("No users found — backend not connected yet.", "لا يوجد مستخدمون — لم يتم توصيل الخادم بعد.")}
          </p>
        ) : (
          <div className="divide-y divide-border">
            {users.map((u) => (
              <div key={u.id} className="flex items-center justify-between gap-4 p-4">
                <div>
                  <p className="text-sm font-medium text-foreground">{u.full_name || u.email}</p>
                  <p className="text-xs text-muted-foreground">{u.email}</p>
                </div>
                <div className="flex gap-1.5">
                  {u.roles.length === 0 ? (
                    <span className="rounded-full bg-secondary px-2.5 py-0.5 text-[11px] text-muted-foreground">
                      {t("trainee", "متدرب")}
                    </span>
                  ) : (
                    u.roles.map((r) => (
                      <span
                        key={r}
                        className={`rounded-full px-2.5 py-0.5 text-[11px] font-medium capitalize ${
                          r === "admin"
                            ? "bg-destructive/10 text-destructive"
                            : r === "trainer"
                              ? "bg-primary/10 text-primary"
                              : "bg-secondary text-muted-foreground"
                        }`}
                      >
                        {r}
                      </span>
                    ))
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </>
  );
}

interface TraineeRow {
  id: string;
  email: string;
  full_name: string | null;
}

function TraineesTab({ onChanged }: { onChanged: () => void }) {
  const { t } = useLang();
  const [trainees, setTrainees] = useState<TraineeRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [email, setEmail] = useState("");
  const [fullName, setFullName] = useState("");
  const [password, setPassword] = useState("");
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<{ kind: "ok" | "err"; text: string } | null>(null);

  async function load() {
    setLoading(true);
    try {
      const res = await listTrainees();
      setTrainees(res.trainees ?? []);
    } catch (e: any) {
      setMsg({ kind: "err", text: e?.message ?? "Failed to load trainees." });
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void load();
  }, []);

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setMsg(null);
    try {
      await createTrainee({ data: { email: email.trim(), password, fullName: fullName.trim() } });
      setMsg({ kind: "ok", text: t("Trainee created.", "تم إنشاء المتدرب.") });
      setEmail("");
      setFullName("");
      setPassword("");
      await load();
      onChanged();
    } catch (e: any) {
      setMsg({ kind: "err", text: e?.message ?? "Failed to create trainee." });
    } finally {
      setBusy(false);
    }
  }

  async function handleDelete(id: string) {
    if (!confirm(t("Delete this trainee account permanently?", "حذف حساب هذا المتدرب نهائيًا؟"))) return;
    try {
      await deleteTrainee({ data: { userId: id } });
      await load();
      onChanged();
    } catch (e: any) {
      setMsg({ kind: "err", text: e?.message ?? "Failed to delete trainee." });
    }
  }

  return (
    <div className="grid gap-8 lg:grid-cols-[380px_1fr]">
      {/* Create form */}
      <div>
        <h2 className="mb-4 text-lg font-semibold text-foreground">
          {t("Create Trainee Account", "إنشاء حساب متدرب")}
        </h2>
        <form
          onSubmit={handleCreate}
          className="space-y-4 rounded-xl border border-border bg-card p-5 shadow-sm"
        >
          <div>
            <label className="mb-1 block text-sm font-medium text-foreground">
              {t("Full name", "الاسم الكامل")}
            </label>
            <input
              type="text"
              required
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm"
              placeholder={t("e.g. Ahmed Hassan", "مثال: أحمد حسن")}
            />
          </div>
          <div>
            <label className="mb-1 block text-sm font-medium text-foreground">
              {t("Email", "البريد الإلكتروني")}
            </label>
            <input
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm"
              placeholder="trainee@example.com"
            />
          </div>
          <div>
            <label className="mb-1 block text-sm font-medium text-foreground">
              {t("Temporary password", "كلمة مرور مؤقتة")}
            </label>
            <input
              type="text"
              required
              minLength={6}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm"
              placeholder={t("At least 6 characters", "6 أحرف على الأقل")}
            />
            <p className="mt-1 text-xs text-muted-foreground">
              {t(
                "Share this with the trainee so they can sign in.",
                "شارك هذه مع المتدرب لتسجيل الدخول.",
              )}
            </p>
          </div>
          <button
            type="submit"
            disabled={busy}
            className="w-full rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-60"
          >
            {busy ? t("Creating…", "جارٍ الإنشاء…") : t("Create Trainee", "إنشاء متدرب")}
          </button>
          {msg && (
            <p className={`text-sm ${msg.kind === "ok" ? "text-green-600" : "text-destructive"}`}>
              {msg.text}
            </p>
          )}
        </form>
      </div>

      {/* Trainee list */}
      <div>
        <h2 className="mb-4 text-lg font-semibold text-foreground">
          {t("Trainees", "المتدربون")}{" "}
          <span className="text-sm font-normal text-muted-foreground">({trainees.length})</span>
        </h2>
        <div className="overflow-hidden rounded-xl border border-border bg-card">
          {loading ? (
            <p className="p-6 text-sm text-muted-foreground">{t("Loading…", "جارٍ التحميل…")}</p>
          ) : trainees.length === 0 ? (
            <p className="p-6 text-sm text-muted-foreground">
              {t("No trainees yet. Create one on the left.", "لا يوجد متدربون بعد. أنشئ واحدًا على اليسار.")}
            </p>
          ) : (
            <div className="divide-y divide-border">
              {trainees.map((tr) => (
                <div key={tr.id} className="flex items-center justify-between gap-4 p-4">
                  <div>
                    <p className="text-sm font-medium text-foreground">{tr.full_name || tr.email}</p>
                    <p className="text-xs text-muted-foreground">{tr.email}</p>
                  </div>
                  <button
                    onClick={() => handleDelete(tr.id)}
                    className="rounded-lg border border-destructive/30 px-3 py-1 text-xs font-medium text-destructive hover:bg-destructive/10"
                  >
                    {t("Delete", "حذف")}
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

function NotifyTab() {
  const { t } = useLang();
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [url, setUrl] = useState("");
  const [busy, setBusy] = useState(false);
  const [result, setResult] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);

  async function handleSend(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setResult(null);
    setErr(null);
    try {
      const res: any = await sendPushToTrainees({
        data: { title: title.trim(), body: body.trim(), url: url.trim() || undefined },
      });
      setResult(
        t(
          `Sent to ${res.sent} device(s) across ${res.recipients} trainee(s). ${res.failed} failed.`,
          `أُرسل إلى ${res.sent} جهاز عبر ${res.recipients} متدرب. فشل ${res.failed}.`,
        ),
      );
      setTitle("");
      setBody("");
      setUrl("");
    } catch (e: any) {
      setErr(e?.message ?? "Failed to send notification.");
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="max-w-xl">
      <h2 className="mb-2 text-lg font-semibold text-foreground">
        {t("Send Push Notification to Trainees", "إرسال إشعار لكل المتدربين")}
      </h2>
      <p className="mb-4 text-sm text-muted-foreground">
        {t(
          "This sends a browser push notification to every trainee who has enabled notifications, and logs it in their in-app inbox.",
          "يرسل هذا إشعار متصفح لكل متدرب فعّل الإشعارات، ويسجله في صندوق الوارد داخل التطبيق.",
        )}
      </p>
      <form onSubmit={handleSend} className="space-y-4 rounded-xl border border-border bg-card p-5 shadow-sm">
        <div>
          <label className="mb-1 block text-sm font-medium text-foreground">{t("Title", "العنوان")}</label>
          <input
            type="text"
            required
            maxLength={120}
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm"
            placeholder={t("e.g. New lesson available", "مثال: درس جديد متاح")}
          />
        </div>
        <div>
          <label className="mb-1 block text-sm font-medium text-foreground">{t("Message", "الرسالة")}</label>
          <textarea
            required
            maxLength={500}
            rows={3}
            value={body}
            onChange={(e) => setBody(e.target.value)}
            className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm"
            placeholder={t("What do you want to tell your trainees?", "ماذا تريد أن تخبر متدربيك؟")}
          />
        </div>
        <div>
          <label className="mb-1 block text-sm font-medium text-foreground">
            {t("Link (optional)", "رابط (اختياري)")}
          </label>
          <input
            type="text"
            value={url}
            onChange={(e) => setUrl(e.target.value)}
            className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm"
            placeholder="/dashboard/my-courses"
          />
        </div>
        <button
          type="submit"
          disabled={busy}
          className="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-60"
        >
          {busy ? t("Sending…", "جارٍ الإرسال…") : t("Send to all trainees", "إرسال لكل المتدربين")}
        </button>
        {result && <p className="text-sm text-green-600">{result}</p>}
        {err && <p className="text-sm text-destructive">{err}</p>}
      </form>
    </div>
  );
}
