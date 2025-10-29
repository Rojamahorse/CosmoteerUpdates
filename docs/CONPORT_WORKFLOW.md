# Cosmoteer ConPort + Cline Workflow

This repository tracks the live Steam installation at `D:\SteamLibrary\steamapps\common\Cosmoteer`.
The `main-unstable-mcp` branch mirrors each patch release so we can diff game updates against our mods.
All long-term context is stored in ConPort and shared through the MCP server hosted on this machine.

## MCP Server

- **Endpoint:** `https://conport.rojamahorse.com/mcp` (SSE transport).
- **Workspace ID:** `cosmoteer-main` (use exactly this string so everyone shares the same memory bank).
- **Server launch:**
  ```powershell
  pwsh -File e:\AI\context-portal\scripts\conport-launch.ps1 -HostIP 0.0.0.0 -Port 8765 -BasePath E:\AI\ConPortData
  ```
  The shortcut in the Windows Startup folder already calls this script on logon.

## Cline / Claude Dev Configuration

Insert this block into `mcpServers` in VS Code settings:

```json
{
  "mcpServers": {
    "Conport": {
      "type": "sse",
      "url": "https://conport.rojamahorse.com/mcp",
      "timeout": 120,
      "disabled": false
    }
  }
}
```

Copy `e:\AI\context-portal\conport-custom-instructions\cline_conport_strategy` into Custom Instructions.
Start each session with:

```
Initialize according to custom instructions.
Use workspace_id "cosmoteer-main".
Repository root: D:\SteamLibrary\steamapps\common\Cosmoteer.
```

## Daily Workflow

1. `git pull`
2. Initialize the session as above.
3. Work normally; request diffs/summaries via the agent.
4. After changes or a Steam patch:
   - Run **ConPort Sync** so decisions/progress are logged.
   - Update `CONPORT_MEMORY.md` if high-level context changed.
5. Commit and push:
   ```powershell
   git status
   git add <paths>
   git commit -m "Describe patch or change"
   git push -u origin main-unstable-mcp
   ```

## Capturing Game Updates

- When Steam updates Cosmoteer, rerun the workflow and create a commit.
- Suggested message: `Steam patch YYYY-MM-DD (version)`.
- Use `log_decision` to describe the patch and link relevant modules.

## ConPort Tips

- `log_decision` – document patches, design choices, mod impacts.
- `log_progress` – record verification steps or mod updates.
- `link_conport_items` – connect decisions to progress entries or files.
- `export_conport_to_markdown` – archive ConPort before major releases.

## Maintenance

- `.gitignore` keeps ConPort exports/logs out of Git (see repo root).
- Back up `E:\AI\ConPortData\cosmoteer-main` regularly.
- If the MCP connection fails, ensure the server script is running and the Cloudflare tunnel points to `http://localhost:8765`.
