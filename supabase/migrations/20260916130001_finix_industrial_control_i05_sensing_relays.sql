-- Module I05: Sensing Relays — Photocell, Level & Pump Alternation
--
-- ORIGINAL CONTENT. Topic sequence follows standard industrial-control
-- curricula; all explanations and worked examples written for Finix.
-- No third-party text is reproduced.

INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES (
  'finix-sensing-relays',
  'I05',
  'finix-industrial-control',
  'Sensing Relays: Photocell, Level & Pump Alternation',
  'ريليهات الاستشعار: الخلية الضوئية والمستوى وتبادل المضخات',
  $s$Relays that watch a physical condition and act on it: daylight switching, conductive level control and dry-run protection, and duty/standby pump alternation — with the smart-sensor equivalent of each and the failures that destroy pumps.$s$,
  $s$ريليهات تراقب حالة فيزيائية وتتصرف بناءً عليها: التبديل بضوء النهار، التحكم في المستوى بالأقطاب وحماية التشغيل الجاف، وتبادل المضخات بين العاملة والاحتياطية — مع المكافئ الذكي لكل منها والأعطال التي تدمّر المضخات.$s$,
  NULL,
  27
)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$What a Sensing Relay Is and Why It Needs Hysteresis$t$,
$t$ما هو ريليه الاستشعار ولماذا يحتاج نطاق تباطؤ$t$,
$c$A contactor switches a load. A timer switches on elapsed time. A **sensing relay** switches on a measured physical condition — how bright it is, how deep the water is, whether a phase is missing. It converts something in the real world into a contact that the rest of the control circuit already knows how to use.

**The three parts of every sensing relay.** Whatever it measures, the internal structure is the same, and recognising it lets you diagnose an unfamiliar device:

1. **The sensing element** — the part exposed to the physical world: a light-dependent resistor, a pair of electrodes in a tank, a voltage tap on the incoming phases. It produces a small, continuously varying signal.
2. **The comparison stage** — circuitry that compares that signal against a threshold you set with a dial. This is where "how bright is too dark" becomes a yes/no decision.
3. **The output contact** — a changeover contact that the control circuit uses exactly like any other contact.

The dial you adjust is almost always the **threshold**, not the sensitivity of the sensing element itself. Understanding that distinction keeps you from chasing an imaginary fault when a relay seems unresponsive: often the element is fine and the threshold is simply set beyond the range the condition ever reaches.

**Hysteresis: the single most important concept in this module.** A physical condition rarely crosses a threshold cleanly. Daylight at dusk fades gradually and fluctuates as clouds pass. Water in a tank ripples. If the relay switched at exactly one threshold, it would **chatter** — switching on and off many times per second as the signal hovered at the trip point, destroying the contacts and the load with it.

The solution is to use **two** thresholds instead of one: the relay operates at one level and releases at a different level, with a deliberate gap between them. That gap is called hysteresis, or a differential, or a deadband.

A worked illustration. Suppose a daylight switch turns lighting **on** when the light falls below 20 lux, and turns it **off** only when the light rises above 50 lux. At dusk the light falls past 20 and the lamps come on. Now the light hovers around 20 lux as clouds pass — but the relay will not switch off, because switching off requires 50 lux, which will not happen until well after dawn. One clean operation instead of hundreds.

**Why this matters when you set a device in the field.** Many relays give you one dial for the threshold and a second for the differential. Set the differential too narrow and you get chatter. Set it too wide and the relay becomes sluggish — a tank level control with an enormous differential will let the water fall dangerously low before it calls for the pump. Choosing the differential is a real engineering judgement, not a default to leave alone.

**The other anti-chatter tool: a response delay.** Hysteresis handles a slowly drifting signal. It does not handle a brief spike — a car's headlights sweeping across a daylight sensor, a wave slapping a level probe. For that, most sensing relays include a short response delay: the condition must persist for a set period before the output acts. This is exactly the interval/ON-delay behaviour from the previous module, built into the sensing device.

When you commission a sensing relay, you are therefore setting up to three things: **threshold**, **differential**, and **response delay**. A technician who adjusts only the first and wonders why the output flickers has not understood the device.

**What the rest of this module covers.** The following lessons take three sensing relays that appear constantly in real installations — daylight switching, liquid level, and pump duty alternation — and work through how each is wired, how it fails, and what its smart-control equivalent can and cannot replace.$c$,
$c$الكونتاكتور يفصل ويوصّل حملًا. والمؤقت يعمل بمرور الزمن. أما **ريليه الاستشعار** فيعمل بناءً على حالة فيزيائية مقاسة — كم الإضاءة، كم عمق الماء، هل يوجد طور مفقود. إنه يحوّل شيئًا في العالم الحقيقي إلى تلامس تعرف بقية دائرة التحكم كيف تستخدمه أصلًا.

**الأجزاء الثلاثة في كل ريليه استشعار.** مهما كان المقيس، فالبنية الداخلية واحدة، وإدراكها يمكّنك من تشخيص جهاز غير مألوف:

1. **عنصر الاستشعار** — الجزء المعرّض للعالم الفيزيائي: مقاومة ضوئية، زوج أقطاب في خزان، نقطة قياس جهد على الأطوار الداخلة. ينتج إشارة صغيرة متغيرة باستمرار.
2. **مرحلة المقارنة** — دائرة تقارن تلك الإشارة بعتبة تضبطها بقرص. هنا يتحول سؤال "كم من الظلام يُعد ظلامًا" إلى قرار بنعم أو لا.
3. **تلامس الخرج** — تلامس تحويل تستخدمه دائرة التحكم تمامًا كأي تلامس آخر.

القرص الذي تضبطه هو **العتبة** في الغالب، لا حساسية عنصر الاستشعار نفسه. وإدراك هذا الفرق يجنبك مطاردة عطل وهمي حين يبدو الريليه غير مستجيب: غالبًا يكون العنصر سليمًا والعتبة مضبوطة خارج المدى الذي تبلغه الحالة أصلًا.

**نطاق التباطؤ (Hysteresis): أهم مفهوم في هذا البرنامج.** نادرًا ما تعبر الحالة الفيزيائية العتبة بشكل نظيف. ضوء النهار عند الغسق يخفت تدريجيًا ويتذبذب مع مرور السحب. والماء في الخزان يتموج. لو بدّل الريليه عند عتبة واحدة بالضبط، لحدثت **رفرفة** — تشغيل وفصل عشرات المرات في الثانية بينما تحوم الإشارة حول نقطة الفصل، فتتلف التلامسات ويتلف الحمل معها.

الحل استخدام عتبتين بدل واحدة: يعمل الريليه عند مستوى ويتحرر عند مستوى مختلف، بفجوة مقصودة بينهما. تسمى هذه الفجوة نطاق التباطؤ أو الفرق التفاضلي أو النطاق الميت.

مثال توضيحي محلول. لنفترض أن مفتاح ضوء النهار يشغّل الإضاءة حين ينخفض الضوء تحت 20 لكس، ولا يطفئها إلا حين يرتفع فوق 50 لكس. عند الغسق ينخفض الضوء تحت 20 فتضيء المصابيح. والآن يحوم الضوء حول 20 لكس مع مرور السحب — لكن الريليه لن يفصل، لأن الفصل يتطلب 50 لكس، وهذا لن يحدث إلا بعد الفجر بوقت. عملية واحدة نظيفة بدل مئات.

**لماذا يهم هذا عند ضبط جهاز ميدانيًا.** كثير من الريليهات تمنحك قرصًا للعتبة وآخر للفرق التفاضلي. اضبط الفرق ضيقًا جدًا فتحصل على رفرفة. واضبطه واسعًا جدًا فيصبح الريليه بليدًا — تحكم مستوى خزان بفرق تفاضلي هائل سيترك الماء يهبط لمستوى خطير قبل أن يطلب المضخة. اختيار الفرق التفاضلي حكم هندسي حقيقي، لا قيمة افتراضية تُترك كما هي.

