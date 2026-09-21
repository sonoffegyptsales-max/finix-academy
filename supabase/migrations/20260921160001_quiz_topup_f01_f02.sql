-- Quiz top-up: F01 (team roles/KPI) and F02 (electrical fundamentals).

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

-- ========== F01 ==========
SELECT pg_temp.add_q('finix-team-roles-kpi-evaluation','bronze',4,
  'Which role is responsible for the first technical response when a client reports a fault?',
  'أي دور مسؤول عن الاستجابة التقنية الأولى حين يبلّغ عميل عن عطل؟',
  'The sales representative','مندوب المبيعات',false,
  'The support or service technician','فني الدعم أو الخدمة',true,
  'The warehouse keeper','أمين المخزن',false,
  'The account manager','مدير الحساب',false);

SELECT pg_temp.add_q('finix-team-roles-kpi-evaluation','bronze',5,
  'What does a KPI measure?',
  'ماذا يقيس مؤشر الأداء الرئيسي؟',
  'The total number of employees in a company','إجمالي عدد الموظفين في الشركة',false,
  'A defined aspect of performance that can be tracked over time','جانبًا محددًا من الأداء يمكن تتبعه عبر الزمن',true,
  'The price of a product','سعر المنتج',false,
  'The warranty period of a device','مدة ضمان الجهاز',false);

SELECT pg_temp.add_q('finix-team-roles-kpi-evaluation','silver',3,
  'A technician completes jobs quickly but generates many return visits. Which KPI pair best reveals this problem?',
  'فني ينهي الأعمال بسرعة لكنه يولّد زيارات إعادة كثيرة. أي زوج من المؤشرات يكشف هذه المشكلة أفضل؟',
  'Jobs per day alone','عدد الأعمال يوميًا وحده',false,
  'Completion speed together with first-time fix rate','سرعة الإنجاز مع معدل الإصلاح من المرة الأولى',true,
  'Number of devices installed alone','عدد الأجهزة المركّبة وحده',false,
  'Travel distance per job','مسافة السفر لكل عمل',false);

SELECT pg_temp.add_q('finix-team-roles-kpi-evaluation','silver',4,
  'Why should an evaluation form combine quantitative metrics with a supervisor''s written assessment?',
  'لماذا ينبغي أن يجمع نموذج التقييم بين مقاييس كمية وتقييم مكتوب من المشرف؟',
  'Because written notes replace the need for any numbers','لأن الملاحظات المكتوبة تغني عن أي أرقام',false,
  'Because numbers alone miss judgement, client handling and safety discipline','لأن الأرقام وحدها تغفل الحكم والتعامل مع العملاء وانضباط السلامة',true,
  'Because it makes the form longer','لأنه يجعل النموذج أطول',false,
  'Because supervisors prefer writing to measuring','لأن المشرفين يفضلون الكتابة على القياس',false);

SELECT pg_temp.add_q('finix-team-roles-kpi-evaluation','silver',5,
  'A team has strong installers but repeated scope disputes with clients. Which role is most likely under-staffed?',
  'فريق لديه مركّبون أقوياء لكن نزاعات نطاق متكررة مع العملاء. أي دور على الأرجح ناقص الكادر؟',
  'The installation technician','فني التركيب',false,
  'The surveyor or project coordinator who defines scope up front','المساح أو منسق المشروع الذي يحدد النطاق مقدمًا',true,
  'The warehouse keeper','أمين المخزن',false,
  'The firmware specialist','أخصائي البرامج الثابتة',false);

SELECT pg_temp.add_q('finix-team-roles-kpi-evaluation','gold',2,
  'Two technicians have identical job counts. One has far more callbacks but much higher client satisfaction scores. What is the most professional interpretation?',
  'فنيان لهما عدد أعمال متطابق. أحدهما لديه استدعاءات أكثر بكثير لكن درجات رضا عملاء أعلى بكثير. ما التفسير الأكثر احترافية؟',
  'The satisfied clients are simply being polite and the data should be ignored','العملاء الراضون مجاملون فقط وينبغي تجاهل البيانات',false,
  'Investigate whether he is taking harder jobs or over-promising during handover, since the two signals conflict and one metric alone would mislead','تحقق إن كان يأخذ أعمالًا أصعب أو يبالغ في الوعود عند التسليم، فالإشارتان متعارضتان ومؤشر واحد وحده سيضلل',true,
  'Promote him immediately based on satisfaction','رقّه فورًا بناءً على الرضا',false,
  'Discipline him immediately based on callbacks','عاقبه فورًا بناءً على الاستدعاءات',false);

