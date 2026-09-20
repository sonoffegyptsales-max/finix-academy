-- ============================================================================
-- Finix Industrial Control track + Module I04: Timers & Timing Functions
--
-- ORIGINAL CONTENT. The topic progression follows standard industrial control
-- pedagogy; all explanations, analogies, worked examples and quiz items are
-- written for Finix Academy. No third-party text is reproduced.
-- ============================================================================

-- 1. New track -------------------------------------------------------------
INSERT INTO public.tracks (id, name, name_ar, tagline, tagline_ar, position)
VALUES (
  'finix-industrial-control',
  'Finix Industrial Control',
  'فينيكس للتحكم الصناعي',
  'Classical motor-control and automatic relay circuits, taught side by side with their modern smart-control equivalents.',
  'دوائر التحكم في المحركات والمرحّلات الآلية الكلاسيكية، مشروحة جنبًا إلى جنب مع مكافئاتها في التحكم الذكي الحديث.',
  7
)
ON CONFLICT (id) DO NOTHING;

-- 2. Module ----------------------------------------------------------------
INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES (
  'finix-timers-timing-functions',
  'I04',
  'finix-industrial-control',
  'Timers & Timing Functions: From Relay Logic to Smart Scheduling',
  'المؤقتات ووظائف التوقيت: من منطق المرحّلات إلى الجدولة الذكية',
  'The ten standard timing functions every control technician must recognise — ON delay, OFF delay, interval, repeat cycle and the rest — how to read a timing diagram, how to set a multi-function timer, worked panel applications, and how each classical timing function maps onto modern smart scheduling.',
  'وظائف التوقيت العشر القياسية التي يجب أن يعرفها كل فني تحكم — تأخير التشغيل، تأخير الفصل، النبضة، الدورة المتكررة وغيرها — وكيفية قراءة مخطط التوقيت، وضبط المؤقت متعدد الوظائف، وتطبيقات عملية من لوحات التحكم، وكيف ترتبط كل وظيفة كلاسيكية بالجدولة الذكية الحديثة.',
  NULL,
  26
)
ON CONFLICT (slug) DO NOTHING;

-- 3. Lessons ---------------------------------------------------------------

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
'The Timer as a Control Component',
'المؤقت كعنصر تحكم',
'A contactor answers one question: is the circuit on or off? A timer answers a different and more powerful one: **when**, and **for how long**. The moment you add a timer to a panel, the circuit stops being a simple switch and starts being a *sequence* — and sequences are what automatic control actually is.

**The coil.** Like a contactor, a timer has a control input, marked **A1** and **A2**. Applying the rated voltage across A1-A2 is what wakes the timer up. Timers are sold in many coil voltages — 24 V DC, 24 V AC, 110 V AC, 220-240 V AC — and a very common field mistake is fitting a 24 V timer into a 220 V control circuit. Always read the label before wiring.

**Timed contacts versus instantaneous contacts.** This is the distinction that separates technicians who understand timers from those who merely fit them. A **timed contact** changes state only after the set time has elapsed. An **instantaneous contact** changes state the moment the timer is energised, exactly like an ordinary relay contact. Many multi-function timers offer both. If you wire your holding circuit through a timed contact when you needed an instantaneous one, the circuit will appear dead for the duration of the delay and you will chase a fault that does not exist.

**Contact numbering.** Timer contacts are usually **changeover** (SPDT) contacts, and the industry numbers them in a predictable way. On a two-contact timer you will typically find one changeover numbered **15-16-18** and a second numbered **25-26-28**. In each group the first number is the common terminal, the middle number is the normally closed path, and the last number is the normally open path. So 15 is common, 16 is NC, 18 is NO. Recognising this pattern lets you read almost any timer terminal diagram without a manual.

**What a timer does not do.** A control timer is not built to carry motor current. Its contacts are rated for control loads — typically a few amperes — and their job is to switch a **contactor coil**, not the motor itself. The contactor carries the power; the timer carries only the decision. Technicians who forget this weld timer contacts and then blame the timer.',
'الكونتاكتور يجيب عن سؤال واحد: هل الدائرة تعمل أم لا؟ أما المؤقت فيجيب عن سؤال مختلف وأقوى: **متى**، و**لمدة كم**. في اللحظة التي تضيف فيها مؤقتًا إلى اللوحة، تتوقف الدائرة عن كونها مفتاحًا بسيطًا وتتحول إلى *تتابع* — والتتابع هو جوهر التحكم الآلي فعليًا.

**الملف.** مثل الكونتاكتور، للمؤقت دخل تحكم يُرمز له بـ **A1** و**A2**. تطبيق الجهد المقنّن بين A1-A2 هو ما يُشغّل المؤقت. تُصنَّع المؤقتات بجهود ملف متعددة — 24 فولت مستمر، 24 فولت متردد، 110 فولت، 220-240 فولت — ومن الأخطاء الميدانية الشائعة جدًا تركيب مؤقت 24 فولت في دائرة تحكم 220 فولت. اقرأ اللوحة التعريفية دائمًا قبل التوصيل.

**التلامسات المؤقتة مقابل التلامسات اللحظية.** هذا هو الفرق الذي يفصل الفني الذي يفهم المؤقتات عمّن يركّبها فقط. **التلامس المؤقت** يغيّر حالته فقط بعد انقضاء الزمن المضبوط. أما **التلامس اللحظي** فيغيّر حالته فور تغذية المؤقت، تمامًا مثل تلامس مرحّل عادي. كثير من المؤقتات متعددة الوظائف توفّر النوعين. وإذا وصّلت دائرة التثبيت عبر تلامس مؤقت بينما كنت تحتاج تلامسًا لحظيًا، ستبدو الدائرة ميتة طوال مدة التأخير وستطارد عطلًا غير موجود.

**ترقيم التلامسات.** تلامسات المؤقت غالبًا **تحويلية** (SPDT)، والصناعة ترقّمها بنمط يمكن توقّعه. في مؤقت بتلامسين ستجد عادة تلامسًا تحويليًا مرقّمًا **15-16-18** وآخر مرقّمًا **25-26-28**. في كل مجموعة، الرقم الأول هو الطرف المشترك، والرقم الأوسط هو المسار المغلق طبيعيًا، والأخير هو المسار المفتوح طبيعيًا. أي أن 15 مشترك، و16 مغلق طبيعيًا، و18 مفتوح طبيعيًا. إدراك هذا النمط يمكّنك من قراءة أي مخطط أطراف مؤقت تقريبًا دون كتالوج.

**ما لا يفعله المؤقت.** مؤقت التحكم غير مصمّم لحمل تيار المحرك. تلامساته مقنّنة لأحمال التحكم — بضعة أمبيرات عادة — ومهمتها تشغيل **ملف كونتاكتور**، لا المحرك نفسه. الكونتاكتور يحمل القدرة، والمؤقت يحمل القرار فقط. والفنيون الذين ينسون ذلك يلحمون تلامسات المؤقت ثم يلومون المؤقت.',
1
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
'How to Read a Timing Diagram',
'كيف تقرأ مخطط التوقيت',
'Every timer datasheet in the world explains its functions with a **timing diagram**, and a technician who can read one can select and commission any timer from any manufacturer without needing the text. It is the single most transferable skill in this module.

