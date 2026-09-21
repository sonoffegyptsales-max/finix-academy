-- Quiz top-up: M13-M16 (integration, device mastery, troubleshooting, security).

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

-- ========== M13 ==========
SELECT pg_temp.add_q('sonoff-smart-home-integration','bronze',3,
  'What does a Zigbee USB coordinator allow a Home Assistant machine to do?',
  'ماذا يتيح دونجل منسق Zigbee لجهاز Home Assistant؟',
  'Connect to the internet faster','الاتصال بالإنترنت أسرع',false,
  'Act as the Zigbee gateway itself, with no manufacturer gateway needed','أن يعمل كبوابة Zigbee نفسها بلا حاجة لبوابة مصنّع',true,
  'Increase the Wi-Fi range','زيادة مدى Wi-Fi',false,
  'Store camera footage','تخزين لقطات الكاميرا',false);

SELECT pg_temp.add_q('sonoff-smart-home-integration','bronze',4,
  'What is Matter multi-admin?',
  'ما تعدد الإدارة في Matter؟',
  'A way to give several people the same password','طريقة لإعطاء عدة أشخاص الكلمة نفسها',false,
  'The ability for one device to belong to several ecosystems simultaneously','قدرة جهاز واحد على الانتماء لعدة منظومات في آن',true,
  'A requirement to use two gateways','اشتراط استخدام بوابتين',false,
  'An administrator account type','نوع حساب مدير',false);

SELECT pg_temp.add_q('sonoff-smart-home-integration','bronze',5,
  'Matter runs over which transports?',
  'يعمل Matter فوق أي وسائط نقل؟',
  'Zigbee and Z-Wave only','Zigbee وZ-Wave فقط',false,
  'Wi-Fi, Ethernet and Thread','Wi-Fi وإيثرنت وThread',true,
  'Bluetooth only','بلوتوث فقط',false,
  'Infrared and 433 MHz','الأشعة تحت الحمراء و٤٣٣ ميجاهرتز',false);

SELECT pg_temp.add_q('sonoff-smart-home-integration','silver',2,
  'A client buys Matter-over-Thread devices but has no HomePod, Apple TV or Nest Hub. What is the problem?',
  'عميل يشتري أجهزة Matter فوق Thread لكن بلا HomePod أو Apple TV أو Nest Hub. ما المشكلة؟',
  'Thread devices need a subscription','أجهزة Thread تحتاج اشتراكًا',false,
  'There is no Thread border router, so the devices cannot reach the IP network','لا يوجد موجّه حدود Thread فلا تستطيع الأجهزة بلوغ شبكة IP',true,
  'Thread devices only work outdoors','أجهزة Thread تعمل في الخارج فقط',false,
  'The devices need Ethernet cables','الأجهزة تحتاج كابلات إيثرنت',false);

SELECT pg_temp.add_q('sonoff-smart-home-integration','silver',3,
  'A dimmer imported into Home Assistant appears as a switch with no brightness control. What should be checked?',
  'ديمر مستورد في Home Assistant يظهر كمفتاح بلا تحكم بالسطوع. ما الذي ينبغي فحصه؟',
  'The device is faulty and must be replaced','الجهاز معطل ويجب استبداله',false,
  'The entity domain mapping, since it imported as switch rather than light','ربط نطاق الكيان فقد استُورد كمفتاح لا كمصباح',true,
  'The Wi-Fi password','كلمة Wi-Fi',false,
  'The circuit breaker rating','تصنيف قاطع الدائرة',false);

SELECT pg_temp.add_q('sonoff-smart-home-integration','silver',4,
  'Why should devices be renamed in Home Assistant before automations are built?',
  'لماذا ينبغي إعادة تسمية الأجهزة في Home Assistant قبل بناء الأتمتة؟',
  'Because names cannot be changed later at all','لأن الأسماء لا يمكن تغييرها لاحقًا إطلاقًا',false,
  'Because entity IDs derive from the pairing name, and renaming later breaks automations referencing the old ID','لأن معرّفات الكيانات تُشتق من اسم الإقران وإعادة التسمية لاحقًا تكسر الأتمتة المشيرة للمعرّف القديم',true,
  'Because Home Assistant charges per rename','لأن Home Assistant يحاسب على كل إعادة تسمية',false,
  'Because Arabic names are not supported','لأن الأسماء العربية غير مدعومة',false);

