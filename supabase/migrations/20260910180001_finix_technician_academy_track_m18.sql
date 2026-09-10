INSERT INTO public.tracks (id, name, name_ar, tagline, tagline_ar, position) VALUES ('finix-technician-academy', 'Finix Technician Academy', 'أكاديمية فني فينيكس', 'Finix Systems internal technician training: team structure, electrical fundamentals, networking, wireless protocols, and site survey methodology.', 'تدريب فنيي فينيكس سيستمز الداخلي: هيكل الفريق وأساسيات الكهرباء والشبكات والبروتوكولات اللاسلكية ومنهجية مسح الموقع.', 6);

-- Module F01: Team Roles, Skills & Performance Evaluation
-- Transcribed (cleaned/reordered) from Finix's own internal technician onboarding document.

INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position) VALUES ('finix-team-roles-kpi-evaluation', 'F01', 'finix-technician-academy', 'Team Roles, Skills & Performance Evaluation', 'أدوار الفريق والمهارات وتقييم الأداء', 'The 4 core roles in a smart home team, required skills per role, collaborative skills, and the full field performance evaluation form with 5 professional KPIs.', 'الأدوار الأربعة الأساسية في فريق المنزل الذكي، المهارات المطلوبة لكل دور، المهارات الجماعية، واستمارة تقييم الأداء الميداني الكاملة مع 5 مؤشرات أداء احترافية.', NULL, 18);
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'The 4 Core Roles in a Smart Home Team', 'الأدوار الأساسية الأربعة في فريق المنزل الذكي', 'Building a professional smart home team requires blending electrical and networking skills. To succeed, tasks must be split across defined roles:

**1. Network Engineer / Technician** — the backbone of the home. Responsibilities: distributing Wi-Fi access points to cover dead zones, managing the router (static IP reservation, port forwarding when needed), handling different protocols (Zigbee, Z-Wave, Matter), and securing the network with firewalls to protect client privacy.

**2. Installation Technician** — installs and wires the smart devices; ideally more than one person. Must know electrical fundamentals well: distinguishing live/neutral/ground cables, using crimping and stripping tools competently, knowing where wiring connects and installing devices correctly, and knowing how to bind a device to its control program after installation.

**3. Classical Control & Panel Technician** — handles the electrical panel work: relays and contactors for loads, reading and executing electrical diagrams, knowing where the neutral wire sits behind switches (most smart switches need it), and organizing the distribution board so it''s easy to maintain.

**4. UX & Programming Specialist (The Designer)** — the person who makes the system "impress" the client: wide imagination, refined taste, and the ability to simplify technical matters. Skills: programming scenes and automations logically and smoothly, designing control dashboards that are easy for children and the elderly to use, linking voice assistants (Alexa, Google Assistant) and introducing the client to voice commands, and working with aggregation platforms like Home Assistant or Homey.', 'بناء فريق منزل ذكي محترف يتطلب مزيجًا دقيقًا بين مهارات الكهرباء والبرمجيات. لكي ينجح الفريق، يجب أن توزّع المهام على أدوار محددة:

**١- مهندس/فني الشبكات** — هو "العمود الفقري" للمنزل. مسؤولياته: توزيع نقاط الواي فاي لتغطية النطاقات الميتة، إدارة الراوتر (عمل IP ثابت للأجهزة وفتح Port Forwarding إذا لزم الأمر)، التعامل مع البروتوكولات المختلفة (Zigbee, Z-Wave, Matter)، وتأمين الشبكة بجدران حماية لحماية خصوصية العميل.

**٢- فني التركيبات** — هو الفني الذي يمكنه تركيب وتشغيل القطعة الذكية، ويُفضّل أن يكون أكثر من شخص. يجب أن يعرف جيدًا أساسيات الكهرباء: التمييز بين كابلات الكهرباء والأرضي والراجع، التمكن من استخدام العدد مثل البنسة والخلاصة والقشارة، معرفة القطعة الذكية وطريقة تركيبها مع تمييز أماكن توصيل الأسلاك الكهربائية بها، ومعرفة طريقة ربط القطعة بعد التركيب على البرنامج الخاص بها.

**٣- فني التركيبات والتحكم الكلاسيكي** — بما أنك خبير في الدمج، فهذا الشخص هو أنت أو من يمثلك في الموقع. المواصفات: متمكن من التعامل مع اللوحات الكهربائية، يلتزم بمعايير السلامة. المهارات المطلوبة: فهم للتعامل مع الـContactors والـRelays للأحمال، القدرة على قراءة وتنفيذ المخططات الكهربائية، معرفة "مهارة التأسيس الذكي": أين يوضع سلك النيوترال خلف المفاتيح (لأن أغلب القطع الذكية تحتاجه)، وتجهيز لوحات التوزيع بشكل منظم يسهل صيانته.

