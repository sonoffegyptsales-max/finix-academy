-- Step 4g-2: M17 L2/L3/L4 — zoning strategy, layered diagnosis, handover.

UPDATE public.lessons SET content = $c$Thermostat wiring and commissioning are covered in depth in the Device-Specific Mastery module. This lesson is the layer above: deciding how many control points a property needs and how they should relate.

**The question that comes before wiring.**

"How many thermostats?" is a design decision with comfort and cost consequences, and it is answered by how the building behaves, not by how many rooms it has.

Rooms that need separate control:

- **Different solar exposure.** A south-facing room and a north-facing room on one thermostat means one of them is always wrong.
- **Different occupancy patterns.** Bedrooms occupied at night, living areas during the day, a home office on weekdays.
- **Different thermal behaviour.** A room with large glazing loses and gains heat far faster than an internal one.
- **Different preferences.** The most common real reason — and the one that makes zoning a comfort feature rather than an engineering nicety.

**Where the sensor sits versus where the thermostat sits.**

These need not be the same place, and separating them solves a common problem. A control point on a hallway wall may be convenient to reach but is a poor place to measure comfort — hallways are draughty and unoccupied.

Where the system supports remote sensors, place the sensor where people actually are and leave the interface where it is convenient. A remote sensor in the occupied zone is frequently the cheapest comfort improvement available in an existing installation.

**Zone interaction — the failure nobody anticipates.**

Zones on a shared plant fight each other. One zone calling for heat while an adjacent zone calls for cooling, on a system that can only do one at a time, produces a plant that runs constantly and satisfies nobody.

Design against it: group zones with similar demand onto shared plant, use a changeover strategy on systems that cannot do both simultaneously, and set a deadband between heating and cooling setpoints wide enough that no zone can demand both in quick succession.

**Setback strategy, matched to thermal mass.**

An unoccupied property does not need full comfort, but the saving depends entirely on recovery time.

- **Fast-responding systems** — fan coils, split units — tolerate deep setbacks. Recovery is quick, so the saving is real.
- **Slow systems** — underfloor heating, high thermal mass — do not. A deep setback on underfloor heating takes hours to recover, so the system either runs flat out for a long period or the client arrives to a cold house. Use a shallow setback and a long pre-heat instead.

**Occupancy-driven control, done carefully.** Geofencing and presence detection are the honest way to avoid conditioning an empty house. Build in enough margin for recovery — a system that starts conditioning when the client is two minutes away has not helped.

**The safety limits that must never be automated away.**

Whatever logic sits on top, the following stay in place: freeze protection so pipes cannot freeze regardless of setback; compressor minimum off-time; and a maximum temperature limit on any heating system a child or vulnerable person can reach.

**What to hand over.** Which zones exist, which sensor governs which, what the setback schedule is, and how to change it. A client who cannot adjust their own heating schedule will call you every time the season turns.$c$,
content_ar = $c$تمديد الثرموستات وتشغيله مغطيان بعمق في وحدة إتقان الأجهزة. وهذا الدرس الطبقة الأعلى: تقرير كم نقطة تحكم يحتاج العقار وكيف ينبغي أن تترابط.

**السؤال الذي يسبق التمديد.**

"كم ثرموستات؟" قرار تصميم بعواقب راحة وتكلفة، ويُجاب بكيف يتصرف المبنى لا بكم غرفة فيه.

الغرف التي تحتاج تحكمًا منفصلًا:

- **تعرض شمسي مختلف.** فغرفة جنوبية وأخرى شمالية على ثرموستات واحد تعني أن إحداهما خطأ دائمًا.
- **أنماط إشغال مختلفة.** غرف نوم مشغولة ليلًا ومعيشة نهارًا ومكتب منزلي أيام الأسبوع.
- **سلوك حراري مختلف.** فغرفة بزجاج واسع تفقد وتكسب حرارة أسرع بكثير من داخلية.
- **تفضيلات مختلفة.** أشيع سبب حقيقي — وهو الذي يجعل التقسيم ميزة راحة لا لطافة هندسية.

**أين يجلس الحساس مقابل أين يجلس الثرموستات.**

لا يلزم أن يكونا المكان نفسه، وفصلهما يحل مشكلة شائعة. فنقطة التحكم على جدار ممر قد تكون مريحة الوصول لكنها مكان رديء لقياس الراحة — فالممرات ذات تيارات وغير مشغولة.

