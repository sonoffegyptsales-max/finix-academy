-- Step 4d-3: M14 L3 — Air quality monitoring and environmental sensors.

UPDATE public.lessons SET content = $c$An air-quality sensor is only as good as its placement. A correctly specified sensor in the wrong position reports numbers that are technically accurate and practically meaningless.

**What these sensors actually measure.**

- **CO2** — the direct proxy for ventilation adequacy and occupancy. Outdoor air sits around 400–420 ppm. Below 800 ppm indoors is comfortable, 1000–1400 ppm produces noticeable drowsiness and reduced concentration, and above 1500 ppm the space is clearly under-ventilated. This is the reading that drives ventilation automation.
- **VOC** — volatile organic compounds from cleaning products, paint, furniture off-gassing, cooking. Usually reported as an index rather than an absolute concentration, because the sensor responds to a mixture of gases rather than identifying any one.
- **PM2.5** — fine particulates, from outdoor pollution, cooking and smoke. The reading that matters most in dusty environments and near busy roads.
- **Temperature and humidity** — comfort and, in humid climates, the mould risk indicator. Sustained relative humidity above roughly 60% supports mould growth.

**The critical distinction: true NDIR CO2 versus estimated eCO2.**

Many inexpensive sensors do not measure CO2 at all. They measure VOC and *estimate* a CO2-equivalent figure from it. The reading is labelled eCO2 and it is a derived number, not a measurement.

This matters because VOC and CO2 do not track together. Someone cleaning with a solvent produces a VOC spike and therefore a high eCO2 reading in a well-ventilated room. A crowded but chemically clean room produces genuine CO2 rise that an eCO2 sensor may understate.

If ventilation automation depends on the reading, specify a true NDIR sensor. If the client simply wants general air-quality awareness, an eCO2 device is adequate — but say which one you installed.

**Placement — the rules that decide validity.**

- **Breathing height.** Roughly 1.1 to 1.5 m for a seated space. Sensors at ceiling level read stratified air; sensors at skirting level read floor draughts.
- **Away from direct airflow.** Never in front of an air-conditioning outlet, an open window, or a fan. Moving air is exchanged air, and the sensor reports the supply rather than the room.
- **Away from heat sources.** Screens, lamps, appliances and direct sunlight all corrupt the temperature reading and, through it, the humidity calculation.
- **Away from the kitchen and bathroom** unless that is the deliberate target. Cooking and showering produce enormous local VOC, particulate and humidity spikes that do not represent the living space.
- **Not in a corner or behind furniture.** Air stagnates there, so the sensor responds slowly and reports a pocket rather than the room.
- **Away from doorways.** Draught paths give transient readings uncorrelated with the space.

**Self-heating.** A mains-powered sensor generates its own heat. A device reading one to two degrees above true room temperature is usually doing exactly that. Check against a reference thermometer after installation and apply the offset correction if the device supports one.

**Calibration and drift.**

CO2 sensors drift. Many use automatic baseline calibration, which assumes the space reaches outdoor CO2 levels periodically — true for a normal home overnight, false for a continuously occupied space or a sealed room. In those cases the baseline algorithm slowly corrupts the reading, and the sensor needs either manual calibration or a model without ABC.

**Explaining the numbers to the client.**

Raw ppm figures mean nothing to most people. The value of the installation is in the interpretation: "above this number, open a window" or, better, an automation that runs the ventilation so nobody has to watch a number at all.

Air quality is also the easiest category to sell, because the client can *feel* the result — the stuffy afternoon meeting room that stops being stuffy is a more persuasive demonstration than any chart.$c$,
content_ar = $c$حساس جودة الهواء بجودة موضعه فقط. فالحساس المحدَّد صحيحًا في الموضع الخطأ يبلّغ أرقامًا دقيقة تقنيًا وبلا معنى عمليًا.

**ما تقيسه هذه الحساسات فعلًا.**

- **ثاني أكسيد الكربون** — الوكيل المباشر لكفاية التهوية والإشغال. الهواء الخارجي نحو ٤٠٠–٤٢٠ جزءًا بالمليون. وتحت ٨٠٠ داخليًا مريح، و١٠٠٠–١٤٠٠ ينتج نعاسًا ملحوظًا وتركيزًا أقل، وفوق ١٥٠٠ يكون الحيز ناقص التهوية بوضوح. وهذه القراءة التي تقود أتمتة التهوية.
- **المركبات العضوية المتطايرة** — من منظفات ودهانات وانبعاث أثاث وطبخ. تُبلَّغ عادة كمؤشر لا تركيز مطلق، لأن الحساس يستجيب لخليط غازات لا يعرّف واحدًا بعينه.
- **الجسيمات الدقيقة ٢٫٥** — من تلوث خارجي وطبخ ودخان. القراءة الأهم في البيئات المغبرة وقرب الطرق المزدحمة.
- **الحرارة والرطوبة** — الراحة، وفي المناخات الرطبة مؤشر خطر العفن. فالرطوبة النسبية المستمرة فوق ٦٠٪ تقريبًا تدعم نمو العفن.

