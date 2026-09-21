-- Step 4e-1: M15 L1 — Diagnosing Zigbee mesh network problems.

UPDATE public.lessons SET content = $c$"The device keeps dropping off" is the most common support call in smart home work, and the cause is almost never the device. This lesson is the diagnostic order that finds the real fault.

**How the mesh is actually built.**

Zigbee devices fall into three roles:

- **Coordinator** — one per network. Forms it, holds the keys, routes traffic.
- **Routers** — mains-powered devices (switches, sockets, relays). They relay traffic for others and are permanently awake. **These are what make the mesh a mesh.**
- **End devices** — battery-powered sensors, buttons, valves. They sleep most of the time and never relay anything for anyone.

The consequence installers miss: a property full of battery sensors and one gateway has **no mesh at all**. It has a star network at the limit of the coordinator's range, and it will be unreliable no matter how many sensors are added. Only mains-powered devices extend coverage.

**The diagnostic order — follow it, do not jump ahead.**

1. **Is it one device or several?** One device failing is a device, placement or battery problem. Several failing in the same area is a coverage problem. Everything failing at once is the coordinator, its power, or interference.
2. **Check the link quality figure.** Zigbee reports LQI or RSSI per device. A device sitting at the bottom of the range is telling you its problem before you start guessing.
3. **Map the routing.** Zigbee2MQTT and ZHA both draw a network map showing which device routes through which. This is the single most useful diagnostic artefact available, and it frequently reveals that a device is routing through something on the far side of the house.
4. **Check what changed.** A mesh that worked for a year and then degraded usually had something introduced: a new Wi-Fi access point, a new appliance, a metal shelf, a mirror, or a router device that was unplugged.

**Wi-Fi interference — the most common root cause.**

Zigbee and 2.4 GHz Wi-Fi occupy the same band. Zigbee channels 15, 20 and 25 fall in the gaps between Wi-Fi channels 1, 6 and 11, and those three Zigbee channels are the ones to use.

Two practical rules that resolve a large share of complaints:

- Never site the coordinator next to the Wi-Fi router. They are two transmitters in one band sitting a few centimetres apart.
- Never plug the coordinator directly into a machine with USB 3.0 ports. USB 3.0 emits broadband noise centred in the 2.4 GHz band. Use an extension cable and get half a metre of separation.

**Physical obstructions, ranked by severity.**

Metal is the worst — a device inside a metal enclosure, behind a fridge, or in a metal-clad consumer unit is effectively shielded. Then water: fish tanks and water tanks absorb 2.4 GHz strongly, and so do people, which is why a mesh can behave differently in an occupied room. Then mirrors, which are metal-backed glass. Then concrete and brick, which attenuate steadily with thickness.

**Repairing coverage properly.**

The fix for a weak area is almost always to add a mains-powered router device in the gap between the coordinator and the failing device — a smart socket in a hallway is the cheapest and most effective repair available.

After adding it, **devices do not re-route instantly.** Zigbee re-routes on failure, not on opportunity. Repair the network, or power-cycle the affected end devices, to force them to find the new path.

**The battery trap.**

A battery at the end of its life produces intermittent, weather-sensitive behaviour — the device works when warm, drops out when cold, and reappears after you arrive to investigate. Before any deep network diagnosis on a single battery device, replace the battery. It costs nothing and it resolves a significant share of these calls.

**What to tell the client.**

Mesh problems are usually coverage problems, and coverage is fixed by adding powered devices rather than by replacing the failing one. Clients frequently want to return a "faulty" sensor that is working perfectly and simply cannot be heard from where it sits.$c$,
content_ar = $c$"الجهاز يفصل باستمرار" أشيع اتصال دعم في عمل المنازل الذكية، والسبب لا يكون الجهاز أبدًا تقريبًا. وهذا الدرس ترتيب التشخيص الذي يجد العطل الحقيقي.

**كيف تُبنى الشبكة فعلًا.**

أجهزة Zigbee تقع في ثلاثة أدوار:

- **المنسق** — واحد لكل شبكة. يكوّنها ويحمل المفاتيح ويوجّه المرور.
- **الموجّهات** — الأجهزة المغذاة من الشبكة (مفاتيح ومقابس وريليهات). ترحّل المرور للآخرين وتبقى مستيقظة دائمًا. **وهذه ما يجعل الشبكة شبكية.**
- **الأجهزة الطرفية** — حساسات وأزرار وصمامات تعمل ببطارية. تنام أغلب الوقت ولا ترحّل شيئًا لأحد أبدًا.

