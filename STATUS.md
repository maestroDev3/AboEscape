# Status

Current project state for planning and Claude projects. Maintained by Claude
after every status change (see CLAUDE.md, “Keeping the status”).
The GitHub issues are authoritative; this file is the summary.

**Last updated:** 2026-09-29

## In progress

- Nothing yet – the repo only contains the working rules, skill and CI.

## Up next

- “First start” from CLAUDE.md: create labels, epics and stories as issues,
  run the Scaffold workflow, refine the first story “Project setup”.

## Planned epics (no issue numbers yet)

| Epic | Stories (in order) |
|---|---|
| Foundation | Project setup (scaffold, green CI, theme, `pumpApp`) → Create, edit and delete subscriptions → Subscription list sorted by next billing date |
| Cost overview | Monthly and yearly totals → Breakdown by category |
| Deadlines and reminders | Calculate cancellation date (minimum term, notice period) → Reminder X days before the deadline → Reminder before billing / end of free trial |
| Subscription lifecycle | Mark as cancelled, archive → Price changes with history |
| Data safety | Backup and CSV export |

## Recently done

- Repo created with CLAUDE.md, STATUS.md, Flutter skill and CI

## Open decisions (user only)

- Keep the name “Abo Escape” (German “Abo”) or use a fully English name like “Sub Escape” for international markets?
- Single currency (EUR) or multiple currencies?
- In-app disclaimer (deadlines without guarantee)?
- Android only, or iOS later?
