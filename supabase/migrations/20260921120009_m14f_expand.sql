-- Step 4d-6: M14 L6 — Integrating with Apple Home (HomeKit).

UPDATE public.lessons SET content = $c$Apple Home clients are the least tolerant of rough edges and the most likely to notice them. They are also often the highest-value clients in a residential portfolio, so getting this right is commercially worthwhile.

**The three routes in.**

1. **Native HomeKit support.** The device is certified and pairs directly with an eight-digit code. Cleanest, most reliable, no intermediate software.
2. **Matter.** A Matter-certified device joins Apple Home like any other Matter device, and can simultaneously belong to other ecosystems. This is the preferred modern route.
3. **A bridge.** Software such as Homebridge, or Home Assistant's HomeKit Bridge, exposes non-HomeKit devices to Apple Home. Enormously capable, and it introduces a dependency: the bridge machine must be running for those devices to exist in Apple Home.

**The home hub requirement.**

Automations and remote access need a resident hub in the property: a HomePod, a HomePod mini, or an Apple TV. Without one, the client can control devices only while on the local network, and no automation runs at all.

This is a specification item, not an afterthought. If the client has no Apple TV or HomePod, Apple Home automation is not available to them until they buy one — and discovering that at handover is an uncomfortable conversation.

**Accessory categories — the detail that defines the experience.**

HomeKit assigns every accessory a category, which determines the tile the client sees and the controls it offers. A dimmable light exposed as a plain switch loses the brightness slider entirely; a fan exposed as a light gets a bulb icon and nonsensical controls.

Check every accessory tile after setup. When bridging, most bridge software lets you override the category — set it correctly rather than leaving the client with a bulb icon on their extractor fan.

**Room assignment before automation.**

Assign every accessory to the correct room immediately. Siri's natural-language control depends entirely on it: "turn off the bedroom lights" only works if those lights are in the bedroom room.

Use the client's own room names, and match them to the names used in eWeLink and any other app. A device called "Kitchen Ceiling" in one app and "Kitchen Light 1" in another guarantees confusion for everyone including you on the support call.

**Naming for voice.**

HomeKit names are spoken, so they must be pronounceable and distinct. Avoid model numbers, avoid abbreviations, and avoid names that sound alike — "Hall Light" and "Wall Light" will be confused by both Siri and the family.

Short, natural, and different from each other.

**Scenes and Adaptive Lighting.**

Scenes in Apple Home are straightforward and worth setting up for the client during handover rather than leaving as an exercise. Two or three genuinely useful scenes get used; twelve elaborate ones do not.

Adaptive Lighting, on compatible colour-temperature bulbs, shifts warmth across the day automatically. It demonstrates well and it needs no client configuration, which makes it an easy win at handover.

**Multi-admin, and who owns the home.**

The Apple Home "home" belongs to an Apple ID, with other family members invited. As with the eWeLink account, the client must own it — never create it on your own Apple ID. Invite additional family members during handover so nobody is locked out later.

**What to verify before leaving.**

Every accessory appears with the correct category and controls; every accessory is in the correct room; Siri controls a sample of them by voice; the resident hub is present and shows as connected; remote access works from cellular data with Wi-Fi disabled; and, where a bridge is used, that the client understands the bridge must stay powered on.$c$,
content_ar = $c$عملاء Apple Home أقل تسامحًا مع الحواف الخشنة وأكثر من يلاحظها. وهم أيضًا غالبًا أعلى العملاء قيمة في محفظة سكنية، فإتقان هذا مجدٍ تجاريًا.

**المسارات الثلاثة للدخول.**

1. **دعم HomeKit الأصلي.** الجهاز معتمد ويقترن مباشرة برمز من ثمانية أرقام. أنظفها وأوثقها وبلا برنامج وسيط.
2. **Matter.** الجهاز المعتمد بـ Matter ينضم لـ Apple Home كأي جهاز Matter، ويمكنه الانتماء لمنظومات أخرى في آن. وهذا المسار الحديث المفضل.
3. **جسر.** برامج مثل Homebridge أو جسر HomeKit في Home Assistant تعرض أجهزة غير HomeKit لـ Apple Home. قدرة هائلة، وتُدخل اعتمادًا: فجهاز الجسر يجب أن يعمل لتوجد تلك الأجهزة في Apple Home.

