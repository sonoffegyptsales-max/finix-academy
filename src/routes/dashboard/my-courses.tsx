import { createFileRoute } from "@tanstack/react-router";
import { useLang } from "@/lib/language";
import { finixModules } from "@/content/finix";

export const Route = createFileRoute("/dashboard/my-courses")({
  head: () => ({
    meta: [{ title: "My Courses — Finix Academy" }],
  }),
  component: MyCoursesPage,
});

const trackColors = {
  "hardware-foundations": "bg-sky-500/10 text-sky-600",
  "networking-protocols": "bg-green-500/10 text-green-600",
  "team-project-management": "bg-amber-500/10 text-amber-600",
  "survey-terminology-tools": "bg-purple-500/10 text-purple-600",
};

const trackNames = {
  "hardware-foundations": "Electrical & Automation Hardware",
  "networking-protocols": "Networking & Smart Home Protocols",
  "team-project-management": "Smart Home Team & Project Management",
  "survey-terminology-tools": "Site Survey & Field Tools",
};

function MyCoursesPage() {
  const tracks = [
    "hardware-foundations",
    "networking-protocols",
    "team-project-management",
    "survey-terminology-tools",
  ];

  return (
    <div className="p-6">
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">My Courses</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            {finixModules.length} modules · 4 tracks
          </p>
        </div>
        <span className="rounded-full bg-primary/10 px-3 py-1 text-xs font-medium text-primary">
          In Progress
        </span>
      </div>

      {tracks.map((trackId) => {
        const trackModules = finixModules.filter((m) => m.track === trackId);

        return (
          <section key={trackId} className="mb-8">
            <div className="mb-4 flex items-center gap-2">
              <span className={`rounded-full px-3 py-1 text-xs font-medium ${trackColors[trackId]}`}>
                {trackNames[trackId]}
              </span>
              <span className="text-xs text-muted-foreground">
                {trackModules.length} modules
              </span>
            </div>

            <div className="grid gap-4 md:grid-cols-2">
              {trackModules.map((mod) => (
                <div
                  key={mod.slug}
                  className="overflow-hidden rounded-xl border border-border bg-card p-5 shadow-sm transition-colors hover:border-primary/50 hover:bg-primary/5"
                >
                  <div className="flex items-start justify-between">
                    <div className="flex items-center gap-2">
                      <span className="font-mono text-xs text-muted-foreground">{mod.code}</span>
                      <span className="rounded-full border border-border bg-secondary px-2 py-0.5 text-[11px] text-muted-foreground">
                        {mod.lessons.length} lessons
                      </span>
                    </div>
                    <span className="rounded-full border border-primary/20 bg-primary/10 px-2.5 py-0.5 text-[11px] font-medium text-primary">
                      Not started
                    </span>
                  </div>
                  <h3 className="mt-3 text-base font-semibold text-foreground">
                    {mod.title}
                  </h3>
                  <p className="mt-2 text-sm leading-relaxed text-muted-foreground line-clamp-2">
                    {mod.summary}
                  </p>
                  <div className="mt-4 flex items-center gap-2">
                    <a
                      href={mod.url}
                      target="_blank"
                      rel="noreferrer"
                      className="inline-flex items-center gap-1.5 rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 transition-colors"
                    >
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/>
                        <polyline points="15 3 21 3 21 9"/>
                        <line x1="10" y1="14" x2="21" y2="3"/>
                      </svg>
                      Start Module
                    </a>
                    <span className="text-xs text-muted-foreground">3 quizzes</span>
                  </div>
                </div>
              ))}
            </div>
          </section>
        );
      })}
    </div>
  );
}