وحيث يدعم النظام حساسات بعيدة، ضع الحساس حيث يكون الناس فعلًا واترك الواجهة حيث تكون مريحة. والحساس البعيد في المنطقة المشغولة كثيرًا ما يكون أرخص تحسين راحة متاح في تركيب قائم.

**تفاعل المناطق — الفشل الذي لا يتوقعه أحد.**

المناطق على معدة مشتركة تتقاتل. فمنطقة تطلب تدفئة بينما مجاورة تطلب تبريدًا، على نظام لا يفعل إلا واحدًا في المرة، ينتج معدة تعمل باستمرار ولا ترضي أحدًا.

صمّم ضد ذلك: اجمع المناطق ذات الطلب المتشابه على معدة مشتركة، واستخدم استراتيجية تبديل في الأنظمة التي لا تفعل الاثنين معًا، واضبط نطاقًا ميتًا بين نقطتي ضبط التدفئة والتبريد واسعًا كفاية كيلا تطلب منطقة الاثنين بتتابع سريع.

**استراتيجية التراجع مطابقة للكتلة الحرارية.**

العقار غير المشغول لا يحتاج راحة كاملة، لكن التوفير يعتمد كليًا على زمن الاسترداد.

- **الأنظمة سريعة الاستجابة** — ملفات المراوح والوحدات المنفصلة — تحتمل تراجعات عميقة. فالاسترداد سريع والتوفير حقيقي.
- **الأنظمة البطيئة** — التدفئة الأرضية والكتلة الحرارية العالية — لا تحتمل. فالتراجع العميق في التدفئة الأرضية يأخذ ساعات للاسترداد، فإما يعمل النظام بأقصاه فترة طويلة أو يصل العميل لبيت بارد. استخدم تراجعًا ضحلًا وتسخينًا مسبقًا طويلًا بدلًا منه.

**التحكم المدفوع بالإشغال بعناية.** فالسياج الجغرافي وكشف الحضور الطريقة الصادقة لتجنب تكييف بيت فارغ. وابنِ هامشًا كافيًا للاسترداد — فنظام يبدأ التكييف والعميل على بعد دقيقتين لم يساعد.

**حدود السلامة التي يجب ألا تُؤتمت بعيدًا أبدًا.**

مهما كان المنطق فوقها، تبقى التالية: حماية التجمد كيلا تتجمد المواسير مهما كان التراجع؛ وزمن إطفاء الضاغط الأدنى؛ وحد حرارة أقصى على أي نظام تدفئة يصله طفل أو شخص ضعيف.

**ما تسلّمه.** أي مناطق موجودة وأي حساس يحكم أيها وما جدول التراجع وكيف يُغيَّر. فالعميل الذي لا يستطيع تعديل جدول تدفئته سيتصل بك كلما تغير الفصل.$c$
WHERE title = 'Integrating Thermostats & HVAC Control Points';

UPDATE public.lessons SET content = $c$"The lights stopped working" describes a symptom, not a fault. The instinct to fix the first suspicious thing you see is what turns a twenty-minute call into an afternoon, because it treats symptoms in an order determined by visibility rather than probability.

**Start with questions, not tools.**

Four questions resolve a surprising proportion of calls before you touch anything:

1. **When did it last work?** Establishes whether this is a new installation fault or a degradation.
2. **What changed?** New router, new appliance, a power cut, a firmware update, someone redecorating. Something nearly always changed.
3. **Is it everything or one thing?** The single most informative question — it localises the fault to a layer immediately.
4. **Does it work manually?** Separates the smart layer from the electrical layer in one step.

**The layer model — work bottom-up, always.**

A smart installation is a stack, and a fault at a low layer produces symptoms at every layer above it. Diagnosing top-down means chasing effects.

1. **Electrical** — is there power at the device? Is the breaker on? Does the physical switch work?
2. **Device** — is it powered, are its indicators normal, does it respond to a local press?
3. **Radio** — is it within range, what is its link quality, has anything metallic or electrically noisy appeared nearby?
4. **Gateway** — is it online, powered, and reachable?
5. **Network** — is the router up, is the internet up, has anything changed in the network configuration?
6. **Cloud** — is the vendor's service up? Check the status page before assuming a local fault.
7. **Application logic** — is the automation correct, are its conditions met, was it accidentally disabled?

The discipline is to verify each layer before moving up. A technician who begins at layer 7 rewriting automations, when the fault is a tripped breaker at layer 1, will not find it.

**Divide the search space.**

