-- Quiz top-up: I06, I07 (industrial), M11, M12 (SONOFF).

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

-- ========== I06 Voltage & Phase Protection ==========
SELECT pg_temp.add_q('finix-voltage-phase-protection','bronze',4,
  'What happens to a three-phase motor that loses one phase while running?',
  'ماذا يحدث لمحرك ثلاثي الأطوار يفقد طورًا أثناء التشغيل؟',
  'It stops immediately with no damage','يتوقف فورًا بلا ضرر',false,
  'It keeps turning but draws much higher current in the remaining phases','يظل يدور لكنه يسحب تيارًا أعلى بكثير في الأطوار المتبقية',true,
  'It speeds up','تزداد سرعته',false,
  'It reverses direction','ينعكس اتجاهه',false);

SELECT pg_temp.add_q('finix-voltage-phase-protection','bronze',5,
  'Why does phase sequence matter for a three-phase motor?',
  'لماذا يهم تتابع الأطوار لمحرك ثلاثي الأطوار؟',
  'It determines the motor''s speed','يحدد سرعة المحرك',false,
  'It determines the direction of rotation','يحدد اتجاه الدوران',true,
  'It determines the supply frequency','يحدد تردد التغذية',false,
  'It has no practical effect','لا أثر عملي له',false);

SELECT pg_temp.add_q('finix-voltage-phase-protection','silver',3,
  'Why can an overload relay fail to protect a motor during a single-phasing event?',
  'لماذا قد يفشل ريلاي الحمل الزائد في حماية محرك أثناء حدث فقد طور؟',
  'Because overload relays only work on DC','لأن ريليهات الحمل الزائد تعمل على المستمر فقط',false,
  'Because the current rise may stay below its trip setting while windings still overheat','لأن ارتفاع التيار قد يبقى تحت ضبط فصله بينما تسخن الملفات مع ذلك',true,
  'Because it responds only to voltage','لأنه يستجيب للجهد فقط',false,
  'Because phase loss reduces current','لأن فقد الطور يخفض التيار',false);

SELECT pg_temp.add_q('finix-voltage-phase-protection','silver',4,
  'After maintenance on a supply transformer, a pump runs backwards. What should be checked?',
  'بعد صيانة محول تغذية تعمل مضخة بالعكس. ما الذي ينبغي فحصه؟',
  'The pump impeller','دافعة المضخة',false,
  'The phase sequence, which may have been swapped during reconnection','تتابع الأطوار الذي قد يكون بُدّل أثناء إعادة التوصيل',true,
  'The overload relay setting','ضبط ريلاي الحمل الزائد',false,
  'The motor bearings','محامل المحرك',false);

SELECT pg_temp.add_q('finix-voltage-phase-protection','silver',5,
  'Why is an under-voltage condition dangerous for a running motor?',
  'لماذا تكون حالة انخفاض الجهد خطرة على محرك يعمل؟',
  'It causes the motor to overspeed','تسبب زيادة سرعة المحرك',false,
  'The motor draws more current to maintain torque, which overheats the windings','يسحب المحرك تيارًا أكبر للحفاظ على العزم فتسخن الملفات',true,
  'It reduces current and causes no harm','تخفض التيار ولا تسبب ضررًا',false,
  'It only affects the indicator lamps','تؤثر على لمبات البيان فقط',false);

SELECT pg_temp.add_q('finix-voltage-phase-protection','gold',3,
  'A site with a generator changeover reports motors failing shortly after every power cut. What should be examined?',
  'موقع بتحويل مولّد يبلّغ عن فشل محركات بعد كل انقطاع كهرباء بقليل. ما الذي ينبغي فحصه؟',
  'The motors are simply old','المحركات قديمة ببساطة',false,
  'Whether the changeover preserves phase sequence and whether restart is delayed until supply is stable','هل يحافظ التحويل على تتابع الأطوار وهل يُؤخر إعادة التشغيل حتى تستقر التغذية',true,
  'The generator fuel quality','جودة وقود المولّد',false,
  'The lighting circuits','دوائر الإنارة',false);

SELECT pg_temp.add_q('finix-voltage-phase-protection','gold',4,
  'Why should a protection relay include a restart delay after supply is restored?',
  'لماذا ينبغي أن يتضمن ريلاي حماية تأخير إعادة تشغيل بعد استعادة التغذية؟',
  'To save electricity','لتوفير الكهرباء',false,
  'To avoid all motors restarting simultaneously and to let supply and plant stabilise','لتجنب إعادة تشغيل كل المحركات في آن وللسماح للتغذية والمنشأة بالاستقرار',true,
  'To let the operator leave the room','ليغادر المشغّل الغرفة',false,
  'Because relays cannot switch quickly','لأن الريليهات لا تستطيع التبديل بسرعة',false);

