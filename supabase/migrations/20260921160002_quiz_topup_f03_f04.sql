-- Quiz top-up: F03 (site survey) and F04 (power devices and protection).

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

-- ========== F03 ==========
SELECT pg_temp.add_q('finix-site-survey-methodology','bronze',3,
  'What is the main purpose of a standardized survey form?',
  'ما الغرض الرئيسي من نموذج مسح موحد؟',
  'To make the visit take longer','لجعل الزيارة تستغرق وقتًا أطول',false,
  'To ensure no critical question is forgotten regardless of who performs the survey','لضمان عدم نسيان أي سؤال حرج بغض النظر عمن يؤدي المسح',true,
  'To replace speaking with the client','للاستغناء عن التحدث مع العميل',false,
  'To satisfy the warehouse department','لإرضاء قسم المخازن',false);

SELECT pg_temp.add_q('finix-site-survey-methodology','bronze',4,
  'Why should the survey record the location of the consumer unit and available circuits?',
  'لماذا ينبغي أن يسجل المسح موقع لوحة التوزيع والدوائر المتاحة؟',
  'Only for aesthetic reasons','لأسباب جمالية فقط',false,
  'Because it determines what can be powered and where protection must be added','لأنه يحدد ما يمكن تغذيته وأين يجب إضافة الحماية',true,
  'Because clients always ask about it','لأن العملاء يسألون عنه دائمًا',false,
  'Because it is required for painting work','لأنه مطلوب لأعمال الدهان',false);

SELECT pg_temp.add_q('finix-site-survey-methodology','bronze',5,
  'What should be photographed during a survey?',
  'ماذا ينبغي تصويره أثناء المسح؟',
  'Nothing, to protect client privacy entirely','لا شيء لحماية خصوصية العميل تمامًا',false,
  'Existing wiring, switch boxes, the consumer unit and any obstruction affecting the work','التمديد القائم وعلب المفاتيح ولوحة التوزيع وأي عائق يؤثر على العمل',true,
  'Only the exterior of the building','واجهة المبنى فقط',false,
  'Only the client''s furniture','أثاث العميل فقط',false);

SELECT pg_temp.add_q('finix-site-survey-methodology','silver',2,
  'A client wants smart switches throughout, but the survey finds no neutral at most switch boxes. What is the correct response during the survey?',
  'عميل يريد مفاتيح ذكية في كل مكان لكن المسح لا يجد نيوترال في أغلب علب المفاتيح. ما الاستجابة الصحيحة أثناء المسح؟',
  'Quote the job normally and deal with it during installation','سعّر العمل عاديًا وتعامل معها أثناء التركيب',false,
  'Record it, and price either no-neutral devices or an alternative approach before quoting','سجّلها وسعّر إما أجهزة تعمل بلا نيوترال أو مقاربة بديلة قبل التسعير',true,
  'Tell the client smart switches are impossible','أخبر العميل أن المفاتيح الذكية مستحيلة',false,
  'Ignore it since most devices work without neutral','تجاهلها فأغلب الأجهزة تعمل بلا نيوترال',false);

SELECT pg_temp.add_q('finix-site-survey-methodology','silver',3,
  'Why is asking the client about their daily routine part of a technical survey?',
  'لماذا يكون سؤال العميل عن روتينه اليومي جزءًا من مسح تقني؟',
  'It is small talk only','مجرد حديث ودي',false,
  'Because automation design depends on when people arrive, sleep and use each space','لأن تصميم الأتمتة يعتمد على متى يصل الناس وينامون ويستخدمون كل حيز',true,
  'Because it determines the cable colour','لأنه يحدد لون الكابل',false,
  'Because it sets the warranty period','لأنه يحدد مدة الضمان',false);