**الأداة الأخرى ضد الرفرفة: تأخير الاستجابة.** نطاق التباطؤ يعالج إشارة تنحرف ببطء. لكنه لا يعالج نبضة قصيرة — أضواء سيارة تمسح حساس ضوء نهار، موجة تصفع قطب مستوى. لذلك تتضمن أغلب ريليهات الاستشعار تأخير استجابة قصيرًا: يجب أن تستمر الحالة مدة محددة قبل أن يتصرف الخرج. وهذا بالضبط سلوك الفترة/تأخير التشغيل من البرنامج السابق، مبنيًا داخل جهاز الاستشعار.

لذا فأنت عند التشغيل التجريبي لريليه استشعار تضبط ثلاثة أشياء: **العتبة** و**الفرق التفاضلي** و**تأخير الاستجابة**. والفني الذي يضبط الأول فقط ثم يتساءل لماذا يرتعش الخرج لم يفهم الجهاز.

**ما يغطيه باقي هذا البرنامج.** تتناول الدروس التالية ثلاثة ريليهات استشعار تظهر باستمرار في التركيبات الحقيقية — التبديل بضوء النهار، ومستوى السائل، وتبادل المضخات — وتعالج كيف يُوصَّل كل منها، وكيف يفشل، وما الذي يستطيع مكافئه الذكي استبداله وما لا يستطيع.$c$,
1
FROM public.modules WHERE slug = 'finix-sensing-relays';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$Photocell and Daylight Switching$t$,
$t$الخلية الضوئية والتبديل بضوء النهار$t$,
$c$A daylight switch turns lighting on when it gets dark and off when it gets light. It is the simplest useful sensing relay, it is everywhere — street lighting, compound entrances, garden and facade lighting, warehouse yards — and it is misinstalled constantly.

**How it senses.** The element is a light-dependent resistor: its resistance falls as illumination rises. The relay compares that resistance against the threshold you set and operates its contact when the light falls below it. The dial is usually calibrated in lux, or simply marked light-to-dark, and a typical switching range for outdoor lighting sits in the low tens of lux — around the level of deep dusk.

**The three settings, applied here.**
- **Threshold** — how dark before the lamps strike. Set too high, lighting burns through bright afternoons and wastes the client's money. Set too low, the area is genuinely dark before anything happens, which for a car park or a staircase is a safety problem, not an aesthetic one.
- **Differential** — as covered in the previous lesson, the on and off levels must differ. Most daylight switches build in a fixed, sensible differential precisely because the dusk/dawn transition is slow.
- **Response delay** — typically tens of seconds. This is what stops a passing vehicle's headlights, a lightning flash, or a brief heavy cloud from cycling an entire street's lighting.

**The mounting mistakes that cause callbacks.** This is where most daylight-switch faults are created, and none of them are electrical:

- **Never point the sensor at the lighting it controls.** If the sensor can see its own lamps, it creates a feedback loop: darkness turns the lamps on, the lamps illuminate the sensor, the sensor decides it is daytime and turns them off, the area goes dark, and the cycle repeats. The result is a street that flashes all night and a contactor that fails within weeks. If you are called to a site where the lighting cycles endlessly, check the sensor's line of sight before you check anything else.
- **Avoid direct low sun into the sensor.** A sensor squinting into a low morning or evening sun sees a false bright reading and switches off while the site is still dark. General practice is to orient the sensor so it reads diffuse sky light rather than direct sun.
- **Keep it away from reflective surfaces and neighbouring light sources.** A sensor facing a white wall lit by an adjacent building's floodlight reads that building's schedule, not the sky's.
- **Plan for cleaning.** An outdoor sensor accumulates dust, salt and bird droppings. A dirty lens reads darker than reality, so lighting comes on progressively earlier over months. Mount it where a maintenance person can actually reach it, and add lens cleaning to the site's maintenance schedule.

**The contactor sizing trap.** Lighting is not a simple resistive load. Discharge lamps and LED drivers draw a large, very brief inrush at switch-on — for banks of LED drivers this peak can be many times the steady running current, because each driver charges its input capacitors simultaneously. A contactor chosen on running current alone will weld its contacts.

The correct approach is to select a contactor **rated for lighting duty** rather than by running amps, or to derate a general-purpose contactor substantially. On a large lighting circuit, splitting the load across several contactors also helps, since it divides the inrush.

**The smart equivalent — and its genuine trade-off.** Smart control replaces the photocell with an **astronomical clock**: knowing the date and the site's latitude and longitude, the device calculates sunrise and sunset precisely and switches accordingly.

What that gains: no sensor to mount, aim, or clean; no feedback-loop failure mode; perfectly repeatable switching times; and trivially easy offsets such as "on thirty minutes before sunset".

What it loses: an astronomical clock has no idea what the weather is doing. On a heavily overcast winter afternoon the site is genuinely dark an hour before calculated sunset, and a pure astronomical schedule leaves it dark. A photocell responds to actual conditions.

**Best practice is therefore to combine them**, and this is worth explaining to clients: use the astronomical schedule as the primary control, and keep a photocell as an override that can bring lighting on early when real daylight drops below threshold. You get repeatable behaviour on normal days and correct behaviour on abnormal ones.

**A worked example — compound entrance lighting.** Requirement: entrance and perimeter lighting on at dusk, off at dawn, with a reduced night setting after midnight.

A sound design: a photocell or astronomical channel switches the full lighting contactor at dusk; a time channel drops part of the load after midnight, leaving perimeter lighting on; both recombine at dawn. Note that the after-midnight reduction is *time* logic, not *sensing* logic — it is the timer module's work, and recognising which function belongs to which device is the skill this track is building.$c$,
$c$مفتاح ضوء النهار يشغّل الإضاءة عند حلول الظلام ويطفئها عند الضوء. إنه أبسط ريليه استشعار مفيد، وهو موجود في كل مكان — إنارة الشوارع، مداخل الكمبوندات، إضاءة الحدائق والواجهات، ساحات المخازن — ويُركَّب بشكل خاطئ باستمرار.

**كيف يستشعر.** العنصر مقاومة ضوئية: تنخفض مقاومتها كلما ارتفعت الإضاءة. يقارن الريليه تلك المقاومة بالعتبة التي تضبطها ويشغّل تلامسه حين ينخفض الضوء تحتها. القرص معاير عادة باللكس، أو مُعلَّم ببساطة من الضوء إلى الظلام، ومدى التبديل النموذجي للإضاءة الخارجية يقع في عشرات اللكس الدنيا — نحو مستوى الغسق العميق.

**الضبطات الثلاث مطبَّقة هنا.**
- **العتبة** — كم من الظلام قبل أن تضيء المصابيح. اضبطها عالية فتظل الإضاءة تعمل خلال أصائل مشرقة وتهدر مال العميل. واضبطها منخفضة فتصبح المنطقة مظلمة فعلًا قبل أن يحدث أي شيء، وهذا في موقف سيارات أو سلم مشكلة سلامة لا مشكلة جمالية.
- **الفرق التفاضلي** — كما في الدرس السابق، يجب أن يختلف مستوى التشغيل عن الفصل. تبني أغلب مفاتيح ضوء النهار فرقًا ثابتًا ومعقولًا داخليًا، تحديدًا لأن انتقال الغسق والفجر بطيء.
- **تأخير الاستجابة** — عشرات الثواني عادة. وهذا ما يمنع أضواء مركبة عابرة أو وميض برق أو سحابة كثيفة قصيرة من تشغيل وإطفاء إنارة شارع بأكمله.

