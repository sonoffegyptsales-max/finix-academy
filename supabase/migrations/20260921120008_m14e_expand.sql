-- Step 4d-5: M14 L5 — Flashing a Zigbee USB coordinator dongle.

UPDATE public.lessons SET content = $c$Flashing a coordinator dongle is the most technical procedure in this track, and the one that separates an installer who can deploy local control from one who depends on vendor gateways.

**What a coordinator is.**

Every Zigbee network has exactly one coordinator. It forms the network, holds the security keys, assigns addresses and maintains the routing tables. A USB coordinator dongle turns any computer — a small server, a mini PC, a single-board computer — into that coordinator.

This is what allows Home Assistant or Zigbee2MQTT to run a Zigbee network with no manufacturer gateway and no cloud involvement at all.

**Why you would reflash a dongle.**

- It shipped with **router** firmware and you need **coordinator** firmware (or the reverse — a spare dongle flashed as a router makes an excellent mesh repeater).
- The stock firmware is old and lacks fixes for network stability or device compatibility.
- You are switching stacks and the new software expects different firmware.
- The device limit on the stock firmware is too low for the installation.

**Before you start — the three things to get right.**

1. **Identify the exact chip.** CC2652P, CC2652RB, EFR32MG21 and others each take different firmware. Flashing firmware built for a different chip bricks the device. The chip is usually printed on the board or stated in the product listing.
2. **Match firmware to the stack.** Zigbee2MQTT and ZHA have different firmware expectations. Download from the maintainer's official release page, not from a forum link.
3. **Back up the existing network key** if this dongle already runs a live network. Reflashing resets the network, and every paired device will need re-pairing. On a property with forty devices that is most of a working day.

**The procedure.**

1. **Enter bootloader mode.** Most dongles use a button combination — typically hold the BOOT button while inserting the dongle or while pressing RESET. The exact sequence is model-specific; check the manufacturer's documentation rather than guessing.
2. **Confirm the port.** The dongle appears as a serial port. Identify the correct one — flashing the wrong port fails harmlessly, but wastes time on a confusing error.
3. **Flash with the correct tool.** Texas Instruments chips generally use `cc2538-bsl`; Silicon Labs chips use their own tooling. Follow the firmware maintainer's stated procedure.
4. **Do not interrupt.** A flash interrupted partway leaves the device in an indeterminate state. Use a machine that will not sleep, and do not unplug anything until the tool reports completion.
5. **Verify.** Re-insert, confirm the firmware version reported matches what you flashed, and confirm the software recognises it as a coordinator.

**Antenna and placement — where most performance complaints originate.**

A coordinator plugged directly into the back of a server is sitting inside a metal box surrounded by electrical noise, and its range will be poor.

**Always use a USB extension cable.** Get the dongle at least half a metre away from the host machine, away from the metal chassis, away from other USB 3.0 ports, and out in open air. USB 3.0 in particular emits interference squarely in the 2.4 GHz band, and a coordinator adjacent to a USB 3.0 port is a classic and entirely avoidable cause of a flaky mesh.

This single cheap cable resolves more Zigbee reliability problems than any firmware change.

**Channel planning.** Set the Zigbee channel deliberately so it does not collide with the property's Wi-Fi. Zigbee channels 15, 20 and 25 sit in the gaps between the common Wi-Fi channels 1, 6 and 11. Choose before pairing devices — changing channel afterwards forces re-pairing.

**The honest risk statement.**

Flashing can brick a device. It is recoverable in most cases, but not always, and it is not a procedure to perform for the first time on a client's site under time pressure.

Buy a spare dongle, practice the full procedure in the workshop, and only then do it in the field. A bricked coordinator on site means a network that cannot be commissioned and a return visit.$c$,
content_ar = $c$برمجة دونجل المنسق أكثر الإجراءات تقنية في هذا المسار، وهو الذي يفصل فنيًا يستطيع نشر تحكم محلي عمن يعتمد على بوابات المورّدين.

**ما هو المنسق.**

لكل شبكة Zigbee منسق واحد بالضبط. يكوّن الشبكة ويحمل مفاتيح الأمان ويسند العناوين ويصون جداول التوجيه. ودونجل المنسق USB يحوّل أي حاسوب — خادمًا صغيرًا أو حاسوبًا مصغرًا أو لوحة أحادية — إلى ذلك المنسق.

وهذا ما يتيح لـ Home Assistant أو Zigbee2MQTT تشغيل شبكة Zigbee بلا بوابة مصنّع وبلا أي تدخل سحابي.

**لماذا قد تعيد برمجة دونجل.**

