---
name: technical-writing
description: Rules and checks for writing or reviewing technical documentation — READMEs, API references, runbooks, architecture docs, tutorials, release notes, code comments, design docs, or any developer-facing text. Merges ISO 24495 plain-language principles with Google's Technical Writing One and Two courses (words, acronyms, pronouns, active voice, sentence and paragraph structure, lists/tables, punctuation, audience analysis, document organization and headings, illustrations, sample code, self-editing, responsible LLM-assisted drafting and summarizing). Use this whenever asked to draft, edit, review, simplify, proofread, or give feedback on technical writing, even if the person doesn't name a standard or say "plain language" — phrases like "make this README clearer," "review my API docs," "why is this doc confusing," "tighten this up for devs," "fix the punctuation in this guide," or "write a runbook for X" should all trigger it. When the user wants to co-author a substantial new document from scratch (PRD, RFC, design doc, proposal) through several rounds of discussion, the doc-coauthoring skill runs that process and applies these rules. Not for the text of error messages (exceptions, validation errors, CLI/API error output); the error-messages skill covers those.
---

# Technical Writing

A merged rule set for drafting and reviewing technical documentation. It combines two sources that approach the same problem from different angles:

- **ISO 24495** (plain language) — four governing principles: a document should be **relevant**, **findable**, **understandable**, and **usable**. Part 3 adds guidance for writing about specialized subject matter for audiences of mixed expertise, which is exactly the situation most technical docs are in (a README read by both a first-time user and the maintainer).
- **Google's Technical Writing One and Two** — a practical, example-driven course on word choice, sentence and paragraph craft, punctuation, document structure, illustrations, sample code, self-editing, and responsible LLM use, written for software engineers and technical writers. Its overriding rule: **clarity takes precedence over all other rules.** When two guidelines below conflict in a specific sentence, pick whichever reading is least ambiguous for this reader.

Apply this whenever drafting new technical content or reviewing/editing existing content. When reviewing someone else's draft, don't just list every deviation — prioritize the changes that would most help *this* reader, fix organization before sentence-level style, and explain the "why" behind a suggested edit rather than just marking it wrong. If the user is starting a substantial document from scratch and wants to build it together, offer the `doc-coauthoring` workflow for the process and keep applying these rules inside it.

The sections below are organized by where they apply, from planning through to editing. Skip to what's relevant: fixing a paragraph doesn't require re-deriving the audience, but drafting a new document benefits from starting at the top.

---

## 1. Know the audience and scope before drafting

Good documentation is measured against a gap: `what the reader needs to know − what the reader already knows`. You can't close that gap without knowing both sides.

