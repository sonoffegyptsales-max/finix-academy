-- Step 4c: Expand M13 (SONOFF Smart Home Integration).

UPDATE public.lessons SET content = $c$Home Assistant is the platform advanced clients ask for by name, and the one that turns a device installer into a systems integrator. Understanding the three routes into it — and which to pick — is the skill that matters.

**Why clients ask for it.** Full local control, no cloud dependency, unlimited automation complexity, and the ability to combine brands that otherwise refuse to speak to each other. For a client who already has devices from three manufacturers, Home Assistant is often the only honest answer.

**Route 1 — Zigbee coordinator (ZHA or Zigbee2MQTT).**

A USB coordinator dongle plugs into the Home Assistant machine and *becomes* the Zigbee gateway. The SONOFF ZBBridge is not used at all; devices pair directly to the coordinator.

This is the strongest option and the one to recommend by default:

- **Entirely local.** No SONOFF cloud, no internet dependency, no account.
- **Fastest response.** No cloud round trip — automations fire in milliseconds.
- **Survives vendor changes.** If SONOFF changes its cloud terms or discontinues a service, nothing on this site is affected.

The cost is that devices are bound to this coordinator. Moving them later means re-pairing everything.

**Route 2 — Matter.**

Matter-certified SONOFF devices join Home Assistant as Matter devices, alongside any other Matter hub. Clean, standards-based, and multi-admin: the same device can appear in Home Assistant *and* Apple Home simultaneously.

The limitation is coverage — only some of the range is Matter-certified, and feature exposure through Matter is sometimes narrower than the native integration.

**Route 3 — the cloud integration.**

Home Assistant talks to eWeLink's cloud, which talks to the devices. It works, it is easy to set up, and it is the weakest option: it depends on internet, on SONOFF's cloud being up, and on the API not changing.

Use it when the other two are not available, and tell the client plainly what the dependency is.

**Entity mapping — check it before you leave.**

Home Assistant models devices as entities with domains: `light`, `switch`, `sensor`, `climate`. A dimmer that imports as `switch` rather than `light` loses brightness control entirely, and the client discovers it when they try to dim something.

Walk the entity list after import. Confirm dimmers expose brightness, that sensors report the right units, and that multi-gang switches appear as separate controllable entities rather than one.

**Naming, done once.**

Home Assistant entity IDs are generated from whatever name existed at pairing. Rename devices *before* building automations, because renaming later breaks every automation referencing the old ID. Use the client's room vocabulary here exactly as in eWeLink.

**Backups — the non-negotiable.**

Configure automatic backups before handing over, and verify one restores. A Home Assistant install represents hours of configuration; an SD card failure without a backup means rebuilding the entire system from memory.

**The honest caveat about recommending Home Assistant.**

It is powerful and it requires maintenance. Updates occasionally break integrations. A client who wants a system they never think about is better served by eWeLink alone. A client who enjoys tinkering, or a property that genuinely needs cross-brand logic, is the right fit.

Recommending Home Assistant to a client who does not want a hobby creates a support burden that lands on you.$c$,
content_ar = $c$Home Assistant هي المنصة التي يطلبها العملاء المتقدمون بالاسم، وهي التي تحوّل مركّب أجهزة إلى مُكامل أنظمة. وفهم المسارات الثلاثة إليها — وأيها تختار — هو المهارة التي تهم.

**لماذا يطلبها العملاء.** تحكم محلي كامل، وبلا اعتماد على سحابة، وتعقيد أتمتة بلا حدود، والقدرة على دمج علامات ترفض أصلًا التحدث معًا. وللعميل الذي لديه أجهزة من ثلاثة مصنّعين تكون Home Assistant غالبًا الجواب الصادق الوحيد.

**المسار ١ — منسق Zigbee (ZHA أو Zigbee2MQTT).**

دونجل منسق USB يوصَل بجهاز Home Assistant و*يصبح* بوابة Zigbee. ولا يُستخدم ZBBridge إطلاقًا؛ بل تُقرن الأجهزة بالمنسق مباشرة.

