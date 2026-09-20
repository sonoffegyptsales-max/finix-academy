-- Module I02: Motor Starting Methods
-- ORIGINAL CONTENT written for Finix.

INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES (
  'finix-motor-starting-methods',
  'I02',
  'finix-industrial-control',
  'Motor Starting Methods',
  'طرق بدء المحركات',
  $s$Why starting current is the problem, and the methods that solve it: direct-on-line, star-delta, two-speed windings and Dahlander, soft starters and variable frequency drives — with the selection logic for choosing between them.$s$,
  $s$لماذا تيار البدء هو المشكلة، والطرق التي تحلها: البدء المباشر، نجمة/دلتا، الملفات ثنائية السرعة ودالاندر، البادئ الناعم ومغيّر التردد — مع منطق الاختيار بينها.$s$,
  NULL,
  29
)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$The Starting Current Problem$t$,
$t$مشكلة تيار البدء$t$,
$c$Every method in this module exists to solve one problem: a three-phase induction motor connected directly to the supply draws far more current at the instant of starting than it does when running.

**Why it happens.** At standstill the rotor is not turning, so it is not generating the back-EMF that normally opposes the supply voltage and limits current. Electrically, a stationary motor looks close to a short circuit. As the rotor accelerates, back-EMF builds and the current falls toward its normal running value. The inrush is brief — seconds at most — but it is large, typically several times full-load current.

**Why brief and large is still a problem.** Four separate consequences, and a competent installer should be able to name all of them:

1. **Voltage dip on the supply.** A large starting current through the impedance of the supply cable and transformer causes a voltage drop that everything else on that supply experiences. Lights dim, other motors labour, and sensitive electronics can reset. In a building with a weak supply, starting one large motor can disturb an entire floor.
2. **Thermal stress in the motor.** Heating in a conductor rises with the square of current, so a starting current several times running current produces heating many times greater. One start is harmless. Repeated starts in quick succession accumulate heat faster than the motor can dissipate it, which is why motor data specifies a maximum number of starts per hour.
3. **Mechanical shock.** Direct starting applies full torque almost instantly. The driven machine receives a violent jolt through the coupling — hard on gearboxes, belts, couplings and anything carrying a load. On a pump it produces water hammer; on a conveyor it can shift or damage the load.
4. **Supply authority limits.** Utilities frequently impose a limit on the size of motor that may be started direct-on-line, precisely because of the disturbance it causes to other customers. Exceeding that limit is not merely impolite — it can breach the connection agreement.

**Direct-on-line starting, and when it is correct.** DOL is the simplest method: one contactor, one overload relay, full voltage applied immediately. It gives full starting torque, costs least, and has the fewest components to fail.

It is entirely appropriate for small motors, for loads that need full torque from standstill, and where the supply is strong relative to the motor. The engineering question is not "is DOL bad" — it is "is this motor small enough, and this supply strong enough, that the inrush does not matter here?" For a great many small pumps and fans, the answer is yes, and fitting a more complex starter would add failure modes for no benefit.

**Reduced-voltage starting — the general principle.** Every alternative reduces the voltage applied to the windings during starting. Reducing voltage reduces current, which is the goal — but it also reduces torque, and torque falls more steeply than current does.

This is the central trade-off of the entire module: **you cannot reduce starting current without also reducing starting torque.** Therefore every reduced-voltage method carries the same risk — if you reduce the voltage too far for the load, the motor will not accelerate. It will sit drawing heavy current at low speed, heating rapidly, achieving nothing, until the overload trips or something burns.

**Load type determines what is possible.** The load's torque demand at low speed decides which methods are viable:
- A **fan or centrifugal pump** demands little torque at low speed, rising steeply with speed. These accelerate happily on reduced voltage and are ideal candidates.
- A **loaded conveyor, a crusher, or a compressor starting against pressure** demands substantial torque from standstill. Reduced-voltage starting may leave it unable to move at all.

Before selecting a starting method, you must know what the motor is driving. Selecting star-delta for a loaded conveyor because it worked on the last job is how installations fail on commissioning day.

**Nameplate data you need before choosing.** The motor's rated voltage and connection, full-load current, and the supply voltage together determine which methods are even available. A motor whose delta rating does not match the supply voltage cannot be star-delta started at all — a point covered in the next lesson, and one of the most common specification errors in the field.$c$,
$c$كل طريقة في هذا البرنامج وُجدت لحل مشكلة واحدة: المحرك الحثي ثلاثي الأطوار الموصَّل مباشرة بالتغذية يسحب لحظة البدء تيارًا أكبر بكثير مما يسحبه أثناء التشغيل.

**لماذا يحدث ذلك.** عند السكون لا يدور العضو الدوار، فلا يولّد القوة الدافعة العكسية التي تعارض جهد التغذية وتحد التيار عادة. وكهربائيًا يبدو المحرك الساكن قريبًا من قصر. ومع تسارع العضو الدوار تتنامى القوة العكسية وينخفض التيار نحو قيمة تشغيله العادية. والاندفاع قصير — ثوانٍ على الأكثر — لكنه كبير، وعادة أضعاف تيار الحمل الكامل.

