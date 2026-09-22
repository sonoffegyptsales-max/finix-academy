import "./lib/error-capture";

import { consumeLastCapturedError } from "./lib/error-capture";
import { renderErrorPage } from "./lib/error-page";

type ServerEntry = {
  fetch: (request: Request, env: unknown, ctx: unknown) => Promise<Response> | Response;
};

let serverEntryPromise: Promise<ServerEntry> | undefined;

async function getServerEntry(): Promise<ServerEntry> {
  if (!serverEntryPromise) {
    serverEntryPromise = import("@tanstack/react-start/server-entry").then(
      (m) => (m.default ?? m) as ServerEntry,
    );
  }
  return serverEntryPromise;
}

// h3 swallows in-handler throws into a normal 500 Response with body
// {"unhandled":true,"message":"HTTPError"} — try/catch alone never fires for those.
async function normalizeCatastrophicSsrResponse(response: Response): Promise<Response> {
  if (response.status < 500) return response;
  const contentType = response.headers.get("content-type") ?? "";
  if (!contentType.includes("application/json")) return response;

  const body = await response.clone().text();
  if (!isH3SwallowedErrorBody(body)) return response;

  console.error(consumeLastCapturedError() ?? new Error(`h3 swallowed SSR error: ${body}`));
  return new Response(renderErrorPage(), {
    status: 500,
    headers: { "content-type": "text/html; charset=utf-8" },
  });
}

function isH3SwallowedErrorBody(body: string): boolean {
  try {
    const payload = JSON.parse(body) as { unhandled?: unknown; message?: unknown };
    return payload.unhandled === true && payload.message === "HTTPError";
  } catch {
    return false;
  }
}

/**
 * TEMPORARY diagnostic: reports which env var NAMES are visible to the
 * runtime, and from which source. Never reports a value -- only presence and
 * length -- so it is safe to hit in production. Remove once the trainee
 * creation fault is fixed.
 */
function envDiagnostic(env: unknown): Response {
  const names = [
    "SUPABASE_URL",
    "SUPABASE_SERVICE_ROLE_KEY",
    "SUPABASE_PUBLISHABLE_KEY",
    "VAPID_PUBLIC_KEY",
    "VAPID_PRIVATE_KEY",
  ];

  const binding = (env ?? {}) as Record<string, unknown>;
  const report = names.map((n) => {
    const fromProcess = typeof process !== "undefined" ? process.env?.[n] : undefined;
    const fromBinding = binding[n];
    return {
      name: n,
      inProcessEnv: typeof fromProcess === "string" && fromProcess.length > 0,
      processEnvLength: typeof fromProcess === "string" ? fromProcess.length : 0,
      inWorkerBinding: typeof fromBinding === "string" && fromBinding.length > 0,
      bindingLength: typeof fromBinding === "string" ? fromBinding.length : 0,
    };
  });

  return new Response(
    JSON.stringify(
      {
        runtime: typeof process === "undefined" ? "no-process-global" : "has-process-global",
        processEnvKeyCount:
          typeof process !== "undefined" && process.env ? Object.keys(process.env).length : 0,
        workerBindingKeyCount: Object.keys(binding).length,
        vars: report,
      },
      null,
      2,
    ),
    { status: 200, headers: { "content-type": "application/json" } },
  );
}

export default {
  async fetch(request: Request, env: unknown, ctx: unknown) {
    try {
      if (new URL(request.url).pathname === "/__envcheck") {
        return envDiagnostic(env);
      }
      const handler = await getServerEntry();
      const response = await handler.fetch(request, env, ctx);
      return await normalizeCatastrophicSsrResponse(response);
    } catch (error) {
      console.error(error);
      return new Response(renderErrorPage(), {
        status: 500,
        headers: { "content-type": "text/html; charset=utf-8" },
      });
    }
  },
};
