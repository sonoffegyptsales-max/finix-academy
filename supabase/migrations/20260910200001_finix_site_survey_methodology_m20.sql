-- Module F03: Site Survey Methodology & Standardized Survey Forms
-- Original explanatory writing on site survey process, structured around Finix's own
-- survey checklist categories (room/device types from their internal Excel template).

INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position) VALUES ('finix-site-survey-methodology', 'F03', 'finix-technician-academy', 'Site Survey Methodology & Standardized Survey Forms', 'منهجية مسح الموقع واستمارات المعاينة الموحدة', 'The 5-stage professional site survey workflow, the client/technical questions to ask during a visit, and the 6 standardized survey forms covering every room and subsystem.', 'منهجية المعاينة الاحترافية بمراحلها الخمس، الأسئلة الواجب طرحها على العميل وفنيًا أثناء الزيارة، واستمارات المعاينة الست الموحدة التي تغطي كل غرفة ونظام فرعي.', NULL, 20);
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'Site Survey Methodology: Phases & Objectives', 'منهجية مسح الموقع: المراحل والأهداف', 'No smart home project starts without a site visit. A professional site survey is a scheduled visit to evaluate the electrical/construction status, the internet network, and the client''s needs, with the goal of producing a precise engineering design: selecting compatible devices, determining cost, and estimating the crew size and time needed for installation and programming.

**Why the survey matters:**
- **Network & electrical assessment** — confirming a balanced neutral wire exists behind switches, and checking Wi-Fi signal strength coverage.
- **Needs identification** — studying which devices the client wants automated (lighting, AC, curtains, security) and designing interaction scenarios.
- **Avoiding technical problems** — avoiding device-compatibility issues and ensuring the right protocol is selected (Wi-Fi/Zigbee/Z-Wave).
- **Cost estimation** — determining the scope of work and materials needed before starting.

**The survey procedure differs by construction phase:**
- **Under foundation/wiring stage** — engineering drawings and cable-routing plans are reviewed, and control panel locations are determined to ensure the infrastructure needed for centralized wiring is in place.
- **After finishing/plastering** — solutions that don''t require breaking walls are sought, such as wireless systems relying on smart switches installed in place of ordinary ones.

**Five-stage survey workflow:**
1. **Requirements gathering** — sitting with the client to precisely define what they want controlled in each room, checking AC types to determine the right control unit, confirming electrical wiring exists near windows for curtain motors, and surveying entrances/exits for camera and sensor placement.
2. **Load mapping** — calculating electrical loads per point: lighting type (LED spotlights vs. a heavy chandelier) to select the right dimmer, AC/curtain motor load capacity that smart switches must handle, and distance between devices and the gateway to ensure signal range.
3. **Network assessment** — this stage is the heart of a smart home network: measuring Wi-Fi signal strength in every room, identifying the best locations for access points, and checking that the main electrical panel can accommodate the required smart control units and controllers.
4. **Scene logic analysis** — rather than just counting devices, the technician thinks about how the client will actually live in the space: placing motion sensors where they won''t be triggered by pets but will detect a person entering, and ensuring manual switch positions remain logical and comfortable as an emergency override.
5. **As-built documentation** — the technician leaves the site with photos/videos of every electrical panel and open main board, a rough sketch with numbered points, and a list of technical notes (e.g. "need to change a specific wire" or "add an internet/power point").', 'لا يبدأ أي مشروع منزل ذكي دون زيارة للموقع. المعاينة الاحترافية هي زيارة مخصصة لتقييم الحالة الكهربائية/الإنشائية وشبكة الإنترنت واحتياجات العميل، بهدف وضع تصميم هندسي دقيق: اختيار الأجهزة المتوافقة، تحديد التكلفة، وتقدير عدد أفراد الفريق والمدة اللازمة للتركيب والبرمجة.

**أهمية المعاينة:**
- **تقييم الشبكة والكهرباء** — التأكد من وجود سلك نيوترال متعادل خلف المفاتيح، وفحص قوة تغطية الواي فاي.
- **تحديد الاحتياجات** — دراسة الأجهزة المراد أتمتتها (إضاءة، تكييف، ستائر، أمان) وتصميم سيناريوهات التفاعل.
- **تجنب المشكلات التقنية** — تجنب عدم توافق الأجهزة وضمان اختيار البروتوكول المناسب (Wi-Fi/Zigbee/Z-Wave).
- **تقدير التكلفة** — تحديد حجم العمل والمواد اللازمة قبل البدء.

