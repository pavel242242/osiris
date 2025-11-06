# Get Started Tutorial: E-commerce Analytics

**Level:** Beginner
**Time:** 15-30 minutes total (across 3 sessions)
**Idempotent:** Yes - safe to run multiple times

Learn to build deterministic data pipelines using a 3-session workflow:
1. **Setup & Init** (one-time) - Terminal + CLI
2. **Build Pipeline** (repeatable) - Claude Code + MCP
3. **Execute Pipeline** (repeatable) - Terminal + CLI


---

## Session 1: Setup & Init (One-Time)

**Interface:** Terminal + CLI
**Time:** 5-10 minutes

### Step 1: Install and Configure Osiris

See [SETUP.md](SETUP.md) for complete installation instructions:
- Install Osiris in virtual environment
- Configure MCP server with Claude Code
- Verify installation

### Step 2: Initialize Project

```bash
cd examples/get-started
source ../../.venv/bin/activate
osiris init
```

This creates:
- `osiris.yaml` - Project configuration
- `osiris_connections.yaml` - Connection configuration (for databases)
- `.osiris/` - MCP logs and artifacts directory

**Session 1 is complete!** You're now ready to build pipelines with Claude.

---

## What You'll Build

A data pipeline that answers: **"Which product categories are performing best by region?"**

The pipeline will:
- Read sales and product data from CSV files
- Clean data (remove records with missing product_id)
- Join datasets on product_id
- Calculate revenue (quantity × price)
- Aggregate by category and region
- Output results to CSV

---

## Session 2: Build Pipeline (Repeatable)

**Interface:** Claude Code + MCP only
**Time:** 5-10 minutes
**No CLI commands needed!**

### ⚠️ CRITICAL: Pre-Flight Check

**Before starting Claude Code, verify MCP is configured:**

```bash
# 1. Check MCP server is configured
cat ~/.config/claude/mcp.json | grep -A3 "osiris"
# ✅ Expected: Shows osiris configuration with OSIRIS_HOME

# 2. Test MCP server can start
python -m osiris.cli.mcp_entrypoint --selftest
# ✅ Expected: "Selftest completed in <1.3s"
# ⏱️ Expected time: <2 seconds

# ⚠️ If either fails, go back to Session 1 (SETUP.md)
```

### Start Claude Code

**CRITICAL: You MUST start Claude from the correct directory!**

```bash
# Navigate to tutorial directory FIRST
cd "$OSIRIS_REPO/examples/get-started"

# Verify you're in the right place
pwd
# ✅ Expected: /full/path/to/osiris/examples/get-started

ls osiris.yaml
# ✅ Expected: osiris.yaml (file exists)

# THEN start Claude Code
claude
```

**⚠️ Why this matters:** The MCP server looks for `osiris.yaml` in your current working directory first. If you start Claude from the wrong directory, MCP won't find your project configuration!

**First thing to do in Claude:** Run `/mcp` command
- ✅ Expected: "osiris" listed with status "Connected"
- ✅ Expected tools: guide_start, oml_schema_get, oml_validate, oml_save
- ⚠️ If not connected, exit Claude and check pre-flight steps above

### Use This Prompt:
```
I want to build my first Osiris data pipeline using the sample data in this directory.

Sample data:
- data/sales_data.csv - 30 transaction records
- data/product_catalog.csv - 10 product details

Business question: Which product categories perform best by region?

Please use Osiris MCP tools to help me:
1. Get the OML schema (use guide_start and oml_schema_get MCP tools)
2. Build a pipeline that:
   - Reads CSV files from data/ directory
   - Cleans data (remove records with missing product_id)
   - Joins sales with product catalog on product_id
   - Calculates revenue (quantity * price)
   - Aggregates by category and region: total_revenue, order_count, avg_order_value
   - Outputs to category_performance.csv
3. Validate the OML (use oml_validate MCP tool)
4. Save the pipeline (use oml_save MCP tool)

As we work, please explain:
- Which Osiris MCP tools you're using at each step
- What the OML pipeline structure looks like
- How the validation works

I want to understand the MCP-based workflow, not just see the results.
```

### What Happens in Session 2

Claude will use Osiris MCP tools to guide you through:

**Step 1:** Claude calls `guide_start` MCP tool to understand the workflow

**Step 2:** Claude calls `oml_schema_get` to get the OML v0.1.0 JSON schema

