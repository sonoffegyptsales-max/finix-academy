-- Track: Finix Industrial Control (classical control + smart equivalents)
-- Module I04: Timers & Timing Functions
--
-- ORIGINAL CONTENT. Topic sequence informed by standard industrial-control
-- curricula; all explanations, worked examples and figures written for Finix.
-- No third-party text is reproduced.

-- 1. Track (idempotent)
INSERT INTO public.tracks (id, name, name_ar, tagline, tagline_ar, position)
VALUES (
  'finix-industrial-control',
  'Finix Industrial Control',
  'التحكم الصناعي من فينيكس',
  'Classical motor-control and automatic relays, paired lesson-by-lesson with their modern smart-control equivalents.',
  'دوائر التحكم الكلاسيكية والريليهات الأوتوماتيكية، مقترنة درسًا بدرس مع مكافئاتها في التحكم الذكي الحديث.',
  7
)
ON CONFLICT (id) DO NOTHING;

-- 2. Module I04
INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES (
  'finix-timers-timing-functions',
  'I04',
  'finix-industrial-control',
  'Timers & Timing Functions',
  'المؤقتات ووظائف التوقيت',
  $s$Time as a control variable: the standard timing functions (ON-delay, OFF-delay, interval, repeat cycle), how to read a timing diagram, how to set a real timer's range and multiplier, the star-delta timing sequence, and where an app schedule can replace a timer relay — and where it must never.$s$,
  $s$الزمن كمتغير تحكم: وظائف التوقيت القياسية (تأخير التشغيل، تأخير الفصل، الفترة، الدورة المتكررة)، كيف تقرأ مخطط التوقيت، كيف تضبط مدى ومضاعف مؤقت حقيقي، تتابع توقيت نجمة/دلتا، وأين يمكن لجدولة التطبيق أن تحل محل مؤقت الريليه — وأين يجب ألا تفعل أبدًا.$s$,
  NULL,
  26
)
ON CONFLICT (slug) DO NOTHING;

-- 3. Lessons
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$Time as a Control Variable$t$,
$t$الزمن كمتغير تحكم$t$,
$c$A contactor answers one question: is this load on or off? A timer answers a harder one: *for how long*, and *starting when*? The moment you add time to a control circuit, you can sequence events, protect equipment from its own inrush, and automate a process that would otherwise need a person standing at the panel with a stopwatch.

**Why a separate timing device exists at all.** A contactor coil responds in milliseconds — that is its job. But many industrial processes need deliberate, repeatable delays measured in seconds or minutes: let the motor reach speed in star before switching to delta; keep the extractor fan running for three minutes after the oven stops; pulse a lubrication valve for two seconds every twenty minutes. None of that is possible with contactors alone, because a contactor has no memory of time.

**The three things every timer has.** Regardless of manufacturer or technology, a timer relay is defined by three characteristics, and you must be able to state all three before you can wire or specify one:

1. **The timing function** — what the delay actually does. Does the output wait before switching on, or wait before switching off, or pulse once, or cycle continuously? This is the single most common source of field mistakes: a technician fits an ON-delay timer where the circuit needed an OFF-delay, and the machine behaves nothing like the drawing.
2. **The time range** — the span the device can be set across, for example 0.1–10 seconds, or 1–100 minutes. A timer set to its minimum on a wide range is far less accurate than the same delay on a narrow range, which is why timers offer switchable ranges rather than one enormous scale.
3. **The contact arrangement** — how many changeover contacts the timer offers, and whether the timed contacts are separate from any instantaneous contacts. A timer with one changeover contact cannot do the job of one with two, no matter how the timing is set.

**The supply question that catches people out.** A timer needs power to count. That sounds obvious until you meet an OFF-delay function: the output has to change state *after* the control signal has gone away, which means something must still be powering the timing element during the delay. Manufacturers solve this two ways — either the timer stores enough energy internally to complete its count, or it uses a separate permanent auxiliary supply with the control signal applied to a distinct trigger terminal. When you specify an OFF-delay timer, you must know which type you are buying, because the two wire up completely differently and are not interchangeable.

**How a timer is drawn.** In control schematics the timer coil is drawn like a relay coil, usually with a symbol indicating the direction of the delay, and its contacts carry a marking that distinguishes timed contacts from instantaneous ones. The convention that matters most in practice: a timed contact is drawn so the delay direction is visible at a glance, so that anyone reading the drawing knows whether the delay happens on energise or on de-energise without hunting through a parts list.

**Where this module is going.** The next lessons work through the standard timing functions one at a time, then show how to read the timing diagrams that describe them, how to set a real device, and finally where modern smart scheduling genuinely replaces a timer relay — and the specific cases where substituting an app schedule for a hardware timer would be an engineering mistake.$c$,
$c$الكونتاكتور يجيب عن سؤال واحد: هل هذا الحمل يعمل أم لا؟ أما المؤقت فيجيب عن سؤال أصعب: *لكم من الوقت*، و*بدءًا من متى*؟ في اللحظة التي تضيف فيها الزمن إلى دائرة تحكم، يصبح بإمكانك ترتيب الأحداث بالتتابع، وحماية المعدات من تيار اندفاعها، وأتمتة عملية كانت ستحتاج شخصًا يقف عند اللوحة ومعه ساعة إيقاف.

**لماذا يوجد جهاز توقيت منفصل أصلًا.** ملف الكونتاكتور يستجيب خلال أجزاء من الألف من الثانية — وهذه وظيفته. لكن كثيرًا من العمليات الصناعية تحتاج تأخيرات مقصودة وقابلة للتكرار تُقاس بالثواني أو الدقائق: دع المحرك يصل لسرعته على وضع النجمة قبل التحويل إلى دلتا؛ أبقِ مروحة الشفط تعمل ثلاث دقائق بعد توقف الفرن؛ أعطِ صمام التشحيم نبضة لثانيتين كل عشرين دقيقة. لا شيء من ذلك ممكن بالكونتاكتورات وحدها، لأن الكونتاكتور لا ذاكرة له للزمن.

**الأشياء الثلاثة التي يمتلكها كل مؤقت.** بغض النظر عن الشركة المصنّعة أو التقنية، يُعرَّف مؤقت الريليه بثلاث خصائص، ويجب أن تكون قادرًا على ذكرها جميعًا قبل أن توصّل أو تحدد مواصفات أي منها:

1. **وظيفة التوقيت** — ماذا يفعل التأخير فعليًا. هل ينتظر الخرج قبل أن يعمل، أم ينتظر قبل أن يفصل، أم يعطي نبضة واحدة، أم يعمل بدورات متتالية؟ هذا أكثر مصادر الأخطاء الميدانية شيوعًا: يركّب فني مؤقت تأخير تشغيل حيث تحتاج الدائرة تأخير فصل، فتتصرف الماكينة بشكل لا يشبه الرسم إطلاقًا.
2. **مدى الزمن** — المجال الذي يمكن ضبط الجهاز عليه، مثلًا 0.1–10 ثوانٍ، أو 1–100 دقيقة. المؤقت المضبوط على أدنى قيمة في مدى واسع أقل دقة بكثير من نفس التأخير على مدى ضيق، ولهذا توفر المؤقتات مديات قابلة للتبديل بدلًا من تدريج واحد هائل.
3. **ترتيب التلامسات** — كم تلامس تحويل يوفره المؤقت، وهل التلامسات المؤقتة منفصلة عن أي تلامسات لحظية. مؤقت بتلامس تحويل واحد لا يستطيع أداء عمل مؤقت بتلامسين، مهما ضُبط التوقيت.

