-- Step 4b: Expand M12 (Professional SONOFF Installation & Configuration).

UPDATE public.lessons SET content = $c$Every product family has its own failure mode. This lesson is the checklist that prevents each one.

**In-wall switches — the three checks, in order.**

1. **Isolate and prove dead.** Not "flip the breaker" — isolate, then verify at the terminals with a meter. Egyptian consumer units are frequently mislabelled, and the breaker marked "bedroom" often is not.
2. **Identify the conductors.** You need line, neutral and switched-line. Do not trust colour alone: in older work, reused cable means the blue you assume is neutral may be a switched line. Verify with a meter against earth, breaker on, before you commit.
3. **Check depth and fit before final wiring.** Offer the module into the box with the conductors loose. If it will not seat now, it will not seat with wires terminated, and you will be stripping it back out under tension.

When terminating: keep conductor length short enough to fold neatly but long enough to re-terminate once. Every installer has met the box where a previous fitter cut everything flush and left no second chance.

**Smart plugs — check inrush, not running current.**

A plug rated 16 A will handle a 10 A appliance continuously and still fail if that appliance is a motor with a high starting surge. Compressors, pumps and older washing machines are the usual culprits. If the appliance has a motor, derate substantially or use a contactor driven by the plug rather than the plug itself.

Also check physical fit: a bulky plug in a double socket often blocks the adjacent outlet, which the client discovers after you leave.

**Sensors — placement is the whole job.**

- **Motion (PIR)** detects heat moving *across* its field, not toward it. A sensor facing a doorway sees people much later than one mounted perpendicular to the approach. Mount at the manufacturer's height; higher is not better — it widens coverage but reduces sensitivity to small movements.
- **Contact sensors** need the magnet gap within spec, typically well under a centimetre. A warped door or an uneven frame produces intermittent readings that look like a flat battery and are not.
- **Temperature and humidity** must not sit in direct sun, above a heat source, or in still air behind furniture. A sensor reading a sunbeam is reading the sunbeam.
- **Battery sensors do not route.** They are leaf nodes. They need a mains-powered router within range, which brings us to the gateway.

**Gateways — the placement that determines mesh quality.**

Central, elevated, away from the consumer unit, away from the router, out of metal enclosures. Zigbee and Wi-Fi share 2.4 GHz; a gateway sitting on top of the router is being interfered with by the router.

Plan the mesh before you place the gateway: mains-powered devices are routers, battery devices are not. If the far bedroom has only battery sensors and no mains device between it and the gateway, that bedroom has no mesh — it has hope.

**Wiring discipline that pays for itself.**

Label both ends of everything. Photograph each box before you close it. Leave the client's consumer unit better documented than you found it. The next person in that box may be you, eighteen months later, with no memory of the job.

**The commissioning order that avoids rework.**

Power up and verify each device works locally on its physical button *before* pairing anything. A device that does not switch its load by button will not be fixed by an app. Pair, verify again, then build automation. Commissioning in this order means every fault you find has exactly one possible cause.$c$,
content_ar = $c$لكل عائلة منتجات حالة فشل خاصة بها. وهذا الدرس هو قائمة الفحص التي تمنع كلًا منها.

**المفاتيح داخل الجدار — الفحوص الثلاثة بالترتيب.**

1. **اعزل وأثبت انعدام الجهد.** لا "اقلب القاطع" — بل اعزل ثم تحقق عند الأطراف بجهاز قياس. فلوحات التوزيع المصرية كثيرًا ما تكون مسمّاة خطأ، والقاطع المكتوب عليه "غرفة نوم" غالبًا ليس كذلك.
2. **حدّد الموصلات.** تحتاج حيًا ومحايدًا وحيًا مفتاحًا. ولا تثق باللون وحده: ففي الأعمال الأقدم يعني الكابل المعاد استخدامه أن الأزرق الذي تفترضه محايدًا قد يكون حيًا مفتاحًا. تحقق بجهاز قياس مقابل الأرضي، والقاطع مغلق، قبل أن تلتزم.
3. **افحص العمق والاستقرار قبل التمديد النهائي.** أدخل الوحدة في العلبة والموصلات مرتخية. فإن لم تستقر الآن فلن تستقر والأسلاك موصّلة، وستنزعها تحت شد.