**The structure.** A timing diagram is a set of stacked horizontal tracks sharing one time axis that runs left to right. A track sits high when that signal is present and low when it is absent. You will normally see three kinds of track:

- **Supply (A1-A2)** — whether the timer has power.
- **Control or trigger input** — on timers that use a separate start signal, often labelled **B1**.
- **Output contact** — the state of the timed contact, the thing your circuit actually reacts to.

**The markings.** The set time is almost always drawn as **t**, with a horizontal arrow or a brace spanning the delay. Where a function has two independent times, they are shown as **t1** and **t2**. Dashed vertical lines connect a cause on one track to its effect on another — those lines are the argument the diagram is making.

**How to read one properly.** Do not try to absorb the whole picture at once. Put your finger at the far left and move right, and at every vertical line ask two questions: *what just changed?* and *what did it cause?* Reading a timing diagram is tracing cause and effect along a timeline, nothing more.

**Why it matters in the field.** Two timers can carry the same function name in different catalogues and behave differently in detail — particularly in what happens when the supply is removed mid-cycle, or whether the timer resets or holds. The written description often glosses over this. The timing diagram never does, because it has to draw the actual behaviour. When a commissioned circuit behaves *almost* right, the answer is nearly always in the diagram you skipped.',
'كل كتالوج مؤقت في العالم يشرح وظائفه عبر **مخطط التوقيت**، والفني القادر على قراءته يستطيع اختيار وتشغيل أي مؤقت من أي شركة دون الحاجة إلى النص. إنها أكثر مهارة قابلة للنقل في هذه الوحدة.

**البنية.** مخطط التوقيت مجموعة مسارات أفقية متراصّة تشترك في محور زمني واحد يسير من اليسار إلى اليمين. يرتفع المسار عند وجود الإشارة وينخفض عند غيابها. وستجد عادة ثلاثة أنواع من المسارات:

- **التغذية (A1-A2)** — هل المؤقت مُغذّى بالجهد أم لا.
- **دخل التحكم أو التشغيل** — في المؤقتات التي تستخدم إشارة بدء منفصلة، ويُرمز له غالبًا بـ **B1**.
- **تلامس الخرج** — حالة التلامس المؤقت، وهو ما تتفاعل معه دائرتك فعليًا.

**العلامات.** يُرسم الزمن المضبوط دائمًا تقريبًا بالرمز **t**، مع سهم أفقي أو قوس يمتد على فترة التأخير. وحين تحتوي الوظيفة على زمنين مستقلين يُرمز لهما بـ **t1** و**t2**. أما الخطوط الرأسية المتقطعة فتربط السبب في مسار بالنتيجة في مسار آخر — وهذه الخطوط هي الحجة التي يقدّمها المخطط.

**كيف تقرأه بشكل صحيح.** لا تحاول استيعاب الصورة كاملة دفعة واحدة. ضع إصبعك عند أقصى اليسار وتحرّك يمينًا، وعند كل خط رأسي اسأل سؤالين: *ما الذي تغيّر الآن؟* و*ماذا سبّب؟* قراءة مخطط التوقيت هي تتبّع السبب والنتيجة على خط زمني، لا أكثر.

**لماذا يهم ذلك ميدانيًا.** قد يحمل مؤقتان الاسم نفسه للوظيفة في كتالوجين مختلفين ويختلفان في التفاصيل — خصوصًا فيما يحدث عند قطع التغذية في منتصف الدورة، أو هل يُصفّر المؤقت أم يحتفظ بالعدّ. الوصف المكتوب يتجاوز هذه النقطة غالبًا، أما مخطط التوقيت فلا يفعل أبدًا، لأنه مضطر لرسم السلوك الحقيقي. وحين تعمل الدائرة *بشكل شبه صحيح*، تكون الإجابة غالبًا في المخطط الذي تجاوزته.',
2
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
'ON Delay — The Workhorse Function',
'تأخير التشغيل — الوظيفة الأكثر استخدامًا',
'If you learn only one timing function, learn this one. **ON delay** is the most widely used timing function in industrial panels, and it is the function fitted inside every star-delta starter you will ever commission.

**The behaviour.** Apply the supply to A1-A2. The timer starts counting immediately, but the output contact does **not** move. When the set time **t** has elapsed, the output changes state — NO closes, NC opens — and stays that way for as long as the supply remains. Remove the supply and the output returns to rest at once, and the internal count resets to zero ready for the next run.

In one sentence: **energise, wait t, then switch.**

**Where it is used.**

- **Star-delta transition.** The starter runs the motor in star, and an ON delay timer decides the instant the circuit hands over to delta. The set time is the single most important adjustment in the whole starter.
- **Sequential starting.** A plant with several motors must not start them together, because the combined inrush current would collapse the supply or trip the incomer. Give each motor its own ON delay and they start in a staggered sequence, spreading the demand.
- **Ignoring harmless transients.** A level probe or pressure switch that flickers briefly should not trip the plant. Feeding the signal through a short ON delay means the fault must persist for t before anything reacts, which filters out noise without hiding a real fault.

**The commissioning mistake to avoid.** When a star-delta transition sounds violent, technicians commonly shorten the star time, reasoning that the motor is taking too long. Usually the opposite is true: the motor has not yet reached sufficient speed in star, so the delta contactor closes while the slip is still high and draws a heavy transient. Time the motor until its sound stabilises in star, then set **t** slightly beyond that point.',
'إن لم تتعلم سوى وظيفة توقيت واحدة، فلتكن هذه. **تأخير التشغيل (ON delay)** هي أكثر وظائف التوقيت استخدامًا في لوحات التحكم الصناعية، وهي الوظيفة الموجودة داخل كل بادئ نجمة-دلتا ستقوم بتشغيله.

**السلوك.** طبّق التغذية على A1-A2. يبدأ المؤقت العدّ فورًا، لكن تلامس الخرج **لا** يتحرك. وعند انقضاء الزمن المضبوط **t** يغيّر الخرج حالته — يُغلق المفتوح طبيعيًا ويُفتح المغلق طبيعيًا — ويبقى كذلك ما دامت التغذية قائمة. وبمجرد قطع التغذية يعود الخرج إلى وضع السكون فورًا، ويُصفَّر العدّ الداخلي استعدادًا للتشغيلة التالية.

في جملة واحدة: **غذِّ، انتظر t، ثم بدّل.**

**أين تُستخدم.**

