-- Repair, part B: M14-M17 three-option seed questions.

CREATE OR REPLACE FUNCTION pg_temp.add_opt(
  p_qid uuid, p_en text, p_ar text
) RETURNS void LANGUAGE plpgsql AS $fn$
BEGIN
  INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
  VALUES (p_qid, p_en, p_ar, false, 4);
END $fn$;

-- ---------- M14 ----------
SELECT pg_temp.add_opt('04699be8-65c3-4040-b6da-c729b6cc98f1',
  'Because the breaker label is often wrong, so the tester identifies which breaker to switch off',
  'لأن تسمية القاطع غالبًا خاطئة فيحدد جهاز الفحص أي قاطع يُفصل');

SELECT pg_temp.add_opt('1c84dc74-3123-419f-bd47-09050ca39313',
  'Whichever edge type the previous mechanical dimmer used',
  'أي نوع حافة استخدمه الديمر الميكانيكي السابق');

SELECT pg_temp.add_opt('50dffb4f-d849-4fdb-bb8a-aad299f88ce1',
  'Whether the circuit breaker is rated above the lamp wattage',
  'هل قاطع الدائرة مصنّف فوق قدرة المصباح');

SELECT pg_temp.add_opt('c4ade453-8095-48f5-b6f3-b431e5e8417e',
  'The coordinator must be returned to the manufacturer for re-certification',
  'يجب إرجاع المنسق للمصنّع لإعادة الاعتماد');

-- ---------- M15 ----------
SELECT pg_temp.add_opt('52655153-5227-43be-a8c5-92b9f7567a12',
  'Whether the gateway firmware supports the device brand',
  'هل برنامج البوابة يدعم علامة الجهاز');

SELECT pg_temp.add_opt('f7ae5e69-d464-4ceb-93a9-a904664d8528',
  'To reduce the storage space each recording consumes',
  'لتقليل مساحة التخزين التي يستهلكها كل تسجيل');

SELECT pg_temp.add_opt('9b118362-3929-4b65-9015-794f7b2bdb32',
  'The far-side sensors were paired to the wrong Zigbee channel',
  'حساسات الجانب البعيد أُقرنت بقناة Zigbee الخطأ');

SELECT pg_temp.add_opt('a95a2036-fd19-41e2-84ac-8553d763e993',
  'Only that both gateways run the same firmware version',
  'فقط أن تشغّل البوابتان إصدار البرنامج نفسه');

-- ---------- M16 ----------
SELECT pg_temp.add_opt('c89b1a3e-26b3-4502-9082-7efd7890ed41',
  'Reduces the electricity consumed by networking equipment',
  'يقلل الكهرباء التي تستهلكها معدات الشبكة');

SELECT pg_temp.add_opt('b20afadd-0c04-4a2f-9aaf-1b5f37c806fb',
  'Because vendors charge per device for simultaneous updates',
  'لأن المورّدين يحاسبون لكل جهاز على التحديثات المتزامنة');

SELECT pg_temp.add_opt('ab8f7ab3-db85-48b4-91f8-ab64188802c4',
  'Move the IoT devices onto the mobile network instead of Wi-Fi',
  'انقل أجهزة إنترنت الأشياء لشبكة الجوال بدل Wi-Fi');

SELECT pg_temp.add_opt('b0869088-16dc-4c1f-adb6-ae4216a91a80',
  'Rotating a single building-wide PIN every time a tenant leaves',
  'تدوير رمز واحد للمبنى كله كلما غادر مستأجر');

SELECT pg_temp.add_opt('194897dc-a044-44b7-9842-3c06d736f273',
  'Update only the devices whose vendors publish a changelog, and leave the rest untouched indefinitely',
  'حدّث فقط الأجهزة التي ينشر مورّدوها سجل تغييرات واترك البقية دون مساس إلى أجل غير مسمى');

-- ---------- M17 ----------
SELECT pg_temp.add_opt('3c2c88c9-9f57-4e05-83e8-1d16f2a98428',
  'Building scenes before the devices have been physically installed',
  'بناء المشاهد قبل تركيب الأجهزة فيزيائيًا');

SELECT pg_temp.add_opt('8cbbba79-d7a4-4fea-b833-8de047c3881a',
  'Because the thermostat display needs calibrating against a reference thermometer',
  'لأن شاشة الثرموستات تحتاج معايرة مقابل ترمومتر مرجعي');
