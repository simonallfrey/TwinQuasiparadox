# one-time setup
watchfile=/tmp/wk-stdin
outfile=/tmp/wk-out
mkfifo "$watchfile"

# start a persistent wolframscript session reading from the FIFO
( tail -f "$watchfile" \
  | WOLFRAMSCRIPT_CONFIGURATIONPATH="$PWD/WolframScript.conf" \
    WOLFRAMSCRIPT_KERNELPATH=/usr/local/bin/WolframKernel \
    wolframscript -noprompt -linewise \
    > "$outfile" 2>&1 ) &

echo "started persistent kernel, pid $!"
cat <<'EOF'
Send commands to the kernel though /tmp/wk-stdin
e.g.
echo 'Get["/home/s/Code/TwinQuasiparadox/lab-book/figure-elsewhere-two-scales-fixed-by-hand.wl"]; GraphicsRow[{panel1, panel2}, Spacings -> 0.8, Background -> Black, ImageMargins -> 0] // Export["/home/s/Code/TwinQuasiparadox/lab-book/elsewhere-two-scales-fixed-by-hand.png", #, ImageResolution -> 300] &' > /tmp/wk-stdin
EOF
