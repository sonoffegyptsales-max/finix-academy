-- Module F08: Bilingual Terminology & the Technician's Field Toolkit

INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position) VALUES ('finix-terminology-toolkit', 'F08', 'finix-technician-academy', 'Bilingual Terminology & the Technician''s Field Toolkit', 'المصطلحات ثنائية اللغة وحقيبة أدوات الفني الميدانية', 'A standardized bilingual reference for room/space names and device/appliance names used across surveys, proposals, and scene naming, plus the complete field toolkit a smart home technician needs on every job.', 'مرجع موحد ثنائي اللغة لأسماء الغرف والمساحات وأسماء الأجهزة المستخدمة عبر المعاينات والمقترحات وتسمية المشاهد، بالإضافة إلى حقيبة الأدوات الميدانية الكاملة التي يحتاجها فني المنزل الذكي في كل مهمة.', NULL, 25);
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'Room & Space Terminology: A Bilingual Reference', 'مصطلحات الغرف والمساحات: مرجع ثنائي اللغة', 'Getting room names right in Arabic and English matters more than it seems — a survey form, a proposal, or a scene name that mismatches what the client calls a room causes real confusion during handoff and support calls later. This is the standard room/space vocabulary I expect every technician and trainer to use consistently across documentation.

**Main living spaces:** Living Room / Reception (غرفة المعيشة / الريسيبشن), Dining Room (غرفة الطعام / السفرة), Kitchen (المطبخ), Bathroom / Toilet / W.C. (الحمام), Entrance / Foyer (المدخل / اللوبي), Hallway / Corridor (الممر / الطرقة).

**Bedrooms:** Master Bedroom (غرفة النوم الرئيسية), Kids Bedroom / Children''s Room (غرفة نوم الأطفال), Guest Bedroom (غرفة الضيوف), Dressing Room / Walk-in Closet (غرفة الملابس).

**Utility & work spaces:** Office / Study Room (المكتب / غرفة الدراسة), Laundry Room (غرفة الغسيل), Storage Room / Pantry (المخزن), Garage (الجراج), Basement (القبو / السرداب).

**Outdoor & leisure spaces:** Balcony / Terrace (الشرفة / البلكونة), Garden / Backyard (الحديقة), Roof / Rooftop (السطح), Gym / Home Gym (صالة الألعاب الرياضية), Playroom / Game Room (غرفة الألعاب), Fence (السور), Main Gate (البوابة الرئيسية), Pool (حمام السباحة).

**Additional survey-relevant technical spaces:** Shafts / Lightwells (مناور الخدمات), Stairs / Staircase (السلم), Maid''s Room (غرفة الخادمة).

**Why this matters at the survey stage specifically:** when you''re filling out a site survey form room by room, using this exact vocabulary — and confirming it matches what the client actually calls each space — prevents a mismatch where, say, the client''s "study" gets logged as "office" in the system, and then a scene named "Office Lights Off" makes no sense to them when they''re trying to control it by voice.', 'الحصول على أسماء الغرف الصحيحة بالعربية والإنجليزية أهم مما يبدو — استمارة معاينة أو مقترح أو اسم مشهد لا يطابق ما يسميه العميل لغرفة ما يسبب ارتباكًا حقيقيًا أثناء التسليم ومكالمات الدعم لاحقًا. هذه هي مفردات الغرف/المساحات القياسية التي أتوقع من كل فني ومدرّب استخدامها باستمرار عبر كل التوثيق.

**المساحات الأساسية:** غرفة المعيشة / الريسيبشن (Living Room / Reception)، غرفة الطعام / السفرة (Dining Room)، المطبخ (Kitchen)، الحمام (Bathroom / Toilet / W.C.)، المدخل / اللوبي (Entrance / Foyer)، الممر / الطرقة (Hallway / Corridor).

**غرف النوم:** غرفة النوم الرئيسية (Master Bedroom)، غرفة نوم الأطفال (Kids Bedroom)، غرفة الضيوف (Guest Bedroom)، غرفة الملابس (Dressing Room / Walk-in Closet).

