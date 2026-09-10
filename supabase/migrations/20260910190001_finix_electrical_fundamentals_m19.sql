-- Module F02: Electrical Fundamentals Deep-Dive
-- Rewritten explanations of core electrical concepts (DC/AC, Ohm's law, cable sizing, 3-phase),
-- restructured from Finix's own internal training document into clean bilingual lesson content.

INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position) VALUES ('finix-electrical-fundamentals-deep-dive', 'F02', 'finix-technician-academy', 'Electrical Fundamentals Deep-Dive: DC/AC, Ohm''s Law, Cable Sizing & 3-Phase Power', 'التعمق في أساسيات الكهرباء: التيار المستمر والمتردد وقانون أوم وتحديد مقاس الكابل والقدرة ثلاثية الطور', 'DC vs AC theory and comparison, Ohm''s/Power laws with real formulas, worked cable-sizing calculations, and three-phase Star/Delta motor connections with worked examples.', 'نظرية التيار المستمر والمتردد ومقارنتهما، قوانين أوم والقدرة بصيغ حقيقية، حسابات محلولة لتحديد مقاس الكابل، وتوصيلات المحركات ثلاثية الطور نجمة/دلتا بأمثلة محلولة.', NULL, 19);
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'DC vs AC: Fundamentals Every Installer Needs', 'التيار المستمر مقابل المتردد: الأساسيات التي يحتاجها كل فني', 'Electricity is the flow of electrical charge through a conductor (e.g. a wire). Two fundamentally different current types exist:

**Direct Current (DC)** — symbol: a straight line ⎓. Current flows in one direction only, with constant magnitude. Common in batteries, solar cells, and cars; easy to store, but expensive and inefficient to transmit over long distances (significant loss). Can be converted to AC via an inverter.

**Alternating Current (AC)** — symbol: a wavy line ~. Both magnitude and direction change periodically (50 or 60 Hz depending on the country''s grid standard). Used to supply homes and buildings over long distances because voltage can be stepped up or down easily via transformers, with lower transmission loss than DC. Converted to DC via a rectifier bridge.

**Comparison table:**

| Property | AC | DC |
|---|---|---|
| Value & direction | Both change over time | Both constant |
| Frequency | 50 or 60 Hz depending on grid | No frequency |
| Power factor | Between 0 and 1 | Always 1 (unity) |
| Generation | Generators | Batteries, solar cells, rectifiers |
| Transmission | Long distances, low loss | Very short distances, high loss |
| Conversion | To DC via rectifier | To AC via inverter |
| Use | Homes, factories, grid | Electronics, cars, solar systems |

**Why the world still hasn''t fully switched to DC:** three key reasons. First, historically, AC''s voltage could be stepped up/down easily via transformers, while early DC step-up/down required bulky and expensive equipment. Second, technically, AC circuit breakers work by using the current''s natural zero-crossing (twice per cycle) to safely extinguish the arc when interrupting a circuit — DC current never crosses zero, so DC breakers require more complex, more expensive arc-quenching mechanisms. Third, economically, high-voltage DC (HVDC) is now used for very long-distance transmission (e.g. undersea cables) because it has lower losses over those distances, but it requires expensive converter stations at both ends, making it worthwhile only for specific large-scale cases, not general-purpose home/city power.', 'الكهرباء هي تدفق الشحنة الكهربائية عبر موصل (مثل الأسلاك). يوجد نوعان مختلفان جوهريًا من التيار:

**التيار المستمر (DC)** — رمزه خط مستقيم ⎓. يتدفق التيار في اتجاه واحد فقط وبمقدار ثابت. يوجد عادةً في البطاريات والخلايا الشمسية والسيارات؛ سهل التخزين لكن نقله لمسافات طويلة صعب ومكلف (فقد كبير). يمكن تحويله إلى تيار متردد باستخدام إنفرتر (عاكس).

**التيار المتردد (AC)** — رمزه خط متموج ~. تتغير قيمته واتجاهه بشكل دوري (تردده 50 أو 60 هرتز حسب النظام المتبع بالدولة). يُستخدم لتزويد المنازل والمباني بالطاقة عبر مسافات طويلة لأن رفع أو خفض جهد المصدر ممكن بسهولة عبر المحولات، مع فقد أقل عند النقل مقارنة بالتيار المستمر. يمكن تحويله إلى تيار مستمر عبر دائرة توحيد كامل (Rectifier).

**جدول المقارنة:**