SELECT pg_temp.add_q('sonoff-smart-home-integration','silver',5,
  'Why is a community-maintained Homey app a risk worth disclosing to a client?',
  'لماذا يكون تطبيق Homey مصون من المجتمع مخاطرة تستحق الإفصاح للعميل؟',
  'Community apps are always unstable','تطبيقات المجتمع غير مستقرة دائمًا',false,
  'It may be abandoned by its individual maintainer, leaving a critical device unsupported','قد يُهجر من صائنه الفرد فيبقى جهاز حرج بلا دعم',true,
  'They cost more than official apps','تكلف أكثر من التطبيقات الرسمية',false,
  'They cannot be updated','لا يمكن تحديثها',false);

SELECT pg_temp.add_q('sonoff-smart-home-integration','gold',2,
  'A client who wants a system they never think about asks for Home Assistant because a friend recommended it. What is the honest advice?',
  'عميل يريد نظامًا لا يفكر فيه أبدًا يطلب Home Assistant لأن صديقًا أوصى به. ما النصيحة الصادقة؟',
  'Install it, since it is the most capable option','ركّبه فهو الخيار الأقدر',false,
  'Explain it requires ongoing maintenance and updates that occasionally break integrations, and that a simpler platform may suit them better','اشرح أنه يتطلب صيانة مستمرة وتحديثات تكسر التكاملات أحيانًا وأن منصة أبسط قد تناسبه أكثر',true,
  'Refuse to install it','ارفض تركيبه',false,
  'Install it but do not mention maintenance','ركّبه دون ذكر الصيانة',false);

SELECT pg_temp.add_q('sonoff-smart-home-integration','gold',3,
  'Which layer of an installation should carry the functions a household genuinely needs at night?',
  'أي طبقة من التركيب ينبغي أن تحمل الوظائف التي تحتاجها الأسرة فعلًا ليلًا؟',
  'The cloud layer, for remote access','الطبقة السحابية للوصول عن بُعد',false,
  'The physical and local control layers, which survive internet and cloud failure','الطبقتان الفيزيائية والتحكم المحلي اللتان تنجوان من فشل الإنترنت والسحابة',true,
  'The voice assistant layer','طبقة المساعد الصوتي',false,
  'Whichever layer is cheapest','أي طبقة أرخص',false);

SELECT pg_temp.add_q('sonoff-smart-home-integration','gold',4,
  'A Home Assistant installation is lost when its SD card fails, and the client must rebuild everything. What was the preventable failure?',
  'يُفقد تركيب Home Assistant حين تفشل بطاقة الذاكرة ويجب على العميل إعادة بناء كل شيء. ما الفشل الذي كان يمكن منعه؟',
  'Using Home Assistant at all','استخدام Home Assistant أصلًا',false,
  'No automatic backup was configured and verified before handover','لم تُضبط نسخة احتياطية تلقائية ولم يُتحقق منها قبل التسليم',true,
  'The SD card brand was wrong','علامة بطاقة الذاكرة كانت خاطئة',false,
  'Too many devices were paired','أُقرنت أجهزة كثيرة جدًا',false);

SELECT pg_temp.add_q('sonoff-smart-home-integration','gold',5,
  'When is choosing a proprietary, locked ecosystem a professionally defensible decision?',
  'متى يكون اختيار منظومة مغلقة خاصة قرارًا قابلًا للدفاع مهنيًا؟',
  'Never, under any circumstances','أبدًا تحت أي ظرف',false,
  'When it is the best technical fit and the trade-off was explained to the client and chosen deliberately','حين يكون الأنسب تقنيًا وشُرحت المقايضة للعميل واختيرت عمدًا',true,
  'Whenever it is the fastest to commission','كلما كان الأسرع تشغيلًا',false,
  'Whenever the client does not ask','كلما لم يسأل العميل',false);

