-- Step 2a: Quizzes for F08 (Bilingual Terminology & Field Toolkit).
--
-- F08 was the only populated module on the platform with no assessment at all.
-- Questions are drawn from its three lessons: room/space terminology, device
-- terminology, and the field toolkit.

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'bronze', 'Terminology & Toolkit — Bronze', 'المصطلحات وحقيبة الأدوات — برونزي', 80
FROM public.modules WHERE slug = 'finix-terminology-toolkit';

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'silver', 'Terminology & Toolkit — Silver', 'المصطلحات وحقيبة الأدوات — فضي', 80
FROM public.modules WHERE slug = 'finix-terminology-toolkit';

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'gold', 'Terminology & Toolkit — Gold', 'المصطلحات وحقيبة الأدوات — ذهبي', 80
FROM public.modules WHERE slug = 'finix-terminology-toolkit';

-- Helper: add a question with four options, one correct.
CREATE OR REPLACE FUNCTION pg_temp.add_q(
  p_slug text, p_tier text, p_pos int,
  p_q text, p_q_ar text,
  p_a text, p_a_ar text, p_a_ok boolean,
  p_b text, p_b_ar text, p_b_ok boolean,
  p_c text, p_c_ar text, p_c_ok boolean,
  p_d text, p_d_ar text, p_d_ok boolean
) RETURNS void LANGUAGE plpgsql AS $fn$
DECLARE v_quiz uuid; v_q uuid;
BEGIN
  SELECT qz.id INTO v_quiz
  FROM public.quizzes qz JOIN public.modules m ON m.id = qz.module_id
  WHERE m.slug = p_slug AND qz.tier = p_tier::public.quiz_tier;

  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  VALUES (v_quiz, p_q, p_q_ar, p_pos) RETURNING id INTO v_q;

  INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
  VALUES (v_q, p_a, p_a_ar, p_a_ok, 1),
         (v_q, p_b, p_b_ar, p_b_ok, 2),
         (v_q, p_c, p_c_ar, p_c_ok, 3),
         (v_q, p_d, p_d_ar, p_d_ok, 4);
END $fn$;

-- ---------- BRONZE: recall ----------
SELECT pg_temp.add_q('finix-terminology-toolkit','bronze',1,
 'A client asks for smart control in the "صالة". Which English term should appear on your survey form?',
 'يطلب عميل تحكمًا ذكيًا في "الصالة". أي مصطلح إنجليزي يجب أن يظهر في استمارة المعاينة؟',
 'Living room / reception','غرفة المعيشة / الاستقبال',true,
 'Bathroom','حمام',false,
 'Kitchen','مطبخ',false,
 'Balcony','بلكونة',false);

SELECT pg_temp.add_q('finix-terminology-toolkit','bronze',2,
 'What does a multimeter measure that a non-contact voltage tester cannot?',
 'ما الذي يقيسه الملتيميتر ولا يستطيع قياسه كاشف الجهد غير التلامسي؟',
 'Only whether a wire is live','فقط إن كان السلك مكهربًا',false,
 'Actual voltage, current and resistance values','قيم الجهد والتيار والمقاومة الفعلية',true,
 'Wi-Fi signal strength','قوة إشارة الواي فاي',false,
 'Cable length','طول الكابل',false);

SELECT pg_temp.add_q('finix-terminology-toolkit','bronze',3,
 'Which term describes a wall-mounted switch that replaces an existing mechanical switch?',
 'أي مصطلح يصف مفتاحًا جداريًا يحل محل مفتاح ميكانيكي قائم؟',
 'Gateway','بوابة',false,
 'Sensor','حساس',false,
 'Retrofit smart switch','مفتاح ذكي بديل (ريتروفيت)',true,
 'Repeater','مكرر إشارة',false);

SELECT pg_temp.add_q('finix-terminology-toolkit','bronze',4,
 'Why does a technician carry a label printer on every job?',
 'لماذا يحمل الفني طابعة ملصقات في كل مهمة؟',
 'To print receipts for the client','لطباعة إيصالات للعميل',false,
 'To label wires and devices so the install can be serviced later','لترميز الأسلاك والأجهزة كي يمكن صيانة التركيب لاحقًا',true,
 'It is only needed for commercial jobs','مطلوبة فقط في المشاريع التجارية',false,
 'To mark the client''s furniture','لتعليم أثاث العميل',false);