**اشتراط بوابة المنزل.**

الأتمتة والوصول عن بُعد يحتاجان بوابة مقيمة في العقار: HomePod أو HomePod mini أو Apple TV. وبدونها يتحكم العميل بالأجهزة فقط على الشبكة المحلية، ولا تعمل أي أتمتة إطلاقًا.

وهذا بند مواصفة لا فكرة لاحقة. فإن لم يكن لدى العميل Apple TV أو HomePod فأتمتة Apple Home غير متاحة له حتى يشتري واحدًا — واكتشاف ذلك عند التسليم محادثة غير مريحة.

**فئات الملحقات — التفصيل الذي يحدد التجربة.**

يسند HomeKit لكل ملحق فئة تحدد البلاطة التي يراها العميل والتحكمات التي تعرضها. فالمصباح القابل للتعتيم المعروض كمفتاح عادي يفقد شريط السطوع تمامًا؛ والمروحة المعروضة كمصباح تحصل على أيقونة لمبة وتحكمات لا معنى لها.

افحص كل بلاطة ملحق بعد الإعداد. وعند الجسر، أغلب برامج الجسور تتيح تجاوز الفئة — اضبطها صحيحًا بدل ترك العميل بأيقونة لمبة على شفاطه.

**إسناد الغرف قبل الأتمتة.**

أسند كل ملحق للغرفة الصحيحة فورًا. فتحكم Siri باللغة الطبيعية يعتمد عليه كليًا: "أطفئ أنوار غرفة النوم" لا تعمل إلا إن كانت تلك الأنوار في غرفة النوم.

استخدم أسماء غرف العميل نفسها، وطابقها مع الأسماء في eWeLink وأي تطبيق آخر. فجهاز اسمه "سقف المطبخ" في تطبيق و"مصباح المطبخ ١" في آخر يضمن ارتباكًا للجميع بمن فيهم أنت في اتصال الدعم.

**التسمية للصوت.**

أسماء HomeKit تُنطق، فيجب أن تكون قابلة للنطق ومتمايزة. تجنب أرقام الموديلات والاختصارات والأسماء المتشابهة صوتًا — فـ"نور الصالة" و"نور الحائط" ستلتبسان على Siri وعلى العائلة.

قصيرة وطبيعية ومختلفة عن بعضها.

**المشاهد والإضاءة التكيفية.**

المشاهد في Apple Home مباشرة وتستحق الإعداد للعميل أثناء التسليم بدل تركها تمرينًا. فمشهدان أو ثلاثة نافعة فعلًا تُستخدم؛ واثنا عشر متقنة لا تُستخدم.

والإضاءة التكيفية، في لمبات حرارة اللون المتوافقة، تنقل الدفء عبر اليوم تلقائيًا. تُعرض جيدًا ولا تحتاج إعدادًا من العميل، ما يجعلها مكسبًا سهلًا عند التسليم.

**تعدد الإدارة ومن يملك المنزل.**

"منزل" Apple Home يخص معرّف Apple، ويُدعى إليه بقية أفراد العائلة. وكما في حساب eWeLink، يجب أن يملكه العميل — لا تنشئه على معرّفك أبدًا. وادعُ بقية أفراد العائلة أثناء التسليم كيلا يُحبس أحد خارجًا لاحقًا.

**ما تتحقق منه قبل المغادرة.**

كل ملحق يظهر بالفئة والتحكمات الصحيحة؛ وكل ملحق في الغرفة الصحيحة؛ وSiri تتحكم بعينة منها صوتًا؛ والبوابة المقيمة موجودة وتظهر متصلة؛ والوصول عن بُعد يعمل من بيانات الجوال وWi-Fi معطل؛ وحيث يُستخدم جسر، أن العميل يفهم أن الجسر يجب أن يبقى مغذى.$c$
WHERE title = 'Integrating with Apple Home (HomeKit)';
