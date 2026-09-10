-- Module F05: Networking Fundamentals: IP Addressing, NAT & Wireless Protocols

INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position) VALUES ('finix-networking-ip-protocols', 'F05', 'finix-technician-academy', 'Networking Fundamentals: IP Addressing, NAT & Wireless Protocols', 'أساسيات الشبكات: عنونة IP وNAT والبروتوكولات اللاسلكية', 'Network scales (PAN/LAN/MAN/WAN), how IP addresses work, private vs public IP and NAT explained through a hotel analogy, IPv4 classes, and a practical comparison of Wi-Fi, Zigbee, Thread, and Z-Wave.', 'نطاقات الشبكات (PAN/LAN/MAN/WAN)، كيف تعمل عناوين IP، العنوان الخاص والعام وNAT موضّح بمثال الفندق، فئات IPv4، ومقارنة عملية بين Wi-Fi وZigbee وThread وZ-Wave.', NULL, 22);
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'What a Network Is & The Four Network Scales', 'ما هي الشبكة وأنواع الشبكات حسب النطاق', 'A network is simply two or more devices linked together so they can exchange data — over cables, over radio waves, or both. As a trainer, I always tell technicians to think of a network the way they''d think of a road system: the cables and Wi-Fi signals are the roads, the devices are the buildings, and the data packets are the vehicles moving between them. Once that mental picture clicks, everything else — routers, switches, IP addresses — becomes a lot less abstract.

Networks are classified by geographic scale into four tiers:

- **PAN (Personal Area Network)** — the smallest scale, linking devices that are physically very close to a single user, such as a phone talking to a laptop over Bluetooth.
- **LAN (Local Area Network)** — devices within a limited area like a home, office, or school, usually built on Ethernet cabling or Wi-Fi access points.
- **MAN (Metropolitan Area Network)** — covers a wider area such as a city or a large campus.
- **WAN (Wide Area Network)** — links multiple LANs and MANs across long distances — cities, even countries. The internet itself is the largest WAN in existence.

For a smart home installer, 95% of daily work happens inside a LAN — the router, the switches, and the Wi-Fi access points that make up the client''s home network.', 'الشبكة ببساطة هي جهازان أو أكثر مرتبطان معًا ليتبادلا البيانات — سواء عبر كابلات أو موجات لاسلكية أو كلاهما. كمدرّب، أنصح دائمًا الفنيين بتخيّل الشبكة مثل شبكة الطرق: الكابلات وإشارات الواي فاي هي الطرق، والأجهزة هي المباني، وحزم البيانات هي السيارات المتحركة بينها. بمجرد ترسّخ هذه الصورة الذهنية، تصبح باقي المفاهيم — الراوتر، السويتش، عناوين IP — أقل تجريدًا بكثير.

تُصنَّف الشبكات حسب النطاق الجغرافي إلى أربعة مستويات:

- **الشبكة الشخصية (PAN)** — أصغر نطاق، تربط أجهزة قريبة جدًا من مستخدم واحد، مثل اتصال الهاتف باللابتوب عبر البلوتوث.
- **الشبكة المحلية (LAN)** — أجهزة في نطاق محدود مثل منزل أو مكتب أو مدرسة، تُبنى عادة على كابلات إيثرنت أو نقاط وصول واي فاي.
- **الشبكة الحضرية (MAN)** — تغطي نطاقًا أوسع مثل مدينة أو حرم جامعي كبير.
- **الشبكة الواسعة (WAN)** — تربط عدة شبكات محلية وحضرية عبر مسافات طويلة — مدن بل ودول. الإنترنت نفسه هو أكبر شبكة واسعة موجودة.

بالنسبة لفني المنزل الذكي، 95٪ من العمل اليومي يحدث داخل الشبكة المحلية (LAN) — الراوتر والسويتشات ونقاط الواي فاي التي تكوّن شبكة منزل العميل.', 1 FROM public.modules WHERE slug = 'finix-networking-ip-protocols';
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'IP Addresses: How Every Device Gets Found', 'عناوين IP: كيف يُعثر على كل جهاز', 'Every device on a network needs a unique identifier so data knows where to go — that identifier is the IP address. Think of it as the device''s postal address on the network: without it, a packet of data has no destination.

