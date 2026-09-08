import { useCallback, useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";

export interface QuizOption {
  id: string;
  question_id: string;
  option_text: string;
  option_text_ar: string;
  position: number;
}

export interface QuizQuestion {
  id: string;
  quiz_id: string;
  question: string;
  question_ar: string;
  position: number;
  options: QuizOption[];
}

export interface QuizMeta {
  id: string;
  module_id: string;
  tier: "bronze" | "silver" | "gold";
  title: string;
  title_ar: string;
  pass_percent: number;
}

export interface QuizResult {
  attempt_id: string;
  score: number;
  total: number;
  percent: number;
  passed: boolean;
}

/** Loads a quiz's questions + options (answers hidden) for a given module + tier. */
export function useQuiz(moduleId: string | undefined, tier: "bronze" | "silver" | "gold") {
  const [quiz, setQuiz] = useState<QuizMeta | null>(null);
  const [questions, setQuestions] = useState<QuizQuestion[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let active = true;
    if (!moduleId) {
      setLoading(false);
      return;
    }

    async function load() {
      try {
        const { data: quizRow, error: quizErr } = await supabase
          .from("quizzes")
          .select("*")
          .eq("module_id", moduleId)
          .eq("tier", tier)
          .maybeSingle();
        if (quizErr) throw quizErr;
        if (!quizRow) throw new Error("Quiz not found");

        const { data: questionRows, error: qErr } = await supabase
          .from("quiz_questions")
          .select("*")
          .eq("quiz_id", quizRow.id)
          .order("position");
        if (qErr) throw qErr;

        const questionIds = (questionRows ?? []).map((q) => q.id);
        const { data: optionRows, error: oErr } = await supabase
          .from("quiz_options_public")
          .select("*")
          .in("question_id", questionIds.length ? questionIds : ["00000000-0000-0000-0000-000000000000"])
          .order("position");
        if (oErr) throw oErr;

        const optionsByQuestion = new Map<string, QuizOption[]>();
        for (const opt of optionRows ?? []) {
          const list = optionsByQuestion.get(opt.question_id) ?? [];
          list.push(opt);
          optionsByQuestion.set(opt.question_id, list);
        }

        const withOptions: QuizQuestion[] = (questionRows ?? []).map((q) => ({
          ...q,
          options: optionsByQuestion.get(q.id) ?? [],
        }));

        if (!active) return;
        setQuiz(quizRow);
        setQuestions(withOptions);
      } catch (e) {
        if (!active) return;
        setError(e instanceof Error ? e.message : "Failed to load quiz");
      } finally {
        if (active) setLoading(false);
      }
    }

    void load();
    return () => {
      active = false;
    };
  }, [moduleId, tier]);

  return { quiz, questions, loading, error };
}

/** Submits answers for grading via the server-side RPC (server computes the score). */
export function useSubmitQuiz() {
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const submit = useCallback(
    async (
      quizId: string,
      answers: { question_id: string; selected_option_id: string }[],
    ): Promise<QuizResult | null> => {
      setSubmitting(true);
      setError(null);
      try {
        const { data, error: rpcErr } = await supabase.rpc("submit_quiz_attempt", {
          _quiz_id: quizId,
          _answers: answers,
        });
        if (rpcErr) throw rpcErr;
        const row = Array.isArray(data) ? data[0] : data;
        return row as QuizResult;
      } catch (e) {
        setError(e instanceof Error ? e.message : "Failed to submit quiz");
        return null;
      } finally {
        setSubmitting(false);
      }
    },
    [],
  );

  return { submit, submitting, error };
}