SELECT pg_temp.add_q('finix-terminology-toolkit','bronze',5,
 'What is the Arabic term you would write for "ceiling light" on a bilingual survey?',
 'ما المصطلح العربي الذي تكتبه لـ "ceiling light" في معاينة ثنائية اللغة؟',
 'نجفة / إضاءة سقف','نجفة / إضاءة سقف',true,
 'مروحة','مروحة',false,
 'مقبس','مقبس',false,
 'ستارة','ستارة',false);

-- ---------- SILVER: application ----------
SELECT pg_temp.add_q('finix-terminology-toolkit','silver',1,
 'A survey form records "مقبس" in one room and "outlet" in another for the same fitting. Why is this a real problem, not a cosmetic one?',
 'استمارة معاينة تسجّل "مقبس" في غرفة و"outlet" في أخرى لنفس القطعة. لماذا هذه مشكلة حقيقية لا شكلية؟',
 'It looks unprofessional but has no practical effect','تبدو غير احترافية لكن بلا أثر عملي',false,
 'Inconsistent naming breaks the bill of materials count and causes the wrong device quantity to be ordered','عدم اتساق التسمية يفسد حصر الكميات فتُطلب كمية خاطئة من الأجهزة',true,
 'Arabic terms are not allowed on survey forms','المصطلحات العربية غير مسموحة في الاستمارات',false,
 'It only matters if the client reads the form','يهم فقط إن قرأ العميل الاستمارة',false);

SELECT pg_temp.add_q('finix-terminology-toolkit','silver',2,
 'You arrive at a villa to commission 40 Zigbee devices. Which tool prevents the most wasted trips?',
 'تصل إلى فيلا لتشغيل ٤٠ جهاز Zigbee. أي أداة تمنع أكبر قدر من الزيارات المهدرة؟',
 'A larger screwdriver set','طقم مفكات أكبر',false,
 'A label printer','طابعة ملصقات',false,
 'A laptop or phone running a Zigbee network map, so you see mesh coverage before leaving site','حاسوب أو هاتف يعرض خريطة شبكة Zigbee لترى التغطية قبل مغادرة الموقع',true,
 'A spare ladder','سلم احتياطي',false);

SELECT pg_temp.add_q('finix-terminology-toolkit','silver',3,
 'Why should scene names in the app use the client''s own room vocabulary rather than yours?',
 'لماذا يجب أن تستخدم أسماء المشاهد في التطبيق مفردات غرف العميل لا مفرداتك؟',
 'The app requires Arabic names','التطبيق يتطلب أسماء عربية',false,
 'Because the household will not use scenes they cannot find or recognise by name','لأن الأسرة لن تستخدم مشاهد لا تجدها أو لا تتعرف على اسمها',true,
 'It makes the handover document shorter','يجعل مستند التسليم أقصر',false,
 'It has no effect on adoption','لا أثر له على الاستخدام',false);

SELECT pg_temp.add_q('finix-terminology-toolkit','silver',4,
 'A wall box measures 4 cm deep. What does the toolkit knowledge tell you before you quote retrofit switches?',
 'علبة جدارية عمقها ٤ سم. ماذا تخبرك معرفة الحقيبة قبل تسعير مفاتيح الريتروفيت؟',
 'Depth is irrelevant for smart switches','العمق غير مهم للمفاتيح الذكية',false,
 'Most smart switches need 5–7 cm; flag the box depth as a cost item or plan a spacer/back-box change','أغلب المفاتيح الذكية تحتاج ٥–٧ سم؛ سجّل عمق العلبة كبند تكلفة أو خطط لتغيير العلبة',true,
 'Only the neutral wire matters','السلك المحايد فقط هو المهم',false,
 'Use a smaller screwdriver','استخدم مفكًا أصغر',false);

SELECT pg_temp.add_q('finix-terminology-toolkit','silver',5,
 'Which pair of terms is most often confused on survey forms, causing a wiring surprise on installation day?',
 'أي زوج من المصطلحات يُخلط بينه غالبًا في الاستمارات فيسبب مفاجأة في التمديد يوم التركيب؟',
 'Ceiling light vs. floor lamp','إضاءة سقف مقابل أباجورة أرضية',false,
 'Switch vs. socket — one interrupts a live circuit, the other supplies a plug load','مفتاح مقابل مقبس — أحدهما يقطع دائرة والآخر يغذي حملًا',true,
 'Door vs. window','باب مقابل شباك',false,
 'Bedroom vs. guest room','غرفة نوم مقابل غرفة ضيوف',false);

