-- Step 3: Expand I06 (Voltage & Phase Protection) from one lesson to three.
--
-- I06 had a single lesson where its sibling modules carry three to six. The
-- existing lesson covers what supply faults destroy; these two add the devices
-- that detect them and the smart-monitoring layer that reports them.

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$Phase-Sequence, Phase-Failure and Voltage Monitoring Relays$t$,
$t$ريليهات تتابع الأطوار وفقد الطور ومراقبة الجهد$t$,
$c$The previous lesson established what supply faults do to a motor. This one covers the devices that catch them, because none of these faults is reliably caught by an overload relay.

**Why the overload relay is the wrong tool for this job.** A thermal overload measures current and integrates it over time. That is exactly right for a mechanically overloaded motor. It is close to useless for supply faults, because the fault may not raise current at all in the phase the relay is watching, and because by the time a phase-loss condition has raised current enough to trip a thermal element, the winding has already been overheating for a long time. Supply protection is a separate device with a separate job.

**The three-phase monitoring relay.** One compact DIN-rail device covers several distinct functions. Understanding which function is doing what is the difference between setting it correctly and leaving it at factory defaults:

- **Phase failure** — one of the three supply conductors is missing. The relay detects the collapse of that phase's voltage and drops its output contact.
- **Phase sequence (phase rotation)** — the three phases are present but in the wrong order, L1-L3-L2 instead of L1-L2-L3. Nothing is wrong electrically; the motor simply runs backwards. On a pump this means it runs without delivering; on a compressor or a conveyor it can destroy the machine. A sequence relay refuses to allow the start.
- **Phase asymmetry (imbalance)** — all three phases are present but unequal. Small imbalances produce disproportionate heating, because negative-sequence current heats the rotor heavily. A common setting is to trip somewhere in the region of a few percent voltage imbalance, but the correct figure comes from the motor manufacturer, not from habit.
- **Under-voltage and over-voltage** — adjustable thresholds with a deliberate delay so a momentary dip does not stop production unnecessarily.

**Setting the delays, and why it matters commercially.** Every one of these functions has a time setting, and the setting is a judgement about the cost of a nuisance trip versus the cost of damage. A dip of 8% for 200 ms happens constantly on a weak Egyptian feeder when a neighbouring load starts. If the relay trips on it, production stops several times a day and the client will eventually ask you to bypass the protection — which is the worst possible outcome. Set the delay long enough to ride through normal supply behaviour and short enough to act before the motor overheats. If you cannot achieve both, the answer is not a shorter delay; it is that the supply needs fixing or the motor needs thermistor protection as well.

**How the relay is wired into the circuit.** The relay senses the incoming three phases directly. Its output is a changeover contact wired into the control circuit, in series with the contactor coil, exactly like the overload contact. This placement is deliberate: the relay never switches motor current, only the coil. That is why one small relay can protect a very large motor.

An important consequence: the monitoring relay must be wired so that a fault *opens* the coil circuit. The output contact is used in its normally-open, held-closed-while-healthy sense, so that a failure of the relay itself, or loss of its own supply, stops the motor rather than silently removing protection. Protection that fails open is protection; protection that fails closed is decoration.

**The reset question.** Automatic reset restarts the motor when the supply recovers — good for an unattended pump that should resume, dangerous for a machine someone may be working on. Manual reset forces a human to look at the machine before it restarts. As a rule, anything with a mechanical hazard gets manual reset; anything where an unattended restart is safe and desirable gets automatic reset with a restart delay.

**Commissioning check.** Do not assume a monitoring relay works because its LED is green. Prove each function: open one phase at the isolator and confirm the contactor drops out; swap two phases and confirm the sequence function blocks the start; if the relay has an imbalance function, confirm the setting against the motor data sheet rather than leaving the default. A relay nobody has tested is an assumption, not a protection.$c$,
$c$أسّس الدرس السابق ما تفعله أخطاء التغذية بالمحرك. ويتناول هذا الدرس الأجهزة التي تكتشفها، لأن أيًا من هذه الأخطاء لا يلتقطه ريليه الحمل الزائد بشكل موثوق.

**لماذا ريليه الحمل الزائد أداة خاطئة لهذه المهمة.** الحمل الزائد الحراري يقيس التيار ويكامله عبر الزمن. وهذا صحيح تمامًا لمحرك محمّل ميكانيكيًا زيادة. لكنه شبه عديم الفائدة لأخطاء التغذية، لأن العطل قد لا يرفع التيار إطلاقًا في الطور الذي يراقبه الريليه، ولأنه حين يرفع فقدُ الطور التيارَ بما يكفي لفصل عنصر حراري تكون اللفة قد سخنت منذ وقت طويل. حماية التغذية جهاز منفصل بمهمة منفصلة.