وهذا أقوى خيار وهو الذي يُنصح به افتراضيًا:

- **محلي بالكامل.** لا سحابة SONOFF ولا اعتماد على إنترنت ولا حساب.
- **أسرع استجابة.** لا رحلة سحابية — فتعمل الأتمتة خلال أجزاء من الألف من الثانية.
- **ينجو من تغيّرات المورّد.** فإن غيّرت SONOFF شروط سحابتها أو أوقفت خدمة فلا يتأثر شيء في هذا الموقع.

والتكلفة أن الأجهزة مرتبطة بهذا المنسق. ونقلها لاحقًا يعني إعادة إقران كل شيء.

**المسار ٢ — Matter.**

أجهزة SONOFF المعتمدة بـ Matter تنضم لـ Home Assistant كأجهزة Matter، جنبًا إلى جنب مع أي بوابة Matter أخرى. نظيف ومبني على معايير ومتعدد الإدارة: فالجهاز نفسه يظهر في Home Assistant *و* Apple Home في آن.

والقيد هو التغطية — فجزء من المدى فقط معتمد بـ Matter، وعرض الميزات عبر Matter أحيانًا أضيق من التكامل الأصلي.

**المسار ٣ — التكامل السحابي.**

تتحدث Home Assistant مع سحابة eWeLink التي تتحدث مع الأجهزة. يعمل، وسهل الإعداد، وهو أضعف الخيارات: يعتمد على الإنترنت وعلى بقاء سحابة SONOFF وعلى عدم تغيّر الواجهة.

استخدمه حين لا يتوفر الآخران، وأخبر العميل بوضوح ما هو الاعتماد.

**ربط الكيانات — افحصه قبل المغادرة.**

تنمذج Home Assistant الأجهزة ككيانات بنطاقات: `light` و`switch` و`sensor` و`climate`. والديمر الذي يُستورد كـ `switch` بدل `light` يفقد التحكم بالسطوع تمامًا، ويكتشفه العميل حين يحاول تعتيم شيء.

راجع قائمة الكيانات بعد الاستيراد. وتأكد أن الديمرات تعرض السطوع، وأن الحساسات تبلّغ بالوحدات الصحيحة، وأن المفاتيح متعددة المفاتيح تظهر ككيانات منفصلة قابلة للتحكم لا ككيان واحد.

**التسمية، تُفعل مرة.**

معرّفات كيانات Home Assistant تُولَّد من الاسم الموجود وقت الإقران. أعد تسمية الأجهزة *قبل* بناء الأتمتة، لأن إعادة التسمية لاحقًا تكسر كل أتمتة تشير للمعرّف القديم. واستخدم مفردات غرف العميل هنا تمامًا كما في eWeLink.

**النسخ الاحتياطية — غير قابلة للتفاوض.**

اضبط نسخًا تلقائية قبل التسليم وتحقق من استعادة واحدة. فتركيب Home Assistant يمثل ساعات من الإعداد؛ وفشل بطاقة الذاكرة بلا نسخة يعني إعادة بناء النظام كله من الذاكرة.

**التحفظ الصادق حول التوصية بـ Home Assistant.**

قوية وتحتاج صيانة. والتحديثات تكسر التكاملات أحيانًا. والعميل الذي يريد نظامًا لا يفكر فيه أبدًا يخدمه eWeLink وحده أفضل. والعميل الذي يستمتع بالعبث، أو العقار الذي يحتاج فعلًا منطقًا عابرًا للعلامات، هو الملاءمة الصحيحة.

والتوصية بـ Home Assistant لعميل لا يريد هواية تخلق عبء دعم يقع عليك.$c$
WHERE title = 'Integrating SONOFF with Home Assistant';

UPDATE public.lessons SET content = $c$Homey occupies the space between eWeLink's simplicity and Home Assistant's complexity: a commercial hub with a polished interface, wide protocol support, and no requirement that the client become a hobbyist.