- **الانتقال من نجمة إلى دلتا.** يُشغّل البادئ المحرك على وضع النجمة، ويحدّد مؤقت تأخير التشغيل اللحظة التي تنتقل فيها الدائرة إلى دلتا. والزمن المضبوط هو أهم ضبط منفرد في البادئ كله.
- **البدء المتتابع.** المنشأة التي بها عدة محركات يجب ألا تبدأها معًا، لأن تيار البدء المجمّع سيُسقط الجهد أو يفصل القاطع الرئيسي. امنح كل محرك تأخير تشغيل خاصًا به فتبدأ المحركات بتتابع متدرّج يوزّع الطلب.
- **تجاهل العابرات غير الضارة.** حسّاس المستوى أو مفتاح الضغط الذي يرتجف للحظة يجب ألا يوقف المنشأة. تمرير الإشارة عبر تأخير تشغيل قصير يعني أن العطل يجب أن يستمر مدة t قبل أن يتفاعل أي شيء، وهذا يرشّح الضوضاء دون أن يُخفي عطلًا حقيقيًا.

**خطأ التشغيل الذي يجب تجنّبه.** حين يبدو الانتقال إلى دلتا عنيفًا، يميل الفنيون إلى تقصير زمن النجمة ظنًا أن المحرك يستغرق وقتًا طويلًا. والحقيقة عادة عكس ذلك: المحرك لم يصل بعد إلى سرعة كافية على النجمة، فيُغلق كونتاكتور الدلتا والانزلاق ما زال مرتفعًا فيسحب تيارًا عابرًا ثقيلًا. راقب المحرك حتى يستقر صوته على وضع النجمة، ثم اضبط **t** بعد هذه النقطة بقليل.',
3
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
'OFF Delay and the Auxiliary Supply Problem',
'تأخير الفصل ومشكلة التغذية المساعدة',
'**OFF delay** is the mirror image of ON delay, and it solves a completely different class of problem: keeping something running *after* the command to stop has gone.

**The behaviour.** The output switches **immediately** when the timer is triggered. It stays switched while the trigger is present. When the trigger is removed, the timer starts counting, and only after the set time **t** does the output fall back to rest.

In one sentence: **switch at once, and release t after the command disappears.**

**The engineering problem hiding inside it.** Think carefully about what this function demands. The timer must keep working *after* its command has been taken away — but if that command was also its power source, the timer has just lost the energy it needs to finish counting. This is a genuine design conflict, and manufacturers solve it two ways.

- **OFF delay with auxiliary supply.** The timer is given a permanent supply on A1-A2 that is never interrupted, and a **separate control terminal, usually B1**, receives the command. Removing the signal at B1 starts the delay while the timer stays comfortably powered from A1-A2. This is the robust and predictable method, and it is what you should specify whenever the panel design allows a permanent control supply.
- **True voltage-loss OFF delay.** The timer stores a little energy internally and continues to count for a period after its supply disappears entirely. This is convenient when no permanent supply is available, but the hold time is limited by the internal energy store, and these units are less forgiving of long delays.

Knowing which of the two you are holding is not academic. If you wire a B1-type timer expecting it to survive total supply loss, it will simply drop out the instant the panel loses control voltage, and the delay you designed will never happen.

**Where it is used.**

- **Fan run-on.** A motor or drive cabinet fan continues after shutdown to clear residual heat. Stopping the fan at the same instant as the load is how insulation gets cooked over time.
- **Staircase and corridor lighting.** The light stays on for a set period after the push button is released.
- **Post-cycle purge.** A machine finishes a cycle and an extract fan or wash continues briefly to clear the chamber.',
'**تأخير الفصل (OFF delay)** هو الصورة المرآتية لتأخير التشغيل، ويحلّ صنفًا مختلفًا تمامًا من المشكلات: إبقاء شيء يعمل *بعد* زوال أمر الإيقاف.

**السلوك.** يبدّل الخرج حالته **فورًا** عند تشغيل المؤقت، ويبقى مبدّلًا ما دامت إشارة التشغيل قائمة. وعند زوال الإشارة يبدأ المؤقت العدّ، ولا يعود الخرج إلى وضع السكون إلا بعد انقضاء الزمن المضبوط **t**.

في جملة واحدة: **بدّل فورًا، وحرّر بعد t من زوال الأمر.**

**المشكلة الهندسية الكامنة داخلها.** تأمّل ما تتطلبه هذه الوظيفة. على المؤقت أن يستمر في العمل *بعد* سحب الأمر منه — لكن إذا كان ذلك الأمر هو مصدر تغذيته أيضًا، فقد فقد للتو الطاقة التي يحتاجها لإتمام العدّ. هذا تعارض تصميمي حقيقي، وتحلّه الشركات المصنّعة بطريقتين.

- **تأخير الفصل بتغذية مساعدة.** يُمنح المؤقت تغذية دائمة على A1-A2 لا تُقطع أبدًا، ويستقبل **طرف تحكم منفصل، غالبًا B1**، إشارة الأمر. وقطع الإشارة عند B1 يبدأ التأخير بينما يظل المؤقت مغذّى بأمان من A1-A2. وهذه هي الطريقة الأمتن والأكثر قابلية للتنبؤ، وهي ما ينبغي أن تطلبه كلما سمح تصميم اللوحة بتغذية تحكم دائمة.
- **تأخير الفصل عند فقد الجهد فعليًا.** يخزّن المؤقت قدرًا صغيرًا من الطاقة داخليًا ويواصل العدّ فترة بعد اختفاء تغذيته كليًا. وهذا مريح حين لا تتوفر تغذية دائمة، لكن زمن الاحتفاظ محدود بمخزون الطاقة الداخلي، وهذه الوحدات أقل تسامحًا مع التأخيرات الطويلة.

ومعرفة أيّ النوعين بين يديك ليست مسألة نظرية. فإذا وصّلت مؤقتًا من نوع B1 وأنت تتوقع أن يصمد أمام فقد التغذية الكامل، فسيفصل فورًا لحظة فقدان اللوحة لجهد التحكم، ولن يحدث التأخير الذي صمّمته أبدًا.

**أين يُستخدم.**

- **استمرار المروحة بعد الإيقاف.** تستمر مروحة المحرك أو كابينة الدرايف بعد الإيقاف لتصريف الحرارة المتبقية. وإيقاف المروحة في اللحظة نفسها مع الحمل هو ما يُتلف العزل مع الوقت.
- **إنارة السلالم والممرات.** يبقى الضوء مضاءً فترة محددة بعد رفع اليد عن زر الضغط.
- **التطهير بعد الدورة.** تنهي الماكينة دورتها فتستمر مروحة الشفط أو الغسيل فترة قصيرة لتنظيف الحيّز.',
4
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
'Interval (One-Shot) Timing',
'توقيت النبضة (التشغيل لمرة واحدة)',
'**Interval** timing — also called one-shot or pulse timing — produces an output of an exact, fixed duration, and its defining quality is that the duration does not depend on how long the operator holds the button.

**The behaviour.** On trigger, the output switches **immediately**. It stays switched for exactly the set time **t**, then returns to rest **on its own**, whether or not the trigger is still present. A brief tap and a continuous press produce exactly the same result.

In one sentence: **one command, one measured pulse.**

