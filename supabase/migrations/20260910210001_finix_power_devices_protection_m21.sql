-- Module F04: Power Conversion Devices & Electrical Protection Equipment
-- Rewritten/summarized explanations, restructured from Finix's own internal training document.

INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position) VALUES ('finix-power-devices-protection', 'F04', 'finix-technician-academy', 'Power Conversion Devices & Electrical Protection Equipment', 'أجهزة تحويل الطاقة ومعدات الحماية الكهربائية', 'Adapters vs power supplies vs chargers and battery charging curves, circuit breaker types (MCB/MCCB/ACB) and selection rules, relay structure and types, and contactors/selector switches/overload protection.', 'الفرق بين الأدابتور ومزود الطاقة والشاحن ومنحنيات شحن البطاريات، أنواع قواطع الدوائر وقواعد اختيارها، تركيب الريليه وأنواعه، والكونتاكتور ومفاتيح الاختيار وحماية الحمل الزائد.', NULL, 21);
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'Adapters, Power Supplies & Chargers: Key Differences', 'الفرق بين الأدابتور ومزود الطاقة والشاحن', 'Three device types often get confused despite very different jobs:

**Adapter** — a small external converter that steps down AC mains to a fixed, low DC voltage/current (e.g. 12V or 9V at a set amperage) to feed one specific device. It has no smart circuitry and doesn''t disconnect power automatically. Typical examples: router adapters, monitor adapters, modem adapters.

**Power Supply** — a larger, often internal or industrial unit that delivers a continuous, stable power feed to several circuits at once, standing out for its ability to sustain high, stable current without the voltage sagging under heavy load. Some variable/adjustable types exist for precise manual control (used in maintenance/lab settings). Typical examples: a desktop PC''s internal power supply, a CCTV camera system''s power supply.

**Charger** — a device dedicated specifically to charging batteries; it doesn''t just convert current, it manages the charging process itself. Its output voltage/current rises and falls dynamically depending on battery fill level and temperature, and it contains a smart cutoff circuit that stops or reduces current once the battery reaches 100% to protect against damage or explosion. Typical examples: phone chargers, laptop chargers, car battery chargers.

**How charger voltage changes through the charging curve** (illustrated with lithium-ion battery charging behavior, which follows 3 main stages):

1. **Constant Current (CC) stage** — battery is nearly empty (0% to roughly 70-80%). Current is held at a fixed maximum safe rate to push energy in quickly, while voltage rises gradually as the cell''s internal resistance is overcome, until it approaches the cell''s safe maximum (commonly around 4.2V per cell).

2. **Constant Voltage (CV) stage** — battery is 80% to ~99% full. Voltage stops rising and holds steady at the safe maximum, while current begins tapering down gradually and then rapidly (this stage is sometimes called the saturation phase), since the remaining charge capacity needed keeps shrinking.

3. **Trickle/float charge stage** — battery reaches 100%. Voltage drops slightly to a safe "maintenance" level; current and voltage both settle to very low levels, whose only job is compensating for the battery''s natural self-discharge leakage while it sits on the charger, without stressing the cells.

**Fast-charging protocols** (Quick Charge, USB Power Delivery) don''t just rely on the traditional battery curve — they run a digital negotiation protocol between the phone''s processor and the charger: the phone initially requests a higher available voltage (e.g. 9V, 12V, or even 20V) to push power at high speed in the first few minutes, then as the phone heats up or the battery approaches full, the processor signals the charger to step the voltage down gradually and intelligently (in small steps, e.g. 0.2V increments) to keep the phone from overheating.', 'ثلاثة أنواع أجهزة كثيرًا ما تُخلط رغم اختلاف وظيفتها تمامًا:

**الأدابتور (Adapter)** — محول خارجي صغير يخفّض التيار المتردد من الشبكة إلى تيار مستمر ثابت الجهد/التيار (مثل 12 فولت أو 9 فولت بأمبير محدد) لتغذية جهاز واحد بعينه. لا يحتوي دوائر ذكية ولا يفصل الطاقة تلقائيًا. أمثلة شائعة: أدابتور الراوتر، أدابتور الشاشة، أدابتور المودم.

