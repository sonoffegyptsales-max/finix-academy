-- Step 4f: Expand M16 (Mesh Security & Network Hardening) — three lessons.

UPDATE public.lessons SET content = $c$Smart home devices are the weakest computers on a client's network. They run firmware that is rarely updated, they are built to a price, and they sit on the same network as the family's banking and work laptops. Segmentation is the control that limits what a compromise can reach.

**The threat, stated plainly.**

A compromised smart device is rarely interesting in itself. Nobody wants to control a light. What an attacker wants is a foothold on the network — a permanently-on machine, inside the perimeter, that nobody monitors and nobody patches.

From there, everything else on the flat network is reachable: network drives, computers, the router's admin interface, and any camera stream.

**The control: separate the untrusted devices.**

Segmentation places IoT devices on their own network, isolated from the primary one. A compromised device can then talk to the internet and to other IoT devices, but not to the family's computers, phones or storage.

Three implementations, in descending order of rigour:

1. **VLAN with firewall rules** — proper segmentation on managed equipment, with explicit rules governing what may cross between segments. The correct answer for a commercial site or a high-value residence.
2. **A separate SSID mapped to a guest or IoT network** — available on most prosumer routers and adequate for the great majority of homes.
3. **The router's built-in guest network with client isolation** — crude, available on almost anything, and still far better than a flat network.

**The complication you must plan for.**

Segmentation breaks discovery. mDNS, SSDP and similar protocols do not cross network boundaries by default, which is exactly the point — and it is also how Chromecast, AirPlay, printer discovery and many app-to-device pairings work.

Consequences to design around:

- **Commission before segmenting**, or ensure the phone is on the IoT network during pairing. A device that cannot see the phone cannot be set up.
- **mDNS reflection or repeating** may be needed so the family's phones can still discover the devices they are allowed to use.
- **Firewall rules must permit the specific flows** the client actually needs — phone to gateway, phone to camera stream — rather than everything or nothing.

This is why segmentation is a design decision made before installation, not a change applied afterwards. Retrofitting it to a working installation reliably breaks things the client had come to rely on.

**What to segment, and what not to.**

Segment: cameras, sensors, switches, gateways, televisions, and anything with an unmaintained firmware story.

Do not segment away the things that need to talk to each other. A gateway and its devices belong on the same segment. The goal is isolating the untrusted group from the trusted group, not isolating every device from every other device.

**Additional hardening that costs nothing.**

- **Disable UPnP on the router.** It lets devices open inbound ports by themselves, which is precisely what you do not want an untrusted device doing.
- **Never port-forward to a camera or gateway.** Exposing a device directly to the internet is the single most dangerous thing in residential networking. Use the vendor's relay service or a VPN into the property.
- **Change the router's admin password** and disable remote administration.
- **Separate the Wi-Fi password** for the IoT network from the family's, so sharing one does not expose the other.

**How to explain it to a client.**

"Your smart devices go on their own network, so that if one of them ever has a security problem, it can't reach your computers or your files." Most clients accept that immediately, and it takes no technical background to understand.

Note it in the handover documentation, including which network is which and which password belongs to which — otherwise the first person to add a device will put it in the wrong place.$c$,
content_ar = $c$أجهزة المنازل الذكية أضعف حواسيب على شبكة العميل. تشغّل برامج نادرًا ما تُحدَّث، ومبنية بسعر، وتجلس على الشبكة نفسها مع حواسيب العائلة المصرفية والعملية. والتقسيم هو الضابط الذي يحد ما يصله الاختراق.

**التهديد بوضوح.**

الجهاز الذكي المخترق نادرًا ما يكون مثيرًا بذاته. فلا أحد يريد التحكم بمصباح. وما يريده المهاجم موطئ قدم على الشبكة — آلة تعمل دائمًا داخل المحيط لا يراقبها أحد ولا يرقّعها أحد.

ومن هناك يمكن الوصول لكل شيء آخر على الشبكة المسطحة: أقراص الشبكة والحواسيب وواجهة إدارة الراوتر وأي بث كاميرا.

**الضابط: افصل الأجهزة غير الموثوقة.**