**أخطاء التركيب التي تسبب استدعاءات صيانة.** هنا تُصنع أغلب أعطال مفاتيح ضوء النهار، ولا شيء منها كهربائي:

- **لا توجّه الحساس أبدًا نحو الإضاءة التي يتحكم بها.** إن رأى الحساس مصابيحه، نشأت حلقة تغذية راجعة: الظلام يشغّل المصابيح، والمصابيح تضيء الحساس، فيقرر الحساس أن النهار حلّ فيطفئها، فتظلم المنطقة، وتتكرر الدورة. النتيجة شارع يومض طوال الليل وكونتاكتور يتلف خلال أسابيع. فإن استُدعيت لموقع تتكرر إضاءته بلا توقف، افحص مجال رؤية الحساس قبل أي شيء آخر.
- **تجنب الشمس المنخفضة المباشرة على الحساس.** الحساس المواجه لشمس صباح أو مساء منخفضة يقرأ سطوعًا كاذبًا فيفصل بينما الموقع ما يزال مظلمًا. والممارسة العامة توجيه الحساس ليقرأ ضوء السماء المنتشر لا الشمس المباشرة.
- **أبعده عن الأسطح العاكسة ومصادر الضوء المجاورة.** الحساس المواجه لحائط أبيض يضيئه كشاف مبنى مجاور يقرأ جدول ذلك المبنى لا جدول السماء.
- **خطط للتنظيف.** الحساس الخارجي يتراكم عليه الغبار والأملاح وفضلات الطيور. والعدسة المتسخة تقرأ أظلم من الواقع، فتعمل الإضاءة أبكر تدريجيًا عبر الشهور. ركّبه حيث يمكن لفني الصيانة الوصول إليه فعلًا، وأضف تنظيف العدسة لجدول صيانة الموقع.

**فخ تحديد حجم الكونتاكتور.** الإضاءة ليست حملًا مقاومًا بسيطًا. مصابيح التفريغ وسائقات LED تسحب تيار اندفاع كبيرًا وقصيرًا جدًا عند التشغيل — وفي مجموعات سائقات LED قد يبلغ هذا الذروة أضعاف تيار التشغيل المستقر، لأن كل سائق يشحن مكثفات دخله في آن واحد. والكونتاكتور المختار بتيار التشغيل وحده ستلتحم تلامساته.

النهج الصحيح اختيار كونتاكتور **مصنّف لخدمة الإضاءة** لا بتيار التشغيل، أو تخفيض تصنيف كونتاكتور عام بشكل كبير. وفي دائرة إضاءة كبيرة، يساعد أيضًا تقسيم الحمل على عدة كونتاكتورات لأنه يقسّم تيار الاندفاع.

**المكافئ الذكي — ومقايضته الحقيقية.** يستبدل التحكم الذكي الخلية الضوئية بـ**ساعة فلكية**: بمعرفة التاريخ وخط عرض الموقع وطوله، يحسب الجهاز الشروق والغروب بدقة ويبدّل وفقًا لهما.

ما يكسبه ذلك: لا حساس يُركَّب أو يُوجَّه أو يُنظَّف؛ ولا حالة فشل بحلقة تغذية راجعة؛ وأوقات تبديل قابلة للتكرار تمامًا؛ وإزاحات سهلة جدًا مثل "التشغيل قبل الغروب بثلاثين دقيقة".

وما يخسره: الساعة الفلكية لا تعلم شيئًا عن الطقس. ففي أصيل شتوي كثيف الغيوم يكون الموقع مظلمًا فعلًا قبل الغروب المحسوب بساعة، ويتركه الجدول الفلكي الصِّرف مظلمًا. أما الخلية الضوئية فتستجيب للظروف الفعلية.

**لذا فأفضل ممارسة هي الجمع بينهما**، وهذا يستحق الشرح للعملاء: استخدم الجدول الفلكي كتحكم أساسي، وأبقِ خلية ضوئية كتجاوز يشغّل الإضاءة مبكرًا حين يهبط ضوء النهار الحقيقي تحت العتبة. فتحصل على سلوك قابل للتكرار في الأيام العادية وسلوك صحيح في الأيام غير العادية.

**مثال محلول — إضاءة مدخل كمبوند.** المطلوب: إضاءة المدخل والسور تعمل عند الغسق وتُطفأ عند الفجر، مع وضع ليلي مخفّض بعد منتصف الليل.

تصميم سليم: خلية ضوئية أو قناة فلكية تشغّل كونتاكتور الإضاءة الكاملة عند الغسق؛ وقناة زمنية تفصل جزءًا من الحمل بعد منتصف الليل تاركة إضاءة السور؛ ويعود الاثنان معًا عند الفجر. ولاحظ أن التخفيض بعد منتصف الليل منطق *زمني* لا منطق *استشعار* — إنه عمل برنامج المؤقتات، وإدراك أي وظيفة تخص أي جهاز هو المهارة التي يبنيها هذا المسار.$c$,
2
FROM public.modules WHERE slug = 'finix-sensing-relays';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$Liquid Level Relays and Dry-Run Protection$t$,
$t$ريليهات مستوى السائل وحماية التشغيل الجاف$t$,
$c$Level control is the sensing application that most directly protects expensive equipment, and the one where a wiring mistake has the fastest consequences. A centrifugal pump running dry can destroy its mechanical seal in minutes, because the pumped liquid is also what cools and lubricates that seal.

**Conductive (electrode) level sensing.** The most common industrial method for water: probes are suspended in the tank at the levels of interest, and the relay detects whether liquid is bridging the gap between a probe and a common reference. Water conducts; air does not. The relay's sensitivity dial accommodates different liquid conductivities — clean water conducts poorly compared with mineral-rich or treated water, and a relay set for one may not detect the other.

**Why the probe supply is AC and never DC.** This is the detail that separates someone who understands the device from someone who merely fits it. If a steady DC voltage were applied across probes in water, the arrangement becomes an electrolysis cell: material migrates from one electrode to the other, the probes erode and become coated, and readings drift until the system fails. Level relays therefore excite the probes with a low-voltage **AC** signal, which has no net direction and so causes no net plating. Low voltage also keeps the probe circuit safe in a tank a person might reach into.

If you ever encounter probes that have eroded or grown a deposit unusually fast, suspect a device applying DC excitation, or a probe circuit wired to the wrong terminals.

**The standard three-probe arrangement.** Level relays typically use three probes to give a working differential — the hysteresis concept from lesson one, expressed physically:

- A **common/reference** probe reaching near the bottom, always immersed in normal operation.
- A **low-level** probe at the level where action should begin.
- A **high-level** probe at the level where action should stop.

Using two separate probes for start and stop is what creates the differential, and it is why a properly installed level control does not chatter as the surface ripples.

**Fill mode versus empty mode — get this backwards and the logic inverts.** The same relay usually supports both, selected by a switch, and the distinction is about what the pump is doing:

- **Filling** (a rooftop or storage tank being filled): the pump runs when the level is **low** and stops when the level reaches **high**.
- **Emptying** (a sump or pit being drained): the pump runs when the level is **high** and stops when it reaches **low**.

A technician who selects the wrong mode produces a system that runs the pump when the tank is already full — and in an emptying application, leaves a sump to overflow.

**Dry-run protection — the critical function.** In many Egyptian buildings a pump lifts water from a ground-level tank or a well to a rooftop tank. If the source runs empty and the pump keeps running, the pump is destroyed quickly and expensively.

Dry-run protection uses a probe in the **source**, not the destination: if the source level falls below a minimum, the pump is stopped regardless of what the destination tank wants. This protection must be **independent** of the fill logic, because its whole purpose is to override a demand for water that cannot safely be met.

