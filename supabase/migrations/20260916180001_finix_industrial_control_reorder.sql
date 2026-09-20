-- Reorder Finix Industrial Control modules into curriculum sequence.
-- Modules were authored out of order (I04/I05 first), so positions reflected
-- creation order rather than teaching order. This sets I01..I07 in sequence.

UPDATE public.modules SET position = 26 WHERE slug = 'finix-contactors-control-logic';
UPDATE public.modules SET position = 27 WHERE slug = 'finix-motor-starting-methods';
UPDATE public.modules SET position = 28 WHERE slug = 'finix-motor-protection';
UPDATE public.modules SET position = 29 WHERE slug = 'finix-timers-timing-functions';
UPDATE public.modules SET position = 30 WHERE slug = 'finix-sensing-relays';
UPDATE public.modules SET position = 31 WHERE slug = 'finix-voltage-phase-protection';
UPDATE public.modules SET position = 32 WHERE slug = 'finix-panel-building-faultfinding';