SELECT pg_temp.add_q('finix-voltage-phase-protection','gold',5,
  'A protection relay is installed but a client disables it because it "trips too often" during brownouts. What is the professional response?',
  'رُكّب ريلاي حماية لكن العميل يعطّله لأنه "يفصل كثيرًا" أثناء هبوط الجهد. ما الاستجابة الاحترافية؟',
  'Agree and leave it disabled','وافق واتركه معطلًا',false,
  'Explain that the trips are evidence of a genuine supply problem, and address the supply or set correct thresholds rather than removing protection','اشرح أن الفصل دليل على مشكلة تغذية حقيقية وعالج التغذية أو اضبط عتبات صحيحة بدل إزالة الحماية',true,
  'Replace it with a larger relay','استبدله بريلاي أكبر',false,
  'Disable only the under-voltage element','عطّل عنصر انخفاض الجهد فقط',false);

-- ========== I07 Panel Building & Fault-Finding ==========
SELECT pg_temp.add_q('finix-panel-building-faultfinding','bronze',3,
  'Why are power and control wiring separated within a panel?',
  'لماذا يُفصل تمديد القدرة عن تمديد التحكم داخل لوحة؟',
  'Only for visual neatness','للترتيب البصري فقط',false,
  'To reduce induced interference on control circuits and make the panel safer to work on','لتقليل التداخل المستحث على دوائر التحكم وجعل العمل باللوحة أأمن',true,
  'Because regulations forbid them touching','لأن اللوائح تمنع تلامسهما',false,
  'To reduce the cost of cable','لخفض تكلفة الكابلات',false);

SELECT pg_temp.add_q('finix-panel-building-faultfinding','bronze',4,
  'What is the purpose of ferrule or wire numbering in a control panel?',
  'ما الغرض من ترقيم الأسلاك في لوحة تحكم؟',
  'To make the panel look professional','لجعل اللوحة تبدو احترافية',false,
  'To let any technician trace a conductor against the drawing without tracing it physically','ليتتبع أي فني موصّلًا مقابل الرسم دون تتبعه فيزيائيًا',true,
  'To indicate the cable manufacturer','لبيان مصنّع الكابل',false,
  'To record the installation date','لتسجيل تاريخ التركيب',false);

SELECT pg_temp.add_q('finix-panel-building-faultfinding','bronze',5,
  'Why must every panel have a properly bonded earth connection?',
  'لماذا يجب أن يكون لكل لوحة توصيل أرضي مربوط صحيحًا؟',
  'To improve signal quality only','لتحسين جودة الإشارة فقط',false,
  'So a fault to the enclosure carries current to earth and operates the protective device','فالعطل للحاوية يحمل تيارًا للأرض ويشغّل جهاز الحماية',true,
  'To reduce the panel temperature','لخفض حرارة اللوحة',false,
  'To meet colour coding rules','لتلبية قواعد ترميز الألوان',false);

SELECT pg_temp.add_q('finix-panel-building-faultfinding','silver',3,
  'A control circuit works when tested with the panel door open but fails when closed. What should be suspected?',
  'دائرة تحكم تعمل عند الاختبار وباب اللوحة مفتوح وتفشل عند إغلاقه. بماذا ينبغي الاشتباه؟',
  'The control transformer is undersized','محول التحكم أصغر من اللازم',false,
  'A trapped or chafed conductor, or a door-mounted device whose wiring is strained when the door closes','موصّل محشور أو متآكل أو جهاز مركّب على الباب يُجهد تمديده عند الإغلاق',true,
  'The contactor coil is wrong','ملف الكونتاكتور خاطئ',false,
  'The panel is too small','اللوحة صغيرة جدًا',false);

SELECT pg_temp.add_q('finix-panel-building-faultfinding','silver',4,
  'When several devices in a panel fail at once, what should the technician look for first?',
  'حين تفشل عدة أجهزة في لوحة دفعة واحدة، ما الذي ينبغي أن يبحث عنه الفني أولًا؟',
  'Replace each device in turn','استبدل كل جهاز بالدور',false,
  'What they share, such as a common supply, fuse or control transformer','ما يتشاركونه كتغذية مشتركة أو فيوز أو محول تحكم',true,
  'The panel manufacturer','مصنّع اللوحة',false,
  'The ambient humidity','الرطوبة المحيطة',false);

