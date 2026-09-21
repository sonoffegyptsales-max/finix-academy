-- Module I01: Contactors & Control Logic
-- ORIGINAL CONTENT written for Finix.

INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES (
  'finix-contactors-control-logic', 'I01', 'finix-industrial-control',
  'Contactors and Control Logic',
  'الكونتاكتورات ومنطق التحكم',
  'How a contactor is built and why the shading coil matters, the hold-in latch with stop priority, and how to wire interlocking, reversing and separate power/control circuits.',
  'كيف يُبنى الكونتاكتور ولماذا مهم لفافة التظليل، و QE hold-in مع أولوية الإيقاف، وكيفية تمديد التداخل والت Reversing ودوائر الطاقة والتحكم المنفصلة.',
  NULL, 1
);
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
VALUES
(
  'finix-contactors-control-logic',
  'Inside the Contactor: Coil, Contacts and the Shading Coil',
  'داخل الكونتاكتور: الـ coil والوصلات ولفافة التظليل',
  'A contactor is an electromagnet that closes heavy contacts with a light coil current. The coil (A1–A2) pulls the moving armature; fixed and moving contacts then carry the load. Three normally-open main poles carry the motor power; normally-open and normally-closed auxiliary contacts carry the control circuit — and that separation between power and control is the whole point of industrial control panels.',
  ' الكونتاكتور هو مغناطيس كهربائي يغلق وصلات ثقيلة بتيار خفيف للـ coil. الـ coil (A1–A2) يسحب الذراع المتحرك؛ والوصلات الثابتة والمتحركة تحمل الحمل بعدها. ثلاثة أقطاب رئيسيةnormally-open تحمل طاقة المحرك؛ والوصلات المساعدةnormally-open وnormally-closed تحمل دائرة التحكم — وهذا الفصل بين الطاقة والتحكم هو كل شيء في لوحات التحكم الصناعية.',
  1
),
(
  'finix-contactors-control-logic',
  'Why the Shading Coil Matters: Diagnosing the Buzz',
  'لماذا مهمة لفافة التظليل: تشخيص الهز}{
  'When the coil is AC, the magnetic force passes through zero twice per cycle. Without the shading ring (the small copper band on each AC pole face) the armature would chatter at line frequency — a loud buzz and rapid contact wear. A contactor that buzzes loudly is telling you something mechanical: the shading ring has burned through, the pole face is contaminated, or the armature is not seating. Do not silence it with tape or cleaner and walk away — the contactor is failing in real time.',
  'عندما يكون الـ coil تيار متردد، تصل قوة الجذب إلى الصفر مرتين في كل دورة. بدون حلقة التظليل (الشريط النحاسي الصغير على كل وجه قطب تيار متردد) يرتطم الذراع بتردد الشبكة — همهمة عالية وتآكل سريع للتوصيلات. الكونتاكتور الذي يهز بشكل واضح يخبرك بشيء ميكانيكي: حلقة التظليل احترقت، أو وجه القطب ملوث، أو الذراع لا يغطي بشكل كامل.',
  2
),
(
  'finix-contactors-control-logic',
  'The Hold-In Latch, Stop Priority, and Separate Power/Control Circuits',
  ' QE latch، أولوية الإيقاف، ودوائر الطاقة والتحكم المنفصلة',
  'The standard start/stop circuit uses a normally-open start button, a normally-closed stop button, and the contactor\'s own normally-open auxiliary contact wired in parallel with the start button to hold the coil energized after you release the start button. The stop button sits upstream of that latch junction, so a pressed stop always wins — even if the start button is being held down. Power and control are wired from separate supplies wherever possible: the contactor coil at 24V or 110V AC for safety, the motor power at full mains voltage. A technician who understands this split can read any panel.',
  'دائرة البدء/الإيقاف القياسية تستخدم زر بدءnormally-open، وزر إيقافnormally-closed، وعقدة المساعدة normally-open للكونتاكتور مركبة على التوازي مع زر البدء لتثبيت الـ coil بعد إفلات زر البدء. زر الإيقاف يكون قبل نقطة التثبيت، لذا الإيقاف المضغوط يفوز دائماً — حتى لو زر البدء مضغوط. الطاقة والتحكم يتم تمديدهما من مصادر منفصلة كلما أمكن: coil الكونتاكتور عند 24V أو 110V AC للسلامة، وطاقة المحرك عند جهد الشبكة الكامل. الفني الذي يفهم هذا الفصل يقرأ أي لوحة.',
  3
);

