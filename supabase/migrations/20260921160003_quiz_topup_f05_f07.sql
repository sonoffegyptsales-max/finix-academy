-- Quiz top-up: F05 (networking), F06 (mesh/ecosystems), F07 (Alpha Control).

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

-- ========== F05 ==========
SELECT pg_temp.add_q('finix-networking-ip-protocols','bronze',4,
  'What does DHCP do on a home network?',
  'ماذا يفعل بروتوكول DHCP في شبكة منزلية؟',
  'It encrypts all traffic','يشفّر كل المرور',false,
  'It automatically assigns IP addresses to devices that join','يسند عناوين IP تلقائيًا للأجهزة التي تنضم',true,
  'It blocks unknown devices','يحجب الأجهزة المجهولة',false,
  'It converts Wi-Fi to Ethernet','يحوّل Wi-Fi إلى إيثرنت',false);

SELECT pg_temp.add_q('finix-networking-ip-protocols','bronze',5,
  'Which address range is a private IP range?',
  'أي نطاق عناوين يُعد نطاق IP خاصًا؟',
  '8.8.8.0 to 8.8.8.255','٨٫٨٫٨٫٠ إلى ٨٫٨٫٨٫٢٥٥',false,
  '192.168.0.0 to 192.168.255.255','١٩٢٫١٦٨٫٠٫٠ إلى ١٩٢٫١٦٨٫٢٥٥٫٢٥٥',true,
  '1.1.1.0 to 1.1.1.255','١٫١٫١٫٠ إلى ١٫١٫١٫٢٥٥',false,
  '200.100.50.0 to 200.100.50.255','٢٠٠٫١٠٠٫٥٠٫٠ إلى ٢٠٠٫١٠٠٫٥٠٫٢٥٥',false);

SELECT pg_temp.add_q('finix-networking-ip-protocols','silver',3,
  'A gateway loses connection every few days and returns after a router restart. Which configuration change most likely prevents it?',
  'بوابة تفقد الاتصال كل بضعة أيام وتعود بعد إعادة تشغيل الراوتر. أي تغيير إعداد يمنع ذلك على الأرجح؟',
  'Changing the Wi-Fi password','تغيير كلمة Wi-Fi',false,
  'Assigning the gateway a static or DHCP-reserved IP address','إسناد عنوان IP ثابت أو محجوز بـ DHCP للبوابة',true,
  'Disabling the firewall entirely','تعطيل الجدار الناري تمامًا',false,
  'Moving the router to another room','نقل الراوتر لغرفة أخرى',false);

SELECT pg_temp.add_q('finix-networking-ip-protocols','silver',4,
  'Why does a device on a private IP address still reach the internet?',
  'لماذا يصل جهاز بعنوان IP خاص للإنترنت رغم ذلك؟',
  'Because private addresses are routable on the internet','لأن العناوين الخاصة قابلة للتوجيه على الإنترنت',false,
  'Because NAT on the router translates it to the public address','لأن NAT في الراوتر يترجمه للعنوان العام',true,
  'Because DHCP forwards the traffic','لأن DHCP يمرر المرور',false,
  'Because the ISP assigns two addresses per device','لأن مزود الخدمة يسند عنوانين لكل جهاز',false);

SELECT pg_temp.add_q('finix-networking-ip-protocols','silver',5,
  'Two devices on a network intermittently lose connectivity and the router logs an address conflict. What is the cause?',
  'جهازان على شبكة يفقدان الاتصال متقطعًا ويسجل الراوتر تعارض عناوين. ما السبب؟',
  'The Wi-Fi channel is too crowded','قناة Wi-Fi مزدحمة جدًا',false,
  'A static address was set inside the DHCP pool and was also handed to another device','ضُبط عنوان ثابت داخل نطاق DHCP وسُلّم أيضًا لجهاز آخر',true,
  'The cable is too long','الكابل طويل جدًا',false,
  'The router firmware is outdated','برنامج الراوتر قديم',false);

