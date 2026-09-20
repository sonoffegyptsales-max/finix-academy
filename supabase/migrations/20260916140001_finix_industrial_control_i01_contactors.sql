-- Module I01: Contactors & Control Logic
--
-- ORIGINAL CONTENT. Topic sequence follows standard industrial-control
-- curricula; all explanations and worked examples written for Finix.

INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES (
  'finix-contactors-control-logic',
  'I01',
  'finix-industrial-control',
  'Contactors & Control Logic',
  'الكونتاكتورات ومنطق التحكم',
  $s$The building block of every control panel: how a contactor works, how to identify its terminals, the latch and interlock circuits that make it useful, and why the power and control circuits are kept separate.$s$,
  $s$اللبنة الأساسية لكل لوحة تحكم: كيف يعمل الكونتاكتور، كيف تحدد أطرافه، دوائر التثبيت والتعشيق التي تجعله مفيدًا، ولماذا تُفصل دائرة القوى عن دائرة التحكم.$s$,
  NULL,
  28
)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$Inside a Contactor$t$,
$t$داخل الكونتاكتور$t$,
$c$A contactor is an electrically operated switch. A small current through its coil closes large contacts that carry the load current. That separation — small current controlling large current — is the foundation of every control panel ever built.

**The physical parts.** Energising the coil creates a magnetic field that pulls a **moving core** toward a **fixed core**. The moving core carries the contacts, so they close with it. Remove the coil supply and a **return spring** pushes everything back, opening the contacts. Understanding this mechanism explains most contactor faults: anything that stops the cores meeting fully, or stops the spring returning them, produces a specific and recognisable symptom.

**The shading ring, and the hum that tells you it is gone.** On an AC contactor the magnetic field follows the supply waveform, passing through zero twice per cycle. At those instants the pull disappears and the spring starts to reopen the contacts — which would produce violent buzzing and rapid contact destruction. A **shading ring**, a closed copper loop set into the face of the core, carries an induced current that sustains a magnetic field through those zero crossings and holds the core closed.

A contactor that buzzes loudly usually has a damaged shading ring, dirt between the core faces preventing full closure, or a coil voltage too low to pull in properly. A buzzing contactor is not a cosmetic problem — it is a contactor that is not making proper contact, heating up, and on its way to welding or failing.

**Main contacts versus auxiliary contacts.** The distinction matters constantly:
- **Main contacts** carry the load current to the motor or other load. They are physically substantial, usually three of them for a three-phase load, and normally open.
- **Auxiliary contacts** are small, carry only control-circuit current, and exist purely so the control logic can know what the contactor is doing. They come as normally-open and normally-closed types.

The classic beginner's error is running load current through an auxiliary contact. It will pass briefly and then fail, sometimes spectacularly.

**Reading the terminal markings.** Control gear numbering is standardised enough that you can wire an unfamiliar contactor correctly from the markings alone:
- **Main contacts** are marked either 1/2, 3/4, 5/6, or with supply-side and load-side designations such as L1/L2/L3 in and T1/T2/T3 out, or R/S/T in and U/V/W out. The pairing always indicates line in and load out for the same pole.
- **Coil terminals** are A1 and A2.
- **Auxiliary contacts** carry two-digit numbers where the second digit states the function: a contact ending in 3 and 4 is normally open, and one ending in 1 and 2 is normally closed. The first digit simply numbers which auxiliary block it is.

Once you know that rule you can look at an unlabelled auxiliary block and state what it does. It is worth memorising because it removes the need to guess or to meter every terminal on an unfamiliar panel.

**Coil voltage is a specification, not a detail.** Contactor coils are made for specific voltages — commonly 230V AC or 24V DC in building work, sometimes 110V AC on sites where a lower control voltage is required for safety. Fitting a coil rated for a different voltage than the control circuit supplies is a common and expensive mistake: too low and the contactor chatters or fails to pull in fully; too high and the coil overheats and burns out. Always check the coil marking against the control supply before fitting a replacement, because externally identical contactors may carry entirely different coils.

**AC and DC coils behave differently on inrush.** An AC coil draws a substantially higher current at the instant of energisation than it does once the core has closed, because the closing core changes the magnetic circuit. This matters when sizing the control transformer or the contacts that switch the coil — the switching element must handle the inrush, not just the holding current.