**What it is.** A physical hub with Zigbee, Z-Wave, Wi-Fi, Bluetooth, infrared and 433 MHz radios built in. That radio breadth is its real advantage — it can absorb legacy devices that neither eWeLink nor a Zigbee-only setup can reach, including older RF remotes and IR-controlled air conditioners.

**Who it suits.** A client with a mixed collection of brands and generations who wants one app and does not want to maintain a server. Homey is the honest recommendation when Home Assistant would be over-specified and eWeLink alone would be under-specified.

**Flow-based automation.**

Homey builds automation as visual "Flows" with a When / And / Then structure, mapping directly onto the trigger / condition / action model from the automation lesson. The visual editor is genuinely usable by clients, which matters: a client who can safely adjust their own automations generates far fewer support calls than one who must phone you to change a time.

Advanced Flows allow branching and parallel paths. Use them sparingly — the same single-purpose discipline applies, and a sprawling visual flow is just as hard to debug as a sprawling script.

**Getting SONOFF devices in.**

Zigbee devices pair directly to Homey's built-in Zigbee radio, bypassing the SONOFF gateway entirely. Wi-Fi devices come in through a community or official eWeLink app, which routes via the cloud with the dependency that implies.

**Capability mapping is the check that matters.**

Homey exposes devices through *capabilities*: `onoff`, `dim`, `measure_temperature`, `target_temperature`. A device whose capabilities are mapped incompletely by its app will appear to work while silently missing functions.

Test every function on every device type after pairing. A dimmer that pairs as on/off only is the most common instance, and it is a five-minute check that prevents a callback.

**Community apps — the real dependency.**

Much of Homey's device support comes from community-maintained apps rather than the manufacturer. They are often excellent. They are also maintained by individuals, and one can be abandoned.

Before committing a client's installation to a community app, check when it was last updated and how actively its issues are answered. If a critical device depends on an unmaintained app, that is a risk you should name in the handover rather than discover later.

**Backups.** Homey offers cloud backup on its subscription tier. Enable it. A hub failure without a backup means re-pairing every device in the property.

**Positioning it commercially.**

Homey costs more than a SONOFF gateway and less than the time Home Assistant demands. When a client says "I want everything in one app and I don't want to think about it", and their devices span several brands, Homey is usually the correct and defensible recommendation.$c$,
content_ar = $c$تحتل Homey المساحة بين بساطة eWeLink وتعقيد Home Assistant: بوابة تجارية بواجهة مصقولة ودعم بروتوكولات واسع وبلا اشتراط أن يصبح العميل هاويًا.

**ما هي.** بوابة فيزيائية بها راديوهات Zigbee وZ-Wave وWi-Fi وبلوتوث وأشعة تحت حمراء و٤٣٣ ميجاهرتز مدمجة. واتساع الراديو هذا ميزتها الحقيقية — فتستطيع استيعاب أجهزة قديمة لا يصلها eWeLink ولا إعداد Zigbee وحده، بما فيها ريموتات RF قديمة ومكيفات تُدار بالأشعة.

**من تناسب.** عميل بمجموعة مختلطة من العلامات والأجيال يريد تطبيقًا واحدًا ولا يريد صيانة خادم. وHomey هي التوصية الصادقة حين تكون Home Assistant مبالغة ويكون eWeLink وحده قاصرًا.

**أتمتة قائمة على التدفقات.**

تبني Homey الأتمتة كـ"تدفقات" مرئية ببنية عندما/و/إذن، تنطبق مباشرة على نموذج المشغّل/الشرط/الفعل من درس الأتمتة. والمحرر المرئي قابل للاستخدام فعلًا من العملاء، وهذا يهم: فالعميل الذي يستطيع تعديل أتمتته بأمان يولّد اتصالات دعم أقل بكثير ممن يجب أن يتصل بك لتغيير وقت.

والتدفقات المتقدمة تتيح التفرع والمسارات المتوازية. استخدمها باعتدال — فانضباط الغرض الواحد نفسه ينطبق، والتدفق المرئي المتشعب يصعب تنقيحه كالسكريبت المتشعب تمامًا.

**إدخال أجهزة SONOFF.**