SELECT pg_temp.add_q('finix-networking-ip-protocols','gold',2,
  'A client reports that smart devices work at home but remote control fails from outside. Local network is fine. Where should you look first?',
  'عميل يبلّغ أن الأجهزة الذكية تعمل في البيت لكن التحكم عن بُعد يفشل من الخارج. الشبكة المحلية سليمة. أين تنظر أولًا؟',
  'The Zigbee channel assignment','إسناد قناة Zigbee',false,
  'Internet connectivity, the vendor cloud service status, and whether the account is signed in','اتصال الإنترنت وحالة خدمة سحابة المورّد وهل الحساب مسجل دخوله',true,
  'The physical wall switches','المفاتيح الجدارية الفيزيائية',false,
  'The breaker panel','لوحة القواطع',false);

SELECT pg_temp.add_q('finix-networking-ip-protocols','gold',3,
  'An installer suggests port-forwarding to a camera so the client can view it remotely. Why is this the wrong recommendation?',
  'فني يقترح توجيه منفذ لكاميرا ليشاهدها العميل عن بُعد. لماذا هذه توصية خاطئة؟',
  'Because port forwarding is slower than cloud','لأن توجيه المنافذ أبطأ من السحابة',false,
  'Because it exposes the camera directly to the internet where it will be scanned and attacked','لأنه يعرّض الكاميرا مباشرة للإنترنت حيث ستُمسح وتُهاجَم',true,
  'Because cameras cannot use port forwarding','لأن الكاميرات لا تستطيع استخدام توجيه المنافذ',false,
  'Because it requires a static public IP in all cases','لأنه يتطلب IP عامًا ثابتًا في كل الحالات',false);

SELECT pg_temp.add_q('finix-networking-ip-protocols','gold',4,
  'After the client replaced their router, none of the smart devices reconnected. What is the most probable reason?',
  'بعد استبدال العميل راوتره لم يعد أي جهاز ذكي للاتصال. ما السبب الأرجح؟',
  'The devices were permanently damaged','تلفت الأجهزة نهائيًا',false,
  'The new router has a different network name or password, and the devices hold the old credentials','الراوتر الجديد له اسم شبكة أو كلمة مختلفة والأجهزة تحمل البيانات القديمة',true,
  'Smart devices only work with one router brand','الأجهزة الذكية تعمل مع علامة راوتر واحدة فقط',false,
  'The gateway firmware expired','انتهت صلاحية برنامج البوابة',false);

SELECT pg_temp.add_q('finix-networking-ip-protocols','gold',5,
  'A property has excellent Wi-Fi signal everywhere but smart devices in one room still fail. What does this tell you?',
  'عقار بإشارة Wi-Fi ممتازة في كل مكان لكن الأجهزة الذكية في غرفة واحدة ما تزال تفشل. بماذا يخبرك هذا؟',
  'That Wi-Fi coverage and the device''s own radio coverage are not the same thing','أن تغطية Wi-Fi وتغطية راديو الجهاز نفسه ليستا الشيء نفسه',true,
  'That the Wi-Fi measurement must be wrong','أن قياس Wi-Fi خاطئ حتمًا',false,
  'That the room has no electricity','أن الغرفة بلا كهرباء',false,
  'That all devices in that room are faulty','أن كل أجهزة تلك الغرفة معطلة',false);

-- ========== F06 ==========
SELECT pg_temp.add_q('finix-mesh-ecosystems-automation','bronze',4,
  'Which device type extends a Zigbee mesh network?',
  'أي نوع أجهزة يمدد شبكة Zigbee الشبكية؟',
  'Battery-powered sensors','الحساسات التي تعمل ببطارية',false,
  'Mains-powered devices acting as routers','الأجهزة المغذاة من الشبكة التي تعمل كموجّهات',true,
  'Any device regardless of power source','أي جهاز بغض النظر عن مصدر الطاقة',false,
  'Only the coordinator','المنسق فقط',false);

SELECT pg_temp.add_q('finix-mesh-ecosystems-automation','bronze',5,
  'What are the three parts of a typical automation rule?',
  'ما الأجزاء الثلاثة لقاعدة أتمتة نموذجية؟',
  'Device, brand and price','الجهاز والعلامة والسعر',false,
  'Trigger, condition and action','المشغّل والشرط والفعل',true,
  'Input, output and voltage','الدخل والخرج والجهد',false,
  'Sensor, cable and relay','الحساس والكابل والريلاي',false);

