-- Step 4d-1: M14 L1 — Smart wall sockets and Fusion-series switches.

UPDATE public.lessons SET content = $c$Retrofit is where most installation problems begin, and nearly all of them are decided before you pick up a screwdriver. This lesson is the survey-first discipline that prevents them.

**The three checks that decide whether the job is possible.**

Before quoting, before ordering, before disconnecting anything:

1. **Neutral present?** This is the one that kills jobs. Many older installations wired switch positions with live and switch-return only — no neutral at the switch box. Most smart switches need a neutral to power their radio and processor continuously. No neutral means either a no-neutral-capable model, a different approach entirely (smart relay at the fixture, smart bulbs), or running a neutral, which is often impractical in a finished wall.
2. **Box depth adequate?** A smart module is substantially deeper than the mechanical switch it replaces. Measure the available depth behind the faceplate, and remember the existing conductors have to fold in behind the module. A shallow box in a solid wall is a real obstruction — sometimes solvable with a deeper back box, sometimes not.
3. **Load within rating?** Check the actual connected load against the device rating, and check it for the worst case rather than the normal case. Motor loads and heavily capacitive LED drivers draw inrush current far above their steady-state figure.

**Identifying conductors correctly.**

Never trust cable colour alone. Colour conventions vary by era, by country, and by whoever did the last modification. Confirm with a tester, with the circuit isolated and then briefly energised as needed, that you have identified:

- **Live (permanent)** — present regardless of switch position
- **Switch return / load** — live only when the mechanical switch is closed
- **Neutral** — the return path
- **Earth** — where present; older installations may lack it

The classic trap is a switch box containing what looks like a neutral but is actually a switch return from another circuit. Wiring a device's neutral terminal to that will produce behaviour that looks like a faulty device.

**Isolation discipline.**

Isolate at the breaker, lock off or tag it, and *verify dead at the point of work* with a tester you have proven on a known live source first. The prove-test-prove sequence is not optional and not a formality — testers fail, and a tester that reads dead because its battery is flat has killed people.

**Fusion-series multi-gang considerations.**

Multi-gang smart switches share a single neutral and a single radio across several independently switched outputs. Two consequences follow:

- **All gangs are on one module.** A fault in the module affects every circuit it controls, not one.
- **Load balance matters.** The combined load across all gangs must stay within the module's total rating, which is usually lower than the sum of the per-gang ratings.

**Physical operation must survive.** Confirm after installation that every gang still switches by hand with the network down. A client who cannot turn on a light during a Wi-Fi outage will remember it, and the fix at that point is a return visit.

**Testing before you close the wall.**

Test with the faceplate off and the module accessible: every gang switches its intended load, physical buttons work, the device pairs and responds, and nothing warms abnormally under load. Finding a problem after everything is screwed shut and the furniture is back turns a two-minute fix into an afternoon.$c$,
content_ar = $c$التعديل التحديثي هو حيث تبدأ أغلب مشاكل التركيب، وتقريبًا كلها تُحسم قبل أن تمسك مفكًا. وهذا الدرس هو انضباط المسح أولًا الذي يمنعها.

**الفحوص الثلاثة التي تحدد إن كان العمل ممكنًا.**

قبل التسعير وقبل الطلب وقبل فصل أي شيء:

1. **هل النيوترال موجود؟** هذا الذي يقتل الأعمال. فكثير من التركيبات القديمة وصّلت مواضع المفاتيح بالحي وعائد المفتاح فقط — بلا نيوترال في علبة المفتاح. وأغلب المفاتيح الذكية تحتاج نيوترال لتغذية راديوها ومعالجها باستمرار. وغيابه يعني إما موديلًا يعمل بلا نيوترال أو مقاربة مختلفة تمامًا (ريلاي ذكي عند الوحدة أو لمبات ذكية) أو مد نيوترال، وهو غالبًا غير عملي في جدار منتهٍ.
2. **هل عمق العلبة كافٍ؟** الوحدة الذكية أعمق كثيرًا من المفتاح الميكانيكي الذي تستبدله. قِس العمق المتاح خلف الوجه، وتذكر أن الموصّلات الموجودة يجب أن تنطوي خلف الوحدة. والعلبة الضحلة في جدار مصمت عائق حقيقي — يُحل أحيانًا بعلبة خلفية أعمق وأحيانًا لا.
3. **هل الحمل ضمن التصنيف؟** افحص الحمل الموصول فعلًا مقابل تصنيف الجهاز، وافحصه للحالة الأسوأ لا المعتادة. فأحمال المحركات ومشغّلات LED عالية السعة تسحب تيار اندفاع أعلى بكثير من رقمها المستقر.

**تعريف الموصّلات بشكل صحيح.**

لا تثق بلون الكابل وحده أبدًا. فأعراف الألوان تتباين بالحقبة والبلد ومن أجرى آخر تعديل. وتأكد بجهاز فحص، والدائرة معزولة ثم مغذّاة لحظيًا حسب الحاجة، أنك عرّفت:

- **الحي (الدائم)** — موجود بغض النظر عن وضع المفتاح
- **عائد المفتاح/الحمل** — حي فقط حين يُغلق المفتاح الميكانيكي
- **النيوترال** — مسار العودة
- **الأرضي** — حيث يوجد؛ فالتركيبات الأقدم قد تفتقده

والفخ الكلاسيكي علبة مفتاح تحوي ما يبدو نيوترالًا لكنه فعلًا عائد مفتاح من دائرة أخرى. وتوصيل طرف نيوترال الجهاز به سينتج سلوكًا يبدو كجهاز معطل.

**انضباط العزل.**

اعزل عند القاطع واقفله أو علّمه و*تحقق من انعدام الجهد عند نقطة العمل* بجهاز فحص أثبتّه على مصدر حي معروف أولًا. وتسلسل إثبات-فحص-إثبات ليس اختياريًا ولا شكليًا — فأجهزة الفحص تعطل، وجهاز يقرأ ميتًا لأن بطاريته فرغت قد قتل أشخاصًا.

**اعتبارات سلسلة Fusion متعددة المفاتيح.**

المفاتيح الذكية متعددة المفاتيح تتشارك نيوترالًا واحدًا وراديو واحدًا عبر عدة مخارج مبدَّلة استقلالًا. وينتج عن ذلك أمران:

- **كل المفاتيح على وحدة واحدة.** فالعطل في الوحدة يؤثر على كل دائرة تتحكم بها لا واحدة.
- **توازن الحمل يهم.** فالحمل المجمّع عبر كل المفاتيح يجب أن يبقى ضمن التصنيف الكلي للوحدة، وهو عادة أقل من مجموع تصنيفات كل مفتاح.

**التشغيل الفيزيائي يجب أن ينجو.** تأكد بعد التركيب أن كل مفتاح ما يزال يبدّل يدويًا والشبكة معطلة. فالعميل الذي لا يستطيع إنارة مصباح أثناء انقطاع Wi-Fi سيتذكرها، والإصلاح عندئذ زيارة أخرى.

**الاختبار قبل إغلاق الجدار.**

اختبر والوجه مفكوك والوحدة متاحة: كل مفتاح يبدّل حمله المقصود، والأزرار الفيزيائية تعمل، والجهاز يقترن ويستجيب، ولا شيء يسخن بشكل غير طبيعي تحت الحمل. فاكتشاف مشكلة بعد إغلاق كل شيء وإعادة الأثاث يحوّل إصلاحًا بدقيقتين إلى بعد ظهيرة كاملة.$c$
WHERE title = 'Smart Wall Sockets & Fusion Series Switches: Retrofit Wiring';