والنتيجة التي يغفلها الفنيون: عقار مليء بحساسات البطاريات وبوابة واحدة **بلا شبكة شبكية إطلاقًا**. بل شبكة نجمية عند حد مدى المنسق، وستكون غير موثوقة مهما أُضيف من حساسات. فالأجهزة المغذاة من الشبكة وحدها تمدد التغطية.

**ترتيب التشخيص — اتبعه ولا تقفز.**

1. **جهاز واحد أم عدة؟** فشل جهاز واحد مشكلة جهاز أو موضع أو بطارية. وفشل عدة في المنطقة نفسها مشكلة تغطية. وفشل الكل دفعة مشكلة المنسق أو تغذيته أو التداخل.
2. **افحص رقم جودة الوصلة.** يبلّغ Zigbee عن LQI أو RSSI لكل جهاز. والجهاز الجالس في قاع المدى يخبرك بمشكلته قبل أن تبدأ التخمين.
3. **ارسم التوجيه.** يرسم Zigbee2MQTT وZHA كلاهما خريطة شبكة تبيّن أي جهاز يوجّه عبر أي. وهذه أنفع قطعة تشخيصية متاحة، وتكشف كثيرًا أن جهازًا يوجّه عبر شيء في الجهة المقابلة من البيت.
4. **افحص ما تغيّر.** فالشبكة التي عملت سنة ثم تدهورت أُدخل إليها شيء عادة: نقطة وصول Wi-Fi جديدة أو جهاز جديد أو رف معدني أو مرآة أو موجّه فُصل.

**تداخل Wi-Fi — أشيع سبب جذري.**

يحتل Zigbee وWi-Fi عند ٢٫٤ جيجاهرتز النطاق نفسه. وقنوات Zigbee ١٥ و٢٠ و٢٥ تقع في الفجوات بين قنوات Wi-Fi ١ و٦ و١١، وتلك القنوات الثلاث هي التي تُستخدم.

وقاعدتان عمليتان تحلان حصة كبيرة من الشكاوى:

- لا تضع المنسق بجوار راوتر Wi-Fi أبدًا. فهما مرسلان في نطاق واحد يجلسان على بعد سنتيمترات.
- لا توصل المنسق مباشرة بجهاز فيه منافذ USB 3.0. فـ USB 3.0 يبث ضجيجًا عريض النطاق متمركزًا في ٢٫٤ جيجاهرتز. استخدم كابل تمديد واحصل على نصف متر فصل.

**العوائق الفيزيائية مرتبة بالشدة.**

المعدن الأسوأ — فالجهاز داخل حاوية معدنية أو خلف ثلاجة أو في لوحة معدنية محجوب فعليًا. ثم الماء: فأحواض السمك وخزانات المياه تمتص ٢٫٤ جيجاهرتز بقوة، وكذلك البشر، ولهذا تتصرف الشبكة اختلافًا في غرفة مشغولة. ثم المرايا وهي زجاج مبطن بمعدن. ثم الخرسانة والطوب اللذان يُوهنان باطراد مع السماكة.

**إصلاح التغطية صحيحًا.**

إصلاح المنطقة الضعيفة دائمًا تقريبًا إضافة جهاز موجّه مغذى من الشبكة في الفجوة بين المنسق والجهاز الفاشل — فمقبس ذكي في ممر أرخص وأنجع إصلاح متاح.

وبعد إضافته، **لا تعيد الأجهزة التوجيه فورًا.** فـ Zigbee يعيد التوجيه عند الفشل لا عند الفرصة. أصلح الشبكة أو أعد تدوير طاقة الأجهزة الطرفية المتأثرة لإجبارها على إيجاد المسار الجديد.

**فخ البطارية.**

البطارية في نهاية عمرها تنتج سلوكًا متقطعًا حساسًا للطقس — فيعمل الجهاز حين يدفأ ويفصل حين يبرد ويعود بعد وصولك للفحص. وقبل أي تشخيص شبكي عميق لجهاز بطارية واحد، استبدل البطارية. لا تكلف شيئًا وتحل حصة معتبرة من هذه الاتصالات.

**ما تخبر به العميل.**

مشاكل الشبكة مشاكل تغطية عادة، والتغطية تُصلح بإضافة أجهزة مغذاة لا باستبدال الفاشل. فالعملاء يريدون كثيرًا إرجاع حساس "معطل" يعمل تمامًا ولا يمكن سماعه فقط من حيث يجلس.$c$
WHERE title = 'Diagnosing Zigbee Mesh Network Problems';