-- ========== M14 ==========
SELECT pg_temp.add_q('sonoff-device-specific-mastery','bronze',3,
  'Which dimming mode is correct for most dimmable LED lamps?',
  'أي وضع تعتيم صحيح لأغلب مصابيح LED القابلة للتعتيم؟',
  'Leading edge','الحافة الأمامية',false,
  'Trailing edge','الحافة الخلفية',true,
  'Either, with no difference','أي منهما بلا فرق',false,
  'Neither; LEDs cannot be dimmed','لا هذا ولا ذاك؛ LED لا يمكن تعتيمها',false);

SELECT pg_temp.add_q('sonoff-device-specific-mastery','bronze',4,
  'What is the difference between a true NDIR CO2 sensor and an eCO2 sensor?',
  'ما الفرق بين حساس NDIR حقيقي لثاني أكسيد الكربون وحساس eCO2؟',
  'There is no difference','لا فرق',false,
  'eCO2 estimates a CO2-equivalent from VOC rather than measuring CO2 directly','eCO2 يقدّر مكافئًا لثاني أكسيد الكربون من المركبات المتطايرة بدل قياسه مباشرة',true,
  'NDIR sensors measure humidity only','حساسات NDIR تقيس الرطوبة فقط',false,
  'eCO2 sensors are more accurate','حساسات eCO2 أدق',false);

SELECT pg_temp.add_q('sonoff-device-specific-mastery','bronze',5,
  'What is the correct mounting height for an air-quality sensor in a seated space?',
  'ما ارتفاع التركيب الصحيح لحساس جودة هواء في حيز جلوس؟',
  'At ceiling level','عند مستوى السقف',false,
  'Roughly 1.1 to 1.5 metres, at breathing height','نحو ١٫١ إلى ١٫٥ متر عند ارتفاع التنفس',true,
  'At skirting level','عند مستوى الوزرة',false,
  'Directly above a radiator','فوق مشع الحرارة مباشرة',false);

SELECT pg_temp.add_q('sonoff-device-specific-mastery','silver',2,
  'A dimmer buzzes audibly and the lamps flicker at low levels. Which two checks address this first?',
  'ديمر يطن مسموعًا والمصابيح تومض عند المستويات المنخفضة. أي فحصين يعالجان هذا أولًا؟',
  'Replace the lamps with higher wattage','استبدل المصابيح بقدرة أعلى',false,
  'Confirm trailing-edge mode for the LED load and calibrate the minimum brightness above the instability threshold','تأكد من وضع الحافة الخلفية لحمل LED وعاير السطوع الأدنى فوق عتبة عدم الاستقرار',true,
  'Increase the supply voltage','ارفع جهد التغذية',false,
  'Replace the dimmer with a plain switch','استبدل الديمر بمفتاح عادي',false);

SELECT pg_temp.add_q('sonoff-device-specific-mastery','silver',3,
  'Why should all lamps on a single dimmed circuit be the same model?',
  'لماذا ينبغي أن تكون كل مصابيح دائرة معتّمة واحدة الموديل نفسه؟',
  'To reduce purchase cost','لخفض تكلفة الشراء',false,
  'Because different drivers respond differently to the same waveform, causing uneven brightness','لأن المشغّلات المختلفة تستجيب للموجة نفسها اختلافًا فينتج سطوع غير متساوٍ',true,
  'Because mixing models voids the warranty','لأن خلط الموديلات يبطل الضمان',false,
  'Because dimmers can only address one model','لأن الديمرات تخاطب موديلًا واحدًا فقط',false);

