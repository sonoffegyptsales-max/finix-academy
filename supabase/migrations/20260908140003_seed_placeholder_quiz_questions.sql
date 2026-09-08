-- 16. Seed: placeholder quiz questions (3 per quiz) generated from module/lesson titles.
-- Trainers should replace these with real assessment content via the Admin/Trainer panel.

-- Questions for module M01 (electrical-fundamentals), applied to all 3 tiers
DO $$
DECLARE
  _quiz_id uuid;
  _question_id uuid;
BEGIN
  FOR _quiz_id IN
    SELECT q.id FROM public.quizzes q
    JOIN public.modules mo ON mo.id = q.module_id
    WHERE mo.slug = 'electrical-fundamentals'
  LOOP
    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "Electrical Fundamentals for Automation Engineers" covers: Direct Current (DC): Properties, Advantages & Disadvantages?', 'أي درس في "أساسيات الكهرباء لمهندسي الأتمتة" يغطي: التيار المستمر DC: الخصائص والمزايا والعيوب؟', 1)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, 'Direct Current (DC): Properties, Advantages & Disadvantages', 'التيار المستمر DC: الخصائص والمزايا والعيوب', true, 1),
      (_question_id, 'Alternating Current (AC): Properties & Comparison with DC', 'التيار المتردد AC: الخصائص والمقارنة مع المستمر', false, 2),
      (_question_id, 'Ohm''s Law Wheel & Power Calculations', 'عجلة قانون أوم وحسابات القدرة', false, 3);

    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "Electrical Fundamentals for Automation Engineers" covers: Alternating Current (AC): Properties & Comparison with DC?', 'أي درس في "أساسيات الكهرباء لمهندسي الأتمتة" يغطي: التيار المتردد AC: الخصائص والمقارنة مع المستمر؟', 2)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, 'Alternating Current (AC): Properties & Comparison with DC', 'التيار المتردد AC: الخصائص والمقارنة مع المستمر', true, 1),
      (_question_id, 'Direct Current (DC): Properties, Advantages & Disadvantages', 'التيار المستمر DC: الخصائص والمزايا والعيوب', false, 2),
      (_question_id, 'Ohm''s Law Wheel & Power Calculations', 'عجلة قانون أوم وحسابات القدرة', false, 3);

    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "Electrical Fundamentals for Automation Engineers" covers: Ohm''s Law Wheel & Power Calculations?', 'أي درس في "أساسيات الكهرباء لمهندسي الأتمتة" يغطي: عجلة قانون أوم وحسابات القدرة؟', 3)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, 'Ohm''s Law Wheel & Power Calculations', 'عجلة قانون أوم وحسابات القدرة', true, 1),
      (_question_id, 'Direct Current (DC): Properties, Advantages & Disadvantages', 'التيار المستمر DC: الخصائص والمزايا والعيوب', false, 2),
      (_question_id, 'Alternating Current (AC): Properties & Comparison with DC', 'التيار المتردد AC: الخصائص والمقارنة مع المستمر', false, 3);

  END LOOP;
END $$;

-- Questions for module M02 (protection-devices-control-components), applied to all 3 tiers
DO $$
DECLARE
  _quiz_id uuid;
  _question_id uuid;
