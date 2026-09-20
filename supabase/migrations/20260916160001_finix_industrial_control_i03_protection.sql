-- Module I03: Motor Protection
-- ORIGINAL CONTENT written for Finix.

INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES (
  'finix-motor-protection',
  'I03',
  'finix-industrial-control',
  'Motor Protection: Overload, Short Circuit & Thermal',
  'حماية المحركات: الحمل الزائد والقصر والحرارة',
  $s$What actually destroys motors and how each protective device answers a different threat: thermal overload relays, short-circuit protection, motor protection circuit breakers, thermistors, and why one device cannot cover every fault.$s$,
  $s$ما يدمّر المحركات فعلًا وكيف يعالج كل جهاز حماية تهديدًا مختلفًا: ريليهات الحمل الزائد الحرارية، حماية القصر، قواطع حماية المحركات، الثرمستورات، ولماذا لا يغطي جهاز واحد كل الأعطال.$s$,
  NULL,
  30
)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$Overload Versus Short Circuit: Two Different Threats$t$,
$t$الحمل الزائد مقابل القصر: تهديدان مختلفان$t$,
$c$The single most important idea in motor protection is that **overload and short circuit are different problems requiring different devices.** Technicians who do not hold this distinction clearly end up fitting one device and believing the motor is protected when it is not.

**Overload: moderate excess current, sustained.** A motor drawing somewhat more than its rated current — because the driven machine is jammed, a bearing is failing, the motor is undersized for the job, or a phase has been lost — will not fail instantly. It heats gradually. The insulation on the windings degrades as temperature rises, and over minutes or hours the motor cooks itself.

The protection required is **time-dependent**: it must tolerate brief overloads (every start is an overload) while acting on sustained ones. Trip too fast and the motor cannot start; trip too slowly and the windings burn.

**Short circuit: enormous current, instantaneous.** A fault between phases or from phase to earth produces current limited only by the supply's capacity — potentially thousands of amps. This must be interrupted in a fraction of a second, because the energy involved destroys cables, welds contactor contacts, and can cause fire or an arc-flash injury.

The protection required is **fast and high-capacity**: it must break an enormous current safely, which demands a device with sufficient breaking capacity.

**Why one device cannot do both well.** An overload relay is designed to measure heating over time; it has neither the speed nor the breaking capacity to interrupt a short circuit. A fuse or circuit breaker sized to let a motor start without nuisance tripping is necessarily set far above running current, so it cannot detect a modest sustained overload.

Therefore a properly protected motor circuit has **both**: short-circuit protection upstream, overload protection sized to the motor. Finding a motor with only one is finding a motor that is unprotected against something.

**The thermal overload relay.** The traditional device uses bimetallic strips heated by the motor current. Different metals expand at different rates, so the strip bends as it heats, and at a set deflection it operates a contact. Because the strips take time to heat, the response is naturally time-dependent — brief starting current does not trip it, sustained overload does.

That contact is a **signal**, not an interruption. The overload relay does not break the motor current itself; its normally-closed auxiliary contact sits in the contactor's coil circuit, so tripping de-energises the coil and the contactor opens. The contactor does the switching; the relay only decides.

This is why an overload relay must be correctly integrated into the control circuit. An overload relay whose contact is not wired into the coil circuit is decoration.

**Setting the overload relay.** Set to the motor's full-load current as marked on the nameplate — with the critical caveat from the star-delta lesson that you must know whether the relay measures line or winding current.

Two failure patterns to recognise:
- **Set too low**: nuisance tripping, usually during starting or under normal peak load. The temptation is to wind the setting up until tripping stops, which defeats the protection entirely. The correct response is to establish why the current is high.
- **Set too high**: the motor burns out with the relay never tripping. This is the failure nobody notices until there is smoke, and it is frequently the result of someone previously "fixing" nuisance tripping.