-- Quizzes for I01
INSERT INTO public.quizzes (module_id, code, tier, title, title_ar)
VALUES
  ('finix-contactors-control-logic', 'I01', 'bronze', 'Contactors Basics — Bronze', 'أساسيات الكونتاكتورات — برونزي'),
  ('finix-contactors-control-logic', 'I01', 'silver', 'Contactors & Control Logic — Silver', 'الكونتاكتورات ومنطق التحكم — فضي'),
  ('finix-contactors-control-logic', 'I01', 'gold', 'Contactors & Control Logic — Gold', 'الكونتاكتورات ومنطق التحكم — ذهبي');

INSERT INTO public.quiz_questions (quiz_code, tier, question, question_ar, correct_letter, options_json)
VALUES
  ('I01', 'bronze', 'What part pulls the contactor\'s moving armature closed?',
   'ما الجزء الذي يسحب الذراع المتحرك للكونتاكتور إلى الوضع المغلق؟',
   'A', '{"A":"The electromagnet coil (A1–A2)","B":"The motor power supply","C":"The auxiliary normally-open contact","D":"The shading ring"}'),
  ('I01', 'bronze', 'What function does the small copper shading ring on an AC contactor pole serve?',
   'ما وظيفة شريط التظليل النحاسي الصغير على قطب الكونتاكتور تيار متردد؟',
   'B', '{"A":"It increases the coil current","B":"It prevents the armature from chattering at line frequency","C":"It acts as a fuse for the load","D":"It converts AC to DC for the coil"}'),
  ('I01', 'bronze', 'In a standard start/stop latch circuit, where is the normally-closed stop button placed relative to the latch junction?',
   'في دائرة تثبيت البدء/إيقاف القياسية، أين يوضع زر الإيقافnormally-closed بالنسبة لنقطة التثبيت؟',
   'A', '{"A":"Upstream of the latch junction, so it always wins","B":"In parallel with the start button only","C":"After the contactor coil, on the load side","D":"On the motor power circuit only"}'),

  ('I01', 'silver', 'A contactor is buzzing loudly in a live panel. What is the most likely cause?',
   'كونتاكتور يهز بشكل واضح في لوحة تعمل. ما السبب الأكثر احتمالاً؟',
   'C', '{"A":"The motor is overloaded","B":"The start button is stuck","C":"The shading ring has failed or the armature is not seating","D":"The control supply voltage is too high"}'),
  ('I01', 'silver', 'Why are power and control circuits kept on separate supplies in an industrial panel?',
   'لماذا تحافظ دوائر الطاقة والتحكم على مصادر منفصلة في لوحة صناعية؟',
   'B', '{"A":"To reduce the total cable cost","B":"To let the control circuit run at a safe low voltage while the motor sees full mains","C":"Because contactors require two separate power sources","D":"To make the panel look neater"}'),
  ('I01', 'silver', 'In the hold-in latch circuit, what keeps the contactor coil energized after you release the start button?',
   'في دائرة التثبيت، ما الذي يبقي coil الكونتاكتور مشغلًا بعد إفلات زر البدء؟',
   'D', '{"A":"The stop button","B":"A separate timer","C":"The motor\'s back-EMF","D":"The contactor\'s own normally-open auxiliary contact, wired in parallel with the start button"}'),

  ('I01', 'gold', 'A contactor armature is not seating fully and the unit buzzes. Name two mechanical causes and the correct action.',
   'ذراع كونتاكتور لا يغطي بشكل كامل والوحدة تهز. اذكر سببين ميكانيكيين والإجراء الصحيح.',
   'B', '{"A":"Tighten the motor terminal screws and continue","B":"Check for a burned shading ring, contaminated pole face, or binding armature; replace or repair the contactor — do not silence it and walk away","C":"Reduce the motor load and monitor","D":"Increase the control voltage to force full closure"}'),
  ('I01', 'gold', 'Why does the stop button in a hold-in latch circuit always override a held-down start button?',
   'لماذا زر الإيقاف في دائرة التثبيت يتفوق دائمًا على زر البدء المضغوط؟',
   'C', '{"A":"Because the stop button draws more current","B":"Because the stop button is mechanically larger","C":"Because the stop is wired upstream of the latch junction, breaking the coil path before the start/latch parallel branch","D":"Because the contactor ignores start signals while stop is pressed"}'),
  ('I01', 'gold', 'A technician finds the contactor coil wired at the same 400V mains as the motor load. Why is this a concern, and what should it be?',
   'فني يجد أن coil الكونتاكتور ممدود بنفس 400V الشبكة المحرك. لماذا هذا مصدر قلق، وما الذي يجب أن يكون؟',
   'A', '{"A":"The coil should run at a safe control voltage (e.g. 24V or 110V AC) so the control circuit is safe to work on; mains-on-coil is a shock and maintenance hazard","B":"It is correct — coils are always rated for mains voltage","C":"It only matters if the motor is three-phase","D":"It is fine as long as the contactor is large"}');
