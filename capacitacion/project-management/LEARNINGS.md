# Learnings - Project Management Tools

### 2026-03-21 - Playwright MCP: browser_fill_form requires fields array
**Context:** Filling a form field in Trello's workspace creation dialog
**Learning:** `browser_fill_form` requires a `fields` array parameter with objects containing `name`, `type`, `ref`, and `value`. Calling it with just `ref` and `value` at the top level fails with "expected array, received undefined". Use `browser_type` as a simpler alternative for single text inputs.
**Applies to:** Any Playwright MCP form interaction

### 2026-03-21 - Playwright MCP: react-select comboboxes are not native selects
**Context:** Selecting workspace type in Trello's creation form (react-select component)
**Learning:** Modern web apps use custom combobox components (react-select, etc.) that render as `<input role="combobox">` instead of native `<select>`. Playwright's `selectOption` fails on these. Workaround: click the value-container to open the dropdown, then click the desired option element directly.
**Applies to:** Any Playwright automation interacting with react-select or similar custom dropdown components

### 2026-03-21 - Playwright MCP: click parent container when input is outside viewport
**Context:** Trello's combobox input element was reported as "outside of the viewport" causing timeout
**Learning:** When a Playwright click fails because the target element is "outside of the viewport" despite being "visible, enabled and stable", try clicking a parent/container element instead. In the Trello case, clicking the value-container (`e186`) succeeded where clicking the input (`e188`) timed out repeatedly.
**Applies to:** Playwright automation on pages with overlapping or clipped form elements

### 2026-03-21 - Playwright MCP: browser_drag requires startElement/endElement string params
**Context:** Attempting to drag a Trello card from one list to another using `browser_drag`
**Learning:** `browser_drag` requires `startElement` and `endElement` as string description parameters (e.g., `"Card EPIC-001: Trello Fundamentos"`) in addition to `startRef`/`endRef`. Calling it with only `ref`/`startRef`/`endRef` fails with "Invalid input: expected string, received undefined" for the `startElement`/`endElement` paths. Always provide both the descriptive string and the ref for drag operations.
**Applies to:** Any Playwright MCP drag-and-drop interaction

### 2026-03-21 - Trello card composer: Enter submits and keeps composer open
**Context:** Creating multiple cards in sequence on a Trello board
**Learning:** Trello's card composer (`list-card-composer-textarea` testid) stays open after pressing Enter, allowing rapid sequential card creation without re-clicking "Add a card" between entries. Use `browser_type` with `submit: true` or fill + press Enter to chain card creation efficiently.
**Applies to:** Playwright automation for bulk Trello card creation