SELECT pg_temp.add_q('finix-team-roles-kpi-evaluation','gold',3,
  'A company sets a KPI of "minutes per installation" and callbacks rise sharply over the next quarter. What does this most likely demonstrate?',
  'شركة تضع مؤشر "دقائق لكل تركيب" فترتفع الاستدعاءات بحدة في الربع التالي. ما الذي يوضحه هذا على الأرجح؟',
  'That technicians became less skilled','أن الفنيين صاروا أقل مهارة',false,
  'That a single speed-based metric incentivised skipping verification steps','أن مؤشرًا واحدًا قائمًا على السرعة حفّز تخطي خطوات التحقق',true,
  'That clients became more demanding','أن العملاء صاروا أكثر تطلبًا',false,
  'That the KPI was measured incorrectly','أن المؤشر قيس بشكل خاطئ',false);

SELECT pg_temp.add_q('finix-team-roles-kpi-evaluation','gold',4,
  'A senior technician consistently refuses to document his work, arguing his fix rate is the best on the team. What is the correct management response?',
  'فني أول يرفض باستمرار توثيق عمله محتجًا بأن معدل إصلاحه الأفضل في الفريق. ما الاستجابة الإدارية الصحيحة؟',
  'Accept it, because results matter more than paperwork','اقبلها لأن النتائج تهم أكثر من الأوراق',false,
  'Treat documentation as part of the job, since undocumented work transfers no knowledge and makes the next technician slower','عامل التوثيق كجزء من العمل، فالعمل غير الموثق لا ينقل معرفة ويبطئ الفني التالي',true,
  'Remove him from client-facing work','انقله بعيدًا عن العمل مع العملاء',false,
  'Reduce his job allocation','قلل تخصيص الأعمال له',false);

SELECT pg_temp.add_q('finix-team-roles-kpi-evaluation','gold',5,
  'When evaluating a technician who works mostly alone on remote sites, which evidence source is most reliable?',
  'عند تقييم فني يعمل غالبًا وحده في مواقع نائية، أي مصدر أدلة أكثر موثوقية؟',
  'Supervisor observation, which is rarely possible on those sites','ملاحظة المشرف وهي نادرًا ما تكون ممكنة في تلك المواقع',false,
  'Completed job records, client feedback and callback history taken together','سجلات الأعمال المنجزة وتغذية العملاء وتاريخ الاستدعاءات مجتمعة',true,
  'His own self-assessment alone','تقييمه الذاتي وحده',false,
  'The number of hours he reports','عدد الساعات التي يبلّغ عنها',false);

-- ========== F02 ==========
SELECT pg_temp.add_q('finix-electrical-fundamentals-deep-dive','bronze',4,
  'In a balanced three-phase star connection, what is the relationship between line voltage and phase voltage?',
  'في توصيلة نجمة ثلاثية الأطوار متزنة، ما العلاقة بين جهد الخط وجهد الطور؟',
  'Line voltage equals phase voltage','جهد الخط يساوي جهد الطور',false,
  'Line voltage is the square root of three times phase voltage','جهد الخط يساوي جذر ثلاثة مضروبًا في جهد الطور',true,
  'Line voltage is three times phase voltage','جهد الخط ثلاثة أضعاف جهد الطور',false,
  'Line voltage is half of phase voltage','جهد الخط نصف جهد الطور',false);

SELECT pg_temp.add_q('finix-electrical-fundamentals-deep-dive','bronze',5,
  'What does a cable''s current-carrying capacity depend on besides its cross-sectional area?',
  'على ماذا تعتمد قدرة الكابل على حمل التيار إلى جانب مساحة مقطعه؟',
  'Only its colour','لونه فقط',false,
  'Installation method, ambient temperature and grouping with other cables','طريقة التركيب ودرجة الحرارة المحيطة والتجميع مع كابلات أخرى',true,
  'Only the manufacturer','المصنّع فقط',false,
  'Only the length of the run','طول المد فقط',false);

SELECT pg_temp.add_q('finix-electrical-fundamentals-deep-dive','silver',3,
  'A long cable run feeds a motor that starts sluggishly and runs hot, though the cable is rated for the current. What should be checked?',
  'مد كابل طويل يغذي محركًا يبدأ ببطء ويعمل ساخنًا رغم أن الكابل مصنّف للتيار. ما الذي ينبغي فحصه؟',
  'The motor''s paint finish','دهان المحرك',false,
  'Voltage drop along the run, which is a separate calculation from current rating','هبوط الجهد على طول المد، وهو حساب منفصل عن تصنيف التيار',true,
  'The colour coding of the cores','ترميز ألوان العروق',false,
  'The breaker manufacturer','مصنّع القاطع',false);