وعند التوصيل: أبقِ طول الموصل قصيرًا بما يكفي للطي بأناقة وطويلًا بما يكفي لإعادة التوصيل مرة. وكل فني قابل العلبة التي قص فيها فني سابق كل شيء عند الحافة ولم يترك فرصة ثانية.

**المقابس الذكية — افحص الاندفاع لا تيار التشغيل.**

مقبس مقنن ١٦ أمبير يتحمل جهازًا بـ١٠ أمبير باستمرار ومع ذلك يفشل إن كان ذلك الجهاز محركًا باندفاع بدء عالٍ. والضواغط والمضخات والغسالات الأقدم هي المعتادة. فإن كان للجهاز محرك فخفّض التصنيف بشكل كبير أو استخدم كونتاكتورًا يقوده المقبس بدل المقبس نفسه.

وافحص أيضًا الاستقرار الفيزيائي: فالمقبس الضخم في مقبس مزدوج يحجب غالبًا المخرج المجاور، ويكتشفه العميل بعد مغادرتك.

**الحساسات — الموضع هو العمل كله.**

- **الحركة (PIR)** تكتشف الحرارة المتحركة *عرضًا* في مجالها لا نحوه. فالحساس المواجه لمدخل يرى الأشخاص متأخرًا كثيرًا عن المركّب عموديًا على مسار الاقتراب. ركّب على ارتفاع المصنّع؛ والأعلى ليس أفضل — فهو يوسّع التغطية ويقلل الحساسية للحركات الصغيرة.
- **حساسات التماس** تحتاج فجوة مغناطيس ضمن المواصفة، أقل بكثير من سنتيمتر عادة. والباب الملتوي أو الإطار غير المستوي ينتج قراءات متقطعة تبدو كبطارية فارغة وليست كذلك.
- **الحرارة والرطوبة** يجب ألا تكون في شمس مباشرة أو فوق مصدر حرارة أو في هواء راكد خلف أثاث. والحساس الذي يقرأ شعاع شمس يقرأ شعاع الشمس.
- **حساسات البطارية لا توجّه.** إنها عقد طرفية. وتحتاج موجّهًا مغذّى من الشبكة ضمن المدى، وهذا يقودنا للبوابة.

**البوابات — الموضع الذي يحدد جودة الشبكة.**

مركزي ومرتفع وبعيد عن لوحة التوزيع وبعيد عن الراوتر وخارج العلب المعدنية. فـZigbee وWi-Fi يتشاركان ٢٫٤ جيجاهرتز؛ والبوابة الجالسة فوق الراوتر يشوّش عليها الراوتر.

وخطط للشبكة قبل وضع البوابة: الأجهزة المغذّاة من الشبكة موجّهات، وأجهزة البطارية ليست كذلك. فإن كانت غرفة النوم البعيدة بها حساسات بطارية فقط ولا جهاز مغذّى بينها وبين البوابة، فتلك الغرفة ليس بها شبكة — بل أمل.

**انضباط التمديد الذي يسدد تكلفته.**

علّم طرفي كل شيء. صوّر كل علبة قبل إغلاقها. واترك لوحة العميل موثّقة أفضل مما وجدتها. فالشخص التالي في تلك العلبة قد يكون أنت بعد ثمانية عشر شهرًا بلا ذاكرة عن العمل.

**ترتيب التشغيل الذي يتجنب إعادة العمل.**

شغّل وتحقق أن كل جهاز يعمل محليًا بزره الفيزيائي *قبل* إقران أي شيء. فالجهاز الذي لا يبدّل حمله بالزر لن يصلحه تطبيق. أقرن ثم تحقق ثانية ثم ابنِ الأتمتة. والتشغيل بهذا الترتيب يعني أن لكل عطل تجده سببًا واحدًا ممكنًا بالضبط.$c$
WHERE title = 'Installation Best Practices by Product Type';

UPDATE public.lessons SET content = $c$Pairing a device is not commissioning it. These settings are what separate an installation that behaves predictably from one that generates support calls.

**Power-on state — the setting that matters after every outage.**

When mains returns after a cut, what should the device do? Three options:

- **Off.** Safe default for anything with a hazard — heaters, motors, anything that should not start unattended.
- **On.** Correct for anything that must always run: a fridge circuit, a router socket, corridor lighting in a shared building.
- **Restore previous state.** Usually what a client expects for room lighting — the house comes back as it was.