**لماذا يبقى القصير الكبير مشكلة.** أربع عواقب منفصلة، وينبغي للمركّب الكفء أن يسميها جميعًا:

1. **هبوط الجهد على التغذية.** تيار بدء كبير عبر ممانعة كابل التغذية والمحول يسبب هبوط جهد يختبره كل ما عداه على تلك التغذية. فتخفت الأضواء، وتجهد محركات أخرى، وقد تُعاد تهيئة إلكترونيات حساسة. وفي مبنى بتغذية ضعيفة، قد يزعج بدء محرك كبير طابقًا بأكمله.
2. **إجهاد حراري في المحرك.** التسخين في موصل يرتفع بمربع التيار، فتيار بدء يعادل أضعاف تيار التشغيل ينتج تسخينًا أضعافًا مضاعفة. بدء واحد غير ضار. لكن البدءات المتكررة المتلاحقة تراكم حرارة أسرع مما يبددها المحرك، ولهذا تحدد بيانات المحرك أقصى عدد بدءات في الساعة.
3. **صدمة ميكانيكية.** البدء المباشر يطبّق العزم الكامل فورًا تقريبًا. فتتلقى الآلة المُدارة ارتجاجًا عنيفًا عبر القارنة — قاسٍ على صناديق التروس والسيور والقارنات وكل ما يحمل حملًا. وفي مضخة ينتج مطرقة مائية؛ وفي سير ناقل قد يزيح الحمل أو يتلفه.
4. **حدود شركة الكهرباء.** تفرض المرافق غالبًا حدًا لحجم المحرك الذي يجوز بدؤه مباشرة، تحديدًا بسبب الاضطراب الذي يسببه لعملاء آخرين. وتجاوز ذلك الحد ليس قلة لياقة فحسب — بل قد يخالف اتفاق التوصيل.

**البدء المباشر ومتى يكون صحيحًا.** البدء المباشر أبسط الطرق: كونتاكتور واحد، وريليه حمل زائد واحد، وجهد كامل يُطبَّق فورًا. يعطي عزم بدء كاملًا، وأقل تكلفة، وأقل عدد مكونات قابلة للتلف.

وهو مناسب تمامًا للمحركات الصغيرة، وللأحمال التي تحتاج عزمًا كاملًا من السكون، وحيث تكون التغذية قوية نسبةً للمحرك. والسؤال الهندسي ليس "هل البدء المباشر سيئ" بل "هل هذا المحرك صغير بما يكفي، وهذه التغذية قوية بما يكفي، ليصبح الاندفاع غير مهم هنا؟" ولعدد كبير من المضخات والمراوح الصغيرة، الجواب نعم، وتركيب بادئ أعقد سيضيف حالات فشل بلا فائدة.

**البدء بجهد مخفّض — المبدأ العام.** كل بديل يقلل الجهد المطبَّق على الملفات أثناء البدء. وتقليل الجهد يقلل التيار، وهو الهدف — لكنه يقلل العزم أيضًا، والعزم يهبط بحدة أكبر من التيار.

وهذه هي المقايضة المحورية للبرنامج كله: **لا يمكنك تقليل تيار البدء دون تقليل عزم البدء أيضًا.** لذا تحمل كل طريقة جهد مخفّض المخاطرة ذاتها — فإن قللت الجهد أكثر مما يحتمل الحمل، لن يتسارع المحرك. سيبقى ساحبًا تيارًا ثقيلًا بسرعة منخفضة، يسخن بسرعة، دون إنجاز شيء، حتى يفصل الحمل الزائد أو يحترق شيء.

**نوع الحمل يحدد ما هو ممكن.** طلب الحمل للعزم عند السرعة المنخفضة يقرر أي الطرق صالحة:
- **المروحة أو المضخة الطاردة المركزية** تطلب عزمًا ضئيلًا عند السرعة المنخفضة، يرتفع بحدة مع السرعة. وهذه تتسارع بسهولة على جهد مخفّض وهي مرشحة مثالية.
- **السير الناقل المحمّل أو الكسّارة أو الضاغط الذي يبدأ مقابل ضغط** يطلب عزمًا كبيرًا من السكون. والبدء بجهد مخفّض قد يتركه عاجزًا عن الحركة إطلاقًا.

وقبل اختيار طريقة بدء، يجب أن تعرف ماذا يُدير المحرك. واختيار نجمة/دلتا لسير ناقل محمّل لأنها نجحت في المشروع السابق هو كيف تفشل التركيبات يوم التشغيل التجريبي.

**بيانات لوحة الاسم التي تحتاجها قبل الاختيار.** جهد المحرك المقنن وتوصيله، وتيار الحمل الكامل، وجهد التغذية تحدد معًا أي الطرق متاحة أصلًا. والمحرك الذي لا يطابق تصنيف دلتا فيه جهد التغذية لا يمكن بدؤه بنجمة/دلتا إطلاقًا — نقطة يغطيها الدرس التالي، وهي من أشيع أخطاء المواصفات ميدانيًا.$c$,
1
FROM public.modules WHERE slug = 'finix-motor-starting-methods';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$Star-Delta Starting in Practice$t$,
$t$البدء بنجمة/دلتا عمليًا$t$,
$c$Star-delta is the classic electromechanical reduced-voltage starter. The timing sequence was covered in the timers module; this lesson is about the practical decisions that determine whether it will work at all on a given job.

