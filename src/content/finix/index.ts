/** Finix Academy — Smart Home & Industrial Automation Training.
 *
 * Static fallback curriculum: 10 modules across 4 tracks, each module ending
 * with Bronze / Silver / Gold quizzes. Lesson content lives in the Supabase
 * `lessons` table; this file carries titles, structure and track metadata so
 * the app can render a usable module list before migrations are applied.
 * The old smartacademy.onhercules.app external links were removed — the module
 * page now shows the full bilingual lesson content inline inside ProtectedContent
 * instead of linking out to another app.
 */

export type FinixTrackId =
  | "hardware-foundations"
  | "networking-protocols"
  | "team-project-management"
  | "survey-terminology-tools";

export interface FinixLesson {
  title: string;
  titleAr: string;
}

export interface FinixModule {
  slug: string;
  code: string;
  track: FinixTrackId;
  title: string;
  titleAr: string;
  summary: string;
  summaryAr: string;
  lessons: FinixLesson[];
}

export interface FinixTrack {
  id: FinixTrackId;
  name: string;
  nameAr: string;
  tagline: string;
  taglineAr: string;
}

export const finixTracks: FinixTrack[] = [
  {
    id: "hardware-foundations",
    name: "Electrical & Automation Hardware Foundations",
    nameAr: "أساسيات الكهرباء وعتاد الأتمتة",
    tagline:
      "DC/AC theory, Ohm's Law, three-phase power, protection devices, relays, contactors, and the Alpha Control platform.",
    taglineAr:
      "نظرية التيار المستمر والمتردد وقانون أوم والقدرة ثلاثية الطور وأجهزة الحماية والريليهات والكونتاكتورات ومنصة ألفا كنترول.",
  },
  {
    id: "networking-protocols",
    name: "Networking & Smart Home Protocols",
    nameAr: "الشبكات وبروتوكولات المنزل الذكي",
    tagline: "IP addressing, DHCP, NAT, Zigbee, Z-Wave, Thread, Matter, and smart home ecosystems.",
    taglineAr: "عنونة IP وDHCP وNAT وZigbee وZ-Wave وThread وMatter ومنظومات المنزل الذكي.",
  },
  {
    id: "team-project-management",
    name: "Smart Home Team & Project Management",
    nameAr: "فريق المنزل الذكي وإدارة المشاريع",
    tagline:
      "Team roles and competencies, project phases, after-sales support, KPIs, and performance evaluation for smart home teams.",
    taglineAr:
      "أدوار الفريق وكفاءاته ومراحل المشروع ودعم ما بعد البيع ومؤشرات الأداء وتقييم فرق المنازل الذكية.",
  },
  {
    id: "survey-terminology-tools",
    name: "Site Survey, Device Terminology & Field Tools",
    nameAr: "مسح الموقع ومصطلحات الأجهزة والأدوات الميدانية",
    tagline:
      "Professional site survey methodology, bilingual room and device terminology, tools checklist, and common field problems.",
    taglineAr:
      "منهجية مسح الموقع الاحترافية ومصطلحات الغرف والأجهزة بالعربية والإنجليزية وقائمة الأدوات ومشكلات الميدان الشائعة.",
  },
];