**المساحات الخدمية والعملية:** المكتب / غرفة الدراسة (Office / Study Room)، غرفة الغسيل (Laundry Room)، المخزن (Storage Room / Pantry)، الجراج (Garage)، القبو / السرداب (Basement).

**المساحات الخارجية والترفيهية:** الشرفة / البلكونة (Balcony / Terrace)، الحديقة (Garden / Backyard)، السطح (Roof / Rooftop)، صالة الألعاب الرياضية (Gym / Home Gym)، غرفة الألعاب (Playroom / Game Room)، السور (Fence)، البوابة الرئيسية (Main Gate)، حمام السباحة (Pool).

**مساحات تقنية إضافية مهمة للمعاينة:** مناور الخدمات (Shafts / Lightwells)، السلم (Stairs / Staircase)، غرفة الخادمة (Maid''s Room).

**لماذا يهم هذا في مرحلة المعاينة تحديدًا:** عند تعبئة استمارة معاينة الموقع غرفة بغرفة، استخدام هذه المفردات بالضبط — والتأكد من مطابقتها لما يسميه العميل فعليًا لكل مساحة — يمنع خللًا يجعل، مثلًا، "غرفة الدراسة" لدى العميل تُسجَّل كـ"مكتب" في النظام، ثم يصبح مشهد باسم "Office Lights Off" غير مفهوم له عند محاولة التحكم به صوتيًا.', 1 FROM public.modules WHERE slug = 'finix-terminology-toolkit';
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'Device Terminology: Lighting, Switches, Outlets & Appliances', 'مصطلحات الأجهزة: الإضاءة والمفاتيح والمقابس والأجهزة الكهربائية', 'Alongside room vocabulary, a technician needs a consistent bilingual vocabulary for the devices themselves — this is what goes into proposals, survey forms, and scene-naming conventions.

**Lighting fixtures:** Spotlights / Recessed Lights (سبوتات), Wall Sconces / Wall Lights (بلاكيت), Chandeliers (نجف), Bulbs (لمبات), LED Strip Lights (شريط ليد), Table Lamp (أباجورة), Floor Lamp (لامبدير / لمبة أرضية), Linear LED Profiles (بروفايل ليد), Step / Pathway Lights (كشاف الممر), Track Lights (كشاف توجيهي).

**Switches & outlets:** Light Switch (مفتاح الإضاءة), Dimmer Switch (مفتاح الدايمر — للتحكم في شدة الضوء), Wall Outlet / Socket (البريزة / الفيشة الجدارية), High-Power / AC Switch (مفتاح التكييف - البلاشتيون), Relay Module (الريلاي).

**Living & entertainment appliances:** Air Conditioner / AC (التكييف), Television / TV (التلفزيون), Satellite Receiver (الريسيفر), Projector (جهاز البروجكتور), Fan (المروحة), Heater (الدفاية), Vacuum Cleaner (المكنسة الكهربائية).

**Kitchen appliances:** Refrigerator / Fridge (الثلاجة), Deep Freezer (الديب فريزر), Stove / Cooker / Hob (البوتاجاز), Oven (الفرن), Microwave (الميكروويف), Air Fryer (القلاية الهوائية), Dishwasher (غسالة الأطباق), Range Hood / Exhaust Fan (الشفاط), Water Kettle (الغلاية), Blender (الخلاط).

**Laundry & bath appliances:** Washing Machine (غسالة الملابس), Clothes Dryer (المجفف), Water Heater / Boiler (سخان المياه), Clothes Iron (الكواية), Garment Steamer (كواية البخار العمودية).

**Practical rule:** always record both the English and Arabic term on the survey form for each device the client wants automated — this vocabulary becomes the shared language between the survey team, the programmer building scenes, and the client reviewing the final proposal, so mismatches at this stage are the root cause of most "that''s not what I meant" moments at handoff.', 'بجانب مفردات الغرف، يحتاج الفني مفردات ثنائية اللغة ثابتة للأجهزة نفسها — هذا ما يدخل في المقترحات واستمارات المعاينة واصطلاحات تسمية المشاهد.

