// This file is generated from the LMS schema migrations. Regenerate via
// `supabase gen types typescript` once migrations are applied to the live project.
export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  __InternalSupabase: {
    PostgrestVersion: "14.15"
  }
  public: {
    Tables: {
      profiles: {
        Row: {
          created_at: string
          email: string
          full_name: string | null
          id: string
        }
        Insert: {
          created_at?: string
          email: string
          full_name?: string | null
          id: string
        }
        Update: {
          created_at?: string
          email?: string
          full_name?: string | null
          id?: string
        }
        Relationships: []
      }
      session_attempts: {
        Row: {
          id: string
          locked: boolean
          score: number | null
          session_id: number
          started_at: string
          submitted_at: string | null
          total: number | null
          user_id: string
        }
        Insert: {
          id?: string
          locked?: boolean
          score?: number | null
          session_id: number
          started_at?: string
          submitted_at?: string | null
          total?: number | null
          user_id: string
        }
        Update: {
          id?: string
          locked?: boolean
          score?: number | null
          session_id?: number
          started_at?: string
          submitted_at?: string | null
          total?: number | null
          user_id?: string
        }
        Relationships: []
      }
      session_videos: {
        Row: {
          created_at: string
          created_by: string | null
          description: string | null
          id: string
          position: number
          session_id: number
          source: string
          title: string
          url: string
        }
        Insert: {
          created_at?: string
          created_by?: string | null
          description?: string | null
          id?: string
          position?: number
          session_id: number
          source?: string
          title: string
          url: string
        }
        Update: {
          created_at?: string
          created_by?: string | null
          description?: string | null
          id?: string
          position?: number
          session_id?: number
          source?: string
          title?: string
          url?: string
        }
        Relationships: []
      }
      user_roles: {
        Row: {
          created_at: string
          id: string
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          role?: Database["public"]["Enums"]["app_role"]
          user_id?: string
        }
        Relationships: []
      }
      tracks: {
        Row: {
          id: string
          name: string
          name_ar: string
          tagline: string
          tagline_ar: string
          position: number
          created_at: string
        }
        Insert: {
          id: string
          name: string
          name_ar: string
          tagline: string
          tagline_ar: string
          position?: number
          created_at?: string
        }
        Update: {
          id?: string
          name?: string
          name_ar?: string
          tagline?: string
          tagline_ar?: string
          position?: number
          created_at?: string
        }
        Relationships: []
      }
      modules: {
        Row: {
          id: string
          slug: string
          code: string
          track_id: string
          title: string
          title_ar: string
          summary: string
          summary_ar: string
          external_url: string | null
          position: number
          published: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          slug: string
          code: string
          track_id: string
          title: string
          title_ar: string
          summary: string
          summary_ar: string
          external_url?: string | null
          position?: number
          published?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          slug?: string
          code?: string
          track_id?: string
          title?: string
          title_ar?: string
          summary?: string
          summary_ar?: string
          external_url?: string | null
          position?: number
          published?: boolean
          created_at?: string
          updated_at?: string
        }
        Relationships: []
      }
      lessons: {
        Row: {
          id: string
          module_id: string
          title: string
          title_ar: string
          content: string | null
          content_ar: string | null
          video_url: string | null
          position: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          module_id: string
          title: string
          title_ar: string
          content?: string | null
          content_ar?: string | null
          video_url?: string | null
          position?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          module_id?: string
          title?: string
          title_ar?: string
          content?: string | null
          content_ar?: string | null
          video_url?: string | null
          position?: number
          created_at?: string
          updated_at?: string
        }
        Relationships: []
      }
      quizzes: {
        Row: {
          id: string
          module_id: string
          tier: Database["public"]["Enums"]["quiz_tier"]
          title: string
          title_ar: string
          pass_percent: number
          created_at: string
        }
        Insert: {
          id?: string
          module_id: string
          tier: Database["public"]["Enums"]["quiz_tier"]
          title: string
          title_ar: string
          pass_percent?: number
          created_at?: string
        }
        Update: {
          id?: string
          module_id?: string
          tier?: Database["public"]["Enums"]["quiz_tier"]
          title?: string
          title_ar?: string
          pass_percent?: number
          created_at?: string
        }
        Relationships: []
      }
      quiz_questions: {
        Row: {
          id: string
          quiz_id: string
          question: string
          question_ar: string
          position: number
          created_at: string
        }
        Insert: {
          id?: string
          quiz_id: string
          question: string
          question_ar: string
          position?: number
          created_at?: string
        }
        Update: {
          id?: string
          quiz_id?: string
          question?: string
          question_ar?: string
          position?: number
          created_at?: string
        }
        Relationships: []
      }
      quiz_options: {
        Row: {
          id: string
          question_id: string
          option_text: string
          option_text_ar: string
          is_correct: boolean
          position: number
        }
        Insert: {
          id?: string
          question_id: string
          option_text: string
          option_text_ar: string
          is_correct?: boolean
          position?: number
        }
        Update: {
          id?: string
          question_id?: string
          option_text?: string
          option_text_ar?: string
          is_correct?: boolean
          position?: number
        }
        Relationships: []
      }
      enrollments: {
        Row: {
          id: string
          user_id: string
          module_id: string
          status: string
          completed_at: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          module_id: string
          status?: string
          completed_at?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          module_id?: string
          status?: string
          completed_at?: string | null
          created_at?: string
          updated_at?: string
        }
        Relationships: []
      }
      quiz_attempts: {
        Row: {
          id: string
          user_id: string
          quiz_id: string
          score: number | null
          total: number | null
          percent: number | null
          passed: boolean | null
          started_at: string
          submitted_at: string | null
        }
        Insert: {
          id?: string
          user_id: string
          quiz_id: string
          score?: number | null
          total?: number | null
          percent?: number | null
          passed?: boolean | null
          started_at?: string
          submitted_at?: string | null
        }
        Update: {
          id?: string
          user_id?: string
          quiz_id?: string
          score?: number | null
          total?: number | null
          percent?: number | null
          passed?: boolean | null
          started_at?: string
          submitted_at?: string | null
        }
        Relationships: []
      }
      quiz_answers: {
        Row: {
          id: string
          attempt_id: string
          question_id: string
          selected_option_id: string | null
          is_correct: boolean | null
        }
        Insert: {
          id?: string
          attempt_id: string
          question_id: string
          selected_option_id?: string | null
          is_correct?: boolean | null
        }
        Update: {
          id?: string
          attempt_id?: string
          question_id?: string
          selected_option_id?: string | null
          is_correct?: boolean | null
        }
        Relationships: []
      }
      certificates: {
        Row: {
          id: string
          user_id: string
          tier: Database["public"]["Enums"]["quiz_tier"]
          certificate_number: string
          issued_at: string
        }
        Insert: {
          id?: string
          user_id: string
          tier: Database["public"]["Enums"]["quiz_tier"]
          certificate_number: string
          issued_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          tier?: Database["public"]["Enums"]["quiz_tier"]
          certificate_number?: string
          issued_at?: string
        }
        Relationships: []
      }
      kpi_evaluations: {
        Row: {
          id: string
          evaluator_id: string
          trainee_name: string
          trainee_id: string | null
          project_name: string | null
          scores: Json
          technical_percent: number
          behavioral_percent: number
          final_percent: number
          band: string
          feedback: string | null
          created_at: string
        }
        Insert: {
          id?: string
          evaluator_id: string
          trainee_name: string
          trainee_id?: string | null
          project_name?: string | null
          scores?: Json
          technical_percent: number
          behavioral_percent: number
          final_percent: number
          band: string
          feedback?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          evaluator_id?: string
          trainee_name?: string
          trainee_id?: string | null
          project_name?: string | null
          scores?: Json
          technical_percent?: number
          behavioral_percent?: number
          final_percent?: number
          band?: string
          feedback?: string | null
          created_at?: string
        }
        Relationships: []
      }
      survey_reports: {
        Row: {
          id: string
          created_by: string
          project_name: string
          client_name: string | null
          stages: Json
          notes: string | null
          created_at: string
        }
        Insert: {
          id?: string
          created_by: string
          project_name: string
          client_name?: string | null
          stages?: Json
          notes?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          created_by?: string
          project_name?: string
          client_name?: string | null
          stages?: Json
          notes?: string | null
          created_at?: string
        }
        Relationships: []
      }
    }
    Views: {
      quiz_options_public: {
        Row: {
          id: string
          question_id: string
          option_text: string
          option_text_ar: string
          position: number
        }
        Relationships: []
      }
    }
    Functions: {
      has_role: {
        Args: {
          _role: Database["public"]["Enums"]["app_role"]
          _user_id: string
        }
        Returns: boolean
      }
      submit_quiz_attempt: {
        Args: {
          _quiz_id: string
          _answers: Json
        }
        Returns: {
          attempt_id: string
          score: number
          total: number
          percent: number
          passed: boolean
        }[]
      }
    }
    Enums: {
      app_role: "admin" | "trainee" | "trainer"
      quiz_tier: "bronze" | "silver" | "gold"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][CompositeTypeName]
    : never

export const Constants = {
  public: {
    Enums: {
      app_role: ["admin", "trainee", "trainer"],
      quiz_tier: ["bronze", "silver", "gold"],
    },
  },
} as const