**مسألة التغذية التي توقع الكثيرين.** المؤقت يحتاج طاقة ليعد. يبدو هذا بديهيًا حتى تقابل وظيفة تأخير الفصل: يجب أن يغيّر الخرج حالته *بعد* زوال إشارة التحكم، ما يعني أن شيئًا ما يجب أن يظل يغذّي عنصر التوقيت أثناء التأخير. تحل الشركات المصنّعة ذلك بطريقتين — إما أن يخزّن المؤقت طاقة داخلية كافية لإتمام عده، أو أن يستخدم تغذية مساعدة دائمة منفصلة مع تطبيق إشارة التحكم على طرف تشغيل مستقل. عندما تحدد مواصفات مؤقت تأخير فصل، يجب أن تعرف أي نوع تشتري، لأن الاثنين يُوصَّلان بشكل مختلف تمامًا وغير قابلين للتبادل.

**كيف يُرسم المؤقت.** في المخططات يُرسم ملف المؤقت كملف ريليه، وعادة برمز يوضح اتجاه التأخير، وتحمل تلامساته علامة تميز التلامسات المؤقتة عن اللحظية. العرف الأهم عمليًا: يُرسم التلامس المؤقت بحيث يكون اتجاه التأخير مرئيًا بنظرة واحدة، فيعرف قارئ الرسم هل التأخير عند التغذية أم عند الفصل دون البحث في قائمة القطع.

**إلى أين يتجه هذا البرنامج.** تتناول الدروس التالية وظائف التوقيت القياسية واحدة تلو الأخرى، ثم كيف تقرأ مخططات التوقيت التي تصفها، وكيف تضبط جهازًا حقيقيًا، وأخيرًا أين تحل الجدولة الذكية الحديثة محل مؤقت الريليه فعلًا — والحالات المحددة التي يكون فيها استبدال جدول تطبيق بمؤقت عتادي خطأً هندسيًا.$c$,
1
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$ON-Delay and OFF-Delay: The Two Foundations$t$,
$t$تأخير التشغيل وتأخير الفصل: الأساسان$t$,
$c$Almost every timing requirement in industry is built from two primitives. Master these two and the rest are variations.

**ON-delay (delay on energise).** Apply the control supply; the timer begins counting; nothing at the output changes yet. When the set time elapses, the timed contacts change state and stay changed for as long as the supply remains. Remove the supply and the contacts return instantly to rest, and the count resets to zero.

The behaviour to internalise: **the delay happens at the beginning, the reset is instant.** If the control signal disappears before the set time is reached, the timer simply resets — it does not remember partial progress and it does not operate. That property is genuinely useful: it means a brief glitch on the control signal cannot trigger the delayed output.

*Typical uses:* holding a motor in star before transferring to delta; staggering the start of several large loads so they do not all draw inrush current simultaneously; requiring a start button to be held for two seconds before a machine runs, so an accidental brush against the button does nothing.

**OFF-delay (delay on de-energise).** Apply the control supply; the timed contacts change state **immediately**. Remove the supply and the timer starts counting; when the set time elapses, the contacts return to rest. The delay happens at the end.

*Typical uses:* an extractor or cooling fan that must run on after the main equipment stops, to clear fumes or remove residual heat; a machine guard lock that stays engaged for a few seconds after shutdown while a flywheel coasts to a stop; lighting that stays on briefly after a control signal ends so an operator can leave the area.

**The distinction that causes real faults.** Ask yourself: *does the load need to wait before it starts, or keep going after it stops?* Waiting before starting is ON-delay. Continuing after stopping is OFF-delay. Fitting the wrong one produces a circuit that energises at exactly the wrong moment, and because both devices look almost identical on the DIN rail, the error is easy to make and slow to find.

**A worked example — oven and extractor fan.** An industrial oven must not be left with hot fumes trapped inside. The requirement: when the oven is switched off, the extractor fan must continue for three minutes, then stop by itself.

Work through the logic. Does the fan need to delay its *start*? No — while the oven runs, the fan should already be running. Does it need to continue after the control signal ends? Yes, for three minutes. Therefore this is an **OFF-delay** function, set to three minutes, with the oven's run signal as the timer's control input and the fan contactor driven from the timer's timed contact.

Now check the failure mode, which is the part inexperienced technicians skip. If the timer is the type needing a permanent auxiliary supply and you wire only the oven signal to it, the timer loses power the instant the oven stops — and the fan stops immediately instead of running on. The circuit will appear to work during commissioning (the fan runs while the oven runs) and fail silently at exactly the moment its safety purpose matters. This is why the supply arrangement from the previous lesson is not a footnote.

**Combined ON-and-OFF delay.** Some timers provide both delays in one device with independently set times: the output waits a set period before operating, and waits a second set period before releasing. This is used where a process must ignore short excursions in both directions — for example a level control that should not react to sloshing liquid briefly touching a probe, nor to it briefly uncovering one.$c$,
$c$تقريبًا كل متطلبات التوقيت في الصناعة مبنية من أساسين اثنين. أتقِن هذين، وما تبقى مجرد تنويعات.

**تأخير التشغيل (تأخير عند التغذية).** طبّق تغذية التحكم؛ يبدأ المؤقت بالعد؛ لا شيء يتغير في الخرج بعد. عند انقضاء الزمن المضبوط، تغيّر التلامسات المؤقتة حالتها وتبقى كذلك ما دامت التغذية قائمة. اقطع التغذية فتعود التلامسات فورًا لوضع السكون، ويُصفَّر العد.

السلوك الذي يجب استيعابه: **التأخير يحدث في البداية، والتصفير لحظي.** إذا اختفت إشارة التحكم قبل بلوغ الزمن المضبوط، يُصفَّر المؤقت ببساطة — لا يتذكر تقدمًا جزئيًا ولا يعمل. وهذه الخاصية مفيدة فعلًا: تعني أن اضطرابًا لحظيًا في إشارة التحكم لا يمكنه تشغيل الخرج المؤخَّر.

*استخدامات نموذجية:* إبقاء المحرك على النجمة قبل التحويل لدلتا؛ تدريج بدء عدة أحمال كبيرة كي لا تسحب تيار اندفاعها كله في آن واحد؛ اشتراط الضغط على زر البدء لثانيتين قبل تشغيل الماكينة، فلا يفعل الاحتكاك العرضي بالزر شيئًا.

**تأخير الفصل (تأخير عند قطع التغذية).** طبّق تغذية التحكم؛ تغيّر التلامسات المؤقتة حالتها **فورًا**. اقطع التغذية فيبدأ المؤقت بالعد؛ وعند انقضاء الزمن تعود التلامسات لوضع السكون. التأخير يحدث في النهاية.

*استخدامات نموذجية:* مروحة شفط أو تبريد يجب أن تستمر بعد توقف المعدة الرئيسية، لإخراج الأبخرة أو إزالة الحرارة المتبقية؛ قفل حارس ماكينة يبقى مشتبكًا لثوانٍ بعد الإيقاف بينما تتباطأ حدافة حتى التوقف؛ إضاءة تبقى مضاءة قليلًا بعد انتهاء إشارة التحكم ليغادر المشغّل المنطقة.

**الفارق الذي يسبب أعطالًا حقيقية.** اسأل نفسك: *هل يحتاج الحمل أن ينتظر قبل أن يبدأ، أم أن يستمر بعد أن يتوقف؟* الانتظار قبل البدء هو تأخير تشغيل. الاستمرار بعد التوقف هو تأخير فصل. تركيب النوع الخاطئ ينتج دائرة تعمل في اللحظة الخاطئة تمامًا، ولأن الجهازين يبدوان متطابقين تقريبًا على قضيب التثبيت، فالخطأ سهل الوقوع وبطيء الاكتشاف.

**مثال محلول — فرن ومروحة شفط.** يجب ألا يُترك فرن صناعي وبداخله أبخرة ساخنة محبوسة. المطلوب: عند إطفاء الفرن، تستمر مروحة الشفط ثلاث دقائق ثم تتوقف ذاتيًا.