**Contactor duty ratings.** Contactors are rated by utilisation category, which describes the kind of load rather than just the amps. A contactor switching a resistive heating load has an easier life than one switching a motor, which draws several times its running current at start and produces a significant arc on break. Selecting purely on running current, without regard to what kind of load it is, is how installers end up with welded contacts a few months after commissioning.$c$,
$c$الكونتاكتور مفتاح يعمل كهربائيًا. تيار صغير عبر ملفه يغلق تلامسات كبيرة تحمل تيار الحمل. وهذا الفصل — تيار صغير يتحكم بتيار كبير — هو أساس كل لوحة تحكم بُنيت يومًا.

**الأجزاء المادية.** تغذية الملف تولّد مجالًا مغناطيسيًا يجذب **القلب المتحرك** نحو **القلب الثابت**. والقلب المتحرك يحمل التلامسات فتُغلق معه. اقطع تغذية الملف فيدفع **نابض الإرجاع** كل شيء للخلف فتُفتح التلامسات. وفهم هذه الآلية يفسر أغلب أعطال الكونتاكتورات: فأي شيء يمنع القلبين من الالتقاء التام، أو يمنع النابض من إرجاعهما، ينتج عرضًا محددًا يمكن تمييزه.

**حلقة التظليل، والطنين الذي يخبرك بغيابها.** في الكونتاكتور المتردد يتبع المجال المغناطيسي موجة التغذية، فيمر بالصفر مرتين كل دورة. وفي تلك اللحظات تختفي قوة الجذب ويبدأ النابض بإعادة فتح التلامسات — ما ينتج طنينًا عنيفًا وتلفًا سريعًا للتلامسات. و**حلقة التظليل**، وهي حلقة نحاسية مغلقة مغروسة في وجه القلب، تحمل تيارًا محثًا يُبقي مجالًا مغناطيسيًا عبر تلك اللحظات فيثبت القلب مغلقًا.

والكونتاكتور الذي يطن بصوت عالٍ غالبًا لديه حلقة تظليل تالفة، أو أوساخ بين وجهي القلب تمنع الإغلاق التام، أو جهد ملف منخفض لا يسحبه بشكل صحيح. الطنين ليس مشكلة شكلية — بل كونتاكتور لا يلامس بشكل سليم، يسخن، وفي طريقه للالتحام أو التلف.

**التلامسات الرئيسية مقابل المساعدة.** التمييز مهم باستمرار:
- **التلامسات الرئيسية** تحمل تيار الحمل إلى المحرك أو غيره. ضخمة ماديًا، وثلاثة عادة لحمل ثلاثي الأطوار، ومفتوحة طبيعيًا.
- **التلامسات المساعدة** صغيرة، تحمل تيار دائرة التحكم فقط، وتوجد ليعرف منطق التحكم ما يفعله الكونتاكتور. وتأتي بنوعين: مفتوح طبيعيًا ومغلق طبيعيًا.

وخطأ المبتدئين الكلاسيكي تمرير تيار الحمل عبر تلامس مساعد. سيمر لبرهة ثم يتلف، أحيانًا بشكل مدوٍّ.

**قراءة ترقيم الأطراف.** ترقيم أجهزة التحكم موحد بما يكفي لتوصيل كونتاكتور غير مألوف من العلامات وحدها:
- **التلامسات الرئيسية** تُعلَّم إما 1/2 و3/4 و5/6، أو بتسميات جهة التغذية والحمل مثل L1/L2/L3 دخولًا وT1/T2/T3 خروجًا، أو R/S/T دخولًا وU/V/W خروجًا. والاقتران يشير دائمًا لدخول الخط وخروج الحمل للقطب نفسه.
- **طرفا الملف** هما A1 وA2.
- **التلامسات المساعدة** تحمل أرقامًا من خانتين يحدد رقمها الثاني وظيفتها: التلامس المنتهي بـ3 و4 مفتوح طبيعيًا، والمنتهي بـ1 و2 مغلق طبيعيًا. والرقم الأول يحدد كتلة المساعد فحسب.

وبمعرفة هذه القاعدة يمكنك النظر لكتلة مساعدة غير معنونة وتحديد وظيفتها. تستحق الحفظ لأنها تغنيك عن التخمين أو قياس كل طرف في لوحة غير مألوفة.

**جهد الملف مواصفة لا تفصيلة.** تُصنع ملفات الكونتاكتورات لجهود محددة — 230 فولت متردد أو 24 فولت مستمر شائعة في أعمال المباني، وأحيانًا 110 فولت متردد في مواقع تتطلب جهد تحكم أخفض للسلامة. وتركيب ملف مصنّف لجهد مختلف عمّا تغذيه دائرة التحكم خطأ شائع ومكلف: فالمنخفض جدًا يجعل الكونتاكتور يرتعش أو لا ينسحب تمامًا، والمرتفع جدًا يجعل الملف يسخن ويحترق. تحقق دائمًا من علامة الملف مقابل تغذية التحكم قبل تركيب بديل، فالكونتاكتورات المتطابقة ظاهريًا قد تحمل ملفات مختلفة تمامًا.