**تختلف إجراءات المعاينة حسب المرحلة الإنشائية:**
- **تحت التأسيس** — تُفحص المخططات الهندسية وتُحدد مسارات المواسير، وتُحدد أماكن لوحات التحكم لضمان توفر البنية التحتية اللازمة للأسلاك المركزية.
- **بعد التشطيب** — يُبحث عن حلول لا تتطلب تكسير الحوائط، مثل الأنظمة اللاسلكية التي تعتمد على مفاتيح ذكية تُركّب مكان المفاتيح العادية.

**مراحل عملية المعاينة الخمس:**
١. **حصر الاحتياجات** — الجلوس مع العميل لتحديد ما يريد التحكم به بدقة في كل غرفة، فحص أنواع التكييفات لتحديد وحدة التحكم المناسبة، التأكد من وجود تأسيس كهربائي بالقرب من النوافذ لموتورات الستائر، ومعاينة المداخل والمخارج لتحديد مواضع الكاميرات والحساسات.
٢. **تحديد نقاط الحمل** — حساب الأحمال الكهربائية لكل نقطة: نوع الإضاءة (سبوت LED أم ثريا ضخمة) لاختيار الديمر المناسب، سعة تحمل موتور التكييف أو الستارة التي يجب أن تتحملها المفاتيح الذكية، والمسافة بين الأجهزة والبوابة لضمان مدى الإشارة.
٣. **تقييم الشبكة** — هذه المرحلة هي قلب شبكة المنزل الذكي: قياس قوة إشارة الواي فاي في كل غرفة، تحديد أفضل مواقع نقاط الوصول، والتحقق من أن اللوحة الكهربائية الرئيسية تستوعب وحدات التحكم والكنترولرات الذكية المطلوبة.
٤. **تحليل منطق السيناريوهات** — بدلًا من مجرد عد الأجهزة، يفكر الفني في كيف سيعيش العميل فعليًا في المساحة: وضع حساسات الحركة في مكان لا يصطاد الحيوانات الأليفة لكنه يرى الإنسان فور دخوله، والتأكد أن مواضع المفاتيح اليدوية تبقى منطقية ومريحة كتجاوز في حالات الطوارئ.
٥. **توثيق الموقع** — يخرج الفني من الموقع بصور/فيديوهات لكل علبة كهرباء ولوحة رئيسية مفتوحة، رسم كروكي مبدئي مع ترقيم النقاط، وقائمة ملاحظات فنية (مثل "يحتاج تغيير سلك معين" أو "إضافة نقطة إنترنت أو كهرباء").', 1 FROM public.modules WHERE slug = 'finix-site-survey-methodology';
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'Questions to Ask the Client During Survey', 'الأسئلة الواجب طرحها على العميل أثناء المعاينة', '**First: understanding requirements — questions to ask the client**
These questions aim to draw a picture of daily life inside the home:
- What are your priorities? Comfort and lighting control, security and protection, or energy saving?
- Who will use the system? Are there children or elderly who need simple control methods or voice commands?
- Do you prefer control via mobile app, wall switches, or voice? — to determine the right programming interface.
- Are there specific devices already purchased? (e.g. AC units of a certain model, screens) — to confirm compatibility with the system.
- What''s the scenario you imagine when arriving home? — this question reveals the client''s hidden needs for programming.
- Are you planning to add other parts/rooms in the future? — to account for expansions in the panel and cabling from now.

**Second: technical assessment — questions the technician asks themself**
These are the questions that determine system stability and prevent technical problems:
- Does a neutral wire exist in the box? If not, we''ll need to use No-Neutral switches.
- What''s the distance between the farthest device and the gateway? Do I need signal boosters (repeaters) or Mesh Wi-Fi?
- Do concrete walls block signal in the home?
- Do lighting loads match the relay in the switches?
- Where will I place the "brain" (controller)? It must be centralized, away from high-load sources.
- In the case of wired systems, is there room for DIN-rail modules near a power source?
- What''s the internet condition in the area? Do I need a 4G/5G router as a backup copy?

**Third: closing questions — completing the vision**
- What''s the client''s technical level? If not technical, the interface must be simplified to the maximum degree.
- Does the client''s budget match their expectations? If requests exceed the allocated budget, the client must be candidly informed.