**ريليه مراقبة الأطوار الثلاثة.** جهاز واحد مدمج على قضيب DIN يغطي عدة وظائف متمايزة. وإدراك أي وظيفة تفعل ماذا هو الفرق بين ضبطه صحيحًا وتركه على إعدادات المصنع:

- **فقد الطور** — أحد موصلات التغذية الثلاثة مفقود. يكتشف الريليه انهيار جهد ذلك الطور ويحرر تلامس خرجه.
- **تتابع الأطوار** — الأطوار الثلاثة موجودة لكن بترتيب خاطئ، L1-L3-L2 بدل L1-L2-L3. لا خطأ كهربائيًا؛ المحرك ببساطة يدور عكسيًا. وهذا في مضخة يعني أنها تدور دون أن تضخ؛ وفي ضاغط أو سير ناقل قد يدمّر الآلة. وريليه التتابع يرفض السماح بالبدء.
- **عدم اتزان الأطوار** — الأطوار الثلاثة موجودة لكن غير متساوية. الاختلالات الصغيرة تنتج تسخينًا غير متناسب، لأن تيار التتابع السالب يسخّن العضو الدوار بشدة. والضبط الشائع هو الفصل عند نسبة قليلة من عدم اتزان الجهد، لكن الرقم الصحيح يأتي من مصنّع المحرك لا من العادة.
- **انخفاض الجهد وارتفاعه** — عتبات قابلة للضبط مع تأخير مقصود كي لا يوقف هبوط لحظي الإنتاج بلا داعٍ.

**ضبط التأخيرات ولماذا يهم تجاريًا.** لكل وظيفة من هذه ضبط زمني، والضبط حكم على تكلفة الفصل المزعج مقابل تكلفة التلف. هبوط بنسبة ٨٪ لمدة ٢٠٠ مللي ثانية يحدث باستمرار على تغذية مصرية ضعيفة حين يبدأ حمل مجاور. فإن فصل الريليه عليه، توقف الإنتاج عدة مرات يوميًا وسيطلب منك العميل في النهاية تجاوز الحماية — وهي أسوأ نتيجة ممكنة. اضبط التأخير طويلًا بما يكفي لتجاوز سلوك التغذية الطبيعي وقصيرًا بما يكفي للتصرف قبل أن يسخن المحرك. وإن تعذّر تحقيق الأمرين فالجواب ليس تأخيرًا أقصر؛ بل أن التغذية تحتاج إصلاحًا أو أن المحرك يحتاج حماية ثرمستور أيضًا.

**كيف يُمدَّد الريليه في الدائرة.** يستشعر الريليه الأطوار الثلاثة الداخلة مباشرة. وخرجه تلامس تحويل ممدود في دائرة التحكم، على التوالي مع ملف الكونتاكتور، تمامًا كتلامس الحمل الزائد. وهذا الموضع مقصود: الريليه لا يبدّل تيار المحرك أبدًا، بل الملف فقط. ولهذا يستطيع ريليه صغير واحد حماية محرك كبير جدًا.

ونتيجة مهمة: يجب تمديد ريليه المراقبة بحيث *يفتح* العطلُ دائرةَ الملف. ويُستخدم تلامس الخرج بمعناه المفتوح طبيعيًا والمُغلق أثناء السلامة، حتى يوقف فشلُ الريليه نفسه أو فقدُ تغذيته المحركَ بدل أن يزيل الحماية صامتًا. الحماية التي تفشل مفتوحة حماية؛ والتي تفشل مغلقة زينة.

**مسألة إعادة التعيين.** إعادة التعيين التلقائية تعيد تشغيل المحرك حين تتعافى التغذية — جيدة لمضخة غير مراقَبة يجب أن تستأنف، وخطرة لآلة قد يعمل عليها أحد. وإعادة التعيين اليدوية تجبر إنسانًا على النظر للآلة قبل إعادة تشغيلها. وكقاعدة: كل ما فيه خطر ميكانيكي يأخذ إعادة تعيين يدوية؛ وكل ما يكون فيه الاستئناف غير المراقَب آمنًا ومرغوبًا يأخذ إعادة تعيين تلقائية مع تأخير إعادة تشغيل.

