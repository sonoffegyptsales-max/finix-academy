import { Outlet, createFileRoute } from "@tanstack/react-router";
import { useAuth } from "@/lib/auth";
import { useLang, LanguageToggle } from "@/lib/language";

export const Route = createFileRoute("/dashboard")({
  component: DashboardLayout,
});

function DashboardLayout() {
  const { user, signOut, loading, isAdmin, isTrainer, isStaff } = useAuth();
  const { t, isRTL } = useLang();

  const roleLabel = isAdmin ? "Admin" : isTrainer ? "Trainer" : "Trainee";
  const roleBadgeColor = isAdmin
    ? "bg-destructive text-destructive-foreground"
    : isTrainer
      ? "bg-primary text-primary-foreground"
      : "bg-sidebar-accent text-sidebar-accent-foreground";

  const navItems = [
    { to: "/dashboard", label: t("Dashboard", "لوحة التحكم"), icon: "dashboard" },
    { to: "/dashboard/my-courses", label: t("My Courses", "دوراتي"), icon: "courses" },
    { to: "/dashboard/certifications", label: t("Certifications", "اعتمادات"), icon: "certs" },
    { to: "/dashboard/field-survey", label: t("Field Survey", "مسح الموقع"), icon: "survey" },
    ...(isStaff
      ? [{ to: "/dashboard/kpi-evaluator", label: t("KPI Evaluator", "تقييم الأداء"), icon: "kpi" }]
      : []),
    ...(isStaff
      ? [{
          to: "/dashboard/admin-panel",
          label: isAdmin ? t("Admin Panel", "لوحة الإدارة") : t("Trainer Panel", "لوحة المدرب"),
          icon: "admin",
        }]
      : []),
  ];

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <p className="text-sm text-muted-foreground">Loading…</p>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <div className="max-w-md text-center">
          <h1 className="text-2xl font-bold text-foreground">Credentials required</h1>
          <p className="mt-3 text-sm text-muted-foreground">
            {t("Sign in to access the dashboard.", "تسجيل الدخول للوصول إلى لوحة التحكم.")}
          </p>
          <a
            href="/auth"
            className="mt-6 inline-flex items-center justify-center rounded-lg bg-primary px-6 py-2.5 text-sm font-medium text-primary-foreground hover:bg-primary/90"
          >
            {t("Sign in", "تسجيل الدخول")}
          </a>
        </div>
      </div>
    );
  }

  return (
    <div className="flex min-h-screen bg-background">
      {/* Sidebar — matches target: dark slate-900 */}
      <aside className="relative w-64 flex-shrink-0 bg-sidebar border-r border-sidebar-border">
        {/* Logo */}
        <div className="flex h-16 items-center gap-2 border-b border-sidebar-border px-4">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-primary">
              <polygon points="13 2 3 14 12 14 14 18 21 10 19 8 13 2"/>
            </svg>
          </div>
          <div className="flex flex-col">
            <span className="text-sm font-semibold text-sidebar-foreground">Finix Academy</span>
            <span className="text-[10px] text-sidebar-accent-foreground">Finix Systems</span>
          </div>
        </div>

        {/* User profile */}
        <div className="flex items-center gap-3 border-b border-sidebar-border px-4 py-3">
          <div className="flex h-9 w-9 items-center justify-center rounded-full bg-primary text-primary-foreground text-sm font-semibold">
            {user.email?.charAt(0).toUpperCase() || "U"}
          </div>
          <div className="flex flex-col overflow-hidden">
            <span className="truncate text-sm font-medium text-sidebar-foreground">
              {user.email?.split("@")[0] || "User"}
            </span>
            <span className={`w-fit rounded-full px-1.5 py-0.5 text-[10px] font-semibold ${roleBadgeColor}`}>
              {roleLabel}
            </span>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex flex-col gap-0.5 px-2 py-3">
          {navItems.map((item) => {
            const isActive =
              typeof window !== "undefined" &&
              window.location.pathname === item.to;
            return (
              <a
                key={item.to}
                href={item.to}
                className={`flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors ${
                  isActive
                    ? "bg-primary/10 text-sidebar-primary"
                    : "text-sidebar-accent-foreground hover:bg-sidebar-accent hover:text-sidebar-foreground"
                }`}
              >
                <NavIcon name={item.icon} className={isActive ? "text-primary" : "text-sidebar-accent-foreground"} />
                <span className="truncate">{item.label}</span>
                {isActive && (
                  <span className="ml-auto h-1.5 w-1.5 rounded-full bg-primary" />
                )}
              </a>
            );
          })}
        </nav>

        {/* Footer badge */}
        <div className="absolute bottom-0 left-0 right-0 border-t border-sidebar-border bg-sidebar/90 px-4 py-2">
          <a
            href="https://onhercules.app"
            target="_blank"
            rel="noreferrer"
            className="inline-flex items-center gap-1.5 rounded-full border border-sidebar-border bg-sidebar-accent/50 px-3 py-1 text-[10px] font-medium text-sidebar-accent-foreground hover:bg-sidebar-accent hover:text-sidebar-foreground transition-colors"
          >
            <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <polygon points="13 2 3 14 12 14 14 18 21 10 19 8 13 2"/>
            </svg>
            Built with Hercules
          </a>
        </div>
      </aside>

      {/* Main content */}
      <main className="flex flex-1 flex-col">
        {/* Top bar */}
        <div className="flex h-16 items-center justify-between border-b border-border bg-background px-6">
          <h2 className="text-lg font-semibold text-foreground">
            {isAdmin
              ? t("Admin Dashboard", "لوحة تحكم الإدارة")
              : isTrainer
                ? t("Trainer Dashboard", "لوحة تحكم المدرب")
                : t("My Dashboard", "لوحتي")}
          </h2>
          <div className="flex items-center gap-3">
            <LanguageToggle />
            <button className="relative rounded-lg p-1.5 text-muted-foreground hover:text-foreground hover:bg-secondary transition-colors">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
                <path d="M13.73 21a2 2 0 0 1-3.46 0"/>
              </svg>
              <span className="absolute -right-0.5 -top-0.5 h-2 w-2 rounded-full bg-primary border-2 border-background" />
            </button>
            <button className="flex items-center gap-2 rounded-lg border border-border bg-card px-3 py-1.5 text-xs text-foreground hover:bg-secondary transition-colors">
              <span className="font-medium">{user.email?.split("@")[0] || "User"}</span>
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="m6 9 6 6 6-6"/>
              </svg>
            </button>
            <button className="flex items-center gap-1.5 rounded-lg bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90 transition-colors">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V9a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
              </svg>
              Chat
            </button>
            <button
              onClick={() => {
                void signOut().then(() => window.location.href = "/auth");
              }}
              className="rounded-lg border border-border px-3 py-1.5 text-xs text-foreground hover:bg-secondary transition-colors"
            >
              {t("Sign out", "تسجيل الخروج")}
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1">
          <Outlet />
        </div>
      </main>
    </div>
  );
}

