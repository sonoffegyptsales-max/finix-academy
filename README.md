# Finix Academy

Standalone web app for **Finix Academy — Smart Home & Industrial Automation Training** (Finix Systems).

An in-house rebuild of the training portal previously prototyped on the Hercules platform
(smartacademy.onhercules.app): the same curriculum structure — 10 modules across 4 tracks,
Bronze/Silver/Gold tier quizzes and certifications, technician KPI evaluation, and a
five-stage site survey & engineering audit form — owned end-to-end in this repo.

## Stack

- TanStack Start (React 19) + TanStack Router, deployed on Vercel
- Tailwind CSS 4 + shadcn-style UI
- Supabase (auth + future data tables)
- Bilingual EN/AR (`src/lib/language.tsx`)

## Structure

- `/` — public landing
- `/auth` — sign-in (accounts issued by the academy administrator)
- `/finix` — gated training portal (tracks & modules)
- `/finix/$slug` — module detail with lesson list and tier quiz links
- `/finix/certification` — Bronze/Silver/Gold requirements
- `/finix/kpi` — technician field KPI evaluation (Technical 60% + Behavioral 40%)
- `/finix/survey` — five-stage site survey & engineering audit form

Curriculum data lives in `src/content/finix/index.ts`; lesson playback stays in the
Finix Academy app (each module links out to it).

## Development

```bash
npm install
npx vite dev --port 4322
```

Local dev needs a `.env` (not committed) with:

```
VITE_SUPABASE_URL=...
VITE_SUPABASE_PUBLISHABLE_KEY=...
SUPABASE_URL=...
SUPABASE_PUBLISHABLE_KEY=...
```

On Windows with Node 20, Vite 8 also needs native bindings installed without saving:
`npm install @oxc-parser/binding-win32-x64-msvc @rolldown/binding-win32-x64-msvc --no-save`.
`.nvmrc` pins Node 22 for Vercel builds.
