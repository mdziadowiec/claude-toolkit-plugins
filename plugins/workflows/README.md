# workflows

Workflow and coding-discipline skills for Claude Code — pure prompt skills with **no external
dependencies**. Part of the
[claude-toolkit-plugins](https://github.com/mdziadowiec/claude-toolkit-plugins) marketplace.

## Install

```
/plugin marketplace add mdziadowiec/claude-toolkit-plugins
/plugin install workflows@claude-toolkit-plugins
/reload-plugins
```

## Skills

| Skill | Invoke as | What it does |
|---|---|---|
| crisp | `/workflows:crisp` | Switches to shorter, more direct responses; cuts filler and pleasantries |
| karpathy | `/workflows:karpathy` | Coding discipline — think before coding, simplicity first, surgical changes, goal-driven execution |
| handoff | `/workflows:handoff` | Produces a structured handoff note so a fresh session can continue without re-deriving context |
| doc-coauthoring | `/workflows:doc-coauthoring` | Structured workflow for co-authoring docs, proposals, specs, and decision docs |
| technical-writing | `/workflows:technical-writing` | ISO 24495 plain-language + Google Technical Writing rules for drafting/reviewing developer docs |
| dotnet-xml-docs | `/workflows:dotnet-xml-docs` | C#/VB.NET XML doc comment conventions (`<summary>`, `<param>`, `<exception>`, ...) merged with technical-writing principles for clear, consistent prose |
| code-comments | `/workflows:code-comments` | Inline code comment rules (any language): when to comment at all, always English, no refactor/session narration, TODO conventions, staleness hygiene — applies automatically |
| error-messages | `/workflows:error-messages` | Google's Writing Helpful Error Messages rules: cause, offending value, limit, fix, example, concise wording, audience, consistent terms, tone, error codes — applies automatically when writing error text |

Skills are model-invoked: Claude activates them automatically when your request matches (e.g.
"be brief" → crisp, "keep it surgical" → karpathy), or you can trigger one explicitly with its
`/workflows:<skill>` name.
