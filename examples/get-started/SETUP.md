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

## What Gets Installed

- ✅ `osiris` command-line tool
- ✅ All components (CSV, MySQL, Supabase, DuckDB, etc.)
- ✅ MCP server integration
- ✅ Dependencies (Rich, PyYAML, DuckDB, etc.)

---

## Verification

```bash
# Check Osiris is installed
osiris --version

# Check components are available
osiris components list

# Check Python environment
python --version  # Should be 3.11+
```

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

---

## Next Steps

Setup complete! Now you can:

1. **Run the get-started tutorial**: `cd examples/get-started` and see README.md
2. **Try other examples**: Explore other tutorials in `examples/`
3. **Read the docs**: Check `docs/quickstart.md` for manual pipeline creation

---

## Re-running Setup

This setup is **idempotent** - you can run it again anytime:
- If something breaks
- After pulling new changes
- To update to the latest version

Just run the installation commands again. They will skip steps that are already complete.
