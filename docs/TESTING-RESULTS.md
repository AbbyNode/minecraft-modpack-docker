# Modpack Testing Results

Testing the custom CurseForge URL resolution script against various modpacks requested by the user.

## Test Date
2025-11-03

## Modpacks Tested

### ✅ Successfully Resolved

| Modpack | URL | Resolved Server File | File ID |
|---------|-----|---------------------|---------|
| All The Mods 10 | https://www.curseforge.com/minecraft/modpacks/all-the-mods-10 | ServerFiles-4.14.zip | 5622996 |
| All The Mods 9 | https://www.curseforge.com/minecraft/modpacks/all-the-mods-9 | Server-Files-1.1.1.zip | 5354808 |
| All The Mods 7 | https://www.curseforge.com/minecraft/modpacks/all-the-mods-7 | server.zip | 3513421 |
| All The Mods 3 | https://www.curseforge.com/minecraft/modpacks/all-the-mods-3 | SERVER-FULL-6.1.1.zip | 2556240 |
| RLCraft | https://www.curseforge.com/minecraft/modpacks/rlcraft | Server Pack 1.12.2 - Release v2.9.3.zip | 2533561 |
| Dawn Craft | https://www.curseforge.com/minecraft/modpacks/dawn-craft | Serverpack.zip | 4730261 |
| Better MC Forge BMC4 | https://www.curseforge.com/minecraft/modpacks/better-mc-forge-bmc4 | Server_Pack_v53.zip | 5982075 |
| The Pixelmon Modpack | https://www.curseforge.com/minecraft/modpacks/the-pixelmon-modpack | serverpack939.zip | 4838829 |

### ❌ Failed to Resolve

| Modpack | URL | Reason |
|---------|-----|--------|
| FTB Revelation | https://www.curseforge.com/minecraft/modpacks/ftb-revelation | No server files in latest 3 versions (latest server files is v3.2.0, file ID 2778975) |

### 🔍 Not Tested (No Server Files Available)

The following modpacks were noted as having no server files:
- Cobbleverse Cobblemon: https://www.curseforge.com/minecraft/modpacks/cobbleverse-cobblemon
- Cobblemon SMP Adventure: https://www.curseforge.com/minecraft/modpacks/cobblemon-smp-adventure
- Homestead Cozy: https://www.curseforge.com/minecraft/modpacks/homestead-cozy

## Resolved Download URLs

### All The Mods Series
```
ATM 10: https://mediafilez.forgecdn.net/files/5622/996/ServerFiles-4.14.zip
ATM 9:  https://mediafilez.forgecdn.net/files/5354/808/Server-Files-1.1.1.zip
ATM 7:  https://mediafilez.forgecdn.net/files/3513/421/server.zip
ATM 3:  https://mediafilez.forgecdn.net/files/2556/240/SERVER-FULL-6.1.1.zip
```

### Other Popular Modpacks
```
RLCraft:        https://mediafilez.forgecdn.net/files/2533/561/Server Pack 1.12.2 - Release v2.9.3.zip
Dawn Craft:     https://mediafilez.forgecdn.net/files/4730/261/Serverpack.zip
Better MC:      https://mediafilez.forgecdn.net/files/5982/075/Server_Pack_v53.zip
Pixelmon:       https://mediafilez.forgecdn.net/files/4838/829/serverpack939.zip
```

## Script Behavior

The custom `resolve-curseforge-url.sh` script:

1. ✅ **Searches main files first** - Looks for files with "server" in the filename on the main files page
2. ✅ **Falls back to additional files** - If not found in main list, checks the "Additional Files" section of the first 3 most recent files
3. ✅ **Works without API key** - Uses web scraping (no CurseForge API key required)
4. ⚠️ **Limited search** - Only checks the first page (20 files) and first 3 additional file sections for performance
5. ⚠️ **May miss older server files** - FTB Revelation's server files (v3.2.0) are not in the latest versions

## Comparison: Custom Script vs itzg/minecraft-server

| Feature | Custom Script | itzg/minecraft-server |
|---------|--------------|----------------------|
| CurseForge page URL support | ✅ Yes (web scraping) | ✅ Yes (with API key required) |
| API key required | ❌ No | ✅ Yes (for AUTO_CURSEFORGE) |
| Search depth | First 20 files + first 3 additional files | All files (with API) |
| Direct server file URLs | ✅ Yes (via MODPACK_URL) | ✅ Yes (via GENERIC_PACK) |
| Auto-updates | ❌ No | ✅ Yes (with AUTO_CURSEFORGE) |
| Rate limiting concerns | ⚠️ Possible (web scraping) | ❌ No (official API) |

## Recommendations

### For Most Users
Use **direct server file URLs** with either approach:
- Custom image: Set `MODPACK_URL` to the direct mediafilez.forgecdn.net URL
- itzg image: Set `GENERIC_PACK` to the direct mediafilez.forgecdn.net URL

**Advantages:**
- No API key needed
- Works with both images
- Explicit version control
- No rate limiting concerns

### For Auto-Updates
Use **itzg with AUTO_CURSEFORGE**:
- Requires CurseForge API key (free from https://console.curseforge.com/)
- Automatically updates to latest server files
- Uses official API (no scraping)

### For CurseForge Page URLs Without API Key
Use **custom script**:
- No API key required
- Works for most modpacks
- May miss server files not in latest 20 files
- Relies on web scraping (could break if CurseForge changes their HTML)

## Conclusion

The custom script successfully resolves **8 out of 9** tested modpacks. The failure (FTB Revelation) is expected since server files are not in the latest versions.

For reliability and future-proofing, **direct server file URLs are recommended** for both the custom image and itzg approach.