SELECT pg_temp.add_q('finix-electrical-fundamentals-deep-dive','silver',4,
  'A motor nameplate states 400 V, 7.5 kW, power factor 0.85. Why can you not size the cable from kW alone?',
  'لوحة محرك تذكر ٤٠٠ فولت و٧٫٥ كيلوواط ومعامل قدرة ٠٫٨٥. لماذا لا يمكن تحديد مقطع الكابل من الكيلوواط وحدها؟',
  'Because kW is always wrong on nameplates','لأن الكيلوواط خطأ دائمًا في اللوحات',false,
  'Because the cable carries current, and current depends on voltage and power factor as well as power','لأن الكابل يحمل تيارًا، والتيار يعتمد على الجهد ومعامل القدرة إضافة للقدرة',true,
  'Because kW refers only to starting power','لأن الكيلوواط تشير لقدرة البدء فقط',false,
  'Because cable sizing ignores the motor entirely','لأن تحديد مقطع الكابل يتجاهل المحرك تمامًا',false);

SELECT pg_temp.add_q('finix-electrical-fundamentals-deep-dive','silver',5,
  'Why does a delta connection deliver more power to a motor than star for the same supply?',
  'لماذا تسلّم توصيلة الدلتا قدرة أكبر للمحرك من النجمة لنفس التغذية؟',
  'Because delta uses thicker windings','لأن الدلتا تستخدم ملفات أسمك',false,
  'Because each winding receives the full line voltage rather than line voltage divided by root three','لأن كل ملف يستقبل جهد الخط الكامل بدل جهد الخط مقسومًا على جذر ثلاثة',true,
  'Because delta has no neutral','لأن الدلتا بلا نيوترال',false,
  'Because delta runs at a higher frequency','لأن الدلتا تعمل بتردد أعلى',false);

SELECT pg_temp.add_q('finix-electrical-fundamentals-deep-dive','gold',2,
  'A three-phase motor runs hot and noisy with reduced torque. Measured line currents are unequal by a large margin. What is the most probable cause?',
  'محرك ثلاثي الأطوار يعمل ساخنًا وصاخبًا بعزم منخفض. تيارات الخطوط المقاسة غير متساوية بفارق كبير. ما السبب الأرجح؟',
  'Normal behaviour for any three-phase motor','سلوك طبيعي لأي محرك ثلاثي الأطوار',false,
  'Loss of one phase or a high-resistance connection in one line','فقد طور أو وصلة عالية المقاومة في أحد الخطوط',true,
  'The motor is oversized for the load','المحرك أكبر من الحمل',false,
  'The supply frequency is too high','تردد التغذية مرتفع جدًا',false);

SELECT pg_temp.add_q('finix-electrical-fundamentals-deep-dive','gold',3,
  'An installation passes a continuity test but a lamp circuit still does not work. What does this most usefully tell you?',
  'تركيب يجتاز اختبار الاستمرارية لكن دائرة مصباح ما تزال لا تعمل. ما الذي يخبرك به هذا بشكل أنفع؟',
  'That the cable is definitely broken','أن الكابل مقطوع قطعًا',false,
  'That the conductor path is intact, so the fault lies elsewhere such as the lamp, the switch or the supply','أن مسار الموصّل سليم فالعطل في مكان آخر كالمصباح أو المفتاح أو التغذية',true,
  'That the test equipment is faulty','أن أجهزة الاختبار معطلة',false,
  'That the circuit is overloaded','أن الدائرة محمّلة زائدًا',false);

SELECT pg_temp.add_q('finix-electrical-fundamentals-deep-dive','gold',4,
  'Two identical LED fittings on the same circuit run at visibly different brightness. Which explanation should be investigated first?',
  'وحدتا LED متطابقتان على الدائرة نفسها تعملان بسطوع مختلف بصريًا. أي تفسير ينبغي فحصه أولًا؟',
  'The lamps have different lifespans','المصباحان لهما أعمار مختلفة',false,
  'A poor connection or excessive volt drop on the branch feeding the dimmer one','وصلة رديئة أو هبوط جهد مفرط في الفرع الذي يغذي الأخفت',true,
  'The ceiling height differs','ارتفاع السقف مختلف',false,
  'The circuit breaker is the wrong colour','قاطع الدائرة بلون خاطئ',false);

SELECT pg_temp.add_q('finix-electrical-fundamentals-deep-dive','gold',5,
  'A client asks why their electricity bill rose after adding equipment whose nameplate power did not change. What is the most technically sound answer to investigate?',
  'عميل يسأل لماذا ارتفعت فاتورته بعد إضافة معدات لم تتغير قدرة لوحتها. ما الجواب الأسلم تقنيًا للفحص؟',
  'Nameplate power is the only factor, so the bill must be an error','قدرة اللوحة العامل الوحيد فالفاتورة خطأ حتمًا',false,
  'Energy is power multiplied by time, so longer running hours raise consumption even at unchanged power','الطاقة قدرة مضروبة في زمن، فساعات التشغيل الأطول ترفع الاستهلاك حتى بقدرة ثابتة',true,
  'Three-phase equipment is always billed double','المعدات ثلاثية الأطوار تفوتر دائمًا بالضعف',false,
  'Power factor has no effect on anything','معامل القدرة بلا أثر على أي شيء',false);