SELECT pg_temp.add_q('sonoff-device-specific-mastery','silver',4,
  'A heat pump is wired as though it were a conventional system. What symptom results?',
  'مضخة حرارية موصولة كأنها نظام تقليدي. ما العرض الناتج؟',
  'The fan never runs','المروحة لا تعمل أبدًا',false,
  'Heating is delivered when cooling is demanded, because the reversing valve is not controlled correctly','تُسلَّم تدفئة حين يُطلب تبريد لأن صمام العكس غير متحكم به صحيحًا',true,
  'The compressor never starts','الضاغط لا يبدأ أبدًا',false,
  'The thermostat display stays blank','شاشة الثرموستات تبقى فارغة',false);

SELECT pg_temp.add_q('sonoff-device-specific-mastery','silver',5,
  'Why must a Zigbee coordinator dongle be used with a USB extension cable?',
  'لماذا يجب استخدام دونجل منسق Zigbee مع كابل تمديد USB؟',
  'Because the port supplies insufficient power','لأن المنفذ يوفر طاقة غير كافية',false,
  'To move it away from USB 3.0 interference and the metal chassis, which degrade 2.4 GHz range','لإبعاده عن تداخل USB 3.0 والهيكل المعدني اللذين يُدهوران مدى ٢٫٤ جيجاهرتز',true,
  'Because dongles overheat inside servers','لأن الدونجلات تسخن داخل الخوادم',false,
  'To make firmware flashing possible','لجعل برمجة البرنامج ممكنة',false);

SELECT pg_temp.add_q('sonoff-device-specific-mastery','gold',2,
  'A client reports the air conditioning "runs constantly for no reason". The thermostat is on a wall that gets afternoon sun. What is the cause?',
  'عميل يبلّغ أن التكييف "يعمل باستمرار بلا سبب". الثرموستات على جدار تصله شمس العصر. ما السبب؟',
  'The compressor is failing','الضاغط يفشل',false,
  'The thermostat reads solar gain rather than room temperature and keeps calling for cooling','الثرموستات يقرأ الكسب الشمسي لا حرارة الغرفة فيظل يطلب تبريدًا',true,
  'The refrigerant is low','وسيط التبريد منخفض',false,
  'The fan speed is set too high','سرعة المروحة مضبوطة عالية جدًا',false);

SELECT pg_temp.add_q('sonoff-device-specific-mastery','gold',3,
  'Why must a thermostat''s minimum off-time never be disabled, even if the client finds the delay annoying?',
  'لماذا يجب ألا يُعطَّل زمن الإطفاء الأدنى للثرموستات أبدًا حتى لو وجد العميل التأخير مزعجًا؟',
  'Because it saves electricity','لأنه يوفر الكهرباء',false,
  'Because restarting a compressor against residual head pressure can destroy it','لأن إعادة تشغيل ضاغط مقابل ضغط رأس متبقٍ قد تدمره',true,
  'Because the warranty requires it','لأن الضمان يتطلبه',false,
  'Because it prevents the fan from stalling','لأنه يمنع توقف المروحة',false);

SELECT pg_temp.add_q('sonoff-device-specific-mastery','gold',4,
  'A retrofit job is quoted for forty smart switches. During installation, most switch boxes turn out to have no neutral. What does this reveal?',
  'يُسعّر عمل تعديل تحديثي لأربعين مفتاحًا ذكيًا. أثناء التركيب يتبين أن أغلب علب المفاتيح بلا نيوترال. ماذا يكشف هذا؟',
  'That smart switches are unsuitable for retrofit generally','أن المفاتيح الذكية غير مناسبة للتعديل التحديثي عمومًا',false,
  'That the survey failed to check for neutrals before quoting, which is a survey discipline failure','أن المسح فشل في فحص النيوترالات قبل التسعير وهو فشل انضباط مسح',true,
  'That the client rewired the property','أن العميل أعاد تمديد العقار',false,
  'That the devices were the wrong model','أن الأجهزة كانت بالموديل الخاطئ',false);

