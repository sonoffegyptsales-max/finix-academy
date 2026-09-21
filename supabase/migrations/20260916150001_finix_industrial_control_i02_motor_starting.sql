-- Module I02: Motor Starting Methods
-- ORIGINAL CONTENT written for Finix.

INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES (
  'finix-motor-starting-methods', 'I02', 'finix-industrial-control',
  'Motor Starting Methods',
  'طرق بدء تشغيل المحرك',
  'Direct-on-line, star-delta, soft starter and variable frequency drive, with the wiring, timing and protection each method needs and when to choose which.',
  'التشغيل المباشر، البدء نجمة/دلتا، واضع البدء الناعم ومزود التردد المتغير، مع التمديد والتوقيت والحماية لكل طريقة ومتى تختار أي منها.',
  NULL, 2
);
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
VALUES
(
  'finix-motor-starting-methods',
  'Direct-on-Line (DOL): The Simplest Start',
  'التشغيل المباشر DOL: أبسط بدء',
  'A DOL starter connects the motor directly to full supply voltage through a single contactor and an overload relay. It is the cheapest, simplest and most reliable method — but the inrush current is 5–8× the running current, which can trip upstream breakers and dim lights on the same feeder, and the mechanical shock at full speed can shorten bearing life on large pumps. DOL suits small motors, pumps under about 5kW and anywhere the supply is stiff enough that the voltage dip does not matter.',
  ' واضع DOL يربط المحرك مباشرة بجهد الشبكة الكامل عبر كونتاكتور واحد وريليه حمل زائد. وهي أرخص الطرق وأبسطها وأكثرها موثوقية — لكن تيار الدخول 5–8× تيار التشغيل، مما قد يحرج القواطع الأعلى وينخفض الجهد على نفس التغذية، والصدمة الميكانيكية عند السرعة الكاملة قد تختصر عمر المحامل على مضخات كبيرة. DOL يناسب المحركات الصغيرة والمضخات تحت 5kW وأي مكان تكون فيه التغذية صلبة بما يكفي أن انخفاض الجهد لا matters.',
  1
),
(
  'finix-motor-starting-methods',
  'Star-Delta: Reduced-Voltage Start with Three Contactors',
  'البدء نجمة/دلتا: بدء بجهد مخفض بثلاثة كونتاكتورات',
  'Star-delta changes the motor winding connection from star (each phase gets 1/√3 of the line voltage) to delta (full line voltage) after a timed run period. It needs three contactors — main, star and delta — with an interlock so star and delta never close together, a designed dead-time between them, and star connection done at the motor terminal box, not at the panel. Starting current drops to about 1/3 of DOL, but starting torque also drops to about 1/3, so it suits moderate-inertia loads like centrifugal pumps and fans where the motor can accelerate without full torque. The motor must be wound for both star and delta — a delta-only motor will burn in star.',
  'نجمة/دلتا يغير توصيل لفات المحرك من نجمة (كل طور يحصل على 1/√3 جهد الخط) إلى دلتا (جهد الخط الكامل) بعد فترة تشغيل مؤقتة. يحتاج ثلاثة كونتاكتورات — رئيسي، نجمة، دلتا — مع تداخل حتى لا تغلق النجمة والدلتا معًا، وفترة dead-time مصممة بينهما، والتوصيل النجمي يتم عند صندوق طرفي المحرك لا في اللوحة. ينخفض تيار البدء إلى نحو 1/3 DOL، لكن عزم البدء ينخفض لنحو 1/3 أيضًا، لذا يناسب أحمال القصور المتوسطة مثل المضخات الطرفية وال مراوح حيث يستطيع المحرك التسارع بدون عزم كامل. المحرك يجب أن يكون ملفوفًا لنجمة ودلتا — محرك الدلتا فقط يحرق في نجمة.',
  2
),
(
  'finix-motor-starting-methods',
  'Soft Starters and Variable Frequency Drives: Controlled Acceleration',
  'واضع البدء الناعم ومزود التردد المتغير: تسريع متناقل',
  'A soft starter ramps voltage or current over a configurable time so the motor reaches full speed gently — no mechanical shock, no voltage dip, but the motor still runs at line frequency once started and the soft starter is a one-shot at start. A variable frequency drive (VFD) goes further: it synthesises the supply frequency from DC, so it controls speed, torque and acceleration continuously, can reverse without contactors, and protects with overcurrent, overvoltage and stall detection. VFDs are the most powerful starting method but the most expensive and the most to learn — and they introduce harmonic current, shaft voltage and a need for proper grounding that DOL never does. Choose soft start for pumps you only need to start softly; choose VFD when you also need speed control.',
  'واضع البدء الناعم يغير جهد أو تيار تدريجيًا خلال وقت قابل للإعداد فيتحقق المحرك السرعة الكاملة بسلاسة — لا صدمة ميكانيكية، لا انخفاض جهد، لكن المحرك لا يزال يعمل بتردد الشبكة بعد البدء والواضع الناعم واقٍ一次ية فقط عند البدء. مزود التردد المتغير (VFD) يذهب أبعد: يصنع تردد التغذية من تيار مستمر، فيتحكم بالسرعة والعزم والتسارع باستمرار، ويمكن العكس بدون كونتاكتورات، ويحمي بتيار زائد وجهد زائد وكشف توقف. VFDs هي أقوى طريقة بدء لكن أغلى وأكثر ما تحتاج لتعلم — وتضيف تيار توافقيات وجهد المحور وحاجة لتأريض صحيح لا يحتاجه DOL أبدًا. اختر البدء الناعم للمضخات التي تريد بدءها بلطف فقط؛ اختر VFD عندما تحتاج أيضًا تحكم بالسرعة.',
  3
);