Well installations need a further refinement: a well that has been pumped down will recover over minutes or hours as groundwater seeps back. A dry-run cutout that resets instantly will restart the pump the moment the probe is briefly re-wetted, producing rapid cycling that is itself damaging. The correct behaviour is a **lockout with a deliberate restart delay** — stop the pump, and do not allow a restart until a set recovery period has passed.

**Other level-sensing technologies, and when to choose them.** Conductive probes are cheap and reliable for water, but they are not universal:
- **Float switches** — simple, entirely electromechanical, and immune to conductivity issues, but they have moving parts that jam and tethers that tangle.
- **Ultrasonic and radar** — non-contact, suited to dirty or aggressive liquids, but they can be confused by foam, steam, or a tank with internal obstructions.
- **Pressure transducers** — measure head at the bottom of the tank and infer level; they give a continuous reading rather than discrete points, but they need calibration and are affected by liquid density.

Conductive probes fail on non-conductive liquids entirely — attempting to sense oil or deionised water with electrodes will not work, and recognising that before ordering parts saves a wasted site visit.

**Commissioning a level control.**
1. Confirm fill versus empty mode against the actual application, physically.
2. Verify probe lengths and positions match the drawing — a probe cut to the wrong length silently changes the switching levels.
3. Check that the common probe remains immersed at the lowest operating level, or the relay loses its reference and behaves erratically.
4. Test dry-run protection by simulating an empty source and confirming the pump stops and stays stopped.
5. Test the differential by running a full cycle and observing that the pump does not short-cycle near the switching points.$c$,
$c$التحكم في المستوى هو تطبيق الاستشعار الذي يحمي المعدات الغالية بشكل مباشر أكثر من غيره، وهو الذي يكون لخطأ التوصيل فيه أسرع العواقب. المضخة الطاردة المركزية التي تعمل جافة قد تدمّر حشوتها الميكانيكية خلال دقائق، لأن السائل المضخوخ هو نفسه ما يبرّد تلك الحشوة ويشحّمها.

**استشعار المستوى بالأقطاب.** الطريقة الصناعية الأشيع للماء: تُعلَّق أقطاب في الخزان عند المستويات المهمة، ويكشف الريليه ما إذا كان السائل يجسر الفجوة بين قطب والمرجع المشترك. الماء يوصّل والهواء لا. ويستوعب قرص الحساسية اختلاف موصلية السوائل — فالماء النقي يوصّل بضعف مقارنة بالماء الغني بالمعادن أو المعالج، وريليه مضبوط لأحدهما قد لا يكشف الآخر.

**لماذا تغذية الأقطاب متردد وليست مستمرًا أبدًا.** هذه التفصيلة تفصل من يفهم الجهاز عمّن يركّبه فقط. لو طُبّق جهد مستمر ثابت عبر أقطاب في الماء، لتحوّل الترتيب إلى خلية تحليل كهربائي: تهاجر المادة من قطب لآخر، فتتآكل الأقطاب وتُغلَّف، وتنحرف القراءات حتى يفشل النظام. لذلك تُثير ريليهات المستوى الأقطاب بإشارة **متردد** منخفضة الجهد، لا اتجاه صافيًا لها فلا تسبب ترسيبًا صافيًا. والجهد المنخفض يُبقي دائرة الأقطاب آمنة في خزان قد يُدخل إنسان يده فيه.

فإن صادفت أقطابًا تآكلت أو تراكمت عليها رواسب بسرعة غير معتادة، فاشتبه بجهاز يطبّق إثارة مستمرة، أو بدائرة أقطاب موصّلة لأطراف خاطئة.

**ترتيب الأقطاب الثلاثة القياسي.** تستخدم ريليهات المستوى ثلاثة أقطاب عادة لتوفير فرق تفاضلي عملي — مفهوم نطاق التباطؤ من الدرس الأول، معبَّرًا عنه فيزيائيًا:

- قطب **مشترك/مرجعي** يصل قرب القاع، مغمور دائمًا في التشغيل العادي.
- قطب **المستوى المنخفض** عند المستوى الذي يجب أن يبدأ عنده الفعل.
- قطب **المستوى المرتفع** عند المستوى الذي يجب أن يتوقف عنده.

استخدام قطبين منفصلين للبدء والإيقاف هو ما يخلق الفرق التفاضلي، ولهذا لا يرفرف تحكم المستوى المركّب جيدًا مع تموج السطح.

**وضع التعبئة مقابل وضع التفريغ — اعكسه ينعكس المنطق.** يدعم الريليه الواحد كليهما عادة عبر مفتاح، والتمييز يتعلق بما تفعله المضخة:

- **التعبئة** (خزان علوي أو تخزين يُملأ): تعمل المضخة حين يكون المستوى **منخفضًا** وتتوقف حين يبلغ **المرتفع**.
- **التفريغ** (بئر تجميع أو حفرة تُنزَح): تعمل المضخة حين يكون المستوى **مرتفعًا** وتتوقف حين يبلغ **المنخفض**.

والفني الذي يختار الوضع الخاطئ ينتج نظامًا يشغّل المضخة والخزان ممتلئ أصلًا — وفي تطبيق تفريغ، يترك بئر التجميع يفيض.

**حماية التشغيل الجاف — الوظيفة الحرجة.** في كثير من المباني المصرية ترفع مضخة الماء من خزان أرضي أو بئر إلى خزان علوي. فإن نفد المصدر واستمرت المضخة، دُمّرت المضخة بسرعة وبتكلفة عالية.

تستخدم حماية التشغيل الجاف قطبًا في **المصدر** لا الوجهة: فإن هبط مستوى المصدر تحت الحد الأدنى، تتوقف المضخة بغض النظر عما يريده خزان الوجهة. ويجب أن تكون هذه الحماية **مستقلة** عن منطق التعبئة، لأن غرضها كله تجاوز طلب ماء لا يمكن تلبيته بأمان.

وتحتاج تركيبات الآبار تحسينًا إضافيًا: البئر الذي نُزح يتعافى خلال دقائق أو ساعات مع تسرب المياه الجوفية عائدة. وقاطع التشغيل الجاف الذي يُصفَّر فورًا سيعيد تشغيل المضخة لحظة ابتلال القطب للحظة، منتجًا تشغيلًا متكررًا سريعًا ضارًا بذاته. والسلوك الصحيح **إقفال مع تأخير إعادة تشغيل مقصود** — أوقف المضخة، ولا تسمح بإعادة التشغيل حتى تمر فترة تعافٍ محددة.

**تقنيات استشعار مستوى أخرى ومتى تختارها.** الأقطاب رخيصة وموثوقة للماء، لكنها ليست شاملة:
- **مفاتيح العوامة** — بسيطة وكهروميكانيكية بالكامل ومحصّنة ضد مشاكل الموصلية، لكن لها أجزاء متحركة تعلق وحبال تتشابك.
- **الموجات فوق الصوتية والرادار** — بلا تلامس، مناسبة للسوائل المتسخة أو الكاوية، لكن قد تربكها الرغوة أو البخار أو خزان بعوائق داخلية.
- **محولات الضغط** — تقيس ضغط العمود عند قاع الخزان وتستنتج المستوى؛ تعطي قراءة مستمرة لا نقاطًا منفصلة، لكنها تحتاج معايرة وتتأثر بكثافة السائل.

وتفشل الأقطاب تمامًا مع السوائل غير الموصلة — فمحاولة استشعار زيت أو ماء منزوع الأيونات بالأقطاب لن تنجح، وإدراك ذلك قبل طلب القطع يوفر زيارة موقع مهدرة.

