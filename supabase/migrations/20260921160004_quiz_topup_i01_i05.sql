-- Quiz top-up: I01-I05 (industrial control core), 2 per tier each.

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

-- ========== I01 Contactors & Control Logic ==========
SELECT pg_temp.add_q('finix-contactors-control-logic','bronze',4,
  'What is the function of a shading ring in an AC contactor?',
  'ما وظيفة حلقة التظليل في كونتاكتور تيار متردد؟',
  'To insulate the coil from the core','لعزل الملف عن القلب',false,
  'To maintain holding force as the AC waveform passes through zero','للحفاظ على قوة الإمساك حين تمر موجة التيار المتردد بالصفر',true,
  'To cool the contactor','لتبريد الكونتاكتور',false,
  'To limit the coil current','لتحديد تيار الملف',false);

SELECT pg_temp.add_q('finix-contactors-control-logic','bronze',5,
  'What is an auxiliary contact used for?',
  'فيم يُستخدم التلامس المساعد؟',
  'To carry the main motor current','لحمل تيار المحرك الرئيسي',false,
  'To provide low-current signalling for latching, interlocking and indication','لتوفير إشارات منخفضة التيار للإمساك والتعاشق والبيان',true,
  'To earth the contactor frame','لتأريض هيكل الكونتاكتور',false,
  'To replace the overload relay','لاستبدال ريلاي الحمل الزائد',false);

SELECT pg_temp.add_q('finix-contactors-control-logic','silver',4,
  'In a latch circuit, why must the stop button be wired in series ahead of the holding contact?',
  'في دائرة إمساك، لماذا يجب توصيل زر الإيقاف على التوالي قبل تلامس الإمساك؟',
  'To reduce the current through the button','لتقليل التيار عبر الزر',false,
  'So that pressing stop breaks the circuit regardless of the holding contact state','فيقطع ضغط الإيقاف الدائرة بغض النظر عن حالة تلامس الإمساك',true,
  'To make the start button work faster','لجعل زر البدء يعمل أسرع',false,
  'To protect the contactor coil from overvoltage','لحماية ملف الكونتاكتور من الجهد الزائد',false);

SELECT pg_temp.add_q('finix-contactors-control-logic','silver',5,
  'Why should a stop button use a normally-closed contact rather than normally-open?',
  'لماذا ينبغي أن يستخدم زر الإيقاف تلامسًا مغلقًا عاديًا لا مفتوحًا عاديًا؟',
  'Because normally-closed contacts last longer','لأن التلامسات المغلقة عاديًا تدوم أطول',false,
  'So a broken wire stops the motor instead of disabling the stop function','فالسلك المقطوع يوقف المحرك بدل تعطيل وظيفة الإيقاف',true,
  'Because it uses less current','لأنها تستهلك تيارًا أقل',false,
  'Because it is cheaper to manufacture','لأنها أرخص تصنيعًا',false);

SELECT pg_temp.add_q('finix-contactors-control-logic','gold',4,
  'A contactor buzzes loudly and its coil overheats, though the control voltage measures correct. What is the most probable cause?',
  'كونتاكتور يطن بصوت عالٍ ويسخن ملفه رغم أن جهد التحكم مقاس صحيحًا. ما السبب الأرجح؟',
  'The motor is oversized','المحرك أكبر من اللازم',false,
  'A broken shading ring or dirt preventing the armature from seating fully','حلقة تظليل مكسورة أو أوساخ تمنع الجزء المتحرك من الاستقرار كاملًا',true,
  'The supply frequency is too low','تردد التغذية منخفض جدًا',false,
  'The auxiliary contacts are welded','التلامسات المساعدة ملحومة',false);

SELECT pg_temp.add_q('finix-contactors-control-logic','gold',5,
  'A reversing starter occasionally causes a severe short circuit when direction is changed quickly. Which protection was inadequate?',
  'بادئ عكسي يسبب أحيانًا قصرًا شديدًا عند تغيير الاتجاه بسرعة. أي حماية كانت غير كافية؟',
  'The overload relay setting','ضبط ريلاي الحمل الزائد',false,
  'Mechanical and electrical interlocking between the two contactors','التعاشق الميكانيكي والكهربائي بين الكونتاكتورين',true,
  'The control transformer rating','تصنيف محول التحكم',false,
  'The indicator lamp wiring','تمديد لمبة البيان',false);