**Step 3:** Claude creates an OML pipeline definition that:
- Uses `filesystem.csv_reader` to read CSV files
- Uses `core.filter` to remove records with missing product_id
- Uses `core.join` to join sales with product catalog
- Uses `core.compute` to calculate revenue (quantity × price)
- Uses `core.aggregate` to sum by category and region
- Uses `filesystem.csv_writer` to output results

**Step 4:** Claude calls `oml_validate` to check:
- OML structure is correct
- All required fields are present
- Business logic is valid
- Connections and components exist

**Step 5:** Claude calls `oml_save` to save the validated pipeline to `pipelines/category_performance.oml.yaml`

### Session 2 Exit Criteria

**Verify pipeline was created successfully:**

```bash
# Exit Claude Code and check in terminal:

# ✅ Checkpoint 1: Pipeline file exists
ls -la "$OSIRIS_REPO/examples/get-started/pipelines/category_performance.oml.yaml"
# Expected: File exists, size > 0 bytes

# ✅ Checkpoint 2: Pipeline contains valid YAML
head -20 "$OSIRIS_REPO/examples/get-started/pipelines/category_performance.oml.yaml"
# Expected: Shows oml_version, id, steps sections

# ✅ Checkpoint 3: MCP logs show successful operations
ls -la "$OSIRIS_REPO/examples/get-started/.osiris/mcp/logs/audit/"
# Expected: audit-YYYY-MM-DD.jsonl file with recent timestamp

echo "✅ Session 2 complete! Ready for Session 3"
```

**⚠️ If pipeline file missing:**
- Claude may have encountered an error during oml_save
- Check Claude's conversation for error messages
- Re-run Session 2 with the prompt again

**Quick Verification Script:**
```bash
# Run automated verification
./verify-session-2.sh

# This checks pipeline file, YAML structure, and MCP logs
```

**Key Point:** Everything happens through MCP tools. No CLI commands in this session!

---

## Sample Data

### sales_data.csv (30 transactions)
```csv
order_id,product_id,region,quantity,price,order_date,customer_id
1001,P001,North America,2,29.99,2024-01-15,C001
1002,P002,Europe,1,149.99,2024-01-15,C002
...
```

**Note:** Includes intentional data quality issues (missing product_id values) for learning.

### product_catalog.csv (10 products)
```csv
product_id,product_name,category,cost_price
P001,Wireless Mouse,Electronics,15.00
P002,USB-C Hub,Electronics,75.00
...
```

---

## Session 3: Execute Pipeline (Repeatable)

**Interface:** Terminal + CLI
**Time:** 5-10 minutes
**Exit Claude Code for this session**

Now that you have a validated OML pipeline, it's time to execute it.

### Step 1: Compile the Pipeline

```bash
cd "$OSIRIS_REPO/examples/get-started"
source "$OSIRIS_REPO/.venv/bin/activate"
osiris compile pipelines/category_performance.oml.yaml
```
⏱️ Expected time: <5 seconds

**Expected output:**
```
✅ Compilation successful
📦 Manifest saved to: build/category_performance-<hash>.manifest.yaml
```

**⚠️ If "FileNotFoundError":**
```bash
# Check pipeline exists
ls -la pipelines/category_performance.oml.yaml
# If missing, go back to Session 2

# Check you're in correct directory
pwd  # Should end with: examples/get-started
```

**Validation Checkpoint:**
```bash
# Verify manifest was created
ls -la build/*.manifest.yaml
# ✅ Expected: At least one .manifest.yaml file
```

### Step 2: Run the Pipeline

```bash
osiris run --last-compile --verbose
```
⏱️ Expected time: <10 seconds (CSV data is small)

**Expected output:**
```
🚀 Starting pipeline execution...
📖 Step 1/6: Reading sales_data.csv...
✓ Loaded 30 rows
📖 Step 2/6: Reading product_catalog.csv...
✓ Loaded 10 rows
🔧 Step 3/6: Filtering records...
✓ Removed 2 rows with missing product_id
🔧 Step 4/6: Joining datasets...
✓ Joined on product_id
🔧 Step 5/6: Calculating revenue...
✓ Added revenue column
🔧 Step 6/6: Aggregating by category and region...
✓ Grouped into 5 categories
✅ Pipeline completed successfully
```

**⚠️ If execution fails:**
```bash
# Check data files exist
ls -la data/*.csv
# Should show: sales_data.csv, product_catalog.csv

# View detailed error
osiris logs list  # Get most recent run ID
osiris logs show <run-id>  # View error details
```