export const finixModules: FinixModule[] = [
  {
    slug: "electrical-fundamentals",
    code: "M01",
    track: "hardware-foundations",
    title: "Electrical Fundamentals for Automation Engineers",
    titleAr: "أساسيات الكهرباء لمهندسي الأتمتة",
    summary:
      "DC/AC characteristics, Ohm's Law wheel, three-phase power, Star/Delta motor connections, cable sizing, and power supply types.",
    summaryAr:
      "خصائص التيار المستمر والمتردد وعجلة قانون أوم والقدرة ثلاثية الطور وتوصيلات المحركات نجمة/دلتا وتحديد مقاس الكابلات وأنواع مزودات التغذية.",
    lessons: [
      {
        title: "Direct Current (DC): Properties, Advantages & Disadvantages",
        titleAr: "التيار المستمر DC: الخصائص والمزايا والعيوب",
      },
      {
        title: "Alternating Current (AC): Properties & Comparison with DC",
        titleAr: "التيار المتردد AC: الخصائص والمقارنة مع المستمر",
      },
      {
        title: "Ohm's Law Wheel & Power Calculations",
        titleAr: "عجلة قانون أوم وحسابات القدرة",
      },
      {
        title: "Three-Phase Power & Star/Delta Motor Connections",
        titleAr: "القدرة ثلاثية الطور وتوصيلات المحركات نجمة/دلتا",
      },
      {
        title: "Power Supplies: Adapter vs Power Supply vs Charger",
        titleAr: "مصادر التغذية: المحول مقابل مزود الطاقة مقابل الشاحن",
      },
    ],
  },
  {
    slug: "protection-devices-control-components",
    code: "M02",
    track: "hardware-foundations",
    title: "Protection Devices & Control Components",
    titleAr: "أجهزة الحماية ومكونات التحكم",
    summary:
      "Circuit breakers (MCB/MCCB/ACB), relay types, contactors, selector switches, and overload relays for industrial and smart home panels.",
    summaryAr:
      "قواطع الدوائر (MCB/MCCB/ACB) وأنواع الريليهات والكونتاكتورات ومفاتيح الاختيار وريليهات الحمل الزائد للوحات الصناعية والمنازل الذكية.",
    lessons: [
      {
        title: "Circuit Breakers: MCB, MCCB, ACB & Selecting the Right One",
        titleAr: "قواطع الدوائر: MCB وMCCB وACB وكيفية الاختيار الصحيح",
      },
      {
        title: "Relay: Types, Operation & Applications in Smart Home",
        titleAr: "الريليه: الأنواع وطريقة التشغيل وتطبيقاته في المنزل الذكي",
      },
      {
        title: "Contactor, Selector Switch & Overload Relay",
        titleAr: "الكونتاكتور ومفتاح الاختيار وريليه الحمل الزائد",
      },
      {
        title: "Electrical Load Types & Safety",
        titleAr: "أنواع الأحمال الكهربائية والسلامة",
      },
    ],
  },
  {
    slug: "alpha-control-platform",
    code: "M03",
    track: "hardware-foundations",
    title: "Alpha Control Smart Automation Platform",
    titleAr: "منصة ألفا كنترول للأتمتة الذكية",
    summary:
      "Architecture, hardware modules, wiring, commissioning and cloud integration of the Alpha Control system.",
    summaryAr:
      "بنية نظام ألفا كنترول ووحداته المادية وتمديداته والتشغيل والدمج السحابي.",
    lessons: [
      {
        title: "Alpha Control: Architecture & Core Board",
        titleAr: "ألفا كنترول: البنية واللوحة الأساسية",
      },
    ],
  },
  {
    slug: "network-fundamentals",
    code: "M04",
    track: "networking-protocols",
    title: "Network Fundamentals for Smart Home Technicians",
    titleAr: "أساسيات الشبكات لفنيي المنازل الذكية",
    summary:
      "Network types, IP addressing, IP classes A–E, DHCP, NAT, and Wi-Fi fundamentals.",
    summaryAr:
      "أنواع الشبكات وعنونة IP وفئات العناوين من A إلى E وDHCP وNAT وأساسيات الواي فاي.",
    lessons: [
      {
        title: "Network Types, Components & IP Addressing",
        titleAr: "أنواع الشبكات ومكوناتها وعنونة IP",
      },
      {
        title: "IP Classes A–E, DHCP & NAT Explained",
        titleAr: "شرح فئات IP من A إلى E وDHCP وNAT",
      },
    ],
  },
  {
    slug: "smart-home-wireless-protocols",
    code: "M05",
    track: "networking-protocols",
    title: "Smart Home Wireless Protocols",
    titleAr: "بروتوكولات اللاسلكي في المنزل الذكي",
    summary:
      "Zigbee mesh network roles, Z-Wave, Thread, Matter/CSA standard — comparison and use cases.",
    summaryAr:
      "أدوار شبكة Zigbee الشبكية وZ-Wave وThread ومعيار Matter/CSA — المقارنة وحالات الاستخدام.",
    lessons: [
      {
        title: "Zigbee: Mesh Roles, Architecture & Sonoff Devices",
        titleAr: "Zigbee: أدوار الشبكة الشبكية والبنية وأجهزة SONOFF",
      },
      {
        title: "Z-Wave & Thread: Two Reliable Alternatives",
        titleAr: "Z-Wave وThread: بديلان موثوقان",
      },
      {
        title: "Matter Standard, CSA & Smart Home Ecosystems",
        titleAr: "معيار Matter وتحالف CSA ومنظومات المنزل الذكي",
      },
      {
        title: "Protocol Comparison: Wi-Fi, Zigbee, Z-Wave & Thread",
        titleAr: "مقارنة البروتوكولات: Wi-Fi وZigbee وZ-Wave وThread",
      },
    ],
  },
  {
    slug: "team-roles-competencies",
    code: "M06",
    track: "team-project-management",
    title: "Smart Home Team: Roles & Required Competencies",
    titleAr: "فريق المنزل الذكي: الأدوار والكفاءات المطلوبة",
    summary:
      "The 5 essential roles in a professional smart home team — skills, responsibilities, and how they collaborate.",
    summaryAr:
      "الأدوار الخمسة الأساسية في فريق منازل ذكية محترف — المهارات والمسؤوليات وطريقة التعاون بينها.",
    lessons: [
      {
        title: "The 5 Roles of a Professional Smart Home Team",
        titleAr: "الأدوار الخمسة لفريق منازل ذكية محترف",
      },
    ],
  },
  {
    slug: "project-execution-after-sales",
    code: "M07",
    track: "team-project-management",
    title: "Project Execution: Installation Phases & After-Sales",
    titleAr: "تنفيذ المشروع: مراحل التركيب وما بعد البيع",
    summary:
      "Six phases from site survey to final handover, plus a professional after-sales support program.",
    summaryAr:
      "المراحل الست من مسح الموقع حتى التسليم النهائي، إضافة إلى برنامج احترافي لدعم ما بعد البيع.",
    lessons: [
      {
        title: "The 6 Phases of a Smart Home Installation Project",
        titleAr: "المراحل الست لمشروع تركيب منزل ذكي",
      },
    ],
  },
  {
    slug: "kpi-performance-evaluation",
    code: "M08",
    track: "team-project-management",
    title: "KPI & Performance Evaluation for Smart Home Technicians",
    titleAr: "مؤشرات الأداء وتقييم فنيي المنازل الذكية",
    summary:
      "5 key performance indicators for smart home technicians, personal competency assessment, and the official monthly evaluation form.",
    summaryAr:
      "مؤشرات الأداء الخمسة لفنيي المنازل الذكية وتقييم الكفاءة الشخصية ونموذج التقييم الشهري الرسمي.",
    lessons: [
      {
        title: "5 KPIs & The Technician Evaluation Form",
        titleAr: "مؤشرات الأداء الخمسة ونموذج تقييم الفني",
      },
    ],
  },
  {
    slug: "site-survey-methodology",
    code: "M09",
    track: "survey-terminology-tools",
    title: "Site Survey Methodology",
    titleAr: "منهجية مسح الموقع",
    summary:
      "The 5 phases of a professional smart home site survey — from infrastructure audit to documentation.",
    summaryAr:
      "المراحل الخمسة لمسح موقع منزل ذكي باحترافية — من تدقيق البنية التحتية حتى التوثيق.",
    lessons: [
      {
        title: "What is a Site Survey & Why It's Non-Negotiable",
        titleAr: "ما هو مسح الموقع ولماذا هو خطوة لا غنى عنها",
      },
      {
        title: "Client Consultation Questions for the Site Survey",
        titleAr: "أسئلة استشارة العميل أثناء مسح الموقع",
      },
    ],
  },
  {
    slug: "bilingual-device-room-terminology",
    code: "M10",
    track: "survey-terminology-tools",
    title: "Bilingual Device & Room Terminology",
    titleAr: "مصطلحات الأجهزة والغرف بالعربية والإنجليزية",
    summary:
      "Complete bilingual (Arabic/English) reference for room names, lighting fixtures, switches, appliances, and smart home components.",
    summaryAr:
      "مرجع كامل ثنائي اللغة (عربي/إنجليزي) لأسماء الغرف ووحدات الإضاءة والمفاتيح والأجهزة ومكونات المنزل الذكي.",
    lessons: [
      {
        title: "Room Names: Arabic–English Reference",
        titleAr: "أسماء الغرف: مرجع عربي–إنجليزي",
      },
      {
        title: "Device Terminology: Lighting, Switches & Appliances",
        titleAr: "مصطلحات الأجهزة: الإضاءة والمفاتيح والأجهزة الكهربائية",
      },
      {
        title: "Tools Checklist for the Smart Home Technician",
        titleAr: "قائمة أدوات فني المنازل الذكية",
      },
    ],
  },
];