-- ========== I02 Motor Starting Methods ==========
SELECT pg_temp.add_q('finix-motor-starting-methods','bronze',4,
  'Roughly how large is the starting current of a direct-on-line induction motor compared with its full-load current?',
  'كم يبلغ تيار بدء محرك حثي يبدأ مباشرة تقريبًا مقارنة بتيار حمله الكامل؟',
  'About the same','نفسه تقريبًا',false,
  'Around six to eight times','نحو ستة إلى ثمانية أضعاف',true,
  'About half','نحو النصف',false,
  'About twenty times','نحو عشرين ضعفًا',false);

SELECT pg_temp.add_q('finix-motor-starting-methods','bronze',5,
  'What does a soft starter do that a star-delta starter does not?',
  'ما الذي يفعله البادئ الناعم ولا يفعله بادئ النجمة دلتا؟',
  'It reverses the motor','يعكس المحرك',false,
  'It ramps voltage smoothly rather than switching between two fixed steps','يرفع الجهد بسلاسة بدل التبديل بين خطوتين ثابتتين',true,
  'It eliminates the need for overload protection','يلغي الحاجة لحماية الحمل الزائد',false,
  'It increases the motor''s rated power','يزيد القدرة المصنّفة للمحرك',false);

SELECT pg_temp.add_q('finix-motor-starting-methods','silver',4,
  'A star-delta started motor struggles to reach speed before changeover and trips. What is the most likely cause?',
  'محرك يبدأ بنجمة دلتا يكافح للوصول للسرعة قبل التحويل فيفصل. ما السبب الأرجح؟',
  'The delta contactor is faulty','كونتاكتور الدلتا معطل',false,
  'The load requires more starting torque than star connection can provide','الحمل يتطلب عزم بدء أكبر مما توفره توصيلة النجمة',true,
  'The supply voltage is too high','جهد التغذية مرتفع جدًا',false,
  'The overload relay is undersized','ريلاي الحمل الزائد أصغر من اللازم',false);

SELECT pg_temp.add_q('finix-motor-starting-methods','silver',5,
  'Why is a VFD chosen over a soft starter when the process needs speed control during running?',
  'لماذا يُختار مغيّر التردد على البادئ الناعم حين تحتاج العملية تحكمًا بالسرعة أثناء التشغيل؟',
  'Because a soft starter is more expensive','لأن البادئ الناعم أغلى',false,
  'Because a soft starter only controls the start, while a VFD varies frequency continuously','لأن البادئ الناعم يتحكم بالبدء فقط بينما يغيّر مغيّر التردد التردد باستمرار',true,
  'Because a VFD needs no protection devices','لأن مغيّر التردد لا يحتاج أجهزة حماية',false,
  'Because soft starters cannot handle three-phase motors','لأن البادئات الناعمة لا تتعامل مع محركات ثلاثية الأطوار',false);

SELECT pg_temp.add_q('finix-motor-starting-methods','gold',4,
  'A star-delta starter repeatedly welds its delta contactor. Which timing error most likely explains this?',
  'بادئ نجمة دلتا يلحم كونتاكتور الدلتا مرارًا. أي خطأ توقيت يفسر هذا على الأرجح؟',
  'The star period is far too long','فترة النجمة طويلة جدًا',false,
  'Insufficient transition delay, so delta closes while the star contactor is still arcing','تأخير انتقال غير كافٍ فتغلق الدلتا وكونتاكتور النجمة ما يزال يقوّس',true,
  'The overload is set too low','الحمل الزائد مضبوط منخفضًا جدًا',false,
  'The motor is connected in reverse','المحرك موصول معكوسًا',false);

SELECT pg_temp.add_q('finix-motor-starting-methods','gold',5,
  'A client wants to reduce a large motor''s starting current, but the driven load requires high breakaway torque. Which option best fits?',
  'عميل يريد خفض تيار بدء محرك كبير لكن الحمل المُدار يتطلب عزم انفصال عاليًا. أي خيار أنسب؟',
  'Star-delta, since it always reduces current','نجمة دلتا لأنها تخفض التيار دائمًا',false,
  'A VFD or soft starter with torque control, since star-delta reduces torque drastically','مغيّر تردد أو بادئ ناعم بتحكم بالعزم لأن النجمة دلتا تخفض العزم بشدة',true,
  'Direct on line with a larger breaker','بدء مباشر بقاطع أكبر',false,
  'Reduce the motor size','قلّل حجم المحرك',false);

