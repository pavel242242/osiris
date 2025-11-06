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

Add Osiris MCP server to Claude Code with proper environment:

```bash
# From repo root (where .venv is located)
REPO_ROOT="$(git rev-parse --show-toplevel)"
TUTORIAL_DIR="$REPO_ROOT/examples/get-started"

claude mcp add osiris \
  "$REPO_ROOT/.venv/bin/python" \
  -m osiris.cli.mcp_entrypoint \
  --env OSIRIS_HOME="$TUTORIAL_DIR"
```

**What this does:**
- Registers Osiris as an MCP server with Claude Code
- Sets OSIRIS_HOME to `examples/get-started/` (where osiris.yaml will live)
- MCP server will look for config and secrets in that directory
- Claude can now use Osiris MCP tools to build pipelines

**Environment file (.env):**
If you need database connections (MySQL, Supabase, etc.), create `.env` in `examples/get-started/`:
```bash
cd examples/get-started
cat > .env << 'EOF'
MYSQL_PASSWORD=your-mysql-password
SUPABASE_SERVICE_ROLE_KEY=your-key
EOF
```

The MCP server will automatically load `.env` from OSIRIS_HOME.

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

## MCP Tools vs CLI Commands

### Available Through MCP (for Claude Code users):
- `guide_start` - Get workflow guidance
- `oml_schema_get` - Get OML schema
- `oml_validate` - Validate OML pipeline
- `oml_save` - Save OML pipeline
- `components_list` - List available components
- `connections_list` - List connections
- `connections_doctor` - Diagnose connection issues
- `discovery_request` - Discover database schemas
- `usecases_list` - List OML templates
- `memory_capture` - Capture session memory
- `aiop_list` / `aiop_show` - View execution logs

### Only Through CLI (for contributors):
- `osiris init` - Initialize project (run once during setup)
- `osiris compile` - Compile OML to manifest
- `osiris run` - Execute pipeline
- `osiris logs` - View execution logs

**Key principle:** Claude Code users build pipelines through MCP tools. Pipeline execution happens outside of Claude sessions.

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
2. Check that OSIRIS_HOME is set in the MCP config
3. Restart Claude Code completely
4. Run `/mcp` to check server status
5. If not listed or OSIRIS_HOME missing, re-run the full `claude mcp add` command with --env

### Issue: "MCP server can't find osiris.yaml"

**Solution:**
```bash
# Verify OSIRIS_HOME is set correctly in MCP config
cat ~/.config/claude/mcp.json | grep -A5 osiris

# Should show: "OSIRIS_HOME": "/full/path/to/osiris/examples/get-started"
# If missing or wrong, reconfigure:
REPO_ROOT="$(git rev-parse --show-toplevel)"
claude mcp add osiris \
  "$REPO_ROOT/.venv/bin/python" \
  -m osiris.cli.mcp_entrypoint \
  --env OSIRIS_HOME="$REPO_ROOT/examples/get-started"
```

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