تتبّع المنطق. هل تحتاج المروحة لتأخير *بدئها*؟ لا — أثناء عمل الفرن ينبغي أن تكون المروحة تعمل أصلًا. هل تحتاج للاستمرار بعد انتهاء إشارة التحكم؟ نعم، لثلاث دقائق. إذن هذه وظيفة **تأخير فصل**، مضبوطة على ثلاث دقائق، بإشارة تشغيل الفرن كدخل تحكم للمؤقت، وكونتاكتور المروحة مُغذّى من التلامس المؤقت.

الآن افحص حالة الفشل، وهي الجزء الذي يتخطاه الفنيون قليلو الخبرة. إذا كان المؤقت من النوع الذي يحتاج تغذية مساعدة دائمة ووصّلت له إشارة الفرن فقط، يفقد المؤقت طاقته لحظة توقف الفرن — فتتوقف المروحة فورًا بدل أن تستمر. ستبدو الدائرة سليمة أثناء التشغيل التجريبي (المروحة تدور بينما الفرن يعمل) وتفشل صامتة في اللحظة التي يهم فيها غرضها الوقائي بالضبط. لهذا فإن ترتيب التغذية في الدرس السابق ليس هامشًا.

**التأخير المزدوج عند التشغيل والفصل.** توفر بعض المؤقتات كلا التأخيرين في جهاز واحد بزمنين مستقلين: ينتظر الخرج مدة محددة قبل العمل، وينتظر مدة ثانية قبل التحرر. يُستخدم هذا حيث يجب أن تتجاهل العملية تقلبات قصيرة في الاتجاهين — مثل تحكم في المستوى لا ينبغي أن يستجيب لسائل يتمايل فيلامس مجسًا للحظة، ولا لانكشاف المجس للحظة.$c$,
2
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$Interval, One-Shot and Repeat-Cycle Functions$t$,
$t$وظائف الفترة والنبضة الواحدة والدورة المتكررة$t$,
$c$Beyond the two foundations sit the functions that generate time rather than merely delay it.

**Interval (one-shot / single pulse).** On receiving the control signal, the output changes state **immediately** and holds for the set time, then returns to rest **on its own** — even if the control signal is still present. That last clause is the whole point: an interval timer produces a pulse of fixed length regardless of how long the input is held.

This matters for anything where an operator might hold a button too long. A timed glue dispense, a metered water fill, a fixed-length wash: if the duration were determined by how long someone pressed a button, every cycle would differ. The interval function makes the dose repeatable and takes human variability out of the process.

*A subtlety worth knowing:* interval timers differ in how they respond to a new signal arriving while the pulse is still running. Some ignore it; some restart the count (retriggerable). If a process can receive overlapping start requests, you must know which behaviour you have bought, or the dose will not be what you expect.

**Interval-OFF.** The mirror image: the output sits operated, and on receiving the signal it releases for the set time before returning. Less common, but used where a continuously energised circuit must be interrupted for a fixed, repeatable period.

**Repeat cycle (flasher).** The output alternates on and off continuously for as long as the supply is present. Two variants exist and the difference is not cosmetic:

- **Starting with OFF** — on power-up the output stays at rest for the first interval, then begins alternating. Choose this when the process must not act the instant it is switched on: an intermittent agitator that should let material settle before its first stir.
- **Starting with ON** — the output operates immediately on power-up, then alternates. Choose this when the first action must be immediate: a warning beacon that must flash the moment a hazard condition appears, not one interval later.

Better repeat-cycle timers allow the on-time and the off-time to be set **independently**, which is what you need for a duty such as *run two seconds, rest twenty minutes*. A timer offering only a symmetrical cycle cannot do that job, and checking this before purchase saves a return.

*Typical uses:* flashing warning beacons; intermittent lubrication; periodic agitation of a settling tank; purge cycles.

**Random / asymmetric functions.** Some multi-function timers include a randomised or asymmetric mode, most often used in security lighting so a building does not display an obviously mechanical pattern to an observer.

**A worked example — timed dosing with a purge.** A mixing vessel must receive a two-second additive dose every fifteen minutes while the plant is running, and the dosing line must be purged with air for one second after each dose.

Break it into its timing primitives rather than reaching for a single clever device:

1. A **repeat-cycle** timer establishes the fifteen-minute rhythm and emits the trigger.
2. That trigger drives an **interval** timer set to two seconds, which opens the additive valve for a precise dose — fixed-length regardless of how long the trigger persists.
3. The end of the dose triggers a second **interval** timer set to one second, which opens the air valve to purge the line.

Three simple, independently adjustable functions, each doing one job. This is the correct instinct in control design: compose behaviour from well-understood primitives instead of specifying one complicated device whose internal behaviour nobody on site fully understands. When the plant manager later asks for a three-second dose, you turn one dial rather than reprogramming a black box.$c$,
$c$خلف الأساسين تقع الوظائف التي *تولّد* الزمن بدلًا من مجرد تأخيره.

**الفترة (النبضة الواحدة).** عند استقبال إشارة التحكم، يغيّر الخرج حالته **فورًا** ويبقى للزمن المضبوط، ثم يعود لوضع السكون **من تلقاء نفسه** — حتى لو كانت إشارة التحكم ما تزال قائمة. هذه العبارة الأخيرة هي جوهر الموضوع: مؤقت الفترة ينتج نبضة بطول ثابت بغض النظر عن مدة بقاء الدخل.

يهم هذا في أي شيء قد يضغط فيه المشغّل زرًا مدة أطول من اللازم. جرعة غراء مؤقتة، تعبئة ماء بمقدار محدد، غسلة بطول ثابت: لو كانت المدة محكومة بمدة ضغط شخص ما على زر، لاختلفت كل دورة عن الأخرى. وظيفة الفترة تجعل الجرعة قابلة للتكرار وتُخرج التباين البشري من العملية.

*تفصيلة تستحق المعرفة:* تختلف مؤقتات الفترة في استجابتها لإشارة جديدة تصل أثناء النبضة. بعضها يتجاهلها، وبعضها يعيد بدء العد. إذا كانت العملية قد تستقبل طلبات بدء متداخلة، فيجب أن تعرف أي سلوك اشتريت، وإلا لن تكون الجرعة كما تتوقع.

**فترة الفصل.** الصورة المعاكسة: يبقى الخرج عاملًا، وعند استقبال الإشارة يتحرر للزمن المضبوط قبل أن يعود. أقل شيوعًا، لكنه يُستخدم حيث يجب قطع دائرة دائمة التغذية لمدة ثابتة وقابلة للتكرار.

**الدورة المتكررة (الوماض).** يتناوب الخرج بين التشغيل والفصل باستمرار ما دامت التغذية قائمة. يوجد شكلان والفرق بينهما ليس شكليًا:

- **البدء بالفصل** — عند التغذية يبقى الخرج ساكنًا أول فترة، ثم يبدأ التناوب. اختر هذا عندما يجب ألا تعمل العملية لحظة تشغيلها: خلّاط متقطع ينبغي أن يترك المادة تستقر قبل أول تقليب.
- **البدء بالتشغيل** — يعمل الخرج فورًا عند التغذية ثم يتناوب. اختر هذا عندما يجب أن يكون الفعل الأول فوريًا: منارة تحذير يجب أن تومض لحظة ظهور الخطر، لا بعد فترة كاملة.

تتيح المؤقتات الأفضل ضبط زمن التشغيل وزمن الفصل **بشكل مستقل**، وهذا ما تحتاجه لخدمة مثل *اعمل ثانيتين، ارتَح عشرين دقيقة*. المؤقت الذي يوفر دورة متماثلة فقط لا يصلح لهذا العمل، والتحقق من ذلك قبل الشراء يوفر عملية إرجاع.

*استخدامات نموذجية:* منارات تحذير وامضة؛ تشحيم متقطع؛ تقليب دوري لخزان ترسيب؛ دورات تطهير.