There are two address formats in active use. **IPv4** is the older and still most common format, written as four number groups separated by dots, e.g. 192.168.1.1 — each group is called an **octet** because it always represents exactly 8 bits of data, regardless of the device''s internal architecture (this is a stricter, more precise term than "byte", whose size wasn''t always fixed historically). Each octet ranges from 0 to 255. **IPv6** is the newer format built to solve IPv4''s biggest limitation — the world is running out of IPv4 addresses — and uses a much larger address space written in hexadecimal groups, e.g. fe80::200:f8ff:fe21:67cf.

An IP address can be assigned two ways: **DHCP (automatic)** — a router or service assigns the address dynamically to any device that joins the network, which is what happens by default in almost every home; or **static (manual)** — the address is entered manually in the device''s network settings and never changes, which installers use deliberately for devices that must always be reachable at the same address, like a gateway or a server.

**Finding a device''s IP address, practically:** on Windows, open Command Prompt (Win+R, type `cmd`) and run `ipconfig`. On Android, go to Settings → About Phone → Status, and the IP shows under network details. On iOS, go to Settings → Wi-Fi, tap the (i) icon next to the connected network, and the IPv4 address is listed there.', 'كل جهاز على الشبكة يحتاج معرّفًا فريدًا حتى تعرف البيانات إلى أين تتجه — هذا المعرّف هو عنوان IP. تخيّله كالعنوان البريدي للجهاز على الشبكة: بدونه، حزمة البيانات لا تملك وجهة.

يوجد صيغتان للعناوين قيد الاستخدام حاليًا. **IPv4** هي الصيغة الأقدم والأكثر شيوعًا حتى الآن، تُكتب كأربع مجموعات أرقام مفصولة بنقاط، مثل 192.168.1.1 — تُسمى كل مجموعة **أوكتت (Octet)** لأنها تمثل دائمًا 8 بتات بالضبط من البيانات، بغض النظر عن بنية الجهاز الداخلية (هذا مصطلح أدق وأصرم من "بايت" الذي لم يكن حجمه ثابتًا دائمًا تاريخيًا). كل أوكتت يتراوح بين 0 و255. أما **IPv6** فهي الصيغة الأحدث المصممة لحل أكبر قيد في IPv4 — العالم بدأ ينفد من عناوين IPv4 — وتستخدم مساحة عناوين أكبر بكثير تُكتب بمجموعات ست عشرية، مثل fe80::200:f8ff:fe21:67cf.

يمكن تخصيص عنوان IP بطريقتين: **DHCP (تلقائي)** — يخصص الراوتر أو الخدمة العنوان ديناميكيًا لأي جهاز ينضم للشبكة، وهذا ما يحدث افتراضيًا في أغلب المنازل؛ أو **ثابت (يدوي)** — يُدخَل العنوان يدويًا في إعدادات شبكة الجهاز ولا يتغير أبدًا، ويستخدمه الفنيون عمدًا للأجهزة التي يجب أن تظل متاحة دائمًا بنفس العنوان، مثل بوابة أو خادم.

**معرفة عنوان IP لجهاز ما، عمليًا:** على ويندوز، افتح موجه الأوامر (Win+R ثم اكتب `cmd`) وشغّل الأمر `ipconfig`. على أندرويد، اذهب إلى الإعدادات ← حول الهاتف ← الحالة، ويظهر IP ضمن تفاصيل الشبكة. على iOS، اذهب إلى الإعدادات ← Wi-Fi، اضغط أيقونة (i) بجانب الشبكة المتصلة، ويظهر عنوان IPv4 هناك.', 2 FROM public.modules WHERE slug = 'finix-networking-ip-protocols';
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'Private vs Public IP, IP Classes, and How NAT Connects Them', 'العنوان الخاص والعام وفئات IP وكيف يربطهما NAT', 'Every home network actually has two different IP addresses in play at once, and mixing them up is one of the most common beginner mistakes.