أجهزة Zigbee تُقرن مباشرة براديو Zigbee المدمج في Homey، متجاوزة بوابة SONOFF تمامًا. وأجهزة Wi-Fi تدخل عبر تطبيق مجتمعي أو رسمي لـ eWeLink يمر بالسحابة بما يعنيه ذلك من اعتماد.

**ربط القدرات هو الفحص الذي يهم.**

تعرض Homey الأجهزة عبر *قدرات*: `onoff` و`dim` و`measure_temperature` و`target_temperature`. والجهاز الذي يربط تطبيقُه قدراتِه ناقصًا سيبدو عاملًا بينما يفقد وظائف صامتًا.

اختبر كل وظيفة في كل نوع جهاز بعد الإقران. والديمر الذي يُقرن كتشغيل/إطفاء فقط هو الحالة الأشيع، وهو فحص بخمس دقائق يمنع استدعاءً.

**تطبيقات المجتمع — الاعتماد الحقيقي.**

كثير من دعم Homey للأجهزة يأتي من تطبيقات يصونها المجتمع لا المصنّع. وهي ممتازة غالبًا. وهي أيضًا مصونة بأفراد، وقد يُهجر أحدها.

وقبل ربط تركيب عميل بتطبيق مجتمعي، افحص متى حُدّث آخر مرة وكم تُجاب مشكلاته بنشاط. فإن اعتمد جهاز حرج على تطبيق غير مصون فتلك مخاطرة ينبغي تسميتها في التسليم لا اكتشافها لاحقًا.

**النسخ الاحتياطية.** توفر Homey نسخًا سحابية في باقة اشتراكها. فعّلها. ففشل البوابة بلا نسخة يعني إعادة إقران كل جهاز في العقار.

**تموضعها تجاريًا.**

تكلف Homey أكثر من بوابة SONOFF وأقل من الوقت الذي تتطلبه Home Assistant. وحين يقول عميل "أريد كل شيء في تطبيق واحد ولا أريد التفكير فيه"، وتمتد أجهزته عبر عدة علامات، تكون Homey عادة التوصية الصحيحة والقابلة للدفاع.$c$
WHERE title = 'Integrating SONOFF with Homey';

UPDATE public.lessons SET content = $c$Matter is the first serious attempt to end the compatibility problem that has defined smart homes for a decade. Understanding what it actually guarantees — and what it does not — is what lets you make promises you can keep.

**What it is.** An application-layer standard from the CSA, backed by Apple, Google, Amazon and Samsung together. It defines how devices describe themselves and how controllers talk to them, so a certified device works with any certified controller without a vendor bridge.

**What it is not.** Matter is not a radio. It runs over Wi-Fi, Ethernet or Thread. "Matter over Thread" and "Matter over Wi-Fi" are both Matter; they differ in the transport underneath and therefore in power consumption and mesh behaviour.

**Multi-admin — the feature that changes the client conversation.**

A single Matter device can be commissioned into several ecosystems at once. The same light can appear in Apple Home for one family member, Google Home for another, and Home Assistant for the installer's automations — simultaneously, with no bridge.

This is genuinely new and it solves a real household argument: the family no longer has to standardise on one phone platform.

**Thread, and why the border router matters.**

Thread is a low-power mesh radio, conceptually similar to Zigbee. Thread devices need a **border router** to reach the IP network — commonly an Apple HomePod, an Apple TV, a Google Nest Hub, or a dedicated device.

The practical consequence for an installer: a client who buys Matter-over-Thread devices without any border router in the property has bought devices that cannot be commissioned. Confirm a border router exists, or specify one, before quoting Thread devices.

**The honest limitations, which you should state up front.**

- **Feature coverage lags.** Matter standardises common device types well. Vendor-specific advanced features — an unusual dimming curve, a proprietary sensor mode — are often unavailable through Matter even when the device supports them natively.
- **Certification is per-device, not per-brand.** SONOFF makes Matter devices; that does not make every SONOFF device Matter. Check the specific model.
- **Commissioning can be fiddly.** QR codes, pairing windows and ecosystem quirks make first setup less smooth than the marketing suggests, particularly across mixed ecosystems.
- **It is still maturing.** Specification versions matter, and a device certified against an older version may not expose newer device types.