**ملفات المتردد والمستمر تتصرف بشكل مختلف عند الاندفاع.** يسحب ملف المتردد تيارًا أعلى بكثير لحظة التغذية مما يسحبه بعد إغلاق القلب، لأن القلب المغلق يغيّر الدائرة المغناطيسية. ويهم هذا عند تحديد حجم محول التحكم أو التلامسات التي تفصّل الملف — فعنصر التبديل يجب أن يتحمل الاندفاع لا تيار الإمساك فقط.

**تصنيفات خدمة الكونتاكتور.** تُصنّف الكونتاكتورات بفئة الاستخدام، التي تصف نوع الحمل لا الأمبيرات فقط. فالكونتاكتور الذي يفصّل حمل تسخين مقاوم يعيش حياة أسهل من الذي يفصّل محركًا يسحب أضعاف تيار تشغيله عند البدء وينتج قوسًا كبيرًا عند القطع. والاختيار بتيار التشغيل وحده، دون اعتبار نوع الحمل، هو كيف ينتهي المركّبون بتلامسات ملتحمة بعد أشهر من التشغيل.$c$,
1
FROM public.modules WHERE slug = 'finix-contactors-control-logic';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$The Latch Circuit and Stop Priority$t$,
$t$دائرة التثبيت وأولوية الإيقاف$t$,
$c$A contactor on its own runs only while you hold the button. The latch circuit — also called a hold-in or seal-in circuit — is what makes a machine stay running after you let go, and it is the single most important circuit in industrial control.

**The problem it solves.** Wire a start button directly to a contactor coil and the motor runs while pressed and stops when released. Useless for anything you want to leave running.

**How the latch works.** Take one of the contactor's own **normally-open auxiliary contacts** and wire it in **parallel** with the start button. The sequence:

1. Press start. Current flows through the button to the coil. The contactor pulls in.
2. As it pulls in, its auxiliary contact closes — and that contact is in parallel with the button, so it now provides a second path for the coil current.
3. Release the button. Current continues through the auxiliary contact. The contactor stays energised, holding its own supply.

The contactor is holding itself in through its own contact. This is why it is called a seal-in.

**Breaking the latch — the stop button.** To stop, you must interrupt the coil circuit. A **normally-closed** stop button wired in **series** with the whole arrangement does this: pressing it breaks the circuit, the coil de-energises, the auxiliary contact opens, and the latch is broken. Release the stop button and the motor stays stopped, because the auxiliary contact is now open and the start button is no longer pressed.

**Stop priority — a safety principle, not a preference.** The stop button goes in series with everything, so it can break the circuit regardless of what else is happening. If somebody holds the start button down while another person presses stop, the machine must stop. Wiring the stop so it can be overridden by a held start button is a serious design fault, and it is one you can spot by inspection: the stop contact must be in the common part of the circuit, upstream of where the start button and the latch contact join.

**Why the stop button is normally closed — and this catches people out.** It seems backwards. But consider what happens when a wire to the button breaks, or a terminal works loose:

- With a **normally-closed** stop button, a broken wire opens the circuit — exactly as if someone had pressed stop. The machine stops. The fault is immediately obvious and the failure is safe.
- With a normally-open arrangement, a broken wire means pressing stop does nothing. The machine keeps running, and nobody discovers the fault until the moment they urgently need to stop it.

This is the **fail-safe** principle: design so the likely failure produces the safe outcome. It is the same reasoning behind emergency-stop circuits, which use normally-closed contacts throughout for exactly this reason.

**Adding protection to the latch.** Real circuits put more than a stop button in series with the coil: the overload relay's normally-closed contact, emergency stops, guard interlocks, and any permissive condition. All are wired in series, so any one of them can break the latch independently. The design intent is simple — any protective device should be able to stop the machine on its own, without depending on any other device.

**A worked example — a conveyor with local and remote stops.** A conveyor must start from a control panel, be stoppable from the panel and from two emergency stops along its length, and stop on motor overload.

The coil circuit runs in series through: the overload's normally-closed contact, emergency stop 1, emergency stop 2, the panel stop button — and then to the parallel pair of the start button and the latch contact, and on to the coil.

