# NPC dialogue card

NPC conversations use `scripts/ui/DialogueCard.gd`: an undimmed, bottom-centred dark green card with a cream pixel border, an existing sprite portrait, speaker name/role, one passage and at most three response buttons. The HUD remains visible. The interaction prompt and toast are hidden while the card is open and restored afterwards.

E, Enter or controller A advances a passage or confirms the focused choice. Left/right selects a response; mouse selection also works. Escape or controller B closes the conversation. Key repeats do not advance passages. Longer text is split at word boundaries, with smaller passages at larger text settings. Responses appear after the final passage. More than three choices use two responses and a More/Previous button, preserving Bisi's delivery and relationship actions.

The existing modal state still holds player movement and the game clock while talking. The scene continues rendering without a full-screen overlay. Greeting, advice, relationship and parcel handover retain their original gameplay actions. Replies stay in the same card, while shop/job choices open their existing panels. Closing any panel restores input and the previous clock state.

`GameUI.gd` owns transitions between the dialogue card, generic panels and title screen. `UI/hud.gd` suppresses prompts through `set_dialogue_active`; the interaction detector can continue updating prompt text without revealing it during dialogue.

Validation: `tests/DialogueCard.tscn` checks every NPC, portraits, maximum response count, advice/greeting flags, paged choices, E/Enter/Escape input, a single greeting reward, held player position, failed parcel handover, shop transitions and maximum-text layout. It runs from `tools/test.ps1`. Rendered captures are stored in `.godot/review-dialogue.png` and `.godot/review-dialogue-large-text.png` during visual review.