**وحدات الإضاءة:** سبوتات (Spotlights / Recessed Lights)، بلاكيت (Wall Sconces)، نجف (Chandeliers)، لمبات (Bulbs)، شريط ليد (LED Strip Lights)، أباجورة (Table Lamp)، لامبدير (Floor Lamp)، بروفايل ليد (Linear LED Profiles)، كشاف الممر (Step / Pathway Lights)، كشاف توجيهي (Track Lights).

**المفاتيح والمقابس:** مفتاح الإضاءة (Light Switch)، مفتاح الدايمر (Dimmer Switch — للتحكم بشدة الضوء)، البريزة / الفيشة الجدارية (Wall Outlet / Socket)، مفتاح التكييف - البلاشتيون (High-Power / AC Switch)، الريلاي (Relay Module).

**أجهزة المعيشة والترفيه:** التكييف (Air Conditioner)، التلفزيون (Television)، الريسيفر (Satellite Receiver)، جهاز البروجكتور (Projector)، المروحة (Fan)، الدفاية (Heater)، المكنسة الكهربائية (Vacuum Cleaner).

**أجهزة المطبخ:** الثلاجة (Refrigerator)، الديب فريزر (Deep Freezer)، البوتاجاز (Stove / Cooker)، الفرن (Oven)، الميكروويف (Microwave)، القلاية الهوائية (Air Fryer)، غسالة الأطباق (Dishwasher)، الشفاط (Range Hood)، الغلاية (Water Kettle)، الخلاط (Blender).

**أجهزة الغسيل والحمام:** غسالة الملابس (Washing Machine)، المجفف (Clothes Dryer)، سخان المياه (Water Heater / Boiler)، الكواية (Clothes Iron)، كواية البخار العمودية (Garment Steamer).

**قاعدة عملية:** سجّل دائمًا المصطلح الإنجليزي والعربي معًا في استمارة المعاينة لكل جهاز يريد العميل أتمتته — تصبح هذه المفردات اللغة المشتركة بين فريق المعاينة والمبرمج الذي يبني المشاهد والعميل الذي يراجع المقترح النهائي، لذا فإن سوء التطابق في هذه المرحلة هو السبب الجذري لأغلب لحظات "هذا ليس ما قصدته" عند التسليم.', 2 FROM public.modules WHERE slug = 'finix-terminology-toolkit';
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'The Smart Home Technician''s Field Toolkit', 'حقيبة أدوات فني المنزل الذكي الميدانية', 'A smart home technician needs a specific toolkit that goes beyond a standard electrician''s bag — part classic electrical tools, part networking gear, part precision instruments. Arriving on site without the right tool means a wasted trip, so this is the checklist I expect a technician''s kit to cover before any job.

**Basic installation & mounting tools:**
- **Insulated screwdriver set** — for removing/installing touch and classic switches (both insulated for electrical safety).
- **Measuring tape** — for determining distances and mounting heights for screens and sensors.
- **Wire drill (SDS type)** — for drilling into walls to mount sensors and cameras.
- **Spirit level** — to ensure touch switches and panels are mounted level on the wall.

**Cable & wiring tools:**
- **Automatic wire strippers** — for precisely stripping sensor and network cable insulation without damaging the conductor.
- **Wire crimping tool (ferrule type)** — for trimming/terminating excess wire neatly inside switch boxes.
- **Soldering iron & solder wire** — for connecting and securing fine sensor wiring.
- **Electrical insulation tape (shrink-wrap type)** — for insulating electrical connections.

