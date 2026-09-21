-- Step 4e-2: M15 L2 — Multi-gateway deployments for larger properties.

UPDATE public.lessons SET content = $c$Adding a second gateway is a decision, not a default. Done deliberately it extends a property cleanly; done reflexively it creates two networks that fight each other.

**When a second gateway is genuinely needed.**

- **The property exceeds one mesh.** Large villas, multi-storey buildings with concrete floors, and separated structures — a main house and an annexe, a house and a workshop — where no chain of router devices can bridge the gap.
- **Device count exceeds the coordinator limit.** Every coordinator has a maximum, set by firmware and memory. Installations approaching it need splitting before they become unstable.
- **Administrative separation is wanted.** A holiday rental where guest-accessible devices should not sit on the owner's network, or a mixed residential and commercial property.

**When it is the wrong answer.**

A weak area caused by a coverage gap does not need a second gateway. It needs a mains-powered router device in the gap, which costs a fraction as much and keeps everything in one network where automations can freely reference any device.

Diagnose coverage properly before proposing a second gateway. Most "we need another gateway" conclusions are actually "we need a smart socket in the hallway".

**Channel planning is mandatory.**

Two coordinators on the same Zigbee channel in radio range of each other will interfere continuously. Assign each gateway a different channel, chosen from the Wi-Fi gaps — 15, 20 and 25 — and record the assignment in the site documentation.

Also plan against the property's Wi-Fi. On a large site with several access points, survey which Wi-Fi channels are actually in use before assigning Zigbee channels, rather than assuming the defaults.

**Device assignment — decide by geography, not convenience.**

Each device belongs to exactly one gateway. Assign by physical zone so that every device pairs to its nearest gateway with a strong link, and so the boundary between zones falls where few devices sit.

The mistake to avoid is pairing devices to whichever gateway happened to be in pairing mode. That produces devices routing across the property to a distant coordinator while a closer one sits idle.

**The cross-gateway automation problem.**

This is the real cost of a multi-gateway design. A device on gateway A cannot directly trigger a device on gateway B — they are separate Zigbee networks.

Cross-gateway logic must run at a layer above both: a hub such as Home Assistant that owns both coordinators, or cloud-level automation in eWeLink. Either adds a dependency and latency to any automation that crosses the boundary.

**Design around it:** keep each automation inside one zone wherever possible. An automation whose trigger and action are on the same gateway is fast and works even if the upper layer is down. A motion sensor on one gateway lighting a lamp on another is a design that will disappoint.

**Documentation that prevents future confusion.**

Record which gateway serves which zone, which channel each uses, and which devices are paired to each. A year later, neither you nor anyone else will remember, and a technician who pairs a replacement device to the wrong gateway creates a fault that looks inexplicable.

A simple table in the handover pack is sufficient and pays for itself the first time anyone returns to site.$c$,
content_ar = $c$إضافة بوابة ثانية قرار لا افتراض. فالمتعمَّدة تمدد عقارًا بنظافة؛ والانعكاسية تخلق شبكتين تتقاتلان.

**متى تُحتاج بوابة ثانية فعلًا.**

- **العقار يتجاوز شبكة واحدة.** فيلات كبيرة ومبانٍ متعددة الطوابق بأرضيات خرسانية ومنشآت منفصلة — بيت رئيسي وملحق أو بيت وورشة — حيث لا تستطيع سلسلة أجهزة موجّهة جسر الفجوة.
- **عدد الأجهزة يتجاوز حد المنسق.** فلكل منسق حد أقصى يضبطه البرنامج والذاكرة. والتركيبات المقتربة منه تحتاج تقسيمًا قبل أن تصبح غير مستقرة.
- **يُراد فصل إداري.** إيجار عطلات حيث يجب ألا تجلس أجهزة الضيوف على شبكة المالك، أو عقار سكني وتجاري مختلط.

**متى يكون الجواب الخطأ.**

المنطقة الضعيفة بسبب فجوة تغطية لا تحتاج بوابة ثانية. بل جهازًا موجّهًا مغذى في الفجوة، يكلف جزءًا يسيرًا ويبقي كل شيء في شبكة واحدة حيث تستطيع الأتمتة الإشارة لأي جهاز بحرية.

شخّص التغطية صحيحًا قبل اقتراح بوابة ثانية. فأغلب استنتاجات "نحتاج بوابة أخرى" هي فعلًا "نحتاج مقبسًا ذكيًا في الممر".

**تخطيط القنوات إلزامي.**

منسقان على قناة Zigbee نفسها ضمن مدى راديو بعضهما سيتداخلان باستمرار. أسند لكل بوابة قناة مختلفة مختارة من فجوات Wi-Fi — ١٥ و٢٠ و٢٥ — وسجّل الإسناد في وثائق الموقع.