SELECT pg_temp.add_q('finix-mesh-ecosystems-automation','silver',3,
  'A hallway light triggered by motion keeps switching on during the day. Which change fixes it correctly?',
  'مصباح ممر مشغّل بالحركة يظل يضيء أثناء النهار. أي تغيير يصلحه صحيحًا؟',
  'Reduce the sensor sensitivity to zero','اخفض حساسية الحساس للصفر',false,
  'Add a light-level or sun-position condition to the rule','أضف شرط مستوى ضوء أو موضع شمس للقاعدة',true,
  'Remove the motion sensor','أزل حساس الحركة',false,
  'Replace the lamp with a dimmer','استبدل المصباح بديمر',false);

SELECT pg_temp.add_q('finix-mesh-ecosystems-automation','silver',4,
  'Why should a smart-home automation avoid depending on the cloud for a stairwell light?',
  'لماذا ينبغي أن تتجنب أتمتة منزلية الاعتماد على السحابة لإضاءة بيت درج؟',
  'Because cloud automation is always slower to configure','لأن الأتمتة السحابية أبطأ دائمًا في الإعداد',false,
  'Because a safety-relevant light must still work during an internet outage','لأن إضاءة متعلقة بالسلامة يجب أن تعمل أثناء انقطاع الإنترنت',true,
  'Because cloud services cost money','لأن الخدمات السحابية تكلف مالًا',false,
  'Because stairwells cannot use sensors','لأن بيوت الدرج لا تستطيع استخدام حساسات',false);

SELECT pg_temp.add_q('finix-mesh-ecosystems-automation','silver',5,
  'A client has devices from three manufacturers and wants one app. Which approach is most appropriate to evaluate first?',
  'عميل لديه أجهزة من ثلاثة مصنّعين ويريد تطبيقًا واحدًا. أي مقاربة أنسب للتقييم أولًا؟',
  'Replace all devices with one brand','استبدل كل الأجهزة بعلامة واحدة',false,
  'A hub platform or Matter, which can present multiple brands in a single interface','منصة بوابة أو Matter تستطيع عرض عدة علامات في واجهة واحدة',true,
  'Use three separate apps permanently','استخدم ثلاثة تطبيقات منفصلة دائمًا',false,
  'Disable the devices that do not match','عطّل الأجهزة غير المتطابقة',false);

SELECT pg_temp.add_q('finix-mesh-ecosystems-automation','gold',2,
  'A mesh worked well for a year, then several devices in one wing became unreliable. Nothing was added. What should be investigated?',
  'شبكة عملت جيدًا سنة ثم صارت عدة أجهزة في جناح واحد غير موثوقة. لم يُضف شيء. ما الذي ينبغي فحصه؟',
  'The devices reached end of life simultaneously','بلغت الأجهزة نهاية عمرها في آن',false,
  'Whether a mains-powered router device in that path was unplugged or a new obstruction appeared','هل فُصل جهاز موجّه مغذى في ذلك المسار أو ظهر عائق جديد',true,
  'The Wi-Fi password changed','تغيّرت كلمة Wi-Fi',false,
  'The season changed','تغيّر الفصل',false);

SELECT pg_temp.add_q('finix-mesh-ecosystems-automation','gold',3,
  'An automation turns off the lights whenever the household leaves, but family members complain it fires while someone is still home. What is the design flaw?',
  'أتمتة تطفئ الأنوار كلما غادرت الأسرة لكن أفرادها يشكون من أنها تعمل وأحدهم ما يزال في البيت. ما عيب التصميم؟',
  'The lights are too bright','الأنوار ساطعة جدًا',false,
  'Presence is being judged from one phone rather than all household members','يُحكم على الحضور من هاتف واحد لا من كل أفراد الأسرة',true,
  'The automation runs too slowly','الأتمتة تعمل ببطء شديد',false,
  'Motion sensors cannot detect people','حساسات الحركة لا تكشف الناس',false);