-- ========== I03 Motor Protection ==========
SELECT pg_temp.add_q('finix-motor-protection','bronze',4,
  'What type of fault does a thermal overload relay primarily protect against?',
  'أي نوع أعطال يحمي منه ريلاي الحمل الزائد الحراري أساسًا؟',
  'Instantaneous short circuit','قصر لحظي',false,
  'Sustained moderate overcurrent that heats the windings over time','تيار زائد معتدل مستمر يسخّن الملفات عبر الزمن',true,
  'Overvoltage','جهد زائد',false,
  'Earth leakage','تسرب أرضي',false);

SELECT pg_temp.add_q('finix-motor-protection','bronze',5,
  'Where is a thermistor located when used for motor protection?',
  'أين يوضع الثرمستور حين يُستخدم لحماية المحرك؟',
  'In the control panel next to the contactor','في لوحة التحكم بجوار الكونتاكتور',false,
  'Embedded in the motor windings','مدفونًا في ملفات المحرك',true,
  'On the supply busbar','على قضيب التغذية',false,
  'Inside the circuit breaker','داخل قاطع الدائرة',false);

SELECT pg_temp.add_q('finix-motor-protection','silver',4,
  'Why does an overload relay alone not protect a motor that is cooled by its own fan and runs at low speed on a VFD?',
  'لماذا لا يحمي ريلاي الحمل الزائد وحده محركًا يُبرَّد بمروحته ويعمل بسرعة منخفضة على مغيّر تردد؟',
  'Because VFDs do not produce current','لأن مغيّرات التردد لا تنتج تيارًا',false,
  'Because at low speed the fan cools poorly while current may still be within limits','لأن المروحة تبرّد بسوء عند السرعة المنخفضة بينما قد يبقى التيار ضمن الحدود',true,
  'Because overload relays fail on VFDs','لأن ريليهات الحمل الزائد تفشل مع مغيّرات التردد',false,
  'Because VFDs remove all heating','لأن مغيّرات التردد تزيل كل التسخين',false);

SELECT pg_temp.add_q('finix-motor-protection','silver',5,
  'A motor protection scheme has a breaker for short circuit and an overload relay. Which additional threat remains uncovered?',
  'مخطط حماية محرك به قاطع للقصر وريلاي حمل زائد. أي تهديد إضافي يبقى غير مغطى؟',
  'Nothing remains uncovered','لا شيء يبقى غير مغطى',false,
  'Supply faults such as phase loss or phase reversal','أعطال التغذية كفقد الطور أو عكس الأطوار',true,
  'Mechanical bearing wear','بلى المحامل الميكانيكي',false,
  'Cable insulation colour','لون عزل الكابل',false);

SELECT pg_temp.add_q('finix-motor-protection','gold',4,
  'A motor trips on overload every afternoon in summer but never in the morning. What should be investigated first?',
  'محرك يفصل على الحمل الزائد كل عصر في الصيف ولا يفصل صباحًا أبدًا. ما الذي ينبغي فحصه أولًا؟',
  'The motor windings are failing','ملفات المحرك تفشل',false,
  'Ambient temperature at the relay and the motor, since both derate with heat','الحرارة المحيطة عند الريلاي والمحرك فكلاهما يتناقص تصنيفه بالحرارة',true,
  'The supply frequency changes in the afternoon','تردد التغذية يتغير عصرًا',false,
  'The overload relay is the wrong brand','ريلاي الحمل الزائد بعلامة خاطئة',false);

SELECT pg_temp.add_q('finix-motor-protection','gold',5,
  'An overload relay is replaced with a higher setting because it "keeps tripping". Two months later the motor burns out. What principle was violated?',
  'يُستبدل ريلاي حمل زائد بضبط أعلى لأنه "يظل يفصل". بعد شهرين يحترق المحرك. أي مبدأ انتُهك؟',
  'Relays should always be set to maximum','ينبغي ضبط الريليهات على الأقصى دائمًا',false,
  'A protective device that trips is reporting a fault; raising the setting removes the protection rather than the cause','الجهاز الواقي الذي يفصل يبلّغ عن عطل، ورفع الضبط يزيل الحماية لا السبب',true,
  'Overload relays should be removed on large motors','ينبغي إزالة ريليهات الحمل الزائد في المحركات الكبيرة',false,
  'The breaker should have been changed instead','كان ينبغي تغيير القاطع بدلًا منه',false);