**الوظائف العشوائية وغير المتماثلة.** تتضمن بعض المؤقتات متعددة الوظائف وضعًا عشوائيًا، يُستخدم غالبًا في إضاءة الأمن كي لا يُظهر المبنى نمطًا آليًا واضحًا للمراقب.

**مثال محلول — جرعة مؤقتة مع تطهير.** يجب أن يستقبل وعاء خلط جرعة إضافة لثانيتين كل خمس عشرة دقيقة أثناء تشغيل المصنع، ويجب تطهير خط الجرعات بالهواء لثانية واحدة بعد كل جرعة.

فكّكها إلى وظائفها الأولية بدل اللجوء لجهاز واحد بارع:

1. مؤقت **دورة متكررة** يرسّخ إيقاع الخمس عشرة دقيقة ويصدر الإشارة.
2. تلك الإشارة تشغّل مؤقت **فترة** مضبوطًا على ثانيتين، يفتح صمام الإضافة لجرعة دقيقة — بطول ثابت بغض النظر عن استمرار الإشارة.
3. نهاية الجرعة تشغّل مؤقت **فترة** ثانيًا مضبوطًا على ثانية واحدة، يفتح صمام الهواء لتطهير الخط.

ثلاث وظائف بسيطة قابلة للضبط باستقلال، كل منها يؤدي عملًا واحدًا. هذه هي الغريزة الصحيحة في تصميم التحكم: ركّب السلوك من عناصر أولية مفهومة جيدًا بدل تحديد جهاز واحد معقد لا يفهم أحد في الموقع سلوكه الداخلي بالكامل. وعندما يطلب مدير المصنع لاحقًا جرعة ثلاث ثوانٍ، تدير قرصًا واحدًا بدل إعادة برمجة صندوق أسود.$c$,
3
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$Reading a Timing Diagram and Setting a Real Timer$t$,
$t$قراءة مخطط التوقيت وضبط مؤقت حقيقي$t$,
$c$A timing diagram is the unambiguous language of timer behaviour. Datasheets use it because words like "delay" are ambiguous and a diagram is not.

**How to read one.** Time runs left to right. Each row is one signal, drawn as a square wave: high means energised/closed, low means de-energised/open. The top row is almost always the control input; below it are the timed contacts. Delays are marked with an arrow or bracket spanning the gap between an input edge and the corresponding output edge.

The reading technique that removes all doubt: **put your finger on an input edge and slide right until the output row changes.** The horizontal distance you travelled is the delay, and *which* input edge you started from tells you the function. If the output changes at a distance after the input's **rising** edge, it is ON-delay. If it changes at a distance after the **falling** edge, it is OFF-delay. If it changes immediately at the rising edge and then falls by itself later, it is interval. Three seconds of finger-tracing settles arguments that words cannot.

**Reading the terminal markings.** Control-gear terminal numbering follows a convention worth memorising, because it lets you wire an unfamiliar device correctly from the markings alone.

- **A1 and A2** are the supply/coil terminals — the power that makes the device operate. On timers needing a separate trigger, you will find an additional control terminal distinct from A1/A2, and confusing the two is the classic wiring error on OFF-delay devices.
- **Changeover contacts** are numbered in groups of three: a common, a normally-closed and a normally-open. The first digit identifies which contact block you are on, the second digit its role within the block. Once you recognise the pattern, an unlabelled timer holds no mystery.

**Range and multiplier.** Most multi-function timers carry two selectors besides the time dial: a **function selector** (which timing behaviour) and a **range or multiplier selector** (typically marked as factors such as ×1, ×10, ×100, or as bands like seconds/minutes/hours). The final time is the dial reading multiplied by the selected factor.

Two practical rules follow:

1. **Always choose the narrowest range that contains your target time.** A ten-second delay set on a hundred-second range sits near the bottom of the scale, where dial resolution and device tolerance are at their worst. The same ten seconds on a ten-second range uses the full scale and is far more repeatable.
2. **Set the function selector before the time.** On many devices the function switch changes what the dial means, so setting the time first and the function afterwards can silently leave you with a different delay than you intended.

**Commissioning a timer properly.** Setting the dial is not commissioning. The procedure that catches real faults:

1. With the circuit safely isolated, confirm the function selector matches the drawing — not what you assume the circuit needs, but what the drawing specifies.
2. Verify the supply arrangement: is A1/A2 permanently fed, or switched? For an OFF-delay device, confirm it retains power through the delay.
3. Energise and **time the delay with a watch.** Do not trust the dial legend. Dials drift, previous technicians move them, and a timer that reads ten seconds but delivers four will produce a star-delta transition that destroys contactors.
4. Test the reset behaviour: interrupt the control signal partway through the delay and confirm the timer resets rather than resuming. Circuits are commissioned in the happy path and fail in the interrupted one.
5. Record the measured time on the panel schedule, not just the intended one. The next technician will thank you, and a drifting timer becomes visible across successive maintenance visits.

**Failure modes to recognise in the field.** A timer that operates instantly every time usually has its timed contact confused with an instantaneous contact, or a function selector on the wrong setting. A timer that never operates may have its trigger applied to the coil terminals of a type expecting a separate trigger. A timer whose delay wanders between cycles is often being fed a supply that sags during starting, and the fault is in the supply, not the timer — replacing the timer in that case wastes money and leaves the fault in place.$c$,
$c$مخطط التوقيت هو اللغة غير الملتبسة لسلوك المؤقتات. تستخدمه أوراق البيانات لأن كلمات مثل "تأخير" ملتبسة، والمخطط ليس كذلك.

**كيف تقرأه.** الزمن يسير من اليسار لليمين. كل صف إشارة واحدة، مرسومة كموجة مربعة: المستوى المرتفع يعني مُغذّى/مغلق، والمنخفض يعني مفصول/مفتوح. الصف العلوي هو دخل التحكم في الغالب؛ وتحته التلامسات المؤقتة. تُعلَّم التأخيرات بسهم أو قوس يمتد بين حافة الدخل وحافة الخرج المقابلة.

تقنية القراءة التي تزيل كل شك: **ضع إصبعك على حافة الدخل وحرّكه يمينًا حتى يتغير صف الخرج.** المسافة الأفقية التي قطعتها هي التأخير، و*أي* حافة دخل بدأت منها تخبرك بالوظيفة. إن تغيّر الخرج بعد مسافة من الحافة **الصاعدة** فهو تأخير تشغيل. وإن تغيّر بعد مسافة من الحافة **الهابطة** فهو تأخير فصل. وإن تغيّر فورًا عند الحافة الصاعدة ثم هبط ذاتيًا لاحقًا فهو فترة. ثلاث ثوانٍ من تتبع الإصبع تحسم جدالًا لا تحسمه الكلمات.

**قراءة ترقيم الأطراف.** يتبع ترقيم أطراف أجهزة التحكم عرفًا يستحق الحفظ، لأنه يتيح لك توصيل جهاز غير مألوف بشكل صحيح من العلامات وحدها.

- **A1 وA2** طرفا التغذية/الملف — الطاقة التي تجعل الجهاز يعمل. في المؤقتات التي تحتاج تشغيلًا منفصلًا، ستجد طرف تحكم إضافيًا مستقلًا عن A1/A2، والخلط بينهما هو خطأ التوصيل الكلاسيكي في أجهزة تأخير الفصل.
- **تلامسات التحويل** تُرقَّم في مجموعات من ثلاثة: مشترك، ومغلق طبيعيًا، ومفتوح طبيعيًا. الرقم الأول يحدد كتلة التلامس، والثاني دوره داخلها. وبمجرد أن تتعرف على النمط، لا يعود المؤقت غير المعنون لغزًا.

