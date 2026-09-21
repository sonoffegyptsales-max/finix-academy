-- Step 4d-4: M14 L4 — Smart thermostat with multi-function control panel.

UPDATE public.lessons SET content = $c$A thermostat is the highest-risk device in the residential smart-home catalogue. It controls expensive plant, it can cause real damage if mis-wired, and it is the device clients notice immediately when it misbehaves.

**Understand the system before touching the wiring.**

HVAC control wiring is not standardised across systems, and connecting the wrong pair can destroy a compressor. Identify the system type first:

- **Conventional split system** — separate heating and cooling, controlled by discrete wires.
- **Heat pump** — uses a reversing valve, and the control logic differs fundamentally from conventional systems. Wiring a heat pump as if it were conventional produces heating when cooling is demanded.
- **Fan coil unit** — common in apartments and hotels, typically valve plus multi-speed fan.
- **Underfloor heating** — high thermal mass, slow response, entirely different control strategy.
- **Line-voltage system** — where the thermostat switches mains directly rather than a low-voltage control signal. Never connect a low-voltage thermostat to a line-voltage system.

**Standard conventional terminal designations.**

| Terminal | Function |
|---|---|
| R / Rh / Rc | 24 V power (Rh heating, Rc cooling; often linked) |
| W | Heat call |
| Y | Cool call / compressor |
| G | Fan |
| C | Common — the return that powers the thermostat |
| O / B | Reversing valve (heat pump only) |

**The C-wire problem.** A smart thermostat needs continuous power for its display and radio, which means a common wire. Many older installations ran only R, W, Y and G, because a mechanical thermostat needed no power of its own.

Without a C wire the options are: run a new cable, fit a common-wire adapter at the air handler, or select a thermostat with an alternative power arrangement. Some devices "power steal" through the heating circuit, which can cause relay chatter or a faintly energised system. Prefer a real C wire where it is achievable.

**Document before disconnecting.**

Photograph the existing terminal block before removing a single wire, and label every conductor with its terminal. Do not rely on wire colour — HVAC colour conventions are frequently ignored in practice, and a cable whose colours were reused during a previous repair will mislead you completely.

This photograph is also your route back if the new thermostat proves incompatible.

**Compressor protection is not optional.**

An air-conditioning compressor restarted against residual head pressure can be damaged or destroyed. Every thermostat has a minimum off-time setting, typically three to five minutes, and it must be enabled.

The failure mode that catches installers: an automation that rapidly toggles the thermostat, or a poorly set differential causing short cycling. Both destroy compressors, and both are the installer's fault rather than the equipment's.

**Differential and cycle settings.**

The differential is how far temperature must drift from setpoint before the system responds. Too narrow and the system short-cycles, wearing components and wasting energy; too wide and comfort suffers.

Match it to thermal mass: a fast-responding fan coil tolerates a narrow differential, while underfloor heating needs a wide one because the floor keeps emitting heat long after the call ends.

**Sensor placement governs everything.**

The thermostat measures where it is mounted. Mount it on an internal wall at roughly 1.5 m, away from direct sun, away from supply air, away from lamps and screens, and not on a wall backing onto a bathroom or kitchen.

A thermostat in direct afternoon sun will cool an already-comfortable house all afternoon, and the client will report that the air conditioning "runs constantly for no reason".

**Testing the full sequence.**

Before leaving, call heat and confirm the correct output energises; call cool and confirm the compressor and fan respond; test fan-only; verify the minimum off-time delay actually holds by demanding a rapid cycle; and confirm the system stops cleanly when satisfied.

On a heat pump, explicitly confirm the reversing valve behaves correctly in both modes. This is the error that hides until the season changes, six months after handover.$c$,
content_ar = $c$الثرموستات أعلى الأجهزة مخاطرة في كتالوج المنزل الذكي السكني. يتحكم بمعدات باهظة، ويسبب ضررًا حقيقيًا إن أُخطئ توصيله، وهو الجهاز الذي يلاحظه العملاء فورًا حين يسيء التصرف.

**افهم النظام قبل لمس التمديد.**

تمديد تحكم التكييف غير موحد عبر الأنظمة، وتوصيل الزوج الخطأ قد يدمر ضاغطًا. عرّف نوع النظام أولًا:

- **نظام منفصل تقليدي** — تدفئة وتبريد منفصلان يُتحكم بهما بأسلاك متمايزة.
- **مضخة حرارية** — تستخدم صمام عكس، ومنطق التحكم يختلف جوهريًا عن التقليدي. وتوصيلها كأنها تقليدية ينتج تدفئة حين يُطلب تبريد.
- **وحدة ملف مروحة** — شائعة في الشقق والفنادق، عادة صمام ومروحة متعددة السرعات.
- **تدفئة أرضية** — كتلة حرارية عالية واستجابة بطيئة واستراتيجية تحكم مختلفة تمامًا.
- **نظام بجهد الخط** — حيث يبدّل الثرموستات الشبكة مباشرة لا إشارة تحكم منخفضة الجهد. لا توصل ثرموستات منخفض الجهد بنظام بجهد الخط أبدًا.