BEGIN
  FOR _quiz_id IN
    SELECT q.id FROM public.quizzes q
    JOIN public.modules mo ON mo.id = q.module_id
    WHERE mo.slug = 'protection-devices-control-components'
  LOOP
    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "Protection Devices & Control Components" covers: Circuit Breakers: MCB, MCCB, ACB & Selecting the Right One?', 'أي درس في "أجهزة الحماية ومكونات التحكم" يغطي: قواطع الدوائر: MCB وMCCB وACB وكيفية الاختيار الصحيح؟', 1)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, 'Circuit Breakers: MCB, MCCB, ACB & Selecting the Right One', 'قواطع الدوائر: MCB وMCCB وACB وكيفية الاختيار الصحيح', true, 1),
      (_question_id, 'Relay: Types, Operation & Applications in Smart Home', 'الريليه: الأنواع وطريقة التشغيل وتطبيقاته في المنزل الذكي', false, 2),
      (_question_id, 'Contactor, Selector Switch & Overload Relay', 'الكونتاكتور ومفتاح الاختيار وريليه الحمل الزائد', false, 3);

    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "Protection Devices & Control Components" covers: Relay: Types, Operation & Applications in Smart Home?', 'أي درس في "أجهزة الحماية ومكونات التحكم" يغطي: الريليه: الأنواع وطريقة التشغيل وتطبيقاته في المنزل الذكي؟', 2)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, 'Relay: Types, Operation & Applications in Smart Home', 'الريليه: الأنواع وطريقة التشغيل وتطبيقاته في المنزل الذكي', true, 1),
      (_question_id, 'Circuit Breakers: MCB, MCCB, ACB & Selecting the Right One', 'قواطع الدوائر: MCB وMCCB وACB وكيفية الاختيار الصحيح', false, 2),
      (_question_id, 'Contactor, Selector Switch & Overload Relay', 'الكونتاكتور ومفتاح الاختيار وريليه الحمل الزائد', false, 3);

    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "Protection Devices & Control Components" covers: Contactor, Selector Switch & Overload Relay?', 'أي درس في "أجهزة الحماية ومكونات التحكم" يغطي: الكونتاكتور ومفتاح الاختيار وريليه الحمل الزائد؟', 3)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, 'Contactor, Selector Switch & Overload Relay', 'الكونتاكتور ومفتاح الاختيار وريليه الحمل الزائد', true, 1),
      (_question_id, 'Circuit Breakers: MCB, MCCB, ACB & Selecting the Right One', 'قواطع الدوائر: MCB وMCCB وACB وكيفية الاختيار الصحيح', false, 2),
      (_question_id, 'Relay: Types, Operation & Applications in Smart Home', 'الريليه: الأنواع وطريقة التشغيل وتطبيقاته في المنزل الذكي', false, 3);

  END LOOP;
END $$;

-- Questions for module M03 (alpha-control-platform), applied to all 3 tiers
DO $$
DECLARE
  _quiz_id uuid;
  _question_id uuid;
BEGIN
  FOR _quiz_id IN
    SELECT q.id FROM public.quizzes q
    JOIN public.modules mo ON mo.id = q.module_id
    WHERE mo.slug = 'alpha-control-platform'
  LOOP
    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "Alpha Control Smart Automation Platform" covers: Alpha Control: Architecture & Core Board?', 'أي درس في "منصة ألفا كنترول للأتمتة الذكية" يغطي: ألفا كنترول: البنية واللوحة الأساسية؟', 1)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, 'Alpha Control: Architecture & Core Board', 'ألفا كنترول: البنية واللوحة الأساسية', true, 1),
      (_question_id, 'None of the M03 lessons', 'لا شيء من دروس M03', false, 2),
      (_question_id, 'None of the M03 lessons', 'لا شيء من دروس M03', false, 3);

  END LOOP;
END $$;

-- Questions for module M04 (network-fundamentals), applied to all 3 tiers
DO $$
DECLARE
  _quiz_id uuid;
  _question_id uuid;
