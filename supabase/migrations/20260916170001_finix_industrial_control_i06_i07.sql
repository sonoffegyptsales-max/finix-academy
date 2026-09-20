-- Modules I06 and I07
-- ORIGINAL CONTENT written for Finix.

-- ===== I06: Voltage & Phase Protection =====
INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES (
  'finix-voltage-phase-protection',
  'I06',
  'finix-industrial-control',
  'Voltage & Phase Protection',
  'حماية الجهد والأطوار',
  $s$Supply-side faults that destroy equipment: under- and over-voltage, phase failure, phase reversal and asymmetry — what each does, how protection relays detect them, and why phase sequence must be checked before a pump ever runs.$s$,
  $s$أعطال جهة التغذية التي تدمّر المعدات: انخفاض وارتفاع الجهد، فقد الطور، عكس تتابع الأطوار وعدم الاتزان — ماذا يفعل كل منها، وكيف تكشفها ريليهات الحماية، ولماذا يجب فحص تتابع الأطوار قبل تشغيل أي مضخة.$s$,
  NULL,
  31
)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$Supply Faults and What They Destroy$t$,
$t$أعطال التغذية وما تدمّره$t$,
$c$Motor protection covered faults originating in the motor or its load. This lesson covers faults arriving from the **supply** — and in many regions, including much of Egypt, supply-side disturbance is the more common cause of equipment failure.

**Under-voltage.** When supply voltage falls below the motor's rated value, the motor attempts to deliver the same mechanical power from a lower voltage, which it can only do by drawing more current. That current causes heating. A motor running continuously at significantly reduced voltage will overheat even though nothing is mechanically wrong.

Under-voltage also causes contactors to drop out or, worse, to chatter — hovering at the margin of holding, buzzing, overheating and eventually welding or burning their coils.

**Over-voltage.** Excess voltage stresses winding insulation and saturates magnetic cores, causing additional heating. It is generally less immediately destructive than under-voltage for motors, but it is hard on electronics — drives, control power supplies and any smart devices in the panel.

**Phase failure.** As covered in the protection module: a three-phase motor that loses one phase keeps running on two, drawing much higher current in the remaining phases and overheating. The critical point bears repeating — the motor does *not* stop, so the fault is not self-announcing.

Phase failure has a second, nastier variant. If a phase is lost while the motor is stopped, it will not start when commanded. It will sit drawing heavy current with no rotation, heating rapidly. A motor that hums but does not turn is the classic symptom, and the correct response is to remove power immediately rather than repeatedly attempting to start it.

**Phase asymmetry (imbalance).** The three phases may all be present but at unequal voltages. Even modest imbalance produces disproportionately large imbalance in the motor's currents, causing uneven heating in the windings. A motor fed from an imbalanced supply runs hotter and dies younger, with no single dramatic event to point at.

**Phase reversal (wrong phase sequence).** If two phases are swapped, a three-phase motor runs backwards. For some loads this is merely wrong; for others it is destructive:
- A **centrifugal pump** running backwards moves little or no water while appearing to run normally. It can run dry and damage its seal, and the fault may go undiagnosed because the motor sounds fine.
- A **compressor** running backwards can be damaged quickly, as lubrication systems are often direction-dependent.
- A **conveyor or lift** running backwards is an immediate safety hazard.

This is why phase sequence must be verified before commissioning any directional equipment, and re-verified after any work on the incoming supply. A common and costly scenario: a utility does work on the street supply, reconnects two phases transposed, and every pump in the building begins turning backwards simultaneously.

**Voltage protection relays.** A supply protection relay monitors all three phases continuously and trips a contactor when any monitored condition goes out of limits. Typical functions:
- Under-voltage and over-voltage, each with an adjustable threshold.
- Phase failure.
- Phase asymmetry, with an adjustable percentage threshold.
- Phase sequence, which refuses to allow operation if the sequence is wrong.

**Settings, and the reason for each.** As with sensing relays, these devices have a threshold, a differential and a delay:
- **Thresholds** should be set from the connected equipment's tolerance, not arbitrarily. Too tight and the plant trips on every minor supply fluctuation; too loose and equipment is damaged before protection acts.
- **Trip delay** prevents tripping on brief dips — a large motor starting elsewhere in the building causes a momentary dip that is harmless.
- **Restart delay** is essential. After a supply failure, every motor in the building would otherwise restart simultaneously the moment power returns, producing a combined inrush that can trip the incoming protection or collapse the supply again. A staggered restart delay, with different delays on different machines, spreads the load.

**A worked example — water pump protection in a building with unstable supply.** Requirements and reasoning:
1. **Phase sequence protection** prevents the pumps running backwards after any supply work. Without it, a transposed reconnection means pumps that run but deliver nothing.
2. **Phase failure protection** stops the pumps rather than letting them run on two phases.
3. **Under-voltage protection** stops them during a brownout instead of letting them overheat.
4. **Restart delay**, different for each pump, prevents both restarting simultaneously when supply returns.
5. **Dry-run protection** remains in place independently — supply protection does not replace it, because the two answer different threats.

That layering is the point: each protective device answers one specific threat, and none of them substitutes for another.$c$,
$c$غطّت حماية المحركات أعطالًا منشؤها المحرك أو حمله. ويغطي هذا الدرس أعطالًا تصل من **التغذية** — وفي مناطق كثيرة، منها أجزاء واسعة من مصر، يكون اضطراب جهة التغذية السبب الأشيع لفشل المعدات.

**انخفاض الجهد.** حين يهبط جهد التغذية دون قيمة المحرك المقننة، يحاول المحرك تقديم القدرة الميكانيكية ذاتها من جهد أقل، ولا يستطيع ذلك إلا بسحب تيار أكبر. وذلك التيار يسبب تسخينًا. والمحرك العامل باستمرار بجهد منخفض كثيرًا سيسخن رغم سلامة كل شيء ميكانيكيًا.

