-- Step 4d-2: M14 L2 — Dimmer switches, load types and curve settings.

UPDATE public.lessons SET content = $c$Dimmers generate more callbacks than any other device category, and the cause is almost always a mismatch between the dimming method and the load. This lesson is how to get it right the first time.

**Why dimming LEDs is hard.**

An incandescent bulb is a resistive load — a simple filament. Chop the waveform any way you like and it dims smoothly, because it responds to average power.

An LED lamp is not a lamp electrically. It is a driver circuit feeding a semiconductor, and that driver expects a clean supply. Chopping its input produces behaviour the designer may never have tested for: flicker, buzzing, refusal to start at low levels, or a driver that fails early from stress.

This is why "the dimmer is faulty" is usually wrong. The dimmer is working; it is incompatible with that particular driver.

**Leading edge versus trailing edge.**

- **Leading edge (forward phase)** cuts the *start* of each half-cycle. Traditional, robust, and designed for inductive loads — wirewound transformers and incandescent lamps. It is electrically noisy and often produces audible buzz with electronic drivers.
- **Trailing edge (reverse phase)** cuts the *end* of each half-cycle. Gentler, quieter, and the correct choice for electronic transformers and most dimmable LEDs.

**The working rule:** trailing edge for LED and electronic-transformer loads, leading edge for incandescent and wirewound-transformer loads. Set this deliberately — a dimmer left on its default may be in the wrong mode for the load actually fitted.

**Minimum and maximum brightness calibration.**

Most dimmers expose a minimum-level setting, and it is the single most useful adjustment available.

Every LED lamp has a threshold below which its driver cannot sustain a stable output — it flickers, strobes, or drops out entirely. Setting the minimum just above that threshold means the client's dimmer range maps entirely onto the usable region, and the bottom of their slider produces the dimmest *stable* light rather than a flicker.

Calibrate it on site, with the lamps actually installed: lower the level until instability appears, then raise it slightly and set that as the floor. This five-minute procedure eliminates the majority of dimmer complaints.

**"Dimmable" is not a guarantee of compatibility.**

A lamp marked dimmable will dim *with some dimmers*. Compatibility depends on the specific driver and the specific dimmer. Manufacturers publish compatibility lists precisely because the combinations do not all work.

The practical consequence: on any significant dimming job, test one lamp with the intended dimmer before buying forty of them. A client with forty incompatible lamps is an expensive conversation.

**Minimum load.**

Many dimmers specify a minimum load. A single low-wattage LED lamp on a dimmer rated for incandescent loads may fall below it, producing flicker or a lamp that glows faintly when off. Check the figure and add load or change device if the installation sits underneath it.

**Mixing lamps on one circuit.**

Do not. Different drivers on the same dimmer respond differently to the same waveform, and the result is lamps at visibly different brightnesses and inconsistent low-end behaviour. All lamps on a dimmed circuit should be the same model where at all possible.

**What to verify before leaving.**

Full range sweep from minimum to maximum with no flicker, no audible buzz from lamp or dimmer, correct behaviour switching on at a low preset level, and the physical control working with the network down.$c$,
content_ar = $c$الديمرات تولّد استدعاءات أكثر من أي فئة أجهزة أخرى، والسبب دائمًا تقريبًا عدم تطابق بين طريقة التعتيم والحمل. وهذا الدرس كيف تصيبها من المرة الأولى.

**لماذا تعتيم LED صعب.**

اللمبة المتوهجة حمل مقاوم — فتيلة بسيطة. اقطع الموجة كيفما شئت فتعتم بسلاسة، لأنها تستجيب لمتوسط القدرة.

ومصباح LED ليس مصباحًا كهربائيًا. بل دائرة مشغّل تغذي شبه موصل، وذلك المشغّل يتوقع تغذية نظيفة. وقطع دخله ينتج سلوكًا قد لا يكون المصمم اختبره: وميض أو طنين أو رفض البدء عند مستويات منخفضة أو مشغّل يعطل مبكرًا من الإجهاد.