**Private IP** — the address the router assigns to each device inside the local network (e.g. 192.168.1.5). It''s only unique inside that one network — your neighbor''s smart plug can have the exact same private address as yours, because the two networks never talk to each other directly. It''s free, and it can''t be reached directly from the internet, which is itself a layer of protection.

**Public IP** — the single address the internet service provider assigns to the router itself, unique across the entire internet. Every device behind that router shares this one public address when talking to the outside world.

**How the router bridges the two — NAT (Network Address Translation):** picture a hotel. Your room number is your private IP — meaningful only inside the hotel. The hotel''s street address is the public IP — the only thing the outside world needs to find the building. When you send mail, the front desk (the router) writes the hotel''s public address on the envelope but keeps a log of which room actually sent it. When a reply arrives addressed to the hotel, the front desk checks its log and delivers it to your specific room — not any other guest''s. That''s exactly what a router''s NAT table does: it lets every device in the home share one public IP, while keeping track of which private IP originated each outgoing request so the response comes back to the right device.

**IPv4 address classes** — historically, IPv4 space was divided into classes by the range of the first octet, each intended for a different network size:

| Class | Range (first octet) | Typical use |
|---|---|---|
| A | 0–127 | Huge networks — ISPs, giant corporations |
| B | 128–191 | Medium networks — universities, mid-size ISPs |
| C | 192–223 | Small networks — homes and small businesses |
| D | 224–239 | Multicast — sending to a group of devices at once |
| E | 240–255 | Reserved for research/experimentation |

Nearly every home router assigns Class C private addresses (the familiar 192.168.x.x range), which is why that''s the range technicians see constantly in the field.', 'كل شبكة منزلية لديها في الواقع نوعان مختلفان من عناوين IP يعملان في آن واحد، والخلط بينهما من أكثر أخطاء المبتدئين شيوعًا.

**العنوان الخاص (Private IP)** — العنوان الذي يخصصه الراوتر لكل جهاز داخل الشبكة المحلية (مثل 192.168.1.5). هو فريد فقط داخل تلك الشبكة الواحدة — يمكن لمقبس جارك الذكي أن يملك نفس العنوان الخاص بالضبط، لأن الشبكتين لا تتحدثان مباشرة أبدًا. مجاني، ولا يمكن الوصول إليه مباشرة من الإنترنت، وهذا في حد ذاته طبقة حماية.

**العنوان العام (Public IP)** — العنوان الوحيد الذي يخصصه مزود خدمة الإنترنت للراوتر نفسه، فريد عبر الإنترنت بأكمله. كل جهاز خلف ذلك الراوتر يشارك هذا العنوان العام الواحد عند التواصل مع العالم الخارجي.

**كيف يربط الراوتر بينهما — تقنية NAT (ترجمة عنوان الشبكة):** تخيّل فندقًا. رقم غرفتك هو عنوانك الخاص — له معنى فقط داخل الفندق. عنوان الفندق في الشارع هو العنوان العام — الشيء الوحيد الذي يحتاجه العالم الخارجي للعثور على المبنى. عندما ترسل بريدًا، يكتب موظف الاستقبال (الراوتر) عنوان الفندق العام على المظروف لكنه يحتفظ بسجل يحدد أي غرفة أرسلته فعليًا. عندما يصل رد موجه للفندق، يتحقق موظف الاستقبال من سجله ويوصّله لغرفتك تحديدًا — لا لأي ضيف آخر. هذا بالضبط ما يفعله جدول NAT في الراوتر: يتيح لكل جهاز في المنزل مشاركة عنوان عام واحد، مع تتبّع أي عنوان خاص أصدر كل طلب صادر حتى يعود الرد للجهاز الصحيح.