SELECT pg_temp.add_q('finix-panel-building-faultfinding','silver',5,
  'Why should a panel drawing be updated whenever a modification is made?',
  'لماذا ينبغي تحديث رسم اللوحة كلما أُجري تعديل؟',
  'Because regulations require quarterly updates','لأن اللوائح تتطلب تحديثات ربعية',false,
  'Because an inaccurate drawing sends the next technician down a wrong path and lengthens every future fault','لأن الرسم غير الدقيق يرسل الفني التالي لمسار خاطئ ويطيل كل عطل مستقبلي',true,
  'To increase the value of the panel','لرفع قيمة اللوحة',false,
  'Because drawings expire','لأن الرسوم تنتهي صلاحيتها',false);

SELECT pg_temp.add_q('finix-panel-building-faultfinding','gold',4,
  'A technician finds a blown fuse, replaces it, and it blows again immediately. What is the correct next step?',
  'فني يجد فيوزًا محروقًا فيستبدله فيحترق فورًا مرة أخرى. ما الخطوة التالية الصحيحة؟',
  'Fit a larger fuse to hold','ركّب فيوزًا أكبر ليصمد',false,
  'Stop replacing fuses and find the fault, since the fuse is reporting a real short or overload','توقف عن استبدال الفيوزات وجد العطل، فالفيوز يبلّغ عن قصر أو حمل زائد حقيقي',true,
  'Replace the contactor','استبدل الكونتاكتور',false,
  'Increase the control voltage','ارفع جهد التحكم',false);

SELECT pg_temp.add_q('finix-panel-building-faultfinding','gold',5,
  'A panel has been modified by several technicians over years and faults now take much longer to diagnose. What is the root problem?',
  'لوحة عُدّلت بأيدي عدة فنيين عبر سنوات وصارت الأعطال تستغرق وقتًا أطول بكثير للتشخيص. ما المشكلة الجذرية؟',
  'The panel is simply old','اللوحة قديمة ببساطة',false,
  'Undocumented modifications, so the drawing no longer describes the panel that exists','تعديلات غير موثقة فلم يعد الرسم يصف اللوحة الموجودة',true,
  'The contactors need replacing','الكونتاكتورات تحتاج استبدالًا',false,
  'The panel needs repainting','اللوحة تحتاج إعادة دهان',false);

-- ========== M11 SONOFF Ecosystem Fundamentals ==========
SELECT pg_temp.add_q('sonoff-ecosystem-fundamentals','bronze',3,
  'Which factor most determines whether a device should use Wi-Fi or Zigbee?',
  'أي عامل يحدد أكثر إن كان ينبغي أن يستخدم جهاز Wi-Fi أم Zigbee؟',
  'The colour of the device','لون الجهاز',false,
  'Whether it is mains-powered and how many devices the site will hold','هل هو مغذى من الشبكة وكم جهازًا سيحمل الموقع',true,
  'The brand of the router','علامة الراوتر',false,
  'The size of the room','حجم الغرفة',false);

SELECT pg_temp.add_q('sonoff-ecosystem-fundamentals','bronze',4,
  'Why should the client own the platform account rather than the installer?',
  'لماذا ينبغي أن يملك العميل حساب المنصة لا الفني؟',
  'Because installers cannot create accounts','لأن الفنيين لا يستطيعون إنشاء حسابات',false,
  'So the client keeps control and can recover access independently of the installer','فيحتفظ العميل بالسيطرة ويستطيع استرداد الوصول باستقلال عن الفني',true,
  'Because accounts expire annually','لأن الحسابات تنتهي سنويًا',false,
  'To reduce the subscription cost','لخفض تكلفة الاشتراك',false);

SELECT pg_temp.add_q('sonoff-ecosystem-fundamentals','bronze',5,
  'What is the role of a gateway in a Zigbee installation?',
  'ما دور البوابة في تركيب Zigbee؟',
  'It supplies mains power to the devices','تغذي الأجهزة بطاقة الشبكة',false,
  'It forms the Zigbee network and bridges it to the IP network','تكوّن شبكة Zigbee وتجسرها لشبكة IP',true,
  'It replaces the need for a router','تغني عن الراوتر',false,
  'It stores the client''s automations offline only','تخزن أتمتة العميل دون اتصال فقط',false);

