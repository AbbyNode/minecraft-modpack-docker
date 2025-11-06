

latest_url=$(curl -s "https://api.github.com/repos/Querz/mcaselector/releases/latest" \
| jq -r '.assets[] | select(.name | endswith(".jar")) | .browser_download_url') && \
echo "Downloading MCSelector from $latest_url" && \
curl -L "$latest_url" -o mcaselector.jar && \
chmod +x mcaselector.jar