**Where Matter belongs in a specification.**

Use it where cross-ecosystem compatibility is a stated client requirement, where the household spans phone platforms, or where the client is explicitly worried about being locked in.

Do not use it as a blanket default. A single-ecosystem household with no cross-brand requirement gains little and may lose access to device features that the native integration exposes.

**The sentence that sells it honestly.** "This device will still work if you change from Apple to Google in three years, and it will work with hardware from other manufacturers." That is a real promise, it is true, and it is worth money to a client who has been burned by a discontinued app before.$c$,
content_ar = $c$Matter أول محاولة جادة لإنهاء مشكلة التوافق التي عرّفت المنازل الذكية لعقد. وفهم ما يضمنه فعلًا — وما لا يضمنه — هو ما يتيح لك وعودًا تستطيع الوفاء بها.

**ما هو.** معيار طبقة تطبيق من CSA تدعمه Apple وGoogle وAmazon وSamsung معًا. يحدد كيف تصف الأجهزة نفسها وكيف تتحدث معها المتحكمات، فيعمل جهاز معتمد مع أي متحكم معتمد دون جسر خاص بالمورّد.

**ما ليس هو.** Matter ليس راديو. يعمل فوق Wi-Fi أو إيثرنت أو Thread. و"Matter فوق Thread" و"Matter فوق Wi-Fi" كلاهما Matter؛ ويختلفان في النقل تحتهما وبالتالي في استهلاك الطاقة وسلوك الشبكة.

**تعدد الإدارة — الميزة التي تغيّر الحديث مع العميل.**

جهاز Matter واحد يمكن تشغيله في عدة منظومات في آن. فالمصباح نفسه يظهر في Apple Home لفرد وGoogle Home لآخر وHome Assistant لأتمتة الفني — في آن وبلا جسر.

وهذا جديد فعلًا ويحل خلافًا منزليًا حقيقيًا: لم تعد العائلة مضطرة للتوحد على منصة هاتف واحدة.

**Thread ولماذا يهم موجّه الحدود.**

Thread راديو شبكي منخفض الطاقة، مشابه مفاهيميًا لـ Zigbee. وأجهزة Thread تحتاج **موجّه حدود** للوصول لشبكة IP — عادة HomePod أو Apple TV أو Google Nest Hub أو جهاز مخصص.

والنتيجة العملية للفني: العميل الذي يشتري أجهزة Matter فوق Thread بلا موجّه حدود في العقار قد اشترى أجهزة لا يمكن تشغيلها. تأكد من وجود موجّه حدود أو حدّد واحدًا قبل تسعير أجهزة Thread.

**القيود الصادقة التي ينبغي ذكرها مقدمًا.**

- **تغطية الميزات متأخرة.** يوحّد Matter أنواع الأجهزة الشائعة جيدًا. أما الميزات المتقدمة الخاصة بالمورّد — منحنى تعتيم غير معتاد أو وضع حساس خاص — فغالبًا غير متاحة عبر Matter حتى لو دعمها الجهاز أصلًا.
- **الاعتماد لكل جهاز لا لكل علامة.** تصنع SONOFF أجهزة Matter؛ وهذا لا يجعل كل جهاز SONOFF من Matter. افحص الموديل المحدد.
- **التشغيل قد يكون مربكًا.** رموز QR ونوافذ الإقران وخصوصيات المنظومات تجعل الإعداد الأول أقل سلاسة مما يوحي التسويق، خصوصًا عبر منظومات مختلطة.
- **ما يزال ينضج.** إصدارات المواصفة تهم، والجهاز المعتمد مقابل إصدار أقدم قد لا يعرض أنواع أجهزة أحدث.

**أين ينتمي Matter في المواصفة.**

استخدمه حيث يكون التوافق عبر المنظومات مطلبًا صريحًا للعميل، أو حيث تمتد الأسرة عبر منصات هواتف، أو حيث يقلق العميل صراحة من الحبس لدى مورّد.