**Why that independence matters.** This is the function you reach for whenever the *quantity* delivered must be consistent. If a valve is open for as long as somebody holds a button, then the amount dispensed depends on that person, on that day. Put an interval timer in the path and the dose becomes a property of the circuit rather than a property of the operator. Consistency stops being a matter of training and becomes a matter of engineering.

**There is also an inverse form.** **Interval OFF** works the other way round: the output sits switched, and the trigger produces a measured *gap* of length t before it returns. It is the less common of the two, but it appears where a process must be interrupted briefly and precisely rather than started briefly.

**Where it is used.**

- **Dosing and filling.** A valve opens for a fixed time to deliver a repeatable quantity of liquid.
- **Alarms and signals.** A buzzer or beacon sounds for a defined period on an event, then silences itself without anyone attending to it.
- **Timed wash or rinse steps.** A stage in a cycle that must last a set duration regardless of operator behaviour.
- **Lubrication pulses.** A lubricator runs for a short measured burst.

**A practical caution.** Check the datasheet for what happens if the trigger arrives *again* while the pulse is still running. Some timers ignore the new trigger and finish the original pulse; others restart the count from zero, extending the output. On a dosing application those two behaviours give different quantities in the tank, and that difference is exactly the kind of fault that gets blamed on the mechanical side for weeks.',
'**توقيت النبضة (Interval)** — ويُسمى أيضًا التشغيل لمرة واحدة أو التوقيت النبضي — ينتج خرجًا بمدة محددة ثابتة، وخاصيته المميّزة أن هذه المدة لا تعتمد على المدة التي يضغط فيها المشغّل على الزر.

**السلوك.** عند التشغيل يبدّل الخرج حالته **فورًا**، ويبقى مبدّلًا مدة الزمن المضبوط **t** بالضبط، ثم يعود إلى وضع السكون **من تلقاء نفسه**، سواء بقيت إشارة التشغيل أم لا. فالنقرة القصيرة والضغط المستمر يعطيان النتيجة نفسها تمامًا.

في جملة واحدة: **أمر واحد، نبضة واحدة مقيسة.**

**لماذا يهم هذا الاستقلال.** هذه هي الوظيفة التي تلجأ إليها كلما وجب أن تكون *الكمية* المنصرفة ثابتة. فإذا ظل الصمام مفتوحًا طالما ضغط أحدهم على الزر، فإن الكمية المنصرفة تعتمد على ذلك الشخص في ذلك اليوم. وبإدخال مؤقت نبضة في المسار تصبح الجرعة خاصية من خصائص الدائرة لا خاصية من خصائص المشغّل، فتتحول الثباتية من مسألة تدريب إلى مسألة هندسة.

**وله صورة عكسية أيضًا.** **نبضة الفصل (Interval OFF)** تعمل بالاتجاه المعاكس: يبقى الخرج مبدّلًا، وتُنتج إشارة التشغيل *فجوة* مقيسة بطول t قبل أن يعود. وهي الأقل شيوعًا بين الاثنتين، لكنها تظهر حين يجب مقاطعة عملية بدقة لفترة وجيزة بدلًا من بدئها لفترة وجيزة.

**أين تُستخدم.**

- **الجرعات والتعبئة.** يُفتح الصمام مدة ثابتة لتسليم كمية سائل قابلة للتكرار.
- **الإنذارات والإشارات.** يعمل الجرس أو الكشّاف مدة محددة عند وقوع حدث، ثم يُسكت نفسه دون تدخل أحد.
- **خطوات الغسيل أو الشطف الموقوتة.** مرحلة في دورة يجب أن تستمر مدة محددة بغض النظر عن سلوك المشغّل.
- **نبضات التزييت.** تعمل وحدة التزييت دفقة قصيرة مقيسة.

**تنبيه عملي.** راجع الكتالوج لمعرفة ما يحدث إذا وصلت إشارة التشغيل *مرة أخرى* أثناء سريان النبضة. بعض المؤقتات تتجاهل الإشارة الجديدة وتُكمل النبضة الأصلية، وبعضها يعيد العدّ من الصفر فيُطيل الخرج. وفي تطبيق جرعات يعطي هذان السلوكان كميتين مختلفتين في الخزان، وهذا الفرق تحديدًا هو نوع العطل الذي يُلقى باللوم فيه على الجانب الميكانيكي لأسابيع.',
5
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
'Repeat Cycle (Flasher) Timing',
'توقيت الدورة المتكررة (الفلاشر)',
'**Repeat cycle** timing — commonly called flasher or cyclic timing — is the only standard function that runs continuously on its own. Energise it and it will switch on and off, over and over, for as long as it has power. Every other function in this module performs its action once and then waits for a new command.

**The two starting variants.** Catalogues list two versions, and the difference is only what the cycle does first.

- **Repeat cycle starting with OFF** — the output stays at rest for the first period, then begins alternating. Use this when the plant should have a quiet moment before the first pulse arrives.
- **Repeat cycle starting with ON** — the output switches immediately on energisation, then alternates. Use this when the first action must happen without delay.

**Equal versus independent times.** Simpler flashers use one setting for both halves, giving a symmetrical cycle of equal on and off periods. Better units provide **t1** for the on period and **t2** for the off period independently, and that separation is usually what the process actually needs. An intermittent agitator may need to run for ten seconds and rest for five minutes — a symmetrical timer cannot express that at all.

**Where it is used.**

- **Warning beacons.** A flashing lamp draws attention far more effectively than a steady one, which is why hazard indication is almost always flashed.
- **Intermittent agitation.** A mixer stirs periodically to keep a product in suspension without running continuously, saving both energy and wear.
- **Periodic dosing or flushing.** A pump injects or flushes on a fixed rhythm through the day.
- **Cyclic drainage.** A pump clears an accumulating sump at regular intervals rather than waiting for a level switch.

**What to check on site.** Two things catch people out. First, confirm whether the unit resets to the start of the cycle when supply is lost, or resumes mid-cycle — on a dosing application that determines whether an interrupted shift under-doses or over-doses. Second, remember that the contacts are operating continuously, perhaps thousands of times a day. Electrical life is a finite number of operations, so a flasher driving a contactor coil day and night will reach the end of its rated life far sooner than an ON delay timer that operates once per shift. Specify accordingly, and treat a flasher as a wearing part.',
'**الدورة المتكررة (Repeat cycle)** — وتُسمى عادة الفلاشر أو التوقيت الدوري — هي الوظيفة القياسية الوحيدة التي تعمل باستمرار من تلقاء نفسها. غذِّها فتقوم بالتشغيل والفصل مرارًا وتكرارًا ما دامت التغذية قائمة. أما كل وظيفة أخرى في هذه الوحدة فتؤدي عملها مرة واحدة ثم تنتظر أمرًا جديدًا.

**نوعا البداية.** تُدرج الكتالوجات نسختين، والفرق بينهما هو ما تفعله الدورة أولًا فقط.

- **دورة متكررة تبدأ بالفصل** — يبقى الخرج في وضع السكون في الفترة الأولى ثم يبدأ التناوب. استخدمها حين ينبغي أن تحظى المنشأة بلحظة هدوء قبل وصول أول نبضة.
- **دورة متكررة تبدأ بالتشغيل** — يبدّل الخرج حالته فور التغذية ثم يتناوب. استخدمها حين يجب أن يقع الفعل الأول دون تأخير.