Any of the four protective elements breaks the circuit alone. All are normally closed, so a broken wire anywhere stops the conveyor rather than disabling a stop. This is what "fail-safe" looks like in an actual wiring arrangement, and it is worth tracing on paper until the logic is instinctive.$c$,
$c$الكونتاكتور وحده يعمل فقط بينما تضغط الزر. ودائرة التثبيت — وتسمى أيضًا دائرة الإمساك أو الاحتفاظ — هي ما يجعل الماكينة تستمر بالعمل بعد أن ترفع يدك، وهي أهم دائرة منفردة في التحكم الصناعي.

**المشكلة التي تحلها.** وصّل زر بدء مباشرة بملف كونتاكتور فيعمل المحرك أثناء الضغط ويتوقف عند الترك. عديم الفائدة لأي شيء تريده أن يستمر.

**كيف يعمل التثبيت.** خذ أحد **التلامسات المساعدة المفتوحة طبيعيًا** للكونتاكتور نفسه ووصّله على **التوازي** مع زر البدء. والتتابع:

1. اضغط البدء. يسري التيار عبر الزر إلى الملف. فينسحب الكونتاكتور.
2. وبانسحابه يُغلق تلامسه المساعد — وذلك التلامس موازٍ للزر، فيوفر الآن مسارًا ثانيًا لتيار الملف.
3. ارفع يدك عن الزر. يستمر التيار عبر التلامس المساعد. فيبقى الكونتاكتور مُغذّى، ممسكًا بتغذيته بنفسه.

الكونتاكتور يمسك نفسه عبر تلامسه الخاص. ولهذا تسمى دائرة إمساك.

**كسر التثبيت — زر الإيقاف.** للإيقاف يجب قطع دائرة الملف. وزر إيقاف **مغلق طبيعيًا** موصَّل على **التوالي** مع الترتيب كله يفعل ذلك: فضغطه يقطع الدائرة، ويفقد الملف تغذيته، وينفتح التلامس المساعد، وينكسر التثبيت. وارفع يدك عن زر الإيقاف فيبقى المحرك متوقفًا، لأن التلامس المساعد صار مفتوحًا وزر البدء لم يعد مضغوطًا.

**أولوية الإيقاف — مبدأ سلامة لا تفضيل.** يوضع زر الإيقاف على التوالي مع كل شيء، ليقطع الدائرة مهما كان ما يجري. فإن أمسك أحدهم زر البدء مضغوطًا بينما يضغط آخر الإيقاف، يجب أن تتوقف الماكينة. وتوصيل الإيقاف بحيث يمكن لزر بدء مضغوط تجاوزه عيب تصميمي خطير، ويمكن كشفه بالفحص: فتلامس الإيقاف يجب أن يكون في الجزء المشترك من الدائرة، قبل نقطة التقاء زر البدء وتلامس التثبيت.

**لماذا زر الإيقاف مغلق طبيعيًا — وهذا يوقع الكثيرين.** يبدو معكوسًا. لكن تأمل ما يحدث حين ينقطع سلك للزر، أو يرتخي طرف:

- مع زر إيقاف **مغلق طبيعيًا**، السلك المقطوع يفتح الدائرة — تمامًا كما لو ضغط أحدهم الإيقاف. فتتوقف الماكينة. ويصبح العطل واضحًا فورًا والفشل آمنًا.
- ومع ترتيب مفتوح طبيعيًا، السلك المقطوع يعني أن ضغط الإيقاف لا يفعل شيئًا. فتستمر الماكينة، ولا يكتشف أحد العطل حتى اللحظة التي يحتاج فيها بشدة لإيقافها.

هذا مبدأ **الفشل الآمن**: صمّم بحيث ينتج الفشل المرجح النتيجة الآمنة. وهو المنطق ذاته خلف دوائر إيقاف الطوارئ، التي تستخدم تلامسات مغلقة طبيعيًا في كل مكان لهذا السبب بالضبط.

**إضافة الحماية للتثبيت.** الدوائر الحقيقية تضع أكثر من زر إيقاف على التوالي مع الملف: التلامس المغلق طبيعيًا لريليه الحمل الزائد، وإيقافات الطوارئ، وتعشيقات الحُرّاس، وأي شرط تصريح. وكلها توصَّل على التوالي، فيستطيع أي منها كسر التثبيت باستقلال. ونية التصميم بسيطة — ينبغي أن يستطيع أي جهاز وقائي إيقاف الماكينة بمفرده، دون اعتماد على جهاز آخر.

**مثال محلول — سير ناقل بإيقافات محلية وبعيدة.** يجب أن يبدأ سير ناقل من لوحة تحكم، وأن يمكن إيقافه من اللوحة ومن إيقافي طوارئ على امتداده، وأن يتوقف عند الحمل الزائد للمحرك.

