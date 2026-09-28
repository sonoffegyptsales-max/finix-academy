# Finix Academy — Practical Lab Curriculum (Labs A/B/C)

Companion to docs/COURSE_PLAN.md. Every exercise maps to platform modules the
trainee has already passed at Bronze tier or higher.

**Class size: 12 trainees maximum — 3 benches × 4 trainees, working in pairs
(2 pairs per bench). One lead instructor + one lab assistant per 12.**
Rationale: pair work forces the "one wires, one verifies against the diagram"
discipline from F01's KPI loop; more than 4 per bench means someone watches
instead of wiring.

Safety baseline for every lab: insulated tools, RCD-protected bench supplies,
lockout before touching any circuit, instructor sign-off before energizing.

---

## Lab A — Electrical Fundamentals Bench (after Track 1, modules F02/F04/F05)
**Duration: 4 hours · 6 exercises**
Photo: `public/labs/lab-a-electrical-bench.png`

| # | Exercise | Time | Maps to |
|---|---|---|---|
| A1 | Multimeter drills: measure AC/DC voltage, continuity, resistance on prepared boards; identify a broken conductor hidden in a junction box | 40 min | F02 L1 |
| A2 | Breaker + cable sizing: given 3 real loads (kettle, LED bank, small motor), compute breaker rating and wire gauge, then assemble MCB + wire on DIN rail | 45 min | F04 L2, Cable Sizing worked example |
| A3 | Neutral hunt: on a mock switch box, determine if a neutral is present; decide smart-switch vs no-neutral vs relay-at-ceiling (the M11 L4 decision) | 30 min | F03, M11 L4 |
| A4 | Relay + contactor anatomy: strip a dead relay and a dead contactor, name every part, then wire a live low-voltage relay controlling a lamp | 45 min | F04 L3/L4 |
| A5 | IP addressing on the bench: connect 2 laptops + router, assign static IPs, ping, find a deliberately wrong subnet mask | 40 min | F05 L2 |
| — | Breaks + setup/reset between exercises | 60 min | |

**Pass gate:** A2 assembly energizes correctly first try + A3 decision justified aloud in Egyptian Arabic exactly as to a customer.

---

## Lab B — Smart Home Installation (after Track 2, modules M11–M15)
**Duration: 4 hours · 5 exercises**
Photo: `public/labs/lab-b-smart-home-wall.png`

| # | Exercise | Time | Maps to |
|---|---|---|---|
| B1 | Live SONOFF install: wire a MINIR4 behind an existing wall switch on the training wall (real 230V, RCD-protected), pair to eWeLink on a CLIENT-owned test account | 50 min | M12 L1, M17 L4 |
| B2 | Zigbee mesh build: coordinator + 6 devices across the lab; then instructor kills one router device — trainees diagnose which sensors dropped and why, using the M15 symptom→cause method | 45 min | M13, M15 L1 |
| B3 | Dimmer bench: same LED lamp on leading vs trailing edge; observe flicker, set minimum brightness floor, swap to a non-dimmable lamp and identify the symptom | 35 min | M14 L2 |
| B4 | Automation build: motion → light with lux condition + manual override, tested with the network cable pulled (local vs cloud execution — the M12 L3 principle) | 40 min | M12 L3, M16 |
| B5 | Handover roleplay: one pair is the installer, one pair the customer; 10-minute handover including the "what to do when something breaks" card, in the course register | 30 min | M17 L4 |
| — | Breaks + reset | 40 min | |

**Pass gate:** B4 automation still works with internet disconnected + B1 account ownership correct (client email, installer as shared access — the credential-hygiene rule).

---

## Lab C — Industrial Control Panel (after Track 3, modules I01–I07)
**Duration: 6 hours · 5 exercises — the capstone**
Photo: `public/labs/lab-c-motor-panel.png`

| # | Exercise | Time | Maps to |
|---|---|---|---|
| C1 | DOL starter from schematic: contactor + overload + start/stop + latch, wire-numbered per the F/I convention, motor runs | 75 min | I01 L2 |
| C2 | Stop-priority proof: instructor holds START pressed while trainee hits STOP — machine must stop (NC stop in the common leg). If it doesn't, find why | 20 min | I01 L2/L3 |
| C3 | Convert C1 to star-delta: add second/third contactor + timer, set transition time for the bench motor, measure inrush current both ways with a clamp meter | 90 min | I02, F02 L4 |
| C4 | Fault injection: instructor plants 3 faults (loose control wire, swapped NO/NC, overload set to line-vs-coil current wrong); trainees find all 3 with meter + schematic, no trial-and-error allowed | 60 min | I07, I03 |
| C5 | Timer functions live: ON-delay vs OFF-delay on the panel beacon; read the timing diagram first, predict, then wire and verify | 45 min | I04 L2/L3 |
| — | Breaks + reset + capstone sign-off | 70 min | |

**Pass gate:** C4 all three faults found *with stated reasoning* ("الفشل الثاني غالبًا أغلى من الأول" — no part-swapping without a why) + C3 inrush measurements recorded in the field form.

---

## Per-bench equipment list (one-time purchase, ×3 benches)

| Item | Qty/bench | Est. EGP |
|---|---|---|
| DIN rail + enclosure training frame | 1 | 2,500 |
| Contactors (LC1-style, 220V coil) | 3 | 1,800 |
| Thermal overload relay | 1 | 900 |
| Star-delta / multifunction timer | 2 | 1,600 |
| MCBs (B6, C10, C16) + RCD 30mA | 1 set | 1,500 |
| Small 3-phase motor (0.37 kW) | 1 | 4,500 |
| Push buttons, e-stop, beacon, lamps | 1 set | 1,200 |
| Digital multimeter + clamp meter | 2+1 | 3,000 |
| SONOFF kit: MINIR4, dimmer, 6× Zigbee devices, dongle, gateway | 1 kit | 6,500 |
| Wiring, ducting, lugs, consumables (per cohort) | — | 1,500 |
| **Total per bench** | | **~25,000** |
| **Total 3 benches** | | **~75,000 EGP one-time** (SONOFF kit at distributor cost reduces this) |

Consumables per cohort of 12: ~4,500 EGP.

---

## Cohort economics at recommended prices

Full programme + labs at 11,900 EGP × 12 trainees = **142,800 EGP per cohort**.
Instructor cost (32 h sessions + 14 h labs ≈ 46 h × ~400 EGP) ≈ 18,400 EGP +
assistant ≈ 6,000 + consumables 4,500 → **~114,000 EGP gross margin per cohort**
after the benches are amortized (first ~1 cohort pays for all three benches).