- **Identify the reader's role** (software engineer, ops/on-call, PM, integrator, end user, new team member) and their **proximity** to the subject — someone can be an expert engineer and still be a total newcomer to *this* codebase or *this* concept. Proximity fades with time too: even experienced engineers forget details of a project they haven't touched in a year. As the audience widens beyond your own team, assume you must explain more — your team's abbreviations and data structures are not common knowledge.
- **Answer four questions before you outline**: Who is the reader? What is their goal — why are they reading this? What do they already know? What should they know or be able to do afterward?
- **Write down what the reader needs to learn.** For a how-to or tutorial, that's a list of tasks ("list hotels by price"), in the order the reader must master them if one depends on another. For a design doc, it's a list of things to understand ("three reasons X outperforms Y") rather than tasks.
- **Identify the reading context**: mid-incident under time pressure, or calmly onboarding? On a phone, in a terminal, in an IDE tooltip?
- **Watch for the curse of knowledge** — the more expert you are, the easier it is to forget what a newcomer doesn't yet know, and to make passing reference to subtle interactions you don't stop to explain. If you're documenting something you built, assume you need to explain more than feels natural.
- **State the document's scope up front**: what it covers, and — just as important — what it explicitly does *not* cover. Limit the non-scope to topics the reader would *reasonably expect* the document to cover; listing unrelated topics is noise. A stated non-scope prevents both reader confusion and writer scope creep; if your draft starts wandering into the non-scope, either refocus the document or revise the scope statement, and when reviewing a draft, delete sections that don't serve the scope.
- **State the audience and prerequisites**: name the roles you're writing for, any required background ("assumes familiarity with matrix multiplication"), and any prerequisite reading ("read X before this document"). Link to resources where readers can brush up.
- **Select content honestly**: include what the reader needs, cut what only serves the writer's convenience, and never omit information the reader needs to act safely or correctly.
- **For specialized/technical subject matter** (ISO 24495-3's extension — directly relevant to engineering docs): match implementation depth to reader expertise; state your assumptions and how information was validated (tested on what, under what conditions); name known edge cases and limitations explicitly, including what's *not yet known* or confirmed ("known unknowns"); give the reader the "so what," not just the facts; state the concrete next action where relevant; list supporting material needed (glossary, related docs, changelog); and present information with integrity — report limitations fairly, don't cherry-pick favorable results, disclose conflicts of interest (e.g., vendor-authored comparisons).

## 2. Structure for findability

A reader should be able to tell fast whether a document serves their purpose, and locate the one thing they came for.

- **Lead with the most important message.** Summarize key points at the very start — assume busy readers may only read the first paragraph. Keep minor details (what *didn't* change, history) out of that opening. Page one is the hardest to write; expect to revise it many times.
- **Introduce long documents with**: what the document covers, what prior knowledge the reader needs (with links), and what it doesn't cover. Keep the introduction short enough to maintain — don't try to cover everything in it.
- **Order information by the reader's task**, not by your implementation history. For instructions, use the order the reader will actually perform steps. Put common cases before edge cases. Put conditions before instructions ("If the build fails, run X", not "Run X if the build fails"), and if skipping a step risks damage or data loss, put the warning *before* the instruction.
- **Explain why before asking the reader to do something.** A tutorial step makes more sense when the reader knows what it achieves. Alternating a concept with a practical step that applies it is an especially engaging pattern.
- **Compare new ideas to what the reader already knows.** Most technical work is evolutionary, not revolutionary — anchoring a new concept to a familiar one ("like X, except...") shortens the distance to understanding.
- **Use headings that predict content**, phrased around the reader's task ("Creating the site," "What to do if the migration fails") rather than unfamiliar tools or internal terminology ("Running the carambola command"). Put at least a sentence or two of orienting text under each heading — never stack a level-3 heading directly under a level-2 heading.
- **Choose single-document vs. multi-document structure deliberately.** How-to guides, overviews, and conceptual guides aimed at newcomers work better as shorter documents. In-depth tutorials, best-practice guides, and command-line references can be longer, especially for readers with some experience. Long reference pages are scanned, not read; even a long narrative tutorial can benefit from splitting into parts.
- **Outline before drafting long documents** (or write free-form, then reorganize against an outline). An outline reveals gaps and lets you move topics around cheaply. Keep each outline item to one concept or one task, place information where it becomes relevant (project history goes at the end, as a link, not in the getting-started section), and share the outline with co-authors and reviewers before drafting.
- **Disclose information progressively.** Introduce new terms and concepts near the instructions that need them, not all up front. Break walls of text with tables, diagrams, lists, and headings. Split a long series of steps into shorter lists of sub-tasks. Start with simple cases and layer in complexity.
- **Add navigation**: introduction and summary sections, a logical progression of headings, a table of contents for anything long, links to related or deeper material rather than inlining everything, and links to what to learn next.
- **Keep supplementary information separate** from the must-know steps — background, rationale, and history belong in an appendix, an ADR, or a linked doc, not blocking the main flow.
- **For specialized/technical subject matter**: give an informative summary and explicit scope statement at the start of any long or complex document; provide more than one way to reach the same information (TOC, search, cross-links), since readers often arrive mid-task from a search hit rather than reading start to finish.

## 3. Choose words deliberately

- **Define unfamiliar terms** the first time they appear, or link to an existing good explanation — don't reinvent a definition that already exists elsewhere. If the document introduces many new terms, collect them in a glossary.
- **Use one term per concept, consistently**, for the entire document (and ideally across your whole documentation set). Renaming a concept partway through is as disruptive to a reader's mental model as renaming a variable mid-function is to a compiler — and readers who see two near-synonyms assume you mean two different things. If a name is long, introduce the short form once, explicitly ("Protocol Buffers (or protobufs for short)"), then use only the short form.
- **Introduce acronyms properly**: on first use in a document or section, spell out the full term followed by the acronym in parentheses, with both in bold — **Telekinetic Tactile Network (TTN)** — then use the acronym consistently afterward. Don't cycle back and forth between the long and short forms. Only define an acronym if it's both significantly shorter than the full term *and* used many times; readers must mentally expand a newly learned acronym, so one used two or three times costs more than it saves.
- **Watch ambiguous pronouns** — "it," "they/them/their," "this," "that." Use a pronoun only after introducing its noun, keep it close to that noun (rule of thumb: if more than about five words separate them, repeat the noun instead), and never let a second noun get inserted in between. If it's not obvious what "this" refers to, either replace it with the actual noun or put a noun right after it ("this user ID" beats a bare "this").
- **Prefer simple, common words over rare or ornate ones** — a large share of technical readers read English as a second language, and plain vocabulary travels better internationally and translates more reliably than obscure or obsolete English.
- **Stay culturally neutral.** Avoid idioms ("a piece of cake," "sticky wicket," "be that as it may") and culture-specific references (sports metaphors, regional slang, religious terms used as slang like "kosher"). Idioms are a form of the curse of knowledge — their nonliteral meaning is invisible to native speakers — and machine translation handles them worse than plain English.
- **Format code-related text in code font**: commands, flags, file names, paths, variables, functions, and literal values.

## 4. Write clear, active, concise sentences

This is the area where ISO's "understandable" principle and Google's course overlap most, and where the specific techniques compound well together.

- **Prefer active voice; use passive sparingly**: actor + verb + target ("The script deletes temporary files"), not target + verb + actor ("Temporary files are deleted [by the script]"). Active voice is shorter, names who's responsible, and doesn't force the reader to mentally flip the sentence around; passive that omits the actor forces the reader to guess. Watch for the passive-voice tell: a form of *be* (is/are/was/were) plus a past participle (often *-ed*, but also irregular forms like *known*, *frozen*, *sat*), frequently followed by a preposition ("was generated by"). Check each clause of a multi-clause sentence separately. Sentences starting with an imperative verb ("Open the file," "Click Submit") are active even without a stated actor — the implied actor is "you."
- **Choose strong, specific verbs.** Weak, generic verbs (forms of *be*, "occur," "happen") often signal that a sentence's real actor is missing or that it's passive. "The exception occurs when dividing by zero" → "Dividing by zero raises the exception." A form of *be* is sometimes the right verb — don't contort a sentence to remove every one.
- **Avoid "There is / There are" openers.** They pair a generic noun with a generic verb. Delete the opener and promote the real subject ("The `x` variable stores..."), move a subject from the end to the front ("There are two facts you should know" → "You should know two facts"), or create a subject if none exists ("There is no guarantee the updates arrive in order" → "Clients might not receive the updates in order").
- **One idea per sentence.** If a sentence contains "and," "or," a list of items, or multiple independent clauses, consider whether it should become two sentences or a bulleted/numbered list.
- **Cut filler.** "In order to" → "to"; "is able to" → "can"; "at this point in time" → "now"; "determine the location of" → "find"; "causes the triggering of" → "triggers"; "provides a detailed description of" → "describes." Shorter documentation reads faster, is easier to maintain, and has fewer places to go wrong. Say each fact once — a reader who finds two versions that disagree can't know which is current.
- **Scrutinize subordinate clauses** (introduced by "which," "that," "because," "whose," "until," "unless," "since"). Ask whether a clause *extends* the main idea or *branches off* into a separate one — if it branches, split it into its own sentence. In US English, use "which" for a nonessential clause (comma before it) and "that" for an essential one (no comma). Test: read it aloud — if you hear a pause before the clause, use "which."
- **Replace vague adjectives/adverbs with numbers.** "Runs screamingly fast" tells the reader nothing verifiable; "runs 225–250% faster" does. Don't mix marketing language or sales pitches into educational material — when readers expect education, give them education.
- **Write to the reader in second person**: "you," not "we" or an impersonal third person.

## 5. Punctuate for the least ambiguous reading

Technical writing picks the least ambiguous option, even where general English allows several. Use a style guide for anything not covered here.

- **Commas**: put one where a reader naturally pauses. Use the serial (Oxford) comma before the last item of an inline list ("C++, Python, and Java") — or better, turn the inline list into a bulleted list. Put a comma between a condition and its consequence ("If the program runs slowly, try the `--perf` flag"). A pair of commas can hold a short definition ("Python, an easy-to-use language, ..."). Comma after an introductory transition ("Consequently, clients ...").
- **No comma splices**: don't join two independent sentences with only a comma. "The service restarts, it reloads the cache" → "The service restarts. It reloads the cache."
- **Semicolons** unite two highly related thoughts; a period separates distinct ones. Both sides of a semicolon must be complete sentences, and the sentence should still make sense with the two sides swapped. Put a comma after a transition that follows a semicolon ("...; however, ..."). Don't use semicolons to separate items in an inline list — use commas.
- **Em dashes** mark a longer pause than a comma, or set off a digression in a pair ("Protocol Buffers—often called protobufs—encode..."). They're optional; commas often work too.
- **En dashes**: don't use them (Google style). **Hyphens** join compound modifiers ("floating-point feature," "decision-making system"); when unsure, check a dictionary, glossary, or the house style guide.
- **Colons**: end the sentence that introduces a list or table with a colon. A colon can also introduce an inline list, but not every inline list needs one.
- **Parentheses** signal non-critical asides — keep them to a minimum, since text that isn't critical may not belong at all. If the parentheses hold a whole sentence, the period goes inside; if they end a sentence, the period goes outside.

## 6. Build lists, tables, and paragraphs that scan well

- **Look for prose that wants to be a list.** Technical readers scan lists far faster than paragraphs.
- **Use a bulleted list for unordered items, a numbered list for ordered ones.** Test: if reordering the items changes the meaning, it must be numbered; if not, it should be bulleted. Nest lists when items group naturally (e.g., tasks under "At work" / "After work").
- **Convert embedded ("run-in") lists inside sentences into real lists.** A long sentence with "or," or a string of items stuffed into it, is usually a list trying to escape.
- **Keep list items parallel**: matching grammar, logical category, capitalization, and punctuation — and voice (one passive item in an active list breaks it). The first item sets the pattern readers expect. Start numbered steps with imperative verbs consistently ("Stop the server," "Edit the file," "Restart the server") — don't mix commands with descriptive statements ("The process stalls").
- **Punctuate list items consistently**: start each item with a capital letter; end items that are complete sentences with a period; leave fragments unpunctuated.
- **Give every list and table an introductory sentence** ending in a colon, so the reader knows what they're about to see (the word "following" is a reliable, if optional, signal: "the following table summarizes...").
- **In tables**, label every column with a meaningful header, keep cell content short (more than about two sentences in a cell means it belongs in another format), and keep each column's data type consistent down the column. Wide tables can render badly on phones; check the target form factor.
- **Write a strong opening sentence for every paragraph** — it establishes the paragraph's central point, and busy readers often read only this sentence before deciding whether to continue. A misleading opener (one that names a side topic) sends readers the wrong way. A rhetorical question can also work as an opener.
- **Keep each paragraph on a single topic.** Don't preview what a later section will cover or recap an earlier one. Delete or relocate any sentence that drifts from the topic, even if it's individually well-written.
- **Aim for 3–5 sentences per paragraph**; readers avoid paragraphs of more than about seven. Split long ones. A document full of one-sentence paragraphs signals disorganized structure, not good pacing — combine related one-liners or convert them to a list.
- **A good paragraph answers what, why, and how**: what you're telling the reader, why it matters to them, and how they should use it (or how they can know it's true).

## 7. Use diagrams, screenshots, and illustrations purposefully

Any graphic makes readers *like* a document more, but only instructive graphics help them *learn*. Decorative or merely pretty images (a chain to illustrate a linked list) can mislead.

- **Write the caption before making the illustration**, then build the illustration to match the caption. A good caption is brief, states the takeaway (what should the reader remember?), and focuses attention — especially in a busy image. By convention, the caption goes below the figure. Check that the image actually shows everything the caption claims.
- **Constrain how much a single diagram tries to say.** Rule of thumb: if explaining it would take more than one paragraph (or more than about five bullet points), split it — show the big picture of subsystems first, then a separate, zoomed-in diagram per subsystem (or progressively add detail across a sequence).
- **Focus the reader's eye deliberately** — a callout, arrow, or highlighted shape that breaks the visual pattern tells the reader where to look, and lets the prose refer directly to it instead of describing where to look.
- **Treat illustrating as re-illustrating.** Revise like a draft and ask: Can I simplify it? Should it be two images? Is the text readable, with enough color contrast to pass accessibility checks? Do bright colors pull attention from the point? Do arrows have one clear direction and labels where the meaning isn't obvious? What's the takeaway?
- **Export diagrams as SVG** where possible so they scale cleanly across screen sizes.
- **Use images and diagrams anywhere they'd communicate a process, comparison, or structure faster than prose would** — and only where they carry real information, not for decoration.

## 8. Write sample code like it's a teaching tool, not scratch work

Good sample code is often the best documentation; programmers care about the code more than the prose around it.

- **Make sample code correct**: it should build without errors, do what it claims, follow language conventions, and be as production-ready as possible (no security vulnerabilities). Samples teach readers how to use your product, so show the approach your team considers best. Test and maintain samples like production code — systems change and samples silently break. Snippets degrade fastest because they're tested least.
- **Don't reuse unit tests as samples.** A test's goal is to test; a sample's only goal is to educate.
- **Keep it concise.** Include only what's essential to the point being taught — a `malloc` snippet, not the Linux source tree — but never use bad practices to shorten code; correctness beats brevity. If you trade away production-readiness for clarity, say so in a comment.
- **Make it understandable**: descriptive names, no clever tricks, no deep nesting. Spell out parameter names in examples (`Level(rank=5, dimension=28, opacity=48)`, not `Level(5, 28, 48)`), especially for newcomers to the API. Highlight a key line in bold or color sparingly — if everything is highlighted, nothing is.
- **Comment the non-obvious, not the obvious.** Keep comments short but prefer clarity over brevity; remember that what's obvious to you may not be to a newcomer. For very experienced readers, explain *why* the code does something rather than *what* it does. Readers who copy-paste a snippet take its comments with them, so put anything that belongs in the pasted code *in* the comment; put long or tricky conceptual explanation in prose *before* the sample.
- **Make it reusable**: state every dependency and setup step needed to run it, make it extensible, and consider side effects if it's pasted into someone else's program — nobody wants insecure or grossly inefficient code.
- **Show the anti-example when a mistake is easy to make** — a short "this is wrong, and here's why" next to the correct version (e.g., bash forbids spaces around `=`) can save more confusion than a correct-only example.
- **Sequence a set of examples by complexity**: start at "Hello World" and build through simple, moderate, and complex samples rather than jumping straight to the advanced case.
- **Document how to run the sample** — libraries to install, environment variables, IDE settings — and describe the expected output or result, especially when the code is hard to run.

## 9. Keep tone respectful and the whole document cohesive

- **Address the reader directly** ("you," "your service") instead of "we" or an impersonal third person.
- **Match formality to the audience and document**: a contributor guide recruiting volunteers can be conversational; an enterprise developer guide is usually more formal. Either way, it should sound natural read aloud.
- **Avoid "simply," "just," and "obviously"** in instructions — what's obvious to the author is frequently not obvious to the reader, and the word reads as condescending the moment a step turns out not to be simple.
- **Keep terminology, tone, and formatting consistent** across sentences, sections, and — ideally — your whole documentation set. The same field, button, or concept should have the same name in the README, the reference doc, and the UI.
- **Treat the document as a system**: each element — a paragraph, a diagram, a code sample — should be clear on its own *and* work together with the others. The work of writing is untangling the dependencies among the parts of a topic and presenting them in a logical stream the reader can follow.
- **Attribute and source claims a reader can't verify themselves.** Mark reused or adapted content, and identify the author/team so readers can judge expertise, currency, and potential conflicts of interest (e.g., an internal benchmark vs. an independent one).

## 10. Self-edit before calling it done

A first draft is a starting point, not a deliverable; budget real time for revision. Use several of these, not just one:

- **Adopt (or ask about) a house style guide** if one exists for the project or organization, and default to its conventions over personal preference. For small projects without one, the Google developer documentation style guide's highlights are a reasonable default.
- **Build a lightweight persona** for the target reader (role, end goal such as "restore the database," assumed background such as "knows Python, runs Linux, comfortable on the command line") and re-read the draft as that person. Tell readers the assumptions you made. Don't over-fit to one or two personas at the expense of everyone else who'll read the doc.
- **Check the draft against its own introduction and outline**: does the overview accurately describe what the document covers, and did you cover everything you meant to? Treat this as documentation QA.
- **Read it out loud** (or run it through a screen reader). Awkward phrasing, overlong sentences, and missing commas reveal themselves in a way silent reading often misses.
- **Come back to it later with fresh eyes** — even an hour of distance surfaces things a tired brain glossed over.
- **Change the context**: a different font, size, or color, a printed copy, a different device — anything that breaks the visual pattern your eyes have gotten used to.
- **Get a peer reviewer** for specific, constructive comments. They don't need deep subject-matter expertise, but they do need to know the style conventions you're both working from.
- **Evaluate continually, not just at the end.** Check drafts against Sections 1–9 at every stage, not only right before publishing.
- **Test with real readers across expertise levels** before publishing anything substantial — a novice and an expert will snag on different things, and a doc serving both audiences needs both kinds of feedback.
- **Keep evaluating after publication.** Support tickets, "how do I…" questions in chat or code review, dead-end doc-search queries, and abandoned onboarding flows are all signals that something needs revision — treat them as more reliable than a fixed review calendar.

## 11. Using an LLM (including yourself) to help draft technical writing

When you're the one generating a draft, or advising someone on how to prompt effectively, apply the same discipline to the prompt that you'd apply to the document. A good prompt is itself good technical writing: if a human received it, would they know exactly what's being asked?

**Drafting:**

- **State a role, an audience, a document type, and a goal** — "describe the Frambus app" underspecifies all four; "You are a senior engineer. Describe the Frambus app to new engineers joining the on-call rotation, as a one-page runbook. Afterward they should be able to restart the service and triage the top three alerts" gives an LLM (or a human ghostwriter) enough to aim at.
- **Ask for a section, not a whole long document.** "The section of the programmer's guide that explains how to change a reservation" beats "a complete programmer's guide."
- **Specify style, structure, and length explicitly** (e.g., "intro paragraph, then a table of one-line bug summaries, then a subsection per bug"), or attach a style guide or exemplar document to mimic. LLM output defaults to long, bullet-heavy text — ask for brevity ("limit to the three most important items"), and check the result, since LLMs miscount.
- **Supply context and constrain sourcing**: an LLM only knows its training data, any retrieval, and what you give it — it doesn't know the function you wrote this morning. Attach source code, docs, transcripts, or emails, and say "only use information from the attached material" to reduce fabrication. Beware that an LLM treats attachments as factual: it may document a bug in attached code as a feature.
- **Iterate** — rephrase more specifically, or simply reissue the prompt, since responses vary. But when a response is very good, hand-editing the rest of the way is often faster than chasing a perfect prompt.
- **Remember what's lost by skipping the draft struggle yourself**: "One writes to know what one is thinking." Writing a design doc is how its author finds the unsolved issues; clear technical writing is the byproduct of clear technical thought. If accuracy or original insight matters more than speed, do at least a rough pass of the hard reasoning before delegating polish.

**Revising, formatting, and summarizing:**

- **Fix organization before grammar and style.** A reorganization prompt needs context: what the document is, who it's for, what they already know, and specific questions ("Should X come earlier?") — "reorganize this" forces the model to guess.
- **Then copy edit and style-check** with targeted prompts: find grammar, punctuation, and spelling errors; identify (or rewrite) passive voice; list deviations from Google's Technical Writing One principles for a named audience; or take a reviewer role ("You are a CS professor reviewing this draft...") to hunt for factual mistakes and logical flaws. LLMs are strong critics, even of their own output.
- **For format conversion**, give the document, the target format, and specific requirements ("convert to Markdown; use only level-2 and level-3 headings"), or name the style guide to conform to.
- **For summaries**, state the style, target audience, purpose, and optionally tone ("one sentence, for engineers deciding whether to take the course; engaging but not marketing"). To match a house style, include two or three exemplar summaries (few-shot prompting). A good summarization prompt is often longer than the summary. Consider whether an image or diagram would summarize better than text.
- **Always verify LLM output**, including your own: check facts, check that code samples actually run, and check passages that don't "feel" right. Apply the same verification to an LLM's editing feedback.

---

## Quick review pass

Run a draft through these four questions before treating it as done:

1. **Relevant** — Does every section serve this reader's actual task? Are assumptions, limitations, and next steps stated clearly enough for someone at the edge of their expertise?
2. **Findable** — Could a reader locate the one thing they came for in under 10 seconds? Does the doc state its scope, non-scope, and audience up front? Do task-based headings work without reading the body, and does each have text under it?
3. **Understandable** — Active voice, strong verbs, one idea per sentence, defined terms and acronyms used consistently, unambiguous pronouns, clean punctuation (no comma splices, serial commas, no en dashes), 3–5 sentence paragraphs, parallel lists, diagrams where prose would be slower?
4. **Usable** — Has someone outside the writing team — ideally both a novice and an expert — actually tried to use this to complete the task it's meant to support? Do the code samples run as shown?

A document that passes three of the four isn't done — the principles reinforce each other, and a gap in one usually resurfaces as a support ticket about another.