SELECT pg_temp.add_q('sonoff-device-specific-mastery','gold',5,
  'Before reflashing a coordinator dongle that runs a live forty-device network, what is the critical consideration?',
  'قبل إعادة برمجة دونجل منسق يشغّل شبكة حية بأربعين جهازًا، ما الاعتبار الحرج؟',
  'The flashing takes several hours','البرمجة تستغرق ساعات',false,
  'Reflashing resets the network, so every device must be re-paired — most of a working day','إعادة البرمجة تصفّر الشبكة فيجب إعادة إقران كل جهاز — أغلب يوم عمل',true,
  'The dongle must be returned to the manufacturer','يجب إرجاع الدونجل للمصنّع',false,
  'Flashing requires the client to be present','البرمجة تتطلب حضور العميل',false);

-- ========== M15 ==========
SELECT pg_temp.add_q('sonoff-network-troubleshooting','bronze',3,
  'Which Zigbee channels sit in the gaps between common Wi-Fi channels?',
  'أي قنوات Zigbee تقع في الفجوات بين قنوات Wi-Fi الشائعة؟',
  '1, 6 and 11','١ و٦ و١١',false,
  '15, 20 and 25','١٥ و٢٠ و٢٥',true,
  '2, 4 and 8','٢ و٤ و٨',false,
  '11, 12 and 13','١١ و١٢ و١٣',false);

SELECT pg_temp.add_q('sonoff-network-troubleshooting','bronze',4,
  'Which materials most strongly obstruct a 2.4 GHz signal?',
  'أي مواد تعيق إشارة ٢٫٤ جيجاهرتز بأشد قوة؟',
  'Wood and plasterboard','الخشب والجبس',false,
  'Metal, water and mirrors','المعدن والماء والمرايا',true,
  'Glass and fabric','الزجاج والقماش',false,
  'Paint and wallpaper','الدهان وورق الجدران',false);

SELECT pg_temp.add_q('sonoff-network-troubleshooting','bronze',5,
  'What should be measured before specifying multiple cameras on a property?',
  'ما الذي ينبغي قياسه قبل تحديد عدة كاميرات في عقار؟',
  'The number of rooms','عدد الغرف',false,
  'The internet upload capacity, since cameras consume far more bandwidth than other devices','سعة رفع الإنترنت فالكاميرات تستهلك عرض نطاق أكبر بكثير من غيرها',true,
  'The wall paint colour','لون دهان الجدار',false,
  'The number of light fittings','عدد وحدات الإنارة',false);

SELECT pg_temp.add_q('sonoff-network-troubleshooting','silver',2,
  'After adding a smart socket to fix a weak mesh area, the failing sensor still drops out. What step was missed?',
  'بعد إضافة مقبس ذكي لإصلاح منطقة شبكة ضعيفة ما يزال الحساس الفاشل يفصل. أي خطوة أُغفلت؟',
  'The socket must be the same brand','يجب أن يكون المقبس بالعلامة نفسها',false,
  'Devices do not re-route on opportunity, so the network must be repaired or the device power-cycled','الأجهزة لا تعيد التوجيه عند الفرصة فيجب إصلاح الشبكة أو إعادة تدوير طاقة الجهاز',true,
  'The socket needs a firmware update first','المقبس يحتاج تحديث برنامج أولًا',false,
  'Smart sockets cannot act as routers','المقابس الذكية لا تستطيع العمل كموجّهات',false);

SELECT pg_temp.add_q('sonoff-network-troubleshooting','silver',3,
  'A single battery sensor behaves intermittently and works better in warm weather. What should be done before network diagnosis?',
  'حساس بطارية واحد يتصرف متقطعًا ويعمل أفضل في الطقس الدافئ. ما الذي ينبغي فعله قبل تشخيص الشبكة؟',
  'Replace the gateway','استبدل البوابة',false,
  'Replace the battery, since a dying battery produces exactly this temperature-sensitive pattern','استبدل البطارية فالبطارية المحتضرة تنتج هذا النمط الحساس للحرارة بالضبط',true,
  'Change the Zigbee channel','غيّر قناة Zigbee',false,
  'Move the router','انقل الراوتر',false);

