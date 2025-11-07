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
# IMPORTANT: Replace with your actual path to the osiris repo
OSIRIS_REPO="/path/to/osiris"  # UPDATE THIS!

cd "$OSIRIS_REPO"
rm -rf .venv

echo "✅ Cleanup complete - ready for fresh installation"
```

**Note:** Update `OSIRIS_REPO` to your actual path. Example: `/Users/yourname/projects/osiris`

---

## Installation

Since you're following this tutorial from the cloned Osiris repository:

```bash
# 1. Save the repo path (IMPORTANT - you'll need this later!)
OSIRIS_REPO="$(pwd)"  # Run this from the osiris repo root
echo "export OSIRIS_REPO='$OSIRIS_REPO'" >> ~/.bashrc  # Or ~/.zshrc
echo "Saved OSIRIS_REPO=$OSIRIS_REPO"

# 2. Create virtual environment
python3.11 -m venv .venv

# 3. Activate it
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# 4. Install Osiris in development mode
pip install -e .
```

**Validation Checkpoint 1:**
```bash
# Test installation
osiris --version
# ✅ Expected output: Osiris v0.5.x
# ⏱️ Expected time: <1 second

osiris components list | head -5
# ✅ Expected output:
# Available Components:
# - filesystem.csv_extractor (Read CSV files)
# - filesystem.csv_writer (Write CSV files)
# ...
# ⏱️ Expected time: <2 seconds

# ⚠️ If "osiris: command not found":
# - Check venv is activated: which python (should show .venv)
# - Re-run: source .venv/bin/activate
```

**Note:** For production use outside this repo, install via PyPI: `pip install osiris-pipeline`

---

## Initialize Osiris Project

Navigate to the tutorial directory and initialize:

```bash
cd "$OSIRIS_REPO/examples/get-started"
osiris init
```
⏱️ Expected time: <2 seconds

**Validation Checkpoint 2:**
```bash
# Verify project files were created
ls -la osiris.yaml
# ✅ Expected: -rw-r--r--  1 user  staff  ... osiris.yaml

ls -la osiris_connections.yaml
# ✅ Expected: -rw-r--r--  1 user  staff  ... osiris_connections.yaml

ls -la .osiris/mcp/logs/
# ✅ Expected: audit/  cache/  telemetry/

# ⚠️ If files missing:
# - Check you're in examples/get-started: pwd
# - Check venv is activated: which osiris
# - Re-run: osiris init
```

**What was created:**
- `osiris.yaml` - Project configuration with base_path set to this directory
- `osiris_connections.yaml` - Database connections (not needed for CSV tutorial)
- `.osiris/mcp/logs/` - MCP audit, cache, and telemetry logs

**Important:** `osiris init` sets `filesystem.base_path` to the current directory's absolute path. All Osiris operations (MCP logs, artifacts, pipelines) will be isolated here.

---

## Configure MCP with Claude Code

Add Osiris MCP server to Claude Code with proper environment:

```bash
# Using the saved OSIRIS_REPO variable
TUTORIAL_DIR="$OSIRIS_REPO/examples/get-started"

claude mcp add osiris \
  "$OSIRIS_REPO/.venv/bin/python" \
  -m osiris.cli.mcp_entrypoint \
  --env OSIRIS_HOME="$TUTORIAL_DIR"
```
⏱️ Expected time: <5 seconds

**Validation Checkpoint 3:**
```bash
# Verify MCP server is configured
cat ~/.claude.json | grep -A10 "osiris"
# ✅ Expected output showing:
# "osiris": {
#   "command": "/full/path/to/.venv/bin/python",
#   "args": ["-m", "osiris.cli.mcp_entrypoint"],
#   "env": {
#     "OSIRIS_HOME": "/full/path/to/examples/get-started"
#   }
# }

# Test MCP server can start
python "$OSIRIS_REPO/.venv/bin/python" -m osiris.cli.mcp_entrypoint --selftest
# ✅ Expected output: "Self-test completed in <1.3s"
# ⏱️ Expected time: <2 seconds

