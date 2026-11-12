# UI audit fixes — 12 November 2026

The [original audit](UI_Audit.md) is preserved with its before screenshots. This pass implements navigation, dialogue, interaction, layout and presentation fixes. The Aseprite workbook remains the plan for a later hand-drawn art pass.

| Finding | Result |
| --- | --- |
| UI-01: invisible keyboard focus | Shared menus and title scrolling now follow focus. Moving to Phone home reveals its full button. |
| UI-02: inconsistent conversations | All three club characters use the bottom dialogue card with their own names, roles and matching portraits. Service choices transition to the appropriate panel. |
| UI-03: overlapping signs | Removed floor-level E labels; moved shop/bar labels onto furniture or above shelves. The selected target gets gold brackets. Only nearby selected NPC/object captions appear, with doorway/transport landmarks retained. |
| UI-04: Close selected by default | Routine panels focus their first enabled action. Active stock shifts focus a stock choice; bar shifts focus a drink. Delivery panels avoid defaulting to cancellation. The map opens at its heading so the diagram remains visible. |
| UI-05: inconsistent venue detail | Added wood panels, cushions, counter/crate details, plants, trim and frontage windows. Club staff have distinct native pixel silhouettes rather than reused NPC sheets. This is a code-native art pass; the later Aseprite redraw can refine it further. |
| UI-06: sprite grounding | Player, NPCs and stationary venue cast share a visual origin and pixel shadow. Player collision, movement and interaction range remain unchanged. |
| UI-07: large HUD | Reduced panel/dock padding and height. Healthy need descriptions move into tooltips; low/critical advice remains visible. |
| UI-08: unscaled world labels | Target captions now respond to text size. Essential names remain available in the scalable HUD prompt, while decorative signs stay in world space. |
| UI-09: repeated districts | Added glass office architecture for Business District, palm-lined estate scenery for Lekki, and waterfront buildings/railings for Island. Core service interactions remain available. |
| UI-10: unreadable small windows | Enforced a 960×540 minimum window size. Aspect preservation remains enabled; the attempted 640×360 audit resize now stays at the supported minimum. |
| UI-11: text-only phone map | Added a six-landmark neighborhood diagram and current-location marker. District fares have a separate page; contacts give landmark-based directions instead of raw coordinates. |
| UI-12: vague wardrobe choices | Controls name the actual skin tone, hair color and shoe color. Focus stays on the changed property after the page refreshes. |

## Measured layout changes

At 1280×720 with normal text, the top HUD is **88 logical pixels high, down from 122** (about 28% shorter). At 960×540 with 140% text and healthy needs, it is **104 logical pixels high, down from 145**. Critical advice can expand the panel, and remains readable in the stress capture with a billion-naira balance.

The focused Phone home button now sits inside the scroll viewport; the after-capture records `follow_focus: true` and a nonzero scroll position when needed.

## Visual evidence

- [Shop before](ui-audit/screenshots/06-shop.png) / [after](ui-audit/after/screenshots/06-shop.png).
- [Club conversation before](ui-audit/screenshots/08-club-conversation.png) / [after](ui-audit/after/screenshots/08-club-conversation.png).
- [Map before](ui-audit/screenshots/12-phone-map.png) / [after](ui-audit/after/screenshots/12-phone-map.png).
- [Wardrobe after](ui-audit/after/screenshots/11-wardrobe.png).
- [Large-text HUD after](ui-audit/after/screenshots/20-small-large-text-hud.png).
- [Critical needs after](ui-audit/after/screenshots/28-critical-needs-long-cash.png).
- [All 31 after captures](ui-audit/after/screenshots/) and [layout measurements](ui-audit/after/measurements.json).

Run `res://tests/UIAudit.tscn -- --after` graphically to regenerate the after evidence without replacing the original audit captures.

## Validation

The test runner now includes `tests/UIFixes.tscn`, with 31 checks for focus scrolling, primary actions, shared dialogue, distinct cast art, grounding, target markers, text scaling, wardrobe focus, minimum window sizing and district landmarks. The neighborhood test now checks the supervisor through the shared dialogue card. All 17 runner suites passed during the fix pass; the affected UI checks were rerun after final map/contact refinements.

The original save schema is unchanged. New venue cast conversations do not add unsupported relationship or dialogue flags. Native idle art has no new walking animations; the venue cast remains stationary. The visual pass does not replace human playtesting on the target display or a physical controller.
