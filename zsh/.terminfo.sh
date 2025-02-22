terminfo_source=$(cat << 'EOF'
# Use colon separators.
xterm-24bit|xterm with 24-bit direct color mode,
  use=xterm-256color,
  setb24=\E[48:2:%p1%{65536}%/%d:%p1%{256}%/%{255}%&%d:%p1%{255}%&%dm,
  setf24=\E[38:2:%p1%{65536}%/%d:%p1%{256}%/%{255}%&%d:%p1%{255}%&%dm,
# Use semicolon separators.
xterm-24bits|xterm with 24-bit direct color mode,
  use=xterm-256color,
  setb24=\E[48;2;%p1%{65536}%/%d;%p1%{256}%/%{255}%&%d;%p1%{255}%&%dm,
  setf24=\E[38;2;%p1%{65536}%/%d;%p1%{256}%/%{255}%&%d;%p1%{255}%&%dm,
EOF
)

# Ensure xterm-24bit exists in terminfo for true color support
if ! infocmp xterm-24bit >/dev/null 2>&1; then
  echo "$terminfo_source" | tic -x -o ~/.terminfo - 2>/dev/null || \
  echo "Warning: xterm-24bit terminfo not found. True colors may not work correctly."
fi