**التشغيل التجريبي لتحكم المستوى.**
1. تأكد من وضع التعبئة أو التفريغ مقابل التطبيق الفعلي، فعليًا.
2. تحقق أن أطوال الأقطاب ومواضعها تطابق الرسم — فالقطب المقطوع بطول خاطئ يغيّر مستويات التبديل صامتًا.
3. تأكد أن القطب المشترك يبقى مغمورًا عند أدنى مستوى تشغيل، وإلا فقد الريليه مرجعه وتصرف بشكل شاذ.
4. اختبر حماية التشغيل الجاف بمحاكاة مصدر فارغ وتأكد أن المضخة تتوقف وتبقى متوقفة.
5. اختبر الفرق التفاضلي بتشغيل دورة كاملة وملاحظة ألا تتكرر تشغيلات المضخة القصيرة قرب نقاط التبديل.$c$,
3
FROM public.modules WHERE slug = 'finix-sensing-relays';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$Pump Alternation: Duty, Standby and Changeover$t$,
$t$تبادل المضخات: العاملة والاحتياطية والتبديل$t$,
$c$Where water supply matters, installations use two pumps rather than one. Getting the control logic right is what makes the second pump an asset rather than an expensive ornament.

**Why two pumps, and why they must alternate.** A duplex (two-pump) set exists for availability: if one pump fails, the building still has water. But simply designating one pump as "the pump" and the other as "the spare" produces a predictable failure. The duty pump accumulates all the running hours and wears out, while the standby pump sits idle for months — and a centrifugal pump left unused seizes, its seals dry out and stick, and its bearings suffer. The moment you finally need it, it does not start.

**Alternation** solves both problems at once: the controller swaps which pump is duty and which is standby, so running hours accumulate roughly equally, both pumps are regularly proven to work, and neither sits idle long enough to seize.

**The two common alternation strategies.**
- **Alternate on each start** — pump A runs this cycle, pump B the next, and so on. Simple, and it guarantees both pumps run frequently. This suits installations that cycle often, such as a rooftop tank refilling several times a day.
- **Timed rotation** — the duty pump changes after a set running period regardless of cycles. This suits installations that run for long continuous periods, where alternating per start would leave one pump running for hours while the other never starts.

**Duty/standby versus duty/assist — a distinction that changes the design.**
- In **duty/standby**, only one pump runs at a time. The second exists purely for redundancy. This is the normal arrangement for domestic and building water supply.
- In **duty/assist**, the second pump starts *in addition* to the first when demand exceeds what one pump can meet. This suits varying demand — a building where morning peak needs both pumps but overnight demand needs one.

Choosing the wrong one has real consequences. If a system is designed duty/standby and someone configures it duty/assist, both pumps can run simultaneously into pipework and a tank inlet sized for one, which can cause pressure problems and water hammer.

**The failure mode that must be designed out.** In a duty/standby arrangement, **both pumps must never start together on a single level demand.** If the control logic allows it, a low-level signal starts both, doubling the starting current draw — potentially tripping the incoming protection — and slamming flow into pipework designed for one pump.

This is prevented by interlocking the two pump contactors so that each one's normally-closed auxiliary contact sits in the other's coil circuit, exactly the interlock principle from star-delta starting. The same idea protects against a different danger in a different application, which is why the principle is worth understanding rather than memorising per-circuit.

**Automatic changeover on fault — the part that is frequently omitted.** Alternation shares wear, but the real value of a standby pump is that it starts when the duty pump *fails*. For that to happen automatically, the controller must detect the failure. Common detection methods:
- The duty pump's **overload relay trips** — its auxiliary contact signals the fault.
- The duty pump runs but the level does not change within an expected period, indicating it is running but not delivering (a failed impeller, a closed valve, or a lost prime).

On detecting either, the controller should stop the duty pump, start the standby, and — critically — **raise an alarm**. A duplex set that silently switches to standby has used up its redundancy without anyone knowing. The next failure leaves the building without water, and nobody was warned. An unannounced changeover is a fault waiting to become an outage.

**A worked example — a residential building water system.** A common Egyptian arrangement: a ground-level tank fed from the municipal supply, two pumps lifting to a rooftop tank, and gravity distribution to apartments.

The control requirements, assembled from the functions in this module and the last:
1. **Level control** on the rooftop tank calls for water at low level, stops at high level — a fill-mode level relay with a sensible differential (this lesson and the previous one).
2. **Dry-run protection** on the ground tank stops the pumps if the source is empty, independently of what the rooftop tank demands, with a restart delay so a briefly-refilled source does not cause rapid cycling.
3. **Alternation** swaps duty between the two pumps on each start, so wear is shared and both are regularly proven.
4. **Interlock** guarantees only one pump runs at a time.
5. **Fault changeover with alarm** starts the standby if the duty pump's overload trips, and tells someone it happened.
6. **Optionally, a start delay** staggers the pump start after the level signal so a momentarily fluctuating level does not start a pump unnecessarily — the ON-delay function from the timers module.

Six distinct control functions for what a client describes as "two pumps and a tank". Being able to enumerate them, and to explain why each exists, is the difference between quoting a control panel and quoting a box of contactors.$c$,
$c$حيث يهم إمداد المياه، تستخدم التركيبات مضختين لا واحدة. وضبط منطق التحكم صحيحًا هو ما يجعل المضخة الثانية أصلًا لا زينة غالية.

**لماذا مضختان، ولماذا يجب أن تتبادلا.** توجد المجموعة المزدوجة من أجل الإتاحة: إن تعطلت مضخة، يبقى للمبنى ماء. لكن تعيين مضخة كـ"المضخة" والأخرى كـ"الاحتياطية" ببساطة ينتج فشلًا متوقعًا. فالمضخة العاملة تراكم كل ساعات التشغيل وتبلى، بينما تجلس الاحتياطية عاطلة شهورًا — والمضخة الطاردة المركزية المتروكة دون استخدام تتآكل، وتجف حشواتها وتلتصق، وتتضرر محاملها. وفي اللحظة التي تحتاجها فيها أخيرًا، لا تدور.

**التبادل** يحل المشكلتين معًا: يبدّل المتحكم أي المضختين عاملة وأيهما احتياطية، فتتراكم ساعات التشغيل بالتساوي تقريبًا، وتثبت كلتاهما صلاحيتها دوريًا، ولا تجلس أي منهما عاطلة مدة تكفي لتآكلها.

**استراتيجيتا التبادل الشائعتان.**
- **التبادل عند كل تشغيل** — تعمل المضخة أ هذه الدورة، والمضخة ب التالية، وهكذا. بسيط ويضمن تشغيل كلتيهما بتواتر. يناسب التركيبات كثيرة الدورات، كخزان علوي يُعاد ملؤه عدة مرات يوميًا.
- **التناوب الزمني** — تتغير المضخة العاملة بعد فترة تشغيل محددة بغض النظر عن الدورات. يناسب التركيبات التي تعمل لفترات متصلة طويلة، حيث يترك التبادل عند كل تشغيل مضخة تعمل ساعات والأخرى لا تبدأ أبدًا.

**العاملة/الاحتياطية مقابل العاملة/المساعِدة — تمييز يغيّر التصميم.**
- في **العاملة/الاحتياطية** تعمل مضخة واحدة فقط في كل وقت. والثانية موجودة للتكرارية فحسب. وهذا الترتيب المعتاد لإمداد المياه المنزلي والمباني.
- في **العاملة/المساعِدة** تبدأ الثانية *إضافةً* للأولى حين يتجاوز الطلب ما تلبيه واحدة. يناسب الطلب المتغير — مبنى تحتاج ذروته الصباحية مضختين بينما يحتاج طلبه الليلي واحدة.

