-- Finix Academy: full LMS schema — tracks, modules, lessons, quizzes, attempts,
-- certificates, enrollments, KPI evaluations, survey reports, trainer role.
-- Extends the existing profiles/user_roles/session_attempts/session_videos schema.

-- 2. Tracks
CREATE TABLE public.tracks (
  id text PRIMARY KEY,
  name text NOT NULL,
  name_ar text NOT NULL,
  tagline text NOT NULL,
  tagline_ar text NOT NULL,
  position integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.tracks TO authenticated, anon;
GRANT ALL ON public.tracks TO service_role;
ALTER TABLE public.tracks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "tracks_select_all" ON public.tracks
  FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "tracks_staff_write" ON public.tracks
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'))
  WITH CHECK (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'));

-- 3. Modules (courses)
CREATE TABLE public.modules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL UNIQUE,
  code text NOT NULL,
  track_id text NOT NULL REFERENCES public.tracks(id) ON DELETE CASCADE,
  title text NOT NULL,
  title_ar text NOT NULL,
  summary text NOT NULL,
  summary_ar text NOT NULL,
  external_url text,
  position integer NOT NULL DEFAULT 0,
  published boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.modules TO authenticated, anon;
GRANT ALL ON public.modules TO service_role;
ALTER TABLE public.modules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "modules_select_published" ON public.modules
  FOR SELECT TO authenticated, anon
  USING (published = true OR public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'));

CREATE POLICY "modules_staff_write" ON public.modules
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'))
  WITH CHECK (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'));

CREATE INDEX modules_track_idx ON public.modules (track_id, position);

-- 4. Lessons
CREATE TABLE public.lessons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id uuid NOT NULL REFERENCES public.modules(id) ON DELETE CASCADE,
  title text NOT NULL,
  title_ar text NOT NULL,
  content text,
  content_ar text,
  video_url text,
  position integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.lessons TO authenticated, anon;
GRANT ALL ON public.lessons TO service_role;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;

CREATE POLICY "lessons_select_all" ON public.lessons
  FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "lessons_staff_write" ON public.lessons
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'))
  WITH CHECK (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'));

CREATE INDEX lessons_module_idx ON public.lessons (module_id, position);

-- 5. Quiz tier enum + quizzes (one per module per tier)
CREATE TYPE public.quiz_tier AS ENUM ('bronze', 'silver', 'gold');

CREATE TABLE public.quizzes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id uuid NOT NULL REFERENCES public.modules(id) ON DELETE CASCADE,
  tier public.quiz_tier NOT NULL,
  title text NOT NULL,
  title_ar text NOT NULL,
  pass_percent integer NOT NULL DEFAULT 80,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (module_id, tier)
);
GRANT SELECT ON public.quizzes TO authenticated;
GRANT ALL ON public.quizzes TO service_role;
ALTER TABLE public.quizzes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "quizzes_select_authenticated" ON public.quizzes
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "quizzes_staff_write" ON public.quizzes
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'))
  WITH CHECK (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'));

-- 6. Quiz questions & options
CREATE TABLE public.quiz_questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id uuid NOT NULL REFERENCES public.quizzes(id) ON DELETE CASCADE,
  question text NOT NULL,
  question_ar text NOT NULL,
  position integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.quiz_questions TO authenticated;
GRANT ALL ON public.quiz_questions TO service_role;
ALTER TABLE public.quiz_questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "quiz_questions_select_authenticated" ON public.quiz_questions
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "quiz_questions_staff_write" ON public.quiz_questions
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'))
  WITH CHECK (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'));

CREATE TABLE public.quiz_options (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id uuid NOT NULL REFERENCES public.quiz_questions(id) ON DELETE CASCADE,
  option_text text NOT NULL,
  option_text_ar text NOT NULL,
  is_correct boolean NOT NULL DEFAULT false,
  position integer NOT NULL DEFAULT 0
);
-- No direct SELECT grant for authenticated on is_correct exposure — use RPC/server fn
-- for grading; trainees read questions/options via a view that hides is_correct.
GRANT ALL ON public.quiz_options TO service_role;
ALTER TABLE public.quiz_options ENABLE ROW LEVEL SECURITY;

CREATE POLICY "quiz_options_staff_all" ON public.quiz_options
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'))
  WITH CHECK (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'));

-- Trainee-safe view: exposes options WITHOUT is_correct.
CREATE VIEW public.quiz_options_public AS
  SELECT id, question_id, option_text, option_text_ar, position FROM public.quiz_options;
GRANT SELECT ON public.quiz_options_public TO authenticated;

-- 7. Enrollments (per-user per-module progress)
CREATE TABLE public.enrollments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  module_id uuid NOT NULL REFERENCES public.modules(id) ON DELETE CASCADE,
  status text NOT NULL DEFAULT 'in_progress' CHECK (status IN ('not_started','in_progress','completed')),
  completed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, module_id)
);
GRANT SELECT, INSERT, UPDATE ON public.enrollments TO authenticated;
GRANT ALL ON public.enrollments TO service_role;
ALTER TABLE public.enrollments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "enrollments_select" ON public.enrollments
  FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'));

CREATE POLICY "enrollments_insert_own" ON public.enrollments
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY "enrollments_update_own" ON public.enrollments
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid() OR public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'))
  WITH CHECK (user_id = auth.uid() OR public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'));

-- 8. Quiz attempts & answers (grading happens server-side via RPC)
CREATE TABLE public.quiz_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  quiz_id uuid NOT NULL REFERENCES public.quizzes(id) ON DELETE CASCADE,
  score integer,
  total integer,
  percent integer,
  passed boolean,
  started_at timestamptz NOT NULL DEFAULT now(),
  submitted_at timestamptz
);
GRANT SELECT, INSERT ON public.quiz_attempts TO authenticated;
GRANT ALL ON public.quiz_attempts TO service_role;
ALTER TABLE public.quiz_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "quiz_attempts_select" ON public.quiz_attempts
  FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'));

CREATE POLICY "quiz_attempts_insert_own" ON public.quiz_attempts
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE TABLE public.quiz_answers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id uuid NOT NULL REFERENCES public.quiz_attempts(id) ON DELETE CASCADE,
  question_id uuid NOT NULL REFERENCES public.quiz_questions(id) ON DELETE CASCADE,
  selected_option_id uuid REFERENCES public.quiz_options(id) ON DELETE SET NULL,
  is_correct boolean
);
GRANT ALL ON public.quiz_answers TO service_role;
ALTER TABLE public.quiz_answers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "quiz_answers_select_own" ON public.quiz_answers
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.quiz_attempts a
      WHERE a.id = attempt_id
        AND (a.user_id = auth.uid() OR public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'))
    )
  );

-- 9. Certificates
CREATE TABLE public.certificates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tier public.quiz_tier NOT NULL,
  certificate_number text NOT NULL UNIQUE,
  issued_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, tier)
);
GRANT SELECT ON public.certificates TO authenticated;
GRANT ALL ON public.certificates TO service_role;
ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "certificates_select" ON public.certificates
  FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'));

CREATE POLICY "certificates_staff_write" ON public.certificates
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'))
  WITH CHECK (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'));

-- 10. KPI evaluations (server-backed, replaces localStorage)
CREATE TABLE public.kpi_evaluations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  evaluator_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  trainee_name text NOT NULL,
  trainee_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  project_name text,
  scores jsonb NOT NULL DEFAULT '{}'::jsonb,
  technical_percent integer NOT NULL,
  behavioral_percent integer NOT NULL,
  final_percent integer NOT NULL,
  band text NOT NULL,
  feedback text,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT ON public.kpi_evaluations TO authenticated;
GRANT ALL ON public.kpi_evaluations TO service_role;
ALTER TABLE public.kpi_evaluations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "kpi_evaluations_select" ON public.kpi_evaluations
  FOR SELECT TO authenticated
  USING (evaluator_id = auth.uid() OR public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'));

CREATE POLICY "kpi_evaluations_insert_staff" ON public.kpi_evaluations
  FOR INSERT TO authenticated
  WITH CHECK (evaluator_id = auth.uid() AND (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer')));

CREATE POLICY "kpi_evaluations_delete_own" ON public.kpi_evaluations
  FOR DELETE TO authenticated
  USING (evaluator_id = auth.uid() OR public.has_role(auth.uid(), 'admin'));

-- 11. Site survey reports (server-backed, replaces localStorage)
CREATE TABLE public.survey_reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_by uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  project_name text NOT NULL,
  client_name text,
  stages jsonb NOT NULL DEFAULT '{}'::jsonb,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT ON public.survey_reports TO authenticated;
GRANT ALL ON public.survey_reports TO service_role;
ALTER TABLE public.survey_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "survey_reports_select" ON public.survey_reports
  FOR SELECT TO authenticated
  USING (created_by = auth.uid() OR public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'));

CREATE POLICY "survey_reports_insert_own" ON public.survey_reports
  FOR INSERT TO authenticated WITH CHECK (created_by = auth.uid());

CREATE POLICY "survey_reports_delete_own" ON public.survey_reports
  FOR DELETE TO authenticated
  USING (created_by = auth.uid() OR public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'trainer'));

-- 12. Seed: tracks
INSERT INTO public.tracks (id, name, name_ar, tagline, tagline_ar, position) VALUES ('hardware-foundations', 'Electrical & Automation Hardware Foundations', 'أساسيات الكهرباء وعتاد الأتمتة', 'DC/AC theory, Ohm''s Law, three-phase power, protection devices, relays, contactors, and the Alpha Control platform.', 'نظرية التيار المستمر والمتردد وقانون أوم والقدرة ثلاثية الطور وأجهزة الحماية والريليهات والكونتاكتورات ومنصة ألفا كنترول.', 1);
INSERT INTO public.tracks (id, name, name_ar, tagline, tagline_ar, position) VALUES ('networking-protocols', 'Networking & Smart Home Protocols', 'الشبكات وبروتوكولات المنزل الذكي', 'IP addressing, DHCP, NAT, Zigbee, Z-Wave, Thread, Matter, and smart home ecosystems.', 'عنونة IP وDHCP وNAT وZigbee وZ-Wave وThread وMatter ومنظومات المنزل الذكي.', 2);
INSERT INTO public.tracks (id, name, name_ar, tagline, tagline_ar, position) VALUES ('team-project-management', 'Smart Home Team & Project Management', 'فريق المنزل الذكي وإدارة المشاريع', 'Team roles and competencies, project phases, after-sales support, KPIs, and performance evaluation for smart home teams.', 'أدوار الفريق وكفاءاته ومراحل المشروع ودعم ما بعد البيع ومؤشرات الأداء وتقييم فرق المنازل الذكية.', 3);
INSERT INTO public.tracks (id, name, name_ar, tagline, tagline_ar, position) VALUES ('survey-terminology-tools', 'Site Survey, Device Terminology & Field Tools', 'مسح الموقع ومصطلحات الأجهزة والأدوات الميدانية', 'Professional site survey methodology, bilingual room and device terminology, tools checklist, and common field problems.', 'منهجية مسح الموقع الاحترافية ومصطلحات الغرف والأجهزة بالعربية والإنجليزية وقائمة الأدوات ومشكلات الميدان الشائعة.', 4);

-- 13. Seed: modules + lessons
INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES ('electrical-fundamentals', 'M01', 'hardware-foundations', 'Electrical Fundamentals for Automation Engineers', 'أساسيات الكهرباء لمهندسي الأتمتة', 'DC/AC characteristics, Ohm''s Law wheel, three-phase power, Star/Delta motor connections, cable sizing, and power supply types.', 'خصائص التيار المستمر والمتردد وعجلة قانون أوم والقدرة ثلاثية الطور وتوصيلات المحركات نجمة/دلتا وتحديد مقاس الكابلات وأنواع مزودات التغذية.', 'https://smartacademy.onhercules.app/en/courses/jn74pvjmdnpnydn1zqfhsb2nms8d3g4x', 1);
INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES ('protection-devices-control-components', 'M02', 'hardware-foundations', 'Protection Devices & Control Components', 'أجهزة الحماية ومكونات التحكم', 'Circuit breakers (MCB/MCCB/ACB), relay types, contactors, selector switches, and overload relays for industrial and smart home panels.', 'قواطع الدوائر (MCB/MCCB/ACB) وأنواع الريليهات والكونتاكتورات ومفاتيح الاختيار وريليهات الحمل الزائد للوحات الصناعية والمنازل الذكية.', 'https://smartacademy.onhercules.app/en/courses/jn7fekepqa4nppv9q1pz4y7zdn8d2yy8', 2);
INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES ('alpha-control-platform', 'M03', 'hardware-foundations', 'Alpha Control Smart Automation Platform', 'منصة ألفا كنترول للأتمتة الذكية', 'Architecture, hardware modules, wiring, commissioning and cloud integration of the Alpha Control system.', 'بنية نظام ألفا كنترول ووحداته المادية وتمديداته والتشغيل والدمج السحابي.', 'https://smartacademy.onhercules.app/en/courses/jn7edk15e2c0es3v3nm5wtx6e98d2by4', 3);
INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES ('network-fundamentals', 'M04', 'networking-protocols', 'Network Fundamentals for Smart Home Technicians', 'أساسيات الشبكات لفنيي المنازل الذكية', 'Network types, IP addressing, IP classes A–E, DHCP, NAT, and Wi-Fi fundamentals.', 'أنواع الشبكات وعنونة IP وفئات العناوين من A إلى E وDHCP وNAT وأساسيات الواي فاي.', 'https://smartacademy.onhercules.app/en/courses/jn73mhqkt4a76dctt5gpxsgadx8d37ed', 4);
INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES ('smart-home-wireless-protocols', 'M05', 'networking-protocols', 'Smart Home Wireless Protocols', 'بروتوكولات اللاسلكي في المنزل الذكي', 'Zigbee mesh network roles, Z-Wave, Thread, Matter/CSA standard — comparison and use cases.', 'أدوار شبكة Zigbee الشبكية وZ-Wave وThread ومعيار Matter/CSA — المقارنة وحالات الاستخدام.', 'https://smartacademy.onhercules.app/en/courses/jn73eszctb596rw1pbgbke2dex8d2t4b', 5);
INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES ('team-roles-competencies', 'M06', 'team-project-management', 'Smart Home Team: Roles & Required Competencies', 'فريق المنزل الذكي: الأدوار والكفاءات المطلوبة', 'The 5 essential roles in a professional smart home team — skills, responsibilities, and how they collaborate.', 'الأدوار الخمسة الأساسية في فريق منازل ذكية محترف — المهارات والمسؤوليات وطريقة التعاون بينها.', 'https://smartacademy.onhercules.app/en/courses/jn71px6y6wnz5wa27k5phf99hd8d3p3x', 6);
INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES ('project-execution-after-sales', 'M07', 'team-project-management', 'Project Execution: Installation Phases & After-Sales', 'تنفيذ المشروع: مراحل التركيب وما بعد البيع', 'Six phases from site survey to final handover, plus a professional after-sales support program.', 'المراحل الست من مسح الموقع حتى التسليم النهائي، إضافة إلى برنامج احترافي لدعم ما بعد البيع.', 'https://smartacademy.onhercules.app/en/courses/jn7awefebx2xcxxp3e9xb4k4qx8d3e13', 7);
INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES ('kpi-performance-evaluation', 'M08', 'team-project-management', 'KPI & Performance Evaluation for Smart Home Technicians', 'مؤشرات الأداء وتقييم فنيي المنازل الذكية', '5 key performance indicators for smart home technicians, personal competency assessment, and the official monthly evaluation form.', 'مؤشرات الأداء الخمسة لفنيي المنازل الذكية وتقييم الكفاءة الشخصية ونموذج التقييم الشهري الرسمي.', 'https://smartacademy.onhercules.app/en/courses/jn79ytg7wbsyybh33r4svd76h18d23tw', 8);
INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES ('site-survey-methodology', 'M09', 'survey-terminology-tools', 'Site Survey Methodology', 'منهجية مسح الموقع', 'The 5 phases of a professional smart home site survey — from infrastructure audit to documentation.', 'المراحل الخمسة لمسح موقع منزل ذكي باحترافية — من تدقيق البنية التحتية حتى التوثيق.', 'https://smartacademy.onhercules.app/en/courses/jn7bczsf9qr4qcd24zh3rchbs18d3ba6', 9);
INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES ('bilingual-device-room-terminology', 'M10', 'survey-terminology-tools', 'Bilingual Device & Room Terminology', 'مصطلحات الأجهزة والغرف بالعربية والإنجليزية', 'Complete bilingual (Arabic/English) reference for room names, lighting fixtures, switches, appliances, and smart home components.', 'مرجع كامل ثنائي اللغة (عربي/إنجليزي) لأسماء الغرف ووحدات الإضاءة والمفاتيح والأجهزة ومكونات المنزل الذكي.', 'https://smartacademy.onhercules.app/en/courses/jn7935c2283t05h73rn4bmjyr18d27yz', 10);

-- Lessons, inserted via module slug lookup
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'Direct Current (DC): Properties, Advantages & Disadvantages', 'التيار المستمر DC: الخصائص والمزايا والعيوب', 1 FROM public.modules WHERE slug = 'electrical-fundamentals';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'Alternating Current (AC): Properties & Comparison with DC', 'التيار المتردد AC: الخصائص والمقارنة مع المستمر', 2 FROM public.modules WHERE slug = 'electrical-fundamentals';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'Ohm''s Law Wheel & Power Calculations', 'عجلة قانون أوم وحسابات القدرة', 3 FROM public.modules WHERE slug = 'electrical-fundamentals';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'Three-Phase Power & Star/Delta Motor Connections', 'القدرة ثلاثية الطور وتوصيلات المحركات نجمة/دلتا', 4 FROM public.modules WHERE slug = 'electrical-fundamentals';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'Power Supplies: Adapter vs Power Supply vs Charger', 'مصادر التغذية: المحول مقابل مزود الطاقة مقابل الشاحن', 5 FROM public.modules WHERE slug = 'electrical-fundamentals';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'Circuit Breakers: MCB, MCCB, ACB & Selecting the Right One', 'قواطع الدوائر: MCB وMCCB وACB وكيفية الاختيار الصحيح', 1 FROM public.modules WHERE slug = 'protection-devices-control-components';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'Relay: Types, Operation & Applications in Smart Home', 'الريليه: الأنواع وطريقة التشغيل وتطبيقاته في المنزل الذكي', 2 FROM public.modules WHERE slug = 'protection-devices-control-components';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'Contactor, Selector Switch & Overload Relay', 'الكونتاكتور ومفتاح الاختيار وريليه الحمل الزائد', 3 FROM public.modules WHERE slug = 'protection-devices-control-components';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'Electrical Load Types & Safety', 'أنواع الأحمال الكهربائية والسلامة', 4 FROM public.modules WHERE slug = 'protection-devices-control-components';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'Alpha Control: Architecture & Core Board', 'ألفا كنترول: البنية واللوحة الأساسية', 1 FROM public.modules WHERE slug = 'alpha-control-platform';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'Network Types, Components & IP Addressing', 'أنواع الشبكات ومكوناتها وعنونة IP', 1 FROM public.modules WHERE slug = 'network-fundamentals';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'IP Classes A–E, DHCP & NAT Explained', 'شرح فئات IP من A إلى E وDHCP وNAT', 2 FROM public.modules WHERE slug = 'network-fundamentals';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'Zigbee: Mesh Roles, Architecture & Sonoff Devices', 'Zigbee: أدوار الشبكة الشبكية والبنية وأجهزة SONOFF', 1 FROM public.modules WHERE slug = 'smart-home-wireless-protocols';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'Z-Wave & Thread: Two Reliable Alternatives', 'Z-Wave وThread: بديلان موثوقان', 2 FROM public.modules WHERE slug = 'smart-home-wireless-protocols';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'Matter Standard, CSA & Smart Home Ecosystems', 'معيار Matter وتحالف CSA ومنظومات المنزل الذكي', 3 FROM public.modules WHERE slug = 'smart-home-wireless-protocols';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'Protocol Comparison: Wi-Fi, Zigbee, Z-Wave & Thread', 'مقارنة البروتوكولات: Wi-Fi وZigbee وZ-Wave وThread', 4 FROM public.modules WHERE slug = 'smart-home-wireless-protocols';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'The 5 Roles of a Professional Smart Home Team', 'الأدوار الخمسة لفريق منازل ذكية محترف', 1 FROM public.modules WHERE slug = 'team-roles-competencies';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'The 6 Phases of a Smart Home Installation Project', 'المراحل الست لمشروع تركيب منزل ذكي', 1 FROM public.modules WHERE slug = 'project-execution-after-sales';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, '5 KPIs & The Technician Evaluation Form', 'مؤشرات الأداء الخمسة ونموذج تقييم الفني', 1 FROM public.modules WHERE slug = 'kpi-performance-evaluation';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'What is a Site Survey & Why It''s Non-Negotiable', 'ما هو مسح الموقع ولماذا هو خطوة لا غنى عنها', 1 FROM public.modules WHERE slug = 'site-survey-methodology';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'Client Consultation Questions for the Site Survey', 'أسئلة استشارة العميل أثناء مسح الموقع', 2 FROM public.modules WHERE slug = 'site-survey-methodology';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'Room Names: Arabic–English Reference', 'أسماء الغرف: مرجع عربي–إنجليزي', 1 FROM public.modules WHERE slug = 'bilingual-device-room-terminology';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'Device Terminology: Lighting, Switches & Appliances', 'مصطلحات الأجهزة: الإضاءة والمفاتيح والأجهزة الكهربائية', 2 FROM public.modules WHERE slug = 'bilingual-device-room-terminology';
INSERT INTO public.lessons (module_id, title, title_ar, position) SELECT id, 'Tools Checklist for the Smart Home Technician', 'قائمة أدوات فني المنازل الذكية', 3 FROM public.modules WHERE slug = 'bilingual-device-room-terminology';

-- 14. Seed: placeholder quizzes (bronze/silver/gold) per module
-- Generated from module summaries; trainers should replace with real question banks.
INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, tier, 
       m.title || ' — ' || initcap(tier::text) || ' Quiz',
       m.title_ar || ' — اختبار ' || (CASE tier WHEN 'bronze' THEN 'برونزي' WHEN 'silver' THEN 'فضي' ELSE 'ذهبي' END),
       80
FROM public.modules m
CROSS JOIN (SELECT unnest(enum_range(NULL::public.quiz_tier)) AS tier) tiers;


-- 15. Grading RPC: submit a quiz attempt with answers, compute score server-side,
-- persist quiz_attempts + quiz_answers, and auto-issue a certificate if all modules
-- in the matching tier are now passed for that user.
CREATE OR REPLACE FUNCTION public.submit_quiz_attempt(
  _quiz_id uuid,
  _answers jsonb -- [{"question_id": "...", "selected_option_id": "..."}]
)
RETURNS TABLE (attempt_id uuid, score integer, total integer, percent integer, passed boolean)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _user_id uuid := auth.uid();
  _pass_percent integer;
  _tier public.quiz_tier;
  _module_id uuid;
  _attempt_id uuid;
  _total integer := 0;
  _correct integer := 0;
  _answer jsonb;
  _is_correct boolean;
BEGIN
  IF _user_id IS NULL THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  SELECT pass_percent, tier, module_id INTO _pass_percent, _tier, _module_id
  FROM public.quizzes WHERE id = _quiz_id;

  IF _pass_percent IS NULL THEN
    RAISE EXCEPTION 'Quiz not found';
  END IF;

  INSERT INTO public.quiz_attempts (user_id, quiz_id, started_at)
  VALUES (_user_id, _quiz_id, now())
  RETURNING id INTO _attempt_id;

  FOR _answer IN SELECT * FROM jsonb_array_elements(_answers)
  LOOP
    _total := _total + 1;
    SELECT o.is_correct INTO _is_correct
    FROM public.quiz_options o
    WHERE o.id = (_answer->>'selected_option_id')::uuid;

    _is_correct := COALESCE(_is_correct, false);
    IF _is_correct THEN
      _correct := _correct + 1;
    END IF;

    INSERT INTO public.quiz_answers (attempt_id, question_id, selected_option_id, is_correct)
    VALUES (
      _attempt_id,
      (_answer->>'question_id')::uuid,
      (_answer->>'selected_option_id')::uuid,
      _is_correct
    );
  END LOOP;

  UPDATE public.quiz_attempts
  SET score = _correct,
      total = _total,
      percent = CASE WHEN _total > 0 THEN round((_correct::numeric / _total) * 100) ELSE 0 END,
      passed = CASE WHEN _total > 0 THEN (round((_correct::numeric / _total) * 100) >= _pass_percent) ELSE false END,
      submitted_at = now()
  WHERE id = _attempt_id;

  -- Mark enrollment complete on a pass
  IF (SELECT passed FROM public.quiz_attempts WHERE id = _attempt_id) THEN
    INSERT INTO public.enrollments (user_id, module_id, status, completed_at)
    VALUES (_user_id, _module_id, 'completed', now())
    ON CONFLICT (user_id, module_id)
    DO UPDATE SET status = 'completed', completed_at = now(), updated_at = now();

    -- Auto-issue certificate if the user has passed this tier's quiz in every published module
    IF NOT EXISTS (
      SELECT 1 FROM public.modules m
      WHERE m.published = true
        AND NOT EXISTS (
          SELECT 1
          FROM public.quiz_attempts qa
          JOIN public.quizzes q ON q.id = qa.quiz_id
          WHERE qa.user_id = _user_id
            AND q.module_id = m.id
            AND q.tier = _tier
            AND qa.passed = true
        )
    ) THEN
      INSERT INTO public.certificates (user_id, tier, certificate_number)
      VALUES (
        _user_id,
        _tier,
        'FIN-' || upper(_tier::text) || '-' || substr(_user_id::text, 1, 8) || '-' || to_char(now(), 'YYYYMMDD')
      )
      ON CONFLICT (user_id, tier) DO NOTHING;
    END IF;
  END IF;

  RETURN QUERY
  SELECT _attempt_id, _correct, _total,
         CASE WHEN _total > 0 THEN round((_correct::numeric / _total) * 100)::integer ELSE 0 END,
         CASE WHEN _total > 0 THEN (round((_correct::numeric / _total) * 100) >= _pass_percent) ELSE false END;
END;
$$;

REVOKE ALL ON FUNCTION public.submit_quiz_attempt(uuid, jsonb) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.submit_quiz_attempt(uuid, jsonb) TO authenticated;