-- ========== I04 Timers & Timing Functions ==========
SELECT pg_temp.add_q('finix-timers-timing-functions','bronze',4,
  'What does an ON-delay timer do?',
  'ماذا يفعل مؤقت تأخير التشغيل؟',
  'It switches immediately then turns off after a delay','يبدّل فورًا ثم يطفئ بعد تأخير',false,
  'It waits a set time after being energised before switching its output','ينتظر زمنًا محددًا بعد تغذيته قبل تبديل خرجه',true,
  'It produces a single pulse','ينتج نبضة واحدة',false,
  'It repeats on and off continuously','يكرر التشغيل والإطفاء باستمرار',false);

SELECT pg_temp.add_q('finix-timers-timing-functions','bronze',5,
  'Which timing function keeps an output energised for a fixed period after the trigger is removed?',
  'أي وظيفة توقيت تبقي الخرج مغذى لفترة ثابتة بعد إزالة المشغّل؟',
  'ON-delay','تأخير التشغيل',false,
  'OFF-delay','تأخير الإطفاء',true,
  'Repeat cycle','دورة متكررة',false,
  'Instantaneous','لحظي',false);

SELECT pg_temp.add_q('finix-timers-timing-functions','silver',4,
  'A conveyor must run for thirty seconds after the operator releases the button, to clear the line. Which timing function is correct?',
  'سير يجب أن يعمل ثلاثين ثانية بعد ترك المشغّل الزر لتفريغ الخط. أي وظيفة توقيت صحيحة؟',
  'ON-delay','تأخير التشغيل',false,
  'OFF-delay','تأخير الإطفاء',true,
  'One-shot pulse','نبضة واحدة',false,
  'Repeat cycle','دورة متكررة',false);

SELECT pg_temp.add_q('finix-timers-timing-functions','silver',5,
  'Why does a star-delta starter require a transition delay between the two contactors?',
  'لماذا يتطلب بادئ النجمة دلتا تأخير انتقال بين الكونتاكتورين؟',
  'To allow the motor to cool','للسماح للمحرك بالتبريد',false,
  'To let the star contactor arc extinguish before delta closes, preventing a phase-to-phase short','للسماح بإطفاء قوس كونتاكتور النجمة قبل إغلاق الدلتا منعًا لقصر بين الأطوار',true,
  'To reduce the overload relay setting','لخفض ضبط ريلاي الحمل الزائد',false,
  'To let the operator check the direction','ليفحص المشغّل الاتجاه',false);

SELECT pg_temp.add_q('finix-timers-timing-functions','gold',4,
  'A timed process drifts out of sequence only after long continuous running. Which cause fits best?',
  'عملية مؤقتة تخرج عن التسلسل فقط بعد تشغيل مستمر طويل. أي سبب يناسب أكثر؟',
  'The timer was set to the wrong function','ضُبط المؤقت على الوظيفة الخطأ',false,
  'Thermal drift in an analogue timer, or accumulated error across repeated cycles','انجراف حراري في مؤقت تناظري أو خطأ متراكم عبر دورات متكررة',true,
  'The contactor coil voltage is wrong','جهد ملف الكونتاكتور خاطئ',false,
  'The motor is oversized','المحرك أكبر من اللازم',false);

SELECT pg_temp.add_q('finix-timers-timing-functions','gold',5,
  'When converting hardwired timers to a smart controller, which function should NOT be moved into software?',
  'عند تحويل مؤقتات سلكية لمتحكم ذكي، أي وظيفة ينبغي ألا تُنقل للبرمجيات؟',
  'The lighting schedule','جدول الإنارة',false,
  'Safety-critical interlock timing such as star-delta transition','توقيت التعاشق الحرج للسلامة كانتقال النجمة دلتا',true,
  'The production counter','عداد الإنتاج',false,
  'The remote status display','عرض الحالة عن بُعد',false);

