-- Step 2b: M17 was the only module with a single quiz tier (Bronze, 2 questions).
-- Adds Silver and Gold, and tops Bronze up to five questions.

CREATE OR REPLACE FUNCTION pg_temp.add_q(
  p_slug text, p_tier text, p_pos int,
  p_q text, p_q_ar text,
  p_a text, p_a_ar text, p_a_ok boolean,
  p_b text, p_b_ar text, p_b_ok boolean,
  p_c text, p_c_ar text, p_c_ok boolean,
  p_d text, p_d_ar text, p_d_ok boolean
) RETURNS void LANGUAGE plpgsql AS $fn$
DECLARE v_quiz uuid; v_q uuid; v_pos int;
BEGIN
  SELECT qz.id INTO v_quiz
  FROM public.quizzes qz JOIN public.modules m ON m.id = qz.module_id
  WHERE m.slug = p_slug AND qz.tier = p_tier::public.quiz_tier;

  SELECT coalesce(max(position),0) + 1 INTO v_pos
  FROM public.quiz_questions WHERE quiz_id = v_quiz;

  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  VALUES (v_quiz, p_q, p_q_ar, v_pos) RETURNING id INTO v_q;

  INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
  VALUES (v_q, p_a, p_a_ar, p_a_ok, 1),
         (v_q, p_b, p_b_ar, p_b_ok, 2),
         (v_q, p_c, p_c_ar, p_c_ok, 3),
         (v_q, p_d, p_d_ar, p_d_ok, 4);
END $fn$;

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'silver', 'Scene Design & HVAC — Silver', 'تصميم المشاهد والتكييف — فضي', 80
FROM public.modules WHERE slug = 'sonoff-scene-design-hvac-troubleshooting';

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'gold', 'Scene Design & HVAC — Gold', 'تصميم المشاهد والتكييف — ذهبي', 80
FROM public.modules WHERE slug = 'sonoff-scene-design-hvac-troubleshooting';

-- ---------- BRONZE top-up ----------
SELECT pg_temp.add_q('sonoff-scene-design-hvac-troubleshooting','bronze',0,
 'What is the first step in systematic troubleshooting?',
 'ما الخطوة الأولى في استكشاف الأعطال المنهجي؟',
 'Replace the device that seems faulty','استبدل الجهاز الذي يبدو معطلًا',false,
 'Establish exactly what the symptom is and when it occurs','حدّد بدقة ما هو العَرَض ومتى يحدث',true,
 'Reset the whole network','أعد ضبط الشبكة كلها',false,
 'Update all firmware','حدّث كل البرامج الثابتة',false);

SELECT pg_temp.add_q('sonoff-scene-design-hvac-troubleshooting','bronze',0,
 'A good handover means the client can do what without calling you?',
 'التسليم الجيد يعني أن العميل يستطيع فعل ماذا دون الاتصال بك؟',
 'Rewire a switch','إعادة تمديد مفتاح',false,
 'Flash firmware','تحديث البرنامج الثابت',false,
 'Use the daily scenes, add a user, and recover from a Wi-Fi outage','استخدام المشاهد اليومية وإضافة مستخدم والتعافي من انقطاع الواي فاي',true,
 'Reconfigure the gateway','إعادة إعداد البوابة',false);

SELECT pg_temp.add_q('sonoff-scene-design-hvac-troubleshooting','bronze',0,
 'Which thermostat wire supplies constant power that smart thermostats need?',
 'أي سلك ترموستات يوفر الطاقة المستمرة التي تحتاجها الترموستات الذكية؟',
 'The C (common) wire','سلك C المشترك',true,
 'The W wire','سلك W',false,
 'The G wire','سلك G',false,
 'The Y wire','سلك Y',false);

-- ---------- SILVER ----------
SELECT pg_temp.add_q('sonoff-scene-design-hvac-troubleshooting','silver',0,
 'A client says "the lights come on at random". What does a systematic approach check before touching any device?',
 'يقول عميل "الأنوار تعمل عشوائيًا". ماذا يفحص النهج المنهجي قبل لمس أي جهاز؟',
 'Replace the switches immediately','استبدل المفاتيح فورًا',false,
 'Whether an overlapping scene, schedule or motion rule is firing — conflicting automation looks exactly like a fault','هل يعمل مشهد أو جدول أو قاعدة حركة متداخلة — الأتمتة المتعارضة تبدو تمامًا كعطل',true,
 'The Wi-Fi password','كلمة مرور الواي فاي',false,
 'The circuit breaker rating','تصنيف قاطع الدائرة',false);