**مزود الطاقة (Power Supply)** — وحدة أكبر، غالبًا داخلية أو صناعية، توفر تغذية طاقة مستمرة ومستقرة لعدة دوائر في آن واحد، وتتميز بقدرتها العالية على توفير تيار مرتفع وثابت دون أن ينخفض الجهد تحت الأحمال الثقيلة. توجد أنواع متغيرة/قابلة للضبط للتحكم اليدوي الدقيق (تُستخدم في الصيانة والمختبرات). أمثلة شائعة: مزود طاقة الكمبيوتر المكتبي الداخلي، مزود طاقة منظومة كاميرات المراقبة.

**الشاحن (Charger)** — جهاز مخصص لشحن البطاريات تحديدًا؛ لا يكتفي بتحويل التيار بل يدير عملية الشحن نفسها. جهده وتياره الخارجان يرتفعان وينخفضان ديناميكيًا حسب حالة امتلاء البطارية ودرجة حرارتها، ويحتوي دائرة فصل ذكية توقف أو تخفض التيار عند وصول البطارية لنسبة 100٪ لحمايتها من التلف أو الانفجار. أمثلة شائعة: شاحن الهاتف، شاحن اللابتوب، شاحن بطارية السيارة.

**كيف يتغير جهد الشاحن عبر منحنى الشحن** (موضّح بسلوك شحن بطاريات الليثيوم أيون، الذي يمر بثلاث مراحل أساسية):

١. **مرحلة التيار الثابت (CC)** — البطارية شبه فارغة (من 0٪ إلى نحو 70-80٪). يُثبَّت التيار عند أقصى معدل آمن لدفع الطاقة بسرعة، بينما يرتفع الجهد تدريجيًا مع التغلب على المقاومة الداخلية للخلية، حتى يقترب من الحد الآمن الأقصى للخلية (غالبًا نحو 4.2 فولت لكل خلية).

٢. **مرحلة الجهد الثابت (CV)** — البطارية من 80٪ إلى نحو 99٪ ممتلئة. يتوقف الجهد عن الارتفاع ويستقر عند الحد الآمن الأقصى، بينما يبدأ التيار بالانخفاض التدريجي ثم السريع (تُسمى هذه المرحلة أحيانًا مرحلة التشبّع)، لأن كمية الشحنات المتبقية المطلوبة تتقلص باستمرار.

٣. **مرحلة الشحن المنقّط/العائم** — البطارية وصلت 100٪. ينخفض الجهد قليلًا إلى مستوى "صيانة" آمن؛ يستقر التيار والجهد عند مستويات منخفضة جدًا، وظيفتها الوحيدة تعويض أي تسريب طبيعي للشحن أثناء بقاء البطارية على الشاحن، دون إجهاد الخلايا.

**تقنيات الشحن السريع** (Quick Charge وUSB Power Delivery) لا تعتمد فقط على منحنى البطارية التقليدي — بل تُجري بروتوكول تفاوض رقمي بين معالج الهاتف والشاحن: يطلب الهاتف في البداية جهدًا أعلى متاحًا (مثل 9 أو 12 أو حتى 20 فولت) لدفع الطاقة بسرعة عالية في الدقائق الأولى، ثم مع ارتفاع حرارة الهاتف أو اقتراب البطارية من الامتلاء، يرسل المعالج إشارة للشاحن لخفض الجهد تدريجيًا وبذكاء (بخطوات صغيرة، مثل زيادات 0.2 فولت) للحفاظ على برودة الهاتف.', 1 FROM public.modules WHERE slug = 'finix-power-devices-protection';
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'Circuit Breakers: MCB, MCCB & ACB', 'قواطع الدوائر: MCB وMCCB وACB', 'Circuit breakers protect a circuit from overload and short-circuit conditions, and disconnect current automatically when a fault occurs.

**MCB (Miniature Circuit Breaker)** — protects against overload and short-circuit only. Trip current is fixed, not adjustable. Trip curves define breaker sensitivity: Type B trips at 3-5× rated current (suitable for homes: lighting, heaters), Type C trips at 5-10× rated current (suitable for small motors, pumps, AC units), Type D trips at 10-20× rated current (suitable for large motors, loads with high starting currents), plus specialty types K and Z for sensitive electronic equipment. Rated current maxes out around 125A. Not maintainable — the whole breaker is replaced when damaged. Suitable for light loads: lighting, outlets, and light-current systems in homes.