**Manual and automatic reset.** Overload relays offer a reset mode selector. **Manual reset** requires a person to attend and press the reset, which forces someone to look at the machine before restarting it. **Automatic reset** allows restart once the bimetal cools.

Automatic reset is dangerous on any machine where an unexpected restart could injure someone, and it also masks a developing fault — a motor that trips and restarts repeatedly is failing, but nobody sees it. For most industrial applications, manual reset is the correct choice, and choosing automatic should be a deliberate decision with a reason.

**Phase loss and why it destroys motors.** If one phase of a three-phase supply is lost, the motor continues to run on two phases. It does not stop — which is what makes this fault dangerous. The remaining two phases carry substantially increased current to deliver the same power, and the motor overheats.

Standard thermal overload relays respond to this because they see the increased current, but the response may be slow. Relays with dedicated **phase-failure sensitivity** respond faster by detecting the imbalance directly rather than waiting for heating. On any installation where phase loss is a realistic risk — which in practice is most of them — this feature is worth specifying.

**Motor protection circuit breakers.** An MPCB combines short-circuit protection and adjustable overload protection in one device, with a single unit replacing a separate breaker and overload relay. It offers a compact panel, coordinated protection designed to work together, and adjustable current setting. For many installations it is now the default choice, though separate devices remain common in existing panels and in applications needing specific relay characteristics.$c$,
$c$أهم فكرة منفردة في حماية المحركات أن **الحمل الزائد والقصر مشكلتان مختلفتان تتطلبان جهازين مختلفين.** والفنيون الذين لا يمسكون هذا التمييز بوضوح ينتهون بتركيب جهاز واحد واعتقاد أن المحرك محمي بينما هو ليس كذلك.

**الحمل الزائد: تيار زائد معتدل ومستمر.** المحرك الذي يسحب أكثر قليلًا من تياره المقنن — لأن الآلة المُدارة محشورة، أو محمل يتلف، أو المحرك أصغر من المهمة، أو فُقد طور — لن يتلف فورًا. بل يسخن تدريجيًا. فيتدهور عزل الملفات مع ارتفاع الحرارة، وعبر دقائق أو ساعات يطهو المحرك نفسه.

والحماية المطلوبة **معتمدة على الزمن**: يجب أن تتحمل الأحمال الزائدة القصيرة (فكل بدء حمل زائد) بينما تتصرف مع المستمرة. الفصل السريع جدًا يمنع المحرك من البدء؛ والبطيء جدًا يحرق الملفات.

**القصر: تيار هائل ولحظي.** العطل بين طورين أو من طور للأرض ينتج تيارًا لا يحده إلا سعة التغذية — وربما آلاف الأمبيرات. ويجب قطعه في جزء من الثانية، لأن الطاقة المتضمنة تدمّر الكابلات وتلحم تلامسات الكونتاكتورات وقد تسبب حريقًا أو إصابة بوميض القوس.

والحماية المطلوبة **سريعة وعالية السعة**: يجب أن تقطع تيارًا هائلًا بأمان، ما يتطلب جهازًا بسعة قطع كافية.

**لماذا لا يستطيع جهاز واحد أداء الاثنين جيدًا.** ريليه الحمل الزائد مصمم لقياس التسخين عبر الزمن؛ وليس لديه السرعة ولا سعة القطع لمقاطعة قصر. والفيوز أو القاطع المقاس ليسمح ببدء المحرك دون فصل مزعج مضبوط بالضرورة أعلى بكثير من تيار التشغيل، فلا يكشف حملًا زائدًا معتدلًا مستمرًا.

لذا فدائرة المحرك المحمية بشكل سليم فيها **الاثنان**: حماية قصر أمامية، وحماية حمل زائد مقاسة للمحرك. وإيجاد محرك بواحدة فقط هو إيجاد محرك غير محمي من شيء ما.

