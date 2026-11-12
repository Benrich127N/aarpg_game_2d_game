# PH NIGHT startup artwork

`ph-night-splash-v1.png` is the custom startup/loading artwork: a fictional Lagos street at blue hour, with PH NIGHT lettering, food stall, provisions kiosk, plants and a yellow danfo. Created using the built-in OpenAI image generation tool without reference images or third-party input art. The exact prompt is stored in `generation-prompt.txt`.

Source generation record: session `01a1c79a-0965-7042-a236-e47862c2ce33`, file `exec-d22d6bb4-f58d-4644-b9db-5adf2b6a2a16.png`. The delivered PNG is copied unchanged into this directory. AI-generated project artwork; no third-party attribution identified, and no claim of exclusive copyright or a third-party licence is made.

`project.godot` uses this PNG as the engine boot splash, replacing the default engine logo. Filtering is disabled and the background matches the artwork. `Scenes/ui/BootLoading.tscn` is the new startup scene and reuses the same image with a native progress bar. It requests the main menu through Godot's threaded resource loader, displays its actual progress, and opens the menu when ready. No artificial progress increments or minimum wait are added. A retry button appears on a loading error. The image is contained within the viewport so its title is not cropped.

The menu, new-game flow and in-game district transitions retain their existing behaviour. Existing exported Windows builds must be rebuilt to include this source update.

Validation: `tests/BootLoading.tscn` verifies the startup scene and splash settings, threaded completion, loading artwork, error/retry state and opening the loaded menu. It runs in `tools/test.ps1`. A rendered preview is saved at `.godot/review-loading-screen.png` by the test.