**MCCB (Molded Case Circuit Breaker)** — protects against overload and short-circuit, and some variants add an earth-leakage protection module (ELCB). Some types add a 4th pole to connect the neutral separately in addition to the three phases (L1, L2, L3). Adjustable trip current and trip time on most models, within a defined range. Rated current can reach 2500A or more. Some parts (the trip unit) are maintainable and replaceable. Multiple additional features: auxiliary contact points, control relays, shunt trip coils, and remote monitoring/control. A key protective feature called "Current Limitation" caps how high the short-circuit current can rise, protecting the downstream network. MCCB is the primary protection system in low-voltage distribution networks and industrial applications, given its ability to handle very high currents with adjustable, maintainable, and remotely monitorable features.

**ACB (Air Circuit Breaker)** — similar to MCCB but more advanced and handles higher loads, used primarily in main distribution boards (MDBs). Additional features: withdrawable design for easy removal from the panel for maintenance without dismantling busbars/cables, full maintenance capability including contact replacement, rated current up to 6300A, uses push-button controls for trip/close operation unlike other breaker types.

**How to choose a circuit breaker:**
1. Source current type (1-phase / 3-phase).
2. Current type: AC or DC.
3. Breaker capacity (rated current) selected to match the load current and the cable''s current-carrying capacity.

**Breaker current selection basis:** breaker capacity depends on the primary load current × 1.25, so the breaker rating is at least 25% above the load current (safety margin). **Cable current selection basis:** cable capacity is selected based on the breaker''s rated current (not the load current), and must be at least 20% above the breaker''s rating — because the breaker''s job is to protect the cable, not the reverse.', 'تحمي قواطع الدوائر الدائرة من حالات الحمل الزائد وقصر الدائرة، وتفصل التيار تلقائيًا عند حدوث عطل.

**قاطع MCB (القاطع المصغّر)** — يحمي من الحمل الزائد وقصر الدائرة فقط. تيار الفصل ثابت غير قابل للتعديل. منحنيات الفصل تحدد حساسية القاطع: الفئة B تفصل عند 3-5 أضعاف التيار المقنن (مناسبة للمنازل: إضاءة، سخانات)، الفئة C تفصل عند 5-10 أضعاف (مناسبة للمحركات الصغيرة، المضخات، التكييفات)، الفئة D تفصل عند 10-20 ضعفًا (مناسبة للمحركات الكبيرة والأحمال ذات تيارات البدء العالية)، بالإضافة إلى فئتين متخصصتين K وZ للأجهزة الإلكترونية الحساسة. التيار المقنن يصل حتى نحو 125 أمبير. غير قابل للصيانة — يُستبدل القاطع بالكامل عند التلف. مناسب للأحمال الخفيفة: الإضاءة والمقابس وأنظمة التيار الخفيف في المنازل.

**قاطع MCCB (القاطع مصبوب الهيكل)** — يحمي من الحمل الزائد وقصر الدائرة، وبعض الأنواع تضيف وحدة حماية من التسريب الأرضي (ELCB). بعض الأنواع تضيف قطبًا رابعًا لتوصيل النيوترال منفصلًا بالإضافة للأطوار الثلاثة (L1, L2, L3). تيار الفصل وزمن الفصل قابلان للضبط في أغلب الموديلات ضمن مدى محدد. التيار المقنن يصل حتى 2500 أمبير أو أكثر. بعض الأجزاء (وحدة الفصل) قابلة للصيانة والاستبدال. ميزات إضافية متعددة: نقاط مساعدة، ريليهات تحكم، ملفات فصل عن بعد (Shunt Trip)، ومراقبة وتحكم عن بُعد. ميزة حماية مهمة تُسمى "تحديد التيار" (Current Limitation) تحد من ارتفاع تيار قصر الدائرة، ما يحمي الشبكة الواقعة خلفه. يُعد MCCB نظام الحماية الأساسي في شبكات توزيع الجهد المنخفض والتطبيقات الصناعية، نظرًا لقدرته على تحمل تيارات عالية جدًا مع إمكانات ضبط وصيانة ومراقبة عن بُعد.

**قاطع ACB (القاطع الهوائي)** — يشبه MCCB لكنه أكثر تطورًا ويتحمل أحمالًا أعلى، يُستخدم أساسًا في لوحات التوزيع الرئيسية الكبيرة (MDBs). ميزات إضافية: قابل للسحب لسهولة إخراجه من اللوحة للصيانة دون فك الأسلاك أو البارات، قابلية صيانة كاملة تشمل استبدال نقاط التلامس، التيار المقنن يصل حتى 6300 أمبير، يستخدم مفاتيح ضغط لعملية الفصل والتوصيل بخلاف باقي أنواع القواطع.