Egypt has frequent supply interruptions, so this setting gets exercised far more than in many markets. Choosing it deliberately for every device is a ten-second decision per device that prevents a whole class of complaint. The common failure is leaving everything on factory default and discovering after the first cut that every light in the house came on at 3 a.m.

**Inching / pulse mode — for anything momentary.**

Gates, garage doors and some intercom releases need a *pulse*, not a sustained contact. Inching mode closes the relay for a configured duration — commonly a second or so — then releases automatically.

Set this before connecting the gate motor, not after. A relay left latched across a gate controller's input can hold the controller in a command state and damage it. If you are unsure of the required pulse length, the gate controller's manual states it; guessing produces a gate that half-opens.

**External switch detection — the retrofit essential.**

When a DIY module sits behind an existing mechanical switch, the module must understand what that switch is doing. Two configurations:

- **Edge/momentary mode** for retractive (bell-press) switches.
- **Toggle/state mode** for conventional rocker switches that stay in position.

Get this wrong and the symptom is characteristic: the wall switch works "backwards" — it turns the light off when the app turned it on, and the two controls fight each other. Clients describe this as "the switch is broken". It is a configuration setting.

**Power-on delay for multi-device circuits.** Where several devices share a supply, staggering their startup by a second or two avoids a simultaneous inrush that trips the breaker on restoration. Not every model offers it; where it exists, use it on LED-heavy circuits.

**Firmware discipline.**

Update at commissioning, while you are standing there and have physical access. Never bulk-update a live occupied site remotely. If an update fails mid-flight on a device behind a wall plate, you need to be in the room, not on the phone.

Record the firmware version in your handover document. When a fault appears in six months, knowing what version was working is half the diagnosis.

**Verify the physical button on every device before you leave.**

This is the cheapest insurance in the trade. The physical button is what the client uses when the internet is down, when the app updates badly, or when their phone is flat. A device whose button does not work is a device that has removed functionality from the house rather than adding it — and the client will find out on the worst possible evening.$c$,
content_ar = $c$إقران جهاز ليس تشغيله. وهذه الإعدادات هي ما يفصل تركيبًا يتصرف بشكل متوقع عن تركيب يولّد اتصالات دعم.

**حالة ما بعد التغذية — الإعداد الذي يهم بعد كل انقطاع.**

حين تعود الكهرباء بعد قطع، ماذا يجب أن يفعل الجهاز؟ ثلاثة خيارات:

- **مفصول.** الافتراضي الآمن لأي شيء فيه خطر — دفايات ومحركات وكل ما لا ينبغي أن يبدأ بلا مراقبة.
- **موصول.** صحيح لأي شيء يجب أن يعمل دائمًا: دائرة ثلاجة، أو مقبس راوتر، أو إضاءة ممر في مبنى مشترك.
- **استعادة الحالة السابقة.** عادة ما يتوقعه العميل لإضاءة الغرف — يعود البيت كما كان.

ومصر بها انقطاعات تغذية متكررة، فيُستخدم هذا الإعداد أكثر بكثير من أسواق أخرى. واختياره عمدًا لكل جهاز قرار بعشر ثوانٍ للجهاز يمنع فئة كاملة من الشكاوى. والفشل الشائع هو ترك كل شيء على افتراضي المصنع واكتشاف بعد أول قطع أن كل أنوار البيت أضاءت الثالثة صباحًا.

**وضع النبضة — لأي شيء لحظي.**

البوابات وأبواب الجراج وبعض مفاتيح الإنتركم تحتاج *نبضة* لا تلامسًا مستمرًا. ووضع النبضة يغلق الريليه لمدة مضبوطة — ثانية تقريبًا عادة — ثم يحرره تلقائيًا.

اضبط هذا قبل توصيل محرك البوابة لا بعده. فالريليه المتروك مثبتًا على دخل متحكم بوابة قد يبقي المتحكم في حالة أمر فيتلفه. وإن لم تكن واثقًا من طول النبضة المطلوب فدليل متحكم البوابة يذكره؛ والتخمين ينتج بوابة تفتح نصف فتحة.

**اكتشاف المفتاح الخارجي — أساسي في التحديث.**

حين تجلس وحدة DIY خلف مفتاح ميكانيكي قائم، يجب أن تفهم الوحدة ما يفعله ذلك المفتاح. تهيئتان:

- **وضع الحافة/اللحظي** للمفاتيح الارتدادية (ضغط الجرس).
- **وضع التبديل/الحالة** للمفاتيح التقليدية التي تبقى في موضعها.