يضع التقسيم أجهزة إنترنت الأشياء على شبكتها معزولة عن الرئيسية. فيستطيع الجهاز المخترق حينها التحدث للإنترنت ولأجهزة إنترنت الأشياء الأخرى، لا لحواسيب العائلة وهواتفها وتخزينها.

وثلاثة تطبيقات بترتيب صرامة تنازلي:

١. **VLAN بقواعد جدار ناري** — تقسيم سليم على معدات مُدارة بقواعد صريحة تحكم ما يعبر بين الأجزاء. الجواب الصحيح لموقع تجاري أو سكن عالي القيمة.
٢. **SSID منفصل مربوط بشبكة ضيوف أو إنترنت أشياء** — متاح في أغلب راوترات المحترفين وكافٍ للغالبية العظمى من المنازل.
٣. **شبكة الضيوف المدمجة في الراوتر مع عزل العملاء** — خشن ومتاح في أي شيء تقريبًا وما يزال أفضل بكثير من شبكة مسطحة.

**التعقيد الذي يجب التخطيط له.**

التقسيم يكسر الاكتشاف. فـ mDNS وSSDP والمشابهة لا تعبر حدود الشبكات افتراضيًا، وهذا بالضبط المقصود — وهو أيضًا كيف يعمل Chromecast وAirPlay واكتشاف الطابعات وكثير من عمليات إقران التطبيق بالجهاز.

وعواقب تُصمَّم حولها:

- **شغّل قبل التقسيم**، أو تأكد أن الهاتف على شبكة إنترنت الأشياء أثناء الإقران. فالجهاز الذي لا يرى الهاتف لا يمكن إعداده.
- **قد تُحتاج انعكاسات mDNS أو تكرارها** ليظل بوسع هواتف العائلة اكتشاف الأجهزة المسموح لها باستخدامها.
- **قواعد الجدار الناري يجب أن تسمح بالتدفقات المحددة** التي يحتاجها العميل فعلًا — الهاتف للبوابة والهاتف لبث الكاميرا — لا بكل شيء أو لا شيء.

ولهذا التقسيم قرار تصميم يُتخذ قبل التركيب لا تغيير يُطبَّق بعده. فتركيبه لاحقًا على تركيب عامل يكسر بشكل موثوق أشياء صار العميل يعتمد عليها.

**ماذا تقسّم وماذا لا.**

قسّم: الكاميرات والحساسات والمفاتيح والبوابات والتلفزيونات وكل ما قصة برنامجه غير مصونة.

ولا تفصل الأشياء التي تحتاج التحدث لبعضها. فالبوابة وأجهزتها تنتمي للجزء نفسه. والهدف عزل المجموعة غير الموثوقة عن الموثوقة لا عزل كل جهاز عن كل جهاز.

**تقسية إضافية لا تكلف شيئًا.**

- **عطّل UPnP في الراوتر.** فهو يتيح للأجهزة فتح منافذ واردة بنفسها، وهو بالضبط ما لا تريد جهازًا غير موثوق يفعله.
- **لا توجّه منفذًا لكاميرا أو بوابة أبدًا.** فتعريض جهاز مباشرة للإنترنت أخطر شيء في شبكات المنازل. استخدم خدمة ترحيل المورّد أو VPN للعقار.
- **غيّر كلمة إدارة الراوتر** وعطّل الإدارة عن بُعد.
- **افصل كلمة Wi-Fi** لشبكة إنترنت الأشياء عن كلمة العائلة، فمشاركة إحداها لا تكشف الأخرى.

**كيف تشرحها لعميل.**

"أجهزتك الذكية تذهب لشبكتها الخاصة، فإن واجه أحدها مشكلة أمنية يومًا لا يستطيع الوصول لحواسيبك أو ملفاتك." وأغلب العملاء يقبلون ذلك فورًا، ولا يحتاج فهمه خلفية تقنية.

ودوّنه في وثائق التسليم بما فيه أي شبكة أي وأي كلمة تخص أيها — وإلا فأول من يضيف جهازًا سيضعه في المكان الخطأ.$c$
WHERE title = 'Network Segmentation for Smart Home Devices';