BEGIN
  FOR _quiz_id IN
    SELECT q.id FROM public.quizzes q
    JOIN public.modules mo ON mo.id = q.module_id
    WHERE mo.slug = 'network-fundamentals'
  LOOP
    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "Network Fundamentals for Smart Home Technicians" covers: Network Types, Components & IP Addressing?', 'أي درس في "أساسيات الشبكات لفنيي المنازل الذكية" يغطي: أنواع الشبكات ومكوناتها وعنونة IP؟', 1)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, 'Network Types, Components & IP Addressing', 'أنواع الشبكات ومكوناتها وعنونة IP', true, 1),
      (_question_id, 'IP Classes A–E, DHCP & NAT Explained', 'شرح فئات IP من A إلى E وDHCP وNAT', false, 2),
      (_question_id, 'None of the M04 lessons', 'لا شيء من دروس M04', false, 3);

    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "Network Fundamentals for Smart Home Technicians" covers: IP Classes A–E, DHCP & NAT Explained?', 'أي درس في "أساسيات الشبكات لفنيي المنازل الذكية" يغطي: شرح فئات IP من A إلى E وDHCP وNAT؟', 2)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, 'IP Classes A–E, DHCP & NAT Explained', 'شرح فئات IP من A إلى E وDHCP وNAT', true, 1),
      (_question_id, 'Network Types, Components & IP Addressing', 'أنواع الشبكات ومكوناتها وعنونة IP', false, 2),
      (_question_id, 'None of the M04 lessons', 'لا شيء من دروس M04', false, 3);

  END LOOP;
END $$;

-- Questions for module M05 (smart-home-wireless-protocols), applied to all 3 tiers
DO $$
DECLARE
  _quiz_id uuid;
  _question_id uuid;
BEGIN
  FOR _quiz_id IN
    SELECT q.id FROM public.quizzes q
    JOIN public.modules mo ON mo.id = q.module_id
    WHERE mo.slug = 'smart-home-wireless-protocols'
  LOOP
    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "Smart Home Wireless Protocols" covers: Zigbee: Mesh Roles, Architecture & Sonoff Devices?', 'أي درس في "بروتوكولات اللاسلكي في المنزل الذكي" يغطي: Zigbee: أدوار الشبكة الشبكية والبنية وأجهزة SONOFF؟', 1)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, 'Zigbee: Mesh Roles, Architecture & Sonoff Devices', 'Zigbee: أدوار الشبكة الشبكية والبنية وأجهزة SONOFF', true, 1),
      (_question_id, 'Z-Wave & Thread: Two Reliable Alternatives', 'Z-Wave وThread: بديلان موثوقان', false, 2),
      (_question_id, 'Matter Standard, CSA & Smart Home Ecosystems', 'معيار Matter وتحالف CSA ومنظومات المنزل الذكي', false, 3);

    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "Smart Home Wireless Protocols" covers: Z-Wave & Thread: Two Reliable Alternatives?', 'أي درس في "بروتوكولات اللاسلكي في المنزل الذكي" يغطي: Z-Wave وThread: بديلان موثوقان؟', 2)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, 'Z-Wave & Thread: Two Reliable Alternatives', 'Z-Wave وThread: بديلان موثوقان', true, 1),
      (_question_id, 'Zigbee: Mesh Roles, Architecture & Sonoff Devices', 'Zigbee: أدوار الشبكة الشبكية والبنية وأجهزة SONOFF', false, 2),
      (_question_id, 'Matter Standard, CSA & Smart Home Ecosystems', 'معيار Matter وتحالف CSA ومنظومات المنزل الذكي', false, 3);

    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "Smart Home Wireless Protocols" covers: Matter Standard, CSA & Smart Home Ecosystems?', 'أي درس في "بروتوكولات اللاسلكي في المنزل الذكي" يغطي: معيار Matter وتحالف CSA ومنظومات المنزل الذكي؟', 3)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, 'Matter Standard, CSA & Smart Home Ecosystems', 'معيار Matter وتحالف CSA ومنظومات المنزل الذكي', true, 1),
      (_question_id, 'Zigbee: Mesh Roles, Architecture & Sonoff Devices', 'Zigbee: أدوار الشبكة الشبكية والبنية وأجهزة SONOFF', false, 2),
      (_question_id, 'Z-Wave & Thread: Two Reliable Alternatives', 'Z-Wave وThread: بديلان موثوقان', false, 3);

  END LOOP;