**ريليه الحمل الزائد الحراري.** الجهاز التقليدي يستخدم شرائح ثنائية المعدن تسخّنها تيار المحرك. فالمعادن المختلفة تتمدد بمعدلات مختلفة، فتنحني الشريحة مع تسخينها، وعند انحراف محدد تشغّل تلامسًا. ولأن الشرائح تحتاج وقتًا لتسخن، تكون الاستجابة معتمدة على الزمن بطبيعتها — فتيار البدء القصير لا يفصله، والحمل الزائد المستمر يفصله.

وذلك التلامس **إشارة** لا قطع. فريليه الحمل الزائد لا يقطع تيار المحرك بنفسه؛ بل يقع تلامسه المساعد المغلق طبيعيًا في دائرة ملف الكونتاكتور، فيُفقد الفصل تغذية الملف وينفتح الكونتاكتور. الكونتاكتور يقوم بالتبديل، والريليه يقرر فقط.

ولهذا يجب دمج ريليه الحمل الزائد بشكل صحيح في دائرة التحكم. فريليه حمل زائد لا يُوصَّل تلامسه في دائرة الملف مجرد زينة.

**ضبط ريليه الحمل الزائد.** يُضبط على تيار الحمل الكامل للمحرك كما على لوحة الاسم — مع التحفظ الحرج من درس نجمة/دلتا بأنك يجب أن تعرف هل يقيس الريليه تيار الخط أم الملف.

ونمطا فشل يجب تمييزهما:
- **مضبوط منخفضًا جدًا**: فصل مزعج، عادة أثناء البدء أو تحت ذروة حمل عادية. والإغراء رفع الضبط حتى يتوقف الفصل، وهذا يُبطل الحماية تمامًا. والاستجابة الصحيحة تحديد سبب ارتفاع التيار.
- **مضبوط عاليًا جدًا**: يحترق المحرك دون أن يفصل الريليه أبدًا. وهذا الفشل الذي لا يلاحظه أحد حتى يظهر الدخان، وغالبًا نتيجة "إصلاح" سابق لفصل مزعج.

**التصفير اليدوي والتلقائي.** توفر ريليهات الحمل الزائد مفتاح اختيار لوضع التصفير. **التصفير اليدوي** يتطلب حضور شخص وضغط الزر، ما يجبر أحدًا على النظر للماكينة قبل إعادة تشغيلها. و**التصفير التلقائي** يسمح بإعادة التشغيل بعد أن يبرد المعدن.

والتصفير التلقائي خطير في أي ماكينة قد تصيب فيها إعادة تشغيل غير متوقعة أحدًا، ويخفي أيضًا عطلًا ناشئًا — فالمحرك الذي يفصل ويعيد التشغيل مرارًا يتلف، لكن لا أحد يرى ذلك. ولأغلب التطبيقات الصناعية، التصفير اليدوي هو الاختيار الصحيح، واختيار التلقائي ينبغي أن يكون قرارًا مقصودًا له سبب.

**فقد الطور ولماذا يدمّر المحركات.** إن فُقد أحد أطوار تغذية ثلاثية، يستمر المحرك بالدوران على طورين. لا يتوقف — وهذا ما يجعل العطل خطيرًا. فالطوران الباقيان يحملان تيارًا متزايدًا كثيرًا لتقديم القدرة ذاتها، ويسخن المحرك.

وريليهات الحمل الزائد الحرارية القياسية تستجيب لهذا لأنها ترى التيار المتزايد، لكن الاستجابة قد تكون بطيئة. والريليهات ذات **الحساسية المخصصة لفقد الطور** تستجيب أسرع بكشف عدم الاتزان مباشرة بدل انتظار التسخين. وفي أي تركيب يكون فيه فقد الطور خطرًا واقعيًا — وهو عمليًا أغلبها — تستحق هذه الميزة التحديد.