**كيفية اختيار القاطع الكهربائي:**
١. نوع مصدر التيار (طور واحد / ثلاثة أطوار).
٢. نوع التيار: متردد أم مستمر.
٣. سعة القاطع (التيار المقنن) تُختار بما يتناسب مع تيار الحمل وسعة تحمل الكابل.

**أساس اختيار تيار القاطع:** تعتمد سعة القاطع على تيار الحمل الأساسي مضروبًا في 1.25، بحيث يكون القاطع أعلى من تيار الحمل بنسبة 25٪ على الأقل (هامش أمان). **أساس اختيار تيار الكابل:** تُحدد سعة الكابل بناءً على تيار القاطع المقنن (لا تيار الحمل)، ويجب أن تكون أعلى من تيار القاطع بنسبة 20٪ على الأقل — لأن وظيفة القاطع حماية الكابل لا العكس.', 2 FROM public.modules WHERE slug = 'finix-power-devices-protection';
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'Relays: Structure, Operation & Types', 'الريليه: التركيب والتشغيل والأنواع', 'A relay is an electrically-operated switch that works automatically, using a small control signal to control a much larger current or voltage — a core component in smart home switches and devices.

**Basic relay components:**
- **Coil** — when current passes through it, it generates a magnetic field.
- **Iron Core** — amplifies the magnetic field produced by the coil.
- **Armature** — a movable metal piece attracted toward the iron core when the coil is energized.
- **Contacts** — electrical switches whose position (open or closed) is controlled by the movement of the armature.

**How it works:** applying voltage to the coil generates a magnetic field that attracts the armature; the armature''s movement either closes or opens the circuit; when current to the coil is cut, the magnetic field collapses and a spring returns the armature and contacts to their original position.

**Connection types:**
- **NO (Normally Open)** — the circuit is open (no current flows) and only closes when the relay is energized.
- **NC (Normally Closed)** — the circuit is closed (current flows) and opens when the relay is energized.
- **COM (Common)** — the shared point that switches between NO and NC.

**Relay benefits:** it isolates the control circuit (the smart device/controller) from the load circuit, so it protects the lower-power control side; it allows controlling high currents through small, low-power/low-voltage control signals; and it''s used inside smart home switches, appliances, and lighting circuits, reducing the need for manual intervention.

**Relay types:** **Electromechanical relays** — the most common type, using magnetic principles to move mechanical parts that open/close the contact points. **Solid State Relays (SSR)** — no moving parts, using electronic components (transistors or thyristors) to control current flow — stand out for switching speed and long service life. **Reed relays** — consist of a pair of magnetic metal reeds inside a sealed glass tube filled with inert gas, closing when an external magnetic field is applied.', 'الريليه مفتاح كهربائي يعمل تلقائيًا، يستخدم إشارة تحكم صغيرة للتحكم في تيار أو جهد أكبر بكثير — مكون أساسي في مفاتيح وأجهزة المنزل الذكي.

**مكونات الريليه الأساسية:**
- **الملف (Coil)** — عند مرور تيار فيه يولّد مجالًا مغناطيسيًا.
- **البالة الحديدية (Iron Core)** — تعزز المجال المغناطيسي الناتج عن الملف.
- **الذراع المتحركة (Armature)** — قطعة معدنية متحركة تُجذب نحو البالة الحديدية عند تنشيط الملف.
- **نقاط التلامس (Contacts)** — مفاتيح كهربائية يُتحكم بوضعها (فتح أو غلق) عبر حركة الذراع المتحركة.

**طريقة العمل:** تطبيق جهد على الملف يولّد مجالًا مغناطيسيًا يجذب الذراع المتحركة؛ حركة الذراع تؤدي إما لإغلاق الدائرة الكهربائية أو فتحها؛ عند انقطاع التيار عن الملف، يزول المجال المغناطيسي ويعيد نابض الذراع ونقاط التلامس إلى وضعها الأصلي.

**أنواع التوصيل:**
- **NO (عادة مفتوح)** — تكون الدارة مفتوحة (لا يمر تيار) وتُغلق فقط عند تنشيط الريليه.
- **NC (عادة مغلق)** — تكون الدارة مغلقة (يمر تيار) وتُفتح عند تنشيط الريليه.
- **COM (مشترك)** — النقطة المشتركة التي تنتقل بين NO وNC.

