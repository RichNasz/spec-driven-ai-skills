# HOW: Tab Lifecycle

## Purpose

Defines the standard pattern for finding, creating, clearing, and writing a named tab in a Google Doc. Skills that write output to a specific named tab must follow this pattern.

## Constraints

- Use `addDocumentTab` (not `createTab`) in the `batchUpdate` request body when creating a new tab.
- A tab with `endIndex <= 2` is effectively empty — do not attempt to clear it.
- Always capture the `tabId` from the API response when creating a new tab. Do not assume it matches the title or any predictable value.
- The tab title used for lookup must be an exact string match — case-sensitive.

## Lifecycle Steps

**1. Check for existing tab.**
Read the destination document (without tab content for efficiency if only locating tabs) and search for a tab whose `tabProperties.title` matches the target name exactly.

**2a. Tab does not exist — create it.**
Issue a `batchUpdate` with `addDocumentTab` specifying the desired title. Capture the new `tabId` from `replies[0].addDocumentTab.tabProperties.tabId`. The tab is now empty; proceed to the write step.

**2b. Tab exists and has content (`endIndex > 2`) — clear it.**
Issue a `batchUpdate` with `deleteContentRange` from index 1 to `endIndex - 1` with the tab's `tabId`. Then proceed to the write step.

**2c. Tab exists and is empty — proceed directly to the write step.**

**3. Write content.**
Follow the standard write pattern from `how-gws-document-write`.
