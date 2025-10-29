# Memory Bank

- Workspace: D:\SteamLibrary\steamapps\common\Cosmoteer
- Created: $(Get-Date -Format o)

## Product Context
- Goals:
  - Track the exact contents of the Steam installation so each Cosmoteer patch is captured in Git.
  - Provide a reliable baseline for comparing mods and customizations against the vanilla game.
  - Keep ConPort in sync with repository history so LLM agents can answer questions about changes.
- Features:
  - Branch `main-unstable-mcp` mirrors the live game install (Bin, Data, Standard Mods, etc.).
  - ConPort workspace `cosmoteer-main` shared across all Cline clients via the SSE MCP endpoint.
  - Automatic memory templates available on demand for new submodules (init script lives in `e:\AI\context-portal\scripts`).
- Architecture:
  - Git repo rooted at `Cosmoteer/` with remote `origin` (GitHub: CosmoteerUpdates).
  - ConPort server hosted on local machine, reachable at `https://conport.rojamahorse.com/mcp`.
  - Clients (Cline/Claude Dev) connect using custom instructions + MCP config stored in repo docs.

## Active Context
- Current focus:
  - Baseline commit created from Steam install on branch `main-unstable-mcp`.
  - Next step: capture workflow guide and ensure .gitignore excludes transient artifacts.
- Recent changes:
  - Reinitialized Git at `Cosmoteer/.git`; staged and committed full install snapshot.
  - ConPort configuration drafted for shared workspace usage.
- Open issues:
  - Need to document how to run ConPort sync routine after each patch.
  - Establish policy for exporting ConPort data (location, cadence).

## Decisions
- [ ] Summary:
  - Rationale:
  - Implementation details:
  - Tags:

## Progress
- [ ] Summary:
  - Status: planned | in-progress | done
  - Links:

## System Patterns
- Name:
- Description:
- Tags:

## Custom Data
- Category:
- Key:
- Value:
