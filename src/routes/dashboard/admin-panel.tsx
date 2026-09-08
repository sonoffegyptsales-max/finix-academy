import { createFileRoute } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { Protected, useAuth } from "@/lib/auth";
import { useLang } from "@/lib/language";
import { supabase } from "@/integrations/supabase/client";
import { useCurriculum } from "@/hooks/use-curriculum";

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

function AdminPanelPage() {
  const { t } = useLang();
  const { isAdmin } = useAuth();
  const { tracks, modules, loading: curriculumLoading } = useCurriculum();
  const [users, setUsers] = useState<UserRow[]>([]);
  const [usersLoading, setUsersLoading] = useState(true);
  const [certCount, setCertCount] = useState(0);
  const [attemptCount, setAttemptCount] = useState(0);

  useEffect(() => {
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

      {/* Curriculum management */}
      <h2 className="mb-4 text-lg font-semibold text-foreground">
        {t("Curriculum", "المنهج")}
      </h2>
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
        <div className="border-t border-border bg-muted/30 px-4 py-3 text-xs text-muted-foreground">
          {t(
            "Full course/lesson/quiz authoring UI is on the roadmap — for now, edit content directly via the Supabase table editor or SQL.",
            "واجهة تحرير الدورات والدروس والاختبارات الكاملة قيد التطوير — حاليًا، عدّل المحتوى مباشرة عبر محرر جداول Supabase أو SQL.",
          )}
        </div>
      </div>

      {/* Users */}
      <h2 className="mb-4 text-lg font-semibold text-foreground">
        {t("Users", "المستخدمون")}
      </h2>
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

      {/* System info */}
      <div className="overflow-hidden rounded-xl border border-border bg-card p-6">
        <h2 className="mb-4 text-lg font-semibold text-foreground">
          {t("System Information", "معلومات النظام")}
        </h2>
        <div className="grid gap-3 sm:grid-cols-2">
          <div className="flex items-center justify-between rounded-lg bg-background px-4 py-3">
            <span className="text-sm text-muted-foreground">{t("Platform", "المنصة")}</span>
            <span className="text-sm font-medium text-foreground">Finix Academy</span>
          </div>
          <div className="flex items-center justify-between rounded-lg bg-background px-4 py-3">
            <span className="text-sm text-muted-foreground">{t("Built with", "بُني باستخدام")}</span>
            <a
              href="https://onhercules.app"
              target="_blank"
              rel="noreferrer"
              className="inline-flex items-center gap-1.5 rounded-full border border-border bg-muted px-2 py-0.5 text-xs font-medium text-muted-foreground hover:bg-secondary"
            >
              Hercules
            </a>
          </div>
          <div className="flex items-center justify-between rounded-lg bg-background px-4 py-3">
            <span className="text-sm text-muted-foreground">{t("Curriculum source", "مصدر المنهج")}</span>
            <span className="text-sm font-medium text-foreground">
              {curriculumLoading
                ? "…"
                : modules.length > 0
                  ? t("Live (Supabase)", "مباشر (Supabase)")
                  : t("Fallback (bundled)", "احتياطي (مدمج)")}
            </span>
          </div>
        </div>
      </div>
    </div>
  );
}
