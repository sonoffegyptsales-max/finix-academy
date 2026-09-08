import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/dashboard/")({
  component: DashboardPage,
});

function DashboardPage() {
  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-foreground">
          Welcome back, Sonoff Egypt
        </h1>
        <p className="mt-1 text-sm text-muted-foreground">
          Admin Dashboard
        </p>
      </div>

      {/* Quick stats */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {[
          { label: "Total Trainees", value: "3", color: "bg-sky-50 text-sky-600", icon: "users" },
          { label: "Average Quiz Score", value: "0%", color: "bg-green-50 text-green-600", icon: "chart" },
          { label: "Pending Evaluations", value: "0", color: "bg-amber-50 text-amber-600", icon: "clipboard" },
          { label: "Certificates Issued", value: "0", color: "bg-yellow-50 text-yellow-600", icon: "award" },
        ].map((stat) => (
          <div
            key={stat.label}
            className="overflow-hidden rounded-xl border border-border bg-card p-5 shadow-sm"
          >
            <div className={`flex h-10 w-10 items-center justify-center rounded-lg ${stat.color}`}>
              <StatIcon name={stat.icon} className="h-5 w-5" />
            </div>
            <p className="mt-3 text-2xl font-bold text-foreground">{stat.value}</p>
            <p className="text-sm text-muted-foreground">{stat.label}</p>
          </div>
        ))}
      </div>

      {/* Quick actions */}
      <div className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {[
          { href: "/dashboard/my-courses", title: "My Courses", desc: `${finixModules.length} modules · 4 tracks`, color: "bg-primary/10 text-primary", icon: "book" },
          { href: "/dashboard/certifications", title: "Certifications", desc: "Bronze · Silver · Gold tiers", color: "bg-yellow-500/10 text-yellow-600", icon: "award" },
          { href: "/dashboard/kpi-evaluator", title: "KPI Evaluator", desc: "Evaluate technician performance", color: "bg-green-500/10 text-green-600", icon: "chart" },
          { href: "/dashboard/field-survey", title: "Field Survey", desc: "Site survey & audit tool", color: "bg-amber-500/10 text-amber-600", icon: "clipboard" },
        ].map((item) => (
          <a
            key={item.href}
            href={item.href}
            className="flex items-start gap-3 overflow-hidden rounded-xl border border-border bg-card p-5 text-left transition-colors hover:border-primary hover:bg-primary/5"
          >
            <div className={`flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg ${item.color}`}>
              <StatIcon name={item.icon} className="h-5 w-5" />
            </div>
            <div>
              <p className="text-sm font-semibold text-foreground">{item.title}</p>
              <p className="text-xs text-muted-foreground">{item.desc}</p>
            </div>
          </a>
        ))}
      </div>

      {/* Curriculum overview */}
      <div className="mt-8">
        <h2 className="mb-4 text-lg font-semibold text-foreground">Curriculum Overview</h2>
        <div className="overflow-hidden rounded-xl border border-border bg-card">
          <div className="divide-y divide-border">
            {finixTracks.map((track) => {
              const count = finixModules.filter((m) => m.track === track.id).length;
              const colors: Record<string, string> = {
                "hardware-foundations": "bg-sky-500/10 text-sky-600",
                "networking-protocols": "bg-green-500/10 text-green-600",
                "team-project-management": "bg-amber-500/10 text-amber-600",
                "survey-terminology-tools": "bg-purple-500/10 text-purple-600",
              };
              return (
                <div key={track.id} className="flex items-center justify-between gap-4 p-4">
                  <div className="flex items-center gap-3">
                    <span className={`rounded-full px-2.5 py-0.5 text-xs font-medium ${colors[track.id]}`}>
                      {track.name}
                    </span>
                  </div>
                  <span className="text-xs text-muted-foreground">
                    {count} modules
                  </span>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}

function StatIcon({ name, className }: { name: string; className?: string }) {
  const base = { width: 20, height: 20, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", strokeWidth: 2, strokeLinecap: "round", strokeLinejoin: "round" };
  switch (name) {
    case "users":
      return <svg {...base} className={className}><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>;
    case "chart":
      return <svg {...base} className={className}><path d="M18 20V10"/><path d="M12 20V4"/><path d="M6 20v-6"/></svg>;
    case "clipboard":
      return <svg {...base} className={className}><rect width="18" height="12" x="3" y="3" rx="2"/><path d="M8 13l-2 7"/><path d="M16 13l2 7"/><path d="m9 21 1-4h4l1 4"/></svg>;
    case "award":
      return <svg {...base} className={className}><circle cx="12" cy="8" r="7"/><path d="M18 20a3 3 0 0 0-3-3M6 20a3 3 0 0 1 3-3"/><path d="M12 13v4l1 2"/></svg>;
    case "book":
      return <svg {...base} className={className}><path d="M2 3h20v18H2z"/><path d="M7 8h10"/><path d="M7 12h10"/><path d="M7 16h6"/></svg>;
    default:
      return null;
  }
}

import { finixModules, finixTracks } from "@/content/finix";