**The principle.** A three-phase motor's stator has three windings. Connected in **star**, each winding sees the supply voltage divided by the square root of three — roughly 58% of the line voltage. Connected in **delta**, each winding sees the full line voltage.

Starting in star therefore applies substantially reduced voltage to each winding, reducing starting current to roughly a third of what direct-on-line would draw. Once the motor is near running speed, switching to delta applies full voltage for normal operation.

**The torque consequence, stated plainly.** Torque falls with the square of voltage. Applying roughly 58% voltage gives roughly one third of the direct-on-line starting torque. That is a large reduction, and it is why star-delta is unsuitable for loads demanding high starting torque.

**The prerequisite that disqualifies many motors.** For star-delta to work, the motor must be able to run **in delta** at the supply voltage. A motor's nameplate typically states two voltages — the lower for delta connection, the higher for star. Star-delta starting is possible only when the **delta** figure matches your supply.

If the motor's delta rating does not match the supply, star-delta starting is simply not available, regardless of how convenient it would be. Checking this on the nameplate before quoting is essential. It is one of the most common specification errors, and it is usually discovered on site with the panel already built.

**Six cables, not three.** Star-delta requires access to both ends of all three windings, so the motor terminal box must bring out six terminals. A motor with only three terminals brought out has its connection made internally and cannot be star-delta started.

**Open transition and its current surge.** The standard arrangement is open transition: the star contactor opens, there is a brief dead time, then the delta contactor closes. During that dead time the motor is disconnected from the supply and begins to slow. When delta closes, the motor's residual magnetism is no longer synchronised with the supply, which produces a **current surge at transition** — sometimes approaching the direct-on-line inrush the starter was installed to avoid.

This surprises people. A star-delta starter reduces the *initial* inrush effectively, but if the transition happens too early — before the motor has accelerated properly — the transition surge can be severe. This is precisely why the star period must be set correctly and verified by measurement rather than copied from another panel.

**Overload relay placement.** In a star-delta starter, the overload relay is normally placed in the winding circuit rather than the line, which means it measures winding current, not line current. Winding current in delta is lower than line current by a factor of the square root of three. Setting the overload to the motor's full-load *line* current when it is measuring *winding* current will set the protection far too high, leaving the motor effectively unprotected.

This is a genuine and dangerous error. When commissioning a star-delta starter, establish which current the relay actually sees before setting it.

**Commissioning checklist.**
1. Confirm the motor's delta voltage matches the supply.
2. Confirm six terminals are available and the links are removed.
3. Verify the interlock physically prevents star and delta closing together.
4. Set the overload according to what it measures, not the nameplate line current by default.
5. Time the star period and observe the transition. A sharp surge and mechanical jolt means transfer is happening too early.
6. Record the measured star time against the specific machine.

**Why modern practice is moving away from it.** Star-delta has real limitations: fixed torque reduction with no adjustment, a transition surge, the six-cable requirement, and unsuitability for high-torque loads. Soft starters and variable frequency drives control the acceleration profile continuously and remove the discrete transition entirely.

Star-delta remains common because it is inexpensive, robust, and entirely understood — and there are many existing installations. A technician in Egypt today needs to be fluent in both: able to maintain the star-delta panels already in service, and able to explain to a client why their replacement should probably be a soft starter or a drive.$c$,
$c$نجمة/دلتا هو البادئ الكهروميكانيكي الكلاسيكي بجهد مخفّض. وقد غُطي تتابع التوقيت في برنامج المؤقتات؛ وهذا الدرس عن القرارات العملية التي تحدد هل ستعمل أصلًا في مشروع بعينه.

**المبدأ.** العضو الثابت لمحرك ثلاثي الأطوار به ثلاثة ملفات. وبتوصيل **النجمة** يرى كل ملف جهد التغذية مقسومًا على الجذر التربيعي لثلاثة — نحو 58٪ من جهد الخط. وبتوصيل **الدلتا** يرى كل ملف جهد الخط الكامل.

لذا فالبدء على النجمة يطبّق جهدًا مخفّضًا كثيرًا على كل ملف، فيقلل تيار البدء إلى نحو ثلث ما كان البدء المباشر سيسحبه. وبعد أن يقترب المحرك من سرعة التشغيل، يطبّق التحويل لدلتا الجهد الكامل للتشغيل العادي.

**نتيجة العزم بوضوح.** العزم يهبط بمربع الجهد. وتطبيق نحو 58٪ من الجهد يعطي نحو ثلث عزم البدء المباشر. وهذا تخفيض كبير، ولهذا لا تصلح نجمة/دلتا للأحمال التي تطلب عزم بدء عاليًا.

