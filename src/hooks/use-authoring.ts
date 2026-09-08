import { useCallback, useState } from "react";
import { supabase } from "@/integrations/supabase/client";

export interface ModuleRow {
  id: string;
  slug: string;
  code: string;
  track_id: string;
  title: string;
  title_ar: string;
  summary: string;
  summary_ar: string;
  external_url: string | null;
  position: number;
  published: boolean;
}

export interface LessonRow {
  id: string;
  module_id: string;
  title: string;
  title_ar: string;
  content: string | null;
  content_ar: string | null;
  video_url: string | null;
  position: number;
}

export interface QuizRow {
  id: string;
  module_id: string;
  tier: "bronze" | "silver" | "gold";
  title: string;
  title_ar: string;
  pass_percent: number;
}

export interface QuizQuestionRow {
  id: string;
  quiz_id: string;
  question: string;
  question_ar: string;
  position: number;
}

export interface QuizOptionRow {
  id: string;
  question_id: string;
  option_text: string;
  option_text_ar: string;
  is_correct: boolean;
  position: number;
}

/** CRUD hook for staff (trainer/admin) content authoring against Supabase. */
export function useAuthoring() {
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const run = useCallback(async <T,>(fn: () => Promise<T>): Promise<T | null> => {
    setSaving(true);
    setError(null);
    try {
      return await fn();
    } catch (e) {
      setError(e instanceof Error ? e.message : "Something went wrong");
      return null;
    } finally {
      setSaving(false);
    }
  }, []);

  // Modules ---------------------------------------------------------------
  const createModule = useCallback(
    (mod: Omit<ModuleRow, "id">) =>
      run(async () => {
        const { data, error } = await supabase.from("modules").insert(mod).select().single();
        if (error) throw error;
        return data as ModuleRow;
      }),
    [run],
  );

  const updateModule = useCallback(
    (id: string, patch: Partial<Omit<ModuleRow, "id">>) =>
      run(async () => {
        const { data, error } = await supabase.from("modules").update(patch).eq("id", id).select().single();
        if (error) throw error;
        return data as ModuleRow;
      }),
    [run],
  );

  const deleteModule = useCallback(
    (id: string) =>
      run(async () => {
        const { error } = await supabase.from("modules").delete().eq("id", id);
        if (error) throw error;
        return true;
      }),
    [run],
  );

  const togglePublish = useCallback(
    (id: string, published: boolean) =>
      run(async () => {
        const { error } = await supabase.from("modules").update({ published }).eq("id", id);
        if (error) throw error;
        return true;
      }),
    [run],
  );

  // Lessons -----------------------------------------------------------------
  const createLesson = useCallback(
    (lesson: Omit<LessonRow, "id">) =>
      run(async () => {
        const { data, error } = await supabase.from("lessons").insert(lesson).select().single();
        if (error) throw error;
        return data as LessonRow;
      }),
    [run],
  );

  const updateLesson = useCallback(
    (id: string, patch: Partial<Omit<LessonRow, "id">>) =>
      run(async () => {
        const { data, error } = await supabase.from("lessons").update(patch).eq("id", id).select().single();
        if (error) throw error;
        return data as LessonRow;
      }),
    [run],
  );

  const deleteLesson = useCallback(
    (id: string) =>
      run(async () => {
        const { error } = await supabase.from("lessons").delete().eq("id", id);
        if (error) throw error;
        return true;
      }),
    [run],
  );

  // Quizzes / questions / options -------------------------------------------
  const upsertQuiz = useCallback(
    (quiz: Omit<QuizRow, "id"> & { id?: string }) =>
      run(async () => {
        const { data, error } = await supabase
          .from("quizzes")
          .upsert(quiz, { onConflict: "module_id,tier" })
          .select()
          .single();
        if (error) throw error;
        return data as QuizRow;
      }),
    [run],
  );

  const createQuestion = useCallback(
    (q: Omit<QuizQuestionRow, "id">) =>
      run(async () => {
        const { data, error } = await supabase.from("quiz_questions").insert(q).select().single();
        if (error) throw error;
        return data as QuizQuestionRow;
      }),
    [run],
  );

  const updateQuestion = useCallback(
    (id: string, patch: Partial<Omit<QuizQuestionRow, "id">>) =>
      run(async () => {
        const { data, error } = await supabase.from("quiz_questions").update(patch).eq("id", id).select().single();
        if (error) throw error;
        return data as QuizQuestionRow;
      }),
    [run],
  );

  const deleteQuestion = useCallback(
    (id: string) =>
      run(async () => {
        const { error } = await supabase.from("quiz_questions").delete().eq("id", id);
        if (error) throw error;
        return true;
      }),
    [run],
  );

  const createOption = useCallback(
    (o: Omit<QuizOptionRow, "id">) =>
      run(async () => {
        const { data, error } = await supabase.from("quiz_options").insert(o).select().single();
        if (error) throw error;
        return data as QuizOptionRow;
      }),
    [run],
  );

  const updateOption = useCallback(
    (id: string, patch: Partial<Omit<QuizOptionRow, "id">>) =>
      run(async () => {
        const { data, error } = await supabase.from("quiz_options").update(patch).eq("id", id).select().single();
        if (error) throw error;
        return data as QuizOptionRow;
      }),
    [run],
  );

  const deleteOption = useCallback(
    (id: string) =>
      run(async () => {
        const { error } = await supabase.from("quiz_options").delete().eq("id", id);
        if (error) throw error;
        return true;
      }),
    [run],
  );

  return {
    saving,
    error,
    createModule,
    updateModule,
    deleteModule,
    togglePublish,
    createLesson,
    updateLesson,
    deleteLesson,
    upsertQuiz,
    createQuestion,
    updateQuestion,
    deleteQuestion,
    createOption,
    updateOption,
    deleteOption,
  };
}

/** Fetch a single module with its lessons and quizzes (all tiers, with questions+options). */
export async function fetchModuleForAuthoring(moduleId: string) {
  const [{ data: mod }, { data: lessons }, { data: quizzes }] = await Promise.all([
    supabase.from("modules").select("*").eq("id", moduleId).single(),
    supabase.from("lessons").select("*").eq("module_id", moduleId).order("position"),
    supabase.from("quizzes").select("*").eq("module_id", moduleId).order("tier"),
  ]);

  const quizIds = (quizzes ?? []).map((q) => q.id);
  const { data: questions } = quizIds.length
    ? await supabase.from("quiz_questions").select("*").in("quiz_id", quizIds).order("position")
    : { data: [] as QuizQuestionRow[] };

  const questionIds = (questions ?? []).map((q) => q.id);
  const { data: options } = questionIds.length
    ? await supabase.from("quiz_options").select("*").in("question_id", questionIds).order("position")
    : { data: [] as QuizOptionRow[] };

  return {
    module: mod as ModuleRow | null,
    lessons: (lessons ?? []) as LessonRow[],
    quizzes: (quizzes ?? []) as QuizRow[],
    questions: (questions ?? []) as QuizQuestionRow[],
    options: (options ?? []) as QuizOptionRow[],
  };
}