| عنصر المقارنة | التيار المتردد | التيار المستمر |
|---|---|---|
| القيمة والاتجاه | متغيران | ثابتان |
| التردد | 50 أو 60 هرتز حسب الشبكة | لا يوجد تردد |
| معامل القدرة | بين الصفر والواحد | دائمًا واحد صحيح |
| التوليد | مولدات كهربائية | بطاريات، خلايا شمسية، دوائر توحيد |
| النقل | مسافات طويلة بفقد أقل | مسافات قصيرة جدًا بفقد كبير |
| التحويل | إلى مستمر عبر رئيفير | إلى متردد عبر إنفرتر |
| الاستخدام | المنازل والمصانع والشبكة | الإلكترونيات، السيارات، الأنظمة الشمسية |

**لماذا لم يستبدل العالم التيار المتردد بالمستمر بالكامل حتى الآن:** ثلاثة أسباب أساسية. أولًا تاريخيًا، كان رفع أو خفض جهد التيار المتردد سهلًا عبر المحولات، بينما رفع أو خفض التيار المستمر قديمًا كان يحتاج معدات ضخمة ومكلفة. ثانيًا تقنيًا، تعمل قواطع التيار المتردد عبر استغلال مرور التيار بالصفر بشكل طبيعي (مرتين كل دورة) لإطفاء القوس الكهربائي بأمان عند فصل الدائرة — بينما التيار المستمر لا يمر بالصفر أبدًا، فتحتاج قواطعه آليات أكثر تعقيدًا وتكلفة لإطفاء القوس. ثالثًا اقتصاديًا، يُستخدم التيار المستمر عالي الجهد (HVDC) حاليًا لنقل الطاقة لمسافات طويلة جدًا (مثل الكابلات البحرية) لأن فقده أقل على تلك المسافات، لكنه يحتاج محطات تحويل مكلفة في الطرفين، ما يجعله مجديًا فقط لحالات ضخمة محددة، لا للاستخدام العام في المنازل والمدن.', 1 FROM public.modules WHERE slug = 'finix-electrical-fundamentals-deep-dive';
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'Voltage, Current, Resistance & Power: The Core Laws', 'الجهد والتيار والمقاومة والقدرة: القوانين الأساسية', '**Voltage (V)** — a measure of the potential energy possessed by charges at one point compared to another; it''s the pressure that pushes electrical charge. Measured in Volts, symbol V, measured with a voltmeter or multimeter — always between two points.

**Current (I)** — the quantity of electrons passing a point in a conductor over a defined time period. Measured in Amperes, symbol A, measured with an ammeter or multimeter by connecting it in series in the circuit.

**Resistance (R)** — the opposition a conductor presents to current flowing through it. Measured in Ohms, symbol Ω.

**Ohm''s Law:** V = I × R

**Power (P)** — the rate at which electrical energy is converted to another energy form (heat, light, or motion). Measured in Watts, symbol W.

**Power Law:** P = V × I, and combined with Ohm''s Law: P = V × I × cos(θ) where θ is the phase angle between voltage and current (relevant for AC).

**Energy (E)** — total consumption over a period of time: E = P × T, measured in kilowatt-hours.

Applying Ohm''s Law to real troubleshooting: if resistance increases while voltage stays constant, current decreases proportionally (per the law). If voltage and current are too close because a load''s internal resistance dropped, current rises too — and since power = V × I, rising current at constant voltage means higher power draw, which is what damages devices designed for their rated load when they''re connected to the wrong voltage (e.g. a 110V-rated device connected to a 220V line will overheat its windings and fail).', '**الجهد (V)** — مقياس لمقدار الطاقة الكامنة التي تملكها الشحنات في نقطة معينة مقارنة بنقطة أخرى؛ هو الضغط الذي يدفع الشحنة الكهربائية. يُقاس بالفولت، رمزه V، ويُقاس دائمًا بين نقطتين باستخدام الفولتميتر أو الملتيميتر.

**التيار (I)** — كمية الإلكترونات التي تمر في نقطة في الموصل خلال فترة زمنية محددة. يُقاس بالأمبير، رمزه A، ويُقاس بجهاز الأميتر أو الملتيميتر بتوصيله على التوالي في الدائرة.

**المقاومة (R)** — العرقلة التي يقابلها التيار في مروره عبر موصل ما. تُقاس بالأوم، رمزها Ω.

**قانون أوم:** V = I × R

**القدرة (P)** — معدل تحول الطاقة الكهربائية إلى شكل آخر من الطاقة (حرارية أو ضوئية أو حركية). تُقاس بالوات، رمزها W.

**قانون القدرة:** P = V × I، ومدمجًا مع قانون أوم: P = V × I × cos(θ) حيث θ هي زاوية الطور بين الجهد والتيار (مهمة في التيار المتردد).

**الطاقة (E)** — الاستهلاك الكلي على مدى فترة زمنية: E = P × T، وتُقاس بالكيلوات ساعة.

