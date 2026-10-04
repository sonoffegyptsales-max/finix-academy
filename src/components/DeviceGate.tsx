import { useEffect, useState, type ReactNode } from "react";
import { useAuth } from "@/lib/auth";
import { useLang } from "@/lib/language";
import { claimDevice } from "@/lib/device.functions";
import { describeDevice, getDeviceId } from "@/lib/device";

type Gate = { state: "checking" } | { state: "ok" } | { state: "blocked"; devices: string[]; max: number };

/**
 * Runs the device check on EVERY dashboard visit, not only at sign-in.
 *
 * The database already refuses content to an unregistered device, but
 * without this gate such a device lands on an empty dashboard with no
 * explanation. This shows why, and how to fix it.
 */
export function DeviceGate({ children }: { children: ReactNode }) {
  const { user, isStaff, loading, signOut } = useAuth();
  const { t } = useLang();
  const [gate, setGate] = useState<Gate>({ state: "checking" });

  useEffect(() => {
    if (loading) return;
    if (!user || isStaff) {
      setGate({ state: "ok" });
      return;
    }
    let active = true;
    setGate({ state: "checking" });
    claimDevice({
      data: {
        deviceId: getDeviceId(),
        label: describeDevice(),
        userAgent: navigator.userAgent.slice(0, 400),
      },
    })
      .then((res: any) => {
        if (!active) return;
        if (res.status === "blocked") setGate({ state: "blocked", devices: res.devices ?? [], max: res.max ?? 2 });
        else setGate({ state: "ok" });
      })
      // Network hiccup: fail open in the UI; the database still guards content.
      .catch(() => active && setGate({ state: "ok" }));
    return () => {
      active = false;
    };
  }, [user?.id, isStaff, loading]);

  if (gate.state === "checking" && user && !isStaff) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <p className="text-sm text-muted-foreground">{t("Checking this device…", "بنتأكد من الجهاز…")}</p>
      </div>
    );
  }

  if (gate.state === "blocked") {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background px-6" data-testid="device-blocked">
        <div className="w-full max-w-md rounded-xl border border-amber-300 bg-amber-50 p-6 text-amber-900">
          <h1 className="text-xl font-bold">{t("Device limit reached", "وصلت للحد الأقصى من الأجهزة")}</h1>
          <p className="mt-3 text-sm leading-relaxed">
            {t(
              `Your account is already used on ${gate.max} devices, the maximum allowed:`,
              `حسابك مستخدم على ${gate.max} أجهزة بالفعل، وده الحد الأقصى:`,
            )}
          </p>
          <ul className="mt-2 list-inside list-disc text-sm font-medium">
            {gate.devices.map((d, i) => (
              <li key={i}>{d}</li>
            ))}
          </ul>
          <p className="mt-3 text-sm leading-relaxed">
            {t(
              "Open the academy from one of those devices. If you changed your phone or computer, contact the academy and they will free a device for you.",
              "افتح الأكاديمية من جهاز من دول. ولو غيّرت موبايلك أو الكمبيوتر، كلّم الأكاديمية وهي تفضّيلك مكان جهاز.",
            )}
          </p>
          <button
            onClick={() => void signOut().then(() => (window.location.href = "/auth"))}
            className="mt-5 rounded-lg bg-amber-600 px-4 py-2 text-sm font-medium text-white hover:bg-amber-700"
          >
            {t("Sign out", "تسجيل الخروج")}
          </button>
        </div>
      </div>
    );
  }

  return <>{children}</>;
}
