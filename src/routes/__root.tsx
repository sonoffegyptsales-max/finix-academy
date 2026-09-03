import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import {
  Outlet,
  Link,
  createRootRouteWithContext,
  useRouter,
  useNavigate,
  HeadContent,
  Scripts,
} from "@tanstack/react-router";
import { useEffect, type ReactNode } from "react";

import appCss from "../styles.css?url";
import { reportLovableError } from "../lib/lovable-error-reporting";
import { AuthProvider, useAuth } from "../lib/auth";
import { LanguageProvider } from "../lib/language";

function NotFoundComponent() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-4">
      <div className="max-w-md text-center">
        <h1 className="text-7xl font-bold text-foreground">404</h1>
        <h2 className="mt-4 text-xl font-semibold text-foreground">Page not found</h2>
        <p className="mt-2 text-sm text-muted-foreground">
          The page you're looking for doesn't exist or has been moved.
        </p>
        <div className="mt-6">
          <Link
            to="/"
            className="inline-flex items-center justify-center rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90"
          >
            Go home
          </Link>
        </div>
      </div>
    </div>
  );
}

function ErrorComponent({ error, reset }: { error: Error; reset: () => void }) {
  console.error(error);
  const router = useRouter();
  useEffect(() => {
    reportLovableError(error, { boundary: "tanstack_root_error_component" });
  }, [error]);

  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-4">
      <div className="max-w-md text-center">
        <h1 className="text-xl font-semibold tracking-tight text-foreground">
          This page didn't load
        </h1>
        <p className="mt-2 text-sm text-muted-foreground">
          Something went wrong on our end. You can try refreshing or head back home.
        </p>
        <div className="mt-6 flex flex-wrap justify-center gap-2">
          <button
            onClick={() => {
              router.invalidate();
              reset();
            }}
            className="inline-flex items-center justify-center rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90"
          >
            Try again
          </button>
          <a
            href="/"
            className="inline-flex items-center justify-center rounded-md border border-input bg-background px-4 py-2 text-sm font-medium text-foreground transition-colors hover:bg-accent"
          >
            Go home
          </a>
        </div>
      </div>
    </div>
  );
}

export const Route = createRootRouteWithContext<{ queryClient: QueryClient }>()({
  head: () => ({
    meta: [
      { charSet: "utf-8" },
      { name: "viewport", content: "width=device-width, initial-scale=1" },
      { title: "Finix Academy — Smart Home & Industrial Automation Training" },
      {
        name: "description",
        content:
          "Professional training for smart home installers and automation engineers: 10 modules across 4 tracks, tiered certifications, KPI evaluations and site survey tools.",
      },
      { name: "author", content: "Finix Systems" },
      { property: "og:title", content: "Finix Academy — Smart Home & Industrial Automation Training" },
      {
        property: "og:description",
        content: "10 modules · 4 tracks · Bronze/Silver/Gold certifications · bilingual EN/AR delivery.",
      },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
    ],
    links: [
      { rel: "stylesheet", href: appCss },
      { rel: "preconnect", href: "https://fonts.googleapis.com" },
      { rel: "preconnect", href: "https://fonts.gstatic.com", crossOrigin: "anonymous" },
      {
        rel: "stylesheet",
        href: "https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700&family=JetBrains+Mono:wght@400;500&family=Space+Grotesk:wght@400;500;600;700&display=swap",
      },
      { rel: "icon", href: "/favicon.ico", type: "image/x-icon" },
    ],
  }),
  shellComponent: RootShell,
  component: RootComponent,
  notFoundComponent: NotFoundComponent,
  errorComponent: ErrorComponent,
});

function RootShell({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <head>
        <HeadContent />
      </head>
      <body>
        {children}
        <Scripts />
      </body>
    </html>
  );
}

function SiteHeader() {
  const { user, signOut } = useAuth();
  const navigate = useNavigate();
  return (
    <header className="sticky top-0 z-50 border-b border-border bg-background/85 backdrop-blur">
      <div className="mx-auto flex max-w-5xl items-center justify-between gap-4 px-6 py-4">
        <Link to="/" className="font-mono text-sm font-semibold tracking-tight text-foreground">
          FINIX<span className="text-accent">ACADEMY</span>
        </Link>
        <nav className="flex items-center gap-5 text-sm text-muted-foreground">
          <Link to="/finix" activeProps={{ className: "text-accent" }}>
            Portal
          </Link>
          <Link to="/finix/certification" activeProps={{ className: "text-accent" }}>
            Certifications
          </Link>
          <Link to="/finix/kpi" activeProps={{ className: "text-accent" }}>
            KPI
          </Link>
          <Link to="/finix/survey" activeProps={{ className: "text-accent" }}>
            Survey
          </Link>
          {user ? (
            <button
              onClick={() => {
                void signOut().then(() => navigate({ to: "/auth" }));
              }}
              className="rounded-lg border border-border px-3 py-1.5 text-xs text-foreground hover:bg-secondary"
            >
              Sign out
            </button>
          ) : (
            <Link
              to="/auth"
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground"
            >
              Sign in
            </Link>
          )}
        </nav>
      </div>
    </header>
  );
}

function RootComponent() {
  const { queryClient } = Route.useRouteContext();

  return (
    <QueryClientProvider client={queryClient}>
      <LanguageProvider>
        <AuthProvider>
          <div className="min-h-screen bg-background font-sans text-foreground">
            <SiteHeader />
            {/* Required: nested routes render here. Removing <Outlet /> breaks all child routes. */}
            <Outlet />
            <footer className="border-t border-border px-6 py-10 text-center text-xs text-muted-foreground">
              Finix Systems · Smart Home & Industrial Automation Training
            </footer>
          </div>
        </AuthProvider>
      </LanguageProvider>
    </QueryClientProvider>
  );
}