**٤- متخصص تجربة المستخدم والبرمجة (المصمم)** — هذا هو الشخص الذي يجعل العميل "ينبهر" بالنظام. المواصفات: خيال واسع، ذوق رفيع، وقدرة على تبسيط الأمور التقنية للعميل. المهارات المطلوبة: برمجة السيناريوهات (Scenes) والأتمتة (Automation) بشكل منطقي وسلس، تصميم واجهة التحكم (Dashboards) لتكون سهلة الاستخدام للأطفال وكبار السن، ربط المساعدات الصوتية (Alexa, Google Assistant) وتعريف العميل بالأوامر الصوتية، والقدرة على التعامل مع منصات التجميع مثل Home Assistant أو Homey.', 1 FROM public.modules WHERE slug = 'finix-team-roles-kpi-evaluation';
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'Technical Support & Commercial/Service Aspects', 'الدعم الفني والجانب التجاري والخدمي', 'The technical support role is responsible for answering customer inquiries and solving their problems after handover, whether by phone or internet. Required traits: patient, quick-witted, able to keep information organized, and able to communicate it clearly and politely.

Required skills: knowing the technical details of every product, its function, how to operate and program it; knowing the advantages/disadvantages of each product and how to handle them; solving problems logically, in an organized way, and convincingly for the client; and logging problems — recording solutions, making files and videos to help the client solve issues themselves, and recording how the product connects to the software and to scene creation.

Collective skills the team can''t do without: **Troubleshooting** — the ability to identify a fault and its cause, whether "internet", "the device", or "electricity", then propose and execute solutions. **Customer service patience** in explaining the system to the client after installation — this is the most important stage for guaranteeing a Word of Mouth recommendation. **Documentation** — photographing cables and numbering them, and handing the client a "map" of the system to refer to during faults.', 'الدعم الفني هو المسؤول عن الرد على استفسارات العملاء وحل مشكلاتهم بعد التسليم، سواء بالتليفون أو الإنترنت. المواصفات المطلوبة: سهل ومتحدث لبق وسريع البديهة، والقدرة على الحفاظ على المعلومة وإيصالها بسهولة وصبر.

المهارات المطلوبة: معرفة التفاصيل الفنية للمنتجات وتوظيفها والقدرة على تشغيلها وبرمجتها، معرفة المزايا والعيوب لكل منتج وطرق التعامل معها، القدرة على حل المشكلات بشكل منطقي ومنظم ومقنع للعميل، وتسجيل المشكلات — تسجيل الحلول وعمل ملفات وفيديوهات تساعد العميل على الحل بنفسه، وتسجيل طرق ربط المنتج بالبرنامج وعمل السيناريوهات.

مهارات جماعية لا غنى عنها للفريق: **حل المشكلات (Troubleshooting)** — القدرة على تحديد العطل وأسبابه سواء من "الإنترنت" أم "القطعة" أم "الكهرباء"، ثم اقتراح الحلول وتنفيذها. **خدمة العملاء بالصبر** في شرح النظام للعميل بعد التركيب — وهي أهم مرحلة لضمان التوصية (Word of Mouth). **التوثيق (Documentation)** — تصوير الكابلات وترقيمها، وتسليم العميل "خريطة" للنظام للرجوع إليها وقت الأعطال.', 2 FROM public.modules WHERE slug = 'finix-team-roles-kpi-evaluation';
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'Field Performance Evaluation Form & KPIs', 'استمارة تقييم الأداء الميداني ومؤشرات الأداء', 'Monthly/Project Technical Performance Evaluation Form. Rated from 1 (weak) to 5 (excellent).

**First: Technical performance (60%)**
1. Installation & foundation quality: commitment to neutral wiring, cable numbering, panel cleanliness.
2. Scene programming: automation logic, free of programming conflicts.
3. Network wiring: IP assignment, signal stability across the entire site.
4. "First-time fix" rate: no need for a corrective visit for a technical error.

**Second: Behavioral & administrative skills (40%)**
1. Self-reliance: solving on-site emergency problems smartly and without dependence.
2. Working under pressure: composure during tight timing or sudden device failures.
3. Team cooperation: helping colleagues, communicating programming information clearly.
4. Ethics & professionalism: commitment to appointments, appearance, respecting the client''s home privacy.
5. Managing others: guiding assistants/new cable technicians on company standards.

**Results interpretation:** total 36–45 = excellent technician, deserves recognition/promotion. Total 26–35 = good technician, needs simple guidance. Total below 25 = needs intensive training or role re-evaluation.

