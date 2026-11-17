# Saving a diagram through the draw.io editor

Verified on Confluence Cloud with the draw.io (Connect) app, November 2026. The app shows a banner that Atlassian
retires this version on 31 January 2027; after the switch to the new app, check these steps again.

Load the Chrome tools in one ToolSearch call: `tabs_context_mcp, navigate, computer, find, read_page,
javascript_tool, browser_batch`. Coordinates below are for a window of about 1568 px wide; take them from a
screenshot, not from this file.

1. **Put the XML on the clipboard.** Only the `<mxGraphModel>…</mxGraphModel>` part, because Edit Diagram shows that
   part:

   ```powershell
   $m = [regex]::Match((Get-Content -Raw <file>), '(?s)<mxGraphModel.*</mxGraphModel>'); Set-Clipboard -Value $m.Value
   ```

2. **Open the page editor:** `https://<site>/wiki/spaces/<space>/pages/edit-v2/<pageId>`, wait a few seconds.
   Blocks render lazily: scroll to the heading above the diagram (`find` + `scroll_to`) before looking for it.

3. **Select the diagram block.** Clicking or double-clicking inside a diagram opens only the read-only viewer (a black
   bar with ✓ and ✕ and a zoom toolbar); close it with ✕. Instead:
   - click just left of the diagram's left edge, a few pixels outside the frame, so the block's drag handle (⠿) shows
     at the block's top-left corner;
   - click the drag handle. The block gets a blue outline and a block menu opens. The menu holds **Delete**: never
     click into it;
   - press Escape to close the menu (press it again if the menu stays open). The block stays selected.

4. **Click the block's Edit button through the page script**, after checking that the selected block is the right
   diagram. The button can sit outside the visible area, and a coordinate click can land on the diagram instead:

   ```js
   const sel = document.querySelector('.ProseMirror-selectednode');
   const ok = sel && sel.outerHTML.includes('<the number in the diagram name>');
   const b = [...document.querySelectorAll('button')].find(x => x.textContent.trim() === 'Edit' || x.getAttribute('aria-label') === 'Edit');
   if (ok && b) { b.click(); 'clicked' } else { 'not clicked: ' + (sel ? 'other block' : 'nothing selected') + ', button ' + !!b }
   ```

   If the button is missing, wait two seconds and press Escape once more; the floating toolbar appears only after the
   block menu has closed. The editor needs 5–10 seconds to load.

5. **Replace the XML.** Menu Extras > Edit Diagram. Click into the text area, `ctrl+a`, then check the clipboard
   once more (`Get-Clipboard -Raw`: length and a label you expect) — the user may have copied something in the
   meantime — and `ctrl+v`. Click **Apply**; the drop-down next to it has no replace mode because Apply replaces.
   If draw.io answers "Invalid input … Unexpected characters", the clipboard held something else: confirm the error,
   copy again, paste again.

6. **Check the result.** Close the retirement banner, click an empty spot, and use `computer` `zoom` on the canvas.
   For a large diagram set the zoom to 75 % (zoom box top left) and move with Home and PageDown; the mouse wheel zooms.
   Look at every changed box and arrow: text inside its box, no label over a box edge, no arrow hidden under another,
   boxes in a row on one line.

7. **Save in draw.io:** the **Publish** button at the top right. draw.io writes the XML, the preview, its record and
   the new revision into the page draft, and closes. If an old viewer window remains, close it with ✕.

8. **Confirm the revision in the editor** when the draft API does not show it yet:

   ```js
   const hit = [...document.querySelectorAll('.extensionView-content-wrap')].find(n => n.outerHTML.includes('<number>'));
   [...hit.outerHTML.matchAll(/revision(?:&quot;|")?\s*[:=]\s*(?:\{(?:&quot;|")value(?:&quot;|")\s*:\s*)?(?:&quot;|")?(\d+)/g)].map(x => x[1])
   ```

9. **Update the page** (the blue button top right) only after the user approved. Several diagrams of one page can be
   saved first and published with one Update.

Never type credentials into Confluence or draw.io; if the session asks for a login, ask the user to log in.