أخطئ فيه ويكون العَرَض مميزًا: المفتاح الجداري يعمل "بالعكس" — يطفئ الضوء حين شغّله التطبيق، ويتصارع التحكمان. ويصف العملاء هذا بأن "المفتاح مكسور". وهو إعداد تهيئة.

**تأخير التشغيل لدوائر متعددة الأجهزة.** حيث تتشارك أجهزة عدة تغذية واحدة، يتجنب توزيع بدئها بثانية أو اثنتين اندفاعًا متزامنًا يفصل القاطع عند العودة. ولا يوفره كل موديل؛ وحيث يوجد فاستخدمه في الدوائر الكثيفة بـLED.

**انضباط البرامج الثابتة.**

حدّث عند التشغيل، وأنت واقف هناك ولديك وصول فيزيائي. ولا تحدّث موقعًا مأهولًا جماعيًا عن بُعد أبدًا. فإن فشل تحديث في منتصفه على جهاز خلف غطاء جداري فأنت تحتاج أن تكون في الغرفة لا على الهاتف.

وسجّل إصدار البرنامج الثابت في مستند التسليم. فحين يظهر عطل بعد ستة أشهر تكون معرفة الإصدار الذي كان يعمل نصف التشخيص.

**تحقق من الزر الفيزيائي في كل جهاز قبل المغادرة.**

هذا أرخص تأمين في المهنة. فالزر الفيزيائي هو ما يستخدمه العميل حين ينقطع الإنترنت، أو حين يسوء تحديث التطبيق، أو حين تنفد بطارية هاتفه. والجهاز الذي لا يعمل زره جهاز أزال وظيفة من البيت بدل أن يضيف — وسيكتشف العميل ذلك في أسوأ مساء ممكن.$c$
WHERE title = 'Advanced Device Configuration';

UPDATE public.lessons SET content = $c$Automation is where smart homes either earn their cost or become an expensive irritation. The difference is almost never technical capability — it is design discipline.

**Start from the routine, never from the feature list.**

Ask what the household actually does. When do they leave? Who is home during the day? Which lights get forgotten? What wakes them up? What annoys them about the current house?

Every good automation answers a question the family already has. Every bad one answers a question the app made possible.

A client who says "we always forget the balcony light" has just specified an automation. A client who says nothing and receives twelve scenes because the app supports twelve scenes has received a problem.

**The anatomy: trigger, condition, action.**

- **Trigger** — what starts it. Time, sensor state, device state, geofence, sunrise/sunset.
- **Condition** — what must also be true. Only after dark. Only if someone is home. Except on Fridays.
- **Action** — what happens.

The **condition** is what separates a professional automation from a naive one. "Motion turns on the hall light" is naive: it fires at noon in a sunlit hallway. "Motion turns on the hall light, only between sunset and sunrise, only if the light is currently off" is usable.

**Keep each automation single-purpose.**

One automation that handles arriving home, evening lighting and the AC is impossible to debug. Three separate automations, each doing one thing, can each be tested and disabled independently. When something misbehaves six months later — and something will — single-purpose rules let you find it in minutes.

**Loops: the failure that looks like a poltergeist.**

Automation A turns on a light. The light's state change triggers automation B. B changes something that re-triggers A. The result is a house that cycles on its own, and a client who believes the system is haunted.

Prevent it structurally: never let an automation's action be capable of satisfying its own trigger, and be very careful with device-state triggers on devices that other automations also control. Draw the chain on paper for any site with more than a handful of rules.

**Always leave a manual path.**

Every automated thing must remain operable by hand. The wall switch must still work. The client must be able to override any automation without deleting it. This is not a nicety: it is what stops a temporary glitch from becoming an emergency call, and it is what lets an elderly parent or a guest use the house without an app.

**Timing that respects the household.**

Motion-triggered lights need a hold time long enough that the light does not drop while someone is standing still — a common complaint in bathrooms and stairwells. Automations that run at a fixed time should be checked against the family's actual schedule, not a generic one. Sunset-based timing beats clock-based timing for anything daylight-related, because it tracks the season automatically.

**Test as the client, not as the installer.**

Walk the house and use it normally. Do not test by triggering rules from the app — test by doing what the family will do. Most automation faults only appear when a real person moves through a real house at a real time of day.

**The scene count that gets used.**