**فئات عناوين IPv4** — تاريخيًا، قُسِّمت مساحة عناوين IPv4 إلى فئات حسب مدى الأوكتت الأول، كل فئة مخصصة لحجم شبكة مختلف:

| الفئة | المدى (الأوكتت الأول) | الاستخدام الشائع |
|---|---|---|
| A | 0-127 | شبكات ضخمة — مزودو خدمة الإنترنت، شركات عملاقة |
| B | 128-191 | شبكات متوسطة — جامعات، مزودو خدمة متوسطون |
| C | 192-223 | شبكات صغيرة — منازل وشركات صغيرة |
| D | 224-239 | البث الجماعي — إرسال لمجموعة أجهزة دفعة واحدة |
| E | 240-255 | محجوزة للأبحاث والتجريب |

تقريبًا كل راوتر منزلي يخصص عناوين خاصة من الفئة C (نطاق 192.168.x.x المألوف)، ولهذا يراه الفنيون باستمرار في الميدان.', 3 FROM public.modules WHERE slug = 'finix-networking-ip-protocols';
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'Wireless Protocol Comparison: Wi-Fi, Zigbee, Thread & Z-Wave', 'مقارنة البروتوكولات اللاسلكية: Wi-Fi وZigbee وThread وZ-Wave', 'A protocol is the shared "language" and rulebook that lets devices exchange data reliably — formatting the data, controlling the flow so devices aren''t overwhelmed, catching and correcting errors, and finding the best path across the network. A smart home installer works with four wireless protocols regularly, and picking the right one per device is a core professional skill, not a minor detail.

**Wi-Fi** — general-purpose, high-bandwidth, connects straight to the router. Best for devices that move real data volume: cameras, streaming devices, anything with a screen. Downside: higher power draw (not ideal for battery devices) and every device adds load to the router directly.

**Zigbee** — a low-power, low-data-rate protocol purpose-built for IoT. Devices form a self-healing mesh network — mains-powered devices act as repeaters, extending range and reliability as more devices join, without needing a central hub for every single link. Ideal for switches, sensors, and simple commands, not for large data transfers.

**Thread** — the protocol built specifically as a foundation for the future cross-brand standard Matter. Also mesh-based and low-power, but built on IPv6 from the ground up, which makes direct, efficient communication with internet-connected systems easier than Zigbee''s older architecture allows.

**Z-Wave** — similar in purpose to Zigbee (mesh, low-power, sensors and switches) but operates on different, lower radio frequencies (roughly 800–900 MHz instead of Zigbee''s 2.4 GHz), which avoids interference with Wi-Fi networks — a real advantage in crowded urban apartments where many networks overlap.

**Comparison at a glance:**

| | Zigbee | Wi-Fi | Thread | Z-Wave |
|---|---|---|---|---|
| Best for | Smart switches, sensors, lighting | High-bandwidth: video, internet | Connected smart home, works with Matter | Core smart home devices: sensors, locks |
| Frequency | 2.4 GHz (shares band with Wi-Fi) | 2.4/5 GHz | 2.4 GHz | Sub-GHz (avoids Wi-Fi interference) |
| Power draw | Very low | High | Very low | Very low |
| Reliability | Good mesh | Depends on the network | Very high, self-healing, IP-based | Excellent — low interference, strong wall penetration |

**Practical rule of thumb I give every new installer:** choose Wi-Fi for anything that needs bandwidth and is plugged into mains power; choose Zigbee for the bulk of switches and sensors where cost and device variety matter; choose Z-Wave when reliability in a crowded RF environment matters most (locks, security devices); and choose Thread when you''re building for the long term, since it''s the backbone protocol for Matter and reduces future dependence on any single hub brand.', 'البروتوكول هو "اللغة" المشتركة والقواعد التي تتيح للأجهزة تبادل البيانات بشكل موثوق — تنسيق البيانات، التحكم بتدفقها حتى لا تُثقل الأجهزة، اكتشاف الأخطاء وتصحيحها، وإيجاد أفضل مسار عبر الشبكة. يتعامل فني المنزل الذكي مع أربعة بروتوكولات لاسلكية بانتظام، واختيار الأنسب لكل جهاز مهارة احترافية أساسية، لا تفصيلة ثانوية.

