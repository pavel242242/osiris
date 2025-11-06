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

### Start Claude Code

```bash
cd examples/get-started
claude
```

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

**Session 2 complete!** You now have a validated OML pipeline ready to execute.

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
**Time:** 5 minutes
**Exit Claude Code for this session**

Now that you have a validated OML pipeline, it's time to execute it.

### Step 1: Compile the Pipeline

```bash
cd examples/get-started
source ../../.venv/bin/activate
osiris compile pipelines/category_performance.oml.yaml
```

This creates a **deterministic manifest** in `build/` directory. Same OML + same data = same manifest always.

### Step 2: Run the Pipeline

```bash
osiris run --last-compile --verbose
```

**What happens:**
- Reads CSV files from `data/`
- Filters out records with missing product_id
- Joins sales with product catalog
- Calculates revenue (quantity × price)
- Aggregates by category and region
- Writes results to `category_performance.csv`

### Step 3: View Results

```bash
cat category_performance.csv
```

**Expected output:**
```csv
category,region,total_revenue,order_count,avg_order_value
Electronics,North America,1349.88,9,149.99
Electronics,Europe,1049.91,5,209.98
Furniture,North America,799.96,5,159.99
...
```

### Step 4: View Execution Logs (Optional)

```bash
# List execution sessions
osiris logs list

# View HTML report (opens in browser)
osiris logs html --open
```

The HTML report shows:
- Session metadata
- Step-by-step execution trace
- Performance metrics
- Full event/metrics trail

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
cd examples/get-started

# Remove generated files (keeps sample data)
rm -f *.csv
rm -rf pipelines/ build/ aiop/ run_logs/ .osiris/
rm -f osiris.yaml osiris_connections.yaml

echo "✅ Ready for fresh start - run osiris init to begin Session 1"
```

**Note:** This only removes tutorial outputs. Your Osiris installation and MCP configuration remain intact.

---

## Troubleshooting

### Session 1 Issues (Setup & Init)

**Issue: "osiris: command not found"**
```bash
# Activate virtual environment
cd "$(git rev-parse --show-toplevel)"
source .venv/bin/activate
osiris --version
```

**Issue: MCP configuration failed**
- See [SETUP.md](SETUP.md) for detailed MCP setup instructions
- Ensure OSIRIS_HOME environment variable is set in MCP config

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
