import { useCallback, useEffect, useState } from "react";

const STORAGE_KEY = "finix-progress";

function readCompleted(): string[] {
  if (typeof window === "undefined") return [];
  try {
    const parsed: unknown = JSON.parse(localStorage.getItem(STORAGE_KEY) ?? "[]");
    return Array.isArray(parsed) ? parsed.filter((s): s is string => typeof s === "string") : [];
  } catch {
    return [];
  }
}

/**
 * Module completion tracking for the Finix Academy portal.
 * Stored locally per browser until a per-user table is added to Supabase.
 */
export function useFinixProgress() {
  const [completed, setCompleted] = useState<string[]>([]);

  useEffect(() => {
    setCompleted(readCompleted());
    const onStorage = (e: StorageEvent) => {
      if (e.key === STORAGE_KEY) setCompleted(readCompleted());
    };
    window.addEventListener("storage", onStorage);
    return () => window.removeEventListener("storage", onStorage);
  }, []);

  const toggle = useCallback((slug: string) => {
    setCompleted((prev) => {
      const next = prev.includes(slug) ? prev.filter((s) => s !== slug) : [...prev, slug];
      localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
      return next;
    });
  }, []);

  return { completed, toggle, isComplete: (slug: string) => completed.includes(slug) };
}