**قواطع حماية المحركات.** يجمع قاطع حماية المحرك حماية القصر وحماية الحمل الزائد القابلة للضبط في جهاز واحد، فتحل وحدة واحدة محل قاطع منفصل وريليه حمل زائد. ويوفر لوحة أصغر، وحماية منسقة مصممة للعمل معًا، وضبط تيار قابل للتعديل. ولكثير من التركيبات صار الاختيار الافتراضي، وإن بقيت الأجهزة المنفصلة شائعة في اللوحات القائمة وفي التطبيقات المحتاجة لخصائص ريليه معينة.$c$,
1
FROM public.modules WHERE slug = 'finix-motor-protection';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$Thermistors, Special Cases and Protection Coordination$t$,
$t$الثرمستورات والحالات الخاصة وتنسيق الحماية$t$,
$c$Current-based protection infers temperature from current. Sometimes that inference fails, and knowing when is what separates adequate protection from real protection.

**When current-based protection is blind.** A thermal overload relay assumes that normal current means normal temperature. That assumption breaks when the motor overheats for a reason unrelated to current:

- **Blocked ventilation.** A motor whose cooling fan is obstructed, or whose cooling fins are packed with dust, overheats while drawing perfectly normal current. The overload relay sees nothing wrong.
- **High ambient temperature.** A motor in a hot plant room starts from a higher baseline and reaches critical temperature at a current the relay considers acceptable.
- **Low-speed running on a drive.** Most motors are cooled by a fan on their own shaft. Run continuously at low speed from a VFD, the fan turns slowly and cooling collapses — while the current may be entirely normal.
- **Frequent starting.** Each start heats the motor. Many starts in quick succession accumulate heat faster than it dissipates, but no individual start looks like an overload.

In every one of these cases, current-based protection reports a healthy motor while the windings cook.

**Thermistors: measuring temperature directly.** The answer is to measure what actually matters. Thermistors — temperature-dependent resistors — are embedded in the motor windings during manufacture, one per phase, positioned at the hottest point. Their resistance changes sharply at a designed temperature, and a thermistor relay in the panel detects that change and trips.

This protects against every scenario above, because it responds to the winding temperature itself rather than inferring it.

**The prerequisite:** thermistors must be fitted inside the motor. You cannot add them to a motor that does not have them without stripping it. When specifying motors for applications with any of the risk factors above — particularly drive-fed motors running at low speed, or motors in hot or dirty environments — specify thermistors at purchase. Discovering the need afterwards is expensive.

**Thermistors do not replace overload relays.** They protect the motor from overheating, but they do not protect the *cable* from overload, and they respond only once the winding is already hot. Best practice uses both: a thermal overload for current-based protection of the circuit, and thermistors for direct thermal protection of the windings.

**Protection coordination — making devices work together.** A motor circuit typically has several protective devices in series: an upstream distribution breaker, the motor's short-circuit protection, and the overload relay. Coordination means arranging that the **device closest to the fault operates first**.

Why it matters practically: if a fault on one motor trips the main distribution breaker instead of that motor's own protection, the entire panel goes dark. One machine's fault becomes a plant-wide outage, and fault-finding starts from scratch because the tripped device tells you nothing about where the problem is.

Correct coordination means a motor fault trips only that motor's protection. The rest of the plant keeps running, and the tripped device points directly at the faulty circuit. This requires protective devices with appropriately graded ratings and characteristics — a design consideration, not something that happens by accident.

**Practical fault-finding using the protection itself.** The device that tripped is evidence:
- **Overload relay tripped, short-circuit protection intact** — a sustained moderate overcurrent. Look for a mechanical problem in the driven machine, a failing bearing, a lost phase, or a genuinely overloaded motor.
- **Short-circuit protection operated** — a genuine fault. Insulation failure, a damaged cable, water ingress, or a wiring error. Do not simply reset and re-energise; find the fault first, because re-energising into a short is dangerous.
- **Thermistor relay tripped, overload relay intact** — the motor is hot but current is normal. Check ventilation, ambient temperature, duty cycle and start frequency. This combination points specifically away from an electrical overload.
- **Nothing tripped but the motor is dead** — the fault is in the control circuit, not the power circuit. Check the coil, the control supply, the stop chain and the latch.

