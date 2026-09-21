-- Module I03: Motor Protection: Overload, Short Circuit & Thermal
-- ORIGINAL CONTENT written for Finix.

INSERT INTO public.modules (slug, code, track_id, title, title_ar, summary, summary_ar, external_url, position)
VALUES (
  'finix-motor-protection', 'I03', 'finix-industrial-control',
  'Motor Protection: Overload, Short Circuit & Thermal',
  'حماية المحرك: الحمل الزائد والقصر والحراري',
  'What each protection layer actually senses, how overload relays and MCBs work together, and why current-based protection is blind to blocked cooling and hot ambient — plus the case for thermistor protection where temperature, not current, is the real threat.',
  'ما الذي تحسّه كل طبقة حماية في الواقع، وكيف تعمل ريليهات الحمل الزائد وقواطع الدوائر MCB معًا، ولماذا الحماية المعتمدة على التيار عمياء أمام انسداد التبريد والبيئة الحارة — plus الحجة ل protection الحرارية حيث الحرارة وليس التيار هو الخطر الحقيقي.',
  NULL, 3
);
INSERT INTO public.lessons (module_id, title, title_ar, content, content_ar, position)
VALUES
(
  'finix-motor-protection',
  'Overload, Short Circuit and the Two-Threat Model',
  'الحمل الزائد والقصر ونموذج التهديدين',
  'Motor faults fall into two families. The short-circuit family — phase-to-phase, phase-to-ground — produces enormous current almost instantly and must be interrupted mechanically and fast; that is the job of the MCB or MCCB on the supply and the upstream breaker. The overload family — too much load, seized bearings, blocked cooling, too many starts — produces moderately high current for a sustained time and damages the winding gradually; that is the job of the overload relay wired in the control circuit so it can open the contactor coil. A protection scheme that only addresses one of these leaves the motor exposed to the other, which is why the two are never swapped.',
  ' أعطال المحرك تنقسم لعائلتين. عائلة القصر — طور-لطور، طور-لأرض — تنتج تيارًا هائلاً تقريبًا فورًا ويجب أن تُفصل ميكانيكيًا ومجردًا؛ هذه هي مهمة قاطع الدائرة MCB أو MCCB على التغذية والقاطع الأعلى. عائلة الحمل الزائد — حمل زائد، محامل مقفوسة، تبريد مسدود، عدد كبير من البدءيات — تنتج تيارًا مرتفعًا متوسطًا لمدة مستمرة وتتلف اللفة تدريجيًا؛ هذه هي مهمة ريليه الحمل الزائد ممدود في دائرة التحكم ليدخل coil الكونتاكتور. مخطط حماية يعالج عائلة واحدة فقط يعرض المحرك للآخرى، وهذا هو سبب أن لا يُبدل أحدهما بالآخر أبدًا.',
  1
),
(
  'finix-motor-protection',
  'Why Current Alone Is Not Enough — Blocked Cooling, Hot Ambient and Thermistors',
  'لماذا التيار وحده لا يكفي — انسداد التبريد والبيئة الحارة والثرمستورات',
  'Current-based overload protection is fast and reliable for overcurrent, but it sees only what passes through the terminals. A motor whose cooling fan has seized, a panel in direct sun on a hot Egyptian afternoon, a pump running slow on a VFD at low speed with poor axial flow — in all three the winding temperature rises while the current can stay normal or even drop, and the overload relay will not trip until it is too late. That is why wound motors frequently carry embedded thermistors: a resistance element embedded in the stator winding that reads actual winding temperature and feeds it back to a thermal protector. Thermistor protection catches what current cannot — slow thermal rise under normal current — and should be used wherever the motor is enclosed, where ventilation can fail, or where the load is variable. A motor with thermistors that are never connected is a motor with a sensor that nobody reads.',
  ' الحماية من الحمل الزائد المعتمدة على التيار سريعة وموثوقة للتيار الزائد، لكنها ترى فقط ما يمر عبر الأقطاب. محرك مروحة تبريده أقفلت، لوحة تحت الشمس المباشرة في بعد عصري حار مصري، مضخة تعمل ببطء على VFD بسرعة منخفضة مع تدفق محوري ضعيف — في كل ثلثthese ترتفع درجة حرارة اللفة بينما التيار قد يبقى طبيعيًا أو حتى ينخفض، وريليه الحمل الزائد لن يحرج حتى فوات الأوان. وهذا هو سبب أن المحركات اللفية تحمل غالبًا ثرمستورات مدمجة: عنصر مقاومة مدمج في لفة المائع يقرأ درجة حرارة اللفة الفعلية ويعيدها إلى حافظ حراري. حماية الثرمستور تلحق ما لا يلحقه التيار — الارتفاع الحراري البطيء تحت تيار طبيعي — ويجب استخدامها حيث يكون المحرك مغلقًا، حيث يمكن أن يفشل التبريد، أو حيث الحمل متغير. محرك بثرمستورات غير موصولة محرك بsensor لا أحد يقرأه.',
  2
);

-- Quizzes for I03
INSERT INTO public.quizzes (module_id, code, tier, title, title_ar)
VALUES
  ('finix-motor-protection', 'I03', 'bronze', 'Motor Protection — Bronze', 'حماية المحرك — برونزي'),
  ('finix-motor-protection', 'I03', 'silver', 'Motor Protection — Silver', 'حماية المحرك — فضي'),
  ('finix-motor-protection', 'I03', 'gold', 'Motor Protection — Gold', 'حماية المحرك — ذهبي');

