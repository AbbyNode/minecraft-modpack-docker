# Final Summary: Custom Image vs itzg/minecraft-server

## Quick Decision Guide

### Use Direct Server File URLs? → Either Image Works Great

If you use direct URLs from CurseForge "Additional Files":
```
https://mediafilez.forgecdn.net/files/5622/996/ServerFiles-4.14.zip
```

**Recommendation: itzg** for community maintenance and advanced features.

### Use CurseForge Page URLs Without API Key? → Custom Image

If you want to use modpack page URLs:
```
https://www.curseforge.com/minecraft/modpacks/all-the-mods-10
```

Without getting a CurseForge API key → **Custom image** is your only option.

### Want Auto-Updates? → itzg with API Key

If you want automatic modpack updates → **itzg with AUTO_CURSEFORGE** (requires free API key from https://console.curseforge.com/)

## Testing Confirmed

✅ **Custom script tested with 9 modpacks:**
- 8 successful (ATM 3/7/9/10, RLCraft, Dawn Craft, Better MC, Pixelmon)
- 1 expected failure (FTB Revelation - server files not in latest versions)

See [TESTING-RESULTS.md](TESTING-RESULTS.md) for full details.

## Key Differences Clarified

| Feature | Custom Image | itzg/minecraft-server |
|---------|--------------|----------------------|
| **Direct URLs** | ✅ MODPACK_URL | ✅ GENERIC_PACK |
| **Page URLs (no API)** | ✅ Web scraping | ❌ Requires API key |
| **Page URLs (with API)** | ❌ No auto-update | ✅ AUTO_CURSEFORGE |
| **Start scripts** | ✅ Uses modpack's | ⚠️ Own launcher (works 99%) |
| **server.properties** | ⚠️ Template file | ✅ Environment vars |
| **JSON configs** | ✅ Symlinked | ✅ Direct mount |
| **Maintenance** | ⚠️ You maintain | ✅ Community |

## Answered Questions

### 1. Can itzg handle the same files as the custom script?

**For direct URLs:** Yes, identically via GENERIC_PACK.

**For page URLs:** Requires API key (custom script doesn't).

### 2. Does itzg use custom start scripts?

**No**, uses own launcher. Works for 99% of modpacks.

### 3. Does itzg handle server.properties?

**Yes**, via environment variables (better than templates).

### 4. Can I bind mount JSON configs?

**Yes**, directly in ./data/ (simpler than custom image).

## Migration Decision Matrix

### Stay with Custom Image If:

1. You use CurseForge page URLs AND don't want an API key
2. Your modpack has unusual start script requirements (rare)
3. You prefer template-based configuration
4. Current setup works perfectly for you

### Migrate to itzg If:

1. You use direct server file URLs (most common)
2. You want auto-updates (get API key)
3. You want environment variable configuration
4. You want community maintenance
5. You want advanced features (health checks, etc.)

### Hybrid Approach (Recommended):

1. Use custom script to resolve page URLs once
2. Copy the resolved direct URL
3. Use that direct URL with itzg via GENERIC_PACK
4. Benefits:
   - ✅ No API key needed
   - ✅ Community-maintained itzg
   - ✅ Manual modpack updates (stability)
   - ✅ Best of both worlds

## Example: Hybrid Approach

```bash
# 1. Use custom script to resolve (one time)
$ docker run --rm -v $PWD:/work -w /work \
  eclarift/minecraft-modpack:latest \
  bash /scripts/resolve-curseforge-url.sh \
  "https://www.curseforge.com/minecraft/modpacks/all-the-mods-10"

# Output: https://mediafilez.forgecdn.net/files/5622/996/ServerFiles-4.14.zip

# 2. Use that URL with itzg
# docker-compose.yml
services:
  minecraft:
    image: itzg/minecraft-server
    environment:
      EULA: "TRUE"
      TYPE: "AUTO"
      GENERIC_PACK: "https://mediafilez.forgecdn.net/files/5622/996/ServerFiles-4.14.zip"
```

## Documentation Index

- **[ANSWER.md](ANSWER.md)** - Quick answer to original question
- **[TESTING-RESULTS.md](TESTING-RESULTS.md)** - Modpack testing results
- **[CLARIFICATIONS.md](CLARIFICATIONS.md)** - Detailed answers to all questions
- **[ITZG-MIGRATION-ANALYSIS.md](ITZG-MIGRATION-ANALYSIS.md)** - Full comparison
- **[MIGRATION-GUIDE.md](MIGRATION-GUIDE.md)** - Step-by-step migration
- **[CHECKLIST.md](CHECKLIST.md)** - Interactive checklist

## Conclusion

Both approaches are **valid and well-documented**. Choose based on your specific needs:

- **Direct URLs** → itzg recommended
- **Page URLs without API** → Custom image
- **Auto-updates** → itzg with API key
- **Hybrid** → Best flexibility

The documentation now includes testing results, clarifications, and answers to all questions raised.