If several devices fail, find what they share: the same circuit, the same gateway, the same room, the same automation, the same firmware version. The shared element is the fault. This bisection is faster than examining devices one at a time.

**Intermittent faults — the hard category.**

Intermittent means time-dependent, and time-dependence has a cause. Look for what correlates: time of day (solar gain, an automation you forgot about), weather (temperature affecting a battery, rain affecting an outdoor connection), occupancy (bodies absorbing 2.4 GHz), or an appliance cycling (a compressor's inrush disturbing a nearby supply).

When nothing correlates obviously, log rather than guess. A week of data beats a day of speculation, and most platforms will log device availability with no extra hardware.

**Change one thing at a time.**

Changing three things and observing a fix teaches nothing, and leaves two unnecessary changes in place that may cause the next fault. Change one, test, and revert it if it was not the cause.

**Know when to stop and escalate.** If you have worked through the layers without result, stop rather than continuing to make changes. Document what has been eliminated and escalate with that information. An hour of undocumented experimentation makes the next person's job harder, not easier.

**Record the resolution.** The fault, the cause, and the fix. Patterns emerge across sites — the same failure appearing three times signals a product or practice problem worth addressing at source rather than fixing individually forever.$c$,
content_ar = $c$"الأنوار توقفت" يصف عرضًا لا عطلًا. وغريزة إصلاح أول شيء مريب تراه هي ما يحوّل اتصالًا بعشرين دقيقة لبعد ظهيرة، لأنها تعالج الأعراض بترتيب تحدده الرؤية لا الاحتمال.

**ابدأ بأسئلة لا أدوات.**

أربعة أسئلة تحل نسبة مفاجئة من الاتصالات قبل أن تلمس شيئًا:

١. **متى عمل آخر مرة؟** يحدد إن كان عطل تركيب جديد أم تدهورًا.
٢. **ما الذي تغيّر؟** راوتر جديد أو جهاز جديد أو انقطاع كهرباء أو تحديث برنامج أو أحد أعاد الديكور. فشيء تغيّر دائمًا تقريبًا.
٣. **كل شيء أم شيء واحد؟** أكثر الأسئلة إفادة — فيوضّع العطل في طبقة فورًا.
٤. **هل يعمل يدويًا؟** يفصل الطبقة الذكية عن الكهربائية بخطوة واحدة.

**نموذج الطبقات — اعمل من الأسفل للأعلى دائمًا.**

التركيب الذكي كومة، والعطل في طبقة دنيا ينتج أعراضًا في كل طبقة فوقها. والتشخيص من الأعلى مطاردة للآثار.

١. **الكهرباء** — هل هناك طاقة عند الجهاز؟ هل القاطع مغلق؟ هل المفتاح الفيزيائي يعمل؟
٢. **الجهاز** — هل هو مغذى وهل مؤشراته طبيعية وهل يستجيب لضغطة محلية؟
٣. **الراديو** — هل هو ضمن المدى وما جودة وصلته وهل ظهر شيء معدني أو صاخب كهربائيًا قربه؟
٤. **البوابة** — هل هي متصلة ومغذاة ويمكن بلوغها؟
٥. **الشبكة** — هل الراوتر يعمل وهل الإنترنت يعمل وهل تغيّر شيء في إعداد الشبكة؟
٦. **السحابة** — هل خدمة المورّد تعمل؟ افحص صفحة الحالة قبل افتراض عطل محلي.
٧. **منطق التطبيق** — هل الأتمتة صحيحة وهل شروطها متحققة وهل عُطّلت سهوًا؟

والانضباط أن تتحقق من كل طبقة قبل الصعود. فالفني الذي يبدأ في الطبقة ٧ يعيد كتابة الأتمتة والعطل قاطع مفصول في الطبقة ١ لن يجده.

**قسّم فضاء البحث.**

إن فشلت عدة أجهزة فجد ما تتشاركه: الدائرة نفسها أو البوابة نفسها أو الغرفة نفسها أو الأتمتة نفسها أو إصدار البرنامج نفسه. والعنصر المشترك هو العطل. وهذا التنصيف أسرع من فحص الأجهزة واحدًا تلو آخر.

**الأعطال المتقطعة — الفئة الصعبة.**

المتقطع يعني معتمدًا على الوقت، والاعتماد على الوقت له سبب. ابحث عما يرتبط: وقت اليوم (كسب شمسي أو أتمتة نسيتها) أو الطقس (حرارة تؤثر على بطارية أو مطر يؤثر على وصلة خارجية) أو الإشغال (أجساد تمتص ٢٫٤ جيجاهرتز) أو جهاز يدور (اندفاع ضاغط يزعج تغذية قريبة).

وحين لا يرتبط شيء بوضوح، سجّل ولا تخمّن. فأسبوع بيانات يغلب يوم تكهن، وأغلب المنصات تسجل توفر الأجهزة بلا عتاد إضافي.

**غيّر شيئًا واحدًا في المرة.**

فتغيير ثلاثة أشياء وملاحظة إصلاح لا يعلّم شيئًا، ويترك تغييرين غير ضروريين قد يسببان العطل التالي. غيّر واحدًا واختبر وأرجعه إن لم يكن السبب.

**اعرف متى تتوقف وتصعّد.** فإن عملت عبر الطبقات بلا نتيجة فتوقف بدل الاستمرار في التغيير. ووثّق ما استُبعد وصعّد بتلك المعلومات. فساعة تجريب غير موثق تجعل عمل التالي أصعب لا أسهل.

**سجّل الحل.** العطل والسبب والإصلاح. فالأنماط تظهر عبر المواقع — وظهور الفشل نفسه ثلاث مرات يشير لمشكلة منتج أو ممارسة تستحق المعالجة من المنبع بدل إصلاحها فرديًا للأبد.$c$
WHERE title = 'Systematic Troubleshooting: From Symptom to Root Cause';

UPDATE public.lessons SET content = $c$A technically perfect installation that the client cannot use is a failed job. Handover is not the closing formality — it is the step that determines whether the client becomes an advocate or a source of support calls.

**Teach in this order.**

1. **What happens automatically.** Start here, because the client's biggest anxiety is losing control of their own home. Explain what will happen without them doing anything, so nothing surprises them later. A light coming on by itself is delightful when expected and alarming when not.
2. **What they do daily.** The five or six actions they will actually perform. This is the core of the session.
3. **What to do when something is wrong.** The two or three recovery steps that resolve most problems, and when to call you.

**Teach the manual path first, always.**

Before any app, show them that every light still has a switch on the wall. This single demonstration does more for client confidence than anything else in the handover, because it answers the fear underneath all the others: *what if this stops working?*

A client who knows the house works without the technology is relaxed about the technology.

**They must do it, not watch it.**

Demonstration teaches nothing durable. Hand over the phone and have them perform each core task themselves: turn on a light, run a scene, adjust the thermostat, check a camera, let a guest in.

Watching someone do it and doing it yourself produce entirely different retention. It is also how you discover that a label is confusing or an icon is ambiguous — while you are still standing there.

**Train everybody, not just the one who paid.**

The person who commissioned the work is often not the person who uses the house most. Partners, children, parents and domestic staff all need to operate it. A household member who was never shown will either not use the system or will disable things trying to understand them.

Where a full session is not possible, leave the quick reference and offer a short follow-up call.

**Set expectations honestly.**

Say plainly what the system does not do, what depends on internet, what depends on the gateway staying powered, and what needs batteries replacing and roughly when.

A client who was told that remote access needs internet is understanding during an outage. A client who was not feels misled about everything else.

**Leave documentation they will actually read.**

- **A one-page quick reference** — the daily actions, in plain language, on paper, left with them. This is the document that gets used.
- **A device schedule** — what is installed where, with model numbers, for the next technician.
- **Account and network structure** — who owns what, which network is which.
- **Battery list** — which devices have batteries, what type, and expected life.

The one-pager is worth more than a fifty-page manual nobody opens.

**Confirm remote access before leaving.**

Have the client disable Wi-Fi on their phone and control something over cellular data while you are still present. This is the function they will first use away from home, and discovering it does not work at that point produces a support call and a loss of confidence.

**Book the follow-up.**

Schedule a call for two weeks out and say so. It catches the irritating automation they did not think worth reporting, the scene that was almost right, and the family member who was absent at handover.

It also generates work. The two-week call is the natural moment a client asks about extending the system — and a client who has just been reminded that you follow up is a client who recommends you.$c$,
content_ar = $c$التركيب المثالي تقنيًا الذي لا يستطيع العميل استخدامه عمل فاشل. والتسليم ليس شكلية ختامية — بل الخطوة التي تحدد إن صار العميل مناصرًا أم مصدر اتصالات دعم.

**علّم بهذا الترتيب.**

١. **ما يحدث تلقائيًا.** ابدأ هنا لأن أكبر قلق للعميل فقدان السيطرة على بيته. اشرح ما سيحدث دون أن يفعل شيئًا فلا يفاجئه شيء لاحقًا. فالمصباح الذي يضيء وحده مبهج حين يُتوقع ومقلق حين لا.
٢. **ما يفعلونه يوميًا.** الأفعال الخمسة أو الستة التي سيؤدونها فعلًا. وهذا لب الجلسة.
٣. **ماذا يفعلون حين يكون شيء خطأ.** خطوتا أو ثلاث الاسترداد التي تحل أغلب المشاكل ومتى يتصلون بك.

**علّم المسار اليدوي أولًا دائمًا.**

قبل أي تطبيق، أرهم أن كل مصباح ما يزال له مفتاح على الجدار. وهذا العرض وحده يفعل لثقة العميل أكثر من أي شيء آخر في التسليم، لأنه يجيب الخوف الكامن تحت كل الأخرى: *ماذا لو توقف هذا عن العمل؟*

فالعميل الذي يعرف أن البيت يعمل بلا التقنية مرتاح تجاه التقنية.

**يجب أن يفعلوها لا أن يشاهدوها.**

العرض لا يعلّم شيئًا دائمًا. سلّم الهاتف ودعهم يؤدون كل مهمة أساسية بأنفسهم: إضاءة مصباح وتشغيل مشهد وتعديل الثرموستات وفحص كاميرا وإدخال ضيف.

فمشاهدة أحدهم يفعلها وفعلها بنفسك ينتجان احتفاظًا مختلفًا تمامًا. وهي أيضًا كيف تكتشف أن تسمية مربكة أو أيقونة ملتبسة — وأنت ما تزال واقفًا هناك.

**درّب الجميع لا من دفع فقط.**

فمن كلّف بالعمل غالبًا ليس من يستخدم البيت أكثر. فالشركاء والأطفال والوالدون والعاملون المنزليون كلهم يحتاجون تشغيله. وفرد الأسرة الذي لم يُعرض له إما لن يستخدم النظام أو سيعطّل أشياء محاولًا فهمها.

وحيث تتعذر جلسة كاملة، اترك المرجع السريع واعرض مكالمة متابعة قصيرة.

**اضبط التوقعات بصدق.**

قل بوضوح ما لا يفعله النظام وما يعتمد على الإنترنت وما يعتمد على بقاء البوابة مغذاة وما يحتاج استبدال بطاريات ومتى تقريبًا.

فالعميل الذي أُخبر أن الوصول عن بُعد يحتاج إنترنت متفهم أثناء انقطاع. والذي لم يُخبر يشعر أنه ضُلّل بشأن كل شيء آخر.

**اترك وثائق سيقرؤونها فعلًا.**

- **مرجع سريع بصفحة واحدة** — الأفعال اليومية بلغة بسيطة على ورق يُترك معهم. وهذا المستند الذي يُستخدم.
- **جدول أجهزة** — ما رُكّب أين بأرقام الموديلات للفني التالي.
- **بنية الحسابات والشبكة** — من يملك ماذا وأي شبكة أي.
- **قائمة البطاريات** — أي أجهزة بها بطاريات وأي نوع والعمر المتوقع.

والصفحة الواحدة تساوي أكثر من دليل بخمسين صفحة لا يفتحه أحد.

**تأكد من الوصول عن بُعد قبل المغادرة.**

دع العميل يعطّل Wi-Fi في هاتفه ويتحكم بشيء عبر بيانات الجوال وأنت ما تزال حاضرًا. فهذه الوظيفة التي سيستخدمها أول مرة بعيدًا عن البيت، واكتشاف أنها لا تعمل عندئذ ينتج اتصال دعم وفقدان ثقة.

**احجز المتابعة.**

جدول مكالمة بعد أسبوعين وقل ذلك. فهي تلتقط الأتمتة المزعجة التي لم يروا الإبلاغ عنها يستحق والمشهد الذي كان يكاد يصح وفرد الأسرة الغائب عند التسليم.

وتولّد عملًا أيضًا. فمكالمة الأسبوعين اللحظة الطبيعية التي يسأل فيها عميل عن توسيع النظام — والعميل الذي ذُكّر للتو بأنك تتابع هو عميل يوصي بك.$c$
WHERE title = 'Customer Training: Handover That Actually Sticks';