واختيار الخاطئ له عواقب حقيقية. فإن صُمم نظام كعاملة/احتياطية ثم ضبطه أحدهم كعاملة/مساعِدة، أمكن للمضختين العمل معًا في مواسير ومدخل خزان مقاسين لواحدة، ما قد يسبب مشاكل ضغط ومطرقة مائية.

**حالة الفشل التي يجب استبعادها بالتصميم.** في ترتيب العاملة/الاحتياطية، **يجب ألا تبدأ المضختان معًا أبدًا استجابة لطلب مستوى واحد.** فإن سمح منطق التحكم بذلك، شغّلت إشارة المستوى المنخفض كلتيهما، فتضاعف سحب تيار البدء — وربما فصلت الحماية الداخلة — وصدمت التدفق في مواسير مصممة لمضخة واحدة.

ويُمنع ذلك بتعشيق كونتاكتوري المضختين بحيث يقع التلامس المساعد المغلق طبيعيًا لكل منهما في دائرة ملف الآخر، وهو بالضبط مبدأ التعشيق من بدء نجمة/دلتا. المبدأ ذاته يحمي من خطر مختلف في تطبيق مختلف، ولهذا يستحق الفهم لا الحفظ لكل دائرة على حدة.

**التبديل التلقائي عند العطل — الجزء الذي يُهمل كثيرًا.** التبادل يتقاسم البلى، لكن القيمة الحقيقية للمضخة الاحتياطية أنها تبدأ حين *تتعطل* العاملة. ولحدوث ذلك تلقائيًا، يجب أن يكتشف المتحكم العطل. وطرق الكشف الشائعة:
- **فصل ريليه الحمل الزائد** للمضخة العاملة — تلامسه المساعد يشير للعطل.
- المضخة العاملة تدور لكن المستوى لا يتغير خلال فترة متوقعة، ما يدل أنها تعمل دون أن تضخ (مروحة تالفة، أو محبس مغلق، أو فقد تعبئة).

وعند كشف أي منهما، ينبغي أن يوقف المتحكم المضخة العاملة، ويشغّل الاحتياطية، و**يُطلق إنذارًا** — وهذا حرج. فالمجموعة المزدوجة التي تتحول للاحتياطية صامتة تكون قد استهلكت تكراريتها دون علم أحد. والعطل التالي يترك المبنى بلا ماء دون أن يُحذَّر أحد. التبديل غير المعلن عطل ينتظر أن يصبح انقطاعًا.

**مثال محلول — نظام مياه مبنى سكني.** ترتيب مصري شائع: خزان أرضي يُغذّى من شبكة المياه، ومضختان ترفعان إلى خزان علوي، وتوزيع بالجاذبية على الشقق.

متطلبات التحكم، مجمّعة من وظائف هذا البرنامج والسابق:
1. **تحكم المستوى** في الخزان العلوي يطلب الماء عند المستوى المنخفض ويتوقف عند المرتفع — ريليه مستوى بوضع تعبئة وفرق تفاضلي معقول (هذا الدرس والذي قبله).
2. **حماية التشغيل الجاف** على الخزان الأرضي توقف المضختين إن فرغ المصدر، باستقلال عما يطلبه الخزان العلوي، مع تأخير إعادة تشغيل كي لا يسبب مصدر امتلأ للحظة تشغيلًا متكررًا سريعًا.
3. **التبادل** يبدّل العمل بين المضختين عند كل تشغيل، فيُتقاسم البلى وتثبت كلتاهما صلاحيتها دوريًا.
4. **التعشيق** يضمن عمل مضخة واحدة فقط في كل وقت.
5. **التبديل عند العطل مع إنذار** يشغّل الاحتياطية إن فصل الحمل الزائد للعاملة، ويخبر أحدًا بما حدث.
6. **واختياريًا تأخير بدء** يؤخر تشغيل المضخة بعد إشارة المستوى كي لا يشغّل مستوى متذبذب للحظة مضخة بلا داعٍ — وظيفة تأخير التشغيل من برنامج المؤقتات.

ست وظائف تحكم متمايزة لما يصفه العميل بأنه "مضختان وخزان". والقدرة على تعدادها وشرح سبب وجود كل منها هي الفرق بين تسعير لوحة تحكم وتسعير صندوق كونتاكتورات.$c$,
4
FROM public.modules WHERE slug = 'finix-sensing-relays';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$From Sensing Relay to Smart Sensor: The Retrofit Opportunity$t$,
$t$من ريليه الاستشعار إلى الحساس الذكي: فرصة التحديث$t$,
$c$Every sensing relay in this module has a smart-sensor counterpart, and this is the area where the two worlds overlap most commercially — because the classical installations already exist, in enormous numbers, and can be upgraded without being replaced.

**The mapping.**

| Classical sensing relay | Smart equivalent |
|---|---|
| Photocell daylight switch | Astronomical (sunrise/sunset) automation, optionally with a light sensor |
| Conductive level relay | Smart tank level sensor with app display and alerts |
| Dry-run cutout | Current monitoring — a running pump drawing abnormally low current is not pumping |
| Pump alternation relay | Scheduled or logic-driven duty rotation in the controller |
| Fault changeover alarm | Push notification the moment a changeover or trip occurs |

**What smart genuinely adds here — and it is substantial.**

- **You learn about failures immediately.** This is the single biggest gain. A classical duplex pump set that switches to standby tells nobody. A monitored one sends a notification the moment it happens, so the fault is repaired while redundancy still exists rather than after the building loses water.
- **Runtime data exposes developing faults.** A pump whose run time to fill the same tank has crept from eight minutes to fourteen over several months is telling you its impeller is wearing or a filter is blocking. No relay can notice that trend; a system logging each cycle makes it obvious.
- **Consumption becomes visible.** Unexplained pump runs overnight, when nobody is drawing water, is the signature of a leak. A classical system simply pumps; a monitored one reveals the pattern.
- **Remote confirmation saves site visits.** A caretaker can confirm the tank filled overnight without climbing to the roof, and you can answer a client's worried phone call by looking rather than driving.

**What must not move into the smart layer.** The rule from the timers module applies unchanged: if failure destroys equipment or endangers people, the protection stays in hardware.

**Dry-run protection is the clearest case.** A pump running dry can be ruined in minutes. If dry-run protection depends on a cloud service, an internet connection, or a scheduler, then an internet outage becomes a destroyed pump. The cutout must be a hardware interlock in the panel — a level probe or pressure switch wired directly into the pump's control circuit, capable of stopping the pump with no network involved whatsoever.

The smart layer's proper role here is to **report** the dry-run event, not to *perform* the protection. Hardware stops the pump; the app tells the client why, and when.

The same reasoning applies to overflow prevention where a failure would flood a building, and to any interlock preventing two pumps running together.

**The retrofit conversation — how to sell this honestly.** Most existing installations already have working relay-based control. The commercially strong, technically honest proposition is not "rip it out and replace it with smart devices" — it is:

> Keep the protection that already works. Add visibility on top.

A practical retrofit on an existing duplex pump panel:
1. **Leave the level control, dry-run cutout and interlock exactly as they are.** They work, they are proven, and they fail safe.
2. **Add current or power monitoring** on each pump's supply. This is non-invasive and tells you whether each pump actually ran, for how long, and whether it drew normal current.
3. **Take a signal from the existing fault contacts** — the overload auxiliary contacts already in the panel — into a monitored input, so a trip raises a notification.
4. **Deliver alerts and history to the client's phone.**

Notice what this does commercially: it is a low-risk, additive job. You are not taking responsibility for redesigning a working safety system, the installation can be done without extended downtime, and if the smart layer fails completely the building's water supply is entirely unaffected. That last point is what makes it an easy proposition for a cautious client, and it is worth stating explicitly when you quote.

