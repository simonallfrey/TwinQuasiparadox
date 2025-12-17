# Daily Notes – Bash Workflow & Tools

## Overview
- Cleaned up `~/.bash_history.d` by deduplicating entries oldest→newest; each file now holds only lines unique to that session.
- History init moved into `init_history()` (called once per shell) in `~/.bashrc.d/90-history.sh`; per-session `HISTFILE`, timestamps, `ignoredups:ignorespace`, `histappend`, and prompt-time sanity checks.
- Added helpers for working with history, Codex logs, and terminal tweaks.
- Synced the cleaned Bash config into `~/Code/dotfiles/bashrc.d`.

## History Workflow
- History config lives in `~/.bashrc.d/90-history.sh`; re-run in a session with:
  - `init_history` (only if you really need to reinit).
- Files in `~/.bash_history.d` are dated `YYYYMMDD-HHMMSS.PID.hist`; modification times were reset to match filenames.
- **Viewing all history**: `all_history` (prints chronological commands grouped by PID-from-filename; pipe to `less` if desired).
- Note: Only timestamps are stored in history files; PID shown at display time is not persisted.

## Codex Log Viewer
- Command: `codexlog`
  - Picker: `j/k` to move, `Enter` to open, `q` to quit.
  - Filters to user + agent messages with timestamps.
  - `-f/--follow`: stream existing content + new updates.
  - `-o/--out <file>`: write/append formatted output to a file (useful to `tail -f` or open in `nvim` and `:e!`).
  - No implicit `less`; pipe if you want paging.

## Terminal Tweaks
- Background chooser: `choose_term_bg`
  - Keys: `r/g/b` select channel; `j/k` decrement/increment; `Enter` accept; `q` cancel; type `host` to revert to host-based default.
  - Uses a session-only override; default remains host-based.
- Starship prompt hooks are in `~/.bashrc.d/80-starship.sh` (window title + background).

## Helpers
- `cap [-q]`: re-run last command and capture output in `out`, status in `cap_status`.
- `bashtrace`: trace startup: writes to `/tmp/bash-startup.log` and opens in `less`.
- Timestamps in history: `HISTTIMEFORMAT='%F %T '`.

## Syncing Dotfiles
- Bash fragments are synced into `~/Code/dotfiles/bashrc.d` via:
  ```bash
  rsync -a --delete ~/.bashrc.d/ ~/Code/dotfiles/bashrc.d/
  ```
- Dotfiles README in `bashrc.d/README.md` documents the layout.

## Commands Used for Cleanup (reference)
- Dedup histories (python):
  ```bash
  python3 - <<'PY'
  import pathlib, re, time, sys
  histdir = pathlib.Path.home() / ".bash_history.d"
  logs = sorted(histdir.glob("*.hist"), key=lambda p: p.name)
  seen = set()
  for path in logs:
      lines = path.read_text().splitlines()
      out = []
      for line in lines:
          if line not in seen:
              out.append(line)
              seen.add(line)
      path.write_text(("\n".join(out) + "\n") if out else "")
      print(f"{path.name}: {len(lines)} -> {len(out)}")
  PY
  ```
- Reset mtime from filename:
  ```bash
  cd ~/.bash_history.d
  for f in *.hist; do
    base=${f%%.*}; ts=${base/-/}; ts=${ts:0:12}.${ts:12:2}
    touch -t "$ts" "$f"
  done
  ```