تسري دائرة الملف على التوالي عبر: التلامس المغلق طبيعيًا للحمل الزائد، وإيقاف الطوارئ 1، وإيقاف الطوارئ 2، وزر إيقاف اللوحة — ثم إلى الزوج المتوازي من زر البدء وتلامس التثبيت، ومنه إلى الملف.

وأي من العناصر الوقائية الأربعة يقطع الدائرة بمفرده. وكلها مغلقة طبيعيًا، فالسلك المقطوع في أي موضع يوقف السير بدل أن يعطّل إيقافًا. هكذا يبدو "الفشل الآمن" في ترتيب تسليك فعلي، ويستحق تتبعه على الورق حتى يصبح منطقه غريزيًا.$c$,
2
FROM public.modules WHERE slug = 'finix-contactors-control-logic';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$Interlocking, Reversing and Circuit Separation$t$,
$t$التعشيق وعكس الاتجاه وفصل الدوائر$t$,
$c$Some pairs of contactors must never close together. Interlocking is how you guarantee that, and motor reversing is the case where the consequence of getting it wrong is immediate and violent.

**Reversing a three-phase motor.** Swapping any two of the three supply phases reverses the direction of rotation. A reversing starter therefore uses two contactors: a forward contactor connecting the phases straight through, and a reverse contactor connecting two of them crossed over.

**Why they must never close together.** If both close simultaneously, the crossed connection shorts two phases directly to each other. The result is a phase-to-phase fault at full supply capacity — a violent arc, destroyed contactors, and an upstream protective device operating if you are fortunate. This is not a theoretical risk; it is what happens every time the interlock is missing or defeated.

**Electrical interlock.** Take the forward contactor's **normally-closed** auxiliary contact and wire it in series with the reverse contactor's coil, and vice versa. Now, whenever forward is energised, its normally-closed auxiliary is held open, so the reverse coil cannot be energised no matter what the control circuit asks for. The two contactors are mutually exclusive by wiring.

**Mechanical interlock.** A physical bar or lever between the two contactors that blocks one from closing while the other is closed. This is supplied as an accessory that clips between adjacent contactors.

**Use both.** The electrical interlock fails if an auxiliary contact welds closed. The mechanical interlock fails if the linkage breaks or is removed during maintenance. Together the probability of both failing simultaneously is very low. On any reversing application, fitting both is standard practice, not belt-and-braces excess.

**Add a transition delay.** Even with interlocks, reversing a running motor instantly is mechanically brutal: the motor is still spinning one way while being driven the other, producing enormous current and severe mechanical shock to the coupling and the driven machine. Good practice inserts a delay between stopping one direction and starting the other, allowing the motor to slow. This is the ON-delay function from the timers module applied to a different purpose.

**The general interlock principle.** Reversing is the classic case, but the same pattern applies anywhere two loads are mutually exclusive: star and delta contactors in a star-delta starter; duty and standby pumps that must not run together; two supplies that must never be paralleled, such as mains and generator. Recognising "these two must never be on together" as a single recurring problem with one standard solution is more useful than memorising each circuit separately.

**Separating power and control circuits.** In any panel of consequence, the circuit that carries load current and the circuit that carries control signals are kept distinct, and the separation is deliberate:

- **Different voltages.** Control circuits frequently run at a lower voltage than the power circuit — commonly 230V, 110V, or 24V — derived through a control transformer. A lower control voltage means the buttons, switches and wiring that people interact with are safer to work on.
- **Different conductor sizes.** Power conductors are sized for load current; control conductors carry a fraction of an amp and are correspondingly small.
- **Physical separation in the panel.** Power and control wiring are routed in separate trunking where practical. This reduces induced interference in control wiring and, just as importantly, makes the panel readable — a technician tracing a control fault should not have to pick through power cabling to do it.
- **Separate protection.** The control circuit gets its own small protective device, so a control-circuit fault does not trip the main supply and vice versa.

**Why this matters for fault-finding.** Separation lets you isolate a problem quickly. If a motor will not start, you can test the control circuit — is the coil being energised? — independently of the power circuit. A panel where power and control are tangled together forces you to test everything at once, which is slower and more dangerous.

**Control transformer sizing.** The control transformer must supply not just the holding current of every coil that could be energised simultaneously, but the **inrush** of the largest coil pulling in while the others are already holding. Sizing on holding current alone produces a transformer that sags when a contactor pulls in, which can drop other coils out — an intermittent, confusing fault that looks like anything except a transformer problem.$c$,
$c$بعض أزواج الكونتاكتورات يجب ألا تُغلق معًا أبدًا. والتعشيق هو كيف تضمن ذلك، وعكس اتجاه المحركات هو الحالة التي تكون فيها عاقبة الخطأ فورية وعنيفة.