**Wi-Fi** — عام الاستخدام، عريض النطاق، يتصل مباشرة بالراوتر. الأفضل للأجهزة التي تنقل بيانات بحجم حقيقي: الكاميرات، أجهزة البث، أي شيء بشاشة. العيب: استهلاك طاقة أعلى (غير مثالي للأجهزة بالبطارية) وكل جهاز يضيف حملًا مباشرًا على الراوتر.

**Zigbee** — بروتوكول منخفض الطاقة ومنخفض معدل نقل البيانات، مصمم خصيصًا لإنترنت الأشياء. تكوّن الأجهزة شبكة شبكية ذاتية الإصلاح — تعمل الأجهزة المتصلة بالكهرباء كمعيدات إشارة، فتوسع المدى والموثوقية كلما انضمت أجهزة أكثر، دون الحاجة لمحور مركزي لكل رابط. مثالي للمفاتيح والحساسات والأوامر البسيطة، لا لنقل بيانات كبيرة.

**Thread** — البروتوكول المبني خصيصًا كأساس لمعيار Matter العابر للعلامات التجارية المستقبلي. أيضًا قائم على الشبكة الشبكية ومنخفض الطاقة، لكنه مبني على IPv6 من الأساس، ما يسهّل التواصل المباشر والفعّال مع الأنظمة المتصلة بالإنترنت أكثر مما تسمح به بنية Zigbee الأقدم.

**Z-Wave** — مشابه في الغرض لـZigbee (شبكة شبكية، منخفض الطاقة، حساسات ومفاتيح) لكنه يعمل على ترددات لاسلكية مختلفة وأقل (نحو 800-900 ميجاهرتز بدلًا من 2.4 جيجاهرتز الخاص بـZigbee)، ما يتجنب التداخل مع شبكات Wi-Fi — ميزة حقيقية في الشقق الحضرية المزدحمة حيث تتداخل شبكات كثيرة.

**مقارنة سريعة:**

| | Zigbee | Wi-Fi | Thread | Z-Wave |
|---|---|---|---|---|
| الأنسب لـ | مفاتيح ذكية، حساسات، إضاءة | نطاق عريض: فيديو، إنترنت | منزل ذكي متصل، يعمل مع Matter | أجهزة منزل ذكي أساسية: حساسات، أقفال |
| التردد | 2.4 جيجاهرتز (يشارك نطاق Wi-Fi) | 2.4/5 جيجاهرتز | 2.4 جيجاهرتز | دون الجيجاهرتز (يتجنب تداخل Wi-Fi) |
| استهلاك الطاقة | منخفض جدًا | مرتفع | منخفض جدًا | منخفض جدًا |
| الموثوقية | شبكة شبكية جيدة | تعتمد على الشبكة | عالية جدًا، ذاتية الإصلاح، قائمة على IP | ممتازة — تداخل أقل، اختراق جدران قوي |

**قاعدة عملية أعطيها لكل فني جديد:** اختر Wi-Fi لأي شيء يحتاج نطاقًا عريضًا ومتصل بالكهرباء مباشرة؛ اختر Zigbee لمعظم المفاتيح والحساسات حيث تهم التكلفة وتنوع الأجهزة؛ اختر Z-Wave عندما تكون الموثوقية في بيئة راديوية مزدحمة هي الأهم (الأقفال، أجهزة الأمان)؛ واختر Thread عندما تبني لأجل المستقبل، لأنه البروتوكول الأساسي لمعيار Matter ويقلل الاعتماد المستقبلي على علامة تجارية واحدة لبوابة التحكم.', 4 FROM public.modules WHERE slug = 'finix-networking-ip-protocols';
