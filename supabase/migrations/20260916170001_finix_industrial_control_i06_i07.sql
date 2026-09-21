-- Modules I06 and I07
-- ORIGINAL CONTENT written for Finix.

-- ===== I06: Voltage & Phase Protection =====
INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES (
  'finix-voltage-phase-protection', 'I06', 'finix-industrial-control',
  'Voltage & Phase Protection',
  'حماية الجهد والطور',
  'Under-voltage, over-voltage and phase-loss protection — what each does to a motor, how a phase-protection relay detects missing or shifted phases, and why a dead phase at the motor is not the same as a dead phase at the supply.',
  'حماية انخفاض الجهد ورفعه وفقدان الطور — ما الذي يفعله كل منها للمحرك، وكيفية ريله حماية الطور يكتشف الطور المفقود أو المنزاح، ولماذا طور ميت عند المحرك لا يequal طور ميت عند التغذية.',
  NULL, 6
);
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
VALUES
(
  'finix-voltage-phase-protection',
  'Under-Voltage, Over-Voltage and Phase Loss: Three Different Threats',
  'انخفاض الجهد وارتفاعه وفقدان الطور: ثلاث تهديدات مختلفة',
  'Three supply faults threaten a motor and each does it in a different way. Under-voltage makes the motor draw more current for the same torque — its magnetising current rises, it warms, and at low enough voltage it cannot even start; repeated under-voltage starts are a common cause of motor burnout on weak Egyptian rural feeds. Over-voltage stresses the winding insulation and drives magnetising current high at full speed, sometimes tripping the overload even with no load. Phase loss — one of the three supply conductors opens or drops out — is the most deceptive: a delta-connected motor can continue running on the remaining two phases but the current in those two phases and in the open-phase winding goes up dramatically, and the motor burns from inside while the supply voltage still reads near-normal on the healthy phases. None of these is a current-overload fault in the usual sense, so a motor protected only by an overload relay is not protected against any of them — phase and voltage monitoring must be added separately.',
  ' ثلاث أخطاء في التغذية تهدد المحرك وكل منها يفعله بطريق مختلف. انخفاض الجهد يجعل المحرك يسحب تيارًا أكبر لنفس العزم — تزيد تيار التغذية المغذية، يسخن، وعند جهد منخفض بما يكفي لا يستطيع حتى البدء؛ بدءيات انخفاض الجهد المتكررة سبب شائع لحرق المحرك على تغذيات ريفية مصرية ضعيفة. ارتفاع الجهد مجهد لعتادة اللفة ويجعل تيار المغذية مرتفعًا عند السرعة الكاملة، أحيانًا يحرج الحمل الزائد حتى بلا حمل. فقدان الطور — أحد موصلات التغذية الثلاث يفتح أو ينزاح — هو الأكثر خداعًا: محرك دلتا يستطيع الاستمرار بالطورين الباقيين لكن التيار في هذين الطورين وفي اللفة المفتوحة يزداد بشكل ملحوظ، والمحرك يحترق من الداخل بينما جهد التغذية لا يزال يقرأ قريبًا من الطبيعي auf الطورات السليمة. لا واحد من هذه هو عطل حمل زائد بالمعنى المعتاد، لذا محرك محمي فقط بريليه حمل زائد ليس محميًا ضد أي منها — مراقبة الطور والجهد يجب أن تُضاف بشكل منفصل.',
  1
);