ولا تستخدمه افتراضيًا شاملًا. فالأسرة ذات المنظومة الواحدة بلا متطلب عابر للعلامات تكسب قليلًا وقد تفقد الوصول لميزات أجهزة يعرضها التكامل الأصلي.

**الجملة التي تبيعه بصدق.** "هذا الجهاز سيظل يعمل إن انتقلت من Apple إلى Google بعد ثلاث سنوات، وسيعمل مع عتاد من مصنّعين آخرين." وعد حقيقي وصحيح، ويساوي مالًا لعميل اكتوى من قبل بتطبيق أُوقف.$c$
WHERE title = 'Deep Dive: The Matter Ecosystem';

UPDATE public.lessons SET content = $c$The most valuable thing a certified installer sells is not devices. It is an installation the client is not trapped inside. This lesson is the strategy for building that, and for explaining why it is worth paying for.

**What lock-in actually costs the client.**

A locked-in installation depends on one vendor's cloud, one app, and that company's continued commercial interest. When any of those change — a cloud service discontinued, an API closed, a subscription introduced, a company acquired — the client's working system degrades and they have no path out that does not involve replacing hardware.

This is not hypothetical. It happens regularly enough that any client who has been in smart homes for a few years has a story about it.

**The three-layer model for thinking about risk.**

Separate every installation into layers and ask what happens if each one disappears:

1. **Physical layer** — wiring, switches, relays. Survives everything. A smart switch that fails still switches by hand if you specified one with a working physical button.
2. **Local control layer** — the gateway, the Zigbee mesh, local automations. Survives internet and cloud failure. This is where as much logic as possible should live.
3. **Cloud layer** — remote access, voice assistants, cloud-hosted automations. Convenient, and the layer most likely to change under the client's feet.

A well-designed installation puts the things the household *needs* in layers 1 and 2, and only the things they merely *enjoy* in layer 3.

**Practical rules that follow from that.**

- **Prefer local automation.** A motion-triggered light should fire at the gateway, not via the cloud. Faster, and it works during an outage.
- **Prefer Matter or open-API devices** where feature coverage allows, because they can be re-homed to another controller later.
- **Never let safety or daily-essential functions depend on the cloud.** Entrance lighting, stair lighting, anything the client relies on at night.
- **Always keep the physical path.** Every automated circuit must remain hand-operable.
- **Client owns the account.** As covered in the eWeLink lesson — this is the administrative half of the same principle.

**Documenting the fallback path.**

For each major subsystem, write down what happens if the vendor disappears and what the migration route is. "Zigbee devices can be re-paired to any Zigbee coordinator" is a fallback. "Requires eWeLink cloud, no alternative" is a risk that should be visible in the handover document, not a surprise three years later.

This document is also a sales asset. Very few competitors provide it.

**When lock-in is the right call.**

Sometimes a proprietary ecosystem is genuinely the best technical answer — deeper integration, better reliability, a feature set nothing open matches. That is a legitimate choice.

What makes it professional is that it was a *choice*, made with the client, with the trade-off stated. What makes it negligent is arriving there by default because it was the easiest thing to commission.

**How to say it to a client.**

"I can build this so it works beautifully and only with this one company's service, or so it works beautifully and can be moved if that company changes. The second costs a little more today. Which would you like?"

Most clients, asked directly, choose the second — and the ones who do not have made an informed decision you can point back to.$c$,
content_ar = $c$أثمن ما يبيعه الفني المعتمد ليس الأجهزة. بل تركيب لا يكون العميل محبوسًا داخله. وهذا الدرس هو استراتيجية بناء ذلك وشرح لماذا يستحق الدفع.

**ما يكلفه الحبس فعلًا للعميل.**

التركيب المحبوس يعتمد على سحابة مورّد واحد وتطبيق واحد واستمرار اهتمام تلك الشركة تجاريًا. وحين يتغير أي من ذلك — إيقاف خدمة سحابية أو إغلاق واجهة أو إدخال اشتراك أو استحواذ على شركة — يتدهور نظام العميل العامل ولا يجد مخرجًا لا يتضمن استبدال عتاد.

