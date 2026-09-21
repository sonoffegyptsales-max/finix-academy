-- Repair pre-existing defect: 29 seed questions (M11-M17, positions 1-2) were
-- created with only three options instead of four, and in every case the
-- correct answer sits at option position 1 -- a pattern a trainee can exploit
-- without knowing the material.
--
-- This migration adds a fourth plausible distractor to each, then shuffles
-- option positions across the whole bank so the correct answer is no longer
-- predictable by position.

CREATE OR REPLACE FUNCTION pg_temp.add_opt(
  p_qid uuid, p_en text, p_ar text
) RETURNS void LANGUAGE plpgsql AS $fn$
BEGIN
  INSERT INTO public.quiz_options (question_id, option_text, option_text_ar, is_correct, position)
  VALUES (p_qid, p_en, p_ar, false, 4);
END $fn$;

-- ---------- M11 ----------
SELECT pg_temp.add_opt('e749e07a-985c-4254-b9ae-d16620fbd29e',
  'Cloud-only Wi-Fi devices with a faster internet package',
  'أجهزة Wi-Fi سحابية فقط مع باقة إنترنت أسرع');

SELECT pg_temp.add_opt('e5505a59-7c32-4cdf-867f-008e62017d1e',
  'The brand of the previously installed mechanical switch',
  'علامة المفتاح الميكانيكي المركّب سابقًا');

SELECT pg_temp.add_opt('e7ba6f44-81e2-4d67-9efc-c8fdb853d2ad',
  'Battery-powered sensors throughout, since they need no wiring',
  'حساسات تعمل بالبطارية في كل مكان لأنها لا تحتاج تمديدات');

SELECT pg_temp.add_opt('1c3466dc-bbe2-43f7-9c37-9fa5e4a54f50',
  'Create a second account on the installer''s email and hand that over',
  'أنشئ حسابًا ثانيًا على بريد الفني وسلّمه');

SELECT pg_temp.add_opt('0a86b1a7-487b-452d-9621-99893569f5f2',
  'Standardise on the legacy Wi-Fi platform and avoid Matter entirely',
  'وحّد على منصة Wi-Fi القديمة وتجنب Matter تمامًا');

-- ---------- M12 ----------
SELECT pg_temp.add_opt('0706312a-ffb3-45a3-a906-dd0ca86ad4d2',
  'Because building regulations require gateways at the centre of a property',
  'لأن لوائح البناء تشترط وضع البوابات في وسط العقار');

SELECT pg_temp.add_opt('7521635c-f313-4c13-916f-993150bf521a',
  'To record which technician commissioned the device',
  'لتسجيل أي فني شغّل الجهاز');

SELECT pg_temp.add_opt('d46f4718-7c78-454f-9c1f-2d17bd0404cf',
  'Remove the dusk trigger and rely on a fixed clock time instead',
  'أزل مشغّل الغسق واعتمد على وقت ساعة ثابت بدلًا منه');

SELECT pg_temp.add_opt('82b2692b-f938-4971-8bff-16da891cdfc6',
  'The door will open more slowly than the manufacturer specifies',
  'سيفتح الباب أبطأ مما يحدده المصنّع');

SELECT pg_temp.add_opt('68897474-f2eb-41fa-a715-168bed1c4206',
  'Giving every technician administrator rights so anyone can fix anything quickly',
  'منح كل فني صلاحيات مدير ليصلح أي أحد أي شيء بسرعة');

-- ---------- M13 ----------
SELECT pg_temp.add_opt('974ce23e-6853-441e-9a8d-f9bd768a33c5',
  'It removes the need for a gateway in every installation',
  'يلغي الحاجة لبوابة في كل تركيب');

SELECT pg_temp.add_opt('585765eb-8190-42f0-a6d8-28a033f507e6',
  'Having too many mains-powered router devices on the mesh',
  'وجود أجهزة موجّهة مغذاة كثيرة جدًا على الشبكة');

SELECT pg_temp.add_opt('448a33c8-3ec6-4873-9a99-889d7d68d74d',
  'Add a third platform to arbitrate between the two',
  'أضف منصة ثالثة للتحكيم بين الاثنتين');

SELECT pg_temp.add_opt('71b5759d-75ef-4493-aa1a-b1b1d8d572c2',
  'Three separate gateways, one dedicated to each ecosystem',
  'ثلاث بوابات منفصلة واحدة مخصصة لكل منظومة');