SELECT pg_temp.add_q('finix-site-survey-methodology','silver',4,
  'A survey reveals thick reinforced concrete walls between the proposed gateway location and several rooms. What should the survey conclude?',
  'يكشف مسح عن جدران خرسانية مسلحة سميكة بين موقع البوابة المقترح وعدة غرف. بماذا ينبغي أن يخلص المسح؟',
  'Nothing, since wireless passes through all walls','لا شيء فاللاسلكي يعبر كل الجدران',false,
  'That mains-powered repeater devices or a relocated gateway must be priced into the design','أن أجهزة مكررة مغذاة أو بوابة معاد موضعها يجب تسعيرها في التصميم',true,
  'That the client should move house','أن على العميل تغيير المسكن',false,
  'That only battery sensors should be used','أن تُستخدم حساسات بطاريات فقط',false);

SELECT pg_temp.add_q('finix-site-survey-methodology','silver',5,
  'Why should the survey record the internet service and router model?',
  'لماذا ينبغي أن يسجل المسح خدمة الإنترنت وموديل الراوتر؟',
  'To sell the client a new router regardless','لبيع العميل راوترًا جديدًا على أي حال',false,
  'Because remote access, cloud features and segmentation options all depend on it','لأن الوصول عن بُعد والميزات السحابية وخيارات التقسيم تعتمد عليه',true,
  'Because it determines the wall paint','لأنه يحدد دهان الجدار',false,
  'Because it is needed for the electrical certificate','لأنه مطلوب للشهادة الكهربائية',false);

SELECT pg_temp.add_q('finix-site-survey-methodology','gold',2,
  'A surveyor quotes a large villa from photographs the client sent rather than visiting. What is the most likely consequence?',
  'مساح يسعّر فيلا كبيرة من صور أرسلها العميل بدل الزيارة. ما النتيجة الأرجح؟',
  'A more accurate quote because photographs do not lie','عرض أدق لأن الصور لا تكذب',false,
  'Missed neutrals, box depths and wall construction, producing scope changes and disputes mid-job','نيوترالات وأعماق علب وإنشاء جدران مفقودة، فتنشأ تغييرات نطاق ونزاعات في منتصف العمل',true,
  'A faster installation with no risk','تركيب أسرع بلا مخاطرة',false,
  'Better client satisfaction','رضا عميل أفضل',false);

SELECT pg_temp.add_q('finix-site-survey-methodology','gold',3,
  'During survey the client insists on cameras covering the street outside their gate. What is the professional handling?',
  'أثناء المسح يصر العميل على كاميرات تغطي الشارع خارج بوابته. ما التعامل الاحترافي؟',
  'Install as requested without comment','ركّب كما طُلب بلا تعليق',false,
  'Record the request, advise on privacy and signage obligations, and plan masking where coverage exceeds the boundary','سجّل الطلب وانصح بالتزامات الخصوصية واللافتات وخطط للإخفاء حيث تتجاوز التغطية الحد',true,
  'Refuse the entire camera job','ارفض عمل الكاميرات كله',false,
  'Install and let the client handle any complaint','ركّب ودع العميل يتعامل مع أي شكوى',false);

SELECT pg_temp.add_q('finix-site-survey-methodology','gold',4,
  'Two surveyors visit the same property and produce materially different equipment lists. What does this most strongly indicate?',
  'مساحان يزوران العقار نفسه وينتجان قائمتي معدات مختلفتين جوهريًا. ما الذي يشير إليه هذا بقوة؟',
  'That one surveyor is dishonest','أن أحد المساحين غير أمين',false,
  'That the survey process is not standardised enough to produce repeatable results','أن عملية المسح ليست موحدة كفاية لإنتاج نتائج قابلة للتكرار',true,
  'That the property changed between visits','أن العقار تغيّر بين الزيارتين',false,
  'That equipment lists are always subjective','أن قوائم المعدات ذاتية دائمًا',false);