وهذا ليس افتراضيًا. يحدث بتواتر كافٍ ليكون لأي عميل أمضى سنوات في المنازل الذكية قصة عنه.

**نموذج الطبقات الثلاث للتفكير في المخاطرة.**

افصل كل تركيب لطبقات واسأل ماذا يحدث إن اختفت كل منها:

1. **الطبقة الفيزيائية** — تمديد ومفاتيح وريليهات. تنجو من كل شيء. فالمفتاح الذكي المعطل يظل يبدّل يدويًا إن حددت واحدًا بزر فيزيائي عامل.
2. **طبقة التحكم المحلي** — البوابة والشبكة الشبكية والأتمتة المحلية. تنجو من فشل الإنترنت والسحابة. وهنا يجب أن يعيش أكبر قدر ممكن من المنطق.
3. **الطبقة السحابية** — الوصول عن بُعد والمساعدات الصوتية والأتمتة المستضافة سحابيًا. مريحة، وأكثر الطبقات عرضة للتغير تحت قدمي العميل.

والتركيب المصمَّم جيدًا يضع ما *تحتاجه* الأسرة في الطبقتين ١ و٢، وما *تستمتع* به فقط في الطبقة ٣.

**قواعد عملية تنبع من ذلك.**

- **فضّل الأتمتة المحلية.** الإضاءة المشغّلة بالحركة يجب أن تعمل عند البوابة لا عبر السحابة. أسرع، وتعمل أثناء الانقطاع.
- **فضّل أجهزة Matter أو ذات الواجهات المفتوحة** حيث تسمح تغطية الميزات، لأنها يمكن نقلها لمتحكم آخر لاحقًا.
- **لا تدع وظائف السلامة أو الأساسيات اليومية تعتمد على السحابة أبدًا.** إضاءة المداخل وبيوت الدرج وكل ما يعتمد عليه العميل ليلًا.
- **أبقِ المسار الفيزيائي دائمًا.** كل دائرة مؤتمتة يجب أن تبقى قابلة للتشغيل يدويًا.
- **العميل يملك الحساب.** كما في درس eWeLink — وهذا النصف الإداري من المبدأ نفسه.

**توثيق مسار الاحتياط.**

لكل نظام فرعي رئيسي، اكتب ماذا يحدث إن اختفى المورّد وما مسار الهجرة. فـ"أجهزة Zigbee يمكن إعادة إقرانها بأي منسق Zigbee" احتياط. و"يتطلب سحابة eWeLink بلا بديل" مخاطرة ينبغي أن تكون مرئية في مستند التسليم لا مفاجأة بعد ثلاث سنوات.

وهذا المستند أصل بيعي أيضًا. فقليل جدًا من المنافسين يقدمه.

**متى يكون الحبس القرار الصحيح.**

أحيانًا تكون المنظومة المغلقة فعلًا أفضل جواب تقني — تكامل أعمق وموثوقية أفضل ومجموعة ميزات لا يضاهيها مفتوح. وذلك اختيار مشروع.

وما يجعله احترافيًا أنه كان *اختيارًا* اتُّخذ مع العميل والمقايضة مذكورة. وما يجعله إهمالًا هو الوصول إليه افتراضيًا لأنه كان الأسهل تشغيلًا.

**كيف تقولها للعميل.**

"أستطيع بناء هذا ليعمل بشكل رائع ومع خدمة هذه الشركة وحدها، أو ليعمل بشكل رائع ويمكن نقله إن تغيرت تلك الشركة. والثاني يكلف قليلًا أكثر اليوم. أيهما تفضل؟"

وأغلب العملاء، إذا سُئلوا مباشرة، يختارون الثاني — ومن لا يختارونه يكونون قد اتخذوا قرارًا مستنيرًا تستطيع الإشارة إليه لاحقًا.$c$
WHERE title = 'Cross-Platform Integration Strategy';
