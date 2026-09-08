import { createFileRoute } from "@tanstack/react-router";
import { useLang } from "@/lib/language";
import { finixModules, finixSurveyStages } from "@/content/finix";

export const Route = createFileRoute("/dashboard/admin-panel")({
  head: () => ({
    meta: [{ title: "Admin Panel — Finix Academy" }],
  }),
  component: AdminPanelPage,
});

const ENTRIES_KEY = "finix-admin-stats";

function AdminPanelPage() {
  const { t } = useLang();

  // Simulated admin stats
  const statsCards = [
    {
      label: "Total Users",
      value: "3",
      sublabel: "2 trainees · 1 admin",
      icon: (
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/>
          <circle cx="9" cy="7" r="4"/>
          <path d="M22 21v-2a4 4 0 0 0-3-3.87"/>
          <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
        </svg>
      ),
      color: "text-sky-600 bg-sky-50",
    },
    {
      label: "Modules Published",
      value: `${finixModules.length}`,
      sublabel: `${finixModules.length} modules · 4 tracks`,
      icon: (
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M2 3h20v18H2z"/>
          <path d="M7 8h10"/>
          <path d="M7 12h10"/>
          <path d="M7 16h6"/>
        </svg>
      ),
      color: "text-green-600 bg-green-50",
    },
    {
      label: "Pending Surveys",
      value: "0",
      sublabel: "No surveys pending",
      icon: (
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <rect width="18" height="12" x="3" y="3" rx="2"/>
          <path d="M8 13l-2 7"/>
          <path d="M16 13l2 7"/>
          <path d="m9 21 1-4h4l1 4"/>
        </svg>
      ),
      color: "text-amber-600 bg-amber-50",
    },
    {
      label: "Certificates Issued",
      value: "0",
      sublabel: "No certs issued yet",
      icon: (
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <circle cx="12" cy="8" r="7"/>
          <path d="M18 20a3 3 0 0 0-3-3M6 20a3 3 0 0 1 3-3"/>
          <path d="M12 13v4l1 2"/>
        </svg>
      ),
      color: "text-yellow-600 bg-yellow-50",
    },
  ];

  return (
    <div className="p-6">
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Admin Panel</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Manage courses, users, and certifications
          </p>
        </div>
        <span className="rounded-full bg-destructive/10 px-3 py-1 text-xs font-medium text-destructive">
          Admin
        </span>
      </div>

      {/* Admin stats */}
      <div className="mb-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {statsCards.map((stat) => (
          <div
            key={stat.label}
            className="overflow-hidden rounded-xl border border-border bg-card p-5 shadow-sm"
          >
            <div className="flex items-start justify-between">
              <div className={`flex h-10 w-10 items-center justify-center rounded-lg ${stat.color}`}>
                {stat.icon}
              </div>
              <span className="text-2xl font-bold text-foreground">{stat.value}</span>
            </div>
            <p className="mt-3 text-sm text-muted-foreground">{stat.label}</p>
            <p className="text-xs text-muted-foreground/70">{stat.sublabel}</p>
          </div>
        ))}
      </div>

      {/* Quick actions */}
      <h2 className="mb-4 text-lg font-semibold text-foreground">Quick Actions</h2>
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {[
          { href: "/dashboard/my-courses", title: "Manage Courses", desc: "Add, edit, or reorder modules", color: "bg-primary/10 text-primary" },
          { href: "/dashboard/certifications", title: "Certificates", desc: "View and manage issued certificates", color: "bg-yellow-500/10 text-yellow-600" },
          { href: "/dashboard/kpi-evaluator", title: "KPI Reports", desc: "Review technician evaluations", color: "bg-green-500/10 text-green-600" },
          { href: "/dashboard/field-survey", title: "Field Surveys", desc: "Review site survey reports", color: "bg-amber-500/10 text-amber-600" },
          { href: "/dashboard", title: "Dashboard", desc: "Overview and analytics", color: "bg-sky-500/10 text-sky-600" },
          { href: "/", title: "View Public Site", desc: "Preview the landing page", color: "bg-purple-500/10 text-purple-600" },
        ].map((action) => (
          <a
            key={action.href}
            href={action.href}
            className="flex items-start gap-3 overflow-hidden rounded-xl border border-border bg-card p-5 text-left transition-colors hover:border-primary hover:bg-primary/5"
          >
            <div className={`flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg ${action.color}`}>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M5 12h14M12 5l7 7-7 7"/>
              </svg>
            </div>
            <div>
              <p className="text-sm font-medium text-foreground">{action.title}</p>
              <p className="text-xs text-muted-foreground">{action.desc}</p>
            </div>
          </a>
        ))}
      </div>

      {/* System info */}
      <div className="mt-10 overflow-hidden rounded-xl border border-border bg-card p-6">
        <h2 className="mb-4 text-lg font-semibold text-foreground">System Information</h2>
        <div className="grid gap-3 sm:grid-cols-2">
          <div className="flex items-center justify-between rounded-lg bg-background px-4 py-3">
            <span className="text-sm text-muted-foreground">Platform</span>
            <span className="text-sm font-medium text-foreground">Finix Academy</span>
          </div>
          <div className="flex items-center justify-between rounded-lg bg-background px-4 py-3">
            <span className="text-sm text-muted-foreground">Built with</span>
            <a
              href="https://onhercules.app"
              target="_blank"
              rel="noreferrer"
              className="inline-flex items-center gap-1.5 rounded-full border border-border bg-muted px-2 py-0.5 text-xs font-medium text-muted-foreground hover:bg-secondary"
            >
              <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <polygon points="13 2 3 14 12 14 14 18 21 10 19 8 13 2"/>
              </svg>
              Hercules
            </a>
          </div>
          <div className="flex items-center justify-between rounded-lg bg-background px-4 py-3">
            <span className="text-sm text-muted-foreground">Version</span>
            <span className="text-sm font-medium text-foreground">1.0.0</span>
          </div>
          <div className="flex items-center justify-between rounded-lg bg-background px-4 py-3">
            <span className="text-sm text-muted-foreground">Schema</span>
            <span className="text-sm font-medium text-foreground">
              {finixModules.length} modules · {finixModules.length} tracks
            </span>
          </div>
        </div>
      </div>
    </div>
  );
}