**فحص التشغيل التجريبي.** لا تفترض أن ريليه المراقبة يعمل لأن مؤشره أخضر. أثبت كل وظيفة: افتح طورًا واحدًا عند العازل وتأكد أن الكونتاكتور يتحرر؛ بدّل طورين وتأكد أن وظيفة التتابع تمنع البدء؛ وإن كان للريليه وظيفة عدم اتزان فتأكد من الضبط مقابل بيانات المحرك بدل ترك الافتراضي. الريليه الذي لم يختبره أحد افتراض لا حماية.$c$,
2
FROM public.modules WHERE slug = 'finix-voltage-phase-protection';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$Smart Supply Monitoring: What Moves to the App and What Must Not$t$,
$t$المراقبة الذكية للتغذية: ما ينتقل للتطبيق وما يجب ألا ينتقل$t$,
$c$Supply protection is the clearest case in this whole track of a function that must stay in hardware while its *reporting* moves to software. Getting that split right is both the engineering answer and the commercial one.

**The rule, stated once more.** If the failure destroys equipment or endangers people, the protection is hardware. A phase-failure relay must drop the contactor with no network, no cloud, no app and no power to anything but itself. That is not negotiable, and a client who asks you to move it into the app is asking for something you should decline and explain.

**What smart monitoring genuinely adds — and it is a great deal.**

- **You learn about the trip immediately.** A classical monitoring relay stops the motor and sits there with an LED on. Nobody knows until someone walks past or the process fails downstream. A monitored panel sends a notification the moment the contact changes state. On a pump feeding a building, the difference is between a caretaker knowing at 2 a.m. and the residents discovering it at 7 a.m.
- **You can see the supply, not just the trips.** This is the part clients underestimate. Logging voltage on each phase continuously turns an invisible utility problem into evidence. A site that dips to 340 V every afternoon has a documented pattern you can take to the client or the utility, instead of an argument about whether the supply is "bad".
- **Trends predict failures.** Phase imbalance that grows slowly over months usually means a developing connection problem — a loosening terminal, a corroding lug. No relay reports a trend; it either trips or it does not. A logged system shows the drift long before the trip, and that is a maintenance visit you can sell rather than a breakdown you get blamed for.
- **Correlation solves arguments.** When a motor fails, the first question is always whether it was the motor or the supply. A panel that logged voltage, imbalance and current at the moment of failure answers that question with data.

**How to implement it without touching the protection.** The retrofit pattern from the sensing-relay module applies unchanged:

1. **Leave the monitoring relay exactly as it is.** It stays wired in series with the contactor coil, doing its job with no dependency on anything you add.
2. **Take a signal from its existing fault contact** into a monitored input. Most monitoring relays have a spare changeover contact; if not, an add-on auxiliary is cheap. This costs nothing in risk because you are reading a contact, not interrupting one.
3. **Add voltage and current sensing** on the incoming supply for trend data. Non-invasive CTs and a voltage tap give you the continuous picture the relay never provides.
4. **Send alerts and history to whoever is responsible** — caretaker, facility manager, your own service desk.

Note what this does commercially. You are not redesigning a working safety system, so the risk of the job is low and the conversation with a cautious client is easy. The panel still fails safe if every smart component dies. And you have converted a one-off installation into a monitored asset, which is a service relationship rather than a single invoice.

**The Alpha Control fit.** This is a natural application for the platform covered in the Technician track: the monitoring relay's fault contact goes to one of the AC inputs, current sensing goes through the high-current module, and the whole panel reports over MQTT or Modbus to a dashboard — while every protective function stays exactly where it was, in hardware, in the panel, working without a network.

**The sentence to use with a client.** "The protection stays in the panel and works whether or not anything else does. What we are adding is the ability to know — immediately when something trips, and gradually when something is starting to go wrong." That framing sells the work honestly, and it is also simply true.$c$,
$c$حماية التغذية أوضح حالة في هذا المسار كله لوظيفة يجب أن تبقى عتادية بينما ينتقل *إبلاغها* إلى البرمجيات. وضبط هذا الفصل صحيحًا هو الجواب الهندسي والتجاري معًا.

**القاعدة، مرة أخرى.** إن كان الفشل يدمّر معدات أو يعرّض أشخاصًا للخطر فالحماية عتادية. يجب أن يحرر ريليه فقد الطور الكونتاكتور بلا شبكة ولا سحابة ولا تطبيق ولا تغذية لأي شيء سوى نفسه. وهذا غير قابل للتفاوض، والعميل الذي يطلب نقله إلى التطبيق يطلب شيئًا ينبغي أن ترفضه وتشرح سببه.

**ما تضيفه المراقبة الذكية فعلًا — وهو كثير.**