A professional survey report — output from these three question sets — reduces the installation error rate significantly.', '**أولًا: فهم المتطلبات — أسئلة تُطرح على العميل**
الهدف من هذه الأسئلة رسم صورة لشكل الحياة داخل المنزل:
- ما هي أولوياتك؟ الرفاهية والتحكم بالإضاءة، أم الأمان والحماية، أم توفير الطاقة؟
- من سيستخدم النظام؟ هل يوجد أطفال أو كبار سن يحتاجون طرق تحكم بسيطة أو أوامر صوتية؟
- هل تفضل التحكم عبر الموبايل أم مفاتيح الحائط أم الصوت؟ — لتحديد نوع الواجهة البرمجية المناسبة.
- هل توجد أجهزة معينة اشتريتها بالفعل؟ (مثل تكييفات بموديلات معينة، شاشات) — للتأكد من توافقها مع النظام.
- ما هو السيناريو الذي تتخيله عند العودة للمنزل؟ — هذا السؤال يكشف احتياجات العميل الخفية في البرمجة.
- هل تخطط لإضافة أجزاء أخرى مستقبلًا؟ — لحساب التوسعات في اللوحة والكابلات من الآن.

**ثانيًا: التقييم الفني — أسئلة يسألها الفني لنفسه**
هذه هي الأسئلة التي تحدد استقرار النظام وتمنع المشكلات التقنية:
- هل يوجد سلك نيوترال في العلبة؟ إذا لم يوجد سنضطر لاستخدام مفاتيح No-Neutral.
- ما المسافة بين أبعد جهاز والبوابة؟ هل أحتاج مقويات إشارة (Repeaters) أو Mesh Wi-Fi؟
- هل جدران المنزل خرسانية تعزل الإشارة؟
- هل أحمال الإضاءة تتوافق مع الريلاي (Relay) الخاص بالمفاتيح؟
- أين سأضع "المخ" (الكنترولر)؟ يجب أن يكون في مكان مركزي بعيدًا عن مصادر الأحمال العالية.
- في حال الأنظمة السلكية، هل يوجد مكان لتركيب وحدات DIN-Rail قريب من مصدر التيار؟
- ما حالة الإنترنت في المنطقة؟ هل أحتاج راوتر شريحة 4G/5G كنسخة احتياطية؟

**ثالثًا: أسئلة استكمال التصور**
- ما مستوى العميل التقني؟ إذا كان غير تقني، يجب تبسيط الواجهة إلى أقصى درجة.
- هل ميزانية العميل تتناسب مع توقعاته؟ إذا كانت طلباته تتخطى الميزانية المرصودة، يجب مصارحة العميل.

تقرير المعاينة الاحترافي — الناتج من مجموعات الأسئلة الثلاث هذه — يقلل نسبة الخطأ في التركيب بشكل ملحوظ.', 2 FROM public.modules WHERE slug = 'finix-site-survey-methodology';
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'Site Survey Forms: Room-by-Room & System-by-System Checklists', 'استمارات المعاينة: قوائم التحقق حسب الغرفة والنظام', 'A professional survey uses structured forms to make sure nothing is missed, covering every room and every subsystem separately. Each form header records: client name, address, phone number, date, surveying engineer, and salesperson.

**1. Room-by-room device count form** — for every room (Main Gate, Main Door, Master Bathroom, Guest Bathroom, Living Room, Reception, Dining Room, Kitchen, Bathroom, Entrance, Corridor, Master Bedroom, Kids Bedroom, Dressing Room, Office, Laundry Room, Storage Room, Garage, Basement, Garage Gate, Terrace, Garden, Fences, Roof, Gym, Stairs, Maid''s Room), record: lighting circuit count, AC unit count, exhaust fan count, TV count, dual-gang switch count, curtain/shutter count.

**2. Fences & outdoor areas form** — for Fences, Main Gate, Garage Gate, Garden: number of lighting circuits and the proposed device/model, plus security devices and their proposed model/quantity.

**3. Main entrance survey form** — a dedicated checklist covering: smart lock, video doorbell, gate opener, smart intercom, door sensor, welcome lighting, entrance lighting, and CCTV/IP camera — each with proposed specification, model/part number, quantity, and notes.

**4. Per-floor lighting & curtain survey form** — repeated per floor (basement, ground, first, second, third, roof) covering: lighting circuit, exhaust fan with proposed device and quantity, shutter/curtain with proposed device and quantity, and an ''S Curtain'' (motorized curtain track) flag, for every room on that floor.