**عكس اتجاه محرك ثلاثي الأطوار.** تبديل أي طورين من الثلاثة يعكس اتجاه الدوران. لذا يستخدم بادئ العكس كونتاكتورين: كونتاكتور أمامي يوصّل الأطوار مباشرة، وكونتاكتور عكسي يوصّل اثنين منها متقاطعين.

**لماذا يجب ألا يُغلقا معًا.** إن أُغلقا في آن واحد، قصّر التوصيل المتقاطع طورين مباشرة على بعضهما. والنتيجة عطل بين طورين بكامل سعة التغذية — قوس عنيف، وكونتاكتورات مدمّرة، وجهاز حماية أمامي يفصل إن كنت محظوظًا. وهذه ليست مخاطرة نظرية؛ بل ما يحدث كلما غاب التعشيق أو أُبطل.

**التعشيق الكهربائي.** خذ التلامس المساعد **المغلق طبيعيًا** للكونتاكتور الأمامي ووصّله على التوالي مع ملف الكونتاكتور العكسي، والعكس بالعكس. والآن كلما غُذّي الأمامي، بقي مساعده المغلق طبيعيًا مفتوحًا، فلا يمكن تغذية ملف العكس مهما طلبت دائرة التحكم. فالكونتاكتوران متبادلا الاستبعاد بالتسليك.

**التعشيق الميكانيكي.** قضيب أو ذراع مادي بين الكونتاكتورين يمنع أحدهما من الإغلاق بينما الآخر مغلق. يُورَّد كملحق يُثبَّت بين كونتاكتورين متجاورين.

**استخدم الاثنين.** يفشل التعشيق الكهربائي إن التحم تلامس مساعد مغلقًا. ويفشل الميكانيكي إن انكسرت الوصلة أو أُزيلت أثناء الصيانة. ومعًا يصبح احتمال فشلهما في آن واحد ضئيلًا جدًا. وفي أي تطبيق عكس، تركيب الاثنين ممارسة قياسية لا احتياط زائد.

**أضف تأخير انتقال.** حتى مع التعشيقات، فعكس محرك دائر فورًا قاسٍ ميكانيكيًا: فالمحرك ما يزال يدور في اتجاه بينما يُدفع للآخر، منتجًا تيارًا هائلًا وصدمة ميكانيكية شديدة للقارنة والآلة المُدارة. والممارسة الجيدة تُدخل تأخيرًا بين إيقاف اتجاه وبدء الآخر، يتيح للمحرك التباطؤ. وهذه وظيفة تأخير التشغيل من برنامج المؤقتات مطبَّقة لغرض مختلف.

**مبدأ التعشيق العام.** العكس هو الحالة الكلاسيكية، لكن النمط ذاته ينطبق حيثما كان حملان متبادلي الاستبعاد: كونتاكتورا النجمة والدلتا في بادئ نجمة/دلتا؛ ومضختان عاملة واحتياطية يجب ألا تعملا معًا؛ ومصدران يجب ألا يتوازيا أبدًا كالشبكة والمولد. وإدراك أن "هذين يجب ألا يعملا معًا" مشكلة متكررة واحدة لها حل قياسي واحد أنفع من حفظ كل دائرة على حدة.

**فصل دائرتي القوى والتحكم.** في أي لوحة ذات شأن، تُبقى الدائرة الحاملة لتيار الحمل والدائرة الحاملة لإشارات التحكم متمايزتين، والفصل مقصود:

- **جهود مختلفة.** تعمل دوائر التحكم غالبًا بجهد أخفض من دائرة القوى — 230 أو 110 أو 24 فولت شائعة — مشتق عبر محول تحكم. والجهد الأخفض يعني أن الأزرار والمفاتيح والأسلاك التي يتعامل معها الناس أأمن للعمل عليها.
- **مقاطع موصلات مختلفة.** موصلات القوى مقاسة لتيار الحمل؛ وموصلات التحكم تحمل جزءًا من الأمبير فتكون صغيرة بالمقابل.
- **فصل مادي في اللوحة.** تُمرَّر أسلاك القوى والتحكم في مجارٍ منفصلة حيثما أمكن. يقلل ذلك التداخل المحثّ في أسلاك التحكم، والأهم أنه يجعل اللوحة مقروءة — فالفني المتتبع لعطل تحكم لا ينبغي أن ينبش في كابلات القوى ليفعل ذلك.
- **حماية منفصلة.** تحصل دائرة التحكم على جهاز حماية صغير خاص بها، فلا يفصل عطل في التحكم التغذية الرئيسية والعكس صحيح.

