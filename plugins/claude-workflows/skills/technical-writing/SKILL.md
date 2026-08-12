---
name: technical-writing
description: Rules and checks for writing or reviewing technical documentation — READMEs, API references, runbooks, architecture docs, tutorials, release notes, error messages, code comments, design docs, or any developer-facing text. Merges ISO 24495 plain-language principles with Google's Technical Writing One and Two courses (words, active voice, sentence and paragraph structure, lists/tables, audience analysis, document organization, illustrations, sample code, self-editing, responsible LLM-assisted drafting). Use this whenever asked to draft, edit, review, simplify, or give feedback on technical writing, even if the person doesn't name a standard or say "plain language" — phrases like "make this README clearer," "review my API docs," "why is this doc confusing," "tighten this up for devs," or "write a runbook for X" should all trigger it.
---

# Technical Writing

A merged rule set for drafting and reviewing technical documentation. It combines two sources that approach the same problem from different angles:

- **ISO 24495** (plain language) — four governing principles: a document should be **relevant**, **findable**, **understandable**, and **usable**. Part 3 adds guidance for writing about specialized subject matter for audiences of mixed expertise, which is exactly the situation most technical docs are in (a README read by both a first-time user and the maintainer).
- **Google's Technical Writing One and Two** — a practical, example-driven course on word choice, sentence and paragraph craft, document structure, illustrations, sample code, self-editing, and responsible LLM use, written for software engineers and technical writers.

Apply this whenever drafting new technical content or reviewing/editing existing content. When reviewing someone else's draft, don't just list every deviation — prioritize the changes that would most help *this* reader, and explain the "why" behind a suggested edit rather than just marking it wrong.

The sections below are organized by where they apply, from planning through to editing. Skip to what's relevant: fixing a paragraph doesn't require re-deriving the audience, but drafting a new document benefits from starting at the top.

---

## 1. Know the audience and scope before drafting

Good documentation is measured against a gap: `what the reader needs to know − what the reader already knows`. You can't close that gap without knowing both sides.

