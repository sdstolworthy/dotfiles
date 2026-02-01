# Set CHROME_EXECUTABLE environment variable
if command -v google-chrome-stable >/dev/null 2>&1; then
    export CHROME_EXECUTABLE="google-chrome-stable"
elif command -v google-chrome >/dev/null 2>&1; then
    export CHROME_EXECUTABLE="google-chrome"
elif command -v chromium >/dev/null 2>&1; then
    export CHROME_EXECUTABLE="chromium"
elif command -v chrome >/dev/null 2>&1; then
    export CHROME_EXECUTABLE="chrome"
fi