**The 5 Key Performance Indicators (KPIs) for a Smart Home technician:**
1. **First-Time Fix Rate** — does the system (lighting, curtains, automation) work correctly right after installation, without errors? Measured by: number of times the technician had to return to site to fix a wiring or device-configuration error caused by poor installation.
2. **Installation Aesthetics** — the panel and cabling must look professional, since the client pays for both beauty and order, not just function. Measured by: commitment to cable labeling and tie routing, and absence of wall damage around switches.
3. **Response & Resolution Time** — especially relevant during the free follow-up period. Measured by: time elapsed from client complaint to issue closure (remote or on-site visit).
4. **Scene Logic Accuracy** — measures the technician''s "intelligence", not just physical skill. Measured by: absence of command conflicts (e.g. a motion sensor turning off the light while the client is still in the room) — a good technician tests "edge cases" before handover.
5. **Customer Satisfaction (NPS)** — the client''s impression of the technician (honesty, appearance, ability to explain). Measured by: asking the client, 1–10, how satisfied they are with the technician''s explanation of how to use the app after handover.', 'استمارة تقييم أداء فني شهري/مشروع. تُقيَّم من 1 (ضعيف) إلى 5 (ممتاز).

**أولًا: الأداء الفني (٪60)**
١. جودة التأسيس والتركيب: الالتزام بالنيوترال، ترقيم الكابلات، نظافة اللوحة.
٢. برمجة السيناريوهات: منطقية الأتمتة، خلوها من التعارضات البرمجية.
٣. الربط الشبكي: تثبيت الـIPs، استقرار الإشارة في كامل الموقع.
٤. نسبة "الإصلاح من أول مرة": عدم الحاجة لزيارة تصحيحية لخطأ فني.

**ثانيًا: المهارات السلوكية والإدارية (٪40)**
١. الاعتماد على النفس: حل المشكلات الطارئة في الموقع بذكاء ودون اتكال.
٢. العمل تحت الضغط: الثبات عند ضيق الوقت أو تعطل الأجهزة فجأة.
٣. التعاون مع الفريق: مساعدة الزملاء، نقل المعلومات البرمجية بوضوح.
٤. الأخلاق والمهنية: الالتزام بالمواعيد، المظهر، خصوصية منزل العميل.
٥. إدارة الآخرين: توجيه المساعدين وفنيي الكوابل الجدد على معايير الشركة.

**كيفية استخدام النتائج:** مجموع 36-45: فني ممتاز يستحق مكافأة/ترقية. مجموع 26-35: فني جيد يحتاج توجيه بسيط. مجموع أقل من 25: يحتاج تدريب مكثف أو إعادة تقييم لوجوده في الفريق.

**أهم 5 مؤشرات أداء رئيسية (KPIs) لقياس تقييم الفنيين لديك:**
١. **معدل نجاح التشغيل من المرة الأولى (First-Time Fix Rate)** — هذا أهم مؤشر للفني المحترف. الهدف: هل يعمل النظام (الإضاءة، الكولان، الأتمتة) فور انتهاء التركيب وبدون أخطاء؟ القياس: عدد المرات التي احتاج فيها الفني للعودة للموقع لإصلاح خطأ في التوصيل أو "تهنيج" في القطعة بسبب سوء التركيب.
٢. **جودة "تقفيل" اللوحة والأسلاك (Installation Aesthetics)** — في السمارت هوم، العميل يدفع مقابل "الجمال" والترتيب. الهدف: يجب أن تكون لوحة الـDB والمفاتيح لوحة فنية. القياس: التزام الفني بوضع Tags على الأسلاك وترتيب الكابلات باستخدام Cable Ties، وعدم وجود جروح في دهان الحوائط حول المفاتيح.
٣. **زمن الاستجابة والحل (Resolution Time & Response)** — خاصة في مرحلة المتابعة المجانية التي قررت إضافتها. الهدف: سرعة الرد على استفسار العميل وحل المشكلة. القياس: الوقت المستغرق من تواصل العميل بالشكوى حتى إغلاق تذكرة الدعم (سواء عن بعد أو بزيارة).
٤. **كفاءة "برمجة السيناريوهات" (Scene Logic Accuracy)** — هذا يقيس "ذكاء" الفني وليس فقط قوته البدنية. الهدف: هل الأتمتة التي صممها منطقية؟ القياس: عدم تداخل الأوامر (مثلاً: حساس الحركة لا يطفئ الضوء والعميل لا يزال في الغرفة). فني جيد هو من يختبر "الحالات الشاذة" قبل تسليم العميل.
٥. **تقييم رضا العميل (Customer Satisfaction / NPS)** — الهدف: انطباع العميل عن الفني (الأمانة، المظهر، القدرة على الشرح). القياس: سؤال العميل بعد التسليم من 1 إلى 10، ما مدى رضاك عن شرح الفني لكيفية استخدام التطبيق؟', 3 FROM public.modules WHERE slug = 'finix-team-roles-kpi-evaluation';