ويسبب انخفاض الجهد أيضًا سقوط الكونتاكتورات أو — وهو أسوأ — ارتعاشها: تحوم عند حافة الإمساك، تطن، تسخن، وتلتحم أو تحترق ملفاتها في النهاية.

**ارتفاع الجهد.** الجهد الزائد يُجهد عزل الملفات ويُشبع القلوب المغناطيسية، مسببًا تسخينًا إضافيًا. وهو أقل تدميرًا فوريًا من انخفاض الجهد للمحركات عمومًا، لكنه قاسٍ على الإلكترونيات — المغيّرات ومزودات قدرة التحكم وأي أجهزة ذكية في اللوحة.

**فقد الطور.** كما في برنامج الحماية: المحرك ثلاثي الأطوار الذي يفقد طورًا يستمر على طورين، ساحبًا تيارًا أعلى بكثير في الطورين الباقيين فيسخن. والنقطة الحرجة تستحق التكرار — المحرك *لا* يتوقف، فالعطل لا يعلن عن نفسه.

ولفقد الطور صورة ثانية أسوأ. فإن فُقد طور والمحرك متوقف، لن يبدأ عند الأمر. بل سيبقى ساحبًا تيارًا ثقيلًا بلا دوران، يسخن بسرعة. والمحرك الذي يطن دون أن يدور هو العرض الكلاسيكي، والاستجابة الصحيحة قطع التغذية فورًا بدل محاولات بدء متكررة.

**عدم اتزان الأطوار.** قد تكون الأطوار الثلاثة موجودة لكن بجهود غير متساوية. وحتى عدم اتزان معتدل ينتج عدم اتزان كبيرًا بشكل غير متناسب في تيارات المحرك، مسببًا تسخينًا غير متساوٍ في الملفات. والمحرك المغذّى من تغذية غير متزنة يعمل أسخن ويموت أصغر، دون حدث درامي واحد يمكن الإشارة إليه.

**عكس تتابع الأطوار.** إن بُدّل طوران، دار المحرك ثلاثي الأطوار عكسيًا. ولبعض الأحمال هذا خطأ فحسب؛ ولأخرى مدمّر:
- **المضخة الطاردة المركزية** الدائرة عكسيًا تحرّك ماءً قليلًا أو معدومًا بينما تبدو تعمل طبيعيًا. وقد تعمل جافة وتتلف حشوتها، وقد يبقى العطل دون تشخيص لأن صوت المحرك سليم.
- **الضاغط** الدائر عكسيًا قد يتلف سريعًا، فأنظمة التشحيم غالبًا معتمدة على الاتجاه.
- **السير الناقل أو المصعد** الدائر عكسيًا خطر سلامة فوري.

ولهذا يجب التحقق من تتابع الأطوار قبل التشغيل التجريبي لأي معدة اتجاهية، وإعادة التحقق بعد أي عمل على التغذية الداخلة. وسيناريو شائع ومكلف: تقوم شركة الكهرباء بعمل على تغذية الشارع، فتعيد توصيل طورين متبادلين، فتبدأ كل مضخات المبنى بالدوران عكسيًا في آن واحد.

**ريليهات حماية الجهد.** ريليه حماية التغذية يراقب الأطوار الثلاثة باستمرار ويفصل كونتاكتورًا حين تخرج أي حالة مراقَبة عن الحدود. والوظائف النموذجية:
- انخفاض وارتفاع الجهد، لكل منهما عتبة قابلة للضبط.
- فقد الطور.
- عدم اتزان الأطوار، بعتبة نسبة مئوية قابلة للضبط.
- تتابع الأطوار، فيرفض السماح بالتشغيل إن كان التتابع خاطئًا.

**الضبطات وسبب كل منها.** كما في ريليهات الاستشعار، لهذه الأجهزة عتبة وفرق تفاضلي وتأخير:
- **العتبات** ينبغي ضبطها من تحمل المعدات الموصولة، لا اعتباطًا. فالضيقة جدًا تجعل المنشأة تفصل عند كل تذبذب تغذية طفيف؛ والواسعة جدًا تترك المعدات تتلف قبل أن تتصرف الحماية.
- **تأخير الفصل** يمنع الفصل عند الهبوطات القصيرة — فبدء محرك كبير في مكان آخر بالمبنى يسبب هبوطًا لحظيًا غير ضار.
- **تأخير إعادة التشغيل** ضروري. فبعد انقطاع تغذية، كان كل محرك في المبنى سيعيد التشغيل في آن واحد لحظة عودة الكهرباء، منتجًا اندفاعًا مجمّعًا قد يفصل الحماية الداخلة أو يُسقط التغذية ثانية. وتأخير إعادة تشغيل متدرج، بقيم مختلفة لماكينات مختلفة، يوزّع الحمل.

**مثال محلول — حماية مضخات مياه في مبنى بتغذية غير مستقرة.** المتطلبات والمنطق:
1. **حماية تتابع الأطوار** تمنع دوران المضخات عكسيًا بعد أي عمل على التغذية. وبدونها يعني إعادة توصيل متبادلة مضخات تدور ولا تضخ شيئًا.
2. **حماية فقد الطور** توقف المضخات بدل تركها تعمل على طورين.
3. **حماية انخفاض الجهد** توقفها أثناء هبوط الجهد بدل تركها تسخن.
4. **تأخير إعادة تشغيل** مختلف لكل مضخة، يمنع إعادة تشغيلهما معًا عند عودة التغذية.
5. **حماية التشغيل الجاف** تبقى قائمة باستقلال — فحماية التغذية لا تحل محلها، لأن الاثنتين تعالجان تهديدين مختلفين.

