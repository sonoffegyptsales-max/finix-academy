# Recommended Video Resources — Finix Academy

**Every link below was checked programmatically** against YouTube's oEmbed API: all 27 returned HTTP 200, meaning each is public, live and embeddable. None were invented. Verified 23 September 2026.

## How to use these

These are **third-party videos**, not Finix material. Two consequences:

1. **Link to them, don't embed and don't re-upload.** Re-hosting someone else's video is a copyright problem; linking is not. This also matches your no-download policy — the trainee leaves to watch, then returns.
2. **They can disappear.** Channels delete, go private, or get taken down. Re-run the checker before each intake — see the bottom of this document.

Each entry says *why* it's assigned. A video the trainee doesn't know the purpose of is homework; a video with a stated question is training.

---

## SONOFF Installer Track

### M11 L2 — Communication Protocols: Wi-Fi, Zigbee 3.0 & Matter

| Video | Why |
|---|---|
| [Matter vs ZigBee vs WiFi vs Bluetooth vs Thread vs Z-Wave](https://www.youtube.com/watch?v=RX7nGsvw1M0) | Widest comparison. Watch for how it maps protocol to *use case*, which is the lesson's decision table. |
| [Matter, Thread, Zigbee & Z-Wave Explained](https://www.youtube.com/watch?v=MGgyEQIsosE) | Good on why Matter needs a border router — the point trainees most often get wrong. |
| [Why Matter Finally Makes Sense (and Wi-Fi Doesn't)](https://www.youtube.com/watch?v=XIjsPqn8Vxg) | Opinionated. Assign it as a *critique* exercise: which claims hold for an Egyptian villa with thick walls? |

**Question to answer after watching:** a client has 22 devices, 9 battery sensors, and unreliable internet. Which protocol, and why?

---

### M12 L1 — Installation Best Practices (the neutral question)

| Video | Why |
|---|---|
| [How to Install a Smart Switch: Neutral vs. No-Neutral Wire Guide](https://www.youtube.com/watch?v=fAcr1fL2uTM) | **Assign this first.** Directly matches the `m12-neutral-check` diagram. |
| [Turn ANY Light Switch Into a Smart Switch (No Neutral)](https://www.youtube.com/watch?v=YGD_kCwMP1Y) | The no-neutral workaround path, for when the box has live only. |
| [Adding A Neutral Wire To A Light Switch](https://www.youtube.com/watch?v=LaqPDBbMgLM) | The expensive option. Useful for showing trainees what they're quoting for. |

**Caution to state in class:** these are filmed under US/UK wiring conventions and colour codes. The *method* transfers; the wire colours do not. This reinforces the lesson's own rule — measure, don't read colour.

---

### M13 L1 — Integrating SONOFF with Home Assistant

| Video | Why |
|---|---|
| [Zigbee Integration into Home Assistant — Sonoff USB](https://www.youtube.com/watch?v=gN-_TO_HnTQ) | Cleanest end-to-end walkthrough of the direct-Zigbee path. |
| [How to set up SONOFF ZigBee 3.0 USB Dongle Plus in Home Assistant](https://www.youtube.com/watch?v=SlgC7xhhzzE) | Model-specific, matches hardware you actually sell. |
| [How to Add Zigbee Devices to Home Assistant with Dongle-PP10](https://www.youtube.com/watch?v=YrAzjQ3of0o) | Covers the pairing loop after the dongle is running. |

---

### M14 L2 — Configuring Dimmer Switches: Load Types & Curve Settings

| Video | Why |
|---|---|
| [Lamp Dimmers — Leading and Trailing Edge](https://www.youtube.com/watch?v=EDmXiG5AvSQ) | **The core one.** Explains the waveform difference behind the `m14-dimmer-loads` diagram. |
| [Essential Guide to Flawless LED Dimming](https://www.youtube.com/watch?v=tRGfppBahgY) | Practical: minimum load, driver compatibility. |
| [KNOW HOW: Dimming LED lamps — Tips, tricks and problems](https://www.youtube.com/watch?v=zuaQ8WIMUbQ) | Symptom-led — buzz, flicker, early failure. Pairs with the fault column of the diagram. |

**Exercise:** a client reports flicker below 20% only. Name three possible causes and the order you'd test them.

---

### M14 L5 — Flashing a Zigbee USB Coordinator

| Video | Why |
|---|---|
| [Sonoff Dongle Flasher Guide: Upgrade Zigbee Firmware](https://www.youtube.com/watch?v=t-f4f6mhAQw) | Follows the same step order as the `m14-dongle-flash` diagram. |
| [Sonoff Zigbee 3.0 USB Dongle Plus — How to upgrade the firmware](https://www.youtube.com/watch?v=KBAGWBWBATg) | Second angle on bootloader entry, the step that trips people. |

**Warn before assigning:** these videos rarely stress that re-pairing every device is mandatory after a coordinator change. Your lesson does. Make the trainee say why.

---

### M15 L1 — Diagnosing Zigbee Mesh Network Problems

| Video | Why |
|---|---|
| [Why Your Zigbee Mesh Network Keeps Failing (And How To Fix It)](https://www.youtube.com/watch?v=MDD7RRjr7uo) | Symptom-to-cause structure, same as the `m15-mesh-diagnosis` diagram. |
| [For $15 This is HOW TO Improve a Zigbee2MQTT Network](https://www.youtube.com/watch?v=uPo7Mi0WLb4) | Concrete: adding routers to fix coverage. |
| [Fixing my Zigbee with a network Zigbee coordinator](https://www.youtube.com/watch?v=yY-aD1hvwr4) | Coordinator placement — the cause trainees overlook. |

---

### M16 L1 — Network Segmentation for Smart Home Devices

| Video | Why |
|---|---|
| [Advanced Smart Home Security — VLANs and Firewalls](https://www.youtube.com/watch?v=eqr-vTC7EVk) | Conceptual grounding for the `m16-segmentation` diagram. |
| [Unifi IoT VLAN Firewall Rules for Apple HomeKit Users](https://www.youtube.com/watch?v=xMHQy4u8JZA) | Shows the one-way rule concretely, and why mDNS complicates it. |

**Note:** both are UniFi-specific. The principle is vendor-neutral; the menus are not.

---

## Finix Industrial Control Track

### I01 — Contactors & Control Logic

| Video | Why |
|---|---|
| [Latching Circuits](https://www.youtube.com/watch?v=3f3OnyM0S2E) | Matches `i01-latch-stop-priority`. Watch for *why* stop sits upstream of the latch. |
| [How to Wire a 3-Phase Motor with Start/Stop](https://www.youtube.com/watch?v=9x9QdL9N7vc) | Physical wiring of the same circuit — connects schematic to panel. |

---

### I02 — Motor Starting Methods

| Video | Why |
|---|---|
| [Star-Delta Starters Explained](https://www.youtube.com/watch?v=J0rs0vSLpRk) | Best on *why* star-delta reduces starting current. Pairs with `i02-starting-current`. |
| [Star Delta Starter Control Wiring Explained Practically](https://www.youtube.com/watch?v=vVs_1oEVMgQ) | The control circuit in a real panel. |
| [Star Delta Starter Explained — Working Principle](https://www.youtube.com/watch?v=h89TTwlNnpY) | Animated. Good for trainees who struggle with the transition moment. |

**Link to the smart layer:** after watching, ask which parts Alpha Control may replace. Answer per your doctrine — the timer and signalling, never the contactors or overload relay.

---

### I04 — Timers & Timing Functions

| Video | Why |
|---|---|
| [Understanding On-Delay and Off-Delay Timers](https://www.youtube.com/watch?v=r9HeJMCjwjk) | Matches `i04-on-off-delay` directly. |
| [How the Relay Timer Works (OFF Delay)](https://www.youtube.com/watch?v=yTU7EjTV778) | Off-delay alone — the harder of the two to picture. |
| [ON Delay OFF Delay Timer Connection](https://www.youtube.com/watch?v=VQSRWBWwT80) | Wiring-level, complements the theory. |

---

## Gaps — where I recommend *your own* video instead

For these, third-party video is a poor fit and your own footage would be worth more than any link:

- **F01 (team roles), F03 (site survey), F08 (terminology)** — these are *your* company's process. Generic videos teach a different workflow and will contradict your forms.
- **M12 L4 (SONOFF planning tools)** and **M12 L5 (documentation & handover)** — product- and company-specific.
- **M17 L4 (customer training / handover)** — this is the one where your Egyptian-market experience is the entire value. A 6-minute clip of a real handover would outperform anything available publicly.
- **Anything in Arabic.** Every video above is in English. If your trainees are stronger in Arabic, a short Arabic voice-over intro from you before each assigned video closes most of that gap at low cost.

**Highest-value thing you could film:** a panel-wiring walkthrough — DOL starter, then converting it to star-delta, then injecting a fault and finding it. That single video would serve I01, I02, I04 and I07, and no public video will match your panel, your components, or your language.

---

## Re-checking these links

All 27 were verified live on 23 September 2026. Before each new intake, re-run:

```bash
python3 scripts/check_video_links.py
```

It reports any link that has stopped resolving, so a dead resource is caught before a trainee hits it.