تطبيق قانون أوم على استكشاف الأعطال الفعلي: إذا زادت المقاومة مع ثبات الجهد، يقل التيار تناسبيًا (طبقًا للقانون). وإذا اقترب الجهد والتيار بسبب انخفاض المقاومة الداخلية للحمل، يزيد التيار أيضًا — وبما أن القدرة = الجهد × التيار، فإن زيادة التيار مع ثبات الجهد تعني استهلاك قدرة أعلى، وهذا ما يتلف الأجهزة المصممة لحملها المقنن عند توصيلها بجهد خاطئ (مثلًا جهاز مصمم لـ110 فولت متصل بخط 220 فولت سيسخن ملفاته الداخلية ويتلف).', 2 FROM public.modules WHERE slug = 'finix-electrical-fundamentals-deep-dive';
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'Cable Sizing: Matching Wire Gauge to Load', 'تحديد مقاس الكابل: مطابقة قطر السلك مع الحمل', 'An undersized cable overheats under load and is a fire risk; an oversized cable wastes money. The following table is an approximate guide for copper wire cross-sectional area under normal conditions (short cable runs, normal ambient temperature) — actual values shift with installation method (open air vs. conduit vs. underground) and ambient temperature:

| Power (Watts) | Current (Amps) | Cable cross-section (mm²) |
|---|---|---|
| 1300 | 6 | 0.75 |
| 1800 | 8 | 1 |
| 2200–2800 | 10–13 | 1.5 |
| 3500–4400 | 16–20 | 2.5 |
| 5500–7000 | 25–32 | 4 |
| 7000–8800 | 32–40 | 6 |
| 11000–14000 | 50–63 | 10 |
| 15000–19000 | 70–85 | 16 |
| 22000–28000 | 100–125 | 25 |

**Worked example — sizing a circuit breaker and cable for a 2500 W heater:**

1. Find the required current: I = P ÷ V = 2500 ÷ 220 = 11.36 A
2. Apply a 1.25 safety margin for the breaker: 11.36 × 1.25 = 14.2 A → round up to the nearest standard breaker size available in the market: 16A
3. Size the cable based on the breaker rating × 1.2: 16 × 1.2 = 19.2 A → this matches a 2.5 mm² cable cross-section from the sizing table.

**The rule behind this:** the breaker''s rated current must be higher than the load''s actual current by a safety margin (at least 25%) so it doesn''t trip prematurely — but the cable''s current-carrying capacity must be higher than the breaker''s rated current (by roughly 20%), because the breaker''s job is to protect the cable, not the other way around. So: load current < breaker rating < cable capacity.', 'السلك الأقل من المطلوب يسخن تحت الحمل ويشكل خطر حريق؛ والسلك الأكبر من المطلوب يهدر المال. الجدول التالي دليل تقريبي لمساحة مقطع السلك النحاسي في الظروف العادية (مسافة قصيرة، درجة حرارة عادية) — القيم الفعلية تختلف حسب طريقة التمديد (في الهواء أو داخل مواسير أو تحت الأرض) ودرجة الحرارة المحيطة:

| القدرة بالوات | التيار بالأمبير | مساحة مقطع السلك بالملم |
|---|---|---|
| 1300 | 6 | 0.75 |
| 1800 | 8 | 1 |
| 2200-2800 | 10-13 | 1.5 |
| 3500-4400 | 16-20 | 2.5 |
| 5500-7000 | 25-32 | 4 |
| 7000-8800 | 32-40 | 6 |
| 11000-14000 | 50-63 | 10 |
| 15000-19000 | 70-85 | 16 |
| 22000-28000 | 100-125 | 25 |

**مثال محلول — اختيار قاطع وسلك لسخان قدرته 2500 وات:**

١. حساب التيار المطلوب: I = P ÷ V = 2500 ÷ 220 = 11.36 أمبير
٢. تطبيق هامش أمان 1.25 للقاطع: 11.36 × 1.25 = 14.2 أمبير ← نقرّب لأقرب قاطع متوفر بالسوق: 16 أمبير
٣. تحديد مساحة مقطع السلك بناءً على ضرب تيار القاطع × 1.2: 16 × 1.2 = 19.2 أمبير ← تقابل هذه القيمة مساحة مقطع 2.5 مم² من جدول اختيار السلك.

**القاعدة وراء ذلك:** يجب أن يكون تيار القاطع المقنن أعلى من تيار الحمل الفعلي بهامش أمان (25٪ على الأقل) حتى لا يفصل قبل أوانه — لكن سعة تحمل السلك يجب أن تكون أعلى من تيار القاطع (بنحو 20٪)، لأن القاطع وظيفته حماية السلك لا العكس. إذن: تيار الحمل < تيار القاطع < سعة تحمل السلك.', 3 FROM public.modules WHERE slug = 'finix-electrical-fundamentals-deep-dive';
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position) SELECT id, 'Three-Phase Power: Star vs Delta Connections', 'القدرة ثلاثية الطور: توصيلات النجمة والدلتا', 'Three-phase (3-Phase) power is a multi-phase AC electrical system, the most commonly used for industrial loads, hospitals, and towers. Each phase current begins offset from the others by 120 degrees, distributed across three lines (L1, L2, L3).

