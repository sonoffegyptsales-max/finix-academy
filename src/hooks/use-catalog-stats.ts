import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";

export type CatalogStats = {
  tracks: number;
  modules: number;
  lessons: number;
  questions: number;
};

/** Live public catalogue counts from the public_catalog_stats() RPC.
 *
 * The landing page used to show "10 modules / 4 tracks" from a static TS file
 * written before the real curriculum existed (22 modules, 3 tracks). Counts
 * only -- the RPC exposes no titles, bodies or answers, so anonymous visitors
 * see numbers without RLS being weakened. Falls back to null (the caller
 * renders nothing) rather than showing a stale guess.
 */
export function useCatalogStats(): CatalogStats | null {
  const [stats, setStats] = useState<CatalogStats | null>(null);

  useEffect(() => {
    let cancelled = false;
    void (async () => {
      const { data, error } = await supabase.rpc("public_catalog_stats" as never);
      if (!cancelled && !error && data) setStats(data as unknown as CatalogStats);
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  return stats;
}
