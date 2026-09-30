# Status

Current project state for planning and Claude projects. Maintained by Claude
after every status change (see CLAUDE.md, “Keeping the status”).
The GitHub issues are authoritative; this file is the summary.

**Last updated:** 2026-09-30

## In progress

- #20 Choose the app currency – tasks #47, #48

## Up next

- #9 Calculate cancellation date (minimum term, notice period)

## Backlog by epic

| Epic | Stories (in order) |
|---|---|
| #1 Foundation | #20 Choose the app currency (`in-progress`) |
| #8 Deadlines and reminders | #9 Calculate cancellation date (minimum term, notice period) → #21 Deadline disclaimer on first start and in About → #10 Reminder X days before the deadline → #11 Reminder before billing / end of free trial |
| #12 Subscription lifecycle | #13 Mark as cancelled, archive → #14 Price changes with history |
| #15 Data safety | #16 Backup and CSV export |

All stories without a marker are `backlog`.

## Recently done

- #7 Breakdown by category (epic #5 Cost overview complete)
- #6 Monthly and yearly totals
- #4 Subscription list sorted by next billing date
- #3 Create, edit and delete subscriptions
- #2 Project setup (theme, localization, `Clock`, `pumpApp`)

## Decisions

- Name: “Abo Escape” as working title, revisit before store release
- Currency: one app-wide currency (device locale default, changeable), no conversion
- Disclaimer: once on first start + under “About”
- Platform: Android for now, iOS possibly later
- Currency change: existing subscriptions switch to the new currency, no conversion
- After the minimum term: cancellable to the end of every billing period minus notice period

## Open decisions (user only)

- None right now.