SELECT pg_temp.add_q('sonoff-ecosystem-fundamentals','silver',3,
  'A property will have around sixty devices. Why is a Wi-Fi-only design a poor choice?',
  'عقار سيضم نحو ستين جهازًا. لماذا يكون تصميم Wi-Fi فقط خيارًا رديئًا؟',
  'Wi-Fi devices are always slower','أجهزة Wi-Fi أبطأ دائمًا',false,
  'Consumer routers struggle with that many clients and each device adds load to one access point','الراوترات الاستهلاكية تكافح مع هذا العدد وكل جهاز يضيف حملًا على نقطة وصول واحدة',true,
  'Wi-Fi cannot control lighting','Wi-Fi لا يستطيع التحكم بالإنارة',false,
  'Wi-Fi devices cannot be automated','أجهزة Wi-Fi لا يمكن أتمتتها',false);

SELECT pg_temp.add_q('sonoff-ecosystem-fundamentals','silver',4,
  'Why is a battery-powered sensor unable to improve mesh coverage?',
  'لماذا لا يستطيع حساس يعمل ببطارية تحسين تغطية الشبكة الشبكية؟',
  'Because its radio is weaker by design','لأن راديوه أضعف بالتصميم',false,
  'Because it sleeps to save battery and therefore cannot relay traffic for others','لأنه ينام لتوفير البطارية فلا يستطيع ترحيل مرور للآخرين',true,
  'Because it uses a different frequency','لأنه يستخدم ترددًا مختلفًا',false,
  'Because sensors are not part of the mesh','لأن الحساسات ليست جزءًا من الشبكة',false);

SELECT pg_temp.add_q('sonoff-ecosystem-fundamentals','silver',5,
  'A client wants voice control with Apple devices. What must be confirmed during specification?',
  'عميل يريد تحكمًا صوتيًا بأجهزة Apple. ما الذي يجب تأكيده أثناء التحديد؟',
  'That the devices are the same colour','أن الأجهزة بنفس اللون',false,
  'That the devices support HomeKit or Matter, and that a resident home hub exists','أن الأجهزة تدعم HomeKit أو Matter وأن بوابة منزل مقيمة موجودة',true,
  'That the client has a newer phone','أن لدى العميل هاتفًا أحدث',false,
  'That all devices use Wi-Fi','أن كل الأجهزة تستخدم Wi-Fi',false);

SELECT pg_temp.add_q('sonoff-ecosystem-fundamentals','gold',2,
  'A client insists on the cheapest possible devices for a rental property they will not maintain. What is the professional recommendation?',
  'عميل يصر على أرخص أجهزة ممكنة لعقار إيجار لن يصونه. ما التوصية الاحترافية؟',
  'Supply the cheapest devices as requested with no comment','ورّد أرخص الأجهزة كما طُلب بلا تعليق',false,
  'Prioritise devices with reliable physical controls and minimal maintenance, explaining that unmaintained cheap devices generate call-outs','أعطِ الأولوية لأجهزة بتحكمات فيزيائية موثوقة وصيانة أدنى، موضحًا أن الأجهزة الرخيصة غير المصونة تولّد استدعاءات',true,
  'Refuse the job entirely','ارفض العمل كليًا',false,
  'Install only battery devices','ركّب أجهزة بطاريات فقط',false);

SELECT pg_temp.add_q('sonoff-ecosystem-fundamentals','gold',3,
  'Why is it professionally risky to build an installation entirely around one vendor''s cloud service?',
  'لماذا يكون بناء تركيب كاملًا حول خدمة سحابية لمورّد واحد مخاطرة مهنية؟',
  'Because cloud services are always slow','لأن الخدمات السحابية بطيئة دائمًا',false,
  'Because a change in that service, pricing or ownership degrades the client''s working system with no migration path','لأن تغيّرًا في تلك الخدمة أو تسعيرها أو ملكيتها يُدهور نظام العميل العامل بلا مسار هجرة',true,
  'Because clouds cannot be encrypted','لأن السحابات لا يمكن تشفيرها',false,
  'Because it needs a faster router','لأنه يحتاج راوترًا أسرع',false);