**الشرط المسبق الذي يستبعد كثيرًا من المحركات.** لتعمل نجمة/دلتا، يجب أن يكون المحرك قادرًا على العمل **على دلتا** عند جهد التغذية. ولوحة اسم المحرك تذكر عادة جهدين — الأدنى لتوصيل دلتا والأعلى للنجمة. والبدء بنجمة/دلتا ممكن فقط حين يطابق رقم **دلتا** تغذيتك.

فإن لم يطابق تصنيف دلتا للمحرك التغذية، فالبدء بنجمة/دلتا غير متاح ببساطة، مهما كان ملائمًا. والتحقق من ذلك على لوحة الاسم قبل التسعير ضروري. وهو من أشيع أخطاء المواصفات، ويُكتشف عادة في الموقع واللوحة مبنية بالفعل.

**ستة كابلات لا ثلاثة.** تتطلب نجمة/دلتا الوصول لطرفي الملفات الثلاثة، فيجب أن يُخرج صندوق أطراف المحرك ستة أطراف. والمحرك الذي يخرج منه ثلاثة أطراف فقط توصيله داخلي ولا يمكن بدؤه بنجمة/دلتا.

**الانتقال المفتوح واندفاع تياره.** الترتيب القياسي انتقال مفتوح: يُفتح كونتاكتور النجمة، ثم زمن ميت قصير، ثم يُغلق كونتاكتور الدلتا. وخلال ذلك الزمن الميت ينفصل المحرك عن التغذية ويبدأ بالتباطؤ. وحين تُغلق الدلتا، لا تكون مغناطيسية المحرك المتبقية متزامنة مع التغذية، ما ينتج **اندفاع تيار عند الانتقال** — يقارب أحيانًا اندفاع البدء المباشر الذي رُكّب البادئ لتجنبه.

وهذا يفاجئ الناس. فبادئ نجمة/دلتا يقلل الاندفاع *الابتدائي* بفعالية، لكن إن حدث الانتقال مبكرًا جدًا — قبل تسارع المحرك كما ينبغي — قد يكون اندفاع الانتقال شديدًا. ولهذا بالضبط يجب ضبط فترة النجمة بشكل صحيح والتحقق منها بالقياس لا بالنسخ من لوحة أخرى.

**موضع ريليه الحمل الزائد.** في بادئ نجمة/دلتا، يوضع ريليه الحمل الزائد عادة في دائرة الملفات لا الخط، ما يعني أنه يقيس تيار الملف لا تيار الخط. وتيار الملف في دلتا أقل من تيار الخط بعامل الجذر التربيعي لثلاثة. وضبط الحمل الزائد على تيار الحمل الكامل *للخط* بينما يقيس تيار *الملف* سيضبط الحماية أعلى بكثير مما ينبغي، تاركًا المحرك بلا حماية فعليًا.

وهذا خطأ حقيقي وخطير. فعند التشغيل التجريبي لبادئ نجمة/دلتا، حدد أي تيار يراه الريليه فعلًا قبل ضبطه.

**قائمة فحص التشغيل التجريبي.**
1. تأكد أن جهد دلتا للمحرك يطابق التغذية.
2. تأكد من توفر ستة أطراف وإزالة الوصلات.
3. تحقق أن التعشيق يمنع فعليًا انغلاق النجمة والدلتا معًا.
4. اضبط الحمل الزائد وفق ما يقيسه، لا وفق تيار خط لوحة الاسم افتراضيًا.
5. قِس فترة النجمة وراقب الانتقال. فالاندفاع الحاد والارتجاج الميكانيكي يعنيان انتقالًا مبكرًا جدًا.
6. سجّل زمن النجمة المقاس مقابل الماكينة بعينها.

**لماذا تبتعد الممارسة الحديثة عنه.** لنجمة/دلتا قيود حقيقية: تخفيض عزم ثابت بلا ضبط، واندفاع انتقال، واشتراط ستة كابلات، وعدم صلاحية للأحمال عالية العزم. والبادئات الناعمة ومغيّرات التردد تتحكم بمنحنى التسارع باستمرار وتلغي الانتقال المنفصل تمامًا.

وتبقى نجمة/دلتا شائعة لأنها رخيصة ومتينة ومفهومة تمامًا — ولوجود تركيبات قائمة كثيرة. والفني في مصر اليوم يحتاج إتقان الاثنين: قادرًا على صيانة لوحات نجمة/دلتا العاملة بالفعل، وقادرًا على شرح لماذا ينبغي أن يكون بديلها على الأرجح بادئًا ناعمًا أو مغيّر تردد.$c$,
2
FROM public.modules WHERE slug = 'finix-motor-starting-methods';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$Two-Speed Motors, Soft Starters and Drives$t$,
$t$المحركات ثنائية السرعة والبادئات الناعمة والمغيّرات$t$,
$c$Beyond simply starting a motor, many applications need it to run at more than one speed — and the modern answer to both starting and speed control is increasingly the same device.