Three or four scenes matched to moments the family already recognises — leaving, sleeping, cooking, watching television — will be used daily. Twelve scenes covering every combination will be used once, during the handover demonstration, and never again.$c$,
content_ar = $c$الأتمتة هي حيث تكسب المنازل الذكية تكلفتها أو تصبح إزعاجًا غاليًا. والفرق نادرًا ما يكون قدرة تقنية — بل انضباط تصميم.

**ابدأ من الروتين لا من قائمة الميزات أبدًا.**

اسأل عما تفعله الأسرة فعلًا. متى يخرجون؟ من في البيت نهارًا؟ أي الأنوار تُنسى؟ ما الذي يوقظهم؟ ما الذي يزعجهم في البيت الحالي؟

كل أتمتة جيدة تجيب سؤالًا لدى العائلة أصلًا. وكل سيئة تجيب سؤالًا أتاحه التطبيق.

فالعميل الذي يقول "دائمًا ننسى نور البلكونة" قد حدّد لتوّه أتمتة. والعميل الذي لا يقول شيئًا ويتلقى اثني عشر مشهدًا لأن التطبيق يدعم اثني عشر مشهدًا قد تلقى مشكلة.

**التشريح: مشغّل وشرط وفعل.**

- **المشغّل** — ما يبدؤها. وقت أو حالة حساس أو حالة جهاز أو نطاق جغرافي أو شروق/غروب.
- **الشرط** — ما يجب أن يكون صحيحًا أيضًا. بعد الظلام فقط. إن كان أحد في البيت فقط. عدا الجمعة.
- **الفعل** — ما يحدث.

و**الشرط** هو ما يفصل الأتمتة المحترفة عن الساذجة. فـ"الحركة تشغّل نور الصالة" ساذجة: تعمل ظهرًا في صالة مشمسة. أما "الحركة تشغّل نور الصالة، بين الغروب والشروق فقط، وإن كان النور مطفأً حاليًا فقط" فقابلة للاستخدام.

**أبقِ كل أتمتة أحادية الغرض.**

أتمتة واحدة تعالج العودة للبيت والإضاءة المسائية والتكييف يستحيل تنقيحها. وثلاث أتمتات منفصلة، كل منها تفعل شيئًا واحدًا، يمكن اختبار كل منها وتعطيلها باستقلال. وحين يسوء شيء بعد ستة أشهر — وسيسوء — تتيح القواعد أحادية الغرض إيجاده في دقائق.

**الحلقات: الفشل الذي يبدو كجن.**

الأتمتة (أ) تشغّل نورًا. وتغيّر حالة النور يشغّل الأتمتة (ب). و(ب) تغيّر شيئًا يعيد تشغيل (أ). والنتيجة بيت يدور على نفسه، وعميل يعتقد أن النظام مسكون.

امنعها بنيويًا: لا تدع فعل أتمتة قادرًا على تحقيق مشغّلها، وكن حذرًا جدًا مع مشغّلات حالة الأجهزة على أجهزة تتحكم بها أتمتات أخرى أيضًا. وارسم السلسلة على ورق لأي موقع فيه أكثر من حفنة قواعد.

**اترك دائمًا مسارًا يدويًا.**

كل شيء مؤتمت يجب أن يبقى قابلًا للتشغيل يدويًا. المفتاح الجداري يجب أن يظل يعمل. والعميل يجب أن يستطيع تجاوز أي أتمتة دون حذفها. وهذه ليست رفاهية: بل ما يمنع خللًا مؤقتًا من أن يصبح مكالمة طوارئ، وما يتيح لوالد مسن أو ضيف استخدام البيت بلا تطبيق.

**توقيت يحترم الأسرة.**

الأنوار المشغّلة بالحركة تحتاج زمن إبقاء طويلًا بما يكفي كي لا ينطفئ النور وأحدهم واقف بلا حركة — شكوى شائعة في الحمامات وبيوت الدرج. والأتمتة التي تعمل بوقت ثابت يجب فحصها مقابل جدول العائلة الفعلي لا جدول عام. والتوقيت المبني على الغروب يتفوق على المبني على الساعة في كل ما يتعلق بضوء النهار، لأنه يتتبع الفصول تلقائيًا.

**اختبر كالعميل لا كالفني.**

