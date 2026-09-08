import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";
import type { User } from "@supabase/supabase-js";
import { Link } from "@tanstack/react-router";
import { supabase } from "@/integrations/supabase/client";

export type AppRole = "admin" | "trainer" | "trainee";

type AuthValue = {
  loading: boolean;
  user: User | null;
  isAdmin: boolean;
  isTrainer: boolean;
  /** True for admin OR trainer — anyone with staff/teaching privileges. */
  isStaff: boolean;
  roles: AppRole[];
  signOut: () => Promise<void>;
};

const AuthContext = createContext<AuthValue>({
  loading: true,
  user: null,
  isAdmin: false,
  isTrainer: false,
  isStaff: false,
  roles: [],
  signOut: async () => {},
});

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [roles, setRoles] = useState<AppRole[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let active = true;

    const loadRoles = (uid: string | undefined) => {
      if (!uid) {
        setRoles([]);
        return;
      }
      void supabase
        .from("user_roles")
        .select("role")
        .eq("user_id", uid)
        .then(({ data }) => {
          if (active) setRoles((data ?? []).map((r) => r.role as AppRole));
        });
    };

    const { data: sub } = supabase.auth.onAuthStateChange((_event, session) => {
      if (!active) return;
      setUser(session?.user ?? null);
      loadRoles(session?.user?.id);
      setLoading(false);
    });

    void supabase.auth.getSession().then(({ data }) => {
      if (!active) return;
      setUser(data.session?.user ?? null);
      loadRoles(data.session?.user?.id);
      setLoading(false);
    });

    return () => {
      active = false;
      sub.subscription.unsubscribe();
    };
  }, []);

  const signOut = useCallback(async () => {
    await supabase.auth.signOut();
    setUser(null);
    setRoles([]);
  }, []);

  const isAdmin = roles.includes("admin");
  const isTrainer = roles.includes("trainer");
  const isStaff = isAdmin || isTrainer;

  const value = useMemo(
    () => ({ loading, user, isAdmin, isTrainer, isStaff, roles, signOut }),
    [loading, user, isAdmin, isTrainer, isStaff, roles, signOut],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  return useContext(AuthContext);
}

export function Protected({
  children,
  adminOnly,
  staffOnly,
}: {
  children: ReactNode;
  /** Restrict to admin role only. */
  adminOnly?: boolean;
  /** Restrict to admin OR trainer (any staff role). */
  staffOnly?: boolean;
}) {
  const { loading, user, isAdmin, isStaff } = useAuth();

  if (loading) {
    return (
      <div className="mx-auto max-w-md px-6 py-24 text-center text-sm text-muted-foreground">
        Checking your access…
      </div>
    );
  }

  if (!user) {
    return (
      <div className="mx-auto max-w-md px-6 py-24 text-center">
        <h1 className="text-2xl font-bold text-foreground">Credentials required</h1>
        <p className="mt-3 text-sm text-muted-foreground">
          This programme is restricted to enrolled trainees. Accounts are issued by the
          programme administrator only.
        </p>
        <Link
          to="/auth"
          className="mt-6 inline-flex rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
        >
          Sign in
        </Link>
      </div>
    );
  }

  if (adminOnly && !isAdmin) {
    return (
      <div className="mx-auto max-w-md px-6 py-24 text-center">
        <h1 className="text-2xl font-bold text-foreground">Administrators only</h1>
        <p className="mt-3 text-sm text-muted-foreground">
          Your account does not have administrator rights.
        </p>
      </div>
    );
  }

  if (staffOnly && !isStaff) {
    return (
      <div className="mx-auto max-w-md px-6 py-24 text-center">
        <h1 className="text-2xl font-bold text-foreground">Staff only</h1>
        <p className="mt-3 text-sm text-muted-foreground">
          This page is restricted to trainers and administrators.
        </p>
      </div>
    );
  }

  return <>{children}</>;
}
