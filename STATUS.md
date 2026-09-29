# Status

Current project state for planning and Claude projects. Maintained by Claude
after every status change (see CLAUDE.md, “Keeping the status”).
The GitHub issues are authoritative; this file is the summary.

**Last updated:** 2026-09-29

## In progress

- Nothing yet.

## Up next

- #2 Project setup (`ready`) – tasks #17, #18, #19

## Backlog by epic

| Epic | Stories (in order) |
|---|---|
| #1 Foundation | #2 Project setup (`ready`) → #3 Create, edit and delete subscriptions → #4 Subscription list sorted by next billing date → #20 Choose the app currency |
| #5 Cost overview | #6 Monthly and yearly totals → #7 Breakdown by category |
| #8 Deadlines and reminders | #9 Calculate cancellation date (minimum term, notice period) → #21 Deadline disclaimer on first start and in About → #10 Reminder X days before the deadline → #11 Reminder before billing / end of free trial |
| #12 Subscription lifecycle | #13 Mark as cancelled, archive → #14 Price changes with history |
| #15 Data safety | #16 Backup and CSV export |

All stories without a marker are `backlog`.

## Recently done

- Open decisions settled: name, currency, disclaimer, platform
- Flutter project scaffolded (Scaffold workflow), CI green
- Labels, epics and stories created as issues
- Repo created with CLAUDE.md, STATUS.md, Flutter skill and CI

## Decisions

- Name: “Abo Escape” as working title, revisit before store release
- Currency: one app-wide currency (device locale default, changeable), no conversion
- Disclaimer: once on first start + under “About”
- Platform: Android for now, iOS possibly later

## Open decisions (user only)

- None right now.