امشِ في البيت واستخدمه بشكل طبيعي. ولا تختبر بتشغيل القواعد من التطبيق — بل اختبر بفعل ما ستفعله العائلة. فأغلب أعطال الأتمتة لا تظهر إلا حين يتحرك شخص حقيقي في بيت حقيقي في وقت حقيقي من اليوم.

**عدد المشاهد الذي يُستخدم.**

ثلاثة أو أربعة مشاهد مطابقة للحظات تعرفها العائلة أصلًا — الخروج والنوم والطبخ ومشاهدة التلفاز — ستُستخدم يوميًا. واثنا عشر مشهدًا تغطي كل توليفة ستُستخدم مرة واحدة أثناء عرض التسليم ولن تُستخدم أبدًا بعدها.$c$
WHERE title = 'Automation Design Principles';

UPDATE public.lessons SET content = $c$Planning before arrival is what separates a one-visit job from a three-visit job. It costs an hour at a desk and saves a day on site.

**Work from the floor plan.**

Mark every intended device position on a plan of the property. Not a list — a plan, because position is what determines mesh quality, sensor coverage and cable runs, and a list hides all three.

For each position record: what the device controls, which circuit feeds it, whether a neutral is present, back-box depth, and whether the device will be mains-powered or battery.

**Mark the routers, then check the gaps.**

On the plan, mark every mains-powered device — these are your Zigbee routers. Then mark every battery device. Now look for any battery device that has no mains device between it and the gateway, through walls rather than through air.

That is a coverage gap, and it is far cheaper to fix on paper by adding a mains device or a repeater than to discover on commissioning day when the sensor pairs and then drops out an hour later.

**Concrete and steel are the real constraint.**

Egyptian construction is heavily reinforced concrete. A signal that would cross four plasterboard walls may not cross two concrete ones. Plan for the building you are in, not the building in the product brochure's range figure. Range specifications are measured in open air and are close to meaningless indoors.

Count walls and their material along the path between each device and its nearest router. If the answer is more than two solid walls, plan a repeater.

**Gateway placement, decided on the plan.**

Central to the device cluster, elevated, away from the consumer unit and away from the router. If the property is large or spans floors, plan a second gateway — and if you do, plan their Zigbee channels so they do not compete.

**Channel planning.**

Zigbee and 2.4 GHz Wi-Fi share spectrum. Before commissioning, check which Wi-Fi channel the property's router uses, and set the Zigbee channel to sit clear of it. Two gateways on the same Zigbee channel in one property will interfere with each other, and the symptom — devices that pair fine and then respond slowly or intermittently — is one of the hardest faults to diagnose after the fact.

**Load schedule.**

For every switched circuit, record the load type and estimated inrush. This is what determines device rating and prevents the welded-contact failure covered in the product selection lesson. Do it on the plan so the bill of materials falls out of it directly.

**The output of planning.**

A plan pass should produce four things: a device schedule with positions, a bill of materials that matches it, a list of site constraints to confirm on arrival, and a short list of decisions you need from the client before ordering.

That last item is what prevents the most common delay in the trade: arriving with hardware that turns out to be wrong because a question was never asked.$c$,
content_ar = $c$التخطيط قبل الوصول هو ما يفصل مهمة بزيارة واحدة عن مهمة بثلاث زيارات. يكلف ساعة على مكتب ويوفر يومًا في الموقع.

**اعمل من المخطط الأفقي.**

علّم كل موضع جهاز مقصود على مخطط العقار. لا قائمة — بل مخطط، لأن الموضع هو ما يحدد جودة الشبكة وتغطية الحساسات ومسارات الكابلات، والقائمة تخفي الثلاثة.

ولكل موضع سجّل: ما يتحكم به الجهاز، وأي دائرة تغذيه، وهل يوجد محايد، وعمق العلبة الخلفية، وهل سيكون الجهاز مغذّى من الشبكة أم ببطارية.

**علّم الموجّهات ثم افحص الفجوات.**

على المخطط، علّم كل جهاز مغذّى من الشبكة — فهذه موجّهات Zigbee لديك. ثم علّم كل جهاز بطارية. والآن ابحث عن أي جهاز بطارية ليس بينه وبين البوابة جهاز مغذّى، عبر الجدران لا عبر الهواء.

تلك فجوة تغطية، وإصلاحها على الورق بإضافة جهاز مغذّى أو مكرر أرخص بكثير من اكتشافها يوم التشغيل حين يُقرن الحساس ثم ينقطع بعد ساعة.

