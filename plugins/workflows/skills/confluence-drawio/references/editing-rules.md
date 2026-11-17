# Editing rules for page bodies and diagram XML

Give these rules to every subagent that drafts a page.

## Page body (ADF)

- Edit with a Python script that loads the JSON, changes nodes and writes the whole document. Keep the script: it
  documents the change and can be re-run after a merge.
- Leave every node you do not change exactly as it is, including `attrs.localId` and all marks.
- Marks of type `annotation` are the page's **inline comments**. Never drop one; when you rewrite a text node that
  carries one, put the mark on the replacement text. `review_page.py` reports a lost comment by id.
- Leave every `extension` node unchanged. Diagram revisions are written by the draw.io editor, and other macros are
  outside this skill.
- New nodes get no `localId`. Use valid ADF only: paragraph, heading, bulletList/orderedList/listItem,
  table/tableRow/tableHeader/tableCell, codeBlock with `attrs.language`, panel, text with the marks `code`, `strong`,
  `em`, `link`.
- A page title changes only through `Publish-ConfluencePage.ps1 -Title`; the body has no title. Confluence keeps old
  links working after a rename, but links on other pages keep their old text: update those too.

## Writing the text

- Match the page's voice: plain English, present tense, short sentences, active voice, names in code marks.
- Describe the system as it is. No history or work status: not "was renamed", "no longer", "now", "since PR …". A page
  whose subject is the changes themselves is the exception.
- Keep the structure and headings unless a section's subject is gone; then replace it with the section on the current
  mechanism.
- Code examples must compile against the code the page describes; take them from real code. When an example shortens
  a list, say so in the code (`/* , … the other entries */`).
- Every claim needs evidence in the code (file:line) when you draft it; put the evidence in a change list next to the
  draft, not on the page.

## Diagram XML

- Keep every cell id, style and geometry that does not need to change. Change labels first; add or remove cells only
  when the content requires it.
- Labels are HTML inside the `value` attribute: `&lt;br&gt;` breaks a line, `&lt;b&gt;`/`&lt;i&gt;` format, and
  `<hr size="1">` separates a UML box's header from its members. Keep the escaping the file already uses.
- Text must fit its box: about 6.5 px per character at font size 12 and 15 px per line. Widen or heighten the box, or
  shorten the text, rather than let it touch the edges. Add `spacingLeft=6;spacingRight=6;` to a tight box.
- A label on a short edge covers the boxes at both ends: shorten the label, or make the gap wider.
- Two edges between the same boxes overlap as one line: route one around with exit and entry points and waypoints,
  for example `exitX=0.5;exitY=1;entryX=0.5;entryY=1;` plus `<Array as="points"><mxPoint x=".." y=".."/></Array>`
  inside its `mxGeometry`.
- Boxes that form a flow sit on one line (same `y` for the same height), so the arrows between them are straight.
- New cells go into free space; move neighbours rather than overlap them.
- Validate: the XML parses, and every edge's `source` and `target` exist.
