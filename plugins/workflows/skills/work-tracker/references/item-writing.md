# Writing tracker items

The reader is the user, skimming between other work. Each field answers one question; plain sentences, present
tense for facts, no filler. Item codes are fine here; they are the tracker's own language.

## title: what the item is, in one line

- `Preload the two tables the first open still loads late`
- `Event batching: end each batch on the store's flush event, not a 300 ms timer (thread 4211)`
- Q items ask the question: `Trim the preload list?`, `Which branch gets the cache fix?`

## details: facts first, then the plan or the options

Lead with what was found, each fact with its evidence. Then the plan (T) or the options (Q). Then progress lines,
each starting with a date, appended as the work moves, so the item reads as its own short history.

```
Who reads them:
• PriceRule: the order total (OrderView.Total → PriceCalculator.Apply, PriceCalculator.cs:88).
• CustomerGroup: the discount check (Discounts.ForCustomer, Discounts.cs:41).
Test first: the preload test failed for exactly these two tables, then passed. The list now has 23 tables.
2026-11-13: done. Orders.Tests 102/102. No new build warnings.
```

For a claim you haven't checked, say so where it stands: `Why the wait depended on it is not verified yet.`

Reply texts, commit messages and PR descriptions go here as drafts, marked as such:
`Draft reply (not posted): 'Merged main again (<commit>).'`

## recommendation: one choice and the reason

`Option 1. Every screen that lists an abstract type would hit this, and the fix belongs in the loader, where the "start, don't wait" rule lives.`

Recommend even when the choice seems obvious; say what you'd check first if the facts aren't enough.

## answer: the user's words, dated

`2026-11-13: option 1, in the existing framework PR. The logging fix gets its own branch.`

Follow-ups go on a new line with their own date; the original answer stays as it was.

## now and next

- now: `T34: framework part committed 7421687 (not pushed). App part done, uncommitted; Orders.Tests 102/102. Next: your manual run, then the app commit.`
- next: `T35, T36, T37, T39. Outside this phase: T25 (Q10).`

## log: one line per change

`T32 committed 6d1d25d (17 files, +427 −390); all tests green (981/981). Not pushed.`

Name codes, hashes and counts; leave out the story of how you got there.

## phases

- title: `Framework review: first priority`
- note: `Phase A waits until this phase is done. Each commit, push and reply needs your OK.`