SELECT pg_temp.add_q('sonoff-scene-design-hvac-troubleshooting','silver',0,
 'Why should a scene never be built to switch every light in the house at once?',
 'لماذا يجب ألا يُبنى مشهد يبدّل كل أنوار المنزل دفعة واحدة؟',
 'The app does not allow it','التطبيق لا يسمح بذلك',false,
 'Simultaneous inrush across many drivers can trip the circuit, and a single mistimed scene affects the whole household at once','تيار الاندفاع المتزامن عبر سائقات كثيرة قد يفصل الدائرة، ومشهد واحد بتوقيت خاطئ يؤثر على المنزل كله',true,
 'It uses more Zigbee bandwidth','يستهلك نطاق Zigbee أكبر',false,
 'Scenes are limited to five devices','المشاهد محدودة بخمسة أجهزة',false);

SELECT pg_temp.add_q('sonoff-scene-design-hvac-troubleshooting','silver',0,
 'A smart thermostat is installed on a system with no C wire. What is the correct professional response?',
 'رُكّب ترموستات ذكي على نظام بلا سلك C. ما الاستجابة المهنية الصحيحة؟',
 'Use battery power and accept the limitation','استخدم البطارية واقبل القيد',false,
 'Run a C wire, or fit a manufacturer-approved add-a-wire adapter — battery-only operation fails silently when the battery dies','مدّد سلك C أو ركّب محوّل معتمد من المصنّع — التشغيل بالبطارية وحدها يفشل صامتًا عند نفادها',true,
 'Connect the C terminal to earth','اربط طرف C بالأرضي',false,
 'Any spare wire will work as C','أي سلك احتياطي يصلح كـ C',false);

SELECT pg_temp.add_q('sonoff-scene-design-hvac-troubleshooting','silver',0,
 'Which scene design most reliably gets used by an ordinary household?',
 'أي تصميم مشهد تستخدمه الأسرة العادية بأكبر موثوقية؟',
 'Twelve scenes covering every possible combination','اثنا عشر مشهدًا تغطي كل التوليفات الممكنة',false,
 'Three or four scenes matching moments the family already has — leaving, sleeping, cooking, watching','ثلاثة أو أربعة مشاهد تطابق لحظات تعيشها الأسرة أصلًا — الخروج، النوم، الطبخ، المشاهدة',true,
 'One master scene for everything','مشهد رئيسي واحد لكل شيء',false,
 'Scenes named after device model numbers','مشاهد مسماة بأرقام موديلات الأجهزة',false);

SELECT pg_temp.add_q('sonoff-scene-design-hvac-troubleshooting','silver',0,
 'What distinguishes a symptom from a root cause in a smart home fault?',
 'ما الذي يميز العَرَض عن السبب الجذري في عطل منزل ذكي؟',
 'They are the same thing','هما الشيء نفسه',false,
 'The symptom is what the client observes; the root cause is the condition that produces it — fixing only the symptom guarantees a repeat call','العَرَض ما يلاحظه العميل؛ والسبب الجذري هو الحالة المنتجة له — وإصلاح العَرَض وحده يضمن اتصالًا متكررًا',true,
 'Root causes are always network related','الأسباب الجذرية دائمًا متعلقة بالشبكة',false,
 'Symptoms only appear in the app','الأعراض تظهر في التطبيق فقط',false);

-- ---------- GOLD ----------
SELECT pg_temp.add_q('sonoff-scene-design-hvac-troubleshooting','gold',0,
 'Six months after handover a client reports that "nothing works like it used to". Investigation shows the household never used the scenes you built. What went wrong, and at which stage?',
 'بعد ستة أشهر من التسليم يبلّغ عميل أن "لا شيء يعمل كما كان". ويتبين أن الأسرة لم تستخدم المشاهد التي بنيتها. ما الخطأ وفي أي مرحلة؟',
 'The devices degraded and need replacing','تدهورت الأجهزة وتحتاج استبدالًا',false,
 'The scenes were designed around the installation rather than the household''s actual routine, and the handover did not verify the family could use them — a design and handover failure, not a hardware one','صُممت المشاهد حول التركيب لا حول روتين الأسرة الفعلي، ولم يتحقق التسليم من قدرة العائلة على استخدامها — فشل تصميم وتسليم لا فشل عتاد',true,
 'The Wi-Fi changed','تغيّرت شبكة الواي فاي',false,
 'Firmware updates broke the scenes','حدّثت البرامج الثابتة فكسرت المشاهد',false);

