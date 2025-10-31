# TODO: Optimize AI Suggestions UI for Mobile Performance

## Steps to Complete
- [x] Create a new widget `SuggestionChips` in `lib/components/suggestion_chips.dart` that uses `ValueNotifier` for reactive updates to isolate rebuilds.
- [x] Modify `lib/pages/chat_page.dart` to integrate `SuggestionChips` and manage the `ValueNotifier` for suggestions.
- [x] Modify `lib/pages/group_chat_page.dart` to integrate `SuggestionChips` and manage the `ValueNotifier` for suggestions.
- [x] Update suggestion generation and selection logic in both ChatPage and GroupChatPage to use the notifier instead of `setState`.
- [ ] Test the changes on mobile to ensure the reload/lag issue is resolved in both individual and group chats.

## Information Gathered
- The `ChatPage` and `GroupChatPage` widgets rebuild entirely when `setState` is called for suggestions, causing performance issues on mobile devices.
- Suggestions are generated offline and displayed using `ActionChip` in a `Wrap` widget.
- Interactions like generating suggestions or sending messages trigger full UI rebuilds, leading to perceived "reload" on phones.

## Plan
- Extract the suggestions display into a separate `SuggestionChips` widget that uses `ValueNotifier<List<String>>` for reactive updates.
- This prevents the entire pages from rebuilding when suggestions change, improving mobile performance.
- Update both ChatPage and GroupChatPage to instantiate and manage the notifier, passing it to `SuggestionChips`.

## Dependent Files to be Edited
- `lib/pages/chat_page.dart`: Integrate the new widget and update logic.
- `lib/pages/group_chat_page.dart`: Integrate the new widget and update logic.
- New file: `lib/components/suggestion_chips.dart`: Create the isolated suggestions widget.

## Followup Steps
- After edits, run the app on a mobile device and test the suggestion button and sending messages in both individual and group chats to confirm no lag or reload occurs.
- If issues persist, investigate further (e.g., check for other setState calls or optimize message stream).