SELECT pg_temp.add_q('finix-mesh-ecosystems-automation','gold',4,
  'A client complains automations feel "random". Investigation shows twelve overlapping rules affecting the same lights. What is the correct remedy?',
  'عميل يشكو أن الأتمتة تبدو "عشوائية". يكشف الفحص اثنتي عشرة قاعدة متداخلة تؤثر على الأنوار نفسها. ما العلاج الصحيح؟',
  'Add a thirteenth rule to override the others','أضف قاعدة ثالثة عشرة لتجاوز البقية',false,
  'Consolidate to a small number of single-purpose rules with clear conditions','اختصرها لعدد صغير من قواعد أحادية الغرض بشروط واضحة',true,
  'Disable all automation permanently','عطّل كل الأتمتة نهائيًا',false,
  'Replace the gateway','استبدل البوابة',false);

SELECT pg_temp.add_q('finix-mesh-ecosystems-automation','gold',5,
  'Why is a battery sensor a poor choice to extend coverage to a distant outbuilding?',
  'لماذا يكون حساس البطارية خيارًا رديئًا لتمديد التغطية لملحق بعيد؟',
  'Because batteries are expensive','لأن البطاريات باهظة',false,
  'Because battery end devices sleep and never relay traffic for other devices','لأن الأجهزة الطرفية بالبطارية تنام ولا ترحّل مرورًا لأجهزة أخرى أبدًا',true,
  'Because sensors have short range only in cold weather','لأن مدى الحساسات قصير في الطقس البارد فقط',false,
  'Because outbuildings cannot join a mesh','لأن الملاحق لا تستطيع الانضمام لشبكة شبكية',false);

-- ========== F07 ==========
SELECT pg_temp.add_q('finix-alpha-control-platform','bronze',4,
  'What is the purpose of an expansion module in the Alpha Control architecture?',
  'ما الغرض من وحدة توسعة في معمارية Alpha Control؟',
  'To replace the core controller','لاستبدال المتحكم الأساسي',false,
  'To add input or output capacity beyond what the core provides','لإضافة سعة دخل أو خرج تتجاوز ما يوفره الأساسي',true,
  'To supply mains power to the panel','لتغذية اللوحة بطاقة الشبكة',false,
  'To provide internet connectivity only','لتوفير اتصال إنترنت فقط',false);

SELECT pg_temp.add_q('finix-alpha-control-platform','bronze',5,
  'Why does the platform support more than one communication protocol?',
  'لماذا تدعم المنصة أكثر من بروتوكول اتصال؟',
  'To increase the price','لرفع السعر',false,
  'So it can integrate with different equipment and site conditions','لتتمكن من التكامل مع معدات وظروف مواقع مختلفة',true,
  'Because one protocol is always broken','لأن بروتوكولًا واحدًا معطل دائمًا',false,
  'To meet colour coding standards','لتلبية معايير ترميز الألوان',false);

SELECT pg_temp.add_q('finix-alpha-control-platform','silver',3,
  'When converting a classical control panel to smart operation, which layer should remain hardwired?',
  'عند تحويل لوحة تحكم كلاسيكية لتشغيل ذكي، أي طبقة ينبغي أن تبقى موصّلة سلكيًا؟',
  'The indicator lamps','لمبات البيان',false,
  'The power switching and safety protection layer','طبقة تبديل القدرة والحماية والسلامة',true,
  'The remote monitoring layer','طبقة المراقبة عن بُعد',false,
  'The user interface layer','طبقة واجهة المستخدم',false);

SELECT pg_temp.add_q('finix-alpha-control-platform','silver',4,
  'Why is the smart layer designed to be additive and removable in a retrofit?',
  'لماذا تُصمم الطبقة الذكية لتكون إضافية وقابلة للإزالة في التعديل التحديثي؟',
  'To reduce the material cost only','لخفض تكلفة المواد فقط',false,
  'So the proven protection keeps working even if the smart layer is bypassed or fails','فتظل الحماية المثبتة تعمل حتى لو تُجووزت الطبقة الذكية أو فشلت',true,
  'Because regulations forbid permanent controllers','لأن اللوائح تمنع المتحكمات الدائمة',false,
  'Because smart devices expire annually','لأن الأجهزة الذكية تنتهي صلاحيتها سنويًا',false);