- **تعرف بالفصل فورًا.** ريليه المراقبة الكلاسيكي يوقف المحرك ويبقى بمؤشر مضاء. ولا يعلم أحد حتى يمر شخص أو تفشل العملية لاحقًا. أما اللوحة المراقَبة فترسل إشعارًا لحظة تغيّر التلامس. وفي مضخة تغذي مبنى يكون الفرق بين أن يعلم الحارس الثانية صباحًا وأن يكتشف السكان السابعة صباحًا.
- **ترى التغذية لا الفصلات فقط.** وهذا ما يقلل العملاء من شأنه. فتسجيل الجهد على كل طور باستمرار يحوّل مشكلة مرفق غير مرئية إلى دليل. والموقع الذي يهبط إلى ٣٤٠ فولت كل بعد ظهر لديه نمط موثق تأخذه للعميل أو لشركة الكهرباء، بدل جدال حول ما إذا كانت التغذية "سيئة".
- **الاتجاهات تتنبأ بالأعطال.** عدم اتزان الأطوار الذي ينمو ببطء عبر شهور يعني عادة مشكلة توصيل ناشئة — طرف يرتخي أو كوس يتآكل. ولا ريليه يبلّغ عن اتجاه؛ فهو إما يفصل أو لا. والنظام المسجِّل يُظهر الانحراف قبل الفصل بوقت طويل، وتلك زيارة صيانة تبيعها بدل عطل تُلام عليه.
- **الربط يحسم الجدل.** حين يتلف محرك يكون السؤال الأول دائمًا هل كان المحرك أم التغذية. واللوحة التي سجّلت الجهد وعدم الاتزان والتيار لحظة العطل تجيب بالبيانات.

**كيف تنفّذه دون مساس بالحماية.** ينطبق نمط التحديث من برنامج ريليهات الاستشعار دون تغيير:

1. **اترك ريليه المراقبة كما هو تمامًا.** يبقى ممدودًا على التوالي مع ملف الكونتاكتور، يؤدي عمله دون اعتماد على أي شيء تضيفه.
2. **خذ إشارة من تلامس عطله القائم** إلى دخل مراقَب. لأغلب ريليهات المراقبة تلامس تحويل احتياطي؛ وإن لم يوجد فالملحق المساعد رخيص. ولا يكلف هذا شيئًا من المخاطرة لأنك تقرأ تلامسًا لا تقطعه.
3. **أضف استشعار جهد وتيار** على التغذية الداخلة لبيانات الاتجاه. محولات تيار غير اقتحامية ونقطة قياس جهد تعطيك الصورة المستمرة التي لا يوفرها الريليه أبدًا.
4. **أرسل التنبيهات والسجل لمن يتحمل المسؤولية** — حارس أو مدير مرافق أو مكتب خدمتك.

ولاحظ ما يفعله هذا تجاريًا. أنت لا تعيد تصميم نظام سلامة يعمل، فمخاطرة العمل منخفضة والحديث مع عميل حذر سهل. واللوحة تظل تفشل بأمان إن ماتت كل مكوناتك الذكية. وقد حوّلت تركيبًا لمرة واحدة إلى أصل مراقَب، وهي علاقة خدمة لا فاتورة واحدة.

**ملاءمة Alpha Control.** هذا تطبيق طبيعي للمنصة المشروحة في مسار الفني: تلامس عطل ريليه المراقبة يذهب لأحد مداخل التيار المتردد، واستشعار التيار يمر عبر وحدة التيار العالي، وتبلّغ اللوحة كلها عبر MQTT أو Modbus إلى لوحة معلومات — بينما تبقى كل وظيفة حمائية حيث كانت تمامًا، عتادية، في اللوحة، تعمل بلا شبكة.

**الجملة التي تستخدمها مع العميل.** "الحماية تبقى في اللوحة وتعمل سواء عمل غيرها أو لا. وما نضيفه هو القدرة على المعرفة — فورًا حين يفصل شيء، وتدريجيًا حين يبدأ شيء بالتدهور." هذه الصياغة تبيع العمل بصدق، وهي أيضًا صحيحة ببساطة.$c$,
3
FROM public.modules WHERE slug = 'finix-voltage-phase-protection';

-- Widen the module summary now that it covers devices and smart monitoring.
UPDATE public.modules
SET summary = 'Under-voltage, over-voltage and phase-loss faults and what each does to a motor; the monitoring relays that detect them and how to set and prove them; and the smart-monitoring layer that reports supply problems without ever taking over the protection.',
    summary_ar = 'أعطال انخفاض الجهد وارتفاعه وفقد الطور وما يفعله كل منها بالمحرك؛ وريليهات المراقبة التي تكتشفها وكيفية ضبطها وإثباتها؛ وطبقة المراقبة الذكية التي تبلّغ عن مشكلات التغذية دون أن تتولى الحماية أبدًا.'
WHERE slug = 'finix-voltage-phase-protection';