export const finixQuizTiers = ["bronze", "silver", "gold"] as const;
export type FinixQuizTier = (typeof finixQuizTiers)[number];

export const finixQuizTierLabels: Record<
  FinixQuizTier,
  { en: string; ar: string }
> = {
  bronze: { en: "Bronze", ar: "برونزي" },
  silver: { en: "Silver", ar: "فضي" },
  gold: { en: "Gold", ar: "ذهبي" },
};

/** Passing mark for the per-module tier quizzes that earn certifications. */
export const FINIX_QUIZ_PASS_PERCENT = 80;

export interface FinixCertTier {
  id: FinixQuizTier;
  name: string;
  nameAr: string;
  description: string;
  descriptionAr: string;
}

export const finixCertTiers: FinixCertTier[] = [
  {
    id: "bronze",
    name: "Bronze Certification",
    nameAr: "اعتماد برونزي",
    description: "Pass the Bronze quiz of every module with 80% or above.",
    descriptionAr: "اجتاز اختبار البرونزي في كل الوحدات بنسبة ٨٠٪ أو أعلى.",
  },
  {
    id: "silver",
    name: "Silver Certification",
    nameAr: "اعتماد فضي",
    description: "Pass the Silver quiz of every module with 80% or above.",
    descriptionAr: "اجتاز اختبار الفضي في كل الوحدات بنسبة ٨٠٪ أو أعلى.",
  },
  {
    id: "gold",
    name: "Gold Certification",
    nameAr: "اعتماد ذهبي",
    description: "Pass the Gold quiz of every module with 80% or above.",
    descriptionAr: "اجتاز اختبار الذهبي في كل الوحدات بنسبة ٨٠٪ أو أعلى.",
  },
];