**المدى والمضاعف.** تحمل أغلب المؤقتات متعددة الوظائف مفتاحين إلى جانب قرص الزمن: **مفتاح الوظيفة** (أي سلوك توقيت) و**مفتاح المدى أو المضاعف** (يُعلَّم عادة بعوامل مثل ×1 و×10 و×100، أو بنطاقات ثوانٍ/دقائق/ساعات). الزمن النهائي هو قراءة القرص مضروبة في العامل المختار.

تنبثق عن ذلك قاعدتان عمليتان:

1. **اختر دائمًا أضيق مدى يحتوي زمنك المطلوب.** تأخير عشر ثوانٍ مضبوط على مدى مئة ثانية يقع قرب أسفل التدريج، حيث دقة القرص وتفاوت الجهاز في أسوأ حالاتهما. ونفس العشر ثوانٍ على مدى عشر ثوانٍ تستخدم كامل التدريج وتكون أكثر قابلية للتكرار بكثير.
2. **اضبط مفتاح الوظيفة قبل الزمن.** في كثير من الأجهزة يغيّر مفتاح الوظيفة معنى القرص، فضبط الزمن أولًا والوظيفة بعده قد يتركك صامتًا بتأخير مختلف عما قصدت.

**التشغيل التجريبي الصحيح للمؤقت.** ضبط القرص ليس تشغيلًا تجريبيًا. الإجراء الذي يكشف الأعطال الحقيقية:

1. مع عزل الدائرة بأمان، تأكد أن مفتاح الوظيفة يطابق الرسم — لا ما تفترض أن الدائرة تحتاجه، بل ما يحدده الرسم.
2. تحقق من ترتيب التغذية: هل A1/A2 مُغذّى دائمًا أم مُفتَّح؟ وفي جهاز تأخير الفصل، تأكد أنه يحتفظ بالطاقة طوال التأخير.
3. غذِّ الدائرة و**قِس التأخير بساعة.** لا تثق بتدريج القرص. الأقراص تنحرف، والفنيون السابقون يحركونها، والمؤقت الذي يقرأ عشر ثوانٍ ويعطي أربعًا سينتج تحويل نجمة/دلتا يدمّر الكونتاكتورات.
4. اختبر سلوك التصفير: اقطع إشارة التحكم في منتصف التأخير وتأكد أن المؤقت يُصفَّر بدل أن يستأنف. تُشغَّل الدوائر تجريبيًا في المسار السعيد وتفشل في المسار المقطوع.
5. سجّل الزمن المقاس في جدول اللوحة، لا الزمن المقصود فقط. سيشكرك الفني التالي، ويصبح انحراف المؤقت مرئيًا عبر زيارات الصيانة المتعاقبة.

**حالات فشل يجب تمييزها ميدانيًا.** المؤقت الذي يعمل فورًا في كل مرة غالبًا خُلط تلامسه المؤقت بتلامس لحظي، أو مفتاح وظيفته على وضع خاطئ. والمؤقت الذي لا يعمل أبدًا قد يكون تشغيله مطبقًا على طرفي الملف في نوع يتوقع تشغيلًا منفصلًا. والمؤقت الذي يتذبذب تأخيره بين الدورات غالبًا يُغذّى بجهد يهبط أثناء البدء، والعطل في التغذية لا في المؤقت — واستبدال المؤقت هنا يهدر المال ويترك العطل قائمًا.$c$,
4
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$The Star-Delta Timing Sequence$t$,
$t$تتابع توقيت نجمة/دلتا$t$,
$c$Star-delta starting is the classic worked application of an ON-delay timer, and it is the one where getting the timing wrong has immediate physical consequences.

**Why the delay exists.** A three-phase induction motor started directly on line draws a large inrush current — several times its running current — which stresses the supply, dips the voltage for everything else on the busbar, and shocks the driven machinery mechanically. Connecting the stator windings in star during starting reduces the voltage across each winding, which reduces both the starting current and the starting torque substantially. Once the motor has accelerated close to running speed, the windings are reconnected in delta for normal operation at full torque.

The timer's job is to decide **when** that changeover happens.

**The three contactors.** A star-delta starter uses a main contactor, a star contactor and a delta contactor. The star and delta contactors must **never** be closed simultaneously — doing so short-circuits the supply through the windings. This is why star-delta starters carry both an electrical interlock (each contactor's normally-closed auxiliary contact wired in the other's coil circuit) and usually a mechanical interlock as well. That interlock is not optional and it is not a place to economise.

**The two times that matter.**

1. **The star period** — how long the motor runs in star before transfer. Too short and the motor has not accelerated, so it draws a large current surge at transfer, defeating the purpose of the starter. Too long and the motor sits at reduced torque unable to accelerate further, overheating the windings while achieving nothing. The correct value depends on the load's inertia and must be determined for the specific machine, then measured and recorded — not copied from another panel.
2. **The transition dead time** — a brief gap between the star contactor opening and the delta contactor closing. This exists because contactor contacts do not open instantaneously; they take a few milliseconds to part and the arc takes time to extinguish. Without a dead time, the delta contactor can close while the star contacts are still conducting, producing exactly the phase-to-phase short the interlock is meant to prevent. Purpose-built star-delta timers provide this dead time as a designed, fixed property of the device.

**Why this is a hardware timer's job — and this is the key engineering point.** The dead time is measured in milliseconds and its correctness is *safety-critical*: get it wrong and you short the supply through a motor winding. A dedicated star-delta timer performs this transition deterministically, in hardware, every single time, with no dependence on a network, a processor's task scheduler, a firmware update, or a cloud service being reachable.

This is the boundary that the next lesson explores in detail, and it is worth stating plainly here: **you may automate when a star-delta starter is commanded to start; you must not move the star-delta transition timing itself into a smart scheduler.** A phone app deciding a motor should start at 6 a.m. is sound engineering. A phone app deciding the precise millisecond to transfer from star to delta is not. Modern practice for anything beyond simple applications is a soft starter or a variable frequency drive, which manage the acceleration profile electronically and remove the discrete transition entirely.

**Commissioning checklist for a star-delta starter.**

1. With the motor isolated, confirm the interlock physically prevents star and delta closing together — test it by hand, do not assume it.
2. Confirm the winding connections match the motor's nameplate and that the motor is actually suitable for star-delta starting at the supply voltage. A motor whose delta rating does not match the supply must not be started this way.
3. Verify the overload relay is placed correctly for the starter type and set to the appropriate current, remembering that winding currents in a star-delta arrangement are not the same as line currents.
4. Time the star period with a watch on the first start and observe whether the motor has genuinely reached near-running speed before transfer. Listen and watch: a transfer that produces a sharp surge and a mechanical jolt is happening too early.
5. Record the measured star time and the motor it was set for. The correct value is a property of that machine and its load, and it does not transfer to a different one.$c$,
$c$بدء نجمة/دلتا هو التطبيق الكلاسيكي المحلول لمؤقت تأخير التشغيل، وهو الذي يؤدي فيه الخطأ في التوقيت إلى عواقب مادية فورية.

**لماذا يوجد التأخير.** المحرك الحثي ثلاثي الأطوار المبدوء مباشرة على الخط يسحب تيار اندفاع كبيرًا — أضعاف تيار تشغيله — ما يُجهد التغذية، ويُهبط الجهد على كل ما عداه على القضيب، ويصدم الآلات المُدارة ميكانيكيًا. توصيل ملفات العضو الثابت على النجمة أثناء البدء يقلل الجهد عبر كل ملف، فيقلل تيار البدء وعزم البدء معًا بشكل كبير. وبعد أن يتسارع المحرك قريبًا من سرعة التشغيل، تُعاد ملفاته على دلتا للتشغيل العادي بالعزم الكامل.

ووظيفة المؤقت أن يقرر **متى** يحدث ذلك التحويل.