- شُحن ببرنامج **موجّه** وتحتاج برنامج **منسق** (أو العكس — فدونجل احتياطي مبرمج كموجّه يصنع مكررًا شبكيًا ممتازًا).
- البرنامج الأصلي قديم ويفتقد إصلاحات استقرار الشبكة أو توافق الأجهزة.
- تبدّل المنصة والبرنامج الجديد يتوقع برنامجًا مختلفًا.
- حد الأجهزة في البرنامج الأصلي منخفض جدًا للتركيب.

**قبل البدء — ثلاثة أشياء تصيبها.**

1. **عرّف الشريحة بالضبط.** CC2652P وCC2652RB وEFR32MG21 وغيرها كل منها يأخذ برنامجًا مختلفًا. وبرمجة برنامج مبني لشريحة أخرى تُتلف الجهاز. والشريحة مطبوعة عادة على اللوحة أو مذكورة في وصف المنتج.
2. **طابق البرنامج مع المنصة.** فـ Zigbee2MQTT وZHA لهما توقعات برامج مختلفة. نزّل من صفحة إصدارات الصائن الرسمية لا من رابط منتدى.
3. **انسخ مفتاح الشبكة الحالي احتياطيًا** إن كان هذا الدونجل يشغّل شبكة حية. فإعادة البرمجة تصفّر الشبكة، وكل جهاز مقترن سيحتاج إعادة إقران. وفي عقار بأربعين جهازًا ذلك أغلب يوم عمل.

**الإجراء.**

1. **ادخل وضع الإقلاع.** أغلب الدونجلات تستخدم توليفة أزرار — عادة إمساك زر BOOT أثناء إدخال الدونجل أو أثناء ضغط RESET. والتسلسل الدقيق خاص بالموديل؛ راجع وثائق المصنّع لا تخمّن.
2. **تأكد من المنفذ.** يظهر الدونجل كمنفذ تسلسلي. عرّف الصحيح — فبرمجة المنفذ الخطأ تفشل بلا ضرر لكنها تضيع وقتًا في خطأ محيّر.
3. **ابرمج بالأداة الصحيحة.** شرائح Texas Instruments تستخدم عادة `cc2538-bsl`؛ وشرائح Silicon Labs تستخدم أدواتها. اتبع الإجراء الذي يذكره صائن البرنامج.
4. **لا تقاطع.** فالبرمجة المقاطَعة في منتصفها تترك الجهاز بحالة غير محددة. استخدم جهازًا لن ينام، ولا تفصل شيئًا حتى تبلّغ الأداة بالاكتمال.
5. **تحقق.** أعد الإدخال وتأكد أن إصدار البرنامج المبلَّغ يطابق ما برمجته، وأن البرنامج يتعرف عليه كمنسق.

**الهوائي والموضع — حيث تنشأ أغلب شكاوى الأداء.**

المنسق الموصول مباشرة بظهر خادم يجلس داخل صندوق معدني محاط بضجيج كهربائي، وسيكون مداه رديئًا.

**استخدم كابل تمديد USB دائمًا.** أبعد الدونجل نصف متر على الأقل عن الجهاز المضيف، بعيدًا عن الهيكل المعدني وعن منافذ USB 3.0 الأخرى، وفي هواء مفتوح. وUSB 3.0 خصوصًا يبث تداخلًا في نطاق ٢٫٤ جيجاهرتز تمامًا، والمنسق المجاور لمنفذ USB 3.0 سبب كلاسيكي ويمكن تجنبه تمامًا لشبكة متقلبة.

وهذا الكابل الرخيص وحده يحل مشاكل موثوقية Zigbee أكثر من أي تغيير برنامج.

**تخطيط القناة.** اضبط قناة Zigbee عمدًا كيلا تصطدم بـ Wi-Fi العقار. فقنوات Zigbee ١٥ و٢٠ و٢٥ تجلس في الفجوات بين قنوات Wi-Fi الشائعة ١ و٦ و١١. اختر قبل إقران الأجهزة — فتغيير القناة لاحقًا يفرض إعادة الإقران.

**بيان المخاطرة الصادق.**

البرمجة قد تتلف جهازًا. وهي قابلة للاسترداد غالبًا لكن ليس دائمًا، وليست إجراءً تؤديه لأول مرة في موقع عميل تحت ضغط وقت.

اشترِ دونجلًا احتياطيًا وتمرّن على الإجراء كاملًا في الورشة، ثم افعلها ميدانيًا. فمنسق تالف في الموقع يعني شبكة لا يمكن تشغيلها وزيارة أخرى.$c$
WHERE title = 'Flashing a Zigbee USB Coordinator (Dongle)';
