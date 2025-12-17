## Context and goals
- Goal: update Codex CLI to use the latest `gpt-5.1-codex-max` (per livebench.ai), which exposed that npm was outdated (installed via apt), so we needed faster/cleaner apt mirrors and better tooling across Ubuntu/Termux. Also wanted smoother speech-recognition-driven editing and less mouse use in Obsidian.

## npm/apt/mirror work
- npm was from apt; we refreshed mirrors to make apt fast and current.
- Added `scripts/check_ubuntu_mirrors.sh` to benchmark mirrors (single country or all). Tunables: `COUNTRY`, `ALL_COUNTRIES=1`, `LIMIT`, `TOP`, `TIMEOUT`, `JOBS` (parallel), `RELEASE`, `MIRROR_BASE`.
- Latest all-country run (noble, unlimited parallel): fastest mirrors were `mirrors.ircam.fr`, `miroir.univ-lorraine.fr`, `mirror.bytemark.co.uk`, `ubuntu.univ-reims.fr`, `ftp.stw-bonn.de`.
- Swapping apt to a chosen mirror: create `/etc/apt/sources.list.d/custom-mirror.list` with standard `deb` entries pointing at the mirror; optionally comment old `ubuntu.com` lines in `/etc/apt/sources.list`; `sudo apt update` to verify.

## Termux / Codex CLI
- Plan: install Codex CLI on Termux via npm (global), ensuring Termux deps (`git`, `curl`, `nodejs`), handle prefix/PATH if needed. Speech recognition to play nice on Termux/Ubuntu was part of the motivation.

## Obsidian + nvim workflow
- Needed keyboard-first spell correction; Obsidian’s Vim emulation lacks `z=`.
- Installed the Shellcommands plugin to avoid mouse usage and run custom commands.
- Working command to open the current note in fullscreen nvim at the caret:
  ```
  gnome-terminal --full-screen -- /home/s/.local/bin/nvim +call\ cursor\({{caret_position:line}},{{caret_position:column}}\) {{file_path:absolute}}
  ```
  - Use `{{caret_position:line}}` / `{{caret_position:column}}` and escape parens for bash.
  - Add `--working-directory="{{file_dir:absolute}}"` if you want the terminal cwd to match the note’s folder.

## Forward actions
- Update npm (via apt or `npm install -g npm`, or switch to nvm/volta) once mirrors are set; then update Codex CLI to the latest release that supports `gpt-5.1-codex-max`.
- On Termux: install Codex CLI, test with speech recognition workflow.
- In Obsidian: optionally bind the Shellcommands entry to a hotkey; consider LanguageTool or similar plugin if you still want inline suggestions without the mouse.