That last case is worth emphasising, because it is where the separation of power and control circuits from the contactors module pays off directly. Knowing which circuit to test first, from what did *not* trip, saves an enormous amount of time.

**A commissioning discipline.** Record the settings of every protective device on the panel schedule at commissioning. When someone later raises an overload setting to stop nuisance tripping, the record makes that change visible. Undocumented protection settings drift upward over a panel's life, and each increase is invisible until a motor burns.$c$,
$c$الحماية المعتمدة على التيار تستنتج الحرارة من التيار. وأحيانًا يفشل ذلك الاستنتاج، ومعرفة متى هي ما يفصل الحماية الكافية عن الحماية الحقيقية.

**متى تكون الحماية بالتيار عمياء.** يفترض ريليه الحمل الزائد الحراري أن التيار الطبيعي يعني حرارة طبيعية. وينهار ذلك الافتراض حين يسخن المحرك لسبب لا علاقة له بالتيار:

- **تهوية مسدودة.** المحرك الذي تُعاق مروحة تبريده، أو تنسد زعانف تبريده بالغبار، يسخن بينما يسحب تيارًا طبيعيًا تمامًا. ولا يرى ريليه الحمل الزائد خطأً.
- **حرارة محيطة عالية.** المحرك في غرفة ماكينات حارة يبدأ من خط أساس أعلى ويبلغ الحرارة الحرجة عند تيار يعتبره الريليه مقبولًا.
- **التشغيل بسرعة منخفضة على مغيّر تردد.** أغلب المحركات تُبرَّد بمروحة على عمودها. وبالتشغيل المستمر بسرعة منخفضة من مغيّر، تدور المروحة ببطء وينهار التبريد — بينما قد يكون التيار طبيعيًا تمامًا.
- **البدء المتكرر.** كل بدء يسخّن المحرك. والبدءات الكثيرة المتلاحقة تراكم حرارة أسرع من تبديدها، لكن لا يبدو أي بدء منفرد كحمل زائد.

وفي كل حالة من هذه، تبلّغ الحماية بالتيار عن محرك سليم بينما تُطهى الملفات.

**الثرمستورات: قياس الحرارة مباشرة.** الحل قياس ما يهم فعلًا. فالثرمستورات — مقاومات معتمدة على الحرارة — تُغرس في ملفات المحرك أثناء التصنيع، واحد لكل طور، موضوعة عند أسخن نقطة. وتتغير مقاومتها بحدة عند حرارة مصممة، فيكشف ريليه ثرمستور في اللوحة ذلك التغير ويفصل.

وهذا يحمي من كل سيناريو أعلاه، لأنه يستجيب لحرارة الملف نفسها بدل استنتاجها.

**الشرط المسبق:** يجب تركيب الثرمستورات داخل المحرك. ولا يمكنك إضافتها لمحرك لا يحتويها دون تفكيكه. فعند تحديد محركات لتطبيقات فيها أي من عوامل الخطر أعلاه — خاصة المحركات المغذّاة من مغيّر وتعمل بسرعة منخفضة، أو المحركات في بيئات حارة أو متربة — حدد الثرمستورات عند الشراء. فاكتشاف الحاجة لاحقًا مكلف.

**الثرمستورات لا تحل محل ريليهات الحمل الزائد.** تحمي المحرك من السخونة، لكنها لا تحمي *الكابل* من الحمل الزائد، ولا تستجيب إلا بعد أن يسخن الملف أصلًا. وأفضل ممارسة استخدام الاثنين: حمل زائد حراري لحماية الدائرة بالتيار، وثرمستورات لحماية حرارية مباشرة للملفات.