SELECT pg_temp.add_q('sonoff-scene-design-hvac-troubleshooting','gold',0,
 'A thermostat controls a heat pump. The client complains of high bills and short cycling. Which design error is most likely?',
 'ترموستات يتحكم بمضخة حرارية. يشكو العميل من فواتير عالية وتشغيل متقطع قصير. أي خطأ تصميمي هو الأرجح؟',
 'The thermostat is faulty and must be replaced','الترموستات معطل ويجب استبداله',false,
 'The differential/deadband is set too narrow and auxiliary heat is allowed to engage too readily — the thermostat is doing what it was configured to do','نطاق الفرق التفاضلي ضيق جدًا ويُسمح للتسخين المساعد بالعمل بسهولة — الترموستات ينفذ ما أُعد له',true,
 'The C wire is missing','سلك C مفقود',false,
 'The heat pump is undersized','مضخة الحرارة أصغر من اللازم',false);

SELECT pg_temp.add_q('sonoff-scene-design-hvac-troubleshooting','gold',0,
 'You inherit a site where three technicians have each added automation over two years. Lights behave unpredictably. What is the correct first move?',
 'تتسلّم موقعًا أضاف فيه ثلاثة فنيين أتمتة عبر سنتين. الأنوار تتصرف بشكل غير متوقع. ما أول تحرك صحيح؟',
 'Factory reset everything and start again','أعد ضبط كل شيء للمصنع وابدأ من جديد',false,
 'Replace the gateway','استبدل البوابة',false,
 'Inventory every existing scene, schedule and rule first and map overlaps — resetting destroys the client''s working configuration along with the conflict','احصر أولًا كل مشهد وجدول وقاعدة وارسم التداخلات — فإعادة الضبط تدمر إعدادات العميل العاملة مع التعارض',true,
 'Disable all automation permanently','عطّل كل الأتمتة نهائيًا',false);

SELECT pg_temp.add_q('sonoff-scene-design-hvac-troubleshooting','gold',0,
 'Why is customer training a technical deliverable rather than a courtesy?',
 'لماذا يُعد تدريب العميل تسليمًا تقنيًا لا مجاملة؟',
 'It is not — it is purely goodwill','ليس كذلك — مجرد لباقة',false,
 'An installation the household cannot operate produces support calls, false fault reports and eventual abandonment; training is what converts working hardware into a working system','التركيب الذي لا تستطيع الأسرة تشغيله ينتج اتصالات دعم وبلاغات أعطال كاذبة وهجرًا في النهاية؛ والتدريب هو ما يحوّل عتادًا عاملًا إلى نظام عامل',true,
 'It reduces the device warranty period','يقلل مدة ضمان الأجهزة',false,
 'It is only needed for commercial clients','مطلوب للعملاء التجاريين فقط',false);

SELECT pg_temp.add_q('sonoff-scene-design-hvac-troubleshooting','gold',0,
 'A fault appears only in the evening, only in summer, and only in one room. What does this pattern tell a systematic troubleshooter?',
 'عطل يظهر مساءً فقط، صيفًا فقط، وفي غرفة واحدة فقط. ماذا يخبر هذا النمط الفني المنهجي؟',
 'It is random and cannot be diagnosed','عشوائي ولا يمكن تشخيصه',false,
 'The conditions are the evidence: something time-based, temperature-based and location-specific is involved — a schedule, thermal drift, or an HVAC-driven interaction, not a random device failure','الظروف هي الدليل: شيء مرتبط بالوقت والحرارة والموقع — جدول أو انحراف حراري أو تفاعل مع التكييف، لا عطل جهاز عشوائي',true,
 'The device must be replaced','يجب استبدال الجهاز',false,
 'Only a firmware update can fix it','تحديث البرنامج الثابت وحده يصلحه',false);