### Step 3: View Results

```bash
cat category_performance.csv
```
⏱️ Expected time: <1 second

**Expected output:**
```csv
category,region,total_revenue,order_count,avg_order_value
Electronics,North America,1349.88,9,149.99
Electronics,Europe,1049.91,5,209.98
Furniture,North America,799.96,5,159.99
Home & Garden,Europe,649.95,4,162.49
Office Supplies,Asia,449.97,3,149.99
```

**⚠️ If file is empty or missing:**
```bash
# Check pipeline run succeeded
osiris logs list
# Status should show "completed"

# Check for errors in logs
osiris logs html --open
```

### Step 4: View Execution Logs (Optional)

```bash
# List all execution sessions
osiris logs list
# ✅ Expected: Shows at least one run with status "completed"

# View HTML report (opens in browser)
osiris logs html --open
```
⏱️ Expected time: <3 seconds

**The HTML report shows:**
- Session metadata (when, duration, status)
- Step-by-step execution trace
- Performance metrics (rows processed, time per step)
- Full event/metrics trail for debugging

### Session 3 Exit Criteria

**All checkpoints must pass:**

```bash
# ✅ Checkpoint 1: Manifest compiled
ls -la build/*.manifest.yaml
# Expected: File exists

# ✅ Checkpoint 2: Pipeline executed
osiris logs list | head -1
# Expected: Shows recent run with "completed" status

# ✅ Checkpoint 3: Output file created
ls -la category_performance.csv
# Expected: File exists, size > 0 bytes

# ✅ Checkpoint 4: Output has expected structure
head -1 category_performance.csv
# Expected: category,region,total_revenue,order_count,avg_order_value

# ✅ Checkpoint 5: Output has data rows
wc -l category_performance.csv
# Expected: At least 6 lines (1 header + 5 data rows)

echo "✅ Session 3 complete! You've executed your first Osiris pipeline"
```

**Quick Verification Script:**
```bash
# Run automated verification
./verify-session-3.sh

# This checks manifest, execution logs, output file structure, and data
```

**Session 3 complete!** You've successfully executed your first Osiris pipeline.

---

## Key Concepts

### OML (Osiris Markup Language)
YAML-based declarative language defining your pipeline:
- **Extractors**: Read data (CSV, databases, APIs)
- **Processors**: Transform data (filter, join, compute, aggregate)
- **Writers**: Output results

### Deterministic Compilation
Same input + same manifest = same output, **always**. No hidden state or randomness.

### MCP (Model Context Protocol)
**Primary interface for Session 2 (Build Pipeline).** Claude communicates with Osiris through MCP tools:
- `guide_start` - Get workflow guidance (call this first!)
- `oml_schema_get` - Get OML v0.1.0 JSON schema
- `components_list` - List available extractors/processors/writers
- `oml_validate` - Validate pipeline syntax and business logic
- `oml_save` - Save validated pipeline definition
- `discovery_request` - Analyze database schemas (for database sources)
- `connections_list` - List configured connections
- `aiop_list` / `aiop_show` - Debug previous runs

### 3-Session Workflow
1. **Session 1** (Terminal + CLI): One-time setup and project initialization
2. **Session 2** (Claude + MCP): Conversational pipeline building and validation
3. **Session 3** (Terminal + CLI): Compile, run, and view logs

**Separation of concerns:** MCP for AI-assisted design, CLI for deterministic execution.

---

## Iterating: Session 2 ↔ Session 3

After running your first pipeline, you can iterate between Session 2 and Session 3:

### Modify the Pipeline (Session 2 - Claude + MCP)

Start Claude Code again and ask:
```
Can you modify the category_performance pipeline to:
1. Only include orders from January 2024
2. Filter for orders over $50
3. Sort by total_revenue descending
```

Claude will:
- Read the existing OML from `pipelines/category_performance.oml.yaml`
- Modify it based on your requirements
- Validate with `oml_validate`
- Save the updated version with `oml_save`

### Execute Modified Pipeline (Session 3 - Terminal + CLI)

```bash
osiris compile pipelines/category_performance.oml.yaml
osiris run --last-compile --verbose
cat category_performance.csv  # View new results
```

**This workflow is repeatable:** Design with Claude (Session 2) → Execute in terminal (Session 3) → Repeat.