export interface FinixKpiCriterion {
  id: string;
  label: string;
  labelAr: string;
}

export interface FinixKpiGroup {
  id: "technical" | "behavioral";
  title: string;
  titleAr: string;
  /** Share of the final grade, 0–1. */
  weight: number;
  criteria: FinixKpiCriterion[];
}

export const finixKpiGroups: FinixKpiGroup[] = [
  {
    id: "technical",
    title: "Technical Execution",
    titleAr: "الأداء الفني",
    weight: 0.6,
    criteria: [
      { id: "neutral-wire", label: "Neutral wire compliance", labelAr: "الالتزام بالسلك المحايد" },
      {
        id: "wire-labeling",
        label: "Wire labeling & documentation",
        labelAr: "ترميز الأسلاك والتوثيق",
      },
      { id: "panel-aesthetics", label: "Clean panel aesthetics", labelAr: "ترتيب وجودة لوحة التوزيع" },
      {
        id: "scene-logic",
        label: "Scene logic without conflicts",
        labelAr: "منطق المشاهد دون تعارض",
      },
      { id: "first-time-fix", label: "First-time fix rate", labelAr: "نسبة الإصلاح من أول مرة" },
      {
        id: "safety-standards",
        label: "Electrical safety standards",
        labelAr: "معايير السلامة الكهربائية",
      },
    ],
  },
  {
    id: "behavioral",
    title: "Behavioral / Managerial",
    titleAr: "الجانب السلوكي / الإداري",
    weight: 0.4,
    criteria: [
      { id: "self-reliance", label: "Self-reliance & initiative", labelAr: "الاعتماد على النفس والمبادرة" },
      { id: "calmness", label: "Calmness under pressure", labelAr: "الهدوء تحت الضغط" },
      { id: "teamwork", label: "Teamwork & collaboration", labelAr: "العمل الجماعي والتعاون" },
      {
        id: "customer-professionalism",
        label: "Customer professionalism",
        labelAr: "الاحترافية مع العميل",
      },
    ],
  },
];

