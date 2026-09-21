-- Step 4g: Expand M17 (Scene Design, HVAC Integration & Troubleshooting).
--
-- Note on L2: M14 L4 now covers thermostat wiring and commissioning in depth.
-- To avoid duplication, L2 is reframed toward multi-zone strategy and the
-- control-points layer, and cross-references M14 rather than repeating it.
-- L3 likewise defers the deep diagnostic sequence to I07 and focuses on the
-- smart-home-specific layer model.

UPDATE public.lessons SET content = $c$Scenes are where an installation either becomes part of how a household lives, or becomes a novelty they stop using by the second month. The difference is design discipline, not device count.

**The definitions, kept straight.**

- A **scene** is a saved state — several devices set to specific values, recalled together. "Evening" sets the living room to 40%, the kitchen to 60%, and closes the blinds.
- An **automation** is a rule that fires a scene or an action from a trigger and conditions, with no human involved.

Clients conflate them. Keep them separate in your own head, because a scene the client triggers deliberately and an automation that fires on its own need completely different design care.

**Design from the household's day, not from the device list.**

The failure mode is building scenes because devices exist. The right method is asking what the family actually does, and at which moments several things must change at once.

Almost every home has the same four or five:

- **Leaving** — everything off, security armed, climate setback.
- **Returning** — entrance lit, climate restored to comfort.
- **Evening** — soft lighting, blinds closed.
- **Night** — everything off except a low path light, doors confirmed locked.
- **Wake** — gradual light, climate brought up before anyone gets out of bed.

These map onto real transitions, so they get used. "Movie Mode" gets demonstrated once and then forgotten unless the household genuinely watches films that way.

**Four scenes used daily beat twenty that are not.** Build the small set, let the client live with them for a few weeks, and add more only on request. A crowded scene list is harder to use than a short one, and every unused scene is clutter the client has to read past.

**Rules that keep automations from becoming annoying.**

- **Never take away manual control.** If someone has just turned a light on by hand, an automation that turns it off thirty seconds later is infuriating. Build in an override: a manual change suspends automation for that circuit for a period.
- **Use conditions, not just triggers.** Motion in the hallway should light it *only if* it is dark and *only if* the household is not asleep. A trigger without conditions fires in circumstances you never pictured.
- **Beware the feedback loop.** A light that raises a temperature sensor that triggers cooling that changes humidity that triggers ventilation — loops emerge from individually sensible rules.
- **Fail to a sane state.** Ask what happens if the gateway is down. Anything the household needs at night must still work by hand.
- **Delay before acting on a sensor.** A cloud passing over a light sensor should not toggle the lights. Require the condition to persist.

**Get the timing basis right.** "Sunset" is not a clock time and moves through the year; a fixed 18:00 scene is wrong for half the year. Use solar events with an offset for anything daylight-related.

**Naming, for voice and for the client.**

Name scenes as the household would say them. "Good Night" is better than "Scene 3", and it works when spoken to an assistant. Avoid names that sound like other names, and use the client's own vocabulary rather than yours.

**Hand over scenes, do not just build them.**

Sit with the client, trigger each scene while they watch, and let them adjust one in front of you. A client who has changed a scene once knows it is theirs to change, and will not phone you to move a light ten percent.

**Review after two weeks.** Ask which scenes they use. Delete the ones they do not — a scene nobody uses is a small ongoing cost in attention, and removing it improves the system. This review call also finds the automations that are quietly irritating, which clients often do not report unprompted.$c$,
content_ar = $c$المشاهد حيث يصبح التركيب إما جزءًا من كيف تعيش الأسرة أو طرافة تتوقف عن استخدامها بالشهر الثاني. والفرق انضباط تصميم لا عدد أجهزة.

**التعريفات مضبوطة.**

- **المشهد** حالة محفوظة — عدة أجهزة مضبوطة على قيم محددة تُستدعى معًا. فـ"المساء" يضبط الصالة على ٤٠٪ والمطبخ على ٦٠٪ ويغلق الستائر.
- **الأتمتة** قاعدة تطلق مشهدًا أو فعلًا من مشغّل وشروط بلا إنسان.

والعملاء يخلطون بينهما. أبقهما منفصلين في ذهنك، لأن مشهدًا يطلقه العميل عمدًا وأتمتة تعمل وحدها يحتاجان عناية تصميم مختلفة تمامًا.

