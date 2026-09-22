import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";

type Lang = "en" | "ar";

type LanguageValue = {
  lang: Lang;
  setLang: (l: Lang) => void;
  isRTL: boolean;
  /** Pick the correct string based on current language */
  t: (en: string, ar: string) => string;
};

const LanguageContext = createContext<LanguageValue>({
  lang: "en",
  setLang: () => {},
  isRTL: false,
  t: (en) => en,
});

const STORAGE_KEY = "lang";

function readStored(): Lang {
  if (typeof window === "undefined") return "en";
  const v = localStorage.getItem(STORAGE_KEY);
  return v === "ar" ? "ar" : "en";
}

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [lang, setLangState] = useState<Lang>(readStored);

  const setLang = useCallback((l: Lang) => {
    setLangState(l);
    localStorage.setItem(STORAGE_KEY, l);
  }, []);

  const isRTL = lang === "ar";

  /**
   * Drive the document's real direction and language.
   *
   * isRTL was computed here from the start but never applied to <html>, so
   * choosing Arabic translated the words while the page stayed left-to-right:
   * text hugged the left edge, sentences ended on the right, and punctuation
   * landed on the wrong side. Setting dir on the document element lets the
   * browser lay out every component RTL, and lets Tailwind's logical
   * properties (ms-/me-/ps-/pe-, start/end) mirror automatically.
   */
  useEffect(() => {
    if (typeof document === "undefined") return;
    const root = document.documentElement;
    root.setAttribute("dir", isRTL ? "rtl" : "ltr");
    root.setAttribute("lang", lang);
  }, [isRTL, lang]);

  const t = useCallback((en: string, ar: string) => (lang === "ar" ? ar : en), [lang]);

  const value = useMemo(() => ({ lang, setLang, isRTL, t }), [lang, setLang, isRTL, t]);

  return <LanguageContext.Provider value={value}>{children}</LanguageContext.Provider>;
}

export function useLang() {
  return useContext(LanguageContext);
}

export function LanguageToggle() {
  const { lang, setLang, t } = useLang();

  return (
    <button
      onClick={() => setLang(lang === "en" ? "ar" : "en")}
      className="flex items-center gap-1.5 rounded-full border border-border px-3 py-1.5 text-xs font-medium text-foreground transition-colors hover:bg-secondary"
    >
      <span className={lang === "en" ? "text-accent" : "text-muted-foreground"}>EN</span>
      <span className="text-border">/</span>
      <span className={lang === "ar" ? "text-accent" : "text-muted-foreground"}>عربي</span>
    </button>
  );
}