ولهذا فـ"الديمر معطل" خطأ عادة. الديمر يعمل؛ لكنه غير متوافق مع ذلك المشغّل تحديدًا.

**الحافة الأمامية مقابل الخلفية.**

- **الحافة الأمامية (الطور الأمامي)** تقطع *بداية* كل نصف دورة. تقليدية ومتينة ومصممة للأحمال الحثية — المحولات الملفوفة واللمبات المتوهجة. وهي كهربائيًا صاخبة وتنتج غالبًا طنينًا مسموعًا مع المشغّلات الإلكترونية.
- **الحافة الخلفية (الطور العكسي)** تقطع *نهاية* كل نصف دورة. ألطف وأهدأ وهي الخيار الصحيح للمحولات الإلكترونية وأغلب LED القابلة للتعتيم.

**القاعدة العملية:** الحافة الخلفية لأحمال LED والمحولات الإلكترونية، والأمامية للمتوهجة والمحولات الملفوفة. اضبط هذا عمدًا — فالديمر المتروك على افتراضه قد يكون في الوضع الخطأ للحمل المركّب فعلًا.

**معايرة السطوع الأدنى والأقصى.**

أغلب الديمرات تعرض إعداد مستوى أدنى، وهو أنفع تعديل متاح على الإطلاق.

فلكل مصباح LED عتبة لا يستطيع مشغّله تحتها إدامة خرج مستقر — فيومض أو يخفق أو ينقطع تمامًا. وضبط الأدنى فوق تلك العتبة مباشرة يعني أن مدى ديمر العميل ينطبق كله على المنطقة الصالحة، وأن أسفل شريطه ينتج أخفت ضوء *مستقر* لا وميضًا.

عايرها في الموقع بالمصابيح المركّبة فعلًا: اخفض المستوى حتى يظهر عدم الاستقرار ثم ارفعه قليلًا واضبطه أرضية. وهذا الإجراء بخمس دقائق يلغي أغلب شكاوى الديمرات.

**"قابل للتعتيم" ليس ضمانًا للتوافق.**

المصباح الموسوم قابلًا للتعتيم سيعتم *مع بعض الديمرات*. والتوافق يعتمد على المشغّل المحدد والديمر المحدد. والمصنّعون ينشرون قوائم توافق بالضبط لأن التوليفات لا تعمل كلها.

والنتيجة العملية: في أي عمل تعتيم مهم، اختبر مصباحًا واحدًا مع الديمر المقصود قبل شراء أربعين. فالعميل بأربعين مصباحًا غير متوافق محادثة مكلفة.

**الحمل الأدنى.**

كثير من الديمرات تحدد حملًا أدنى. ومصباح LED منخفض القدرة وحيد على ديمر مصنّف لأحمال متوهجة قد يقع تحته، منتجًا وميضًا أو مصباحًا يتوهج خفيفًا وهو مطفأ. افحص الرقم وأضف حملًا أو غيّر الجهاز إن جلس التركيب تحته.

**خلط المصابيح على دائرة واحدة.**

لا تفعل. فالمشغّلات المختلفة على الديمر نفسه تستجيب للموجة نفسها اختلافًا، والنتيجة مصابيح بسطوع مختلف بصريًا وسلوك طرف منخفض غير متسق. وكل مصابيح دائرة معتّمة يجب أن تكون الموديل نفسه حيثما أمكن.

**ما تتحقق منه قبل المغادرة.**

مسح كامل للمدى من الأدنى للأقصى بلا وميض، وبلا طنين مسموع من المصباح أو الديمر، وسلوك صحيح عند التشغيل على مستوى منخفض مسبق، والتحكم الفيزيائي يعمل والشبكة معطلة.$c$
WHERE title = 'Configuring Dimmer Switches: Load Types & Curve Settings';