SELECT pg_temp.add_q('sonoff-network-troubleshooting','silver',4,
  'Why should energy-monitoring alert thresholds be set from a week of observation rather than the datasheet?',
  'لماذا ينبغي ضبط عتبات تنبيه مراقبة الطاقة من أسبوع ملاحظة لا من ورقة البيانات؟',
  'Because datasheets are always wrong','لأن أوراق البيانات خاطئة دائمًا',false,
  'Because thresholds set from theory produce false alarms, and an alert that fires daily gets muted','لأن العتبات المضبوطة نظريًا تنتج إنذارات كاذبة والتنبيه الذي يعمل يوميًا يُكتم',true,
  'Because a week is required by regulation','لأن الأسبوع مطلوب بالتنظيم',false,
  'Because devices need a week to calibrate','لأن الأجهزة تحتاج أسبوعًا للمعايرة',false);

SELECT pg_temp.add_q('sonoff-network-troubleshooting','silver',5,
  'Why must a camera never be mounted behind glass?',
  'لماذا يجب ألا تُركّب كاميرا خلف زجاج أبدًا؟',
  'Because glass reduces the field of view','لأن الزجاج يقلل مجال الرؤية',false,
  'Because infrared reflects off the pane back into the lens and whites out the night image','لأن الأشعة تحت الحمراء تنعكس عن اللوح للعدسة فتبيّض الصورة الليلية',true,
  'Because glass blocks the Wi-Fi signal','لأن الزجاج يحجب إشارة Wi-Fi',false,
  'Because condensation always forms','لأن التكثف يتكوّن دائمًا',false);

SELECT pg_temp.add_q('sonoff-network-troubleshooting','gold',2,
  'A property has forty battery sensors and one gateway, and reliability is poor. What is the fundamental design error?',
  'عقار به أربعون حساس بطارية وبوابة واحدة والموثوقية رديئة. ما خطأ التصميم الجوهري؟',
  'Too many sensors were installed','رُكّبت حساسات كثيرة جدًا',false,
  'There is no mesh, because battery end devices never relay — only mains-powered routers extend coverage','لا توجد شبكة شبكية لأن أجهزة البطاريات الطرفية لا ترحّل — فالموجّهات المغذاة وحدها تمدد التغطية',true,
  'The gateway firmware is outdated','برنامج البوابة قديم',false,
  'The sensors need a different channel each','كل حساس يحتاج قناة مختلفة',false);

SELECT pg_temp.add_q('sonoff-network-troubleshooting','gold',3,
  'A pump''s energy data shows gradually lengthening run times over several months. What does this most likely indicate?',
  'بيانات طاقة مضخة تبيّن أزمنة تشغيل تطول تدريجيًا عبر أشهر. ما الذي يشير إليه هذا على الأرجح؟',
  'The energy meter is drifting','عداد الطاقة ينجرف',false,
  'A developing mechanical problem such as wear, a leak or a failing pressure vessel','مشكلة ميكانيكية تتطور كالبلى أو تسريب أو وعاء ضغط فاشل',true,
  'Normal seasonal variation only','تباين موسمي طبيعي فقط',false,
  'The tariff changed','تغيّرت التعريفة',false);

SELECT pg_temp.add_q('sonoff-network-troubleshooting','gold',4,
  'A client insists cameras cover the street and a neighbour complains. Which preparation most protects both client and installer?',
  'عميل يصر على تغطية الكاميرات للشارع فيشكو جار. أي تحضير يحمي العميل والفني أكثر؟',
  'Deleting the footage immediately','حذف اللقطات فورًا',false,
  'A documented coverage plan with privacy masking configured at installation and the client advised of obligations','خطة تغطية موثقة بإخفاء خصوصية مضبوط عند التركيب والعميل منصوح بالتزاماته',true,
  'Pointing the cameras slightly downward','توجيه الكاميرات لأسفل قليلًا',false,
  'Using lower-resolution cameras','استخدام كاميرات أقل دقة',false);