**أزمنة متساوية أم مستقلة.** الفلاشرات الأبسط تستخدم ضبطًا واحدًا لكلا النصفين، فتعطي دورة متماثلة بفترتي تشغيل وفصل متساويتين. أما الوحدات الأفضل فتوفّر **t1** لفترة التشغيل و**t2** لفترة الفصل بشكل مستقل، وهذا الفصل هو ما تحتاجه العملية فعليًا في الغالب. فالخلّاط المتقطع قد يحتاج أن يعمل عشر ثوانٍ ويرتاح خمس دقائق — والمؤقت المتماثل لا يستطيع التعبير عن ذلك إطلاقًا.

**أين تُستخدم.**

- **كشّافات التحذير.** المصباح الوامض يلفت الانتباه أكثر بكثير من الثابت، ولهذا يكون التنبيه على الخطر وامضًا دائمًا تقريبًا.
- **التقليب المتقطع.** يقلّب الخلّاط دوريًا لإبقاء المنتج معلّقًا دون تشغيل مستمر، فيوفّر الطاقة والتآكل معًا.
- **الجرعات أو الغسيل الدوري.** تحقن المضخة أو تغسل بإيقاع ثابت على مدار اليوم.
- **الصرف الدوري.** تفرّغ المضخة بئر تجميع متراكمًا على فترات منتظمة بدلًا من انتظار مفتاح مستوى.

**ما يجب فحصه في الموقع.** أمران يوقعان الناس في الخطأ. الأول: تأكّد هل تعود الوحدة إلى بداية الدورة عند فقد التغذية أم تستأنف من منتصفها — ففي تطبيق جرعات يحدد ذلك ما إذا كانت الوردية المنقطعة ستُنقص الجرعة أم تزيدها. والثاني: تذكّر أن التلامسات تعمل باستمرار، ربما آلاف المرات يوميًا. والعمر الكهربائي عدد محدود من العمليات، لذا فإن فلاشرًا يُشغّل ملف كونتاكتور ليلًا ونهارًا سيبلغ نهاية عمره المقنّن أسرع بكثير من مؤقت تأخير تشغيل يعمل مرة كل وردية. حدّد المواصفات على هذا الأساس، وتعامل مع الفلاشر كقطعة استهلاكية.',
6
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
'Setting a Multi-Function Timer in Practice',
'ضبط المؤقت متعدد الوظائف عمليًا',
'A modern multi-function timer replaces a drawer full of single-purpose units, but only if you can configure it correctly. Almost every unit gives you three independent settings, and confusing them is the most common reason a correctly wired timer behaves wrongly.

**1. The function selector.** A small rotary switch chooses which of the timing functions the unit performs, identified by codes or miniature timing diagrams printed on the body. Setting this wrongly does not produce a subtle error — the timer will do something entirely different from what the drawing intended.

**2. The time range.** Timers cover an enormous span, from fractions of a second to many hours, and no single scale can resolve that. The range is therefore selected separately, either by a second rotary switch marked in units — seconds, minutes, hours — or by a **multiplier** such as **x1, x2, x4** or similar. The multiplier scales whatever the main dial reads.

**3. The setting dial.** A potentiometer marked with a numeric scale. **The number on this dial is not the time.** The actual delay is the dial reading multiplied by the selected range. A dial at 3 with the range on x4 does not give 3 seconds and does not give 4 — it gives 12. This single misunderstanding causes more commissioning confusion than any other aspect of timers.

**How to set one methodically.**

1. Decide the function you need *before* touching the unit, from the circuit drawing, not from memory.
2. Select the function on the rotary switch.
3. Choose the range that places your target time comfortably inside the dial scale, ideally near mid-scale where the setting is least sensitive to a small knock.
4. Calculate the dial position: required time divided by the multiplier.
5. Energise and **measure the result with a watch**. Do not trust the printed scale on a control panel that matters. These dials are calibrated to a tolerance, they drift with temperature and age, and on an aged panel the legend is often worn or the previous engineer changed the range without telling anyone.

**Accuracy and repeatability.** Two specifications are quoted, and they answer different questions. **Accuracy** is how close the delay is to the number you dialled. **Repeatability** is how consistently the unit reproduces the same delay on every cycle. For most sequencing work, repeatability matters far more — a star-delta transition that is consistently 6.2 seconds when you asked for 6 is entirely acceptable, whereas one that wanders between 4 and 9 seconds is a fault waiting to happen.',
'المؤقت الحديث متعدد الوظائف يحلّ محلّ درج كامل من الوحدات أحادية الغرض، لكن بشرط أن تُحسن ضبطه. فمعظم الوحدات تمنحك ثلاثة ضبطات مستقلة، والخلط بينها هو السبب الأشيع في أن يعمل مؤقت موصّل بشكل صحيح بطريقة خاطئة.

**١. مفتاح اختيار الوظيفة.** مفتاح دوّار صغير يختار أي وظائف التوقيت تؤديها الوحدة، ويُعرَّف برموز أو مخططات توقيت مصغّرة مطبوعة على الجسم. وضبطه خطأً لا ينتج خطأً طفيفًا — بل سيفعل المؤقت شيئًا مختلفًا كليًا عمّا قصده المخطط.

**٢. مدى الزمن.** تغطي المؤقتات مدى هائلًا، من أجزاء الثانية إلى ساعات عديدة، ولا يمكن لتدريج واحد أن يميّز ذلك. لذا يُختار المدى بشكل منفصل، إما بمفتاح دوّار ثانٍ معلَّم بالوحدات — ثوانٍ، دقائق، ساعات — أو بـ**مُضاعِف** مثل **x1 وx2 وx4** أو ما شابه. والمضاعِف يقيس ما يشير إليه القرص الرئيسي.

**٣. قرص الضبط.** مقاومة متغيّرة معلَّمة بتدريج رقمي. **والرقم على هذا القرص ليس هو الزمن.** فالتأخير الفعلي هو قراءة القرص مضروبة في المدى المختار. قرص على 3 والمدى على x4 لا يعطي 3 ثوانٍ ولا يعطي 4 — بل يعطي 12. وهذا الالتباس المنفرد يسبّب من الارتباك في التشغيل أكثر من أي جانب آخر في المؤقتات.

**كيف تضبطه بمنهجية.**

١. حدّد الوظيفة التي تحتاجها *قبل* أن تلمس الوحدة، من مخطط الدائرة لا من الذاكرة.
٢. اختر الوظيفة على المفتاح الدوّار.
٣. اختر المدى الذي يضع زمنك المطلوب داخل تدريج القرص بارتياح، ويُفضَّل قرب منتصف التدريج حيث يكون الضبط أقل حساسية لأي اهتزاز بسيط.
٤. احسب موضع القرص: الزمن المطلوب مقسومًا على المضاعِف.
٥. غذِّ الدائرة و**قِس النتيجة بالساعة**. لا تثق بالتدريج المطبوع في لوحة تحكم لها أهمية. فهذه الأقراص معايَرة ضمن حدود تسامح، وتنحرف مع الحرارة والعمر، وفي لوحة قديمة غالبًا ما يكون التعليم مطموسًا أو يكون المهندس السابق قد غيّر المدى دون أن يخبر أحدًا.