SELECT pg_temp.add_q('finix-alpha-control-platform','silver',5,
  'A site needs the controller mounted where ambient temperature is high and dust is present. What should govern the selection?',
  'موقع يحتاج تركيب المتحكم حيث الحرارة المحيطة عالية والغبار موجود. ما الذي ينبغي أن يحكم الاختيار؟',
  'The colour of the enclosure','لون الحاوية',false,
  'The device''s stated environmental and ingress ratings','التصنيفات البيئية وتصنيف دخول الأجسام المذكورة للجهاز',true,
  'The number of available inputs only','عدد المداخل المتاحة فقط',false,
  'The length of the warranty','مدة الضمان',false);

SELECT pg_temp.add_q('finix-alpha-control-platform','gold',2,
  'A client asks to automate an emergency stop through the controller so it can be triggered from a phone. What is the correct professional response?',
  'عميل يطلب أتمتة إيقاف الطوارئ عبر المتحكم ليُفعّل من هاتف. ما الاستجابة الاحترافية الصحيحة؟',
  'Implement it as requested since it is convenient','نفّذها كما طُلب لأنها مريحة',false,
  'Refuse to route the emergency stop through software, keeping it hardwired, while optionally adding remote status reporting','ارفض تمرير إيقاف الطوارئ عبر البرمجيات مبقيًا إياه سلكيًا، مع إضافة تبليغ حالة عن بُعد اختياريًا',true,
  'Implement it but add a password','نفّذها مع إضافة كلمة مرور',false,
  'Implement it only for authorised users','نفّذها للمستخدمين المخولين فقط',false);

SELECT pg_temp.add_q('finix-alpha-control-platform','gold',3,
  'A retrofit replaces hardwired timers with controller-based timing. Months later a timing fault stops production. Which design decision limits the damage?',
  'تعديل تحديثي يستبدل مؤقتات سلكية بتوقيت قائم على المتحكم. بعد أشهر يوقف عطل توقيت الإنتاج. أي قرار تصميم يحد الضرر؟',
  'Removing all manual controls to avoid confusion','إزالة كل التحكمات اليدوية تجنبًا للارتباك',false,
  'Retaining a manual or bypass path so the plant can run while the controller is diagnosed','الإبقاء على مسار يدوي أو تجاوزي فتعمل المنشأة أثناء تشخيص المتحكم',true,
  'Storing the program only on the controller','تخزين البرنامج على المتحكم فقط',false,
  'Using a single supplier for everything','استخدام مورّد واحد لكل شيء',false);

SELECT pg_temp.add_q('finix-alpha-control-platform','gold',4,
  'When proposing a smart conversion to an industrial client, which argument is most commercially persuasive and technically honest?',
  'عند اقتراح تحويل ذكي لعميل صناعي، أي حجة أكثر إقناعًا تجاريًا وصدقًا تقنيًا؟',
  'That the smart system eliminates the need for maintenance','أن النظام الذكي يلغي الحاجة للصيانة',false,
  'That the protection they already trust stays in place, and visibility and control are added on top','أن الحماية التي يثقون بها تبقى مكانها وتُضاف الرؤية والتحكم فوقها',true,
  'That all existing equipment must be replaced','أن كل المعدات القائمة يجب استبدالها',false,
  'That downtime will be reduced to zero','أن التوقف سيُخفض للصفر',false);

SELECT pg_temp.add_q('finix-alpha-control-platform','gold',5,
  'A controller reports a sensor reading that contradicts what the operator observes on the plant. What should be verified first?',
  'متحكم يبلّغ قراءة حساس تناقض ما يلاحظه المشغّل في المنشأة. ما الذي ينبغي التحقق منه أولًا؟',
  'Replace the controller immediately','استبدل المتحكم فورًا',false,
  'The sensor wiring, its placement and its scaling configuration before trusting either reading','تمديد الحساس وموضعه وإعداد تدريجه قبل الوثوق بأي من القراءتين',true,
  'Assume the operator is mistaken','افترض أن المشغّل مخطئ',false,
  'Assume the controller is always correct','افترض أن المتحكم صحيح دائمًا',false);