/** Each criterion is scored 0–10. */
export const FINIX_KPI_MAX_SCORE = 10;

export function finixKpiBand(percent: number): { en: string; ar: string } {
  if (percent >= 90) return { en: "Excellent", ar: "ممتاز" };
  if (percent >= 75) return { en: "Good", ar: "جيد" };
  if (percent >= 60) return { en: "Acceptable", ar: "مقبول" };
  return { en: "Needs Retraining", ar: "يحتاج إعادة تأهيل" };
}

export interface FinixSurveyStage {
  id: string;
  name: string;
  nameAr: string;
  hint: string;
  hintAr: string;
}

export const finixSurveyStages: FinixSurveyStage[] = [
  {
    id: "infrastructure",
    name: "Infrastructure Audit",
    nameAr: "تدقيق البنية التحتية",
    hint: "Neutral wire check, wall box depth (5–7cm), wiring topology (star/loop), earthing type…",
    hintAr: "فحص السلك المحايد وعمق علب الجدار (٥–٧ سم) وتوبولوجيا التمديد (نجمة/حلقة) ونوع التأريض…",
  },
  {
    id: "load-mapping",
    name: "Load Mapping",
    nameAr: "رسم خريطة الأحمال",
    hint: "Lighting circuits, HVAC amp rating, motorized shutters, plug circuits, total load kW…",
    hintAr: "دوائر الإضاءة وتصنيف أمبير التكييف والستائر الميكانيكية ودوائر المقابس وإجمالي الحمل بالكيلوواط…",
  },
  {
    id: "network-assessment",
    name: "Network Assessment",
    nameAr: "تقييم الشبكة",
    hint: "Wi-Fi signal strength, dead zones, router location, AP coverage plan, DHCP reservations…",
    hintAr: "قوة إشارة الواي فاي والمناطق الميتة وموقع الراوتر وخطة تغطية نقاط الوصول وحجوزات DHCP…",
  },
  {
    id: "scene-logic",
    name: "Scene Logic Design",
    nameAr: "تصميم منطق المشاهد",
    hint: "Automation scenes, schedules, voice control triggers, HVAC zones, security integration…",
    hintAr: "مشاهد الأتمتة والجداول ومشغلات التحكم الصوتي ومناطق التكييف ودمج منظومة الأمن…",
  },
  {
    id: "as-built",
    name: "As-Built Documentation",
    nameAr: "توثيق ما نُفّذ",
    hint: "Circuit diagram summary, device list with IPs/MAC addresses, site photos, handover notes…",
    hintAr: "ملخص المخطط الكهربائي وقائمة الأجهزة مع عناوين IP/MAC وصور الموقع وملاحظات التسليم…",
  },
];