**تسميات الأطراف التقليدية القياسية.**

| الطرف | الوظيفة |
|---|---|
| R / Rh / Rc | تغذية ٢٤ فولت (Rh تدفئة، Rc تبريد؛ مربوطان غالبًا) |
| W | طلب تدفئة |
| Y | طلب تبريد/ضاغط |
| G | مروحة |
| C | مشترك — العودة التي تغذي الثرموستات |
| O / B | صمام العكس (مضخة حرارية فقط) |

**مشكلة سلك C.** الثرموستات الذكي يحتاج تغذية مستمرة لشاشته وراديوه، ما يعني سلكًا مشتركًا. وكثير من التركيبات القديمة مدّت R وW وY وG فقط، لأن الثرموستات الميكانيكي لم يحتج تغذية لنفسه.

وبلا سلك C تكون الخيارات: مد كابل جديد أو تركيب محوّل سلك مشترك عند وحدة المناولة أو اختيار ثرموستات بترتيب تغذية بديل. وبعض الأجهزة "تسرق الطاقة" عبر دائرة التدفئة، ما قد يسبب رفرفة ريلاي أو نظامًا مغذى خفيفًا. فضّل سلك C حقيقيًا حيثما أمكن.

**وثّق قبل الفصل.**

صوّر لوحة الأطراف الحالية قبل نزع سلك واحد، وعلّم كل موصّل بطرفه. ولا تعتمد على لون السلك — فأعراف ألوان التكييف تُتجاهل كثيرًا عمليًا، والكابل الذي أُعيد استخدام ألوانه في إصلاح سابق سيضللك تمامًا.

وهذه الصورة أيضًا طريق عودتك إن ثبت أن الثرموستات الجديد غير متوافق.

**حماية الضاغط ليست اختيارية.**

ضاغط التكييف المعاد تشغيله مقابل ضغط رأس متبقٍ قد يتضرر أو يُدمَّر. ولكل ثرموستات إعداد زمن إطفاء أدنى، عادة ثلاث إلى خمس دقائق، ويجب تفعيله.

ونمط الفشل الذي يوقع الفنيين: أتمتة تبدّل الثرموستات بسرعة، أو تفاضل سيئ الضبط يسبب دورات قصيرة. وكلاهما يدمر الضواغط، وكلاهما خطأ الفني لا المعدة.

**إعدادات التفاضل والدورة.**

التفاضل هو كم يجب أن تنحرف الحرارة عن نقطة الضبط قبل استجابة النظام. فالضيق جدًا يسبب دورات قصيرة تُبلي المكونات وتهدر الطاقة؛ والواسع جدًا يضر الراحة.

طابقه مع الكتلة الحرارية: فملف المروحة سريع الاستجابة يحتمل تفاضلًا ضيقًا، بينما التدفئة الأرضية تحتاج واسعًا لأن الأرضية تظل تبث حرارة بعد انتهاء الطلب بوقت طويل.

**موضع الحساس يحكم كل شيء.**

الثرموستات يقيس حيث يُركّب. ركّبه على جدار داخلي عند نحو ١٫٥ متر، بعيدًا عن الشمس المباشرة وهواء التغذية والمصابيح والشاشات، وليس على جدار يظهر على حمام أو مطبخ.

فالثرموستات في شمس العصر المباشرة سيبرّد بيتًا مريحًا أصلًا طوال العصر، وسيبلّغ العميل أن التكييف "يعمل باستمرار بلا سبب".

**اختبار التسلسل الكامل.**

قبل المغادرة، اطلب تدفئة وتأكد أن الخرج الصحيح يُغذّى؛ واطلب تبريدًا وتأكد أن الضاغط والمروحة يستجيبان؛ واختبر المروحة وحدها؛ وتحقق أن تأخير الإطفاء الأدنى يصمد فعلًا بطلب دورة سريعة؛ وتأكد أن النظام يتوقف نظيفًا عند الاكتفاء.

وفي المضخة الحرارية، تأكد صراحة أن صمام العكس يتصرف صحيحًا في الوضعين. وهذا الخطأ الذي يختبئ حتى يتغير الفصل بعد ستة أشهر من التسليم.$c$
WHERE title = 'Building a Smart Thermostat with a Multi-Function Control Panel';