وخطط أيضًا مقابل Wi-Fi العقار. ففي موقع كبير بعدة نقاط وصول، امسح أي قنوات Wi-Fi مستخدمة فعلًا قبل إسناد قنوات Zigbee بدل افتراض الافتراضيات.

**إسناد الأجهزة — قرّر بالجغرافيا لا بالراحة.**

كل جهاز يخص بوابة واحدة بالضبط. أسند بالمنطقة الفيزيائية بحيث يقترن كل جهاز بأقرب بوابة إليه بوصلة قوية، وبحيث يقع الحد بين المناطق حيث تجلس أجهزة قليلة.

والخطأ الذي يُتجنب هو إقران الأجهزة بأي بوابة صادف أنها في وضع الإقران. فذلك ينتج أجهزة توجّه عبر العقار لمنسق بعيد بينما أقرب منه يجلس عاطلًا.

**مشكلة الأتمتة عبر البوابات.**

وهذه التكلفة الحقيقية لتصميم متعدد البوابات. فالجهاز على البوابة أ لا يستطيع تشغيل جهاز على البوابة ب مباشرة — فهما شبكتا Zigbee منفصلتان.

والمنطق العابر للبوابات يجب أن يعمل في طبقة فوقهما: بوابة مثل Home Assistant تملك كلا المنسقين، أو أتمتة سحابية في eWeLink. وكلاهما يضيف اعتمادًا وزمن استجابة لأي أتمتة تعبر الحد.

**صمّم حول ذلك:** أبقِ كل أتمتة داخل منطقة واحدة حيثما أمكن. فالأتمتة التي مشغّلها وفعلها على البوابة نفسها سريعة وتعمل حتى لو تعطلت الطبقة العليا. وحساس حركة على بوابة يضيء مصباحًا على أخرى تصميم سيخيّب.

**توثيق يمنع ارتباكًا مستقبليًا.**

سجّل أي بوابة تخدم أي منطقة وأي قناة تستخدم كل منها وأي أجهزة مقترنة بكل. فبعد سنة لن تتذكر أنت ولا غيرك، والفني الذي يقرن جهاز استبدال بالبوابة الخطأ يخلق عطلًا يبدو غير قابل للتفسير.

وجدول بسيط في حزمة التسليم يكفي ويسدد ثمنه أول مرة يعود فيها أحد للموقع.$c$
WHERE title = 'Multi-Gateway Deployments for Larger Properties';

UPDATE public.lessons SET content = $c$Energy monitoring is the feature that most reliably converts a curious client into an enthusiastic one, because it produces a number they can act on. It is also the feature most often installed and then ignored.

**What the device reports.**

- **Instantaneous power (W)** — what is being drawn right now. Drives alerts and automation.
- **Accumulated energy (kWh)** — consumption over time. Drives cost calculations.
- **Voltage (V)** — supply quality. Worth watching in areas with unstable supply.
- **Current (A)** — draw in amps, useful for checking a circuit against its rating.

**Accuracy, stated honestly.** Built-in monitoring in a switch or socket is good enough for trends, comparisons and anomaly detection. It is not revenue-grade metering, and it should never be presented to a client as a billing reference. The useful claim is "this shows you where your consumption goes and when something changes", not "this matches your utility meter".

**The distinction that makes it valuable: standby versus running.**

The insight clients find genuinely surprising is not what their air conditioner costs to run — they expect that. It is what the house draws at three in the morning with everyone asleep.

Measure the baseline. Entertainment systems, set-top boxes, chargers, networking equipment and instant water heaters frequently account for a substantial continuous draw that nobody was aware of. That number is the one that justifies the installation.

**Setting thresholds that work.**

A threshold set from a datasheet generates false alarms. Set them from observation:

1. Let the device log for a week under normal use.
2. Look at the actual peak, the normal running level, and the standby level.
3. Set the alert above the observed peak, with margin for a hot day or a heavier-than-usual cycle.

An alert that fires every day gets muted within a week, and once muted it will not fire when something is genuinely wrong. Very few alerts, each meaningful, is the design goal.

**Automations worth building.**

- **Appliance finished** — a washing machine's draw falls to near zero at the end of a cycle. A notification on that transition is one of the most-liked automations in residential work, and it needs a delay to avoid triggering during the pause between cycle phases.
- **Left on** — a high-draw appliance running past a time it normally never does.
- **Failure detection** — a freezer whose compressor stops cycling, or a pump whose draw changes character. This one has real financial value.
- **Overload warning** — a circuit approaching its rating before the breaker trips.

**Diagnostic use — the professional application.**

Energy data reveals mechanical faults before they become failures. A motor drawing progressively more current over months is developing a bearing problem. A compressor with lengthening run times is losing efficiency or refrigerant. A pump cycling more frequently than it did has a leak or a failing pressure vessel.

This turns the installation from a convenience product into a maintenance tool, and it is a strong argument for a monitoring contract.

**Presenting it to the client.**