**الدقة وقابلية التكرار.** تُذكر مواصفتان، وكل منهما تجيب عن سؤال مختلف. **الدقة** هي مدى قرب التأخير من الرقم الذي ضبطته. و**قابلية التكرار** هي مدى ثبات الوحدة في إعادة إنتاج الزمن نفسه في كل دورة. وفي معظم أعمال التتابع تكون قابلية التكرار أهم بكثير — فانتقال نجمة-دلتا يستغرق 6.2 ثانية باستمرار بينما طلبت 6 ثوانٍ أمر مقبول تمامًا، أما الذي يتأرجح بين 4 و9 ثوانٍ فهو عطل ينتظر الوقوع.',
7
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
'Worked Application: A Two-Valve Mixing Sequence',
'تطبيق عملي: تتابع خلط بصمامين',
'Individual functions make sense in isolation; the skill is combining them. Here is a complete worked sequence of the kind you will meet in a small process plant, built entirely from functions covered in this module.

**The requirement.** An operator presses START. Component A must flow into the vessel for 30 seconds. Component B must then flow for 15 seconds. Only when both are in must the agitator run, and it must stir intermittently — 10 seconds running, 20 seconds resting — for a total mixing period of 5 minutes. Then everything must stop and wait for the next START.

**Working out the timing chain.** Read the specification again and notice that each step is triggered by the *completion* of the one before it. That observation is the whole design.

- **Valve A** needs an output that begins at once and lasts exactly 30 seconds regardless of the button — an **interval** function, triggered by the start latch.
- **Valve B** must not open until A has finished, then run for exactly 15 seconds. That is an **ON delay** of 30 seconds to establish *when* it starts, driving an **interval** of 15 seconds to establish *how long* it runs. Two functions, two separate jobs.
- **The agitator** must begin after both valves are done, so it is gated by an **ON delay** of 45 seconds — the sum of the two fill steps. Its intermittent stirring is a **repeat cycle** with t1 of 10 seconds and t2 of 20 seconds, which is exactly why an independent-time flasher was specified rather than a symmetrical one.
- **The overall cycle** is ended by a master **interval** of 5 minutes 45 seconds, or by an ON delay that drops the start latch. Either approach works; the second is usually tidier in a relay panel.

**The lesson inside the example.** Notice the recurring pattern: **ON delay establishes when something starts, interval establishes how long it lasts.** Almost every sequence you will ever build is assembled from those two ideas stacked in various combinations. Once you see it, sequencing stops being intimidating.

**Practical notes for a real panel.**

- Latch the START command through a contactor or relay with its own holding contact. Timers should be triggered by that latch, never directly by a push button, or the sequence dies the instant the operator releases the button.
- Wire the STOP and any emergency stop to break the latch, so that dropping the latch collapses every timer at once. A sequence that can only be stopped by waiting for it to finish is a safety problem, not a design choice.
- Fit indicator lamps on each step. When the sequence misbehaves, lamps tell you *which* step failed in seconds — without them you are measuring terminals with a meter while the plant waits.
- Write the set times on a label inside the panel door. The next technician, possibly you in two years, will need them.',
'الوظائف المنفردة مفهومة بمعزل عن غيرها؛ أما المهارة فهي في تركيبها. وهذا تتابع عملي كامل من النوع الذي ستقابله في منشأة إنتاج صغيرة، مبني بالكامل من وظائف غطّتها هذه الوحدة.

**المطلوب.** يضغط المشغّل زر البدء. يجب أن يتدفق المكوّن A إلى الوعاء لمدة 30 ثانية. ثم يتدفق المكوّن B لمدة 15 ثانية. وفقط بعد دخول الاثنين يعمل الخلّاط، ويجب أن يقلّب بشكل متقطع — 10 ثوانٍ تشغيل و20 ثانية راحة — لفترة خلط إجمالية 5 دقائق. ثم يتوقف كل شيء وينتظر أمر البدء التالي.

**استنتاج سلسلة التوقيت.** اقرأ المواصفة مرة أخرى ولاحظ أن كل خطوة تُشغَّل بـ*اكتمال* الخطوة التي قبلها. هذه الملاحظة هي التصميم كله.

- **الصمام A** يحتاج خرجًا يبدأ فورًا ويدوم 30 ثانية بالضبط بغض النظر عن الزر — أي وظيفة **نبضة (interval)** تُشغَّل من مزلاج البدء.
- **الصمام B** يجب ألا يُفتح حتى ينتهي A، ثم يعمل 15 ثانية بالضبط. وهذا **تأخير تشغيل** 30 ثانية يحدّد *متى* يبدأ، يقود **نبضة** 15 ثانية تحدّد *كم* يدوم. وظيفتان، ومهمتان منفصلتان.
- **الخلّاط** يجب أن يبدأ بعد انتهاء الصمامين، فيُقيَّد بـ**تأخير تشغيل** 45 ثانية — مجموع خطوتي التعبئة. أما تقليبه المتقطع فهو **دورة متكررة** بزمن t1 يساوي 10 ثوانٍ وt2 يساوي 20 ثانية، وهذا بالضبط سبب اشتراط فلاشر بزمنين مستقلين لا متماثلين.
- **الدورة الكلية** تنتهي بـ**نبضة** رئيسية مدتها 5 دقائق و45 ثانية، أو بتأخير تشغيل يُسقط مزلاج البدء. وكلا الأسلوبين يعمل، والثاني أنظف عادة في لوحة مرحّلات.

**الدرس داخل المثال.** لاحظ النمط المتكرر: **تأخير التشغيل يحدد متى يبدأ الشيء، والنبضة تحدد كم يدوم.** وكل تتابع ستبنيه تقريبًا مركّب من هاتين الفكرتين متراصّتين بتوليفات مختلفة. وبمجرد أن ترى ذلك يتوقف التتابع عن كونه مخيفًا.

**ملاحظات عملية للوحة حقيقية.**

- ثبّت أمر البدء عبر كونتاكتور أو مرحّل له تلامس تثبيت خاص. ويجب تشغيل المؤقتات من هذا المزلاج لا من زر الضغط مباشرة، وإلا مات التتابع لحظة رفع المشغّل يده عن الزر.
- وصّل زر الإيقاف وأي إيقاف طوارئ لقطع المزلاج، بحيث يُسقط انهيارُ المزلاج كلَّ المؤقتات دفعة واحدة. فالتتابع الذي لا يمكن إيقافه إلا بانتظار انتهائه مشكلة سلامة لا خيار تصميم.
- ركّب لمبات بيان لكل خطوة. فحين يسيء التتابع التصرف تخبرك اللمبات *أي* خطوة فشلت في ثوانٍ — وبدونها ستقيس الأطراف بالأفوميتر بينما المنشأة متوقفة.
- اكتب الأزمنة المضبوطة على ملصق داخل باب اللوحة. فالفني التالي، وقد يكون أنت بعد عامين، سيحتاجها.',
8
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
'From Relay Timer to Smart Scheduling',
'من مؤقت المرحّل إلى الجدولة الذكية',
'Everything in this module was engineered decades before anyone used the phrase *smart home*, and understanding that lineage is what separates a control engineer from an app user. A smart scheduling feature is not a new invention — it is a timing function that moved from hardware into software.