In single-phase (Single Phase) systems, the household voltage between the phase (L) and neutral (N) is typically 220V. In a three-phase system, the voltage between any phase and neutral is also 220V, but the voltage between any two phases (line voltage) is calculated:

**V(Line) = √3 × V(Phase) = 1.732 × 220 = 380 V**

(√3 = 1.732, derived from the geometry of the 120° phase angles between the three sine waves.)

Three-phase power formula: **P = √3 × V(Line) × I(Line) × cos(θ)**

**Worked example:** required for a 3-phase motor with 5.5 kW power, line-to-line voltage 380V, motor power factor 0.8:

I = P ÷ (√3 × V(Line) × cos θ) = 5500 ÷ (1.732 × 380 × 0.8) = 5500 ÷ 526.5 = 10.4 A

**Star vs Delta connections:** a three-phase motor has 6 terminals labeled U1, V1, W1 (start of the 3 windings) and U2, V2, W2 (end of the 3 windings). In a **Star (Y)** connection, the three winding ends are joined at a common point and fed from the three winding starts — this delivers a lower per-winding voltage, drawing less starting current, suitable for large loads where a lower-current start is needed. In a **Delta (Δ)** connection, the end of each winding connects to the start of the next, forming a closed triangle — this delivers the full line voltage across each winding, suitable for running at full power once the motor has started. This is why many industrial motors use a Star-Delta starter: start in Star (lower current, safer inrush), then switch to Delta once the motor reaches near-full speed (full torque and power).', 'القدرة ثلاثية الطور (3-Phase) هي نظام كهربائي متعدد الأطوار للتيار المتردد، الأكثر استخدامًا في الأحمال الصناعية والمستشفيات والأبراج. يبدأ كل طور من التيار بفارق زاوية 120 درجة عن الآخر، موزّعة على ثلاثة خطوط (L1, L2, L3).

في النظام أحادي الطور (Single Phase)، يكون الجهد المنزلي بين الطور (L) والمحايد (N) عادةً 220 فولت. في النظام ثلاثي الطور، الجهد بين أي طور والمحايد أيضًا 220 فولت، لكن الجهد بين أي طورين (جهد الخط) يُحسب:

**V(الخط) = √3 × V(الطور) = 1.732 × 220 = 380 فولت**

(الجذر التربيعي للعدد 3 = 1.732، وينشأ من الهندسة الرياضية لزوايا الأطوار البالغة 120 درجة بين الموجات الجيبية الثلاث.)

معادلة القدرة ثلاثية الطور: **P = √3 × V(الخط) × I(الخط) × cos(θ)**

**مثال محلول:** المطلوب لمحرك ثلاثي الطور قدرته 5.5 كيلووات، الجهد بين طورين 380 فولت، معامل قدرة المحرك 0.8:

I = P ÷ (√3 × V(الخط) × cos θ) = 5500 ÷ (1.732 × 380 × 0.8) = 5500 ÷ 526.5 = 10.4 أمبير

**توصيلات النجمة مقابل الدلتا:** المحرك ثلاثي الطور له 6 أطراف يُرمز لها U1, V1, W1 (بدايات الملفات الثلاثة) وU2, V2, W2 (نهايات الملفات الثلاثة). في توصيلة **النجمة (Star)**، تُربط نهايات الملفات الثلاثة معًا في نقطة مشتركة وتُغذى من بدايات الملفات الثلاثة — هذا يعطي جهدًا أقل لكل ملف، فيسحب تيار بدء تشغيل أقل، مناسب للأحمال الكبيرة التي تحتاج بدء تشغيل بتيار منخفض. في توصيلة **الدلتا (Delta)**، تُربط نهاية كل ملف ببداية الملف التالي مكوّنة مثلثًا مغلقًا — هذا يعطي جهد الخط الكامل على كل ملف، مناسب للعمل بالقدرة الكاملة بعد بدء تشغيل المحرك. لهذا تستخدم كثير من المحركات الصناعية دائرة بادئ نجمة-دلتا: يبدأ التشغيل بتوصيلة النجمة (تيار أقل، بدء أكثر أمانًا)، ثم يتحول لتوصيلة الدلتا بعد وصول المحرك لسرعته شبه الكاملة (عزم وقدرة كاملان).', 4 FROM public.modules WHERE slug = 'finix-electrical-fundamentals-deep-dive';
