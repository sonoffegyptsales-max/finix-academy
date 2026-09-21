-- Step 4f-2: M16 L2/L3 — Credential hygiene and firmware update policy.

UPDATE public.lessons SET content = $c$Credentials are where installer convenience most often becomes client risk. The shortcuts that make a job faster — one password everywhere, the installer's own account, a shared login for the crew — are the ones that create problems nobody discovers until they matter.

**The account must belong to the client.**

Create the platform account in the client's name, on the client's email, with the client present where possible. Never on your own email, never on a company address, never on an account shared across jobs.

The reasons are practical rather than theoretical. An installation registered to your account means the client cannot recover access if you are unavailable, cannot transfer it when they sell the property, and is dependent on a relationship that may end. It also means you retain access to a household's cameras and locks long after the job finished — a liability you do not want.

When the client already has an account, add yourself as a shared user for the duration of the work and **remove yourself at handover**. Note the removal in the handover record.

**Defaults are not credentials.**

Change every default during commissioning, without exception:

- Device admin passwords and PINs
- The gateway's local access credentials
- The router's admin password, if within scope
- Any Wi-Fi password still set to a printed default

Default credentials for consumer devices are published and indexed. A device left on its factory PIN is not protected by obscurity; it is protected by nothing.

**Smart lock PINs specifically.**

Locks need a policy, not just a password:

- **Unique codes per person**, so an audit trail means something and so revoking one person's access does not require changing everyone's.
- **Temporary codes** for cleaners, contractors and guests, with an expiry set at creation rather than a promise to remove it later.
- **Remove codes when people leave.** The departed housekeeper's code is the classic finding.
- **Never a birthday, a house number, or a repeated digit.** These are the first guesses.

**Use the platform's sharing mechanism, never password sharing.**

Every serious platform supports inviting additional users with their own logins and defined permission levels. Use it.

Sharing the account password instead means no audit trail, no way to revoke one person, and a credential that spreads beyond anyone's knowledge. When the family member with the password leaves or the relationship changes, the only remedy is changing the password for everyone.

**Two-factor authentication.**

Enable it on the primary account at handover, on the client's own device. An account controlling door locks and cameras deserves more than a password, and the moment to set it up is while you are standing there — not in a follow-up email the client will not action.

**Your own operational hygiene.**

You will hold credentials for many client sites. Keep them in a password manager, never in a phone notes app or a spreadsheet. Use a unique password per site. When a technician leaves your company, rotate everything they had access to — this is an unglamorous task that separates a professional operation from an amateur one.

**Record what exists.**

The handover document should state which accounts exist, who owns them, who has shared access, and which codes are issued to whom. Not the passwords themselves — the structure. A client who does not know that a contractor still has a door code cannot make a decision about it.$c$,
content_ar = $c$بيانات الاعتماد حيث تصير راحة الفني غالبًا مخاطرة العميل. فالاختصارات التي تسرّع العمل — كلمة واحدة في كل مكان وحساب الفني نفسه ودخول مشترك للطاقم — هي التي تخلق مشاكل لا يكتشفها أحد حتى تهم.

**الحساب يجب أن يخص العميل.**

أنشئ حساب المنصة باسم العميل على بريده وبحضوره حيثما أمكن. ولا على بريدك أبدًا ولا على عنوان شركة ولا على حساب مشترك عبر الأعمال.

والأسباب عملية لا نظرية. فالتركيب المسجَّل على حسابك يعني أن العميل لا يستطيع استرداد الوصول إن كنت غير متاح، ولا نقله حين يبيع العقار، ويعتمد على علاقة قد تنتهي. ويعني أيضًا أنك تحتفظ بوصول لكاميرات وأقفال أسرة بعد انتهاء العمل بوقت طويل — مسؤولية لا تريدها.

وحين يكون للعميل حساب بالفعل، أضف نفسك مستخدمًا مشاركًا طوال مدة العمل و**أزل نفسك عند التسليم**. ودوّن الإزالة في سجل التسليم.

**الافتراضيات ليست بيانات اعتماد.**

غيّر كل افتراضي أثناء التشغيل بلا استثناء:

- كلمات إدارة الأجهزة وأرقامها السرية
- بيانات الوصول المحلي للبوابة
- كلمة إدارة الراوتر إن كانت ضمن النطاق
- أي كلمة Wi-Fi ما تزال على افتراضي مطبوع

فبيانات الاعتماد الافتراضية لأجهزة المستهلك منشورة ومفهرسة. والجهاز المتروك على رقمه المصنعي غير محمي بالغموض؛ بل غير محمي بشيء.

**أرقام الأقفال الذكية تحديدًا.**

الأقفال تحتاج سياسة لا كلمة مرور فقط:

- **رموز فريدة لكل شخص**، فيعني أثر التدقيق شيئًا ولا يتطلب سحب وصول شخص تغيير رموز الجميع.
- **رموز مؤقتة** للمنظفين والمقاولين والضيوف بانتهاء يُضبط عند الإنشاء لا بوعد بإزالته لاحقًا.
- **أزل الرموز حين يغادر الناس.** فرمز مدبرة المنزل المغادرة هو الاكتشاف الكلاسيكي.
- **لا عيد ميلاد ولا رقم منزل ولا رقم مكرر أبدًا.** فهذه أول التخمينات.

**استخدم آلية المشاركة في المنصة لا مشاركة كلمة المرور أبدًا.**

كل منصة جادة تدعم دعوة مستخدمين إضافيين بدخولهم الخاص ومستويات أذونات محددة. استخدمها.

فمشاركة كلمة الحساب بدلًا من ذلك تعني بلا أثر تدقيق ولا طريقة لسحب شخص واحد واعتمادًا ينتشر خارج علم أحد. وحين يغادر فرد العائلة الذي معه الكلمة أو تتغير العلاقة يكون العلاج الوحيد تغيير الكلمة للجميع.

**التحقق بخطوتين.**

فعّله على الحساب الرئيسي عند التسليم على جهاز العميل نفسه. فالحساب المتحكم بأقفال أبواب وكاميرات يستحق أكثر من كلمة مرور، ولحظة إعداده وأنت واقف هناك — لا في بريد متابعة لن ينفّذه العميل.

**نظافتك التشغيلية.**

ستحمل بيانات اعتماد لمواقع عملاء كثيرة. احفظها في مدير كلمات مرور لا في تطبيق ملاحظات هاتف أو جدول. واستخدم كلمة فريدة لكل موقع. وحين يغادر فني شركتك، دوّر كل ما كان له وصول إليه — وهذه مهمة غير براقة تفصل عملية احترافية عن هاوية.

**سجّل ما هو موجود.**

مستند التسليم ينبغي أن يذكر أي حسابات موجودة ومن يملكها ومن له وصول مشارك وأي رموز صُدرت لمن. لا الكلمات نفسها — بل البنية. فالعميل الذي لا يعرف أن مقاولًا ما يزال معه رمز باب لا يستطيع اتخاذ قرار بشأنه.$c$
WHERE title = 'Credential Hygiene: Passwords, PINs & Shared Access';

UPDATE public.lessons SET content = $c$Firmware updates sit on a genuine tension: unpatched devices accumulate known vulnerabilities, and updates occasionally break working installations. A policy resolves it; an instinct does not.

**Why updates matter.**

Firmware vulnerabilities in smart devices are published, catalogued and exploited at scale by automated scanning. A device running two-year-old firmware with a known remote flaw is not theoretically at risk — it is findable by anyone looking.

**Why blind auto-update is not the whole answer.**

Updates have broken things: a changed API that stops an integration working, a removed feature the client used, a behaviour change that breaks an automation, and occasionally an update that fails and bricks the device.

On a single home this is an inconvenience. On a commercial site with forty devices updating overnight, an unlucky release can disable a property before opening.

**The policy: tier by criticality.**

**Tier 1 — security-critical, update promptly.**
Anything with a lock, a camera, or a network-facing service: door locks, cameras, gateways, routers. The risk of an unpatched vulnerability exceeds the risk of a broken automation. Enable automatic updates here.

**Tier 2 — functional devices, update on a schedule.**
Switches, sockets, dimmers, sensors. Let a release age for a few weeks so problems surface in other people's installations, then apply during a monthly or quarterly window.

**Tier 3 — critical-path devices, update deliberately.**
Anything whose failure stops the client's business or safety function. Update these only in a planned window, one at a time, with someone available to respond.

**Before any update on a live site.**

- **Check the release notes.** Breaking changes are usually disclosed.
- **Have a rollback plan**, or accept there is none — many consumer devices cannot downgrade, and knowing that in advance is part of the decision.
- **Back up the gateway configuration.** Device firmware and hub configuration are separate risks, and a hub restore is often what saves a bad night.
- **Update one device of a type first.** If there are twelve identical switches, update one, confirm it still behaves, then do the rest.
- **Never update immediately before leaving site**, and never on a Friday afternoon. Both are experience talking.

**Power is the real hazard during flashing.**

A device interrupted mid-update is the most common way to brick one permanently. Do not update during a storm, during known supply instability, or when the client is about to leave the property. On a critical gateway, a small UPS during updates is cheap insurance.

**Gateways and hubs deserve extra caution.**

A bricked switch is one circuit. A bricked gateway is every device in the property, and recovery may require re-pairing everything. Treat hub updates as the highest-risk operation in routine maintenance: backup first, planned window, someone on site or reachable.

**Make it a service, not a favour.**

Firmware management is recurring, skilled work that protects the client. It belongs in a maintenance agreement with a defined scope — which devices, what cadence, what response if an update causes a fault.

Clients understand paying for this once it is framed as what keeps their locks and cameras from becoming the weak point. Informally promising to "keep an eye on updates" produces unpaid work that eventually stops happening, which is worse than never offering it.

