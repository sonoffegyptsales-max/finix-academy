import { useEffect, useRef, useState, type ReactNode } from "react";
import { useAuth } from "@/lib/auth";

/**
 * Wrapper for lesson material that raises the cost of copying it.
 *
 * WHAT THIS ACTUALLY DOES:
 *  - blocks selection, copy/cut, right-click, drag and print
 *  - blocks the usual save/print/devtools/screenshot key combinations
 *  - overlays a per-trainee watermark (email + time) so any photo or
 *    recording that escapes is traceable to the account that leaked it
 *  - hides the content whenever the tab loses focus, which is when most
 *    screenshot and capture tools are actually triggered
 *
 * WHAT IT CANNOT DO — be clear about this:
 *  A web page cannot block OS-level screen recording or a phone camera
 *  pointed at the screen. Browsers give no API for it, and anything that
 *  claims otherwise is selling you a deterrent. The watermark is the real
 *  protection: it makes leaks attributable rather than impossible.
 */
export function ProtectedContent({ children }: { children: ReactNode }) {
  const { user } = useAuth();
  const ref = useRef<HTMLDivElement>(null);
  const [hidden, setHidden] = useState(false);
  const [stamp, setStamp] = useState(() => new Date().toLocaleString());

  // Refresh the watermark clock so a screenshot carries a usable timestamp.
  useEffect(() => {
    const id = setInterval(() => setStamp(new Date().toLocaleString()), 30_000);
    return () => clearInterval(id);
  }, []);

  // Hide content when the tab is backgrounded or loses focus — this is the
  // moment most capture tooling fires.
  useEffect(() => {
    const hide = () => setHidden(true);
    const show = () => setHidden(false);
    const onVisibility = () => setHidden(document.visibilityState !== "visible");

    window.addEventListener("blur", hide);
    window.addEventListener("focus", show);
    document.addEventListener("visibilitychange", onVisibility);
    return () => {
      window.removeEventListener("blur", hide);
      window.removeEventListener("focus", show);
      document.removeEventListener("visibilitychange", onVisibility);
    };
  }, []);

  // Block copy paths and the common capture/save shortcuts.
  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    const stop = (e: Event) => {
      e.preventDefault();
      e.stopPropagation();
      return false;
    };

    const onKey = (e: KeyboardEvent) => {
      const k = e.key.toLowerCase();

      // PrintScreen: can't intercept the capture, but we can blank the
      // content and wipe the clipboard so the grab is useless.
      if (k === "printscreen") {
        setHidden(true);
        try {
          void navigator.clipboard.writeText("Finix Academy — protected material");
        } catch {
          /* clipboard permission denied; nothing to do */
        }
        setTimeout(() => setHidden(false), 1200);
        e.preventDefault();
        return;
      }

      const mod = e.ctrlKey || e.metaKey;

      // Save / print / copy / cut / select-all / view-source
      if (mod && ["s", "p", "c", "x", "a", "u"].includes(k)) {
        e.preventDefault();
        return;
      }
      // DevTools: Ctrl+Shift+I/J/C, F12
      if (mod && e.shiftKey && ["i", "j", "c"].includes(k)) {
        e.preventDefault();
        return;
      }
      if (k === "f12") {
        e.preventDefault();
        return;
      }
      // macOS screenshot combos (Cmd+Shift+3/4/5)
      if (e.metaKey && e.shiftKey && ["3", "4", "5"].includes(k)) {
        setHidden(true);
        setTimeout(() => setHidden(false), 1200);
        e.preventDefault();
      }
    };

    el.addEventListener("contextmenu", stop);
    el.addEventListener("copy", stop);
    el.addEventListener("cut", stop);
    el.addEventListener("dragstart", stop);
    el.addEventListener("selectstart", stop);
    document.addEventListener("keydown", onKey, true);

    return () => {
      el.removeEventListener("contextmenu", stop);
      el.removeEventListener("copy", stop);
      el.removeEventListener("cut", stop);
      el.removeEventListener("dragstart", stop);
      el.removeEventListener("selectstart", stop);
      document.removeEventListener("keydown", onKey, true);
    };
  }, []);

  const mark = `${user?.email ?? "Finix Academy"} · ${stamp}`;

  return (
    <div ref={ref} className="finix-protected relative">
      {/* Watermark: repeated so a partial crop still carries identity. */}
      <div
        aria-hidden="true"
        className="pointer-events-none absolute inset-0 z-10 overflow-hidden select-none"
      >
        <div className="flex h-full w-full flex-wrap content-start gap-x-16 gap-y-20 opacity-[0.07]">
          {Array.from({ length: 40 }).map((_, i) => (
            <span
              key={i}
              className="whitespace-nowrap text-[11px] font-semibold tracking-wide text-foreground"
              style={{ transform: "rotate(-24deg)" }}
            >
              {mark}
            </span>
          ))}
        </div>
      </div>

      {/* Content, blanked while the tab is not focused. */}
      <div className={hidden ? "pointer-events-none blur-xl select-none" : ""}>
        {children}
      </div>

      {hidden && (
        <div className="absolute inset-0 z-20 flex items-center justify-center rounded-xl bg-background/80 backdrop-blur-sm">
          <p className="max-w-xs text-center text-sm font-medium text-muted-foreground">
            Content hidden while this window is not in focus.
          </p>
        </div>
      )}
    </div>
  );
}
