/**
 * Admin → Branding: replace the site logo and favicon.
 *
 * The admin picks ONE file per group; the browser renders every required size
 * from it (white logo variant, 192/512 PWA icons, maskable icon, Apple touch
 * icon, favicon) before uploading. That avoids asking a non-designer to
 * prepare seven correctly-sized files by hand.
 *
 * Uploads go through a server function that checks the admin role and writes
 * with the service-role key, so no storage RLS policy is required.
 */

import { useState } from "react";
import { useLang } from "@/lib/language";
import { uploadBrandSet } from "@/lib/branding.functions";
import { renderLogoSet, renderIconSet, useBranding } from "@/lib/branding";

export function BrandingTab() {
  const { t } = useLang();
  const branding = useBranding();

  const [logoFile, setLogoFile] = useState<File | null>(null);
  const [iconFile, setIconFile] = useState<File | null>(null);
  const [logoPreview, setLogoPreview] = useState<string | null>(null);
  const [iconPreview, setIconPreview] = useState<string | null>(null);
  const [busy, setBusy] = useState<"logo" | "icon" | null>(null);
  const [msg, setMsg] = useState<{ kind: "ok" | "err"; text: string } | null>(null);
  // Bumped after a successful upload so the <img> tags refetch rather than
  // showing the browser-cached previous asset.
  const [refresh, setRefresh] = useState(0);

  function pick(
    file: File | null,
    setFile: (f: File | null) => void,
    setPreview: (s: string | null) => void,
  ) {
    setMsg(null);
    setFile(file);
    if (!file) {
      setPreview(null);
      return;
    }
    if (!file.type.startsWith("image/")) {
      setMsg({
        kind: "err",
        text: t("Please choose an image file.", "يرجى اختيار ملف صورة."),
      });
      setFile(null);
      return;
    }
    if (file.size > 5 * 1024 * 1024) {
      setMsg({
        kind: "err",
        text: t("Maximum file size is 5 MB.", "الحد الأقصى لحجم الملف 5 ميجابايت."),
      });
      setFile(null);
      return;
    }
    const reader = new FileReader();
    reader.onload = () => setPreview(String(reader.result));
    reader.readAsDataURL(file);
  }

  async function submit(which: "logo" | "icon") {
    const file = which === "logo" ? logoFile : iconFile;
    if (!file) return;
    setBusy(which);
    setMsg(null);
    try {
      const assets =
        which === "logo" ? await renderLogoSet(file) : await renderIconSet(file);
      await uploadBrandSet({ data: { assets } });
      setMsg({
        kind: "ok",
        text:
          which === "logo"
            ? t(
                "Logo updated across the site.",
                "تم تحديث الشعار في جميع أنحاء الموقع.",
              )
            : t(
                "Favicon and app icons updated. Browser tabs may take a moment to refresh.",
                "تم تحديث أيقونة الموقع وأيقونات التطبيق. قد تستغرق تبويبات المتصفح لحظة للتحديث.",
              ),
      });
      if (which === "logo") {
        setLogoFile(null);
        setLogoPreview(null);
      } else {
        setIconFile(null);
        setIconPreview(null);
      }
      setRefresh((n) => n + 1);
    } catch (e: any) {
      setMsg({ kind: "err", text: e?.message || t("Upload failed.", "فشل الرفع.") });
    } finally {
      setBusy(null);
    }
  }

  const bust = (url: string) => `${url}${url.includes("?") ? "&" : "?"}r=${refresh}`;

  return (
    <div className="space-y-6">
      {msg && (
        <div
          className={`rounded-lg border px-4 py-3 text-sm ${
            msg.kind === "ok"
              ? "border-emerald-200 bg-emerald-50 text-emerald-800"
              : "border-destructive/30 bg-destructive/10 text-destructive"
          }`}
        >
          {msg.text}
        </div>
      )}

      {/* Current branding */}
      <div className="rounded-xl border border-border bg-card p-5">
        <h2 className="text-sm font-semibold text-foreground">
          {t("Current branding", "الهوية الحالية")}
        </h2>
        <p className="mt-1 text-xs text-muted-foreground">
          {t(
            "These are the assets currently served across the site, the installed app and browser tabs.",
            "هذه هي الملفات المستخدمة حالياً في الموقع والتطبيق المثبّت وتبويبات المتصفح.",
          )}
        </p>

        <div className="mt-4 grid gap-4 sm:grid-cols-2">
          <div className="rounded-lg border border-border bg-white p-4">
            <div className="text-[11px] font-medium text-slate-500">
              {t("Logo on light background", "الشعار على خلفية فاتحة")}
            </div>
            <img src={bust(branding.logo)} alt="Logo" className="mt-3 h-10 object-contain" />
          </div>
          <div className="rounded-lg border border-border bg-[#0B1120] p-4">
            <div className="text-[11px] font-medium text-slate-400">
              {t("Logo on dark background", "الشعار على خلفية داكنة")}
            </div>
            <img
              src={bust(branding.logoLight)}
              alt="Logo light"
              className="mt-3 h-10 object-contain"
            />
          </div>
        </div>

        <div className="mt-4 flex flex-wrap items-end gap-5 rounded-lg border border-border bg-secondary/40 p-4">
          {[
            { src: branding.favicon, label: t("Favicon", "أيقونة الموقع"), size: "h-8 w-8" },
            { src: branding.icon192, label: "192px", size: "h-12 w-12" },
            { src: branding.icon512, label: "512px", size: "h-12 w-12" },
            { src: branding.iconMaskable, label: t("Maskable", "قابلة للقص"), size: "h-12 w-12" },
            { src: branding.appleTouch, label: "Apple", size: "h-12 w-12" },
          ].map((it) => (
            <div key={it.label} className="text-center">
              <img
                src={bust(it.src)}
                alt={it.label}
                className={`${it.size} rounded border border-border bg-white object-contain`}
              />
              <div className="mt-1 text-[10px] text-muted-foreground">{it.label}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Replace logo */}
      <div className="rounded-xl border border-border bg-card p-5">
        <h2 className="text-sm font-semibold text-foreground">
          {t("Replace logo", "تغيير الشعار")}
        </h2>
        <p className="mt-1 text-xs text-muted-foreground">
          {t(
            "Upload the full wordmark. A white version for dark backgrounds is generated automatically. PNG with a transparent or white background works best.",
            "ارفع الشعار الكامل. سيتم إنشاء نسخة بيضاء للخلفيات الداكنة تلقائياً. يفضّل استخدام صيغة PNG بخلفية شفافة أو بيضاء.",
          )}
        </p>

        <div className="mt-4 flex flex-wrap items-center gap-3">
          <input
            type="file"
            accept="image/png,image/jpeg,image/webp,image/svg+xml"
            onChange={(e) => pick(e.target.files?.[0] ?? null, setLogoFile, setLogoPreview)}
            className="text-sm text-muted-foreground file:me-3 file:rounded-lg file:border-0 file:bg-secondary file:px-3 file:py-2 file:text-sm file:font-medium file:text-foreground"
          />
          <button
            onClick={() => submit("logo")}
            disabled={!logoFile || busy !== null}
            className="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground disabled:opacity-50"
          >
            {busy === "logo" ? t("Uploading…", "جارٍ الرفع…") : t("Update logo", "تحديث الشعار")}
          </button>
        </div>

        {logoPreview && (
          <div className="mt-4 grid gap-3 sm:grid-cols-2">
            <div className="rounded-lg border border-border bg-white p-4">
              <div className="text-[11px] text-slate-500">
                {t("Preview — light", "معاينة — فاتح")}
              </div>
              <img src={logoPreview} alt="" className="mt-2 h-10 object-contain" />
            </div>
            <div className="rounded-lg border border-border bg-[#0B1120] p-4">
              <div className="text-[11px] text-slate-400">
                {t("Preview — dark", "معاينة — داكن")}
              </div>
              <img
                src={logoPreview}
                alt=""
                className="mt-2 h-10 object-contain brightness-0 invert"
              />
            </div>
          </div>
        )}
      </div>

      {/* Replace favicon / app icons */}
      <div className="rounded-xl border border-border bg-card p-5">
        <h2 className="text-sm font-semibold text-foreground">
          {t("Replace favicon and app icons", "تغيير أيقونة الموقع وأيقونات التطبيق")}
        </h2>
        <p className="mt-1 text-xs text-muted-foreground">
          {t(
            "Upload one square image — ideally just the logo mark, not the full wordmark, since it is displayed as small as 16 pixels. Every icon size is generated from it.",
            "ارفع صورة مربعة واحدة — يفضّل رمز الشعار فقط وليس الشعار الكامل، لأنه يظهر بحجم 16 بكسل. سيتم إنشاء جميع الأحجام منها.",
          )}
        </p>

        <div className="mt-4 flex flex-wrap items-center gap-3">
          <input
            type="file"
            accept="image/png,image/jpeg,image/webp,image/svg+xml"
            onChange={(e) => pick(e.target.files?.[0] ?? null, setIconFile, setIconPreview)}
            className="text-sm text-muted-foreground file:me-3 file:rounded-lg file:border-0 file:bg-secondary file:px-3 file:py-2 file:text-sm file:font-medium file:text-foreground"
          />
          <button
            onClick={() => submit("icon")}
            disabled={!iconFile || busy !== null}
            className="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground disabled:opacity-50"
          >
            {busy === "icon"
              ? t("Uploading…", "جارٍ الرفع…")
              : t("Update icons", "تحديث الأيقونات")}
          </button>
        </div>

        {iconPreview && (
          <div className="mt-4 flex flex-wrap items-end gap-5 rounded-lg border border-border bg-secondary/40 p-4">
            {[
              { cls: "h-4 w-4", label: "16px" },
              { cls: "h-8 w-8", label: "32px" },
              { cls: "h-16 w-16", label: "64px" },
            ].map((s) => (
              <div key={s.label} className="text-center">
                <img
                  src={iconPreview}
                  alt=""
                  className={`${s.cls} rounded border border-border bg-white object-contain`}
                />
                <div className="mt-1 text-[10px] text-muted-foreground">{s.label}</div>
              </div>
            ))}
            <p className="text-[11px] text-muted-foreground">
              {t(
                "Check the 16px preview — if the mark is unreadable at that size, use a simpler image.",
                "تحقق من المعاينة بحجم 16 بكسل — إذا كان الرمز غير واضح، استخدم صورة أبسط.",
              )}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