**صمّم من يوم الأسرة لا من قائمة الأجهزة.**

نمط الفشل بناء مشاهد لأن الأجهزة موجودة. والطريقة الصحيحة سؤال ماذا تفعل العائلة فعلًا وفي أي لحظات يجب أن تتغير عدة أشياء دفعة.

وكل بيت تقريبًا له الأربعة أو الخمسة نفسها:

- **المغادرة** — كل شيء مطفأ والأمن مسلّح والمناخ متراجع.
- **العودة** — المدخل مضاء والمناخ مستعاد للراحة.
- **المساء** — إضاءة ناعمة وستائر مغلقة.
- **الليل** — كل شيء مطفأ إلا نور ممر خافت والأبواب مؤكد قفلها.
- **الاستيقاظ** — ضوء متدرج والمناخ مرفوع قبل نهوض أحد.

وهذه تنطبق على انتقالات حقيقية فتُستخدم. أما "وضع الفيلم" فيُعرض مرة ثم يُنسى إلا إن كانت الأسرة تشاهد أفلامًا بتلك الطريقة فعلًا.

**أربعة مشاهد تُستخدم يوميًا تغلب عشرين لا تُستخدم.** ابنِ المجموعة الصغيرة ودع العميل يعيش بها أسابيع وأضف فقط عند الطلب. فقائمة المشاهد المزدحمة أصعب استخدامًا من القصيرة، وكل مشهد غير مستخدم فوضى يجب أن يقرأ العميل بجانبها.

**قواعد تمنع الأتمتة من أن تصبح مزعجة.**

- **لا تسلب التحكم اليدوي أبدًا.** فإن أضاء أحدهم مصباحًا بيده للتو، فالأتمتة التي تطفئه بعد ثلاثين ثانية مثيرة للغيظ. ابنِ تجاوزًا: فالتغيير اليدوي يعلّق الأتمتة لتلك الدائرة فترة.
- **استخدم شروطًا لا مشغّلات فقط.** فالحركة في الممر يجب أن تضيئه *فقط إن* كان مظلمًا و*فقط إن* لم تكن الأسرة نائمة. والمشغّل بلا شروط يعمل في ظروف لم تتصورها.
- **احذر حلقة التغذية الراجعة.** فمصباح يرفع حساس حرارة يشغّل تبريدًا يغيّر رطوبة يشغّل تهوية — فالحلقات تنشأ من قواعد معقولة فرديًا.
- **افشل لحالة عاقلة.** اسأل ماذا يحدث إن تعطلت البوابة. فكل ما تحتاجه الأسرة ليلًا يجب أن يعمل يدويًا.
- **أخّر قبل التصرف على حساس.** فسحابة تمر فوق حساس ضوء يجب ألا تبدّل الأنوار. اشترط استمرار الحالة.

**اضبط أساس التوقيت صحيحًا.** فـ"الغروب" ليس وقت ساعة ويتحرك عبر السنة؛ ومشهد ثابت عند السادسة مساءً خطأ نصف السنة. استخدم أحداثًا شمسية بإزاحة لأي شيء متعلق بضوء النهار.

**التسمية للصوت وللعميل.**

سمِّ المشاهد كما تقولها الأسرة. فـ"تصبح على خير" أفضل من "مشهد ٣"، وتعمل حين تُنطق لمساعد. وتجنب أسماء تشبه أسماء أخرى واستخدم مفردات العميل لا مفرداتك.

**سلّم المشاهد لا تبنها فقط.**

اجلس مع العميل وأطلق كل مشهد وهو يشاهد ودعه يعدّل واحدًا أمامك. فالعميل الذي غيّر مشهدًا مرة يعرف أنه له ليغيّره ولن يتصل بك لتحريك مصباح عشرة بالمئة.

**راجع بعد أسبوعين.** اسأل أي مشاهد يستخدمون. واحذف ما لا يستخدمون — فالمشهد الذي لا يستخدمه أحد تكلفة انتباه صغيرة مستمرة وإزالته تحسّن النظام. وهذه المكالمة تجد أيضًا الأتمتة المزعجة بهدوء والتي لا يبلّغ عنها العملاء غالبًا دون سؤال.$c$
WHERE title = 'Scene & Routine Design for Real Households';