وهذا التطبيق الطبقي هو المقصود: كل جهاز حماية يعالج تهديدًا محددًا واحدًا، ولا يغني أي منها عن الآخر.$c$,
1
FROM public.modules WHERE slug = 'finix-voltage-phase-protection';

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'bronze', 'Supply Fault Basics', 'أساسيات أعطال التغذية', 80
FROM public.modules WHERE slug = 'finix-voltage-phase-protection';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$What happens to a centrifugal pump whose phase sequence is reversed?$q$,
    $q$ماذا يحدث لمضخة طاردة مركزية عُكس تتابع أطوارها؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-voltage-phase-protection' AND quizzes.tier = 'bronze' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$It runs backwards, moving little or no water while sounding normal, and can run dry$o$, $o$تدور عكسيًا فتحرّك ماءً قليلًا أو معدومًا بينما يبدو صوتها طبيعيًا، وقد تعمل جافة$o$, true, 1),
  ($o$It refuses to start at all$o$, $o$ترفض البدء إطلاقًا$o$, false, 2),
  ($o$It pumps at double the normal rate$o$, $o$تضخ بضعف المعدل الطبيعي$o$, false, 3),
  ($o$Phase sequence does not affect pumps$o$, $o$تتابع الأطوار لا يؤثر على المضخات$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$Why does under-voltage cause a motor to overheat?$q$,
    $q$لماذا يسبب انخفاض الجهد سخونة المحرك؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-voltage-phase-protection' AND quizzes.tier = 'bronze' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$It draws more current to deliver the same mechanical power, and current causes heating$o$, $o$يسحب تيارًا أكبر لتقديم القدرة الميكانيكية ذاتها، والتيار يسبب تسخينًا$o$, true, 1),
  ($o$Lower voltage directly heats the windings$o$, $o$الجهد الأقل يسخّن الملفات مباشرة$o$, false, 2),
  ($o$Under-voltage always reduces heating$o$, $o$انخفاض الجهد يقلل التسخين دائمًا$o$, false, 3),
  ($o$It causes the cooling fan to reverse$o$, $o$يجعل مروحة التبريد تعكس اتجاهها$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$A motor hums but does not turn when started. What should you suspect and do?$q$,
    $q$محرك يطن دون أن يدور عند البدء. بماذا تشتبه وماذا تفعل؟$q$, 3
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-voltage-phase-protection' AND quizzes.tier = 'bronze' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Suspect a lost phase; remove power immediately rather than retrying the start$o$, $o$اشتبه بفقد طور؛ اقطع التغذية فورًا بدل إعادة محاولة البدء$o$, true, 1),
  ($o$Keep pressing start until it turns$o$, $o$استمر بضغط البدء حتى يدور$o$, false, 2),
  ($o$Increase the overload setting$o$, $o$ارفع ضبط الحمل الزائد$o$, false, 3),
  ($o$Humming without rotation is normal at start$o$, $o$الطنين بلا دوران طبيعي عند البدء$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'silver', 'Applying Supply Protection', 'تطبيق حماية التغذية', 80
FROM public.modules WHERE slug = 'finix-voltage-phase-protection';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$Why must different machines have different restart delays after a supply failure?$q$,
    $q$لماذا يجب أن تكون لماكينات مختلفة تأخيرات إعادة تشغيل مختلفة بعد انقطاع التغذية؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-voltage-phase-protection' AND quizzes.tier = 'silver' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Simultaneous restart produces a combined inrush that can trip the incoming protection or collapse the supply again$o$, $o$إعادة التشغيل المتزامنة تنتج اندفاعًا مجمّعًا قد يفصل الحماية الداخلة أو يُسقط التغذية ثانية$o$, true, 1),
  ($o$It spreads the electricity bill more evenly$o$, $o$يوزّع فاتورة الكهرباء بتساوٍ أكبر$o$, false, 2),
  ($o$Restart delays are only cosmetic$o$, $o$تأخيرات إعادة التشغيل شكلية فقط$o$, false, 3),
  ($o$Motors cannot restart without a delay at all$o$, $o$المحركات لا تستطيع إعادة التشغيل بلا تأخير إطلاقًا$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$After the utility worked on the street supply, every pump in a building runs but delivers no water. What is the likely cause?$q$,
    $q$بعد عمل شركة الكهرباء على تغذية الشارع، كل مضخات المبنى تعمل دون ضخ ماء. ما السبب المرجح؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-voltage-phase-protection' AND quizzes.tier = 'silver' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Two phases were reconnected transposed, reversing phase sequence so all pumps run backwards$o$, $o$أُعيد توصيل طورين متبادلين، فعُكس تتابع الأطوار وصارت كل المضخات تدور عكسيًا$o$, true, 1),
  ($o$All the pump impellers failed at once$o$, $o$تلفت كل مراوح المضخات دفعة واحدة$o$, false, 2),
  ($o$The building's water source ran dry simultaneously$o$, $o$جف مصدر مياه المبنى في آن واحد$o$, false, 3),
  ($o$Supply work cannot affect pump direction$o$, $o$عمل التغذية لا يؤثر على اتجاه المضخات$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'gold', 'Layered Protection Design', 'تصميم الحماية الطبقية', 80
FROM public.modules WHERE slug = 'finix-voltage-phase-protection';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$A client asks why a pump panel needs both supply protection and dry-run protection. What is the correct explanation?$q$,
    $q$يسأل عميل لماذا تحتاج لوحة مضخة حماية تغذية وحماية تشغيل جاف معًا. ما الشرح الصحيح؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-voltage-phase-protection' AND quizzes.tier = 'gold' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$They answer different threats — one watches the supply, the other watches the water; neither substitutes for the other$o$, $o$يعالجان تهديدين مختلفين — أحدهما يراقب التغذية والآخر يراقب الماء؛ ولا يغني أحدهما عن الآخر$o$, true, 1),
  ($o$Supply protection makes dry-run protection unnecessary$o$, $o$حماية التغذية تُغني عن حماية التشغيل الجاف$o$, false, 2),
  ($o$It is duplication that could be removed to save cost$o$, $o$تكرار يمكن إزالته لتوفير التكلفة$o$, false, 3),
  ($o$Only one is ever needed; the choice is arbitrary$o$, $o$واحدة فقط تلزم؛ والاختيار اعتباطي$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$A voltage protection relay set with very tight thresholds causes frequent nuisance trips. What is the right response?$q$,
    $q$ريليه حماية جهد مضبوط بعتبات ضيقة جدًا يسبب فصلًا مزعجًا متكررًا. ما الاستجابة الصحيحة؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-voltage-phase-protection' AND quizzes.tier = 'gold' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Set thresholds from the connected equipment's actual tolerance and add a short trip delay for brief dips$o$, $o$اضبط العتبات من تحمل المعدات الموصولة الفعلي وأضف تأخير فصل قصيرًا للهبوطات القصيرة$o$, true, 1),
  ($o$Bypass the relay entirely$o$, $o$تجاوز الريليه كليًا$o$, false, 2),
  ($o$Set thresholds as wide as the relay allows$o$, $o$اضبط العتبات بأوسع ما يسمح الريليه$o$, false, 3),
  ($o$Replace all the motors$o$, $o$استبدل كل المحركات$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

-- ===== I07: Panel Building & Fault-Finding =====
INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES (
  'finix-panel-building-faultfinding',
  'I07',
  'finix-industrial-control',
  'Panel Building & Fault-Finding',
  'بناء اللوحات وتتبع الأعطال',
  $s$Building a control panel that can be maintained, and diagnosing one that has failed: layout and segregation, labelling and documentation, safe isolation, and a systematic fault-finding method that beats guessing.$s$,
  $s$بناء لوحة تحكم قابلة للصيانة، وتشخيص لوحة تعطلت: التخطيط والفصل، الترقيم والتوثيق، العزل الآمن، ومنهج منظم لتتبع الأعطال يتفوق على التخمين.$s$,
  NULL,
  32
)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$Building a Panel That Can Be Maintained$t$,
$t$بناء لوحة قابلة للصيانة$t$,
$c$A control panel is built once and maintained for years, often by people who did not build it. Panel quality is measured not by how it looks on handover day but by how quickly someone can diagnose it at two in the morning three years later.

**Layout principles.**
- **Segregate power and control.** As covered in the contactors module: separate trunking, separate routes. This reduces induced interference and makes the panel readable.
- **Group by function.** Keep each starter's components together — its breaker, contactor and overload adjacent — so a technician working on one machine works in one area rather than tracing wires across the whole backplate.
- **Respect heat.** Contactors, drives and transformers dissipate heat, which rises. Place heat-producing components where their heat will not cook temperature-sensitive electronics above them, and leave the clearances the manufacturer specifies. A panel that works in winter and trips in August usually has a ventilation problem designed in from the start.
- **Leave room for the future.** Spare space on the DIN rail and spare terminals cost almost nothing at build time and save an enormous amount when a client wants a circuit added later.

**Wire identification — the single highest-value habit.** Every conductor should carry a marker at both ends, and the marking must match the drawing. This is the difference between a five-minute diagnosis and a two-hour one.

Number the wires according to the schematic rather than inventing a scheme at the bench: a technician holding the drawing should be able to find any wire in the panel and vice versa. Consistent colour coding — for phases, neutral, earth, and control conductors — reinforces this, and consistency matters more than which specific convention you adopt.

**Terminal discipline.** Use terminal rails for all field connections rather than wiring directly to devices. This means a field cable can be disconnected for testing without disturbing internal panel wiring, and a faulty device can be replaced without cutting anything. It costs a little more and repays it the first time anyone works on the panel.

Observe torque specifications on terminals. Under-tightened terminals produce high-resistance joints that heat, oxidise and eventually fail — an intermittent fault that is genuinely difficult to find because it appears only under load. Over-tightened terminals damage the conductor. Both are avoidable with a torque screwdriver.

**Documentation that actually helps.** The panel should leave your hands with:
- A **schematic** matching the as-built wiring, including any changes made during commissioning. A drawing that does not match reality is worse than no drawing, because it sends the next technician in the wrong direction with confidence.
- A **panel schedule** listing every protective device with its **measured** settings, not just intended ones.
- Timer settings recorded against the machine they were set for.
- A copy inside the panel door, in a pocket, where someone will actually find it.

**Safe isolation — the discipline that keeps people alive.** Before working inside any panel:
1. **Identify** the correct isolator for the circuit — not one that looks right.
2. **Isolate** and **lock off** with your own lock, retaining the key.
3. **Prove the tester works** on a known live source.
4. **Test that the circuit is dead** at the point you will work.
5. **Prove the tester still works** on the known source, confirming it did not fail between steps three and four.

That prove-test-prove sequence is not bureaucracy. A tester that failed silently between steps would show a live circuit as dead, and the consequence is fatal.

**Beware secondary supplies.** A panel may contain circuits fed from elsewhere — a fire alarm interface, a BMS connection, a remote-start signal from another panel, an uninterruptible supply. Isolating the main incomer does not necessarily make everything inside the panel dead. Always test the specific point you intend to touch, and look for warning labels indicating multiple supplies.

**Capacitors hold charge.** Drives and power-factor correction equipment store energy and remain dangerous after isolation. Observe the manufacturer's stated discharge time before working on them, and test rather than assume.$c$,
$c$لوحة التحكم تُبنى مرة وتُصان سنوات، غالبًا على يد من لم يبنوها. وتُقاس جودة اللوحة لا بشكلها يوم التسليم بل بسرعة تشخيصها في الثانية صباحًا بعد ثلاث سنوات.

**مبادئ التخطيط.**
- **افصل القوى عن التحكم.** كما في برنامج الكونتاكتورات: مجارٍ منفصلة ومسارات منفصلة. يقلل ذلك التداخل المحثّ ويجعل اللوحة مقروءة.
- **جمّع حسب الوظيفة.** أبقِ مكونات كل بادئ معًا — قاطعه وكونتاكتوره وحمله الزائد متجاورة — فيعمل الفني على ماكينة واحدة في منطقة واحدة بدل تتبع أسلاك عبر اللوحة كلها.
- **احترم الحرارة.** الكونتاكتورات والمغيّرات والمحولات تبدد حرارة، والحرارة تصعد. ضع المكونات المولّدة للحرارة حيث لا تطهو حرارتها إلكترونيات حساسة فوقها، واترك الخلوص الذي تحدده الشركة المصنّعة. واللوحة التي تعمل شتاءً وتفصل في أغسطس لديها عادة مشكلة تهوية مصممة فيها منذ البداية.
- **اترك مساحة للمستقبل.** المساحة الفائضة على قضيب التثبيت والأطراف الاحتياطية لا تكلف شيئًا تقريبًا وقت البناء وتوفر الكثير حين يريد عميل إضافة دائرة لاحقًا.

**ترقيم الأسلاك — أعلى العادات قيمة.** كل موصل ينبغي أن يحمل علامة عند طرفيه، ويجب أن يطابق الترقيم الرسم. وهذا الفرق بين تشخيص في خمس دقائق وآخر في ساعتين.

رقّم الأسلاك وفق المخطط لا بابتكار نظام على الطاولة: فالفني الممسك بالرسم ينبغي أن يجد أي سلك في اللوحة والعكس. والترميز اللوني المتسق — للأطوار والمتعادل والأرضي وموصلات التحكم — يعزز ذلك، والاتساق أهم من أي عرف بعينه تتبناه.

**انضباط الأطراف.** استخدم قضبان أطراف لكل التوصيلات الميدانية بدل التوصيل مباشرة للأجهزة. فهذا يعني إمكان فصل كابل ميداني للاختبار دون إزعاج أسلاك اللوحة الداخلية، واستبدال جهاز معطوب دون قطع شيء. يكلف قليلًا ويرد تكلفته أول مرة يعمل فيها أحد على اللوحة.

والتزم مواصفات عزم الربط للأطراف. فالأطراف غير المربوطة كفاية تنتج وصلات عالية المقاومة تسخن وتتأكسد وتفشل في النهاية — عطل متقطع يصعب إيجاده فعلًا لأنه يظهر تحت الحمل فقط. والأطراف المربوطة أكثر من اللازم تتلف الموصل. وكلاهما يمكن تجنبه بمفك عزم.

**توثيق ينفع فعلًا.** ينبغي أن تغادر اللوحة يديك ومعها:
- **مخطط** يطابق التسليك كما بُني، شاملًا أي تغييرات أثناء التشغيل التجريبي. فالرسم الذي لا يطابق الواقع أسوأ من لا رسم، لأنه يرسل الفني التالي في الاتجاه الخاطئ بثقة.
- **جدول لوحة** يسرد كل جهاز حماية بضبطاته **المقاسة** لا المقصودة فقط.
- ضبطات المؤقتات مسجّلة مقابل الماكينة التي ضُبطت لها.
- نسخة داخل باب اللوحة، في جيب، حيث سيجدها أحدهم فعلًا.

**العزل الآمن — الانضباط الذي يُبقي الناس أحياء.** قبل العمل داخل أي لوحة:
1. **حدد** العازل الصحيح للدائرة — لا واحدًا يبدو صحيحًا.
2. **اعزل** و**أقفل** بقفلك الخاص، محتفظًا بالمفتاح.
3. **أثبت أن جهاز الاختبار يعمل** على مصدر حي معلوم.
4. **اختبر أن الدائرة ميتة** عند النقطة التي ستعمل عندها.
5. **أثبت أن جهاز الاختبار ما يزال يعمل** على المصدر المعلوم، مؤكدًا أنه لم يتعطل بين الخطوتين الثالثة والرابعة.

وتتابع أثبت-اختبر-أثبت ليس بيروقراطية. فجهاز اختبار تعطل صامتًا بين الخطوتين سيُظهر دائرة حية كميتة، والعاقبة قاتلة.

**احذر التغذيات الثانوية.** قد تحتوي اللوحة دوائر مغذّاة من مكان آخر — واجهة إنذار حريق، أو وصلة نظام إدارة مبنى، أو إشارة بدء بعيد من لوحة أخرى، أو مصدر غير منقطع. وعزل المصدر الرئيسي لا يجعل كل ما في اللوحة ميتًا بالضرورة. اختبر دائمًا النقطة المحددة التي تنوي لمسها، وابحث عن ملصقات تحذير تشير لتغذيات متعددة.

**المكثفات تحتفظ بشحنة.** المغيّرات ومعدات تحسين معامل القدرة تخزن طاقة وتبقى خطيرة بعد العزل. التزم زمن التفريغ الذي تحدده الشركة المصنّعة قبل العمل عليها، واختبر بدل أن تفترض.$c$,
1
FROM public.modules WHERE slug = 'finix-panel-building-faultfinding';

INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
SELECT id,
$t$A Systematic Fault-Finding Method$t$,
$t$منهج منظم لتتبع الأعطال$t$,
$c$Most time lost in fault-finding is spent testing things that were never going to be faulty. A systematic method beats intuition, and it is learnable.

**Step 1 — Gather information before touching anything.** Ask what changed. A machine that worked yesterday and fails today has had something happen to it: maintenance, a supply interruption, a new load added, a setting adjusted, water ingress, or simply a component reaching end of life. The answer frequently identifies the fault before any testing begins.

Ask what the symptom actually is, precisely. "It does not work" is not a symptom. Does the contactor pull in? Does the motor hum? Does it start and then trip? Does it fail only when hot, or only under load, or only in the morning? Each of these points in a different direction.

**Step 2 — Read what the panel is telling you.** Before opening anything, look at the indicators. Which protective devices have operated? As covered in the protection module, the device that tripped is evidence:
- Overload tripped → sustained overcurrent, look mechanical or at a lost phase.
- Short-circuit protection operated → genuine fault, find it before re-energising.
- Thermistor tripped but overload intact → motor hot with normal current; check cooling and duty.
- Nothing tripped but nothing runs → look at the control circuit.

**Step 3 — Split the problem in half.** This is the technique that saves the most time. Rather than testing components in sequence from one end, test at a midpoint to determine which half contains the fault, then repeat within that half. A control circuit with twenty components is diagnosed in a handful of tests rather than twenty.

The natural first split in any motor circuit is **control versus power**: is the contactor coil being energised? If yes, the control circuit is doing its job and the fault is downstream in the power circuit or the motor. If no, the fault is in the control circuit. One test eliminates half the panel.

**Step 4 — Test, do not assume.** Measure rather than inferring from appearance. A contactor that looks closed may have burnt contacts. A wire that looks connected may be broken inside its insulation. A fuse that looks intact may be open.

**Step 5 — Find the root cause, not just the failed part.** A blown fuse is a symptom. A motor that burnt out is a symptom. Replacing the component without asking *why* it failed means it will fail again, and the second failure often costs more than the first.

If an overload keeps tripping, the question is why the current is high — a seizing bearing, a blocked impeller, a lost phase, a mechanical obstruction — not how to make the relay stop complaining.

**Common faults and their signatures.**

| Symptom | Likely causes |
|---|---|
| Contactor chatters or buzzes | Low control voltage, undersized control transformer, damaged shading ring, dirt between core faces |
| Motor hums but does not rotate | Lost phase, mechanically seized load |
| Motor starts then trips after a period | Genuine overload, ventilation blocked, overload set too low, bearing failing |
| Panel works cold, trips when hot | High-resistance joint heating up, ventilation inadequate, thermal overload responding to ambient |
| Intermittent fault under vibration | Loose terminal, damaged conductor inside insulation |
| Everything dead, nothing tripped | Control supply failure, control fuse, a normally-closed device in the stop chain open |
| Motor runs but delivers nothing | Phase reversal (pump/compressor), coupling failure, impeller damage |

**The intermittent fault — the hardest case.** Faults that appear and disappear are usually thermal or mechanical: a joint that opens when it expands, a conductor broken inside insulation that separates under vibration, a component failing only at temperature. Testing while the fault is absent proves nothing.

The productive approach is to find what correlates with the fault: does it appear when the plant is hot, when a particular machine starts, after rain, at a certain time of day? The correlation points at the cause far more reliably than random testing does. Thermal imaging, where available, finds high-resistance joints immediately — they run hot before they fail completely.

**Record what you found and what you did.** Write it on the panel schedule or the job record. The next fault on that panel is frequently related to the last one, and a history turns a mysterious recurring problem into an obvious pattern. This discipline is what makes an experienced technician efficient — not memory, but documentation.$c$,
$c$أغلب الوقت الضائع في تتبع الأعطال يُنفق على اختبار أشياء لم تكن لتكون معطوبة أصلًا. والمنهج المنظم يتفوق على الحدس، وهو قابل للتعلم.

**الخطوة 1 — اجمع المعلومات قبل لمس أي شيء.** اسأل ما الذي تغيّر. فالماكينة التي عملت أمس وتعطلت اليوم حدث لها شيء: صيانة، أو انقطاع تغذية، أو حمل جديد أُضيف، أو ضبط عُدّل، أو دخول ماء، أو ببساطة مكوّن بلغ نهاية عمره. والجواب غالبًا يحدد العطل قبل بدء أي اختبار.

واسأل ما هو العرض بالضبط. "لا يعمل" ليس عرضًا. هل ينسحب الكونتاكتور؟ هل يطن المحرك؟ هل يبدأ ثم يفصل؟ هل يفشل حين يسخن فقط، أو تحت الحمل فقط، أو صباحًا فقط؟ كل من هذه يشير لاتجاه مختلف.

**الخطوة 2 — اقرأ ما تخبرك به اللوحة.** قبل فتح أي شيء، انظر للمؤشرات. أي أجهزة حماية عملت؟ كما في برنامج الحماية، الجهاز الذي فصل دليل:
- فصل الحمل الزائد ← تيار زائد مستمر، ابحث ميكانيكيًا أو عن طور مفقود.
- عملت حماية القصر ← عطل حقيقي، اعثر عليه قبل إعادة التغذية.
- فصل الثرمستور والحمل الزائد سليم ← محرك ساخن بتيار طبيعي؛ افحص التبريد ودورة التشغيل.
- لم يفصل شيء ولا يعمل شيء ← انظر لدائرة التحكم.

**الخطوة 3 — قسّم المشكلة نصفين.** هذه التقنية توفر أكبر قدر من الوقت. فبدل اختبار المكونات بالتتابع من طرف، اختبر عند نقطة وسطى لتحديد أي نصف يحوي العطل، ثم كرر داخل ذلك النصف. فدائرة تحكم بعشرين مكونًا تُشخَّص في اختبارات معدودة بدل عشرين.

والتقسيم الأول الطبيعي في أي دائرة محرك هو **التحكم مقابل القوى**: هل يُغذّى ملف الكونتاكتور؟ إن نعم، فدائرة التحكم تؤدي عملها والعطل خلفها في دائرة القوى أو المحرك. وإن لا، فالعطل في دائرة التحكم. اختبار واحد يستبعد نصف اللوحة.

**الخطوة 4 — اختبر ولا تفترض.** قِس بدل الاستنتاج من المظهر. فالكونتاكتور الذي يبدو مغلقًا قد تكون تلامساته محترقة. والسلك الذي يبدو موصّلًا قد يكون مقطوعًا داخل عزله. والفيوز الذي يبدو سليمًا قد يكون مفتوحًا.

**الخطوة 5 — اعثر على السبب الجذري لا القطعة التالفة فقط.** الفيوز المحترق عرض. والمحرك المحترق عرض. واستبدال المكوّن دون سؤال *لماذا* تلف يعني أنه سيتلف ثانية، والفشل الثاني غالبًا أغلى من الأول.

فإن ظل حمل زائد يفصل، فالسؤال لماذا التيار مرتفع — محمل يتآكل، أو مروحة مسدودة، أو طور مفقود، أو عائق ميكانيكي — لا كيف تجعل الريليه يكف عن الشكوى.

**أعطال شائعة وبصماتها.**

| العرض | الأسباب المرجحة |
|---|---|
| كونتاكتور يرتعش أو يطن | جهد تحكم منخفض، محول تحكم صغير، حلقة تظليل تالفة، أوساخ بين وجهي القلب |
| محرك يطن ولا يدور | طور مفقود، حمل محشور ميكانيكيًا |
| محرك يبدأ ثم يفصل بعد فترة | حمل زائد حقيقي، تهوية مسدودة، حمل زائد مضبوط منخفضًا، محمل يتلف |
| اللوحة تعمل باردة وتفصل ساخنة | وصلة عالية المقاومة تسخن، تهوية غير كافية، حمل زائد حراري يستجيب للحرارة المحيطة |
| عطل متقطع مع الاهتزاز | طرف مرتخٍ، موصل تالف داخل العزل |
| كل شيء ميت ولم يفصل شيء | فشل تغذية التحكم، فيوز التحكم، جهاز مغلق طبيعيًا مفتوح في سلسلة الإيقاف |
| محرك يدور دون إنتاج | عكس تتابع الأطوار (مضخة/ضاغط)، فشل قارنة، تلف مروحة |

**العطل المتقطع — أصعب الحالات.** الأعطال التي تظهر وتختفي حرارية أو ميكانيكية عادة: وصلة تنفتح حين تتمدد، أو موصل مقطوع داخل عزل ينفصل مع الاهتزاز، أو مكوّن يفشل عند حرارة معينة فقط. والاختبار أثناء غياب العطل لا يثبت شيئًا.

والنهج المثمر إيجاد ما يرتبط بالعطل: هل يظهر حين تسخن المنشأة، أو حين تبدأ ماكينة بعينها، أو بعد المطر، أو في وقت معين من اليوم؟ فالارتباط يشير للسبب بموثوقية أكبر بكثير من الاختبار العشوائي. والتصوير الحراري، حيث يتوفر، يجد الوصلات عالية المقاومة فورًا — فهي تسخن قبل أن تفشل تمامًا.

**سجّل ما وجدته وما فعلته.** اكتبه في جدول اللوحة أو سجل المهمة. فالعطل التالي في تلك اللوحة يرتبط غالبًا بالسابق، والسجل يحوّل مشكلة متكررة غامضة إلى نمط بديهي. وهذا الانضباط هو ما يجعل الفني الخبير كفؤًا — لا الذاكرة بل التوثيق.$c$,
2
FROM public.modules WHERE slug = 'finix-panel-building-faultfinding';

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'bronze', 'Panel & Safety Basics', 'أساسيات اللوحات والسلامة', 80
FROM public.modules WHERE slug = 'finix-panel-building-faultfinding';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$In safe isolation, why do you prove the tester works both before and after testing the circuit?$q$,
    $q$في العزل الآمن، لماذا تثبت أن جهاز الاختبار يعمل قبل اختبار الدائرة وبعده؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-panel-building-faultfinding' AND quizzes.tier = 'bronze' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$A tester that failed silently in between would show a live circuit as dead$o$, $o$جهاز اختبار تعطل صامتًا بينهما سيُظهر دائرة حية كميتة$o$, true, 1),
  ($o$It is a paperwork requirement only$o$, $o$مجرد متطلب أوراق$o$, false, 2),
  ($o$To warm the tester up$o$, $o$لتسخين جهاز الاختبار$o$, false, 3),
  ($o$Testing twice is unnecessary$o$, $o$الاختبار مرتين غير ضروري$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$Why is a schematic that does not match the as-built wiring worse than no schematic?$q$,
    $q$لماذا يكون مخطط لا يطابق التسليك المنفَّذ أسوأ من لا مخطط؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-panel-building-faultfinding' AND quizzes.tier = 'bronze' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$It sends the next technician in the wrong direction with confidence$o$, $o$يرسل الفني التالي في الاتجاه الخاطئ بثقة$o$, true, 1),
  ($o$It uses more paper$o$, $o$يستهلك ورقًا أكثر$o$, false, 2),
  ($o$Schematics are not used in practice$o$, $o$المخططات لا تُستخدم عمليًا$o$, false, 3),
  ($o$There is no difference$o$, $o$لا فرق$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'silver', 'Diagnosing Faults', 'تشخيص الأعطال', 80
FROM public.modules WHERE slug = 'finix-panel-building-faultfinding';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$What is the most efficient first split when diagnosing a motor that will not start?$q$,
    $q$ما أكفأ تقسيم أول عند تشخيص محرك لا يبدأ؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-panel-building-faultfinding' AND quizzes.tier = 'silver' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Check whether the contactor coil is being energised — this separates control faults from power faults$o$, $o$افحص هل يُغذّى ملف الكونتاكتور — يفصل هذا أعطال التحكم عن أعطال القوى$o$, true, 1),
  ($o$Start by testing the motor windings$o$, $o$ابدأ باختبار ملفات المحرك$o$, false, 2),
  ($o$Replace the contactor first$o$, $o$استبدل الكونتاكتور أولًا$o$, false, 3),
  ($o$Test every component in sequence from the incomer$o$, $o$اختبر كل مكوّن بالتتابع من المصدر$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$A panel works when cold but trips once the plant warms up. What should you suspect?$q$,
    $q$لوحة تعمل باردة وتفصل بعد أن تسخن المنشأة. بماذا تشتبه؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-panel-building-faultfinding' AND quizzes.tier = 'silver' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$A high-resistance joint heating up, or inadequate panel ventilation$o$, $o$وصلة عالية المقاومة تسخن، أو تهوية لوحة غير كافية$o$, true, 1),
  ($o$The motor is oversized$o$, $o$المحرك أكبر من اللازم$o$, false, 2),
  ($o$The schematic is out of date$o$, $o$المخطط قديم$o$, false, 3),
  ($o$Nothing — this is normal seasonal behaviour$o$, $o$لا شيء — سلوك موسمي طبيعي$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

INSERT INTO public.quizzes (module_id, tier, title, title_ar, pass_percent)
SELECT id, 'gold', 'Fault-Finding Judgement', 'الحكم في تتبع الأعطال', 80
FROM public.modules WHERE slug = 'finix-panel-building-faultfinding';

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$A fuse has blown for the third time in a month. What is the correct response?$q$,
    $q$احترق فيوز للمرة الثالثة في شهر. ما الاستجابة الصحيحة؟$q$, 1
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-panel-building-faultfinding' AND quizzes.tier = 'gold' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Find the root cause of the repeated overcurrent; the fuse is a symptom, not the fault$o$, $o$اعثر على السبب الجذري للتيار الزائد المتكرر؛ الفيوز عرض لا عطل$o$, true, 1),
  ($o$Fit a higher-rated fuse so it stops blowing$o$, $o$ركّب فيوزًا بتصنيف أعلى ليتوقف عن الاحتراق$o$, false, 2),
  ($o$Replace it and take no further action$o$, $o$استبدله ولا تتخذ إجراءً آخر$o$, false, 3),
  ($o$Bypass the fuse holder$o$, $o$تجاوز حامل الفيوز$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$You have isolated the main incomer of a panel. Why must you still test the specific point you intend to work on?$q$,
    $q$عزلت المصدر الرئيسي للوحة. لماذا يجب مع ذلك اختبار النقطة المحددة التي ستعمل عليها؟$q$, 2
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-panel-building-faultfinding' AND quizzes.tier = 'gold' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$The panel may contain circuits fed from elsewhere, and capacitors may still hold charge$o$, $o$قد تحتوي اللوحة دوائر مغذّاة من مكان آخر، وقد تحتفظ المكثفات بشحنة$o$, true, 1),
  ($o$Testing after isolation is optional if the isolator is locked$o$, $o$الاختبار بعد العزل اختياري إن كان العازل مقفلًا$o$, false, 2),
  ($o$Only to check the tester battery$o$, $o$فقط لفحص بطارية جهاز الاختبار$o$, false, 3),
  ($o$Isolating the incomer always kills everything in the panel$o$, $o$عزل المصدر يقتل دائمًا كل ما في اللوحة$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);

WITH q AS (
  INSERT INTO public.quiz_questions (quiz_id, question, question_ar, position)
  SELECT quizzes.id, $q$An intermittent fault cannot be reproduced during testing. What is the most productive approach?$q$,
    $q$عطل متقطع لا يمكن إعادة إنتاجه أثناء الاختبار. ما أكثر النهج إنتاجية؟$q$, 3
  FROM public.quizzes JOIN public.modules ON modules.id = quizzes.module_id
  WHERE modules.slug = 'finix-panel-building-faultfinding' AND quizzes.tier = 'gold' RETURNING id
)
INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
SELECT q.id, v.opt, v.opt_ar, v.correct, v.pos FROM q, (VALUES
  ($o$Find what correlates with it — heat, vibration, a particular machine starting, time of day — and investigate that$o$, $o$اعثر على ما يرتبط به — الحرارة أو الاهتزاز أو بدء ماكينة بعينها أو وقت اليوم — وحقق في ذلك$o$, true, 1),
  ($o$Replace components one by one until it stops$o$, $o$استبدل المكونات واحدًا تلو الآخر حتى يتوقف$o$, false, 2),
  ($o$Declare the panel faulty and rebuild it$o$, $o$اعتبر اللوحة معطوبة وأعد بناءها$o$, false, 3),
  ($o$Ignore it until it becomes permanent$o$, $o$تجاهله حتى يصبح دائمًا$o$, false, 4)
) AS v(opt, opt_ar, correct, pos);
