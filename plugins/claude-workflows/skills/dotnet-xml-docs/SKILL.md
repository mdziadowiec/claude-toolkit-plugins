---
name: dotnet-xml-docs
description: Ensure C# and VB.NET types and members are documented with XML doc comments that follow both .NET's XML documentation conventions and plain-language technical-writing principles (ISO 24495 / Google Technical Writing) — clear one-sentence summaries, active voice, consistent terminology, neutral exception wording, and correct, runnable example code. Use whenever writing or reviewing .NET XML doc comments (`<summary>`, `<remarks>`, `<param>`, `<returns>`, `<exception>`, `<example>`) in C# or VB.NET, documenting a public API surface, or asked to improve/tighten existing doc comments.
---

# .NET XML Documentation Best Practices

XML doc comments are a shared .NET/Roslyn feature — C# (`///`) and VB.NET (`'''`) both compile the same XML tag vocabulary into the same output consumed by IntelliSense tooltips and generated reference sites. Every rule below applies to both languages; where the syntax itself differs, both forms are given.

| | C# | VB.NET |
|---|---|---|
| Comment prefix | `///` | `'''` |
| Null keyword | `null` | `Nothing` |
| Boolean literals | `true` / `false` | `True` / `False` |
| `<code>` language attribute | `language="csharp"` | `language="vb"` |

- Public members should be documented with XML comments.
- Document internal (`Friend` in VB.NET) members too when they're complex or not self-explanatory.

## Writing clear, findable prose

Applies to the text inside `<summary>`, `<remarks>`, `<param>`, `<returns>`, `<value>`, and `<exception>` — none of this is language-specific.

- **Lead with the single most important fact in `<summary>`.** Assume the reader may see only the summary in a tooltip and never open `<remarks>`. Keep it to one sentence; move background, implementation details, usage notes, edge cases, thread-safety, and performance characteristics into `<remarks>`.
- **Start `<summary>` with a present-tense, third-person verb, in active voice** ("Gets the connection string," not "The connection string is retrieved"). Watch for the passive-voice tell: a form of "be" plus a past participle.
- **One idea per sentence.** If a sentence needs "and," "or," or a run of items, split it into more sentences or a `<list>`.
- **Cut filler**: "in order to" → "to," "is able to" → "can." State each fact once — don't restate the same constraint across the summary, remarks, and a param description in three slightly different ways; a reader who finds only one version, and it disagrees with the others, has no way to know which is current.
- **Use one term per concept, consistently**, across `<summary>`, `<param>`, `<returns>`, `<value>`, and `<remarks>` for a member — and ideally across the whole type. Don't call the same thing a "handle" in one place and a "token" elsewhere.
- **Define acronyms and jargon on first use** in `<remarks>`, or point to an existing explanation with `<see cref>`/`<seealso>` rather than re-explaining it.
- **Keep pronouns unambiguous.** Keep "it," "this," "that" close to the noun they refer to; repeat the noun instead if more than about five words separate them, or if a second noun could compete for the reference.
- **Avoid "simply," "just," and "obviously."** What's obvious to the author is often not obvious to the caller.
- **Prefer plain, common words over rare or ornate ones** — API docs are read by non-native English speakers and machine-translated more often than most prose.
- **Replace vague qualifiers with concrete facts** where practical: state the actual limit, complexity, or unit instead of "large," "fast," or "small."

## Tag usage for all APIs

- Use `<summary>` for the one-sentence description covered above.
- Use `<remarks>` for everything that doesn't belong in the summary: implementation details, usage notes, limitations, thread-safety, and other context. Name known edge cases and limitations explicitly rather than leaving them to be discovered at runtime.
- Use `<see langword>` for language keywords — `null`, `true`, `false`, `int`, `bool` in C#; `Nothing`, `True`, `False`, `Integer`, `Boolean` in VB.NET. Use the keyword of whichever language the doc comment itself is written in.
- Use `<c>` for inline code snippets.
- Use `<example>` for usage examples — see "Sample code" below for how to write the example itself.
  - Use `<code>` for code blocks, nested inside `<example>`. Add the language with the `language` attribute: `<code language="csharp">` or `<code language="vb">`.
- Use `<see cref>` to reference other types or members inline, in a sentence.
- Use `<seealso>` for standalone references (not inline) in the "See also" section.
- Use `<inheritdoc/>` to inherit documentation from base classes or interfaces — unless there's a meaningful behavior change, in which case document the difference instead.

## Methods

