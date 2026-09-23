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

export function LessonContent({
  children,
  className = "",
}: {
  children: string;
  className?: string;
}) {
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

          // Lists start flush at the line, with the marker as the first thing
          // on the line — the reviewer asked for numbered points to begin at
          // the start of the line rather than sitting in from it.
          //
          // `list-inside` puts the marker in the content flow instead of
          // hanging it in the padding, so no indent is needed and nothing is
          // left stranded in the margin when the page flips to RTL.
          ul: ({ children }: { children?: ReactNode }) => (
            <ul className="mt-3 list-inside list-disc space-y-1.5 ps-0 text-muted-foreground marker:text-primary">
              {children}
            </ul>
          ),
          ol: ({ children }: { children?: ReactNode }) => (
            <ol className="mt-3 list-inside list-decimal space-y-1.5 ps-0 text-muted-foreground marker:font-semibold marker:text-primary">
              {children}
            </ol>
          ),
          li: ({ children }: { children?: ReactNode }) => (
            <li className="ps-0">{children}</li>
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
          pre: ({ children }: { children?: ReactNode }) => (
            <pre
              dir="ltr"
              className="mt-3 overflow-x-auto rounded-lg border border-border bg-secondary/50 p-3 text-start font-mono text-xs"
            >
              {children}
            </pre>
          ),

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
