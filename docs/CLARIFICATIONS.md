# Important Clarifications on itzg/minecraft-server Migration

## CurseForge Page URL Support Requires API Key

**IMPORTANT UPDATE:** The itzg/minecraft-server image **requires a CurseForge API key** to handle CurseForge modpack page URLs.

### What This Means

#### ✅ Works WITHOUT API Key (Both Images)
- **Direct server file URLs** from CurseForge "Additional Files"
  ```yaml
  # Custom image
  MODPACK_URL=https://mediafilez.forgecdn.net/files/5622/996/ServerFiles-4.14.zip
  
  # itzg image
  GENERIC_PACK=https://mediafilez.forgecdn.net/files/5622/996/ServerFiles-4.14.zip
  ```

#### ❌ Requires API Key with itzg
- **CurseForge modpack page URLs** (e.g., https://www.curseforge.com/minecraft/modpacks/all-the-mods-10)
  ```yaml
  # itzg REQUIRES API key for this:
  environment:
    TYPE: "AUTO_CURSEFORGE"
    CF_API_KEY: "${CF_API_KEY}"  # Required!
    CF_PAGE_URL: "${MODPACK_URL}"
  ```

#### ✅ Works WITHOUT API Key (Custom Script Only)
- The **custom script** can resolve CurseForge modpack page URLs **without** an API key
- Uses web scraping instead of official API
- This is a key advantage of the custom image for users who don't want to get an API key

## Getting a CurseForge API Key

If you want to use AUTO_CURSEFORGE for automatic updates:

1. Go to https://console.curseforge.com/
2. Create an account or log in
3. Create an API key
4. Add to your .env:
   ```env
   CF_API_KEY=your-api-key-here
   ```

## Recommendations Updated

### Scenario 1: You Have Direct Server File URLs
**Use either image** - both work great with GENERIC_PACK/MODPACK_URL

### Scenario 2: You Want to Use Modpack Page URLs (No API Key)
**Keep using the custom image** - it can resolve these without an API key

### Scenario 3: You Want to Use Modpack Page URLs (Have API Key)
**Use itzg with AUTO_CURSEFORGE** - gets automatic updates and uses official API

### Scenario 4: You Want Auto-Updates
**Use itzg with AUTO_CURSEFORGE and API key** - this is the killer feature

## Start Scripts and Custom Launchers

### Question: Does itzg use the custom start script in server files?

**Answer: No**, itzg uses its own optimized launcher.

#### What the Custom Image Does
```bash
# Extracts modpack zip
# Runs the modpack's own start script:
./startserver.sh
# or
./start.sh
# etc.
```

#### What itzg Does
```bash
# Extracts modpack zip
# Uses its own Java launcher with optimized flags
java -Xms4G -Xmx4G @user_jvm_args.txt @libraries/net/.../unix_args.txt nogui
```

#### Is This a Problem?

**For 99% of modpacks: No**

Most modpack start scripts just launch Java with the server jar. itzg does this automatically with better flags (Aikar flags, etc.).

#### When It Might Be a Problem

If a modpack has a **very unusual** start script that does custom setup, you might need to:
1. Use custom JVM_OPTS in docker-compose.yml
2. Or stick with the custom image

We have not found any common modpacks with this issue.

## Server Properties

### Question: Does itzg handle default server.properties?

**Answer: Yes, even better than the custom template approach!**

#### Custom Image Approach
- Uses a `templates/default.properties` file
- Runs a script to merge values into server.properties
- Requires editing template file to change defaults

#### itzg Approach
- Set properties as **environment variables** in docker-compose.yml
- No template files needed
- Easy to override per-deployment

```yaml
environment:
  MOTD: "My Server"
  DIFFICULTY: "hard"
  GAMEMODE: "survival"
  VIEW_DISTANCE: "32"
  MAX_PLAYERS: "20"
  PVP: "FALSE"
  WHITE_LIST: "TRUE"
  # ... 100+ more options available
```

This is actually **superior** to the template approach because:
- ✅ No need to edit files, just environment variables
- ✅ Easy to override in docker-compose.yml
- ✅ Follows Docker best practices
- ✅ Can use different values in different environments

## JSON Config Files (whitelist.json, etc.)

### Question: Can I bind mount JSON configs like whitelist.json?

**Answer: Yes, absolutely!**

#### With itzg
```yaml
volumes:
  - ./data:/data
  - ./data/config:/data/config  # All configs here
```

Then your files will be at:
```
./data/whitelist.json
./data/ops.json
./data/banned-players.json
./data/banned-ips.json
./data/server.properties
```

You can edit these files on your host and they'll be used by the server.

#### Comparison with Custom Image

| File | Custom Image | itzg |
|------|-------------|------|
| whitelist.json | `./data/config/whitelist.json` → linked to `/minecraft/` | `./data/whitelist.json` |
| ops.json | `./data/config/ops.json` → linked to `/minecraft/` | `./data/ops.json` |
| server.properties | `./data/config/server.properties` → linked to `/minecraft/` | Managed by env vars, file at `./data/server.properties` |

Both approaches allow editing on the host. itzg's approach is simpler (direct mount, no symlinking).

## Summary of Key Differences

| Feature | Custom Image | itzg |
|---------|--------------|------|
| **Direct server file URLs** | ✅ MODPACK_URL | ✅ GENERIC_PACK |
| **CurseForge page URLs** | ✅ No API key needed | ⚠️ API key required |
| **Auto-updates** | ❌ No | ✅ Yes (with API key) |
| **Custom start scripts** | ✅ Uses modpack's script | ⚠️ Uses own launcher |
| **Server properties** | ⚠️ Template file | ✅ Environment variables |
| **JSON configs** | ✅ Bind mounted, symlinked | ✅ Bind mounted, direct |
| **Maintenance** | ⚠️ You maintain | ✅ Community maintains |

## Final Recommendations

### Stick with Custom Image If:
- You need CurseForge page URL resolution without API key
- You have a modpack with unusual start script requirements
- You prefer the current template-based config approach

### Migrate to itzg If:
- You use direct server file URLs (most common)
- You want automatic modpack updates (with API key)
- You want better server property management (env vars)
- You want community maintenance and updates
- You want advanced features (health checks, etc.)

### Hybrid Approach:
- Use **direct server file URLs** from CurseForge
- Resolve them manually or with the custom script once
- Use with itzg via GENERIC_PACK
- Get benefits of itzg without needing API key
- Update URLs manually when you want to update the modpack

This hybrid approach gives you the best of both worlds:
- ✅ No API key needed
- ✅ Community-maintained itzg image
- ✅ Advanced features
- ⚠️ Manual modpack updates (which many prefer for stability)