**The direct equivalents.**

| Classical function | Modern smart equivalent |
| --- | --- |
| ON delay | Countdown or *delay start* in an app |
| OFF delay | Auto-off after a set period, run-on timers |
| Interval (one-shot) | Timed action — run for exactly N minutes |
| Repeat cycle | Recurring schedule or loop timer |
| Astronomical or photocell switching | Sunrise/sunset automation using location |
| Multiple timers chained | Multi-step scene or automation routine |

**What genuinely improved.** Honesty here is more useful than enthusiasm. Smart control is better in ways that matter: schedules can follow sunrise and sunset by date and location rather than a fixed clock time that drifts out of season; times are set numerically in an app rather than by a potentiometer with a printed scale; a schedule can be changed remotely without opening a panel; and the system can log what happened and notify the user when it did not. None of those were available to a relay timer at any price.

**What genuinely got worse.** A mechanical or solid-state timer in a panel depends on nothing but its own supply. A cloud schedule can depend on Wi-Fi, on an internet connection, on a vendor service, and sometimes on an account remaining active. Introducing those dependencies into a process that must not stop is a real engineering decision, not a detail. This is why a serious installer checks whether a smart device executes its schedule **locally** on the device, or whether it needs the cloud to fire — because that single answer determines what happens to the client during an internet outage.

**Where the relay is still the right answer.** State this clearly to customers rather than overselling:

- **Safety functions.** Two-hand controls, interlocks and emergency stops belong in hardwired logic or a rated safety device. They must not depend on an app.
- **Processes where a missed cycle is expensive or dangerous.** If a pump must alternate to avoid seizure, or a dosing step must never be skipped, a local timer with no network dependency is the more defensible design.
- **High-cycle duty.** A function operating thousands of times daily is better served by a component specified for that duty.

**The professional position.** The strongest technician in this market is not the one who replaces every relay with a smart switch, nor the one who refuses to fit smart devices at all. It is the one who can look at a panel and say precisely which functions benefit from scheduling, visibility and remote control, and which must stay in hardwired logic — and can explain the reasoning to a client in one clear sentence. That judgement is what you are being trained for, and it is what the customer is actually paying for.',
'كل ما في هذه الوحدة هُندس قبل عقود من استخدام أحد لعبارة *المنزل الذكي*، وفهم هذا النسب هو ما يفصل مهندس التحكم عن مستخدم التطبيق. فخاصية الجدولة الذكية ليست اختراعًا جديدًا — بل هي وظيفة توقيت انتقلت من العتاد إلى البرمجيات.

**المكافئات المباشرة.**

| الوظيفة الكلاسيكية | المكافئ الذكي الحديث |
| --- | --- |
| تأخير التشغيل | العدّ التنازلي أو *بدء مؤجل* في التطبيق |
| تأخير الفصل | الإطفاء التلقائي بعد مدة، ومؤقتات الاستمرار |
| النبضة (لمرة واحدة) | إجراء موقوت — التشغيل لمدة N دقيقة بالضبط |
| الدورة المتكررة | جدول متكرر أو مؤقت دوري |
| التبديل الفلكي أو بالخلية الضوئية | أتمتة الشروق والغروب حسب الموقع |
| مؤقتات متسلسلة متعددة | مشهد أو روتين أتمتة متعدد الخطوات |

**ما تحسّن فعلًا.** الصراحة هنا أنفع من الحماس. التحكم الذكي أفضل في جوانب مهمة: يمكن للجداول أن تتبع الشروق والغروب حسب التاريخ والموقع بدلًا من ساعة ثابتة تنحرف مع تغيّر الفصول؛ وتُضبط الأزمنة رقميًا في تطبيق بدلًا من مقاومة متغيّرة بتدريج مطبوع؛ ويمكن تغيير الجدول عن بُعد دون فتح اللوحة؛ ويستطيع النظام تسجيل ما حدث وإخطار المستخدم حين لا يحدث. ولم يكن أيٌّ من ذلك متاحًا لمؤقت مرحّل بأي ثمن.

**ما ساء فعلًا.** المؤقت الميكانيكي أو الإلكتروني داخل اللوحة لا يعتمد على شيء سوى تغذيته. أما الجدول السحابي فقد يعتمد على الواي فاي، وعلى اتصال الإنترنت، وعلى خدمة الشركة المصنّعة، وأحيانًا على بقاء الحساب فعّالًا. وإدخال هذه التبعيات في عملية يجب ألا تتوقف قرار هندسي حقيقي لا تفصيلة جانبية. ولهذا يتحقق المركّب الجاد مما إذا كان الجهاز الذكي ينفّذ جدوله **محليًا** على الجهاز، أم يحتاج السحابة ليعمل — لأن هذه الإجابة وحدها تحدد ما سيحدث للعميل أثناء انقطاع الإنترنت.

**أين يظل المرحّل هو الإجابة الصحيحة.** اذكر ذلك بوضوح للعملاء بدلًا من المبالغة في البيع:

- **وظائف السلامة.** التحكم باليدين والتعاشقات وأزرار الطوارئ مكانها المنطق السلكي أو جهاز سلامة مقنّن. ويجب ألا تعتمد على تطبيق.
- **العمليات التي يكون فيها تفويت دورة مكلفًا أو خطرًا.** إذا وجب تناوب المضخات لتفادي التآكل، أو وجب ألا تُتخطى خطوة جرعات أبدًا، فإن مؤقتًا محليًا بلا تبعية شبكية هو التصميم الأوجه للدفاع عنه.
- **الخدمة عالية التكرار.** الوظيفة التي تعمل آلاف المرات يوميًا يخدمها عنصر مقنّن لهذه الخدمة بشكل أفضل.

**الموقف المهني.** أقوى فني في هذا السوق ليس من يستبدل كل مرحّل بمفتاح ذكي، ولا من يرفض تركيب الأجهزة الذكية أصلًا. بل هو من ينظر إلى لوحة فيحدد بدقة أي الوظائف تستفيد من الجدولة والرؤية والتحكم عن بُعد، وأيها يجب أن يبقى في المنطق السلكي — ويستطيع شرح السبب للعميل في جملة واحدة واضحة. هذا الحكم هو ما تُدرَّب من أجله، وهو ما يدفع العميل ثمنه فعليًا.',
9
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
'Selecting, Wiring and Fault-Finding Timers',
'اختيار المؤقتات وتوصيلها واكتشاف أعطالها',
'This closing lesson is the one to keep on your phone. It is the checklist for putting a timer into service and for diagnosing one that is not behaving.