- **Identify the reader's role** (software engineer, ops/on-call, PM, integrator, end user, new team member) and their **proximity** to the subject — someone can be an expert engineer and still be a total newcomer to *this* codebase or *this* concept. Proximity fades with time too: even experienced engineers forget details of a project they haven't touched in a year.
- **Identify the reader's purpose**: are they following steps to complete a task, deciding whether to adopt something, debugging a failure, or learning a concept before applying it? A reference doc and a tutorial serve the same topic differently.
- **Identify the reading context**: mid-incident under time pressure, or calmly onboarding? On a phone, in a terminal, in an IDE tooltip?
- **Watch for the curse of knowledge** — the more expert you are, the easier it is to forget what a newcomer doesn't yet know. If you're documenting something you built, assume you need to explain more than feels natural.
- **State the document's scope up front**: what it covers, and — just as important — what it explicitly does *not* cover. A stated non-scope prevents both reader confusion and writer scope creep; if your draft starts wandering into the non-scope, that's a sign to split the document or revise the scope statement.
- **State the audience and prerequisites**: name the roles you're writing for and any required background ("assumes familiarity with X").
- **Select content honestly**: include what the reader needs, cut what only serves the writer's convenience, and never omit information the reader needs to act safely or correctly.
- **For specialized/technical subject matter** (ISO 24495-3's extension — directly relevant to engineering docs): match implementation depth to reader expertise; state your assumptions and how information was validated (tested on what, under what conditions); name known edge cases and limitations explicitly, including what's *not yet known* or confirmed; give the reader the "so what," not just the facts; state the concrete next action where relevant; list supporting material needed (glossary, related docs, changelog); and present information with integrity — report limitations fairly, don't cherry-pick favorable results, disclose conflicts of interest (e.g., vendor-authored comparisons).

## 2. Structure for findability

A reader should be able to tell fast whether a document serves their purpose, and locate the one thing they came for.

- **Lead with the most important message.** Summarize key points at the very start — assume busy readers may only read the first paragraph.
- **Order information by the reader's task**, not by your implementation history. For instructions, use the order the reader will actually perform steps. Put common cases before edge cases. If skipping a step risks damage or data loss, put the warning *before* the instruction.
- **Compare new ideas to what the reader already knows.** Most technical work is evolutionary, not revolutionary — anchoring a new concept to a familiar one ("like X, except...") shortens the distance to understanding.
- **Use headings that predict content**, phrased around the reader's task ("Installing on Windows," "What to do if the migration fails") rather than your internal terminology ("Running the carambola command"). Give each heading at least a sentence of orienting text before diving into a subheading.
- **Choose single-document vs. multi-document structure deliberately.** Short, standalone documents suit newcomers and quick overviews. Longer documents suit in-depth material for readers with some existing familiarity, and can be split into sections that don't need to be read start-to-finish (reference pages are scanned, not read).
- **Outline before drafting long documents.** An outline reveals gaps and lets you move topics around cheaply, before the cost of rewriting prose.
- **Disclose information progressively.** Introduce new terms and concepts near the instructions that need them, not all up front. Break long walls of text and long step sequences into smaller, digestible chunks. Start with simple cases and layer in complexity.
- **Add navigation**: a clear progression of headings, a table of contents for anything long, and links to related or deeper material rather than inlining everything.
- **Keep supplementary information separate** from the must-know steps — background, rationale, and history belong in an appendix, an ADR, or a linked doc, not blocking the main flow.
- **For specialized/technical subject matter**: give an informative summary and explicit scope statement at the start of any long or complex document; provide more than one way to reach the same information (TOC, search, cross-links), since readers often arrive mid-task from a search hit rather than reading start to finish.

## 3. Choose words deliberately

- **Define unfamiliar terms** the first time they appear, or link to an existing good explanation — don't reinvent a definition that already exists elsewhere.
- **Use one term per concept, consistently**, for the entire document (and ideally across your whole documentation set). Renaming a concept partway through is as disruptive to a reader's mental model as renaming a variable mid-function is to a compiler.
- **Introduce acronyms properly**: spell out the full term the first time, followed by the acronym in parentheses, then use the acronym consistently afterward — don't cycle back and forth between the long and short forms. Only bother defining an acronym if it's both meaningfully shorter than the full term *and* used often enough in the document to be worth the reader's effort in learning it.
- **Watch ambiguous pronouns** — "it," "they/them," "this," "that." Use a pronoun only after introducing its noun, keep it close to that noun (rule of thumb: if more than about five words separate them, repeat the noun instead), and never let a second noun get inserted in between. If it's not obvious what "this" refers to, either replace it with the actual noun or put a noun right after it ("this configuration" beats a bare "this").
- **Prefer simple, common words over rare or ornate ones** — plain vocabulary travels better internationally and translates more reliably than obscure English.
- **Stay culturally neutral.** Avoid idioms ("a piece of cake," "sticky wicket") and culture-specific references (sports metaphors, regional slang) that don't translate and can confuse machine translation as much as human readers.

## 4. Write clear, active, concise sentences

This is the area where ISO's "understandable" principle and Google's course overlap most, and where the specific techniques compound well together.

- **Prefer active voice**: actor + verb + target ("The script deletes temporary files"), not target + verb + actor ("Temporary files are deleted [by the script]"). Active voice is shorter, names who's responsible, and doesn't force the reader to mentally flip the sentence around. Watch for the passive-voice tell: a form of *be* (is/are/was/were) plus a past-participle verb, often followed by a preposition ("was generated by"). Sentences starting with an imperative verb ("Open the file," "Click Submit") are active even without a stated actor — the implied actor is "you."
- **Choose strong, specific verbs.** Weak, generic verbs (forms of *be*, "occur," "happen") are a signal that a sentence's real actor or action is missing or buried. "The exception occurs when dividing by zero" → "Dividing by zero raises the exception."
- **Avoid "There is / There are" openers.** They pair a generic noun with a generic verb. Find the real subject: "There is a variable called `x` that stores..." → "The `x` variable stores...".
- **One idea per sentence.** If a sentence contains "and," "or," a list of items, or multiple independent clauses, consider whether it should become two sentences or a bulleted/numbered list.
- **Cut filler.** "In order to" → "to"; "is able to" → "can"; "causes the triggering of" → "triggers." Say each fact once — don't restate the same requirement in slightly different words in three places; a reader who finds only one version and it disagrees with the others has no way to know which is current.
- **Scrutinize subordinate clauses** (introduced by "which," "that," "because," "since," "unless," etc.). Ask whether a clause *extends* the main idea or *branches off* into a separate one — if it branches, split it into its own sentence. In US English, use "which" for a nonessential clause (with a comma) and "that" for an essential one (no comma).
- **Replace vague adjectives/adverbs with numbers.** "Runs screamingly fast" tells the reader nothing verifiable; "runs 225–250% faster" does. Save subjective, marketing-flavored language for marketing, not documentation.

## 5. Build lists, tables, and paragraphs that scan well

- **Use a bulleted list for unordered items, a numbered list for ordered ones.** Test: if reordering the items changes the meaning, it must be numbered; if not, it should be bulleted.
- **Convert embedded ("run-in") lists inside sentences into real lists.** A sentence with "or," or a string of items stuffed into it, is usually a list trying to escape.
- **Keep list items parallel**: matching grammar, logical category, capitalization, and punctuation. Start numbered steps with imperative verbs consistently ("Stop the server," "Edit the file," "Restart the server") — don't mix commands with descriptive statements.
- **Give every list and table an introductory sentence** ending in a colon, so the reader knows what they're about to see (the word "following" is a reliable, if optional, signal: "the following table summarizes...").
- **In tables**, label every column with a meaningful header, keep cell content short (if a cell needs more than a couple of sentences, it probably belongs in prose instead), and keep each column's data type consistent down the column.
- **Write a strong opening sentence for every paragraph** — it establishes the paragraph's topic, and busy readers often read only this sentence before deciding whether to continue.
- **Keep each paragraph on a single topic.** Cut or relocate any sentence that drifts from that topic, even if it's individually well-written.
- **Aim for 3–5 sentences per paragraph.** Much longer becomes an intimidating wall of text; a document full of one-sentence paragraphs usually signals disorganized structure, not good pacing — combine related one-liners or convert them to a list.
- **A good paragraph answers what, why, and how**: what you're telling the reader, why it matters to them, and how they should use or verify it.

## 6. Use diagrams, screenshots, and illustrations purposefully

- **Write the caption before making the illustration**, then build the illustration to match the caption. This keeps the image honest about its own point. A good caption is brief, states the takeaway, and focuses the reader's attention — especially in a busy image.
- **Constrain how much a single diagram tries to say.** Rule of thumb: if explaining the diagram would take more than one paragraph (or more than about five bullet points), split it — show the big picture, then zoom into subsystems separately.
- **Focus the reader's eye deliberately** — a callout, arrow, or highlighted region tells the reader where to look instead of leaving them to guess which of six equally-weighted screenshot elements matters.
- **Treat illustrating as an iterative process**, the same as writing a draft. Ask: can this be simplified? Should it split into two images? Is there enough contrast for accessibility? What's the one-sentence takeaway, and does the image actually deliver it?
- **Export diagrams as SVG** where possible so they scale cleanly across screen sizes.
- **Use images and diagrams anywhere they'd communicate a process, comparison, or structure faster than prose would** — and only where they carry real information, not for decoration.

## 7. Write sample code like it's a teaching tool, not scratch work

- **Make sample code correct**: it should build without errors, actually do what it claims, follow language conventions, avoid known security issues, and be tested and maintained like production code — don't quietly let snippets rot.
- **Keep it concise.** Include only what's essential to the point being taught; strip anything that would distract from that point, but never sacrifice correctness for brevity.
- **Make it understandable**: descriptive names, no unnecessary cleverness, no deep nesting. Spell out parameter names in examples rather than relying on positional arguments, especially for newcomers to the API.
- **Comment for the "why," not the "what," once readers have any experience** — avoid narrating obvious code, and focus commentary on the non-intuitive parts. Remember that readers who copy-paste a snippet take your comments with them, so put anything that belongs in the pasted result *in* the code comment, and put longer conceptual explanation in the surrounding prose instead.
- **Make it reusable**: state any dependencies or setup the reader needs, and think about side effects if this code gets pasted into someone else's real program.
- **Show the anti-example when a mistake is easy to make** — a short "this is wrong, and here's why" can save more confusion than a longer correct-only example.
- **Sequence a set of examples by complexity**: start at "Hello World" and build up, rather than jumping straight to the most advanced case.
- **Document how to actually run the sample** — dependencies, environment setup, and expected output, especially if the code isn't trivially runnable as-is.

## 8. Keep tone respectful and the whole document cohesive

- **Address the reader directly** ("you," "your service") instead of a passive, impersonal third person.
- **Avoid "simply," "just," and "obviously"** in instructions — what's obvious to the author is frequently not obvious to the reader, and the word reads as condescending the moment a step turns out not to be simple.
- **In error messages**, state what happened and what to do next, without blaming language.
- **Keep terminology, tone, and formatting consistent** across sentences, sections, and — ideally — your whole documentation set. The same field, button, or concept should have the same name in the README, the reference doc, and the UI.
- **Treat the document as a system**: each element — a paragraph, a diagram, a code sample — should be clear on its own *and* work together with the others so the reader comes away understanding the whole, not just isolated pieces.
- **Attribute and source claims a reader can't verify themselves.** Mark reused or adapted content, and identify the author/team so readers can judge expertise, currency, and potential conflicts of interest (e.g., an internal benchmark vs. an independent one).

## 9. Self-edit before calling it done

A first draft is a starting point, not a deliverable. Use several of these, not just one:

- **Adopt (or ask about) a house style guide** if one exists for the project or organization, and default to its conventions over personal preference.
- **Build a lightweight persona** for the target reader (role, goal, assumed background) and re-read the draft as if you were that person — but don't over-fit to a single persona at the expense of everyone else who'll read the doc.
- **Read it out loud** (or run it through a screen reader). Awkward phrasing and overlong sentences reveal themselves in a way silent reading often misses.
- **Come back to it later with fresh eyes** — even an hour of distance surfaces things a tired brain glossed over.
- **Change the context**: a different font, a printed copy, a different device — anything that breaks the visual pattern your eyes have gotten used to.
- **Get a peer reviewer.** They don't need deep subject-matter expertise, but they do need to know the style conventions you're both working from.
- **Evaluate continually, not just at the end.** Check drafts against Sections 1–8 at every stage, not only right before publishing.
- **Test with real readers across expertise levels** before publishing anything substantial — a novice and an expert will snag on different things, and a doc serving both audiences needs both kinds of feedback.
- **Keep evaluating after publication.** Support tickets, "how do I…" questions in chat or code review, dead-end doc-search queries, and abandoned onboarding flows are all signals that something needs revision — treat them as more reliable than a fixed review calendar.

## 10. Using an LLM (including yourself) to help draft technical writing

When you're the one generating a first draft, or advising someone on how to prompt effectively, apply the same discipline to the prompt that you'd apply to the document:

- **State a role, an audience, and a document type** — a prompt like "describe the Frambus app" underspecifies all three; "describe the Frambus app to a new engineer joining the on-call rotation, as a one-page runbook" gives an LLM (or a human ghostwriter) enough to actually aim at.
- **State the reader's goal for reading**: what should they be able to do or know afterward? This shapes what content actually belongs in the draft.
- **Specify style and length constraints explicitly**, or point to a style guide or exemplar document to mimic — don't assume default output length or structure will fit the context.
- **Constrain sourcing** when accuracy matters: ask for the response to be grounded only in attached material rather than general background knowledge, to reduce fabricated specifics.
- **Iterate with more specific prompts rather than accepting a mediocre result** — but also know when a "very good" draft is worth hand-editing the rest of the way rather than chasing a perfect prompt.
- **Always verify LLM output**, including your own: check facts, check that code samples actually run, and check that the result doesn't just sound right but *is* right. LLMs are also good editors — they can flag passive voice, inconsistent terminology, or logical gaps if you ask directly, but the same verification discipline applies to that feedback too.
- **Remember what's lost by skipping the draft struggle yourself**: writing is often how a person (or a model working through a design) actually finds the gaps in their own thinking. If accuracy or original insight matters more than speed, do at least a rough pass of the hard reasoning before delegating polish.

---

## Quick review pass

Run a draft through these four questions before treating it as done:

1. **Relevant** — Does every section serve this reader's actual task? Are assumptions, limitations, and next steps stated clearly enough for someone at the edge of their expertise?
2. **Findable** — Could a reader locate the one thing they came for in under 10 seconds? Does the doc state its scope up front? Do headings work without reading the body?
3. **Understandable** — Active voice, one idea per sentence, familiar or defined words, 3–5 sentence paragraphs, diagrams where prose would be slower, consistent terminology throughout?
4. **Usable** — Has someone outside the writing team — ideally both a novice and an expert — actually tried to use this to complete the task it's meant to support?

A document that passes three of the four isn't done — the principles reinforce each other, and a gap in one usually resurfaces as a support ticket about another.