**The professional framing.** A client who asks for "smart pumps" usually means they want to know what their pumps are doing and be told when something goes wrong. They rarely mean they want the app deciding when the pump stops to avoid destroying itself. Separating those two things — supervision versus protection — and explaining which you will move and which you will deliberately leave alone, is how an installer demonstrates engineering judgement rather than product enthusiasm.$c$,
$c$لكل ريليه استشعار في هذا البرنامج نظير من الحساسات الذكية، وهذا هو المجال الذي يتداخل فيه العالمان تجاريًا أكثر من غيره — لأن التركيبات الكلاسيكية موجودة بالفعل بأعداد هائلة، ويمكن تحديثها دون استبدالها.

**التقابل.**

| ريليه الاستشعار الكلاسيكي | المكافئ الذكي |
|---|---|
| مفتاح ضوء النهار بالخلية الضوئية | أتمتة فلكية (شروق/غروب)، مع حساس ضوء اختياريًا |
| ريليه المستوى بالأقطاب | حساس مستوى خزان ذكي بعرض وتنبيهات في التطبيق |
| قاطع التشغيل الجاف | مراقبة التيار — مضخة تدور بتيار منخفض غير طبيعي لا تضخ |
| ريليه تبادل المضخات | تناوب عمل مجدول أو بمنطق في المتحكم |
| إنذار التبديل عند العطل | إشعار فوري لحظة حدوث تبديل أو فصل |

**ما يضيفه الذكي فعلًا هنا — وهو كثير.**

- **تعرف بالأعطال فورًا.** هذا أكبر مكسب على الإطلاق. المجموعة المزدوجة الكلاسيكية التي تتحول للاحتياطية لا تخبر أحدًا. أما المراقَبة فترسل إشعارًا لحظة حدوث ذلك، فيُصلَح العطل والتكرارية ما تزال قائمة بدل أن يُصلَح بعد أن يفقد المبنى ماءه.
- **بيانات التشغيل تكشف أعطالًا ناشئة.** المضخة التي زاد زمن ملئها لنفس الخزان من ثماني دقائق إلى أربع عشرة عبر شهور تخبرك أن مروحتها تبلى أو أن مرشحًا ينسد. لا ريليه يلاحظ هذا الاتجاه؛ لكن نظامًا يسجل كل دورة يجعله بديهيًا.
- **يصبح الاستهلاك مرئيًا.** تشغيلات مضخة غير مفسرة ليلًا، حين لا يسحب أحد ماءً، هي بصمة تسريب. النظام الكلاسيكي يضخ فحسب؛ والمراقَب يكشف النمط.
- **التأكيد عن بُعد يوفر زيارات موقع.** يمكن للحارس أن يتأكد أن الخزان امتلأ ليلًا دون صعود للسطح، ويمكنك الرد على اتصال عميل قلق بالنظر بدل القيادة.

**ما يجب ألا ينتقل للطبقة الذكية.** تنطبق قاعدة برنامج المؤقتات دون تغيير: إن كان الفشل يدمّر معدات أو يعرّض أشخاصًا للخطر، تبقى الحماية عتادية.

**حماية التشغيل الجاف أوضح حالة.** المضخة التي تدور جافة قد تتلف خلال دقائق. فإن اعتمدت حمايتها على خدمة سحابية أو اتصال إنترنت أو مجدول، صار انقطاع الإنترنت مضخة محترقة. يجب أن يكون القاطع تعشيقًا عتاديًا في اللوحة — قطب مستوى أو مفتاح ضغط موصَّل مباشرة في دائرة تحكم المضخة، قادرًا على إيقافها دون أي تدخل من شبكة إطلاقًا.

ودور الطبقة الذكية الصحيح هنا أن **تُبلّغ** عن حدث التشغيل الجاف، لا أن *تؤدي* الحماية. العتاد يوقف المضخة، والتطبيق يخبر العميل لماذا ومتى.

وينطبق المنطق ذاته على منع الطفح حيث يغرق الفشل مبنى، وعلى أي تعشيق يمنع عمل مضختين معًا.

**حوار التحديث — كيف تبيعه بصدق.** أغلب التركيبات القائمة لديها تحكم ريليه يعمل بالفعل. والعرض القوي تجاريًا والصادق تقنيًا ليس "انزع كل شيء واستبدله بأجهزة ذكية" بل:

> أبقِ الحماية التي تعمل بالفعل. وأضف الرؤية فوقها.

تحديث عملي على لوحة مضخات مزدوجة قائمة:
1. **اترك تحكم المستوى وقاطع التشغيل الجاف والتعشيق كما هي تمامًا.** تعمل، ومجربة، وتفشل بأمان.
2. **أضف مراقبة تيار أو قدرة** على تغذية كل مضخة. غير اقتحامية وتخبرك هل عملت كل مضخة فعلًا، وكم، وهل سحبت تيارًا طبيعيًا.
3. **خذ إشارة من تلامسات العطل القائمة** — تلامسات الحمل الزائد المساعدة الموجودة في اللوحة أصلًا — إلى دخل مراقَب، فيطلق الفصل إشعارًا.
4. **أوصل التنبيهات والسجل إلى هاتف العميل.**

لاحظ ما يفعله هذا تجاريًا: عمل إضافي منخفض المخاطر. فأنت لا تتحمل مسؤولية إعادة تصميم نظام سلامة يعمل، ويمكن التركيب دون توقف ممتد، وإن فشلت الطبقة الذكية كليًا لا يتأثر إمداد مياه المبنى إطلاقًا. وهذه النقطة الأخيرة هي ما يجعله عرضًا سهلًا لعميل حذر، وتستحق التصريح بها عند التسعير.

**الصياغة المهنية.** العميل الذي يطلب "مضخات ذكية" يعني عادة أنه يريد أن يعرف ماذا تفعل مضخاته وأن يُخبَر حين يسوء شيء. ونادرًا ما يعني أنه يريد التطبيق أن يقرر متى تتوقف المضخة كي لا تدمّر نفسها. وفصل هذين الأمرين — الإشراف مقابل الحماية — وشرح ما ستنقله وما ستتركه عمدًا، هو كيف يُظهر المركّب حكمًا هندسيًا لا حماسًا للمنتجات.$c$,
5
FROM public.modules WHERE slug = 'finix-sensing-relays';