**الكونتاكتورات الثلاثة.** يستخدم بادئ نجمة/دلتا كونتاكتورًا رئيسيًا وكونتاكتور نجمة وكونتاكتور دلتا. ويجب **ألا** ينغلق كونتاكتورا النجمة والدلتا في آن واحد أبدًا — فذلك يقصر التغذية عبر الملفات. ولهذا يحمل بادئ نجمة/دلتا تعشيقًا كهربائيًا (التلامس المساعد المغلق طبيعيًا لكل كونتاكتور موصَّل في دائرة ملف الآخر) وعادة تعشيقًا ميكانيكيًا أيضًا. هذا التعشيق ليس اختياريًا وليس موضعًا للتوفير.

**الزمنان اللذان يهمّان.**

1. **فترة النجمة** — كم يعمل المحرك على النجمة قبل التحويل. القصيرة جدًا تعني أن المحرك لم يتسارع، فيسحب اندفاع تيار كبيرًا عند التحويل، ما يبطل غرض البادئ. والطويلة جدًا تترك المحرك بعزم منخفض عاجزًا عن مزيد من التسارع، فتسخن ملفاته دون تحقيق شيء. القيمة الصحيحة تعتمد على عطالة الحمل ويجب تحديدها للماكينة بعينها، ثم قياسها وتسجيلها — لا نسخها من لوحة أخرى.
2. **زمن التحويل الميت** — فجوة قصيرة بين فتح كونتاكتور النجمة وغلق كونتاكتور الدلتا. توجد لأن تلامسات الكونتاكتور لا تُفتح لحظيًا؛ تحتاج أجزاء من الألف من الثانية لتتباعد، ويحتاج القوس وقتًا لينطفئ. وبدون زمن ميت قد ينغلق كونتاكتور الدلتا بينما تلامسات النجمة ما تزال موصِّلة، منتجًا بالضبط القصر بين الأطوار الذي وُجد التعشيق لمنعه. توفر مؤقتات نجمة/دلتا المخصصة هذا الزمن الميت كخاصية مصمَّمة وثابتة في الجهاز.

**لماذا هذه وظيفة مؤقت عتادي — وهذه هي النقطة الهندسية المحورية.** الزمن الميت يُقاس بأجزاء من الألف من الثانية وصحته *حرجة للسلامة*: أخطئ فيه فتُقصِّر التغذية عبر ملف محرك. المؤقت المخصص لنجمة/دلتا ينفّذ هذا التحويل بشكل حتمي، في العتاد، في كل مرة، دون اعتماد على شبكة أو مجدول مهام معالج أو تحديث برنامج ثابت أو خدمة سحابية متاحة.

هذا هو الحد الذي يستكشفه الدرس التالي بالتفصيل، ويستحق التصريح به هنا بوضوح: **يمكنك أتمتة *متى* يُؤمر بادئ نجمة/دلتا بالبدء؛ ولا يجوز نقل توقيت التحويل نفسه إلى مجدول ذكي.** تطبيق هاتف يقرر أن محركًا يبدأ السادسة صباحًا هندسة سليمة. وتطبيق هاتف يقرر الجزء الدقيق من الألف من الثانية للانتقال من النجمة إلى الدلتا ليس كذلك. والممارسة الحديثة لأي شيء يتجاوز التطبيقات البسيطة هي البادئ الناعم أو مغيّر التردد، اللذان يديران منحنى التسارع إلكترونيًا ويلغيان التحويل المنفصل تمامًا.

**قائمة فحص التشغيل التجريبي لبادئ نجمة/دلتا.**

1. مع عزل المحرك، تأكد أن التعشيق يمنع فعليًا انغلاق النجمة والدلتا معًا — اختبره يدويًا ولا تفترض.
2. تأكد أن توصيلات الملفات تطابق لوحة بيانات المحرك، وأن المحرك مناسب فعلًا لبدء نجمة/دلتا على جهد التغذية. المحرك الذي لا يطابق تصنيف دلتا فيه جهد التغذية يجب ألا يُبدأ بهذه الطريقة.
3. تحقق أن ريليه الحمل الزائد موضوع بشكل صحيح لنوع البادئ ومضبوط على التيار المناسب، متذكرًا أن تيارات الملفات في ترتيب نجمة/دلتا ليست هي تيارات الخط.
4. قِس فترة النجمة بساعة عند أول تشغيل ولاحظ هل بلغ المحرك فعلًا سرعة قريبة من سرعة التشغيل قبل التحويل. استمع وراقب: التحويل الذي ينتج اندفاعًا حادًا وارتجاجًا ميكانيكيًا يحدث مبكرًا جدًا.
5. سجّل زمن النجمة المقاس والمحرك الذي ضُبط له. القيمة الصحيحة خاصية لتلك الماكينة وحملها، ولا تنتقل إلى غيرها.$c$,
5
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$From Timer Relay to Smart Scheduling: Where Each Belongs$t$,
$t$من مؤقت الريليه إلى الجدولة الذكية: أين ينتمي كل منهما$t$,
$c$Every timing function in this module has a modern counterpart in a smart-control app. Knowing the mapping makes you bilingual across both worlds; knowing the **boundary** makes you a competent engineer rather than an enthusiastic one.

**The direct equivalences.**

| Classical timer function | Smart-control equivalent |
|---|---|
| ON-delay | A scene with a delay step before the action |
| OFF-delay | Run-on: an action scheduled after a trigger ends |
| Interval / one-shot | Countdown or inching mode — device switches on, then off by itself |
| Repeat cycle | Loop or cyclic schedule with independent on/off durations |
| Photocell-driven lighting | Sunrise/sunset automation using the device's location |
| Time-of-day contactor control | A simple daily schedule |

A SONOFF device's inching mode is genuinely an interval timer. A loop schedule is genuinely a repeat-cycle timer. These are not loose analogies — the behaviour is the same, and a technician who understands the relay function already understands the app feature.

**What smart control adds that a relay cannot.**

- **Visibility.** A timer relay's state is knowable only by standing in front of the panel. A smart device reports its state and its history remotely, so a client can see that the pump ran last night without driving to the site.
- **Conditional logic.** A relay times. A smart scene can time *and* check conditions: run the irrigation cycle only if it has not rained, only if the tank level is adequate, only if it is a weekday.
- **Notification.** A timer that fails is discovered when someone notices the process is wrong. A smart device can send a push notification the moment an expected cycle does not complete — which is often the difference between an inconvenience and a destroyed pump.
- **Change without rewiring.** Adjusting a repeat cycle from twenty minutes to fifteen is a dial on a relay and an app edit on a smart device — but changing the *logic*, not just the time, means rewiring in the relay world and a few taps in the smart one.

**What smart control does not replace — and this is where careless installers cause damage.**

A smart scheduler executes when a processor gets round to it, subject to firmware scheduling, network latency, cloud availability, and clock synchronisation. For an irrigation cycle, a variance of a few seconds is irrelevant. For a safety interlock or a star-delta transition, it is unacceptable. State the rule plainly:

> **If the timing is safety-critical, or measured in milliseconds, or its failure damages equipment or injures a person — it stays in hardware.**

Concrete cases that must remain hardware: the star-delta transition dead time; any interlock preventing two contactors closing together; emergency-stop circuits and their associated delays; guard-lock release delays; and any sequence whose failure mode is a short circuit or an unguarded moving machine.

Concrete cases where smart scheduling is entirely appropriate: when a pump is permitted to run; lighting schedules and sunrise/sunset switching; irrigation cycles; intermittent ventilation in occupied spaces; and any process where a delayed or missed cycle is an inconvenience rather than a hazard.

**The hybrid approach — and this is what to actually sell.** The strongest design for most real installations is not "replace the relays" but **hardware for the critical timing, smart control for supervision and convenience.** Leave the star-delta timer doing its deterministic job inside the panel; add a smart contactor or monitoring device that decides *when* the starter is commanded, logs each run, and notifies the client if a start command produced no current draw.