**Document each cycle.** Record what was updated, when, and from which version to which. When something breaks two weeks later, that record is how you find the cause instead of guessing.$c$,
content_ar = $c$تحديثات البرامج الثابتة تجلس على توتر حقيقي: فالأجهزة غير المرقّعة تراكم ثغرات معروفة، والتحديثات تكسر أحيانًا تركيبات عاملة. والسياسة تحل ذلك، والغريزة لا.

**لماذا تهم التحديثات.**

ثغرات البرامج الثابتة في الأجهزة الذكية منشورة ومفهرسة وتُستغل على نطاق واسع بمسح آلي. فالجهاز الذي يشغّل برنامجًا عمره سنتان بعيب بعيد معروف ليس في خطر نظري — بل يمكن إيجاده لأي باحث.

**لماذا التحديث التلقائي الأعمى ليس كل الجواب.**

التحديثات كسرت أشياء: واجهة تغيّرت فتوقف تكامل، وميزة أُزيلت كان العميل يستخدمها، وسلوك تغيّر فكسر أتمتة، وأحيانًا تحديث يفشل فيتلف الجهاز.

وفي بيت واحد هذا إزعاج. وفي موقع تجاري بأربعين جهازًا تُحدَّث ليلًا قد يعطّل إصدار سيئ الحظ عقارًا قبل الافتتاح.

**السياسة: درّج بالحرجية.**

**الدرجة ١ — حرجة أمنيًا، حدّث فورًا.**
كل ما فيه قفل أو كاميرا أو خدمة مواجهة للشبكة: أقفال الأبواب والكاميرات والبوابات والراوترات. فخطر ثغرة غير مرقّعة يفوق خطر أتمتة مكسورة. فعّل التحديث التلقائي هنا.

**الدرجة ٢ — أجهزة وظيفية، حدّث بجدول.**
المفاتيح والمقابس والديمرات والحساسات. دع الإصدار يتقادم أسابيع فتظهر المشاكل في تركيبات الآخرين ثم طبّق خلال نافذة شهرية أو ربعية.

**الدرجة ٣ — أجهزة المسار الحرج، حدّث عمدًا.**
كل ما يوقف فشله عمل العميل أو وظيفة سلامة. حدّثها فقط في نافذة مخططة واحدًا تلو آخر ومع متاح للاستجابة.

**قبل أي تحديث في موقع حي.**

- **اقرأ ملاحظات الإصدار.** فالتغييرات الكاسرة تُفصح عادة.
- **احتفظ بخطة تراجع**، أو اقبل ألا توجد — فكثير من أجهزة المستهلك لا يمكن تخفيضها، ومعرفة ذلك مسبقًا جزء من القرار.
- **انسخ إعداد البوابة احتياطيًا.** فبرنامج الجهاز وإعداد البوابة مخاطرتان منفصلتان، واستعادة البوابة غالبًا ما ينقذ ليلة سيئة.
- **حدّث جهازًا واحدًا من كل نوع أولًا.** فإن كان هناك اثنا عشر مفتاحًا متطابقًا فحدّث واحدًا وتأكد أنه ما يزال يتصرف ثم افعل البقية.
- **لا تحدّث قبل مغادرة الموقع مباشرة أبدًا**، ولا بعد ظهر الجمعة. وكلاهما خبرة تتكلم.

**الطاقة هي الخطر الحقيقي أثناء البرمجة.**

الجهاز المقاطَع في منتصف التحديث أشيع طريقة لإتلافه نهائيًا. لا تحدّث أثناء عاصفة أو عدم استقرار تغذية معروف أو حين يوشك العميل على مغادرة العقار. وفي بوابة حرجة يكون مصدر طاقة احتياطي صغير أثناء التحديثات تأمينًا رخيصًا.

**البوابات تستحق حذرًا إضافيًا.**

المفتاح التالف دائرة واحدة. والبوابة التالفة كل جهاز في العقار، وقد يتطلب الاسترداد إعادة إقران كل شيء. عامل تحديثات البوابات كأعلى عملية مخاطرة في الصيانة الروتينية: نسخة أولًا ونافذة مخططة وشخص في الموقع أو يمكن بلوغه.

**اجعلها خدمة لا معروفًا.**

إدارة البرامج الثابتة عمل متكرر ماهر يحمي العميل. وينتمي لاتفاقية صيانة بنطاق محدد — أي أجهزة وأي وتيرة وأي استجابة إن سبّب تحديث عطلًا.

والعملاء يفهمون الدفع مقابل هذا متى أُطّر بأنه ما يمنع أقفالهم وكاميراتهم من أن تصير نقطة الضعف. أما الوعد غير الرسمي بـ"مراقبة التحديثات" فينتج عملًا غير مدفوع يتوقف في النهاية، وهو أسوأ من عدم عرضه أصلًا.

**وثّق كل دورة.** سجّل ما حُدّث ومتى ومن أي إصدار لأي. فحين ينكسر شيء بعد أسبوعين يكون ذلك السجل كيف تجد السبب بدل التخمين.$c$
WHERE title = 'Firmware Update Policy for Deployed Installations';