**تنسيق الحماية — جعل الأجهزة تعمل معًا.** دائرة المحرك عادة فيها عدة أجهزة حماية على التوالي: قاطع توزيع أمامي، وحماية قصر للمحرك، وريليه الحمل الزائد. والتنسيق يعني ترتيب أن **يعمل الجهاز الأقرب للعطل أولًا**.

ولماذا يهم عمليًا: إن فصل عطل في محرك واحد قاطع التوزيع الرئيسي بدل حماية ذلك المحرك، أظلمت اللوحة بأكملها. فيصبح عطل ماكينة واحدة انقطاعًا لمصنع كامل، ويبدأ تتبع العطل من الصفر لأن الجهاز الفاصل لا يخبرك بموضع المشكلة.

والتنسيق الصحيح يعني أن عطل محرك يفصل حماية ذلك المحرك فقط. فتستمر بقية المنشأة بالعمل، ويشير الجهاز الفاصل مباشرة للدائرة المعطوبة. ويتطلب هذا أجهزة حماية بتصنيفات وخصائص متدرجة بشكل مناسب — اعتبار تصميمي لا شيء يحدث بالصدفة.

**تتبع الأعطال عمليًا باستخدام الحماية نفسها.** الجهاز الذي فصل دليل:
- **فصل ريليه الحمل الزائد وحماية القصر سليمة** — تيار زائد معتدل مستمر. ابحث عن مشكلة ميكانيكية في الآلة المُدارة، أو محمل يتلف، أو طور مفقود، أو محرك محمّل فعلًا فوق طاقته.
- **عملت حماية القصر** — عطل حقيقي. فشل عزل، أو كابل تالف، أو دخول ماء، أو خطأ تسليك. لا تُصفِّر وتعيد التغذية ببساطة؛ اعثر على العطل أولًا، فإعادة التغذية على قصر خطيرة.
- **فصل ريليه الثرمستور والحمل الزائد سليم** — المحرك ساخن لكن التيار طبيعي. افحص التهوية والحرارة المحيطة ودورة التشغيل وتواتر البدء. هذا التركيب يشير تحديدًا بعيدًا عن حمل زائد كهربائي.
- **لم يفصل شيء لكن المحرك متوقف** — العطل في دائرة التحكم لا دائرة القوى. افحص الملف وتغذية التحكم وسلسلة الإيقاف والتثبيت.

وتستحق الحالة الأخيرة التأكيد، لأنها حيث يؤتي فصل دائرتي القوى والتحكم من برنامج الكونتاكتورات ثماره مباشرة. فمعرفة أي دائرة تختبر أولًا، مما *لم* يفصل، توفر وقتًا هائلًا.

**انضباط في التشغيل التجريبي.** سجّل ضبطات كل جهاز حماية في جدول اللوحة عند التشغيل التجريبي. فحين يرفع أحدهم لاحقًا ضبط حمل زائد لإيقاف فصل مزعج، يجعل السجل ذلك التغيير مرئيًا. فضبطات الحماية غير الموثقة تنحرف صعودًا عبر عمر اللوحة، وكل زيادة غير مرئية حتى يحترق محرك.$c$,
2
FROM public.modules WHERE slug = 'finix-motor-protection';