**Networking & connectivity tools ("the backbone of smart"):**
- **Network cable crimper (RJ45 crimper)** — for terminating Cat 6 / Cat 7 Ethernet cables.
- **Network cable tester** — for verifying network wiring integrity before closing up walls.
- **Laptop or tablet** — for programming systems like KNX, Zigbee, Z-Wave, and configuring routers/extenders — ideally pre-loaded with every programming app the job might need before leaving the office.

**Measurement & safety equipment:**
- **Multimeter** — for measuring voltage and confirming the presence of a proper neutral wire before starting work.
- **Electrical test screwdriver (voltage tester)** — for identifying the live wire versus the neutral wire before touching any connection.
- **Insulated gloves** — for protection from electrical shock while testing live circuits.

**A pre-departure checklist worth running every time:** confirm the laptop/tablet has the correct programming software for this specific job loaded and working before leaving the office — discovering a missing app on-site, with no signal to download it, turns a scheduled visit into a wasted one.', 'يحتاج فني المنزل الذكي عدة أدوات خاصة تتجاوز حقيبة الكهربائي القياسية — جزء منها أدوات كهربائية تقليدية، وجزء عتاد شبكات، وجزء أدوات قياس دقيقة. الوصول للموقع بدون الأداة الصحيحة يعني زيارة ضائعة، لذا هذه هي قائمة التحقق التي أتوقعها في حقيبة أي فني قبل أي مهمة.

**أدوات التركيب والتثبيت الأساسية:**
- **طقم مفكات معزولة** — لفك وتركيب المفاتيح اللمسية والتقليدية (معزولة للسلامة الكهربائية).
- **شريط قياس (متر)** — لتحديد المسافات وارتفاعات تركيب الشاشات والحساسات.
- **دريل سلكي (شنيور)** — لثقب الجدران لتثبيت الحساسات والكاميرات.
- **ميزان مياه** — لضمان استواء المفاتيح اللمسية واللوحات على الجدار.

**أدوات التعامل مع الأسلاك والتوصيلات:**
- **قشارة أسلاك أوتوماتيكية** — لتقشير أسلاك الحساسات والشبكات بدقة دون إتلاف الموصل.
- **زردية قصافة (بنسة)** — لقص الأسلاك الزائدة داخل علب المفاتيح بشكل مرتب.
- **كاوية لحام وقصدير** — لتوصيل أسلاك الحساسات الدقيقة وتأمينها.
- **شريط لاصق عازل (شركتون)** — لعزل التوصيلات الكهربائية.

**أدوات الشبكات والاتصالات ("العمود الفقري للسمارت"):**
- **أراجة شبكات (RJ45 Crimper)** — لتركيب كابلات إيثرنت Cat 6 / Cat 7.
- **جهاز فحص الكابلات (Network Cable Tester)** — للتأكد من سلامة توصيل أسلاك الشبكة قبل إغلاق الجدران.
- **لابتوب أو تابلت** — لبرمجة الأنظمة مثل KNX وZigbee وZ-Wave، وإعداد الراوتر والمقويات — يُفضَّل تحميله مسبقًا بكل برامج البرمجة التي قد تحتاجها المهمة قبل مغادرة المكتب.

**أجهزة القياس والسلامة:**
- **جهاز الملتيميتر** — لقياس الجهد (الكهرباء) والتأكد من وجود سلك التعادل الصحيح قبل بدء العمل.
- **مفك فحص كهربائي (تيستر)** — لتحديد سلك الفاز (الحار) عن سلك التعادل (Neutral) قبل العمل.
- **قفازات معزولة** — للحماية من الصدمات الكهربائية أثناء الفحص.

**قائمة تحقق قبل المغادرة يستحق تشغيلها في كل مرة:** تأكد أن اللابتوب أو التابلت يحتوي على برنامج البرمجة الصحيح لهذه المهمة تحديدًا ويعمل قبل مغادرة المكتب — اكتشاف تطبيق مفقود في الموقع، بلا إشارة لتحميله، يحوّل زيارة مجدولة إلى زيارة ضائعة.', 3 FROM public.modules WHERE slug = 'finix-terminology-toolkit';