SELECT pg_temp.add_q('sonoff-ecosystem-fundamentals','gold',4,
  'A specification lists devices whose automations must run during internet outages. Which design follows?',
  'مواصفة تدرج أجهزة يجب أن تعمل أتمتتها أثناء انقطاع الإنترنت. أي تصميم يتبع؟',
  'Cloud automations with a faster internet package','أتمتة سحابية بباقة إنترنت أسرع',false,
  'Local automations executed at the gateway or hub, not in the cloud','أتمتة محلية تُنفَّذ عند البوابة أو المحور لا في السحابة',true,
  'Battery backup for the router only','بطارية احتياطية للراوتر فقط',false,
  'Manual operation only','تشغيل يدوي فقط',false);

SELECT pg_temp.add_q('sonoff-ecosystem-fundamentals','gold',5,
  'A client asks why their neighbour''s identical devices perform worse. Both homes are similar size. What is the most likely differentiator?',
  'عميل يسأل لماذا تؤدي أجهزة جاره المتطابقة أداءً أسوأ. البيتان متشابهان حجمًا. ما العامل المميز الأرجح؟',
  'The neighbour bought counterfeit devices','اشترى الجار أجهزة مقلدة',false,
  'Device placement, the number of mains-powered routers, and channel planning against Wi-Fi','موضع الأجهزة وعدد الموجّهات المغذاة وتخطيط القنوات مقابل Wi-Fi',true,
  'The neighbour''s electricity supply','تغذية الجار الكهربائية',false,
  'The age of the devices','عمر الأجهزة',false);

-- ========== M12 Professional Installation ==========
SELECT pg_temp.add_q('sonoff-professional-installation','bronze',3,
  'What must be verified before installing a smart switch in an existing switch box?',
  'ما الذي يجب التحقق منه قبل تركيب مفتاح ذكي في علبة مفتاح قائمة؟',
  'The colour of the faceplate','لون الوجه',false,
  'Presence of a neutral, adequate box depth, and load within the device rating','وجود نيوترال وعمق علبة كافٍ وحمل ضمن تصنيف الجهاز',true,
  'The brand of the old switch','علامة المفتاح القديم',false,
  'The room temperature','حرارة الغرفة',false);

SELECT pg_temp.add_q('sonoff-professional-installation','bronze',4,
  'What is the correct sequence before working on a circuit?',
  'ما التسلسل الصحيح قبل العمل على دائرة؟',
  'Switch off and begin work immediately','أطفئ وابدأ العمل فورًا',false,
  'Isolate, lock off, then prove the tester, test the circuit dead, and prove the tester again','اعزل واقفل ثم أثبت جهاز الفحص واختبر انعدام الجهد ثم أثبت الجهاز ثانية',true,
  'Test with a screwdriver lamp only','افحص بلمبة مفك فقط',false,
  'Ask the client if the power is off','اسأل العميل إن كانت الكهرباء مفصولة',false);

SELECT pg_temp.add_q('sonoff-professional-installation','bronze',5,
  'Why should devices be named by room during commissioning?',
  'لماذا ينبغي تسمية الأجهزة بالغرفة أثناء التشغيل؟',
  'To make the installation look professional only','لجعل التركيب يبدو احترافيًا فقط',false,
  'Because voice control and automation both depend on names matching how the household speaks','لأن التحكم الصوتي والأتمتة يعتمدان على مطابقة الأسماء لكيف تتحدث الأسرة',true,
  'Because devices refuse to pair without names','لأن الأجهزة ترفض الإقران بلا أسماء',false,
  'To satisfy the warranty','لتلبية الضمان',false);

SELECT pg_temp.add_q('sonoff-professional-installation','silver',3,
  'A smart switch is installed but the client reports the light cannot be switched during a network outage. What was done wrong?',
  'رُكّب مفتاح ذكي لكن العميل يبلّغ أن المصباح لا يمكن تبديله أثناء انقطاع الشبكة. ما الخطأ الذي ارتُكب؟',
  'Nothing; this is normal for smart switches','لا شيء؛ هذا طبيعي للمفاتيح الذكية',false,
  'The physical control path was not preserved or verified during commissioning','لم يُحفظ مسار التحكم الفيزيائي أو يُتحقق منه أثناء التشغيل',true,
  'The wrong colour faceplate was used','استُخدم وجه بلون خاطئ',false,
  'The device needs a firmware update','الجهاز يحتاج تحديث برنامج',false);