**لماذا يهم هذا في تتبع الأعطال.** الفصل يتيح عزل المشكلة بسرعة. فإن لم يبدأ محرك، يمكنك اختبار دائرة التحكم — هل يُغذّى الملف؟ — باستقلال عن دائرة القوى. واللوحة التي تتشابك فيها القوى والتحكم تجبرك على اختبار كل شيء دفعة واحدة، وهو أبطأ وأخطر.

**تحديد حجم محول التحكم.** يجب أن يغذي محول التحكم لا تيار إمساك كل ملف قد يُغذّى في آن واحد فحسب، بل **اندفاع** أكبر ملف ينسحب بينما الأخرى ممسكة أصلًا. والتحديد بتيار الإمساك وحده ينتج محولًا يهبط جهده حين ينسحب كونتاكتور، ما قد يُسقط ملفات أخرى — عطل متقطع ومربك يبدو كأي شيء إلا مشكلة محول.$c$,
3
FROM public.modules WHERE slug = 'finix-contactors-control-logic';

-- Quizzes I01
INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'bronze', 'Contactor Fundamentals', 'أساسيات الكونتاكتور', 80
FROM public.modules WHERE slug = 'finix-contactors-control-logic';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$Which terminals on a contactor are the coil terminals?$q$,
    $q$أي أطراف الكونتاكتور هي طرفا الملف؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-contactors-control-logic' AND quizzes.tier = 'bronze' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$A1 and A2$o$, $o$A1 وA2$o$, true, 1),
  ($o$1 and 2$o$, $o$1 و2$o$, false, 2),
  ($o$13 and 14$o$, $o$13 و14$o$, false, 3),
  ($o$L1 and T1$o$, $o$L1 وT1$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$An auxiliary contact numbered ending in 1 and 2 is which type?$q$,
    $q$التلامس المساعد المنتهي ترقيمه بـ1 و2 من أي نوع؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-contactors-control-logic' AND quizzes.tier = 'bronze' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Normally closed$o$, $o$مغلق طبيعيًا$o$, true, 1),
  ($o$Normally open$o$, $o$مفتوح طبيعيًا$o$, false, 2),
  ($o$A main power contact$o$, $o$تلامس قوى رئيسي$o$, false, 3),
  ($o$A coil terminal$o$, $o$طرف ملف$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$In a latch circuit, how is the contactor's own auxiliary contact wired relative to the start button?$q$,
    $q$في دائرة التثبيت، كيف يُوصَّل التلامس المساعد للكونتاكتور نسبةً لزر البدء؟$q$, 3
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-contactors-control-logic' AND quizzes.tier = 'bronze' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$In parallel with it$o$, $o$على التوازي معه$o$, true, 1),
  ($o$In series with it$o$, $o$على التوالي معه$o$, false, 2),
  ($o$In series with the stop button only$o$, $o$على التوالي مع زر الإيقاف فقط$o$, false, 3),
  ($o$It is not connected to the control circuit$o$, $o$لا يُوصَّل بدائرة التحكم$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'silver', 'Control Circuit Design', 'تصميم دائرة التحكم', 80
FROM public.modules WHERE slug = 'finix-contactors-control-logic';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$Why is a stop button wired as a normally-closed contact rather than normally-open?$q$,
    $q$لماذا يُوصَّل زر الإيقاف كتلامس مغلق طبيعيًا لا مفتوح طبيعيًا؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-contactors-control-logic' AND quizzes.tier = 'silver' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$So a broken wire stops the machine (fail-safe) rather than disabling the stop function$o$, $o$كي يوقف السلك المقطوع الماكينة (فشل آمن) بدل تعطيل وظيفة الإيقاف$o$, true, 1),
  ($o$Because normally-closed buttons are cheaper$o$, $o$لأن الأزرار المغلقة طبيعيًا أرخص$o$, false, 2),
  ($o$To reduce the current through the button$o$, $o$لتقليل التيار عبر الزر$o$, false, 3),
  ($o$It makes no difference to safety$o$, $o$لا فرق في السلامة$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$A contactor buzzes loudly when energised. Which causes are most likely?$q$,
    $q$كونتاكتور يطن بصوت عالٍ عند التغذية. ما الأسباب الأرجح؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-contactors-control-logic' AND quizzes.tier = 'silver' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Damaged shading ring, dirt between core faces, or low coil voltage$o$, $o$حلقة تظليل تالفة، أو أوساخ بين وجهي القلب، أو جهد ملف منخفض$o$, true, 1),
  ($o$The load is too small for the contactor$o$, $o$الحمل أصغر من الكونتاكتور$o$, false, 2),
  ($o$Buzzing is normal and can be ignored$o$, $o$الطنين طبيعي ويمكن تجاهله$o$, false, 3),
  ($o$The auxiliary contacts are normally closed$o$, $o$التلامسات المساعدة مغلقة طبيعيًا$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$How is an electrical interlock between forward and reverse contactors wired?$q$,
    $q$كيف يُوصَّل التعشيق الكهربائي بين كونتاكتوري الأمام والعكس؟$q$, 3
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-contactors-control-logic' AND quizzes.tier = 'silver' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Each contactor's normally-closed auxiliary contact is wired in series with the other's coil$o$, $o$التلامس المساعد المغلق طبيعيًا لكل كونتاكتور يُوصَّل على التوالي مع ملف الآخر$o$, true, 1),
  ($o$Both coils are wired in parallel$o$, $o$يُوصَّل الملفان على التوازي$o$, false, 2),
  ($o$Each contactor's normally-open contact is wired in series with its own coil$o$, $o$التلامس المفتوح طبيعيًا لكل كونتاكتور يُوصَّل على التوالي مع ملفه$o$, false, 3),
  ($o$Interlocks are only mechanical, never electrical$o$, $o$التعشيقات ميكانيكية فقط لا كهربائية أبدًا$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'gold', 'Panel Design Judgement', 'الحكم في تصميم اللوحات', 80
FROM public.modules WHERE slug = 'finix-contactors-control-logic';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$On a reversing starter, why fit both an electrical and a mechanical interlock rather than just one?$q$,
    $q$في بادئ عكس، لماذا تركّب تعشيقًا كهربائيًا وميكانيكيًا معًا بدل واحد فقط؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-contactors-control-logic' AND quizzes.tier = 'gold' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Each has a different failure mode — a welded auxiliary defeats the electrical one, a broken linkage defeats the mechanical one$o$, $o$لكل منهما حالة فشل مختلفة — تلامس مساعد ملتحم يُبطل الكهربائي، ووصلة مكسورة تُبطل الميكانيكي$o$, true, 1),
  ($o$Regulations require two of everything$o$, $o$اللوائح تتطلب اثنين من كل شيء$o$, false, 2),
  ($o$The mechanical interlock is purely decorative$o$, $o$التعشيق الميكانيكي زخرفي فحسب$o$, false, 3),
  ($o$Two interlocks make the motor reverse faster$o$, $o$تعشيقان يجعلان المحرك يعكس أسرع$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$A panel's contactors intermittently drop out when another contactor pulls in. What is the most likely cause?$q$,
    $q$كونتاكتورات لوحة تسقط متقطعًا حين ينسحب كونتاكتور آخر. ما السبب الأرجح؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-contactors-control-logic' AND quizzes.tier = 'gold' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$The control transformer was sized on holding current and sags under coil inrush$o$, $o$محول التحكم حُدد حجمه بتيار الإمساك فيهبط جهده تحت اندفاع الملف$o$, true, 1),
  ($o$The contactors are too large for their loads$o$, $o$الكونتاكتورات أكبر من أحمالها$o$, false, 2),
  ($o$The auxiliary contacts are wired in parallel$o$, $o$التلامسات المساعدة موصَّلة على التوازي$o$, false, 3),
  ($o$This is normal behaviour in any multi-contactor panel$o$, $o$سلوك طبيعي في أي لوحة متعددة الكونتاكتورات$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$Why must the stop contact sit upstream of where the start button and latch contact join?$q$,
    $q$لماذا يجب أن يقع تلامس الإيقاف قبل نقطة التقاء زر البدء وتلامس التثبيت؟$q$, 3
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-contactors-control-logic' AND quizzes.tier = 'gold' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$So stop has priority and works even if someone is holding the start button down$o$, $o$كي تكون للإيقاف أولوية ويعمل حتى لو أمسك أحدهم زر البدء مضغوطًا$o$, true, 1),
  ($o$To shorten the wiring run$o$, $o$لتقصير مسار الأسلاك$o$, false, 2),
  ($o$Because the stop button draws more current$o$, $o$لأن زر الإيقاف يسحب تيارًا أكبر$o$, false, 3),
  ($o$Position in the circuit makes no functional difference$o$, $o$الموضع في الدائرة لا فرق وظيفي له$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);