-- Quizzes I03
INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'bronze', 'Protection Basics', 'أساسيات الحماية', 80
FROM public.modules WHERE slug = 'finix-motor-protection';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$Why can a single device not provide both overload and short-circuit protection equally well?$q$,
    $q$لماذا لا يوفر جهاز واحد حماية الحمل الزائد والقصر بالكفاءة ذاتها؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-motor-protection' AND quizzes.tier = 'bronze' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Overload needs slow time-dependent response; short circuit needs instant high-capacity breaking$o$, $o$الحمل الزائد يحتاج استجابة بطيئة معتمدة على الزمن؛ والقصر يحتاج قطعًا فوريًا عالي السعة$o$, true, 1),
  ($o$Because regulations forbid combined devices$o$, $o$لأن اللوائح تمنع الأجهزة المدمجة$o$, false, 2),
  ($o$Short circuits do not occur on motor circuits$o$, $o$القصر لا يحدث في دوائر المحركات$o$, false, 3),
  ($o$One device can do both equally well$o$, $o$جهاز واحد يؤدي الاثنين بالكفاءة ذاتها$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$Does a thermal overload relay itself interrupt the motor current?$q$,
    $q$هل يقطع ريليه الحمل الزائد الحراري تيار المحرك بنفسه؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-motor-protection' AND quizzes.tier = 'bronze' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$No — its contact de-energises the contactor coil, and the contactor does the switching$o$, $o$لا — تلامسه يقطع تغذية ملف الكونتاكتور، والكونتاكتور يقوم بالتبديل$o$, true, 1),
  ($o$Yes, it breaks the main current directly$o$, $o$نعم، يقطع التيار الرئيسي مباشرة$o$, false, 2),
  ($o$Only on single-phase motors$o$, $o$فقط في المحركات أحادية الطور$o$, false, 3),
  ($o$Only when set to automatic reset$o$, $o$فقط عند ضبطه على التصفير التلقائي$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$What happens to a three-phase motor that loses one phase while running?$q$,
    $q$ماذا يحدث لمحرك ثلاثي الأطوار يفقد طورًا أثناء التشغيل؟$q$, 3
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-motor-protection' AND quizzes.tier = 'bronze' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$It keeps running on two phases, drawing much higher current and overheating$o$, $o$يستمر بالدوران على طورين، ساحبًا تيارًا أعلى بكثير فيسخن$o$, true, 1),
  ($o$It stops immediately and safely$o$, $o$يتوقف فورًا وبأمان$o$, false, 2),
  ($o$It runs normally with no ill effect$o$, $o$يعمل طبيعيًا بلا أثر سيئ$o$, false, 3),
  ($o$It speeds up$o$, $o$تزداد سرعته$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'silver', 'Applying Protection', 'تطبيق الحماية', 80
FROM public.modules WHERE slug = 'finix-motor-protection';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$A motor keeps nuisance-tripping its overload. A technician winds the setting up until it stops. What is wrong with this?$q$,
    $q$محرك يفصل حمله الزائد بإزعاج متكرر. يرفع فني الضبط حتى يتوقف الفصل. ما الخطأ في هذا؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-motor-protection' AND quizzes.tier = 'silver' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$It removes the protection instead of finding why current is high; the motor can now burn out undetected$o$, $o$يزيل الحماية بدل معرفة سبب ارتفاع التيار؛ فيمكن أن يحترق المحرك دون اكتشاف$o$, true, 1),
  ($o$Nothing — this is standard practice$o$, $o$لا شيء — هذه ممارسة قياسية$o$, false, 2),
  ($o$It voids the contactor warranty only$o$, $o$يُبطل ضمان الكونتاكتور فقط$o$, false, 3),
  ($o$Overload settings have no effect on protection$o$, $o$ضبطات الحمل الزائد لا تؤثر على الحماية$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$A VFD-fed motor runs continuously at low speed. Why is a thermal overload relay inadequate protection here?$q$,
    $q$محرك مغذّى من مغيّر تردد يعمل باستمرار بسرعة منخفضة. لماذا لا يكفي ريليه الحمل الزائد الحراري هنا؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-motor-protection' AND quizzes.tier = 'silver' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$The shaft-mounted cooling fan turns slowly so cooling collapses, yet current stays normal$o$, $o$مروحة التبريد على العمود تدور ببطء فينهار التبريد، بينما يبقى التيار طبيعيًا$o$, true, 1),
  ($o$VFDs prevent overload relays from operating$o$, $o$مغيّرات التردد تمنع عمل ريليهات الحمل الزائد$o$, false, 2),
  ($o$Low-speed running always draws excessive current$o$, $o$التشغيل بسرعة منخفضة يسحب دائمًا تيارًا مفرطًا$o$, false, 3),
  ($o$Overload relays cannot be used with drives at all$o$, $o$لا يمكن استخدام ريليهات الحمل الزائد مع المغيّرات إطلاقًا$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$Nothing has tripped, but the motor will not start. Where should you test first?$q$,
    $q$لم يفصل شيء، لكن المحرك لا يبدأ. أين تختبر أولًا؟$q$, 3
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-motor-protection' AND quizzes.tier = 'silver' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$The control circuit — coil, control supply, stop chain and latch$o$, $o$دائرة التحكم — الملف وتغذية التحكم وسلسلة الإيقاف والتثبيت$o$, true, 1),
  ($o$The motor windings$o$, $o$ملفات المحرك$o$, false, 2),
  ($o$The upstream distribution transformer$o$, $o$محول التوزيع الأمامي$o$, false, 3),
  ($o$Replace the contactor immediately$o$, $o$استبدل الكونتاكتور فورًا$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'gold', 'Protection Strategy', 'استراتيجية الحماية', 80
FROM public.modules WHERE slug = 'finix-motor-protection';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$A fault on one motor trips the main distribution breaker and blacks out the whole panel. What has gone wrong?$q$,
    $q$عطل في محرك واحد يفصل قاطع التوزيع الرئيسي ويُظلم اللوحة كلها. ما الخطأ؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-motor-protection' AND quizzes.tier = 'gold' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Protection is not coordinated — the device nearest the fault should operate first$o$, $o$الحماية غير منسقة — ينبغي أن يعمل الجهاز الأقرب للعطل أولًا$o$, true, 1),
  ($o$The main breaker is faulty and should be replaced$o$, $o$القاطع الرئيسي معطوب وينبغي استبداله$o$, false, 2),
  ($o$This is normal and unavoidable$o$, $o$هذا طبيعي وحتمي$o$, false, 3),
  ($o$The motor was too small for its circuit$o$, $o$المحرك أصغر من دائرته$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$When must thermistors be specified, and why can they not simply be added later?$q$,
    $q$متى يجب تحديد الثرمستورات، ولماذا لا يمكن إضافتها لاحقًا ببساطة؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-motor-protection' AND quizzes.tier = 'gold' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$At purchase, for drive-fed, hot-environment or frequently-started motors — they are embedded in the windings during manufacture$o$, $o$عند الشراء، للمحركات المغذّاة من مغيّر أو في بيئات حارة أو كثيرة البدء — فهي مغروسة في الملفات أثناء التصنيع$o$, true, 1),
  ($o$Any time; they clip onto the motor casing$o$, $o$في أي وقت؛ تُثبَّت على غلاف المحرك$o$, false, 2),
  ($o$Only for single-phase motors$o$, $o$فقط للمحركات أحادية الطور$o$, false, 3),
  ($o$They are never needed if an overload relay is fitted$o$, $o$لا تلزم أبدًا إن رُكّب ريليه حمل زائد$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$Why is manual reset usually preferred over automatic reset on an overload relay?$q$,
    $q$لماذا يُفضَّل التصفير اليدوي عادة على التلقائي في ريليه الحمل الزائد؟$q$, 3
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-motor-protection' AND quizzes.tier = 'gold' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$It forces someone to inspect before restarting and prevents a developing fault from being masked by repeated auto-restarts$o$, $o$يُجبر أحدًا على الفحص قبل إعادة التشغيل ويمنع إخفاء عطل ناشئ بإعادة تشغيل تلقائية متكررة$o$, true, 1),
  ($o$Automatic reset damages the bimetallic strips$o$, $o$التصفير التلقائي يتلف الشرائح ثنائية المعدن$o$, false, 2),
  ($o$Manual reset trips faster$o$, $o$التصفير اليدوي يفصل أسرع$o$, false, 3),
  ($o$There is no practical difference between them$o$, $o$لا فرق عملي بينهما$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);