-- Quizzes
INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'bronze', 'Sensing Relay Basics', 'أساسيات ريليهات الاستشعار', 80
FROM public.modules WHERE slug = 'finix-sensing-relays';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$Why does a sensing relay use two different thresholds (a differential) instead of one?$q$,
    $q$لماذا يستخدم ريليه الاستشعار عتبتين مختلفتين (فرقًا تفاضليًا) بدل واحدة؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-sensing-relays' AND quizzes.tier = 'bronze' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$To prevent chatter when the measured condition hovers near the trip point$o$, $o$لمنع الرفرفة حين تحوم الحالة المقاسة قرب نقطة الفصل$o$, true, 1),
  ($o$To make the relay switch faster$o$, $o$لجعل الريليه يبدّل أسرع$o$, false, 2),
  ($o$To reduce the relay's power consumption$o$, $o$لتقليل استهلاك الريليه للطاقة$o$, false, 3),
  ($o$It is a manufacturing limitation with no purpose$o$, $o$قيد تصنيعي بلا غرض$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$Why do conductive level relays excite their probes with AC rather than DC?$q$,
    $q$لماذا تُثير ريليهات المستوى أقطابها بتيار متردد لا مستمر؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-sensing-relays' AND quizzes.tier = 'bronze' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$DC would cause electrolysis, eroding and coating the probes over time$o$, $o$المستمر يسبب تحليلًا كهربائيًا فيآكل الأقطاب ويغلّفها بمرور الوقت$o$, true, 1),
  ($o$AC is cheaper to generate$o$, $o$توليد المتردد أرخص$o$, false, 2),
  ($o$DC cannot pass through water at all$o$, $o$المستمر لا يمر في الماء إطلاقًا$o$, false, 3),
  ($o$There is no technical reason; it is convention$o$, $o$لا سبب تقني؛ مجرد عرف$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$Why must two pumps in a duplex set alternate rather than one always being the duty pump?$q$,
    $q$لماذا يجب أن تتبادل مضختا المجموعة المزدوجة بدل أن تكون واحدة هي العاملة دائمًا؟$q$, 3
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-sensing-relays' AND quizzes.tier = 'bronze' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$To share wear and to prove regularly that the standby pump still works$o$, $o$لتقاسم البلى ولإثبات أن المضخة الاحتياطية ما تزال تعمل دوريًا$o$, true, 1),
  ($o$To double the water flow rate$o$, $o$لمضاعفة معدل تدفق الماء$o$, false, 2),
  ($o$To reduce the electricity bill$o$, $o$لتقليل فاتورة الكهرباء$o$, false, 3),
  ($o$Alternation is optional and rarely used$o$, $o$التبادل اختياري ونادر الاستخدام$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'silver', 'Applying Sensing Relays', 'تطبيق ريليهات الاستشعار', 80
FROM public.modules WHERE slug = 'finix-sensing-relays';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$Street lighting controlled by a photocell flashes on and off all night. What should you check first?$q$,
    $q$إنارة شارع يتحكم بها ريليه ضوئي تومض طوال الليل. ما أول ما تفحصه؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-sensing-relays' AND quizzes.tier = 'silver' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Whether the sensor can see the lamps it controls, creating a feedback loop$o$, $o$هل يرى الحساس المصابيح التي يتحكم بها، فتنشأ حلقة تغذية راجعة$o$, true, 1),
  ($o$Whether the lamps are the correct wattage$o$, $o$هل المصابيح بالقدرة الصحيحة$o$, false, 2),
  ($o$Whether the cable size is adequate$o$, $o$هل مقطع الكابل كافٍ$o$, false, 3),
  ($o$Whether the supply voltage is exactly nominal$o$, $o$هل جهد التغذية مساوٍ تمامًا للاسمي$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$A well-fed pump keeps restarting seconds after its dry-run cutout trips. What behaviour is missing?$q$,
    $q$مضخة تُغذّى من بئر تعيد التشغيل بعد ثوانٍ من فصل قاطع التشغيل الجاف. ما السلوك المفقود؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-sensing-relays' AND quizzes.tier = 'silver' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$A lockout with a restart delay, allowing the well to recover before restarting$o$, $o$إقفال مع تأخير إعادة تشغيل، يتيح للبئر التعافي قبل إعادة البدء$o$, true, 1),
  ($o$A larger pump motor$o$, $o$محرك مضخة أكبر$o$, false, 2),
  ($o$A higher probe sensitivity setting$o$, $o$ضبط حساسية أعلى للقطب$o$, false, 3),
  ($o$Nothing — rapid restarting is normal for wells$o$, $o$لا شيء — إعادة التشغيل السريعة طبيعية للآبار$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$In a duty/standby pump set, why must the two pump contactors be interlocked?$q$,
    $q$في مجموعة مضخات عاملة/احتياطية، لماذا يجب تعشيق كونتاكتوري المضختين؟$q$, 3
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-sensing-relays' AND quizzes.tier = 'silver' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$So a single level demand cannot start both pumps, doubling inrush and over-pressuring pipework sized for one$o$, $o$كي لا يشغّل طلب مستوى واحد المضختين معًا، فيضاعف الاندفاع ويزيد الضغط في مواسير مقاسة لواحدة$o$, true, 1),
  ($o$To make the pumps run faster$o$, $o$لجعل المضختين تدوران أسرع$o$, false, 2),
  ($o$Interlocking is only needed for motor reversing, not pumps$o$, $o$التعشيق مطلوب فقط لعكس المحركات لا للمضخات$o$, false, 3),
  ($o$To reduce the number of contactors required$o$, $o$لتقليل عدد الكونتاكتورات المطلوبة$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'gold', 'Sensing Design & Smart Retrofit', 'تصميم الاستشعار والتحديث الذكي', 80
FROM public.modules WHERE slug = 'finix-sensing-relays';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$A client wants dry-run protection handled by a cloud-connected smart sensor instead of a hardware cutout. Why is this wrong?$q$,
    $q$يريد عميل أن تُدار حماية التشغيل الجاف بحساس ذكي متصل بالسحابة بدل قاطع عتادي. لماذا هذا خطأ؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-sensing-relays' AND quizzes.tier = 'gold' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$An internet or cloud outage would leave the pump running dry and destroy it within minutes; protection must work with no network$o$, $o$انقطاع الإنترنت أو السحابة سيترك المضخة تدور جافة فتتلف خلال دقائق؛ يجب أن تعمل الحماية دون شبكة$o$, true, 1),
  ($o$Smart sensors cannot measure water level at all$o$, $o$الحساسات الذكية لا تستطيع قياس مستوى الماء إطلاقًا$o$, false, 2),
  ($o$It would cost more than a hardware cutout$o$, $o$سيكلف أكثر من قاطع عتادي$o$, false, 3),
  ($o$It is fine as long as the internet is usually reliable$o$, $o$لا بأس به ما دام الإنترنت موثوقًا غالبًا$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$A duplex pump set has silently been running on its standby pump for two months. What design failure does this reveal?$q$,
    $q$مجموعة مضخات مزدوجة تعمل صامتة على مضختها الاحتياطية منذ شهرين. أي فشل تصميمي يكشفه هذا؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-sensing-relays' AND quizzes.tier = 'gold' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Changeover occurred with no alarm, so redundancy was consumed without anyone knowing$o$, $o$حدث التبديل دون إنذار، فاستُهلكت التكرارية دون علم أحد$o$, true, 1),
  ($o$The pumps were alternating correctly as designed$o$, $o$كانت المضختان تتبادلان بشكل صحيح كما صُمم$o$, false, 2),
  ($o$The standby pump is more efficient and should stay in duty$o$, $o$المضخة الاحتياطية أكفأ وينبغي أن تظل عاملة$o$, false, 3),
  ($o$Nothing is wrong; this is normal duplex behaviour$o$, $o$لا خطأ؛ هذا سلوك مزدوج طبيعي$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id,
    $q$Quoting a smart retrofit on a working relay-based pump panel, which scope is the soundest proposal?$q$,
    $q$عند تسعير تحديث ذكي للوحة مضخات تعمل بالريليهات، أي نطاق هو العرض الأسلم؟$q$, 3
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-sensing-relays' AND quizzes.tier = 'gold' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Leave level control, dry-run cutout and interlock intact; add current monitoring and fault-contact signals for alerts and history$o$, $o$اترك تحكم المستوى وقاطع التشغيل الجاف والتعشيق كما هي؛ وأضف مراقبة تيار وإشارات تلامسات العطل للتنبيهات والسجل$o$, true, 1),
  ($o$Remove all relays and rebuild the panel around cloud-controlled devices$o$, $o$انزع كل الريليهات وأعد بناء اللوحة حول أجهزة تعمل بالسحابة$o$, false, 2),
  ($o$Add smart devices but disconnect the old overloads to avoid conflicts$o$, $o$أضف أجهزة ذكية مع فصل الحمولات الزائدة القديمة لتجنب التعارض$o$, false, 3),
  ($o$Monitor only, and also move the dry-run cutout into the app for easier adjustment$o$, $o$راقب فقط، وانقل أيضًا قاطع التشغيل الجاف للتطبيق لتسهيل الضبط$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);