Raw kWh means little. Convert to money using their actual tariff, and compare against something they recognise. "The standby draw in this house costs roughly this much a year" is a sentence clients remember and repeat to other people.

Set the tariff correctly during handover — a dashboard showing costs in the wrong currency or at a default rate undermines confidence in everything else on the screen.$c$,
content_ar = $c$مراقبة الطاقة أكثر ميزة تحوّل عميلًا فضوليًا إلى متحمس، لأنها تنتج رقمًا يستطيع التصرف بناءً عليه. وهي أيضًا أكثر ميزة تُركَّب ثم تُهمل.

**ما يبلّغه الجهاز.**

- **القدرة اللحظية (واط)** — ما يُسحب الآن. تقود التنبيهات والأتمتة.
- **الطاقة المتراكمة (كيلوواط ساعة)** — الاستهلاك عبر الزمن. تقود حسابات التكلفة.
- **الجهد (فولت)** — جودة التغذية. يستحق المراقبة في مناطق التغذية غير المستقرة.
- **التيار (أمبير)** — السحب بالأمبير، نافع لفحص دائرة مقابل تصنيفها.

**الدقة بصدق.** المراقبة المدمجة في مفتاح أو مقبس جيدة كفاية للاتجاهات والمقارنات وكشف الشذوذ. وليست قياسًا بدرجة الفوترة، ولا ينبغي تقديمها للعميل كمرجع فوترة أبدًا. والادعاء النافع "هذا يريك أين تذهب استهلاكاتك ومتى يتغير شيء" لا "هذا يطابق عداد المرفق".

**التمييز الذي يجعلها قيّمة: الاستعداد مقابل التشغيل.**

البصيرة التي يجدها العملاء مفاجئة فعلًا ليست كم يكلف تشغيل مكيفهم — فذلك يتوقعونه. بل كم يسحب البيت الثالثة فجرًا والجميع نائم.

قِس خط الأساس. فأنظمة الترفيه وأجهزة الاستقبال والشواحن ومعدات الشبكة والسخانات الفورية تمثل كثيرًا سحبًا مستمرًا معتبرًا لم يكن أحد واعيًا به. وذلك الرقم هو الذي يبرر التركيب.

**ضبط عتبات تعمل.**

العتبة المضبوطة من ورقة بيانات تولّد إنذارات كاذبة. اضبطها من الملاحظة:

١. دع الجهاز يسجل أسبوعًا تحت استخدام طبيعي.
٢. انظر للذروة الفعلية ومستوى التشغيل الطبيعي ومستوى الاستعداد.
٣. اضبط التنبيه فوق الذروة الملاحظة بهامش ليوم حار أو دورة أثقل من المعتاد.

فالتنبيه الذي يعمل يوميًا يُكتم خلال أسبوع، ومتى كُتم لن يعمل حين يكون شيء خطأ فعلًا. وقليل جدًا من التنبيهات كل منها ذو معنى هو هدف التصميم.

**أتمتة تستحق البناء.**

- **انتهى الجهاز** — سحب الغسالة يهبط لقرب الصفر بنهاية الدورة. والإشعار عند ذلك الانتقال من أحب الأتمتة في العمل السكني، ويحتاج تأخيرًا لتجنب العمل أثناء التوقف بين مراحل الدورة.
- **تُرك يعمل** — جهاز عالي السحب يعمل بعد وقت لا يعمل فيه عادة.
- **كشف الأعطال** — مجمد توقف ضاغطه عن الدوران أو مضخة تغيّر طابع سحبها. وهذه ذات قيمة مالية حقيقية.
- **تحذير الحمل الزائد** — دائرة تقترب من تصنيفها قبل فصل القاطع.

**الاستخدام التشخيصي — التطبيق الاحترافي.**

بيانات الطاقة تكشف أعطالًا ميكانيكية قبل أن تصبح فشلًا. فالمحرك الذي يسحب تيارًا متزايدًا عبر أشهر يطوّر مشكلة محمل. والضاغط بأزمنة تشغيل تطول يفقد كفاءة أو وسيط تبريد. والمضخة التي تدور أكثر مما كانت بها تسريب أو وعاء ضغط فاشل.

وهذا يحوّل التركيب من منتج راحة لأداة صيانة، وهو حجة قوية لعقد مراقبة.

**تقديمها للعميل.**

الكيلوواط ساعة الخام يعني قليلًا. حوّل لمال بتعريفته الفعلية وقارن بشيء يعرفه. فـ"سحب الاستعداد في هذا البيت يكلف نحو هذا سنويًا" جملة يتذكرها العملاء ويكررونها لآخرين.

واضبط التعريفة صحيحًا أثناء التسليم — فلوحة تعرض تكاليف بعملة خطأ أو سعر افتراضي تقوّض الثقة بكل شيء آخر على الشاشة.$c$
WHERE title = 'Energy Monitoring: Reading and Acting on Power Data';