- Use `<param>` to describe method parameters.
  - The description should be a noun phrase that doesn't specify the data type.
  - Begin with an introductory article.
  - If the parameter is a flag enum, start the description with "A bitwise combination of the enumeration values that specifies...".
  - If the parameter is a non-flag enum, start the description with "One of the enumeration values that specifies...".
  - If the parameter is a Boolean, the wording should be of the form "`<see langword="true" />` to ...; otherwise, `<see langword="false" />`." (`<see langword="True" />` / `<see langword="False" />` in VB.NET).
  - If the parameter is passed by reference for output only (`out` in C#, `ByRef` used as an output in VB.NET), the wording should be of the form "When this method returns, contains .... This parameter is treated as uninitialized.".
- Use `<paramref>` to reference parameter names in documentation.
- Use `<typeparam>` to describe type parameters in generic types or methods.
- Use `<typeparamref>` to reference type parameters in documentation.
- Use `<returns>` to describe what the method returns.
  - The description should be a noun phrase that doesn't specify the data type.
  - Begin with an introductory article.
  - If the return type is Boolean, the wording should be of the form "`<see langword="true" />` if ...; otherwise, `<see langword="false" />`." (`True` / `False` in VB.NET).

## Constructors

- The summary wording should be "Initializes a new instance of the <Class> class." — substitute "structure" for "class" when documenting a C# `struct` or VB.NET `Structure`, or "record" for a C# `record`.

## Properties

- The `<summary>` should start with:
  - "Gets or sets..." for a read-write property.
  - "Gets..." for a read-only property.
  - "Gets [or sets] a value that indicates whether..." for properties that return a Boolean value.
- Use `<value>` to describe the value of the property.
  - The description should be a noun phrase that doesn't specify the data type.
  - If the property has a default value, add it in a separate sentence, for example, "The default is `<see langword="false" />`" (`False` in VB.NET).
  - If the value type is Boolean, the wording should be of the form "`<see langword="true" />` if ...; otherwise, `<see langword="false" />`. The default is ...".

## Exceptions

- Use `<exception cref>` to document exceptions thrown by constructors, properties, indexers, methods, operators, and events.
- Document all exceptions thrown directly by the member. For exceptions thrown by nested members, document only the ones users are most likely to encounter.
- State the condition directly and neutrally — what triggers the exception, not who's at fault, and without blaming language. Omit "Thrown if..." or "If..." at the start; e.g., "An error occurred when accessing a Message Queuing API," not "If the queue is inaccessible, this is thrown."

## Lists inside remarks and examples

- Use `<list type="bullet">` for unordered items, `<list type="number">` for items where order matters. Test: if reordering the items changes the meaning, it must be numbered.
- Give the list a lead-in sentence ending in a colon so the reader knows what they're about to see.
- Keep list items grammatically parallel — matching structure, capitalization, and punctuation.

## Sample code in `<example>`

- **Make it correct.** It should compile, actually do what it claims, follow the language's naming and style conventions, avoid known security issues, and be kept up to date as the API changes — don't let snippets rot.
- **Keep it concise.** Include only what's essential to demonstrate the member; strip unrelated setup, but never sacrifice correctness for brevity.
- **Make it understandable.** Descriptive names, no unnecessary cleverness, no deep nesting. Spell out named arguments in examples rather than relying on positional ones, especially for members that aren't obvious from the signature.
- **Comment for the "why," not the "what."** Skip narrating obvious code; focus comments on non-intuitive parts. Readers who copy-paste the snippet take your comments with them.
- **Show the anti-example when a mistake is common.** A short "this throws / this leaks / this deadlocks — here's why" alongside the correct usage can prevent more confusion than a longer correct-only example.
- **Document how to run it** if the snippet isn't trivially runnable as-is: required `using`/`Imports` directives, NuGet packages, or expected output.
- **Match the example's language to the member's declaring language** unless the API is explicitly meant to be shown from both sides (e.g., a cross-language interop scenario) — a VB.NET consumer reading a C#-only example has to mentally translate syntax before they can even evaluate the example's point.

## Self-review checklist

Before treating a doc comment as done:

1. Does `<summary>` alone — without opening `<remarks>` — tell a caller what they need to call this correctly?
2. Active voice, one idea per sentence, no filler, and the same term used everywhere for the same concept?
3. Are parameters, return value, and exceptions documented with the required phrasing patterns above, using the correct language's keyword casing (`true`/`false` vs. `True`/`False`)?
4. Does the `<example>` actually compile and demonstrate the point, not just decorate the doc?