-- ---------- GOLD: judgement ----------
SELECT pg_temp.add_q('finix-terminology-toolkit','gold',1,
 'Your survey form, the client''s quotation and the app scene names all use different words for the same three rooms. The install goes ahead. What is the most likely downstream cost?',
 'استمارتك وعرض سعر العميل وأسماء المشاهد في التطبيق تستخدم كلمات مختلفة لنفس الغرف الثلاث. ونُفّذ التركيب. ما التكلفة الأرجح لاحقًا؟',
 'None — the devices work regardless of naming','لا شيء — الأجهزة تعمل بغض النظر عن التسمية',false,
 'Support calls and a failed handover: the client cannot match what they were sold to what is in the app, and every future service visit starts by re-mapping the site','اتصالات دعم وتسليم فاشل: لا يستطيع العميل مطابقة ما اشتراه بما في التطبيق، وكل زيارة صيانة تبدأ بإعادة رسم الموقع',true,
 'Only the invoice needs correcting','الفاتورة فقط تحتاج تصحيحًا',false,
 'The warranty is voided','يبطل الضمان',false);

SELECT pg_temp.add_q('finix-terminology-toolkit','gold',2,
 'You are standardising terminology across a team of six technicians working in both Arabic and English. What produces the most durable result?',
 'تريد توحيد المصطلحات عبر فريق من ستة فنيين يعملون بالعربية والإنجليزية. ما الذي ينتج أثبت نتيجة؟',
 'Tell everyone to use English only','اطلب من الجميع استخدام الإنجليزية فقط',false,
 'A single controlled bilingual glossary that the survey form, quotation template and app scene names all draw from','مسرد ثنائي اللغة واحد مُحكم تعتمد عليه الاستمارة وقالب العرض وأسماء المشاهد',true,
 'Let each technician use their own preference','دع كل فني يستخدم تفضيله',false,
 'Translate at handover only','ترجم عند التسليم فقط',false);

SELECT pg_temp.add_q('finix-terminology-toolkit','gold',3,
 'A junior technician''s toolkit contains only hand tools — no meter, no network tool, no label printer. Beyond inconvenience, what is the professional risk?',
 'حقيبة فني مبتدئ تحتوي أدوات يدوية فقط — لا جهاز قياس ولا أداة شبكة ولا طابعة ملصقات. ما المخاطرة المهنية بعيدًا عن الإزعاج؟',
 'There is no real risk','لا مخاطرة حقيقية',false,
 'He cannot verify his own work — he cannot prove a circuit is dead before touching it, cannot confirm mesh coverage, and leaves an install nobody can service','لا يستطيع التحقق من عمله — لا يثبت أن الدائرة مفصولة قبل لمسها، ولا يؤكد تغطية الشبكة، ويترك تركيبًا لا يمكن صيانته',true,
 'Only the install speed is affected','تتأثر سرعة التركيب فقط',false,
 'It only matters on commercial sites','يهم في المواقع التجارية فقط',false);

SELECT pg_temp.add_q('finix-terminology-toolkit','gold',4,
 'Why is a bilingual glossary a commercial asset in the Egyptian market specifically, not just a nicety?',
 'لماذا يُعد المسرد ثنائي اللغة أصلًا تجاريًا في السوق المصري تحديدًا لا مجرد رفاهية؟',
 'Because international brands require it','لأن العلامات العالمية تشترطه',false,
 'Because proposals are read by Arabic-speaking clients while devices, apps and datasheets are English — a team that bridges both closes faster and services cleaner','لأن العروض يقرأها عملاء عرب بينما الأجهزة والتطبيقات وكتالوجاتها إنجليزية — والفريق الذي يجسر بينهما يبيع أسرع ويصون أنظف',true,
 'It reduces device cost','يقلل تكلفة الأجهزة',false,
 'It is required by law','يفرضه القانون',false);

SELECT pg_temp.add_q('finix-terminology-toolkit','gold',5,
 'During handover the client uses a room name that appears nowhere in your documentation. What is the correct response?',
 'أثناء التسليم يستخدم العميل اسم غرفة لا يظهر في وثائقك. ما التصرف الصحيح؟',
 'Correct the client to use your term','صحّح للعميل ليستخدم مصطلحك',false,
 'Ignore it — the documentation is already printed','تجاهل — الوثائق مطبوعة بالفعل',false,
 'Adopt the client''s name, update the app scene names and the as-built document on the spot, because the household''s vocabulary is the one that will be used for years','اعتمد اسم العميل وحدّث أسماء المشاهد والمستند النهائي فورًا، لأن مفردات الأسرة هي ما سيُستخدم لسنوات',true,
 'Note it for the next project only','سجّله للمشروع التالي فقط',false);
