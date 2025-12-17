watchfile=/tmp/codex-commands
tail -f "$watchfile" | while IFS= read -r line; do
[ -z "$line" ] && continue
printf '[cmd] %s\n' "$line"
sh -c "$line"
done
