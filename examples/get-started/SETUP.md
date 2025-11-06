# Osiris Setup - Examples

**Idempotent** - Safe to run multiple times. Only installs what's missing.

**Time:** 5-10 minutes

---

## Prerequisites

- Python 3.11+
- Claude Code CLI

Verify your Python version:
```bash
python3.11 --version  # Should show Python 3.11.x or higher
```

---

## Cleanup (Idempotent - Safe to Run)

Remove any existing Osiris installation and MCP configuration for a fresh start:

```bash
# 1. Remove MCP configuration from Claude Code
claude mcp remove osiris 2>/dev/null || echo "No existing MCP config"

# 2. Deactivate virtual environment if active
deactivate 2>/dev/null || true

# 3. Remove virtual environment from repo root
# Navigate to repo root first
cd "$(git rev-parse --show-toplevel)"
rm -rf .venv

echo "✅ Cleanup complete - ready for fresh installation"
```

**Note:** This is safe to run multiple times. It only removes what exists. Everything is installed in the venv (no global installations).

---

## Installation

### Option 1: Install from Cloned Repo (Recommended for Development)

Since you've cloned the Osiris repository, install in development mode:

```bash
# From repo root
python3.11 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -e .
```

Verify installation:
```bash
osiris --version  # Should show: Osiris v0.5.x
osiris components list | head -10  # Should list available components
```

### Option 2: Install from PyPI

If you prefer to use the published package:

```bash
python3.11 -m venv .venv
source .venv/bin/activate
pip install osiris-pipeline
```

---

## Initialize Osiris Project

Navigate to the tutorial directory and initialize:

```bash
cd examples/get-started
osiris init
```

This creates:
- `osiris.yaml` - Project configuration with base paths
- `osiris_connections.yaml` - Connection configuration (if not exists)
- `.osiris/` - MCP logs and artifacts directory

**Important:** `osiris init` automatically sets the `filesystem.base_path` to the current directory's absolute path. All Osiris operations (MCP logs, artifacts, pipelines) will be isolated to this location.

---

## Configure MCP with Claude Code

Add Osiris MCP server to Claude Code:

```bash
# From repo root (where .venv is located)
claude mcp add osiris "$(pwd)/.venv/bin/python" -m osiris.cli.mcp_entrypoint
```

**What this does:**
- Registers Osiris as an MCP server with Claude Code
- Claude can now use Osiris MCP tools to build pipelines
- All operations are config-driven (using osiris.yaml)

---

## Verification

```bash
# 1. Check Osiris is installed
osiris --version

# 2. Verify MCP server can start
osiris mcp run --selftest  # Should complete in <1.3s

# 3. Restart Claude Code to load MCP configuration
# Exit current session and start a new one

# 4. Verify MCP tools are available (in new Claude session)
# Run: /mcp
# You should see "osiris" listed with tools like:
#   - osiris_oml_schema_get
#   - osiris_oml_validate
#   - osiris_oml_save
#   - osiris_discovery_run
#   - osiris_components_list
#   - etc.
```

---

## What Gets Installed

- ✅ `osiris` command-line tool (for contributors)
- ✅ All components (CSV, MySQL, Supabase, DuckDB, etc.)
- ✅ MCP server integration (primary interface)
- ✅ Dependencies (Rich, PyYAML, DuckDB, etc.)
- ✅ Project configuration (osiris.yaml, connections)

---

## Troubleshooting

### Issue: "osiris: command not found"

**Solution:**
```bash
# Make sure virtual environment is activated
source .venv/bin/activate

# Check if osiris is in the venv
which osiris  # Should show path in .venv/bin/
```

### Issue: "Python version incompatible"

**Solution:**
```bash
# Check Python version
python --version

# If too old, use python3.11 explicitly
python3.11 -m venv .venv
source .venv/bin/activate
pip install -e .  # or pip install osiris-pipeline
```

### Issue: "MCP tools not available in Claude"

**Solution:**
1. Verify MCP server is registered: `cat ~/.config/claude/mcp.json` (or equivalent)
2. Restart Claude Code completely
3. Run `/mcp` to check server status
4. If not listed, re-run the `claude mcp add` command

---

## Next Steps

Setup complete! Now you can:

1. **Run the get-started tutorial**: See `README.md` in this directory
2. **Try other examples**: Explore other tutorials in `examples/`
3. **Read the docs**: Check `docs/quickstart.md` for manual pipeline creation

---

## Re-running Setup

This setup is **idempotent** - you can run it again anytime:
- If something breaks
- After pulling new changes
- To update to the latest version

Just run the installation commands again. They will skip steps that are already complete.