**Selection checklist.**

1. **Function** — exactly which timing function the drawing requires.
2. **Coil voltage** — must match the control circuit, and note whether AC or DC.
3. **Time range** — your required delay should fall near the middle of the range, not at the extreme end where resolution is poor.
4. **Contact rating** — sufficient for the contactor coil it will drive, with AC and DC ratings read separately since DC breaking capacity is far lower.
5. **Number of contacts** — one changeover or two, and whether any must be instantaneous.
6. **Mounting** — DIN rail, or a plug-in base which is faster to replace during a breakdown.

**Wiring rules that prevent most faults.**

- Confirm A1 and A2 before energising. A timer fed the wrong voltage may fail silently rather than dramatically.
- Trigger from a latched contact, not straight from a push button.
- Never switch load current through timer contacts — switch a contactor coil.
- Fit a plug-in base on any panel that matters. Swapping a suspect timer in ninety seconds is worth the small extra cost the first time it happens.
- Label the set time and function inside the panel door.

**Fault-finding: a disciplined order.** Work from the simplest possibility to the most complex, and resist the urge to condemn the timer first.

1. **Is the supply present at A1-A2?** Measure it. Do not infer it from a lamp.
2. **Is the trigger arriving?** On a B1-type unit, confirm the control signal is actually present at the terminal.
3. **Is the function selector on the right setting?** Vibration and previous engineers both move these.
4. **Is the range multiplier what you assume?** This is the classic. The dial reads 3, the range is on x4, everybody expects 3 seconds and the panel waits 12.
5. **Are you monitoring a timed contact or an instantaneous one?** Confirm against the terminal numbering before concluding the timer never operated.
6. **Does the output actually change?** Meter across the contact. If the supply, trigger and settings are all correct and the contact still refuses to change state, now you may condemn the timer.

**Three field symptoms and their usual causes.**

- **Delay is roughly right but not exact** — normal tolerance, or a drifting dial. Measure and re-trim rather than replacing the unit.
- **Delay is wrong by a clean factor of two or four** — almost always the range multiplier, not a fault.
- **Timer works when cold and misbehaves when the panel is hot** — thermal drift or a failing electrolytic component. This one genuinely is the timer, and it will get worse.',
'هذا الدرس الختامي هو ما ينبغي أن تحتفظ به على هاتفك. إنه قائمة التحقق لإدخال مؤقت إلى الخدمة، ولتشخيص مؤقت لا يعمل كما ينبغي.

**قائمة الاختيار.**

١. **الوظيفة** — أي وظيفة توقيت يتطلبها المخطط بالضبط.
٢. **جهد الملف** — يجب أن يطابق دائرة التحكم، مع ملاحظة إن كان متردّدًا أم مستمرًا.
٣. **مدى الزمن** — ينبغي أن يقع التأخير المطلوب قرب منتصف المدى، لا عند طرفه الأقصى حيث تضعف الدقة.
٤. **تقنين التلامس** — كافٍ لملف الكونتاكتور الذي سيشغّله، مع قراءة تقنين التيار المتردد والمستمر كلٍّ على حدة لأن قدرة القطع للمستمر أقل بكثير.
٥. **عدد التلامسات** — تلامس تحويلي واحد أم اثنان، وهل يجب أن يكون أي منها لحظيًا.
٦. **طريقة التثبيت** — على قضيب DIN، أم قاعدة قابلة للفصل وهي أسرع في الاستبدال أثناء الأعطال.

**قواعد توصيل تمنع معظم الأعطال.**

- تأكّد من A1 وA2 قبل التغذية. فالمؤقت الذي يُغذّى بجهد خاطئ قد يتلف بصمت لا بشكل درامي.
- شغّله من تلامس مثبَّت، لا من زر ضغط مباشرة.
- لا تمرّر تيار الحمل عبر تلامسات المؤقت أبدًا — شغّل ملف كونتاكتور.
- ركّب قاعدة قابلة للفصل في أي لوحة لها أهمية. فاستبدال مؤقت مشكوك فيه في تسعين ثانية يستحق الفارق البسيط في التكلفة من أول مرة تحتاجه.
- علّم الزمن المضبوط والوظيفة داخل باب اللوحة.

**اكتشاف الأعطال: ترتيب منضبط.** اعمل من الاحتمال الأبسط إلى الأعقد، وقاوم الرغبة في إدانة المؤقت أولًا.

١. **هل التغذية موجودة على A1-A2؟** قِسها. ولا تستنتجها من لمبة.
٢. **هل تصل إشارة التشغيل؟** في وحدة من نوع B1، تأكّد أن إشارة التحكم موجودة فعلًا على الطرف.
٣. **هل مفتاح الوظيفة على الضبط الصحيح؟** فالاهتزاز والمهندسون السابقون كلاهما يحرّك هذه المفاتيح.
٤. **هل مضاعِف المدى هو ما تفترضه؟** هذه هي الكلاسيكية. القرص يقرأ 3، والمدى على x4، والجميع يتوقع 3 ثوانٍ واللوحة تنتظر 12.
٥. **هل تراقب تلامسًا مؤقتًا أم لحظيًا؟** تأكّد من ترقيم الأطراف قبل أن تستنتج أن المؤقت لم يعمل إطلاقًا.
٦. **هل يتغيّر الخرج فعلًا؟** قِس على طرفي التلامس. فإذا كانت التغذية والإشارة والضبط كلها سليمة وما زال التلامس يرفض تغيير حالته، عندها يجوز لك إدانة المؤقت.

**ثلاثة أعراض ميدانية وأسبابها المعتادة.**

- **التأخير قريب من الصحيح لكنه غير مضبوط** — تسامح طبيعي، أو انحراف في القرص. قِس وأعِد الضبط بدلًا من استبدال الوحدة.
- **التأخير خاطئ بمعامل نظيف يساوي اثنين أو أربعة** — هو مضاعِف المدى دائمًا تقريبًا، وليس عطلًا.
- **المؤقت يعمل باردًا ويسيء التصرف حين تسخن اللوحة** — انحراف حراري أو مكوّن إلكتروليتي في طريقه للتلف. وهذه حالة يكون فيها العطل في المؤقت فعلًا، وستزداد سوءًا.',
10
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

-- 4. Quizzes ---------------------------------------------------------------

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'bronze', 'Timers — Bronze: Functions & Terminals', 'المؤقتات — برونزي: الوظائف والأطراف', 80
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'silver', 'Timers — Silver: Applied Selection & Setting', 'المؤقتات — فضي: الاختيار والضبط التطبيقي', 80
FROM public.modules WHERE slug = 'finix-timers-timing-functions';

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'gold', 'Timers — Gold: Sequence Design & Fault Diagnosis', 'المؤقتات — ذهبي: تصميم التتابع وتشخيص الأعطال', 80
FROM public.modules WHERE slug = 'finix-timers-timing-functions';