---

## Cleanup for Fresh Start

To re-run the tutorial from scratch:

```bash
cd "$OSIRIS_REPO/examples/get-started"

# Remove generated files (keeps sample data)
rm -f *.csv
rm -rf pipelines/ build/ aiop/ run_logs/ .osiris/
rm -f osiris.yaml osiris_connections.yaml

echo "✅ Cleanup complete!"
echo "To restart:"
echo "1. Run 'osiris init' to begin Session 1 Step 2"
echo "2. MCP is still configured, no need to reconfigure"
```

**What this removes:**
- Output CSV files
- Generated pipelines (from Session 2)
- Compiled manifests (from Session 3)
- Execution logs
- Project configuration files

**What this keeps:**
- Sample data files (data/*.csv)
- Osiris installation (.venv)
- MCP configuration

**Note:** You can re-run Session 2 and Session 3 without cleanup. This is only for a completely fresh start.

---

## Troubleshooting

### Session 1 Issues (Setup & Init)

**Issue: "osiris: command not found"**
```bash
# Activate virtual environment
cd "$OSIRIS_REPO"
source .venv/bin/activate
osiris --version

# ⚠️ If OSIRIS_REPO not set:
# Find your osiris repo directory and run:
# export OSIRIS_REPO="/full/path/to/osiris"
```

**Issue: MCP configuration failed**
- See [SETUP.md](SETUP.md) for detailed MCP setup instructions
- Verify OSIRIS_HOME is set: `cat ~/.config/claude/mcp.json | grep OSIRIS_HOME`

### Session 2 Issues (Build Pipeline - MCP)

**Issue: "No MCP tools available" or "osiris server not found"**
1. Run `/mcp` in Claude Code to check server status
2. Verify MCP configuration:
```bash
cat ~/.config/claude/mcp.json | grep -A10 osiris
# Should show OSIRIS_HOME pointing to examples/get-started
```
3. Restart Claude Code completely
4. If still not working, see [SETUP.md](SETUP.md)

**Issue: "MCP can't find osiris.yaml"**
- Ensure you ran `osiris init` in Session 1
- Check OSIRIS_HOME in MCP config points to correct directory
- Verify `osiris.yaml` exists in `examples/get-started/`

**Issue: "FileNotFoundError" for CSV files**
```bash
cd examples/get-started
ls -la data/  # Should show sales_data.csv, product_catalog.csv
```

### Session 3 Issues (Execute Pipeline - CLI)

**Issue: "Pipeline not found" when compiling**
```bash
# Check pipeline was saved in Session 2
ls -la pipelines/
# Should show: category_performance.oml.yaml
```

**Issue: "No such file or directory" when running**
- Ensure you ran `osiris compile` before `osiris run`
- Check `build/` directory exists and contains compiled manifest

**Issue: No output CSV created**
- Check run logs: `osiris logs list`
- View detailed logs: `osiris logs html --open`
- Verify data files exist in `data/` directory

---

## Next Steps

🎉 **Congratulations!** You've completed the 3-session workflow!

**What you've learned:**
- ✅ Session 1: Setup and project initialization (one-time)
- ✅ Session 2: AI-assisted pipeline building with MCP (repeatable)
- ✅ Session 3: Deterministic execution with CLI (repeatable)

**What to try next:**

1. **Iterate the workflow** - Modify pipeline in Session 2, execute in Session 3, repeat
2. **Use your own data** - Replace CSV files and rebuild pipeline with Claude
3. **Connect to databases** - See `docs/quickstart.md` for MySQL/Supabase examples
4. **Explore other examples** - Check other tutorials in `examples/`

**Remember the workflow:**
```
Session 1 (one-time) → Session 2 (design) ↔ Session 3 (execute)
```

---

## Support

- **Issues**: [GitHub Issues](https://github.com/keboola/osiris/issues)
- **Discussions**: [GitHub Discussions](https://github.com/keboola/osiris/discussions)
- **Documentation**: [Main README](../../README.md)

---

**Remember:** This tutorial follows a **3-session workflow**:
1. **Session 1** (one-time): Setup & Init - Terminal + CLI
2. **Session 2** (repeatable): Build Pipeline - Claude Code + MCP
3. **Session 3** (repeatable): Execute Pipeline - Terminal + CLI

Each session is **idempotent** - safe to run multiple times. See "Cleanup for Fresh Start" to reset.