**5. Loads, security & safety survey form** — covering: AC units (type and power rating, control method, quantity), sensors, motors, water valves, gas valves, water heaters, and IR remote devices to be integrated — each with technical specification, control method, quantity, and notes.

**6. CCTV & IP camera survey form** — covering: indoor cameras, outdoor cameras, DVR/NVR, cable, power supply, network switch, hard disk drive (HDD), BNC connectors, 30cm power wire jumpers, and monitor — each with description, quantity, and notes.

Using these six standardized forms during every survey visit — rather than relying on memory or informal notes — is what turns a site visit into a repeatable, professional process that produces an accurate quote and prevents missed devices or rooms during installation.', 'المعاينة الاحترافية تستخدم استمارات منظمة لضمان عدم إغفال أي شيء، تغطي كل غرفة وكل نظام فرعي على حدة. رأس كل استمارة يسجل: اسم العميل، العنوان، رقم التليفون، التاريخ، المهندس القائم بالمعاينة، والبائع.

**١. استمارة عدّ الأجهزة لكل غرفة** — لكل غرفة (البوابة الرئيسية، الباب الرئيسي، حمام ماستر، حمام ضيوف، غرفة المعيشة، الريسيبشن، السفرة، المطبخ، الحمام، المدخل، الطرقة، غرفة النوم الرئيسية، غرفة الأطفال، غرفة الملابس، المكتب، غرفة الغسيل، المخزن، الجراج، القبو، بوابة الجراج، البلكونة، الحديقة، الأسوار، السطح، صالة الألعاب، السلم، غرفة الخادمة)، تُسجَّل: عدد خطوط الإضاءة، عدد وحدات التكييف، عدد الشفاطات، عدد أجهزة التلفاز، عدد المفاتيح الثنائية (Dual)، وعدد الستائر.

**٢. استمارة الأسوار والمناطق الخارجية** — للأسوار، البوابة الرئيسية، بوابة الجراج، الحديقة: عدد خطوط الإضاءة والجهاز المقترح لها، بالإضافة إلى أجهزة الأمان والجهاز المقترح وكميته.

**٣. استمارة معاينة الباب الرئيسي** — قائمة تحقق مخصصة تغطي: الكالون الذكي، جرس الباب المرئي، ماكينة فتح الباب، الإنتركم الذكي، حساس الباب، إضاءة الترحيب، إضاءة المدخل، وكاميرا المراقبة CCTV/IP — كل منها بالمواصفات المقترحة والموديل/رقم القطعة والكمية والملاحظات.

**٤. استمارة معاينة الإضاءة والستائر لكل طابق** — تتكرر لكل طابق (القبو، الأرضي، الأول، الثاني، الثالث، السطح) وتغطي: خط الإضاءة، الشفاط مع الجهاز المقترح وكميته، الستارة/الشاتر مع الجهاز المقترح وكميته، وعلامة "S Curtain" (مسار الستارة المحرَّكة) لكل غرفة في ذلك الطابق.

**٥. استمارة معاينة الأحمال والحماية والأمان** — تغطي: وحدات التكييف (النوع والقدرة، طريقة التحكم، الكمية)، الحساسات، الموتورات، صمامات المياه، صمامات الغاز، سخانات المياه، وأجهزة الريموت بالأشعة تحت الحمراء المراد دمجها — كل منها بالمواصفات الفنية وطريقة التحكم والكمية والملاحظات.

**٦. استمارة معاينة كاميرات المراقبة** — تغطي: الكاميرات الداخلية، الكاميرات الخارجية، جهاز التسجيل DVR/NVR، الكابل، مزود الطاقة، السويتش، القرص الصلب (HDD)، وصلات BNC، أسلاك التغذية طول 30 سم، والشاشة — كل منها بالوصف والكمية والملاحظات.

استخدام هذه الاستمارات الست الموحدة في كل زيارة معاينة — بدلًا من الاعتماد على الذاكرة أو ملاحظات غير رسمية — هو ما يحوّل زيارة الموقع إلى عملية احترافية قابلة للتكرار تنتج عرض سعر دقيقًا وتمنع إغفال أي جهاز أو غرفة أثناء التركيب.', 3 FROM public.modules WHERE slug = 'finix-site-survey-methodology';