That design keeps the machine safe under every failure mode — loss of internet, cloud outage, firmware fault — while giving the client the remote visibility and notification they are actually paying for. It also gives you an honest answer to the client who asks whether they can "control everything from the phone": yes for the things that should be controlled from a phone, and deliberately not for the things that protect their equipment and their staff.

**How to have this conversation with a client.** Clients often ask for full app control because they have seen it advertised, not because they have assessed the risk. The professional response is neither to refuse nor to agree blindly: explain which functions move to the app, which stay in the panel, and why — specifically, that a network outage must never be able to cause a short circuit. Clients who understand the distinction trust the installer more, not less, and it is a straightforward way to demonstrate that you are an engineer rather than a box-fitter.$c$,
$c$لكل وظيفة توقيت في هذا البرنامج نظير حديث في تطبيق تحكم ذكي. معرفة التقابل تجعلك ثنائي اللغة عبر العالمين؛ ومعرفة **الحد الفاصل** تجعلك مهندسًا كفؤًا لا مجرد متحمس.

**التقابلات المباشرة.**

| وظيفة المؤقت الكلاسيكي | المكافئ في التحكم الذكي |
|---|---|
| تأخير التشغيل | مشهد بخطوة تأخير قبل الإجراء |
| تأخير الفصل | استمرار بعد الإيقاف: إجراء مجدول بعد انتهاء المُشغِّل |
| الفترة / النبضة الواحدة | العد التنازلي أو وضع Inching — يعمل الجهاز ثم يفصل ذاتيًا |
| الدورة المتكررة | جدول دوري بمدد تشغيل وفصل مستقلة |
| إضاءة بخلية ضوئية | أتمتة الشروق/الغروب حسب موقع الجهاز |
| تحكم كونتاكتور بوقت اليوم | جدول يومي بسيط |

وضع Inching في جهاز SONOFF هو فعلًا مؤقت فترة. والجدول الدوري هو فعلًا مؤقت دورة متكررة. هذه ليست تشبيهات فضفاضة — السلوك واحد، والفني الذي يفهم وظيفة الريليه يفهم ميزة التطبيق سلفًا.

**ما يضيفه التحكم الذكي ولا يستطيعه الريليه.**

- **الرؤية.** حالة مؤقت الريليه لا تُعرف إلا بالوقوف أمام اللوحة. أما الجهاز الذكي فيبلّغ عن حالته وسجله عن بُعد، فيرى العميل أن المضخة عملت ليلة أمس دون أن يقود إلى الموقع.
- **المنطق الشرطي.** الريليه يؤقّت. والمشهد الذكي يمكنه أن يؤقّت *ويفحص* شروطًا: شغّل دورة الري فقط إن لم تمطر، وفقط إن كان مستوى الخزان كافيًا، وفقط في أيام العمل.
- **التنبيه.** المؤقت الذي يفشل يُكتشف حين يلاحظ أحدهم أن العملية خاطئة. والجهاز الذكي يرسل إشعارًا لحظة عدم اكتمال دورة متوقعة — وهذا غالبًا الفرق بين إزعاج ومضخة محترقة.
- **التغيير دون إعادة تسليك.** تعديل دورة متكررة من عشرين دقيقة إلى خمس عشرة هو قرص في الريليه وتعديل تطبيق في الجهاز الذكي — لكن تغيير *المنطق* لا الزمن فقط يعني إعادة تسليك في عالم الريليهات ولمسات قليلة في العالم الذكي.

**ما لا يحل التحكم الذكي محله — وهنا يُحدث المركّبون المستهترون ضررًا.**

المجدول الذكي ينفّذ حين يتفرغ له المعالج، خاضعًا لجدولة البرنامج الثابت وزمن الشبكة وتوافر السحابة وتزامن الساعة. في دورة ري، تفاوت بضع ثوانٍ لا يعني شيئًا. أما في تعشيق سلامة أو تحويل نجمة/دلتا فهو غير مقبول. لنصرّح بالقاعدة بوضوح:

> **إذا كان التوقيت حرجًا للسلامة، أو مُقاسًا بأجزاء من الألف من الثانية، أو كان فشله يتلف معدات أو يصيب إنسانًا — فمكانه العتاد.**

حالات محددة يجب أن تبقى عتادية: زمن التحويل الميت في نجمة/دلتا؛ أي تعشيق يمنع انغلاق كونتاكتورين معًا؛ دوائر إيقاف الطوارئ وتأخيراتها؛ تأخيرات تحرير أقفال الحُرّاس؛ وأي تتابع يكون فشله قصرًا كهربائيًا أو ماكينة متحركة بلا حارس.

حالات محددة تكون فيها الجدولة الذكية مناسبة تمامًا: متى يُسمح للمضخة بالعمل؛ جداول الإضاءة وتبديل الشروق/الغروب؛ دورات الري؛ التهوية المتقطعة في المساحات المأهولة؛ وأي عملية يكون تأخر دورتها أو فواتها إزعاجًا لا خطرًا.

**النهج الهجين — وهذا ما يجب بيعه فعلًا.** أقوى تصميم لمعظم التركيبات الحقيقية ليس "استبدل الريليهات" بل **عتاد للتوقيت الحرج، وتحكم ذكي للإشراف والراحة.** اترك مؤقت نجمة/دلتا يؤدي عمله الحتمي داخل اللوحة؛ وأضف كونتاكتورًا ذكيًا أو جهاز مراقبة يقرر *متى* يُؤمر البادئ، ويسجّل كل تشغيلة، وينبّه العميل إن لم ينتج أمر البدء أي سحب تيار.

هذا التصميم يُبقي الماكينة آمنة في كل حالات الفشل — انقطاع الإنترنت، تعطل السحابة، خلل البرنامج الثابت — بينما يمنح العميل الرؤية عن بُعد والتنبيه اللذين يدفع مقابلهما فعلًا. ويمنحك أيضًا إجابة صادقة للعميل الذي يسأل هل يمكنه "التحكم بكل شيء من الهاتف": نعم لما ينبغي التحكم به من الهاتف، ولا عمدًا لما يحمي معداته وموظفيه.

**كيف تدير هذا الحوار مع العميل.** يطلب العملاء غالبًا تحكمًا كاملًا بالتطبيق لأنهم رأوه في إعلان، لا لأنهم قيّموا المخاطر. والرد المهني ليس الرفض ولا الموافقة العمياء: اشرح أي وظائف تنتقل للتطبيق، وأيها تبقى في اللوحة، ولماذا — وتحديدًا أن انقطاع الشبكة يجب ألا يكون قادرًا أبدًا على إحداث قصر كهربائي. العملاء الذين يفهمون هذا التمييز يثقون بالمركّب أكثر لا أقل، وهي طريقة مباشرة لتُظهر أنك مهندس لا مجرد مركّب صناديق.$c$,
6
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

