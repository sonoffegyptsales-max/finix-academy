import { Link } from "@tanstack/react-router";
import { useLang } from "@/lib/language";

/** Shown in place of lessons/quizzes when the trainee has no access yet. */
export function LockedNotice({ compact = false }: { compact?: boolean }) {
  const { t } = useLang();
  return (
    <div
      className={`rounded-xl border border-amber-300 bg-amber-50 text-amber-900 ${compact ? "p-4" : "p-6"}`}
      role="status"
    >
      <div className="flex items-start gap-3">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="mt-0.5 shrink-0" aria-hidden>
          <rect x="4" y="11" width="16" height="10" rx="2" />
          <path d="M8 11V7a4 4 0 0 1 8 0v4" />
        </svg>
        <div>
          <p className="font-semibold">{t("This module is locked", "الوحدة دي مقفولة")}</p>
          <p className="mt-1 text-sm leading-relaxed">
            {t(
              "Your trainer opens each module when your group reaches it, or it unlocks automatically once your payment is confirmed.",
              "المدرب بيفتح كل وحدة لما مجموعتك توصلها، أو بتتفتح تلقائيًا أول ما الدفع يتأكد.",
            )}
          </p>
          <Link
            to="/enroll"
            className="mt-3 inline-flex rounded-lg bg-amber-600 px-4 py-2 text-sm font-medium text-white hover:bg-amber-700"
          >
            {t("Buy access with InstaPay", "اشترك وادفع بانستاباي")}
          </Link>
        </div>
      </div>
    </div>
  );
}

export function LockBadge() {
  const { t } = useLang();
  return (
    <span className="inline-flex items-center gap-1 rounded-full border border-amber-300 bg-amber-50 px-2.5 py-0.5 text-[11px] font-medium text-amber-800">
      <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" aria-hidden>
        <rect x="4" y="11" width="16" height="10" rx="2" />
        <path d="M8 11V7a4 4 0 0 1 8 0v4" />
      </svg>
      {t("Locked", "مقفولة")}
    </span>
  );
}