function NavIcon({ name, className }: { name: string; className?: string }) {
  const iconProps = {
    width: 18,
    height: 18,
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 2,
    strokeLinecap: "round",
    strokeLinejoin: "round",
  };
  switch (name) {
    case "dashboard":
      return (
        <svg {...iconProps} className={className}>
          <rect width="7" height="9" x="3" y="3" rx="1"/>
          <rect width="7" height="5" x="14" y="3" rx="1"/>
          <rect width="7" height="9" x="14" y="12" rx="1"/>
          <rect width="7" height="5" x="3" y="12" rx="1"/>
        </svg>
      );
    case "courses":
      return (
        <svg {...iconProps} className={className}>
          <path d="M2 3h20v18H2z"/>
          <path d="M7 8h10"/>
          <path d="M7 12h10"/>
          <path d="M7 16h6"/>
        </svg>
      );
    case "certs":
      return (
        <svg {...iconProps} className={className}>
          <circle cx="12" cy="8" r="7"/>
          <path d="M18 20a3 3 0 0 0-3-3M6 20a3 3 0 0 1 3-3"/>
          <path d="M12 13v4l1 2"/>
        </svg>
      );
    case "survey":
      return (
        <svg {...iconProps} className={className}>
          <rect width="18" height="12" x="3" y="3" rx="2"/>
          <path d="M8 13l-2 7"/>
          <path d="M16 13l2 7"/>
          <path d="m9 21 1-4h4l1 4"/>
        </svg>
      );
    case "kpi":
      return (
        <svg {...iconProps} className={className}>
          <path d="M18 20V10"/>
          <path d="M12 20V4"/>
          <path d="M6 20v-6"/>
        </svg>
      );
    case "admin":
      return (
        <svg {...iconProps} className={className}>
          <circle cx="12" cy="12" r="3"/>
          <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H9a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 12.6 9a1.65 1.65 0 0 0 .33-1.82l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V12a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/>
        </svg>
      );
    default:
      return null;
  }
}