SELECT pg_temp.add_q('sonoff-network-troubleshooting','gold',5,
  'A mesh degrades only in the evening when the family is home. What explanation fits best?',
  'شبكة تتدهور مساءً فقط حين تكون العائلة في البيت. أي تفسير يناسب أكثر؟',
  'The devices are faulty at night','الأجهزة معطلة ليلًا',false,
  'Occupancy and evening appliance use add 2.4 GHz absorption and interference','الإشغال واستخدام الأجهزة مساءً يضيفان امتصاصًا وتداخلًا عند ٢٫٤ جيجاهرتز',true,
  'The gateway sleeps during the day','البوابة تنام نهارًا',false,
  'Zigbee does not work after dark','Zigbee لا يعمل بعد الظلام',false);

-- ========== M16 ==========
SELECT pg_temp.add_q('sonoff-mesh-security-hardening','bronze',3,
  'What is the purpose of placing IoT devices on a separate network?',
  'ما الغرض من وضع أجهزة إنترنت الأشياء على شبكة منفصلة؟',
  'To make them faster','لجعلها أسرع',false,
  'To limit what a compromised device can reach on the household network','للحد مما يستطيع جهاز مخترق بلوغه في شبكة الأسرة',true,
  'To reduce their power consumption','لخفض استهلاكها للطاقة',false,
  'To avoid paying for extra bandwidth','لتجنب دفع عرض نطاق إضافي',false);

SELECT pg_temp.add_q('sonoff-mesh-security-hardening','bronze',4,
  'Why should UPnP be disabled on the router?',
  'لماذا ينبغي تعطيل UPnP في الراوتر؟',
  'It slows down the network','يبطئ الشبكة',false,
  'It lets devices open inbound ports by themselves, which untrusted devices should never do','يتيح للأجهزة فتح منافذ واردة بنفسها وهو ما ينبغي ألا تفعله الأجهزة غير الموثوقة',true,
  'It conflicts with Zigbee','يتعارض مع Zigbee',false,
  'It uses too much electricity','يستهلك كهرباء كثيرة',false);

SELECT pg_temp.add_q('sonoff-mesh-security-hardening','bronze',5,
  'Which devices should be on the highest-priority tier for prompt firmware updates?',
  'أي أجهزة ينبغي أن تكون في أعلى درجة أولوية للتحديث الفوري؟',
  'Light switches and sockets','المفاتيح والمقابس',false,
  'Locks, cameras, gateways and routers','الأقفال والكاميرات والبوابات والراوترات',true,
  'Battery sensors','حساسات البطاريات',false,
  'Dimmers only','الديمرات فقط',false);

SELECT pg_temp.add_q('sonoff-mesh-security-hardening','silver',3,
  'Why must segmentation be planned before installation rather than applied afterwards?',
  'لماذا يجب تخطيط التقسيم قبل التركيب لا تطبيقه بعده؟',
  'Because routers cannot be reconfigured later','لأن الراوترات لا يمكن إعادة إعدادها لاحقًا',false,
  'Because it breaks discovery protocols, so commissioning and permitted flows must be designed around it','لأنه يكسر بروتوكولات الاكتشاف فيجب تصميم التشغيل والتدفقات المسموحة حوله',true,
  'Because segmentation costs more later','لأن التقسيم يكلف أكثر لاحقًا',false,
  'Because clients dislike changes','لأن العملاء يكرهون التغييرات',false);

SELECT pg_temp.add_q('sonoff-mesh-security-hardening','silver',4,
  'Why should a cleaner be given a temporary lock code rather than the family code?',
  'لماذا ينبغي إعطاء عامل النظافة رمز قفل مؤقتًا لا رمز العائلة؟',
  'Because cleaners cannot remember long codes','لأن عمال النظافة لا يتذكرون رموزًا طويلة',false,
  'So access can be revoked individually with an audit trail, without changing everyone else''s code','فيمكن سحب الوصول فرديًا بأثر تدقيق دون تغيير رمز الجميع',true,
  'Because temporary codes are more secure by design','لأن الرموز المؤقتة أأمن بالتصميم',false,
  'Because the lock only supports one permanent code','لأن القفل يدعم رمزًا دائمًا واحدًا فقط',false);