-- Quizzes for I02
INSERT INTO public.quizzes (module_id, code, tier, title, title_ar)
VALUES
  ('finix-motor-starting-methods', 'I02', 'bronze', 'Motor Starting Methods — Bronze', 'طرق بدء تشغيل المحرك — برونزي'),
  ('finix-motor-starting-methods', 'I02', 'silver', 'Motor Starting Methods — Silver', 'طرق بدء تشغيل المحرك — فضي'),
  ('finix-motor-starting-methods', 'I02', 'gold', 'Motor Starting Methods — Gold', 'طرق بدء تشغيل المحرك — ذهبي');

INSERT INTO public.quiz_questions (quiz_code, tier, question, question_ar, correct_letter, options_json)
VALUES
  ('I02', 'bronze', 'Which starting method connects the motor directly to full supply voltage through a single contactor?',
   'أي طريقة بدء تربط المحرك مباشرة بجهد الشبكة الكامل عبر كونتاكتور واحد؟',
   'A', '{"A":"Direct-on-line (DOL)","B":"Star-delta","C":"Soft starter","D":"Variable frequency drive"}'),
  ('I02', 'bronze', 'What is the typical inrush current of a DOL start relative to running current?',
   'ما تيار الدخول النموذجي لبدء DOL مقارنة بتيار التشغيل؟',
   'B', '{"A":"1–2× running current","B":"5–8× running current","C":"Equal to running current","D":"10–15× running current"}'),
  ('I02', 'bronze', 'In a star-delta starter, what connection gives each motor phase 1/√3 of the line voltage?',
   'في بدء نجمة/دلتا، أي توصيل يعطي كل طور من المحرك 1/√3 من جهد الخط؟',
   'C', '{"A":"Delta connection","B":"Direct line connection","C":"Star connection","D":"Soft start ramp"}'),

  ('I02', 'silver', 'A star-delta starter must never let the star and delta contactors close at the same time. How is this achieved?',
   'بدء نجمة/دلتا يجب ألا يسمح أبدًا بإغلاق كونتاكتور النجمة والدلتا معًا. كيف يتحقق ذلك؟',
   'B', '{"A":"By using only one contactor","B":"By electrical and/or mechanical interlock between the two contactors, plus a designed dead-time","C":"By wiring them on different supply phases","D":"By a timer that only controls the main contactor"}'),
  ('I02', 'silver', 'Why must a motor intended for star-delta starting be wound for both star and delta?',
   'لماذا يجب أن يكون المحرك المخصص للبدء نجمة/دلتا ملفوفًا لنجمة ودلتا؟',
   'D', '{"A":"Because the soft starter needs it","B":"To reduce the cable length","C":"To let it run slower in star","D":"A delta-only motor connected in star sees too little impedance and burns; the star-delta motor is designed for the voltage change"}'),
  ('I02', 'silver', 'What happens to the motor after the timed star period in a star-delta starter?',
   'ماذا يحدث للمحرك بعد فترة النجمة المؤقتة في بدء نجمة/دلتا؟',
   'A', '{"A":"The windings are reconnected to delta for full-voltage running","B":"The motor coasts to a stop","C":"A soft starter takes over","D":"The overload relay resets"}'),

  ('I02', 'gold', 'A centrifugal pump on a stiff supply starts with DOL but the lights on the same feeder dim badly and a branch breaker trips. What is the most likely cause and the most appropriate first correction?',
   'مضخة طرفية على تغذية صلبة تبدأ بـ DOL لكن الأنوار على نفس التغذية تنخفض كثيرًا وقاطع فرع يحرج. ما السبب الأكثر احتمالاً وأول تصحيح مناسب؟',
   'C', '{"A":"The motor is undersized; replace it","B":"The contactor is chattering; replace it","C":"DOL inrush is drawing too much from the feeder; consider a star-delta or soft starter first, and check the supply impedance before changing the motor","D":"The overload relay setting is too high; lower it"}'),
  ('I02', 'gold', 'When would a variable frequency drive be the right choice over a soft starter, and what is the cost tradeoff?',
   'متى يكون مزود التردد المتغير الخيار الصحيح فوق الواضع الناعم، وما المقايضة الثمنية؟',
   'B', '{"A":"VFD is always cheaper because it needs no contactor","B":"VFD is right when you also need speed control, soft reversal and continuous torque/speed control — but it costs more, needs more expertise, and introduces harmonics and shaft-voltage grounding issues DOL does not","C":"VFD is right only for DC motors","D":"Soft starter is always better; VFDs are obsolete"}'),
  ('I02', 'gold', 'A technician finds a star-delta motor wired in delta only at the terminal box and the star contactor bypassed. What is the danger, and what must be checked before putting it back to star-delta?',
   'فني يجد محرك نجمة/دلتا ممدود بالدلتا فقط في صندوق طرفي والكونتاكتور النجمي متجاوز. ما الخطر، وما الذي يجب فحصه قبل إعادته لنجمة/دلتا؟',
   'A', '{"A":"The motor may have been running above its design voltage in delta; before restoring star-delta, verify the winding rating (which voltages it supports) and the actual supply voltage, and check the motor has not been damaged by overvoltage","B":"Nothing — delta-only is always safe","C":"Only the cable length matters","D":"Only the overload setting matters"}');