**الخرسانة والحديد هما القيد الحقيقي.**

البناء المصري خرسانة مسلحة بكثافة. والإشارة التي تعبر أربعة جدران جبسية قد لا تعبر جدارين خرسانيين. خطط للمبنى الذي أنت فيه لا للمبنى في رقم المدى بكتالوج المنتج. فمواصفات المدى تُقاس في الهواء الطلق وتكاد تكون بلا معنى داخل المباني.

عُدّ الجدران وموادها على المسار بين كل جهاز وأقرب موجّه له. فإن كان الجواب أكثر من جدارين صلبين فخطط لمكرر.

**موضع البوابة، يُحسم على المخطط.**

مركزي لتجمّع الأجهزة، مرتفع، بعيد عن لوحة التوزيع وبعيد عن الراوتر. وإن كان العقار كبيرًا أو متعدد الطوابق فخطط لبوابة ثانية — وإن فعلت فخطط لقنوات Zigbee كي لا تتنافسا.

**تخطيط القنوات.**

يتشارك Zigbee وWi-Fi على ٢٫٤ جيجاهرتز الطيف. وقبل التشغيل افحص أي قناة Wi-Fi يستخدمها راوتر العقار، واضبط قناة Zigbee بعيدًا عنها. وبوابتان على نفس قناة Zigbee في عقار واحد ستتداخلان، والعَرَض — أجهزة تُقرن جيدًا ثم تستجيب ببطء أو تقطّع — من أصعب الأعطال تشخيصًا بعد وقوعه.

**جدول الأحمال.**

لكل دائرة مفتاحة، سجّل نوع الحمل والاندفاع المقدّر. وهذا ما يحدد تصنيف الجهاز ويمنع فشل التلامس الملتحم المغطّى في درس اختيار المنتج. افعله على المخطط كي يخرج حصر الكميات منه مباشرة.

**مخرجات التخطيط.**

يجب أن تنتج جولة التخطيط أربعة أشياء: جدول أجهزة بمواضعها، وحصر كميات يطابقه، وقائمة قيود موقع للتأكيد عند الوصول، وقائمة قصيرة بقرارات تحتاجها من العميل قبل الطلب.

والبند الأخير هو ما يمنع أشيع تأخير في المهنة: الوصول بعتاد يتضح أنه خاطئ لأن سؤالًا لم يُطرح.$c$
WHERE title = 'Using SONOFF Planning Tools';

UPDATE public.lessons SET content = $c$The handover is not paperwork at the end of the job. It is the deliverable that determines whether the installation is used, whether you get called back for trivia, and whether the next technician can work on the site.

**The device inventory.**

Every device, with: its location in the client's own room vocabulary, what it controls, its model, its firmware version at handover, and the circuit that feeds it.

The firmware version matters more than it looks. When something misbehaves in eight months, knowing which version was working is half the diagnosis.

**Credentials, handled properly.**

The client owns the eWeLink account — that was settled at commissioning. Document what access you retain and how they revoke it. If you set Wi-Fi credentials, gateway passwords or a separate IoT network, hand those over in writing and store your copy securely.

Never hand over credentials on a scrap of paper or in a chat message. Never keep the only copy.

**The automation summary — in plain language.**

Not a technical dump. A list a non-technical person can read:

> **Evening** — at sunset, the living room and hall lights come on at 40%.
> **Away** — when both phones leave, everything except the fridge socket turns off.
> **Hall motion** — between sunset and sunrise, movement in the hall turns the light on for 3 minutes.

That is a document the client can hand to a family member. A screenshot of the automation editor is not.

**The troubleshooting sheet.**

Half a page, covering the three things that actually happen:

1. **A device is offline.** Check its breaker, check the physical button works, power-cycle it, wait two minutes.
2. **The app cannot connect.** Check the phone's internet, check the router, restart the app.
3. **An automation did not run.** Check whether it was manually overridden, check the schedule, check the trigger device is online.

Add your contact method and what counts as an emergency.

**The demonstration — the part most installers rush.**

Walk the client through the house and have *them* operate it. Not you demonstrating: them doing it, with you watching. Every scene, every wall switch, the override path, and what happens during a power cut.

A client who has physically used the system once is dramatically more likely to keep using it. A client who watched someone else use it has seen a demonstration and retained nothing.

**Have them prove the offline path.**