-- ===== I07: Panel Building & Fault-Finding =====
INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES (
  'finix-panel-building-fault-finding', 'I07', 'finix-industrial-control',
  'Panel Building and Fault-Finding',
  'بناء اللوحات واستكشاف الأعطال',
  'How to build a control panel soundly — sectioning power and control, routing cables, labelling and earthing — and a practical fault-finding method: how to read a tripped device as a clue not an endpoint, how to separate what the symptom tells you from what the protective device tells you, and how to find the real fault instead of just resetting.',
  'كيفية بناء لوحة تحكم بثبات — تجزئة الطاقة والتحكم، تمديد الكابلات، الترميز والتأريض — وطريقة استكشاف أعطال عملية: كيفية قراءة جهاز محرّج كدليل لا نقطة نهاية، وكيفية فصل ما تخبرك به الأعراض عما يخبرك به الجهاز الحمائي، وكيفية إيجاد العطل الحقيقي بدل إعادة التعيين فقط.',
  NULL, 7
);
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
VALUES
(
  'finix-panel-building-fault-finding',
  'Building a Control Panel Soundly: Power, Control, Cable Routing and Grounding',
  'بناء لوحة تحكم بثبات: الطاقة والتحكم وتمديد الكابلات والتأريض',
  'A reliable panel is built around a few non-negotiable habits. Power and control circuits are kept on separate buses — the contactor coils on a protected 24V or 110V control supply, the motor feeders on the mains bus with their own breakers — because a short in the control side must never take out the motor supply and a motor fault must never put mains voltage onto the 24V side. Feeders are sized for the motor FLA plus a starting allowance and routed with strain relief so a tug on a cable does not crack a terminal. Every wire is labelled at both ends; every device is identifiable without tracing; the earthing is a real low-impedance earth, not a random screw in the enclosure. The panel is built for the technician who has to service it at 2 a.m. — clarity is a safety feature, not a cosmetic one.',
  ' لوحة موثوقة تُبنى حول عادات غير قابلة للتفاوض. دوائر الطاقة والتحكم تبقى على ركاب منفصلة — coils الكونتاكتورات على تغذية تحكم محمية 24V أو 110V، والترايات على ركاب الشبكة بقواطعها الخاصة — لأن قصرًا في جانب التحكم يجب ألا يقطع تغذية المحرك وأولي يجب ألا يضع جهد الشبكة على جانب الـ 24V. الترايا تُحدَّد بحسب تيار التشغيل المحرك FLA زائد هامش بدء وتُ routed مع حواجز شد حتى لا يؤثر سحب الكابل على القطب. كل سلك مُعلَّم من الطرفين؛ كل جهاز يمكن تحديده دون تتبع؛ التأريض أرض حقيقية ذات ممانعة منخفضة لا مش screw عشوائي في العلبة. اللوحة تُبنى للفني الذي يجب عليه صيانتها الساعة الثانية صباحًا — الوضوح ميزة سلامة ليس ميزة جمالية.',
  1
),
(
  'finix-panel-building-fault-finding',
  'Fault-Finding as a Method: What the Symptom Says, What the Trip Says, and What Neither Tells You',
  'استكشاف الأعطال كطريقة: ما الذي تقوله الأعراض، وما الذي يقوله الحرج، وما الذي لا يخبرك به أي منهما',
  'Fault-finding is method, not guesswork. When a motor does not start or trips, you first separate two sources of information: what the machine is doing (not starting, humming, tripping on overload, tripping on short circuit, running hot) and what the protective device did (which relay tripped, what its setting is, whether it was instantaneous or timed). Those two together narrow the field: a humming motor that trips the overload in three seconds is a different fault from a motor that starts, runs for an hour and then trips on overload; a short-circuit trip is not an overload. Then you generate a short list of likely causes ranked by how well each one fits both pieces of information, and you test in order of safety and ease: check the supply and the breaker, check the contactor and its coil, check the overload, check the motor. The real fault is found by eliminating what can be eliminated, not by replacing the first thing that looks wrong. Resetting and re-energising without understanding which of these the trip was is how a second fault becomes a dead motor.',
  ' استكشاف الأعطال طريقة لا تخمين. عندما المحرك لا يبدأ أو يحرج، تفصل أولًا مصدرين للمعلومة: ما الذي يفعله الجهاز (لا يبدأ، يهمهم، يحرج على حمل زائد، يحرج على قصر، يعمل ساخنًا) وما الذي فعله الجهاز الحمائي (أي ريليه حرج، ما إعداداته، هل كان فوريًا أم مؤقتًا). هذان معًا يضيقان الحقل: محرك يهمهم ويشهد الحمل الزائد خلال ثلاث ثوانٍ عطل مختلف عن محرك يبدأ ويعمل ساعة ثم يحرج على حمل زائد؛ حرج قصر ليس حمل زائد. ثم تضع قائمة قصيرة من الأسباب المحتملة مصنفة حسب مدى ملاءمة كل منها لكلا قطفي المعلومة، وتبحث بالترتيب الآمن والسهل: افحص التغذية والقاطع، افحص الكونتاكتور وcoil، افحص الحمل الزائد، افحص المحرك. العطل الحقيقي يُوجد بحذف ما يمكن حذفه، لا باستبدال أول شيء يبدو خاطئًا. إعادة التعيين وإعادة التغذية دون فهم أيًا من هذه كان الحرج هو كيف يصبح عطل ثاني محركًا ميتًا.',
  2
);