**فوائد الريليه:** يعزل دائرة التحكم (الجهاز الذكي أو الكنترولر) عن دائرة الحمل، فيحمي طرف التحكم الأقل قدرة؛ يسمح بالتحكم في تيارات عالية عبر إشارات تحكم صغيرة منخفضة القدرة/الجهد؛ ويُستخدم داخل مفاتيح المنزل الذكي والأجهزة ودوائر الإضاءة، ما يقلل الحاجة للتدخل اليدوي.

**أنواع الريليه:** **الريليهات الكهروميكانيكية** — الأكثر شيوعًا، تستخدم مبدأ المغناطيسية لتحريك أجزاء ميكانيكية تفتح أو تغلق نقاط التلامس. **ريليهات الحالة الصلبة (SSR)** — بلا أجزاء متحركة، تستخدم مكونات إلكترونية (ترانزستورات أو ثايرستورات) للتحكم بتدفق التيار — تتميز بسرعة التبديل العالية وعمرها الطويل. **ريليهات القصبة (Reed)** — تتكون من زوج من القصبات المعدنية المغناطيسية داخل أنبوب زجاجي محكم مملوء بغاز خامل، تُغلق عند تطبيق مجال مغناطيسي خارجي.', 3 FROM public.modules WHERE slug = 'finix-power-devices-protection';
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'Contactors, Selector Switches & Overload Protection', 'الكونتاكتور ومفاتيح الاختيار وحماية الحمل الزائد', '**Contactor** — an electromagnetic switch used to control switching high-power electrical circuits, like electric motors, heating systems, and large-scale lighting.

**Core contactor components:** **Coil** — generates a magnetic field when current passes through it. **Iron core** — split into two parts (fixed and moving) that attract each other when the coil is activated. **Main contacts** — responsible for carrying the high current to the load (e.g. a motor). **Auxiliary contacts** — used in control circuits and interlocking operations.

**How it works:** when current flows to the contactor''s coil based on a control signal, it flips the contact positions — normally-open contacts close, normally-closed contacts open. When control current is cut, contacts return to their natural (default) state.

**Choosing a contactor:** the current/power rating of the load it will control; the coil voltage must match the control circuit''s voltage; and the number of open/closed auxiliary contact points needed.

**Relay vs. contactor comparison:** contactor contacts handle much higher current than a relay, which is designed for weaker loads. Contactors are preferred in 3-phase circuits. Relays don''t have extra auxiliary contacts by default, while a contactor''s auxiliary contacts can be expanded. Contactors are commonly controlled via a push button with an auxiliary hold contact, and can also be controlled remotely via a smart relay device or through programming.

**Selector Switch** — a type of electrical switch distinguished by the ability to choose a specific position from several possible positions, used to control machine/industrial equipment functions such as running a motor or controlling a specific system.

**Selector switch types:** **Two-Position** — choosing between two states, e.g. "on" and "off". **Three-Position** — choosing among three states, e.g. "on" (right), "off" (middle), "on" (left). **Manual/Automatic Selector** — for switching between manual and automatic operation modes. **Momentary Selector** — returns to its original position after the handle is released, used with a spring for automatic return. **Key Selector** — features a lock and key for increased security and to prevent unauthorized changes.

**Overload Protection (Overload Relay)** — an electrical protection device, also known as a thermal breaker, whose core job is to protect motors and electrical equipment from damage caused by excess current beyond the allowed limit, by automatically disconnecting the current; it can be reset manually after the overload cause is resolved. Types: **thermal** (relies on heat generated by current, using thermal windings around the motor''s terminals) and **electronic** (uses electronic sensors to measure current with greater accuracy).

**How overload sizing works — worked example:** for a standard motor, the setting current is calculated by multiplying the motor''s rated FLA (Full Load Amps, from the motor''s nameplate) by a factor of roughly 1.1 to 1.25. So if a motor''s FLA is 10A, the overload should be set somewhere between 11A and 12.5A (e.g. set at 11.5A) — then an overload device is chosen whose adjustable range covers that target setting current.', '**الكونتاكتور** — مفتاح كهرومغناطيسي يُستخدم للتحكم في فصل ووصل الدوائر الكهربائية ذات القدرة العالية، مثل المحركات الكهربائية وأنظمة التدفئة والإضاءة واسعة النطاق.