SELECT pg_temp.add_q('finix-site-survey-methodology','gold',5,
  'A survey is complete and priced, but the client then adds "and make the garden lights smart too". What is the correct process?',
  'اكتمل المسح وسُعّر ثم يضيف العميل "واجعل أنوار الحديقة ذكية أيضًا". ما العملية الصحيحة؟',
  'Absorb it into the existing price to keep goodwill','استوعبها في السعر القائم حفاظًا على النية الحسنة',false,
  'Survey the addition properly, since outdoor work involves different protection, weatherproofing and cable routes, then re-quote','امسح الإضافة صحيحًا، فالعمل الخارجي يتضمن حماية ومقاومة طقس ومسارات كابلات مختلفة، ثم أعد التسعير',true,
  'Add a fixed percentage to the quote','أضف نسبة ثابتة للعرض',false,
  'Refuse any change after survey','ارفض أي تغيير بعد المسح',false);

-- ========== F04 ==========
SELECT pg_temp.add_q('finix-power-devices-protection','bronze',4,
  'What is the essential difference between an MCB and an MCCB?',
  'ما الفرق الجوهري بين القاطع المصغر والقاطع المغلف؟',
  'MCBs are only for DC circuits','القواطع المصغرة للدوائر المستمرة فقط',false,
  'MCCBs handle higher currents and often offer adjustable trip settings','القواطع المغلفة تتعامل مع تيارات أعلى وتوفر غالبًا إعدادات فصل قابلة للضبط',true,
  'MCBs are always faster','القواطع المصغرة أسرع دائمًا',false,
  'There is no practical difference','لا فرق عملي',false);

SELECT pg_temp.add_q('finix-power-devices-protection','bronze',5,
  'What does the trip curve of a circuit breaker describe?',
  'ماذا يصف منحنى فصل قاطع الدائرة؟',
  'The physical shape of the breaker','الشكل الفيزيائي للقاطع',false,
  'How quickly it trips at different multiples of its rated current','بأي سرعة يفصل عند مضاعفات مختلفة من تياره المصنّف',true,
  'Its price over time','سعره عبر الزمن',false,
  'The colour temperature of its indicator','حرارة لون مؤشره',false);

SELECT pg_temp.add_q('finix-power-devices-protection','silver',3,
  'A motor circuit trips its breaker every time the motor starts, though the motor runs fine once going. What is most likely wrong?',
  'دائرة محرك تفصل قاطعها كلما بدأ المحرك رغم أنه يعمل جيدًا بعد الدوران. ما الخطأ الأرجح؟',
  'The motor windings are shorted','ملفات المحرك مقصورة',false,
  'The breaker curve is too sensitive for the motor''s inrush current','منحنى القاطع حساس جدًا لتيار اندفاع المحرك',true,
  'The supply voltage is too low','جهد التغذية منخفض جدًا',false,
  'The motor is undersized','المحرك أصغر من اللازم',false);

SELECT pg_temp.add_q('finix-power-devices-protection','silver',4,
  'Why can a switching power supply be a better choice than a simple adapter for a control panel?',
  'لماذا قد يكون مصدر التغذية المبدّل خيارًا أفضل من محوّل بسيط للوحة تحكم؟',
  'Because it is always cheaper','لأنه أرخص دائمًا',false,
  'Because it holds a regulated output across supply variation and load change','لأنه يحافظ على خرج منظَّم عبر تغيّر التغذية وتغيّر الحمل',true,
  'Because it needs no earth connection','لأنه لا يحتاج توصيل أرضي',false,
  'Because it cannot overheat','لأنه لا يمكن أن يسخن',false);

