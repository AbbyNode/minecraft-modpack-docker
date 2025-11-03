# Building Unmined in Restricted Environments

Due to network security restrictions in some build environments, downloading from `unmined.net` may be blocked. This guide provides a workaround for building the Unmined Docker image in such environments.

## Problem

The Dockerfile downloads Unmined CLI from:
```
https://unmined.net/download/unmined-cli-linux-x64-dev.gz
```

If this domain is blocked, the build will fail with:
```
curl: (6) Could not resolve host: unmined.net
```

## Solution

Download the file manually in an environment where `unmined.net` is accessible, then build the image using a local copy.

### Step 1: Download Unmined CLI

On a machine with unrestricted internet access:

```bash
cd unmined
curl -L "https://unmined.net/download/unmined-cli-linux-x64-dev.gz" -o unmined-cli.gz
```

This will create `unmined/unmined-cli.gz` (approximately 24 MB).

### Step 2: Modify the Dockerfile

Edit `unmined/Dockerfile`:

1. Find lines 19-27 (the RUN curl command)
2. Comment them out by adding `#` at the start of each line
3. Uncomment line 21 (the COPY command)

The section should look like this:

```dockerfile
# Download and install Unmined CLI (Linux glibc x64 for Debian/Ubuntu)
# Using the DEV channel for latest version
# 
# If building in a restricted environment, you can manually download the file:
#   curl -L "https://unmined.net/download/unmined-cli-linux-x64-dev.gz" -o unmined-cli.gz
# Then uncomment the COPY line below and comment out the RUN curl line:
COPY unmined-cli.gz /unmined/unmined-cli.gz

# RUN \
#     curl -L "https://unmined.net/download/unmined-cli-linux-x64-dev.gz" -o unmined-cli.gz && \
#     gunzip unmined-cli.gz && \
#     chmod +x unmined-cli && \
#     mv unmined-cli /usr/local/bin/unmined-cli && \
#     echo "Unmined CLI installed successfully"
```

### Step 3: Add extraction and installation steps

After the COPY line, add:

```dockerfile
COPY unmined-cli.gz /unmined/unmined-cli.gz

RUN \
    gunzip unmined-cli.gz && \
    chmod +x unmined-cli && \
    mv unmined-cli /usr/local/bin/unmined-cli && \
    echo "Unmined CLI installed successfully"
```

### Step 4: Build the image

```bash
docker build -t eclarift/unmined:latest ./unmined
```

### Step 5: Update .dockerignore (Optional)

If you want to prevent accidentally committing the binary, add to `unmined/.dockerignore`:

```
unmined-cli.gz
unmined-cli
```

Note: The `.dockerignore` already excludes `*.md` files, so documentation won't bloat the image.

## Alternative: Pre-built Image

If you cannot build the image at all, you can:

1. Build it on a machine with unrestricted access
2. Export the image:
   ```bash
   docker save eclarift/unmined:latest | gzip > unmined-image.tar.gz
   ```
3. Transfer it to the restricted environment
4. Import it:
   ```bash
   docker load < unmined-image.tar.gz
   ```

## Verification

After building, verify the image works:

```bash
docker run --rm eclarift/unmined:latest unmined-cli --help
```

You should see the Unmined CLI help output.

## Keeping Updated

To update to a newer version of Unmined:

1. Download the latest version from https://unmined.net/downloads/
2. Replace `unmined-cli.gz` with the new version
3. Rebuild the image

The DEV channel link always points to the latest version, so you can use the same download command.