**Two-speed motors: changing speed by changing poles.** An induction motor's synchronous speed is set by the supply frequency and the number of magnetic poles in the stator. With a fixed supply frequency, changing the number of poles changes the speed. Two approaches exist:

**Separate windings.** The stator contains two entirely independent windings with different pole counts. Selecting one or the other gives two speeds, and because the windings are independent, the two speeds can be in any ratio the designer chose. The cost is a physically larger, heavier and more expensive motor, since it carries two complete windings of which only one is ever in use.

**Dahlander (pole-changing) winding.** A single winding whose coils are reconnected by external switching to present a different number of poles. It is more economical than two separate windings, but it can only produce a **2:1 speed ratio** — the higher speed is exactly double the lower. If an application needs any ratio other than 2:1, a Dahlander motor cannot provide it.

That constraint is the key selection fact. A client wanting a 3:1 speed ratio needs separate windings or a drive, and knowing this before quoting avoids ordering the wrong motor.

**Control requirements for two-speed motors.** Switching between speeds requires contactors that must be interlocked — the same mutual-exclusion principle from the contactors module, since energising two speed configurations simultaneously would short the winding. Changing from high to low speed also needs care: the motor is spinning faster than the new configuration's synchronous speed and will act briefly as a generator, producing a current surge and a mechanical jolt. Good practice inserts a delay when stepping down.

**Soft starters.** A soft starter uses electronic switching devices to gradually increase the voltage applied to the motor over a set ramp time, rather than in discrete steps. The result is smooth acceleration with controlled current and no transition surge.

Advantages over star-delta: the ramp time and the initial voltage are adjustable, so the start can be tuned to the actual load rather than accepting a fixed reduction; there is no transition surge; it works on a three-terminal motor; and many units offer a soft *stop*, which is valuable on pumps because it prevents water hammer.

Limitations: a soft starter controls voltage, not frequency. It reduces starting current and mechanical shock, but it cannot control running speed. Once the motor is at full speed, a soft starter is doing nothing — most include a bypass contactor that shorts out the electronics during normal running to avoid unnecessary heat and losses.

**Variable frequency drives.** A VFD converts the incoming AC supply to DC and then synthesises a new AC output at whatever frequency and voltage it chooses. Since motor speed follows supply frequency, this gives continuous speed control across the full range, plus inherently soft starting because the drive can begin at a low frequency and ramp up.

Where a VFD is genuinely the right answer:
- **Variable speed is needed in normal operation** — a pump matching output to demand, a fan matching airflow to conditions, a conveyor running at different rates.
- **Energy saving on centrifugal loads** — for pumps and fans, the power drawn falls very steeply as speed reduces. Running a fan at reduced speed rather than full speed with a damper throttling the flow produces substantial savings, which is often the entire commercial justification.
- **Precise process control** is required.

Limitations and cautions worth stating to a client:
- VFDs generate electrical noise that can disturb other equipment; proper installation practice — screened motor cable correctly terminated, and attention to earthing — is not optional.
- The motor must be suitable for drive operation; running a standard motor continuously at low speed reduces its own cooling, since most motors are cooled by a fan on their own shaft.
- A drive is a more complex device than a contactor, with settings that can be mis-programmed and electronics that fail differently from electromechanical gear.

**Choosing between them — the practical decision path.**
1. Does the application need **variable speed in normal running**? If yes, a VFD, and the starting question answers itself.
2. If only starting matters: is the motor small enough and the supply strong enough for **DOL**? If yes, use it — simplest is best.
3. If starting current must be reduced: does the load need **high starting torque**? If yes, star-delta is likely unsuitable; consider a soft starter or a drive.
4. If the load is a fan or centrifugal pump and cost dominates, **star-delta** remains viable — provided the motor's delta rating matches the supply and six terminals are available.
5. If adjustability, soft stopping, or a three-terminal motor matters, a **soft starter** is the better electromechanical replacement.

Being able to walk a client through that sequence, with reasons, is what distinguishes specifying a starter from guessing at one.$c$,
$c$أبعد من مجرد بدء محرك، تحتاج تطبيقات كثيرة تشغيله بأكثر من سرعة — والإجابة الحديثة للبدء والتحكم بالسرعة تصبح الجهاز ذاته بشكل متزايد.

**المحركات ثنائية السرعة: تغيير السرعة بتغيير الأقطاب.** السرعة التزامنية للمحرك الحثي يحددها تردد التغذية وعدد الأقطاب المغناطيسية في العضو الثابت. وبتردد تغذية ثابت، يغيّر تغيير عدد الأقطاب السرعة. وتوجد طريقتان:

**ملفات منفصلة.** يحتوي العضو الثابت ملفين مستقلين تمامًا بعددي أقطاب مختلفين. واختيار أحدهما يعطي سرعتين، ولأن الملفين مستقلان يمكن أن تكون السرعتان بأي نسبة اختارها المصمم. والتكلفة محرك أكبر وأثقل وأغلى ماديًا، لأنه يحمل ملفين كاملين لا يُستخدم منهما إلا واحد.

