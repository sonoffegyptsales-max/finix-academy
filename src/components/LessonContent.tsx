/**
 * Renders a lesson body written in Markdown.
 *
 * Lesson content was authored in Markdown from the start, but was previously
 * rendered inside a plain <p className="whitespace-pre-line">. That printed the
 * syntax literally: trainees saw `**bold**`, `| a | b |` pipe rows and `- ` at
 * the start of every bullet instead of formatted text, tables and lists.
 *
 * react-markdown + remark-gfm (both already project dependencies) parse it
 * properly. The component map below styles each element to match the app and,
 * critically, keeps tables readable in Arabic: `text-align: start` mirrors
 * under dir="rtl" where a hardcoded `text-left` would not.
 */

import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import type { ReactNode } from "react";
import { useLang } from "@/lib/language";

export function LessonContent({
  children,
  className = "",
}: {
  children: string;
  className?: string;
}) {
  const { t } = useLang();

  if (!children?.trim()) return null;

  return (
    <div className={`finix-lesson-body text-sm leading-relaxed ${className}`}>
      <ReactMarkdown
        remarkPlugins={[remarkGfm]}
        components={{
          p: ({ children }: { children?: ReactNode }) => (
            <p className="mt-3 text-muted-foreground">{children}</p>
          ),

          strong: ({ children }: { children?: ReactNode }) => (
            <strong className="font-semibold text-foreground">{children}</strong>
          ),

          em: ({ children }: { children?: ReactNode }) => (
            <em className="italic">{children}</em>
          ),

          // Lists use list-OUTSIDE with logical padding.
          //
          // list-inside was tried first to make markers start at the line, but
          // it makes the marker an inline box at the start of the item's own
          // text flow: with a long Arabic paragraph the number ends up alone on
          // its line and the text wraps underneath it. list-outside hangs the
          // marker in the padding instead, giving a proper hanging indent, and
          // ps-* is logical so it mirrors to the right edge under dir="rtl".
          ul: ({ children }: { children?: ReactNode }) => (
            <ul className="mt-3 list-outside list-disc space-y-2 ps-5 text-muted-foreground marker:text-primary">
              {children}
            </ul>
          ),
          ol: ({ children }: { children?: ReactNode }) => (
            <ol className="mt-3 list-outside list-decimal space-y-2 ps-5 text-muted-foreground marker:font-semibold marker:text-primary">
              {children}
            </ol>
          ),
          li: ({ children }: { children?: ReactNode }) => (
            <li className="ps-1">{children}</li>
          ),

          // Tables: the single biggest readability win. These were previously
          // unreadable walls of pipe characters.
          table: ({ children }: { children?: ReactNode }) => (
            <div className="mt-4 overflow-x-auto rounded-lg border border-border">
              <table className="w-full border-collapse text-sm">{children}</table>
            </div>
          ),
          thead: ({ children }: { children?: ReactNode }) => (
            <thead className="bg-secondary/60">{children}</thead>
          ),
          tbody: ({ children }: { children?: ReactNode }) => (
            <tbody className="divide-y divide-border">{children}</tbody>
          ),
          tr: ({ children }: { children?: ReactNode }) => (
            <tr className="align-top">{children}</tr>
          ),
          th: ({ children }: { children?: ReactNode }) => (
            <th className="px-3 py-2 text-start font-semibold text-foreground">
              {children}
            </th>
          ),
          td: ({ children }: { children?: ReactNode }) => (
            <td className="px-3 py-2 text-start text-muted-foreground">{children}</td>
          ),

          h1: ({ children }: { children?: ReactNode }) => (
            <h3 className="mt-5 text-base font-bold text-foreground">{children}</h3>
          ),
          h2: ({ children }: { children?: ReactNode }) => (
            <h3 className="mt-5 text-[15px] font-bold text-foreground">{children}</h3>
          ),
          h3: ({ children }: { children?: ReactNode }) => (
            <h4 className="mt-4 text-sm font-semibold text-foreground">{children}</h4>
          ),
          h4: ({ children }: { children?: ReactNode }) => (
            <h5 className="mt-4 text-sm font-semibold text-foreground">{children}</h5>
          ),

          // Inline code stays LTR: device models, IP addresses and protocol
          // names must not be reordered by the bidi algorithm in Arabic text.
          code: ({ children }: { children?: ReactNode }) => (
            <code
              dir="ltr"
              className="rounded bg-secondary px-1.5 py-0.5 font-mono text-[0.85em] text-foreground"
            >
              {children}
            </code>
          ),
          // Fenced blocks. A block tagged ```formula or ```example is rendered
          // as a visually distinct callout rather than a code block: the course
          // review asked that equations, problems and worked examples be set
          // apart from prose instead of sitting inline as bold text where they
          // are easy to skim past.
          //
          // Equations stay dir="ltr" even inside Arabic: "V = √3 × 220" is a
          // mathematical expression, and bidi would otherwise move the operators
          // and the equals sign to the wrong side.
          pre: ({ children }: { children?: ReactNode }) => {
            const child = Array.isArray(children) ? children[0] : children;
            const cls: string =
              (child as { props?: { className?: string } })?.props?.className ?? "";
            const isFormula = /language-(formula|equation|math)/.test(cls);
            const isExample = /language-(example|worked)/.test(cls);

            if (isFormula || isExample) {
              // Each line gets its own dir="auto" so an Arabic step label
              // reads right-to-left while the calculation beside it stays
              // LTR. Forcing the whole block to dir="ltr" reversed every
              // Arabic label; letting it inherit rtl reversed the maths.
              const raw = String(
                (child as { props?: { children?: unknown } })?.props?.children ?? "",
              ).replace(/\n$/, "");

              return (
                <div
                  className={`mt-4 overflow-hidden rounded-lg border ${
                    isFormula
                      ? "border-s-4 border-s-primary bg-primary/5"
                      : "border-s-4 border-s-amber-500 bg-amber-500/5"
                  } border-border`}
                >
                  <div className="flex items-center gap-2 border-b border-border/60 px-3 py-1.5">
                    <span
                      className={`text-[11px] font-bold uppercase tracking-wide rtl:normal-case rtl:tracking-normal rtl:text-xs ${
                        isFormula ? "text-primary" : "text-amber-600"
                      }`}
                    >
                      {isFormula
                        ? t("Formula", "قانون")
                        : t("Worked example", "مثال محلول")}
                    </span>
                  </div>
                  <div className="overflow-x-auto px-3 py-2.5">
                    {raw.split("\n").map((ln, idx) => (
                      <div
                        key={idx}
                        dir="auto"
                        className="whitespace-pre-wrap text-start font-mono text-[13px] leading-relaxed text-foreground"
                      >
                        {ln || "\u00a0"}
                      </div>
                    ))}
                  </div>
                </div>
              );
            }

            return (
              <pre
                dir="ltr"
                className="mt-3 overflow-x-auto rounded-lg border border-border bg-secondary/50 p-3 text-start font-mono text-xs"
              >
                {children}
              </pre>
            );
          },

          blockquote: ({ children }: { children?: ReactNode }) => (
            <blockquote className="mt-3 border-s-4 border-primary/40 bg-secondary/30 ps-4 py-2 text-muted-foreground">
              {children}
            </blockquote>
          ),

          hr: () => <hr className="my-5 border-border" />,

          // Links are rendered as plain text: lesson material must not send
          // trainees off-platform, matching the existing no-external-links rule.
          a: ({ children }: { children?: ReactNode }) => (
            <span className="font-medium text-foreground">{children}</span>
          ),
        }}
      >
        {children}
      </ReactMarkdown>
    </div>
  );
}