-- 4. Quizzes: bronze / silver / gold
INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'bronze', 'Timing Function Basics', 'أساسيات وظائف التوقيت', 80
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$In an ON-delay timer, when do the timed contacts change state?$q$,
    $q$في مؤقت تأخير التشغيل، متى تغيّر التلامسات المؤقتة حالتها؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-timers-timing-functions' AND quizzes.tier = 'bronze'
  RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$After the set time has elapsed following energisation$o$, $o$بعد انقضاء الزمن المضبوط عقب التغذية$o$, true, 1),
  ($o$Immediately on energisation$o$, $o$فورًا عند التغذية$o$, false, 2),
  ($o$After the set time following de-energisation$o$, $o$بعد الزمن المضبوط عقب قطع التغذية$o$, false, 3),
  ($o$Only when the reset button is pressed$o$, $o$فقط عند ضغط زر التصفير$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$An extractor fan must keep running for three minutes after an oven is switched off. Which timing function is required?$q$,
    $q$يجب أن تستمر مروحة الشفط ثلاث دقائق بعد إطفاء الفرن. أي وظيفة توقيت مطلوبة؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-timers-timing-functions' AND quizzes.tier = 'bronze'
  RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$OFF-delay$o$, $o$تأخير الفصل$o$, true, 1),
  ($o$ON-delay$o$, $o$تأخير التشغيل$o$, false, 2),
  ($o$Repeat cycle$o$, $o$دورة متكررة$o$, false, 3),
  ($o$Interval starting with ON$o$, $o$فترة تبدأ بالتشغيل$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$Which terminals on a control-gear device are conventionally the supply/coil terminals?$q$,
    $q$أي أطراف في أجهزة التحكم هي عرفًا طرفا التغذية/الملف؟$q$, 3
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-timers-timing-functions' AND quizzes.tier = 'bronze'
  RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$A1 and A2$o$, $o$A1 وA2$o$, true, 1),
  ($o$L1 and L2$o$, $o$L1 وL2$o$, false, 2),
  ($o$13 and 14$o$, $o$13 و14$o$, false, 3),
  ($o$U and V$o$, $o$U وV$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'silver', 'Applying Timing Functions', 'تطبيق وظائف التوقيت', 80
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$A dose valve must open for exactly two seconds each time it is triggered, even if the operator holds the button for ten seconds. Which function achieves this?$q$,
    $q$يجب أن يفتح صمام الجرعة ثانيتين بالضبط عند كل تشغيل، حتى لو ضغط المشغّل الزر عشر ثوانٍ. أي وظيفة تحقق ذلك؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-timers-timing-functions' AND quizzes.tier = 'silver'
  RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Interval (one-shot) — the pulse length is fixed regardless of input duration$o$, $o$الفترة (نبضة واحدة) — طول النبضة ثابت بغض النظر عن مدة الدخل$o$, true, 1),
  ($o$ON-delay — it waits two seconds before opening$o$, $o$تأخير التشغيل — ينتظر ثانيتين قبل الفتح$o$, false, 2),
  ($o$OFF-delay — it closes two seconds after release$o$, $o$تأخير الفصل — يغلق بعد ثانيتين من التحرير$o$, false, 3),
  ($o$Any function will work identically here$o$, $o$أي وظيفة ستعمل بنفس الشكل هنا$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$You need a ten-second delay. Why is it better to use a 0-10 second range than a 0-100 second range set to its lowest setting?$q$,
    $q$تحتاج تأخيرًا عشر ثوانٍ. لماذا استخدام مدى 0-10 ثوانٍ أفضل من مدى 0-100 ثانية مضبوط على أدناه؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-timers-timing-functions' AND quizzes.tier = 'silver'
  RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Dial resolution and repeatability are best across the full scale, worst at the bottom of a wide range$o$, $o$دقة القرص وقابلية التكرار أفضل عبر التدريج الكامل وأسوأ عند أسفل مدى واسع$o$, true, 1),
  ($o$Wide-range timers draw more current$o$, $o$المؤقتات واسعة المدى تسحب تيارًا أكبر$o$, false, 2),
  ($o$Narrow-range timers are always cheaper$o$, $o$المؤقتات ضيقة المدى أرخص دائمًا$o$, false, 3),
  ($o$There is no practical difference between them$o$, $o$لا فرق عملي بينهما$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$An OFF-delay circuit works during commissioning but the fan stops instantly instead of running on. What is the most likely cause?$q$,
    $q$دائرة تأخير فصل تعمل أثناء التشغيل التجريبي لكن المروحة تتوقف فورًا بدل الاستمرار. ما السبب الأرجح؟$q$, 3
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-timers-timing-functions' AND quizzes.tier = 'silver'
  RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$The timer needs a permanent auxiliary supply but was wired to lose power with the controlled load$o$, $o$المؤقت يحتاج تغذية مساعدة دائمة لكنه وُصِّل ليفقد الطاقة مع الحمل المتحكم فيه$o$, true, 1),
  ($o$The time dial is set too high$o$, $o$قرص الزمن مضبوط على قيمة عالية جدًا$o$, false, 2),
  ($o$The fan motor is too large for the contactor$o$, $o$محرك المروحة أكبر من الكونتاكتور$o$, false, 3),
  ($o$OFF-delay timers always behave this way$o$, $o$مؤقتات تأخير الفصل تتصرف هكذا دائمًا$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'gold', 'Timing Design & the Hardware/Smart Boundary', 'تصميم التوقيت والحد بين العتاد والذكي', 80
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$A client wants the star-delta transition timing moved into a phone app so they can "tune it remotely". What is the correct engineering response?$q$,
    $q$يريد عميل نقل توقيت تحويل نجمة/دلتا إلى تطبيق هاتف ليضبطه عن بُعد. ما الرد الهندسي الصحيح؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-timers-timing-functions' AND quizzes.tier = 'gold'
  RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Refuse and explain: the transition dead time is safety-critical and millisecond-scale, so it must stay in hardware — but start commands and monitoring can move to the app$o$, $o$ارفض واشرح: زمن التحويل الميت حرج للسلامة وبمقياس أجزاء من الألف من الثانية، فيجب أن يبقى عتاديًا — لكن أوامر البدء والمراقبة يمكن نقلها للتطبيق$o$, true, 1),
  ($o$Agree, since modern apps are fast enough$o$, $o$وافق، فالتطبيقات الحديثة سريعة بما يكفي$o$, false, 2),
  ($o$Agree but add a longer delay to compensate for network latency$o$, $o$وافق مع زيادة التأخير لتعويض زمن الشبكة$o$, false, 3),
  ($o$Refuse without explanation since the client will not understand$o$, $o$ارفض دون شرح لأن العميل لن يفهم$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$In a star-delta starter, why is a brief dead time required between the star contactor opening and the delta contactor closing?$q$,
    $q$في بادئ نجمة/دلتا، لماذا يلزم زمن ميت قصير بين فتح كونتاكتور النجمة وغلق كونتاكتور الدلتا؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-timers-timing-functions' AND quizzes.tier = 'gold'
  RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Contacts take milliseconds to part and the arc to extinguish; without the gap both could conduct and short the supply$o$, $o$تحتاج التلامسات أجزاء من الألف من الثانية لتتباعد وينطفئ القوس؛ وبدون الفجوة قد يوصّل الاثنان فيقصران التغذية$o$, true, 1),
  ($o$It gives the motor time to stop completely before delta$o$, $o$يعطي المحرك وقتًا ليتوقف تمامًا قبل دلتا$o$, false, 2),
  ($o$It reduces the electricity bill$o$, $o$يقلل فاتورة الكهرباء$o$, false, 3),
  ($o$It is a legacy convention with no technical purpose$o$, $o$عرف قديم بلا غرض تقني$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$Designing a borehole pump installation, which split between hardware timing and smart control is the soundest?$q$,
    $q$عند تصميم تركيب مضخة بئر، أي توزيع بين التوقيت العتادي والتحكم الذكي هو الأسلم؟$q$, 3
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-timers-timing-functions' AND quizzes.tier = 'gold'
  RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Dry-run protection and starter timing in hardware; scheduling, run logging and failure alerts in the smart layer$o$, $o$حماية التشغيل الجاف وتوقيت البادئ في العتاد؛ والجدولة وتسجيل التشغيل وتنبيهات الفشل في الطبقة الذكية$o$, true, 1),
  ($o$Everything in the smart layer for maximum flexibility$o$, $o$كل شيء في الطبقة الذكية لأقصى مرونة$o$, false, 2),
  ($o$Everything in hardware; smart control adds no value$o$, $o$كل شيء عتادي؛ التحكم الذكي لا يضيف قيمة$o$, false, 3),
  ($o$Dry-run protection in the app and scheduling in hardware$o$, $o$حماية التشغيل الجاف في التطبيق والجدولة في العتاد$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);
