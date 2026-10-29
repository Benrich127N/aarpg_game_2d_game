# Release QA — 0.1.0 Windows candidate

Date: 2026-10-29. Baseline: Godot 4.4.1; Windows x86_64; Compatibility/OpenGL 3.3. Tested graphics device: NVIDIA GeForce MX350, driver 512.77.

## Results

| Check | Result |
| --- | --- |
| Steps 3–5 movement, clock, pause and HUD regression | PASS |
| Steps 6–15 integration | 113 checks PASS |
| Steps 16–19 events, navigation, customization, phone, audio/settings, persistence | 74 checks PASS |
| Independent source-process save write / read | PASS / PASS |
| Windows template export | Exit 0 |
| Standalone headless write / reopen | PASS / PASS; exit 0; final logs clean |
| ZIP extracted into isolated folder; rendered write / reopen without editor | PASS / PASS; exit 0; logs clean |
| Initial visual inspection | Room/street, dialogue/shop, wardrobe preview, phone, settings, night/rain/streetlights reviewed |

The standalone daily-loop check completes a delivery, rejects repeated pay, buys/consumes food, buys/equips a shirt, deposits bank money, sleeps, writes state, and then verifies that state in a new process. Synthetic input covers movement, interactions and controller mappings. Test save paths are isolated from the player's slot.

## Short rendered profile

Two rendered packaged-game sessions on the machine above reported:

| Metric | Daily-loop/write | Reopen/read |
| --- | --- | --- |
| Reported FPS after short warm-up | 57 | 60 |
| Peak resident process memory (sampled) | 180.7 MiB | 153.4 MiB |
| Largest measured scene construction | 43.0 ms | 39.0 ms |
| Node count at report time | 98 | 98 |

These are brief local diagnostics, not minimum hardware requirements or guarantees across a long session. Scene construction timers exclude deferred physics/render work. Memory is sampled Windows resident process memory, not GPU memory; release-only debug counters returned zero and were not treated as actual usage. Raw reports remain in ignored `.godot/packaged-qa-results.json` and `.godot/packaged-qa/qa/`.

## Artifact

`builds/LagosLife-0.1.0-windows.zip` — 34,472,591 bytes (about 32.9 MiB).

SHA-256: `B5A6F1CD847C44C5CE9A8EE9F85CEEA756588CED54060A9D3CE9F826BE5BD6BD`

The ZIP contains exactly the Windows executable, its PCK, README, Godot licence and third-party notices. Unverified legacy art, source tests, test saves, debug logs and editor tools are not packaged. The matching Windows release template was downloaded from the official Godot build archive; no editor or .NET runtime is needed to launch this GDScript build.

The export test caught and fixed scene-path casing mismatches that Windows editor runs tolerated. Explicit audio shutdown removed looping playback cleanup warnings in the final standalone logs.

## Open gates

- A separate clean Windows machine has not yet been tested.
- No external tester feedback has been received.
- Physical controller, listening/sound-mix review, longer-session performance and balancing remain manual checks.
- All implementation milestones are prototypes; this is not a public release or final art/content pass.

Use [the feedback template](Tester_Feedback.md) to record issues. No commit or public publication was performed.