SELECT pg_temp.add_q('sonoff-professional-installation','silver',4,
  'Why should a multi-gang smart switch have its total load checked, not just per-gang loads?',
  'لماذا ينبغي فحص الحمل الكلي لمفتاح ذكي متعدد المفاتيح لا أحمال كل مفتاح فقط؟',
  'Because each gang is independent electrically','لأن كل مفتاح مستقل كهربائيًا',false,
  'Because the module has a combined rating usually lower than the sum of the individual ratings','لأن للوحدة تصنيفًا مجمّعًا أقل عادة من مجموع التصنيفات الفردية',true,
  'Because gangs share the same lamp','لأن المفاتيح تتشارك المصباح نفسه',false,
  'Because the neutral cannot be shared','لأن النيوترال لا يمكن مشاركته',false);

SELECT pg_temp.add_q('sonoff-professional-installation','silver',5,
  'Why should testing be completed before the faceplate is refitted and furniture replaced?',
  'لماذا ينبغي إتمام الاختبار قبل إعادة تركيب الوجه وإرجاع الأثاث؟',
  'To save time on paperwork','لتوفير وقت الأوراق',false,
  'Because a fault found afterwards turns a short fix into a lengthy rework','لأن عطلًا يُكتشف بعدها يحوّل إصلاحًا قصيرًا لإعادة عمل طويلة',true,
  'Because faceplates are difficult to remove','لأن الوجوه صعبة الفك',false,
  'Because the client prefers to watch','لأن العميل يفضل المشاهدة',false);

SELECT pg_temp.add_q('sonoff-professional-installation','gold',2,
  'A switch box contains a conductor that looks like a neutral but is actually a switch return from another circuit. What is the consequence of using it?',
  'علبة مفتاح تحوي موصّلًا يبدو نيوترالًا لكنه فعلًا عائد مفتاح من دائرة أخرى. ما نتيجة استخدامه؟',
  'The device will simply not power on','الجهاز لن يعمل ببساطة',false,
  'Unpredictable behaviour that looks like a faulty device, plus a potentially dangerous cross-circuit connection','سلوك غير متوقع يبدو كجهاز معطل مع وصلة عابرة للدوائر قد تكون خطرة',true,
  'Improved performance','أداء محسّن',false,
  'No effect at all','بلا أثر إطلاقًا',false);

SELECT pg_temp.add_q('sonoff-professional-installation','gold',3,
  'A technician relies on cable colour alone to identify conductors in an old property. Why is this unsafe?',
  'فني يعتمد على لون الكابل وحده لتعريف الموصّلات في عقار قديم. لماذا هذا غير آمن؟',
  'Because colours fade over time only','لأن الألوان تبهت مع الزمن فقط',false,
  'Because colour conventions vary by era and by previous modifications, so only testing confirms function','لأن أعراف الألوان تتباين بالحقبة والتعديلات السابقة فالاختبار وحده يؤكد الوظيفة',true,
  'Because old cables have no colours','لأن الكابلات القديمة بلا ألوان',false,
  'Because colour is only for aesthetics','لأن اللون للجماليات فقط',false);

SELECT pg_temp.add_q('sonoff-professional-installation','gold',4,
  'A client complains a newly installed device "works sometimes". The device is mounted inside a metal enclosure. What is the likely issue?',
  'عميل يشكو أن جهازًا رُكّب حديثًا "يعمل أحيانًا". الجهاز مركّب داخل حاوية معدنية. ما المشكلة المرجحة؟',
  'The device firmware is corrupt','برنامج الجهاز تالف',false,
  'The metal enclosure is shielding the radio, so link quality is marginal','الحاوية المعدنية تحجب الراديو فجودة الوصلة حدية',true,
  'The device is faulty and needs replacing','الجهاز معطل ويحتاج استبدالًا',false,
  'The circuit is overloaded','الدائرة محمّلة زائدًا',false);

SELECT pg_temp.add_q('sonoff-professional-installation','gold',5,
  'Two identical devices are installed the same way; one works reliably and the other does not. What is the most systematic first step?',
  'جهازان متطابقان رُكّبا بالطريقة نفسها؛ أحدهما يعمل بموثوقية والآخر لا. ما الخطوة الأولى الأكثر منهجية؟',
  'Replace the failing device immediately','استبدل الجهاز الفاشل فورًا',false,
  'Compare their link quality and physical surroundings, since identical devices differ mainly by position','قارن جودة وصلتيهما ومحيطهما الفيزيائي، فالأجهزة المتطابقة تختلف أساسًا بالموضع',true,
  'Reset the entire network','صفّر الشبكة كلها',false,
  'Update the gateway firmware','حدّث برنامج البوابة',false);