-- Quizzes for I06
INSERT INTO public.quizzes (module_id, code, tier, title, title_ar)
VALUES
  ('finix-voltage-phase-protection', 'I06', 'bronze', 'Voltage & Phase Protection — Bronze', 'حماية الجهد والطور — برونزي'),
  ('finix-voltage-phase-protection', 'I06', 'silver', 'Voltage & Phase Protection — Silver', 'حماية الجهد والطور — فضي'),
  ('finix-voltage-phase-protection', 'I06', 'gold', 'Voltage & Phase Protection — Gold', 'حماية الجهد والطور — ذهبي');

INSERT INTO public.quiz_questions (quiz_code, tier, question, question_ar, correct_letter, options_json)
VALUES
  ('I06', 'bronze', 'Which supply fault makes a motor draw more current for the same torque and can prevent it from starting at low voltage?',
   'أي خطأ في التغذية يجعل المحرك يسحب تيارًا أكبر لنفس العزم ويستطيع منعه من البدء عند جهد منخفض؟',
   'B', '{"A":"Phase loss","B":"Under-voltage","C":"Over-voltage","D":"Thermistor open"}'),
  ('I06', 'bronze', 'What is the most deceptive supply fault for a delta-connected motor, because it can keep running while the motor burns internally?',
   'ما أكثر خطأ تغذية خداعًا لمحرك دلتا، لأنه قد يستمر بالعمل بينما يحترق المحرك من الداخل؟',
   'C', '{"A":"Over-voltage","B":"High frequency","C":"Phase loss","D":"Undervoltage"}'),
  ('I06', 'bronze', 'A motor protected only by an overload relay is not protected against which class of fault?',
   'محرك محمي فقط بريليه حمل زائد ليس محميًا ضد أي فئة من الع faults؟',
   'D', '{"A":"Overload","B":"Locked rotor current during start","C":"High current on a stalled load","D":"Under-voltage, over-voltage and phase loss"}'),

  ('I06', 'silver', 'Why does under-voltage cause a motor to draw more current for the same torque?',
   'لماذا يسبب انخفاض الجهد أن يسحب المحرك تيارًا أكبر لنفس العزم؟',
   'A', '{"A":"Motor magnetising current rises as voltage falls, so for the same output the total current goes up and the motor can overheat and fail to start","B":"Under-voltage reduces the motor speed so the load is easier","C":"Under-voltage makes the overload relay trip first","D":"Under-voltage only affects DC motors"}'),
  ('I06', 'silver', 'A motor connected in delta loses one supply phase at the motor terminals but continues running. What actually happens inside the motor?',
   'محرك ممدود بالدلتا يفقد أحد طورات التغذية عند أقطاب المحرك لكنه يستمر بالعمل. ما الذي يحدث فعليًا داخل المحرك؟',
   'B', '{"A":"Nothing — it runs normally on two phases","B":"The two remaining phases and the open-phase winding carry excessively high current, and the motor burns from inside while the healthy phases still read near-normal voltage","C":"The motor immediately stops and the overload trips","D":"The motor switches itself to star automatically"}'),
  ('I06', 'silver', 'Why might a motor trip on overload even with no mechanical load when the supply voltage is too high?',
   'لماذا قد يحرج محرك على حمل زائد حتى بلا حمل ميكانيكي عندما يكون جهد التغذية مرتفعًا جدًا؟',
   'C', '{"A":"High voltage reduces the motor current to zero","B":"Over-voltage cannot affect an unloaded motor","C":"Over-voltage drives magnetising current high even at no load, which can be enough to trip an overload relay","D":"Over-voltage only damages insulation and never trips anything"}'),

  ('I06', 'gold', 'You find a motor that trips on overload in a few seconds at start, then runs fine once started — but restarting after a short stop trips it again. Which supply fault category fits best, and what would you check first?',
   'تجد محرك يحرج على حمل زائد خلال ثوانٍ قليلة عند البدء ثم يعمل جيدًا بعد البدء — لكن إعادة البدء بعد توقف قصير تعيد حرجه. أي فئة خطأ تغذية تناسب أفضل، وماذا تفحص أولًا؟',
   'A', '{"A":"This pattern fits under-voltage or a weak supply more than a pure overload: at start the motor draws high current and the weak supply cannot support it — check supply voltage at the motor under load, the upstream impedance, and the breaker and connection integrity before blaming the overload setting","B":"It is always a motor winding fault and the motor must be replaced","C":"Only a fault in the overload relay can cause this; replace it","D":"This only happens with VFDs"}'),
  ('I06', 'gold', 'Explain why phase-loss protection must be added separately from overload protection, using a delta motor with one lost phase as the example.',
   'اشرح لماذا يجب إضافة حماية فقدان الطور بشكل منفصل عن حماية الحمل الزائد، مستخدمًا محرك دلتا مع فقدان طور واحد كمثال.',
   'B', '{"A":"Phase loss is a type of overload and the overload relay always catches it","B":"A lost phase on a delta motor can leave supply voltage appearing near-normal on the remaining phases while the open-phase winding and the two loaded phases carry destructive current; an overload relay looking only at total current may not see the fault in time, so separate phase-loss monitoring is needed","C":"Phase-loss protection is only needed on single-phase motors","D":"Overload protection covers phase loss by definition"}'),
  ('I06', 'gold', 'A motor feeding a pump burns out on a rural village supply that is known to dip under load. Which two protection gaps most likely contributed, and how would you design the protection for the replacement?',
   'محرك يغذي مضخة يحترق على تغذية قرية ريفية معروفة بأنها تنخفض تحت الحمل. ما فجأت الحماية الاثنتان اللتان ساهمتا على الأرجح، وكيف تصمم حماية البديل؟',
   'C', '{"A":"Only the overload setting was wrong; make it lower","B":"No gap — the motor was just old","C":"Under-voltage tolerance was not addressed (no undervoltage monitoring or start interlock) and the motor was probably DOL-started on a weak feed that could not take the inrush — for the replacement add undervoltage monitoring with a start/stop interlock, consider a soft starter or star-delta to reduce inrush, and verify the supply can support the chosen method under worst-case dip","D":"Only a thermistor would have saved it"}');