**ملف دالاندر (تغيير الأقطاب).** ملف واحد تُعاد توصيلات ملفاته بتبديل خارجي ليقدّم عدد أقطاب مختلفًا. أوفر من ملفين منفصلين، لكنه ينتج **نسبة سرعة 2:1** فقط — فالسرعة الأعلى ضعف الأدنى بالضبط. وإن احتاج تطبيق أي نسبة غير 2:1، فمحرك دالاندر لا يوفرها.

وهذا القيد هو حقيقة الاختيار المحورية. فالعميل الذي يريد نسبة 3:1 يحتاج ملفات منفصلة أو مغيّر تردد، ومعرفة ذلك قبل التسعير تجنّب طلب المحرك الخطأ.

**متطلبات التحكم للمحركات ثنائية السرعة.** التبديل بين السرعات يتطلب كونتاكتورات يجب تعشيقها — مبدأ الاستبعاد المتبادل ذاته من برنامج الكونتاكتورات، إذ إن تغذية تكوينَي سرعة معًا ستقصّر الملف. وتغيير السرعة من عالية لمنخفضة يحتاج حذرًا أيضًا: فالمحرك يدور أسرع من السرعة التزامنية للتكوين الجديد وسيعمل لحظيًا كمولّد، منتجًا اندفاع تيار وارتجاجًا ميكانيكيًا. والممارسة الجيدة تُدخل تأخيرًا عند الهبوط.

**البادئات الناعمة.** يستخدم البادئ الناعم عناصر تبديل إلكترونية لزيادة الجهد المطبَّق على المحرك تدريجيًا عبر زمن منحدر محدد، بدل خطوات منفصلة. والنتيجة تسارع سلس بتيار محكوم وبلا اندفاع انتقال.

مزايا على نجمة/دلتا: زمن المنحدر والجهد الابتدائي قابلان للضبط، فيمكن معايرة البدء للحمل الفعلي بدل قبول تخفيض ثابت؛ ولا يوجد اندفاع انتقال؛ ويعمل على محرك بثلاثة أطراف؛ وكثير من الوحدات توفر *إيقافًا* ناعمًا، وهو قيّم للمضخات لأنه يمنع المطرقة المائية.

القيود: البادئ الناعم يتحكم بالجهد لا التردد. فيقلل تيار البدء والصدمة الميكانيكية، لكنه لا يتحكم بسرعة التشغيل. وبعد وصول المحرك للسرعة الكاملة لا يفعل البادئ الناعم شيئًا — ويتضمن أغلبها كونتاكتور تجاوز يقصّر الإلكترونيات أثناء التشغيل العادي لتجنب حرارة وفقد لا لزوم لهما.

**مغيّرات التردد.** يحوّل مغيّر التردد تغذية المتردد الداخلة إلى مستمر ثم يصطنع خرج متردد جديدًا بأي تردد وجهد يختارهما. ولأن سرعة المحرك تتبع تردد التغذية، يعطي هذا تحكمًا مستمرًا بالسرعة عبر المدى الكامل، وبدءًا ناعمًا بطبيعته لأن المغيّر يمكنه البدء بتردد منخفض والصعود تدريجيًا.

وحيث يكون مغيّر التردد هو الإجابة الصحيحة فعلًا:
- **الحاجة لسرعة متغيرة في التشغيل العادي** — مضخة تطابق خرجها بالطلب، أو مروحة تطابق التدفق بالظروف، أو سير ناقل يعمل بمعدلات مختلفة.
- **توفير الطاقة في الأحمال الطاردة المركزية** — ففي المضخات والمراوح تهبط القدرة المسحوبة بحدة شديدة مع انخفاض السرعة. وتشغيل مروحة بسرعة مخفّضة بدل السرعة الكاملة مع خانق يقيّد التدفق ينتج توفيرًا كبيرًا، وهو غالبًا المبرر التجاري بأكمله.
- **الحاجة لتحكم دقيق بالعملية.**

قيود ومحاذير تستحق التصريح بها للعميل:
- تولّد مغيّرات التردد ضوضاء كهربائية قد تزعج معدات أخرى؛ وممارسة التركيب السليمة — كابل محرك مدرّع منهىً بشكل صحيح، والاهتمام بالتأريض — ليست اختيارية.
- يجب أن يكون المحرك مناسبًا للعمل مع مغيّر؛ فتشغيل محرك قياسي باستمرار بسرعة منخفضة يقلل تبريده الذاتي، لأن أغلب المحركات تُبرَّد بمروحة على عمودها.
- المغيّر جهاز أعقد من الكونتاكتور، بضبطات يمكن برمجتها خطأً وإلكترونيات تفشل بشكل مختلف عن الأجهزة الكهروميكانيكية.