Show them that the wall switches still work with the internet disconnected. This single demonstration prevents more panicked calls than anything else in the handover, because the first internet outage is otherwise experienced as "the whole system has failed".

**The as-built record, for the next person.**

Photographs of every box before closing, the final device schedule, the circuit map, and any deviation from the plan with the reason. Store it where you will find it in two years.

The next person in that back box may well be you, with no memory of this job. Write the document you would want to find.$c$,
content_ar = $c$التسليم ليس أوراقًا في نهاية العمل. بل هو المُخرَج الذي يحدد هل يُستخدم التركيب، وهل تُستدعى لأمور تافهة، وهل يستطيع الفني التالي العمل في الموقع.

**حصر الأجهزة.**

كل جهاز مع: موقعه بمفردات غرف العميل نفسه، وما يتحكم به، وموديله، وإصدار برنامجه الثابت عند التسليم، والدائرة التي تغذيه.

وإصدار البرنامج الثابت يهم أكثر مما يبدو. فحين يسوء شيء بعد ثمانية أشهر تكون معرفة الإصدار الذي كان يعمل نصف التشخيص.

**بيانات الاعتماد، بمعالجة صحيحة.**

العميل يملك حساب eWeLink — حُسم ذلك عند التشغيل. وثّق ما تحتفظ به من وصول وكيف يسحبه. وإن ضبطت بيانات واي فاي أو كلمات مرور بوابة أو شبكة إنترنت أشياء منفصلة فسلّمها كتابة واحفظ نسختك بأمان.

لا تسلّم بيانات اعتماد على قصاصة ورق أو في رسالة دردشة أبدًا. ولا تحتفظ بالنسخة الوحيدة أبدًا.

**ملخص الأتمتة — بلغة بسيطة.**

لا تفريغ تقني. بل قائمة يقرأها شخص غير تقني:

> **المساء** — عند الغروب تضيء أنوار الصالة والمدخل بنسبة ٤٠٪.
> **الخروج** — حين يغادر الهاتفان يُفصل كل شيء عدا مقبس الثلاجة.
> **حركة المدخل** — بين الغروب والشروق تشغّل الحركة في المدخل النور لثلاث دقائق.

هذا مستند يستطيع العميل تسليمه لفرد من العائلة. ولقطة شاشة لمحرر الأتمتة ليست كذلك.

**ورقة استكشاف الأعطال.**

نصف صفحة تغطي الأمور الثلاثة التي تحدث فعلًا:

1. **جهاز غير متصل.** افحص قاطعه، وتأكد أن الزر الفيزيائي يعمل، وأعد تغذيته، وانتظر دقيقتين.
2. **التطبيق لا يتصل.** افحص إنترنت الهاتف، وافحص الراوتر، وأعد تشغيل التطبيق.
3. **أتمتة لم تعمل.** افحص هل جرى تجاوزها يدويًا، وافحص الجدول، وتأكد أن جهاز التشغيل متصل.

وأضف وسيلة الاتصال بك وما يُعد طارئًا.

**العرض العملي — الجزء الذي يستعجله أغلب الفنيين.**

امشِ بالعميل في البيت واجعله *هو* يشغّله. لا أن تعرض أنت: بل هو يفعل وأنت تراقب. كل مشهد وكل مفتاح جداري ومسار التجاوز وماذا يحدث أثناء قطع الكهرباء.

فالعميل الذي استخدم النظام فيزيائيًا مرة أرجح بكثير أن يستمر باستخدامه. والعميل الذي شاهد غيره يستخدمه رأى عرضًا ولم يحتفظ بشيء.

**اجعلهم يثبتون المسار دون اتصال.**

أرِهم أن المفاتيح الجدارية ما تزال تعمل والإنترنت مفصول. وهذا العرض الواحد يمنع مكالمات ذعر أكثر من أي شيء آخر في التسليم، لأن أول انقطاع إنترنت يُعاش وإلا على أنه "النظام كله فشل".

**سجل ما نُفّذ، للشخص التالي.**

صور كل علبة قبل إغلاقها، وجدول الأجهزة النهائي، وخريطة الدوائر، وأي انحراف عن المخطط مع سببه. واحفظه حيث ستجده بعد سنتين.

فالشخص التالي في تلك العلبة قد يكون أنت بلا ذاكرة عن هذا العمل. اكتب المستند الذي تتمنى أن تجده.$c$
WHERE title = 'Project Documentation & Handover';