-- Quizzes for I07
INSERT INTO public.quizzes (module_id, code, tier, title, title_ar)
VALUES
  ('finix-panel-building-fault-finding', 'I07', 'bronze', 'Panel Building & Fault-Finding — Bronze', 'بناء اللوحات واستكشاف الأعطال — برونزي'),
  ('finix-panel-building-fault-finding', 'I07', 'silver', 'Panel Building & Fault-Finding — Silver', 'بناء اللوحات واستكشاف الأعطال — فضي'),
  ('finix-panel-building-fault-finding', 'I07', 'gold', 'Panel Building & Fault-Finding — Gold', 'بناء اللوحات واستكشاف الأعطال — ذهبي');

INSERT INTO public.quiz_questions (quiz_code, tier, question, question_ar, correct_letter, options_json)
VALUES
  ('I07', 'bronze', 'Why are power and control circuits kept on separate buses in a control panel?',
   'لماذا تحافظ دوائر الطاقة والتحكم على ركاب منفصلة في لوحة تحكم؟',
   'B', '{"A":"To use less cable","B":"So a control-side fault cannot take out the motor supply and a motor fault cannot put mains voltage on the control side","C":"Because contactors need two separate supplies","D":"To make the panel look neater"}'),
  ('I07', 'bronze', 'What is the first thing to check when a motor does not start?',
   'ما أول شيء تفحصه عندما لا يبدأ المحرك؟',
   'A', '{"A":"The supply, the breaker and the contactor","B":"The motor winding colour","C":"The panel paint","D":"The overload setting label"}'),
  ('I07', 'bronze', 'Which of these is a safety/clearness practice when building a panel?',
   'أي هذه عبارة عن ممارسة سلامة/وضوح عند بناء لوحة؟',
   'D', '{"A":"Leaving unlabelled wires to save time","B":"Routing the motor feeder without strain relief","C":"Earthing to a random screw","D":"Labelling every wire at both ends and keeping devices identifiable"}'),

  ('I07', 'silver', 'A motor hums but does not start and the overload relay trips after a few seconds. Name two likely causes from the contactor and motor side and the method to separate them.',
   'محرك يهمهم لكن لا يبدأ وريليه الحمل الزائد يحرج بعد ثوانٍ قليلة. اذكر سببين محتملين من جانب الكونتاكتور والمحرك وطريقة فصلهما.',
   'A', '{"A":"Likely causes include a contactor not making full connection (one pole not seated, worn contacts) or a motor with a bad winding/phasing; separate them by checking contactor voltage on all poles and the motor terminals, visually and with a meter, before concluding either","B":"Humming always means the overload is faulty","C":"Humming means the motor must be replaced without inspection","D":"Only a VFD causes humming"}'),
  ('I07', 'silver', 'Why is it dangerous to simply reset a tripped device and re-energise without understanding which fault category the trip belonged to?',
   'لماذا من الخطر إعادة تعيين جهاز متحرج وتغذيته ثانية دون فهم أي فئة عطل كان الحرج منها؟',
   'C', '{"A":"It is not dangerous if you reset quickly","B":"Resetting always fixes the fault","C":"You risk a second, possibly worse fault becoming a dead motor because the first reset did not address the real cause — a short-circuit trip re-energised is an arc, a repeated overload trip re-energised is a burnt winding","D":"Only the overload setting changes"}'),
  ('I07', 'silver', 'What does a short-circuit trip tell you that an overload trip does not?',
   'ما الذي يخبرك به حرج قصر ولا يخبرك به حرج حمل زائد؟',
   'B', '{"A":"Nothing — they mean the same thing","B":"A short-circuit trip indicates an extremely high current fault (phase-to-phase or phase-to-ground) that must have happened fast, which is a different root cause from a sustained overload","C":"A short-circuit trip is always a false trip","D":"An overload trip is always the more serious one"}'),

  ('I07', 'gold', 'You are called to a panel where a pump motor trips on overload every few hours then runs again after a reset. Walk through the fault-finding method from symptom and trip to a short list of causes.',
   'ندرج إلى لوحة حيث محرك مضخة يحرج على حمل زائد كل بضع ساعات ثم يعمل مرة أخرى بعد إعادة تعيين. حلّط طريقة استكشاف الأعطال من الأعراض والحرج إلى قائمة قصيرة من الأسباب.',
   'A', '{"A":"Symptom: motor runs then trips after a while and resets; trip: timed overload (not instantaneous short circuit). Shortlist ranked by fit: (1) mechanical overload or seized/binding load on the pump, (2) undersized motor for the actual duty, (3) failing bearing increasing load, (4) overload relay set incorrectly or drifting, (5) supply voltage low enough to raise current. Test in safety/ ease order: inspect the pump and mechanical load, check the motor current trend against FLA, check the overload setting and calibration, check supply voltage under load","B":"Replace the overload relay first and call it done","C":"It is always the motor and the motor must be replaced","D":"Only the breaker matters"}'),
  ('I07', 'gold', 'A panel you inherit has motor feeders and contactor coils sharing one unprotected bus, no labels on the control wires, and an earth bonded to a paint-scraped screw. List the defects against the building rules and the first fix order.',
   'لوحة توارثها فيها الترايات و coils الكونتاكتورات تشارك ركابًا واحدًا غير محمي، لا توجد تسميات على أسلاك التحكم، وأرض ممدودة إلى مشص مصدأ بالمسح. اذكر العيوب مقابل قواعد البناء وترتيب الإصلاح الأول.',
   'B', '{"A":"No defects — this is a normal panel","B":"Defects: (1) no separation of power and control — a control fault can take the motor out and a motor fault can put mains on the control side, (2) no control wire labelling — unsafe and unreadable, (3) inadequate earth — high impedance, not a real low-impedance earth. Fix order: first establish a proper separate control supply and isolate the contactor coils onto it, then label every control wire at both ends, then re-earth the enclosure to a proper low-impedance earth; re-check feeder sizing and strain relief at the same time","C":"Only the labelling matters","D":"Only the earth matters; the bus sharing is fine"}'),
  ('I07', 'gold', 'A motor trip shows the overload relay tripped instantaneously, faster than its time setting should allow. What does this tell you, and what would you suspect first?',
   'حرج محطّم يظهر ريليه الحمل الزائد قد حرج بشكل فوري أسرع مما تسمح به إعداداته الزمنية. ماذا يخبرك هذا، وماذا تشك أولًا؟',
   'C', '{"A":"The overload setting is correct and the motor is fine","B":"It is always a motor winding fault","C":"An instantaneous trip from a relay whose setting should give a delay suggests the current rose far faster than a normal overload — suspect a short-circuit or ground fault, a sustained locked rotor, or a mis-set/duplicate instantaneous element on the same device, and investigate the actual current waveform and the device\'s instantaneous setting before accepting it as an overload","D":"Only the contactor coil matters"}');