END $$;

-- Questions for module M06 (team-roles-competencies), applied to all 3 tiers
DO $$
DECLARE
  _quiz_id uuid;
  _question_id uuid;
BEGIN
  FOR _quiz_id IN
    SELECT q.id FROM public.quizzes q
    JOIN public.modules mo ON mo.id = q.module_id
    WHERE mo.slug = 'team-roles-competencies'
  LOOP
    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "Smart Home Team: Roles & Required Competencies" covers: The 5 Roles of a Professional Smart Home Team?', 'أي درس في "فريق المنزل الذكي: الأدوار والكفاءات المطلوبة" يغطي: الأدوار الخمسة لفريق منازل ذكية محترف؟', 1)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, 'The 5 Roles of a Professional Smart Home Team', 'الأدوار الخمسة لفريق منازل ذكية محترف', true, 1),
      (_question_id, 'None of the M06 lessons', 'لا شيء من دروس M06', false, 2),
      (_question_id, 'None of the M06 lessons', 'لا شيء من دروس M06', false, 3);

  END LOOP;
END $$;

-- Questions for module M07 (project-execution-after-sales), applied to all 3 tiers
DO $$
DECLARE
  _quiz_id uuid;
  _question_id uuid;
BEGIN
  FOR _quiz_id IN
    SELECT q.id FROM public.quizzes q
    JOIN public.modules mo ON mo.id = q.module_id
    WHERE mo.slug = 'project-execution-after-sales'
  LOOP
    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "Project Execution: Installation Phases & After-Sales" covers: The 6 Phases of a Smart Home Installation Project?', 'أي درس في "تنفيذ المشروع: مراحل التركيب وما بعد البيع" يغطي: المراحل الست لمشروع تركيب منزل ذكي؟', 1)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, 'The 6 Phases of a Smart Home Installation Project', 'المراحل الست لمشروع تركيب منزل ذكي', true, 1),
      (_question_id, 'None of the M07 lessons', 'لا شيء من دروس M07', false, 2),
      (_question_id, 'None of the M07 lessons', 'لا شيء من دروس M07', false, 3);

  END LOOP;
END $$;

-- Questions for module M08 (kpi-performance-evaluation), applied to all 3 tiers
DO $$
DECLARE
  _quiz_id uuid;
  _question_id uuid;
BEGIN
  FOR _quiz_id IN
    SELECT q.id FROM public.quizzes q
    JOIN public.modules mo ON mo.id = q.module_id
    WHERE mo.slug = 'kpi-performance-evaluation'
  LOOP
    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "KPI & Performance Evaluation for Smart Home Technicians" covers: 5 KPIs & The Technician Evaluation Form?', 'أي درس في "مؤشرات الأداء وتقييم فنيي المنازل الذكية" يغطي: مؤشرات الأداء الخمسة ونموذج تقييم الفني؟', 1)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, '5 KPIs & The Technician Evaluation Form', 'مؤشرات الأداء الخمسة ونموذج تقييم الفني', true, 1),
      (_question_id, 'None of the M08 lessons', 'لا شيء من دروس M08', false, 2),
      (_question_id, 'None of the M08 lessons', 'لا شيء من دروس M08', false, 3);

  END LOOP;
END $$;

-- Questions for module M09 (site-survey-methodology), applied to all 3 tiers
DO $$
DECLARE
  _quiz_id uuid;
  _question_id uuid;