-- ========== I05 Sensing Relays ==========
SELECT pg_temp.add_q('finix-sensing-relays','bronze',4,
  'What is hysteresis in a sensing relay?',
  'ما التخلفية في ريلاي استشعار؟',
  'The delay before the relay powers up','التأخير قبل تشغيل الريلاي',false,
  'The difference between the switch-on and switch-off thresholds','الفرق بين عتبتي التشغيل والإطفاء',true,
  'The maximum current it can switch','أقصى تيار يستطيع تبديله',false,
  'The coil resistance','مقاومة الملف',false);

SELECT pg_temp.add_q('finix-sensing-relays','bronze',5,
  'Why are conductive level probes excited with AC rather than DC?',
  'لماذا تُغذى مجسات المستوى الموصّلة بتيار متردد لا مستمر؟',
  'Because AC is cheaper to generate','لأن التيار المتردد أرخص توليدًا',false,
  'Because DC causes electrolysis that corrodes the probes','لأن التيار المستمر يسبب تحليلًا كهربائيًا يآكل المجسات',true,
  'Because AC travels further in water','لأن التيار المتردد ينتقل أبعد في الماء',false,
  'Because DC cannot pass through liquid','لأن التيار المستمر لا يمر في السائل',false);

SELECT pg_temp.add_q('finix-sensing-relays','silver',4,
  'A street lighting photocell switches the lamps on and off rapidly all night. What is the most likely cause?',
  'خلية ضوئية لإنارة شارع تشغّل المصابيح وتطفئها بسرعة طوال الليل. ما السبب الأرجح؟',
  'The lamps are faulty','المصابيح معطلة',false,
  'The photocell is positioned where it sees the light it controls, creating a feedback loop','الخلية موضوعة حيث ترى الضوء الذي تتحكم به فتنشأ حلقة تغذية راجعة',true,
  'The supply voltage is too high','جهد التغذية مرتفع جدًا',false,
  'The relay contacts are too large','تلامسات الريلاي كبيرة جدًا',false);

SELECT pg_temp.add_q('finix-sensing-relays','silver',5,
  'Why does a duty/standby pump arrangement alternate which pump starts first?',
  'لماذا يبادل ترتيب المضخة العاملة/الاحتياطية أي مضخة تبدأ أولًا؟',
  'To reduce the electricity bill','لخفض فاتورة الكهرباء',false,
  'To equalise running hours and confirm the standby pump still works','لمعادلة ساعات التشغيل والتأكد أن المضخة الاحتياطية ما تزال تعمل',true,
  'Because pumps cannot run twice in a row','لأن المضخات لا تستطيع العمل مرتين متتاليتين',false,
  'To reduce the water pressure','لخفض ضغط الماء',false);

SELECT pg_temp.add_q('finix-sensing-relays','gold',4,
  'A borehole pump with dry-run protection keeps restarting and stopping repeatedly during low-water periods. Which feature is missing or misconfigured?',
  'مضخة بئر بحماية التشغيل الجاف تظل تعيد التشغيل والتوقف مرارًا في فترات انخفاض الماء. أي ميزة مفقودة أو سيئة الضبط؟',
  'The overload relay','ريلاي الحمل الزائد',false,
  'A recovery lockout timer that holds the pump off long enough for the well to refill','مؤقت قفل استرداد يبقي المضخة مطفأة كفاية ليعاد امتلاء البئر',true,
  'The level probe excitation voltage','جهد تغذية مجس المستوى',false,
  'The pump impeller size','حجم دافعة المضخة',false);

SELECT pg_temp.add_q('finix-sensing-relays','gold',5,
  'A tank level control chatters, rapidly switching the pump at the fill point. Which adjustment is the correct first remedy?',
  'تحكم مستوى خزان يرفرف فيبدّل المضخة بسرعة عند نقطة الامتلاء. أي تعديل هو العلاج الأول الصحيح؟',
  'Increase the pump size','زد حجم المضخة',false,
  'Widen the differential between the start and stop levels','وسّع التفاضل بين مستويي البدء والتوقف',true,
  'Lower the supply voltage','اخفض جهد التغذية',false,
  'Replace the contactor with a larger one','استبدل الكونتاكتور بأكبر',false);
