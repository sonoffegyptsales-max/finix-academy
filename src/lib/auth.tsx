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

type AuthValue = {
  loading: boolean;
  user: User | null;
  isAdmin: boolean;
  signOut: () => Promise<void>;
};

const AuthContext = createContext<AuthValue>({
  loading: true,
  user: null,
  isAdmin: false,
  signOut: async () => {},
});

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let active = true;

    const loadRole = (uid: string | undefined) => {
      if (!uid) {
        setIsAdmin(false);
        return;
      }
      void supabase
        .from("user_roles")
        .select("role")
        .eq("user_id", uid)
        .eq("role", "admin")
        .maybeSingle()
        .then(({ data }) => {
          if (active) setIsAdmin(Boolean(data));
        });
    };

    const { data: sub } = supabase.auth.onAuthStateChange((_event, session) => {
      if (!active) return;
      setUser(session?.user ?? null);
      loadRole(session?.user?.id);
      setLoading(false);
    });

    void supabase.auth.getSession().then(({ data }) => {
      if (!active) return;
      setUser(data.session?.user ?? null);
      loadRole(data.session?.user?.id);
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
    setIsAdmin(false);
  }, []);

  const value = useMemo(
    () => ({ loading, user, isAdmin, signOut }),
    [loading, user, isAdmin, signOut],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  return useContext(AuthContext);
}

export function Protected({
  children,
  adminOnly,
}: {
  children: ReactNode;
  adminOnly?: boolean;
}) {
  const { loading, user, isAdmin } = useAuth();

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

  return <>{children}</>;
}