SELECT pg_temp.add_q('finix-power-devices-protection','silver',5,
  'A relay is rated 10 A resistive but is switching a motor of 6 A. Why may it still fail early?',
  'ريلاي مصنّف ١٠ أمبير مقاوم لكنه يبدّل محركًا بست أمبير. لماذا قد يفشل مبكرًا رغم ذلك؟',
  'Because motors draw far higher inrush and the inductive break arcs the contacts','لأن المحركات تسحب اندفاعًا أعلى بكثير والقطع الحثي يقوّس التلامسات',true,
  'Because 6 A is above 10 A','لأن ستة أمبير أعلى من عشرة',false,
  'Because relays cannot switch motors at all','لأن الريليهات لا تبدّل محركات إطلاقًا',false,
  'Because the coil voltage is wrong','لأن جهد الملف خاطئ',false);

SELECT pg_temp.add_q('finix-power-devices-protection','gold',2,
  'A panel has a correctly sized breaker and a correctly sized overload relay, yet a motor burned out from a locked rotor. Which protection gap does this reveal?',
  'لوحة بها قاطع بمقاس صحيح وريلاي حمل زائد بمقاس صحيح، ومع ذلك احترق محرك من دوار مقفول. أي فجوة حماية يكشفها هذا؟',
  'No gap; this cannot happen','لا فجوة؛ هذا لا يمكن أن يحدث',false,
  'The overload may have been set above the motor''s full-load current, so it never saw the condition as an overload','قد يكون الحمل الزائد مضبوطًا فوق تيار الحمل الكامل للمحرك فلم يرَ الحالة حملًا زائدًا أبدًا',true,
  'The breaker should have been smaller than the overload','كان ينبغي أن يكون القاطع أصغر من الحمل الزائد',false,
  'Locked rotor is not an electrical fault','الدوار المقفول ليس عطلًا كهربائيًا',false);

SELECT pg_temp.add_q('finix-power-devices-protection','gold',3,
  'A technician replaces a nuisance-tripping 16 A breaker with a 32 A one and the tripping stops. Why is this dangerous?',
  'فني يستبدل قاطع ١٦ أمبير كثير الفصل بآخر ٣٢ أمبير فيتوقف الفصل. لماذا هذا خطر؟',
  'It is not dangerous if the tripping stopped','ليس خطرًا ما دام الفصل توقف',false,
  'The cable is still sized for 16 A, so it can now overheat without the breaker ever tripping','الكابل ما يزال بمقاس ١٦ أمبير فقد يسخن الآن دون أن يفصل القاطع أبدًا',true,
  'Because 32 A breakers are less reliable','لأن قواطع ٣٢ أمبير أقل موثوقية',false,
  'Because it voids the breaker warranty','لأنه يبطل ضمان القاطع',false);

SELECT pg_temp.add_q('finix-power-devices-protection','gold',4,
  'An installation has an RCD that trips intermittently, always during wet weather, with no obvious faulty appliance. Where should investigation focus?',
  'تركيب به قاطع تسرب يفصل متقطعًا دائمًا في الطقس الرطب بلا جهاز معطل واضح. أين ينبغي تركيز الفحص؟',
  'Replace the RCD immediately','استبدل قاطع التسرب فورًا',false,
  'Outdoor circuits and enclosures where moisture ingress raises earth leakage','الدوائر والحاويات الخارجية حيث يرفع دخول الرطوبة تسرب الأرضي',true,
  'The indoor lighting circuit only','دائرة الإنارة الداخلية فقط',false,
  'The consumer unit busbar','قضيب لوحة التوزيع',false);

SELECT pg_temp.add_q('finix-power-devices-protection','gold',5,
  'Why is discrimination (coordination) between an upstream and downstream protective device important?',
  'لماذا يهم التمييز (التنسيق) بين جهاز حماية علوي وآخر سفلي؟',
  'It reduces the cost of the panel','يقلل تكلفة اللوحة',false,
  'So a local fault trips only the local device, leaving the rest of the installation energised','فالعطل المحلي يفصل الجهاز المحلي وحده تاركًا بقية التركيب مغذى',true,
  'So both devices trip together for safety','فيفصل الجهازان معًا للسلامة',false,
  'So the breakers age at the same rate','فتتقادم القواطع بالمعدل نفسه',false);