**الاختيار بينها — مسار القرار العملي.**
1. هل يحتاج التطبيق **سرعة متغيرة في التشغيل العادي**؟ إن نعم، فمغيّر تردد، ويجيب سؤال البدء عن نفسه.
2. وإن كان البدء وحده المهم: هل المحرك صغير بما يكفي والتغذية قوية بما يكفي **للبدء المباشر**؟ إن نعم فاستخدمه — الأبسط أفضل.
3. وإن وجب تقليل تيار البدء: هل يحتاج الحمل **عزم بدء عاليًا**؟ إن نعم فنجمة/دلتا غالبًا غير مناسبة؛ فكّر ببادئ ناعم أو مغيّر.
4. وإن كان الحمل مروحة أو مضخة طاردة مركزية وكانت التكلفة حاكمة، تبقى **نجمة/دلتا** صالحة — شرط مطابقة تصنيف دلتا للتغذية وتوفر ستة أطراف.
5. وإن كانت القابلية للضبط أو الإيقاف الناعم أو محرك بثلاثة أطراف مهمة، فالـ**بادئ الناعم** البديل الكهروميكانيكي الأفضل.

والقدرة على اصطحاب عميل عبر ذلك التتابع، بأسبابه، هي ما يميّز تحديد بادئ عن تخمينه.$c$,
3
FROM public.modules WHERE slug = 'finix-motor-starting-methods';