# ⚠️ If selftest fails:
# - Check osiris.yaml exists: ls -la "$TUTORIAL_DIR/osiris.yaml"
# - Check venv path is correct: ls -la "$OSIRIS_REPO/.venv/bin/python"
# - Re-run: osiris init (from examples/get-started directory)
```

**What this does:**
- Registers Osiris as an MCP server with Claude Code
- Sets OSIRIS_HOME to `examples/get-started/` (where osiris.yaml lives)
- MCP server will look for config and secrets in that directory
- Claude can now use Osiris MCP tools to build pipelines

**Environment file (.env) - Optional:**
For database connections (MySQL, Supabase), create `.env` in `examples/get-started/`:
```bash
cd "$OSIRIS_REPO/examples/get-started"
cat > .env << 'EOF'
MYSQL_PASSWORD=your-mysql-password
SUPABASE_SERVICE_ROLE_KEY=your-key
EOF
```

**Note:** This CSV tutorial doesn't need `.env` - only for database examples.

---

## Final Verification & Exit Criteria

**Session 1 Exit Criteria - All must pass:**

```bash
# ✅ Checkpoint 1: Osiris installed
osiris --version
# Expected: Osiris v0.5.x

# ✅ Checkpoint 2: MCP server works
python -m osiris.cli.mcp_entrypoint --selftest
# Expected: "Self-test completed in <1.3s"

# ✅ Checkpoint 3: MCP configured in Claude
cat ~/.claude.json | grep "osiris" | wc -l
# Expected: >0 (at least 1 line)

# ✅ Checkpoint 4: Project initialized
ls -la "$OSIRIS_REPO/examples/get-started/osiris.yaml"
# Expected: File exists

# ✅ Checkpoint 5: MCP logs directory created
ls -la "$OSIRIS_REPO/examples/get-started/.osiris/mcp/logs/"
# Expected: audit/ cache/ telemetry/ directories

echo "✅ All checkpoints passed! Ready for Session 2"
```

**Final Step: Restart Claude Code**
```bash
# Exit any running Claude Code session
# Then verify MCP in new session:
cd "$OSIRIS_REPO/examples/get-started"
claude

# In Claude, run: /mcp
# ✅ Expected: "osiris" listed with status "Connected"
# ✅ Expected tools: guide_start, oml_schema_get, oml_validate, etc.
```

**Quick Verification Script:**
```bash
# Run automated verification
./verify-session-1.sh

# This checks all 5 checkpoints and provides detailed feedback
```

**If Session 1 Exit Criteria Not Met:**
- See Troubleshooting section below
- Re-run failed step
- Run verification script again

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
cd "$OSIRIS_REPO"
python3.11 -m venv .venv
source .venv/bin/activate
pip install -e .
```

### Issue: "MCP tools not available in Claude"

**Solution:**
```bash
# 1. Verify MCP server is registered
cat ~/.claude.json | grep -A10 "osiris"
# Should show "osiris" configuration

# 2. Check OSIRIS_HOME is set
cat ~/.claude.json | grep "OSIRIS_HOME"
# Should show: "OSIRIS_HOME": "/full/path/to/examples/get-started"

# 3. Test MCP server
python -m osiris.cli.mcp_entrypoint --selftest
# Should pass in <1.3s

# 4. Restart Claude Code completely (exit and relaunch)

# 5. If still not working, reconfigure:
cd "$OSIRIS_REPO"
TUTORIAL_DIR="$OSIRIS_REPO/examples/get-started"
claude mcp add osiris \
  "$OSIRIS_REPO/.venv/bin/python" \
  -m osiris.cli.mcp_entrypoint \
  --env OSIRIS_HOME="$TUTORIAL_DIR"
```

### Issue: "MCP server can't find osiris.yaml"

**Solution:**
```bash
# Verify OSIRIS_HOME points to correct directory
cat ~/.claude.json | grep "OSIRIS_HOME"
# Should show: "OSIRIS_HOME": "/full/path/to/examples/get-started"

# Verify osiris.yaml exists there
ls -la "$OSIRIS_REPO/examples/get-started/osiris.yaml"
# Should show file

# If missing, reinitialize:
cd "$OSIRIS_REPO/examples/get-started"
source "$OSIRIS_REPO/.venv/bin/activate"
osiris init
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