SELECT pg_temp.add_q('sonoff-mesh-security-hardening','silver',5,
  'Why should a gateway update never be performed immediately before leaving site on a Friday?',
  'لماذا ينبغي ألا يُجرى تحديث بوابة قبل مغادرة الموقع مباشرة يوم جمعة؟',
  'Because updates are slower at the end of the week','لأن التحديثات أبطأ في نهاية الأسبوع',false,
  'Because a failed gateway update disables every device and nobody is available to recover it','لأن فشل تحديث البوابة يعطّل كل جهاز ولا أحد متاح لاستعادته',true,
  'Because vendors release updates only on Mondays','لأن المورّدين يصدرون التحديثات الاثنين فقط',false,
  'Because firmware expires over weekends','لأن البرامج تنتهي صلاحيتها في العطلات',false);

SELECT pg_temp.add_q('sonoff-mesh-security-hardening','gold',2,
  'An installer registers a client''s smart home on the installer''s own email address. What is the primary risk to the client?',
  'فني يسجل منزل عميل الذكي على بريد الفني نفسه. ما المخاطرة الأساسية على العميل؟',
  'Slower device response','استجابة أجهزة أبطأ',false,
  'The client cannot recover access independently, cannot transfer it on sale, and the installer retains access to locks and cameras','لا يستطيع العميل استرداد الوصول باستقلال ولا نقله عند البيع ويحتفظ الفني بوصول للأقفال والكاميرات',true,
  'The warranty becomes void','يبطل الضمان',false,
  'Automations stop working','تتوقف الأتمتة',false);

SELECT pg_temp.add_q('sonoff-mesh-security-hardening','gold',3,
  'Why is a compromised smart light bulb a serious security concern on a flat network?',
  'لماذا تكون لمبة ذكية مخترقة قلقًا أمنيًا جديًا في شبكة مسطحة؟',
  'Because the attacker can control the lighting','لأن المهاجم يستطيع التحكم بالإنارة',false,
  'Because it provides a permanently-on, unmonitored foothold from which the rest of the network is reachable','لأنها توفر موطئ قدم دائم التشغيل وغير مراقب يمكن منه بلوغ بقية الشبكة',true,
  'Because it consumes excessive bandwidth','لأنها تستهلك عرض نطاق مفرطًا',false,
  'Because it will fail quickly','لأنها ستفشل سريعًا',false);

SELECT pg_temp.add_q('sonoff-mesh-security-hardening','gold',4,
  'A commercial site updates forty devices overnight and a bad release disables the property before opening. Which policy would have prevented this?',
  'موقع تجاري يحدّث أربعين جهازًا ليلًا فيعطّل إصدار سيئ العقار قبل الافتتاح. أي سياسة كانت ستمنع هذا؟',
  'Disabling all updates permanently','تعطيل كل التحديثات نهائيًا',false,
  'Tiering by criticality, letting releases age, and updating one device of a type first','التدريج بالحرجية وترك الإصدارات تتقادم وتحديث جهاز واحد من كل نوع أولًا',true,
  'Updating during business hours instead','التحديث في ساعات العمل بدلًا من ذلك',false,
  'Using only one device manufacturer','استخدام مصنّع أجهزة واحد فقط',false);

SELECT pg_temp.add_q('sonoff-mesh-security-hardening','gold',5,
  'When a technician leaves the company, what is the correct security action regarding client sites?',
  'حين يغادر فني الشركة، ما الإجراء الأمني الصحيح بخصوص مواقع العملاء؟',
  'Nothing, since they signed an agreement','لا شيء فقد وقّع اتفاقًا',false,
  'Rotate credentials for every site they had access to','دوّر بيانات الاعتماد لكل موقع كان له وصول إليه',true,
  'Notify clients but change nothing','أبلغ العملاء دون تغيير شيء',false,
  'Only change the office passwords','غيّر كلمات المكتب فقط',false);