-- Quizzes I02
INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'bronze', 'Starting Method Basics', 'أساسيات طرق البدء', 80
FROM public.modules WHERE slug = 'finix-motor-starting-methods';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$Why does a stationary induction motor draw much higher current than a running one?$q$,
    $q$لماذا يسحب المحرك الحثي الساكن تيارًا أعلى بكثير من الدائر؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-motor-starting-methods' AND quizzes.tier = 'bronze' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$At standstill there is no back-EMF to oppose the supply, so it behaves close to a short circuit$o$, $o$عند السكون لا توجد قوة دافعة عكسية تعارض التغذية، فيتصرف قريبًا من القصر$o$, true, 1),
  ($o$The motor windings are colder and have lower resistance$o$, $o$ملفات المحرك أبرد ومقاومتها أقل$o$, false, 2),
  ($o$The supply voltage rises at the moment of starting$o$, $o$يرتفع جهد التغذية لحظة البدء$o$, false, 3),
  ($o$It does not; starting current equals running current$o$, $o$لا يفعل؛ تيار البدء يساوي تيار التشغيل$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$What speed ratio can a Dahlander pole-changing winding produce?$q$,
    $q$أي نسبة سرعة ينتجها ملف دالاندر لتغيير الأقطاب؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-motor-starting-methods' AND quizzes.tier = 'bronze' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$2:1 only$o$, $o$2:1 فقط$o$, true, 1),
  ($o$Any ratio the designer chooses$o$, $o$أي نسبة يختارها المصمم$o$, false, 2),
  ($o$3:1 only$o$, $o$3:1 فقط$o$, false, 3),
  ($o$It gives continuously variable speed$o$, $o$يعطي سرعة متغيرة باستمرار$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$What does a variable frequency drive control that a soft starter cannot?$q$,
    $q$ما الذي يتحكم به مغيّر التردد ولا يستطيعه البادئ الناعم؟$q$, 3
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-motor-starting-methods' AND quizzes.tier = 'bronze' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Running speed, because it controls frequency not just voltage$o$, $o$سرعة التشغيل، لأنه يتحكم بالتردد لا بالجهد فقط$o$, true, 1),
  ($o$Starting current$o$, $o$تيار البدء$o$, false, 2),
  ($o$Mechanical shock at start$o$, $o$الصدمة الميكانيكية عند البدء$o$, false, 3),
  ($o$Nothing; they are functionally identical$o$, $o$لا شيء؛ هما متطابقان وظيفيًا$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'silver', 'Selecting a Starting Method', 'اختيار طريقة البدء', 80
FROM public.modules WHERE slug = 'finix-motor-starting-methods';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$Which nameplate condition must be satisfied before a motor can be star-delta started?$q$,
    $q$أي شرط في لوحة الاسم يجب تحققه قبل بدء محرك بنجمة/دلتا؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-motor-starting-methods' AND quizzes.tier = 'silver' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$The motor's delta voltage rating must match the supply voltage, with six terminals available$o$, $o$يجب أن يطابق تصنيف جهد دلتا للمحرك جهد التغذية، مع توفر ستة أطراف$o$, true, 1),
  ($o$The motor's star voltage rating must match the supply$o$, $o$يجب أن يطابق تصنيف جهد النجمة التغذية$o$, false, 2),
  ($o$The motor must be rated above a minimum power$o$, $o$يجب أن يكون المحرك فوق قدرة دنيا$o$, false, 3),
  ($o$Any three-phase motor can be star-delta started$o$, $o$أي محرك ثلاثي الأطوار يمكن بدؤه بنجمة/دلتا$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$A loaded conveyor must start from standstill under full load. Why is star-delta a poor choice?$q$,
    $q$سير ناقل محمّل يجب أن يبدأ من السكون بحمل كامل. لماذا نجمة/دلتا اختيار سيئ؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-motor-starting-methods' AND quizzes.tier = 'silver' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Star connection gives roughly one third of DOL torque, which may not accelerate a high-torque load$o$, $o$توصيل النجمة يعطي نحو ثلث عزم البدء المباشر، وقد لا يُسرّع حملًا عالي العزم$o$, true, 1),
  ($o$Star-delta cannot be used on conveyors for safety reasons$o$, $o$لا يمكن استخدام نجمة/دلتا في السيور لأسباب سلامة$o$, false, 2),
  ($o$Star-delta draws more current than DOL$o$, $o$نجمة/دلتا تسحب تيارًا أكثر من البدء المباشر$o$, false, 3),
  ($o$Conveyors always require DC motors$o$, $o$السيور تتطلب دائمًا محركات تيار مستمر$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$Why can setting a star-delta overload relay to the nameplate line current leave a motor unprotected?$q$,
    $q$لماذا قد يترك ضبط ريليه الحمل الزائد لنجمة/دلتا على تيار خط لوحة الاسم المحرك بلا حماية؟$q$, 3
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-motor-starting-methods' AND quizzes.tier = 'silver' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$The relay is usually in the winding circuit, where current is lower than line current, so the setting ends up far too high$o$, $o$الريليه عادة في دائرة الملف حيث التيار أقل من تيار الخط، فينتهي الضبط أعلى بكثير مما ينبغي$o$, true, 1),
  ($o$Overload relays do not work on star-delta starters at all$o$, $o$ريليهات الحمل الزائد لا تعمل مع بادئات نجمة/دلتا إطلاقًا$o$, false, 2),
  ($o$The setting should always be double the nameplate current$o$, $o$ينبغي أن يكون الضبط دائمًا ضعف تيار لوحة الاسم$o$, false, 3),
  ($o$Line and winding currents are always identical$o$, $o$تيارا الخط والملف متطابقان دائمًا$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'gold', 'Starting Strategy & Trade-offs', 'استراتيجية البدء والمقايضات', 80
FROM public.modules WHERE slug = 'finix-motor-starting-methods';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$A star-delta starter still produces a large current surge, but only at the moment of transition. What is the most likely cause?$q$,
    $q$بادئ نجمة/دلتا ما يزال ينتج اندفاع تيار كبيرًا، لكن عند لحظة الانتقال فقط. ما السبب الأرجح؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-motor-starting-methods' AND quizzes.tier = 'gold' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$The star period is too short, so transfer happens before the motor has accelerated properly$o$, $o$فترة النجمة قصيرة جدًا، فيحدث الانتقال قبل تسارع المحرك كما ينبغي$o$, true, 1),
  ($o$The overload relay is set too low$o$, $o$ريليه الحمل الزائد مضبوط منخفضًا جدًا$o$, false, 2),
  ($o$The motor is too small for the starter$o$, $o$المحرك أصغر من البادئ$o$, false, 3),
  ($o$A transition surge is unavoidable and cannot be reduced$o$, $o$اندفاع الانتقال حتمي ولا يمكن تقليله$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$A client wants to reduce energy cost on a large ventilation fan currently running full speed with a damper throttling airflow. What do you recommend?$q$,
    $q$يريد عميل تقليل تكلفة الطاقة لمروحة تهوية كبيرة تعمل بسرعة كاملة مع خانق يقيّد التدفق. بماذا توصي؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-motor-starting-methods' AND quizzes.tier = 'gold' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$A VFD to reduce fan speed instead of throttling, since power falls steeply with speed on centrifugal loads$o$, $o$مغيّر تردد لتقليل سرعة المروحة بدل الخنق، لأن القدرة تهبط بحدة مع السرعة في الأحمال الطاردة المركزية$o$, true, 1),
  ($o$A star-delta starter, which reduces running energy consumption$o$, $o$بادئ نجمة/دلتا، فهو يقلل استهلاك طاقة التشغيل$o$, false, 2),
  ($o$A soft starter, which controls running speed$o$, $o$بادئ ناعم، فهو يتحكم بسرعة التشغيل$o$, false, 3),
  ($o$Nothing can reduce energy use on an existing fan$o$, $o$لا شيء يقلل استهلاك الطاقة في مروحة قائمة$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$Why must reduced-voltage starting never be applied without knowing the driven load?$q$,
    $q$لماذا يجب ألا يُطبَّق البدء بجهد مخفّض دون معرفة الحمل المُدار؟$q$, 3
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-motor-starting-methods' AND quizzes.tier = 'gold' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Reducing voltage reduces torque; if torque falls below what the load needs, the motor stalls and overheats drawing heavy current$o$, $o$تقليل الجهد يقلل العزم؛ وإن هبط العزم دون ما يحتاجه الحمل، يتوقف المحرك ويسخن ساحبًا تيارًا ثقيلًا$o$, true, 1),
  ($o$Reduced voltage always damages the windings$o$, $o$الجهد المخفّض يتلف الملفات دائمًا$o$, false, 2),
  ($o$The load type only affects running current, not starting$o$, $o$نوع الحمل يؤثر على تيار التشغيل فقط لا البدء$o$, false, 3),
  ($o$It is only a concern for single-phase motors$o$, $o$يهم فقط في المحركات أحادية الطور$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);