**التمييز الحرج: NDIR حقيقي مقابل eCO2 مقدَّر.**

كثير من الحساسات الرخيصة لا تقيس ثاني أكسيد الكربون إطلاقًا. بل تقيس المركبات المتطايرة و*تقدّر* رقمًا مكافئًا منها. والقراءة موسومة eCO2 وهي رقم مشتق لا قياس.

وهذا يهم لأن المتطايرات وثاني أكسيد الكربون لا يتحركان معًا. فمن ينظف بمذيب ينتج قفزة متطايرات وبالتالي قراءة eCO2 عالية في غرفة جيدة التهوية. والغرفة المزدحمة لكن النظيفة كيميائيًا تنتج ارتفاعًا حقيقيًا قد يقلله حساس eCO2.

فإن اعتمدت أتمتة التهوية على القراءة فحدّد حساس NDIR حقيقيًا. وإن أراد العميل وعيًا عامًا بجودة الهواء فجهاز eCO2 كافٍ — لكن قل أيهما ركّبت.

**الموضع — القواعد التي تحدد الصلاحية.**

- **ارتفاع التنفس.** نحو ١٫١ إلى ١٫٥ متر لحيز جلوس. فالحساسات عند السقف تقرأ هواءً متطبقًا، وعند الوزرة تقرأ تيارات الأرضية.
- **بعيدًا عن التيار المباشر.** لا أمام مخرج تكييف أو نافذة مفتوحة أو مروحة أبدًا. فالهواء المتحرك هواء مستبدل، والحساس يبلّغ التغذية لا الغرفة.
- **بعيدًا عن مصادر الحرارة.** الشاشات والمصابيح والأجهزة وأشعة الشمس المباشرة كلها تفسد قراءة الحرارة، ومن خلالها حساب الرطوبة.
- **بعيدًا عن المطبخ والحمام** إلا إن كان ذلك الهدف المقصود. فالطبخ والاستحمام ينتجان قفزات متطايرات وجسيمات ورطوبة هائلة محليًا لا تمثل حيز المعيشة.
- **ليس في ركن أو خلف أثاث.** فالهواء يركد هناك، فيستجيب الحساس ببطء ويبلّغ جيبًا لا غرفة.
- **بعيدًا عن المداخل.** فمسارات التيار تعطي قراءات عابرة لا ترتبط بالحيز.

**التسخين الذاتي.** الحساس المغذى من الشبكة يولّد حرارته. والجهاز الذي يقرأ درجة أو درجتين فوق حرارة الغرفة الحقيقية يفعل ذلك عادة. افحص مقابل ترمومتر مرجعي بعد التركيب وطبّق تصحيح الإزاحة إن دعمه الجهاز.

**المعايرة والانجراف.**

حساسات ثاني أكسيد الكربون تنجرف. وكثير منها يستخدم معايرة خط أساس تلقائية تفترض أن الحيز يبلغ مستويات الخارج دوريًا — صحيح لمنزل عادي ليلًا، وخطأ لحيز مشغول باستمرار أو غرفة محكمة. وفي تلك الحالات تفسد خوارزمية خط الأساس القراءة ببطء، ويحتاج الحساس معايرة يدوية أو موديلًا بلا ABC.

**شرح الأرقام للعميل.**

أرقام الأجزاء بالمليون الخام لا تعني شيئًا لأغلب الناس. وقيمة التركيب في التفسير: "فوق هذا الرقم افتح نافذة"، أو أفضل، أتمتة تشغّل التهوية فلا يضطر أحد لمراقبة رقم أصلًا.

وجودة الهواء أسهل فئة للبيع أيضًا، لأن العميل *يشعر* بالنتيجة — فغرفة الاجتماعات الخانقة بعد الظهر التي تكف عن الاختناق عرض أقنع من أي رسم بياني.$c$
WHERE title = 'Air Quality Monitoring: Setting Up Environmental Sensors';