BEGIN
  FOR _quiz_id IN
    SELECT q.id FROM public.quizzes q
    JOIN public.modules mo ON mo.id = q.module_id
    WHERE mo.slug = 'site-survey-methodology'
  LOOP
    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "Site Survey Methodology" covers: What is a Site Survey & Why It''s Non-Negotiable?', 'أي درس في "منهجية مسح الموقع" يغطي: ما هو مسح الموقع ولماذا هو خطوة لا غنى عنها؟', 1)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, 'What is a Site Survey & Why It''s Non-Negotiable', 'ما هو مسح الموقع ولماذا هو خطوة لا غنى عنها', true, 1),
      (_question_id, 'Client Consultation Questions for the Site Survey', 'أسئلة استشارة العميل أثناء مسح الموقع', false, 2),
      (_question_id, 'None of the M09 lessons', 'لا شيء من دروس M09', false, 3);

    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "Site Survey Methodology" covers: Client Consultation Questions for the Site Survey?', 'أي درس في "منهجية مسح الموقع" يغطي: أسئلة استشارة العميل أثناء مسح الموقع؟', 2)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, 'Client Consultation Questions for the Site Survey', 'أسئلة استشارة العميل أثناء مسح الموقع', true, 1),
      (_question_id, 'What is a Site Survey & Why It''s Non-Negotiable', 'ما هو مسح الموقع ولماذا هو خطوة لا غنى عنها', false, 2),
      (_question_id, 'None of the M09 lessons', 'لا شيء من دروس M09', false, 3);

  END LOOP;
END $$;

-- Questions for module M10 (bilingual-device-room-terminology), applied to all 3 tiers
DO $$
DECLARE
  _quiz_id uuid;
  _question_id uuid;
BEGIN
  FOR _quiz_id IN
    SELECT q.id FROM public.quizzes q
    JOIN public.modules mo ON mo.id = q.module_id
    WHERE mo.slug = 'bilingual-device-room-terminology'
  LOOP
    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "Bilingual Device & Room Terminology" covers: Room Names: Arabic–English Reference?', 'أي درس في "مصطلحات الأجهزة والغرف بالعربية والإنجليزية" يغطي: أسماء الغرف: مرجع عربي–إنجليزي؟', 1)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, 'Room Names: Arabic–English Reference', 'أسماء الغرف: مرجع عربي–إنجليزي', true, 1),
      (_question_id, 'Device Terminology: Lighting, Switches & Appliances', 'مصطلحات الأجهزة: الإضاءة والمفاتيح والأجهزة الكهربائية', false, 2),
      (_question_id, 'Tools Checklist for the Smart Home Technician', 'قائمة أدوات فني المنازل الذكية', false, 3);

    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "Bilingual Device & Room Terminology" covers: Device Terminology: Lighting, Switches & Appliances?', 'أي درس في "مصطلحات الأجهزة والغرف بالعربية والإنجليزية" يغطي: مصطلحات الأجهزة: الإضاءة والمفاتيح والأجهزة الكهربائية؟', 2)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, 'Device Terminology: Lighting, Switches & Appliances', 'مصطلحات الأجهزة: الإضاءة والمفاتيح والأجهزة الكهربائية', true, 1),
      (_question_id, 'Room Names: Arabic–English Reference', 'أسماء الغرف: مرجع عربي–إنجليزي', false, 2),
      (_question_id, 'Tools Checklist for the Smart Home Technician', 'قائمة أدوات فني المنازل الذكية', false, 3);

    INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
    VALUES (_quiz_id, 'Which lesson in "Bilingual Device & Room Terminology" covers: Tools Checklist for the Smart Home Technician?', 'أي درس في "مصطلحات الأجهزة والغرف بالعربية والإنجليزية" يغطي: قائمة أدوات فني المنازل الذكية؟', 3)
    RETURNING id INTO _question_id;

    INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position) VALUES
      (_question_id, 'Tools Checklist for the Smart Home Technician', 'قائمة أدوات فني المنازل الذكية', true, 1),
      (_question_id, 'Room Names: Arabic–English Reference', 'أسماء الغرف: مرجع عربي–إنجليزي', false, 2),
      (_question_id, 'Device Terminology: Lighting, Switches & Appliances', 'مصطلحات الأجهزة: الإضاءة والمفاتيح والأجهزة الكهربائية', false, 3);

  END LOOP;
END $$;