INSERT INTO public.quiz_questions (quiz_code, tier, question, question_ar, correct_letter, options_json)
VALUES
  ('I03', 'bronze', 'Which fault family produces enormous current almost instantly and must be interrupted by the supply breaker?',
   'أي عائلة عطل تنتج تيارًا هائلاً تقريبًا فورًا ويجب أن تُفصله قاطعة التغذية؟',
   'B', '{"A":"Overload","B":"Short circuit (phase-to-phase or phase-to-ground)","C":"Blocked cooling","D":"Winding temperature rise"}'),
  ('I03', 'bronze', 'Where is the overload relay normally wired so it can open the contactor coil when the motor is overloaded?',
   'أين عادةً يُمدّد ريليه الحمل الزائد ليمسك coil الكونتاكتور عند حمل المحرك الزائد؟',
   'C', '{"A":"In the motor power circuit only","B":"On the motor casing","C":"In the control circuit, in series with the contactor coil","D":"Across the supply terminals"}'),
  ('I03', 'bronze', 'What is the main purpose of a short-circuit breaker (MCB/MCCB) on a motor feeder?',
   'ما الغرض الرئيسي لقاطع الدائرة MCB/MCCB على تغذية المحرك؟',
   'A', '{"A":"To interrupt the enormous current of a short-circuit fault fast","B":"To detect gradual winding temperature rise","C":"To ramp the start current","D":"To read thermistor temperature"}'),

  ('I03', 'silver', 'A motor has a normal running current but the winding is overheating and eventually fails. Name two conditions under which this can happen and explain why the overload relay did not help.',
   'محرك له تيار تشغيل طبيعي لكن اللفة ترتفع حرارتها وينهار في النهاية. اذكر حالتين يمكن أن يحدث فيهما هذا واشرح لماذا لم يساعد ريليه الحمل الزائد.',
   'A', '{"A":"Blocked cooling (e.g. seized fan) or hot ambient: current can stay normal while temperature rises, so the current-based overload relay never sees the fault — thermistor protection is needed where temperature, not current, is the threat","B":"The overload relay was set too low and tripped too early","C":"Only unbalanced voltage causes this and the relay always catches it","D":"Current-based protection always covers this, so the relay must have been faulty"}'),
  ('I03', 'silver', 'What does a thermistor embedded in a motor winding actually measure?',
   'ما الذي يقيسه الثرمستور المدمج في لفة المحرك فعليًا؟',
   'C', '{"A":"The supply voltage","B":"The motor speed","C":"The actual winding temperature","D":"The overload relay setting"}'),
  ('I03', 'silver', 'Why should thermistor protection be used on an enclosed motor where ventilation can fail?',
   'لماذا يجب استخدام حماية الثرمستور على محرك مغلق حيث يمكن أن يفشل التبريد؟',
   'B', '{"A":"Because thermistors make the motor start faster","B":"Because the current can stay normal while the winding overheats, and thermistor protection catches what current cannot","C":"Because enclosed motors draw less current","D":"Because thermistors replace the overload relay entirely"}'),

  ('I03', 'gold', 'A technician inspects a large pump motor and finds three thermistor wires leaving the terminal box but terminating in a connector that is never plugged into anything. What is the risk, and what is the correct action?',
   'فني يفحص محرك مضخة كبير ويجد ثلاثة أسلاك ثرمستور تخرج من صندوق الأقطاب لكنها تنتهي في موصل لا يُوصَّل أبدًا. ما الخطر، وما الإجراء الصحيح؟',
   'D', '{"A":"No risk — thermistors are decorative","B":"The motor will run faster","C":"The thermistors will overheat the cable","D":"The motor has a temperature sensor that nobody reads; the risk is that winding-overtemperature faults go undetected until failure — connect the thermistors to a thermal protector or monitoring input per the motor data sheet"}'),
  ('I03', 'gold', 'Explain the two-threat model for motor protection and why a scheme that protects only against short circuit is not sufficient.',
   'اشرح نموذج التهديدين لحماية المحرك ولماذا مخططًا يحمي ضد القصر فقط ليس كافيًا.',
   'C', '{"A":"There is only one threat and short circuit covers it all","B":"Overload is the only real threat and short-circuit protection is unnecessary","C":"Short-circuit threats need fast mechanical interruption by the supply breaker; overload threats need sustained-current detection by the overload relay to protect the winding gradually — a scheme covering only one leaves the motor exposed to the other","D":"They are the same threat and one device covers both always"}'),
  ('I03', 'gold', 'A motor on a VFD runs at low speed with low current but the winding temperature rises because axial cooling air is poor. Which protection would catch this first, and why?',
   'محرك على VFD يعمل بسرعة منخفضة وتيار منخفض لكن درجة حرارة اللفة ترتفع لأن هواء التبريد المحوري ضعيف. أي حماية تلحق هذا أولًا، ولماذا؟',
   'B', '{"A":"The current-based overload relay, because it always detects low-speed operation","B":"Thermistor / winding-temperature protection, because the current is low and the overload relay sees nothing while the actual winding temperature is the threat","C":"Only an MCB can detect this","D":"No protection can detect this; the motor will always fail"}');