**مكونات الكونتاكتور الأساسية:** **الملف (Coil)** — يولّد مجالًا مغناطيسيًا عند مرور التيار فيه. **النواة الحديدية** — تنقسم إلى جزأين (ثابت ومتحرك) ينجذبان لبعضهما عند تفعيل الملف. **نقاط التلامس الرئيسية** — مسؤولة عن تمرير التيار العالي للحمل (مثل المحرك). **نقاط التلامس المساعدة** — تُستخدم في دوائر التحكم وعمليات الربط (Interlocking).

**طريقة العمل:** عند مرور تيار كهربائي إلى ملف الكونتاكتور بناءً على إشارة تحكم، فإنه يغيّر وضع نقاط التلامس — النقاط المفتوحة عادة تُغلق، والنقاط المغلقة عادة تُفتح. عند انقطاع تيار التحكم، تعود نقاط التلامس إلى وضعها الطبيعي (الافتراضي).

**اختيار الكونتاكتور:** تصنيف التيار/القدرة للحمل الذي سيعمل عليه؛ يجب أن يكون جهد الملف متوافقًا مع جهد دائرة التحكم؛ وعدد نقاط التلامس المساعدة المفتوحة والمغلقة المطلوبة.

**مقارنة الريليه بالكونتاكتور:** نقاط تلامس الكونتاكتور تتحمل تيارًا أعلى بكثير من الريليه المصمم لأحمال أضعف. يُفضَّل الكونتاكتور في دوائر الأطوار الثلاثة. لا يملك الريليه نقاط تلامس مساعدة إضافية افتراضيًا، بينما يمكن زيادة نقاط التلامس المساعدة في الكونتاكتور. يُتحكم بالكونتاكتور عادة عبر زر ضغط مع نقطة تلامس مساعدة للإبقاء عليه شغالًا، ويمكن أيضًا التحكم به عن بعد عبر جهاز ريليه ذكي أو من خلال البرمجة.

**مفتاح الاختيار (Selector Switch)** — نوع من المفاتيح الكهربائية يتميز بإمكانية اختيار وضع محدد من بين عدة أوضاع ممكنة، يُستخدم للتحكم في وظائف الآلات والمعدات الصناعية مثل تشغيل محرك أو التحكم في نظام معين.

**أنواع مفتاح الاختيار:** **مفتاح ثنائي الوضع** — الاختيار بين حالتين، مثل "تشغيل" و"إيقاف". **مفتاح ثلاثي الوضع** — الاختيار بين ثلاث حالات، مثل "تشغيل" (يمين)، "إيقاف" (وسط)، "تشغيل" (يسار). **مفتاح يدوي/تلقائي** — للتحويل بين وضعي التشغيل اليدوي والتلقائي. **مفتاح ذو رجوع تلقائي** — يعود إلى وضعه الأصلي بعد ترك المقبض، يُستخدم مع نابض للعودة التلقائية. **مفتاح بمفتاح قفل** — يتميز بقفل ومفتاح لزيادة الأمان ومنع التغيير غير المصرح به.

**حماية الحمل الزائد (الأوفرلود)** — جهاز حماية كهربائي، يُعرف أيضًا بالقاطع الحراري، وظيفته الأساسية حماية المحركات والأجهزة الكهربائية من التلف الناتج عن التيار الزائد عن الحد المسموح، عبر فصل التيار تلقائيًا؛ يمكن إعادة ضبطه يدويًا بعد زوال سبب الحمل الزائد. الأنواع: **حراري** (يعتمد على الحرارة الناتجة عن التيار باستخدام ملفات حرارية حول أطراف المحرك) و**إلكتروني** (يستخدم مستشعرات إلكترونية لقياس التيار بدقة أعلى).

**كيفية حساب ضبط الأوفرلود — مثال محلول:** لمحرك قياسي، يُحسب تيار الضبط بضرب التيار المقنن FLA (Full Load Amps، من لوحة بيانات المحرك) في معامل يتراوح تقريبًا بين 1.1 و1.25. فإذا كان تيار FLA لمحرك ما 10 أمبير، يُضبط الأوفرلود بين 11 و12.5 أمبير (مثلًا يُضبط على 11.5 أمبير) — ثم يُختار جهاز أوفرلود يغطي مداه القابل للضبط قيمة تيار الضبط المستهدفة.', 4 FROM public.modules WHERE slug = 'finix-power-devices-protection';
