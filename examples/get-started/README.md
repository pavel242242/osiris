# Get Started Tutorial: E-commerce Analytics

**Level:** Beginner
**Time:** 15-30 minutes
**Idempotent:** Yes - safe to run multiple times

Learn to build deterministic data pipelines by describing what you want in plain English.


## Prerequisites

✅ **Osiris must be installed first**

If you haven't installed Osiris yet, see [SETUP.md](SETUP.md).

Verify installation:
```bash
osiris --version  # Should show v0.5.x
```

---

## Before You Start: Cleanup (Optional)

If you've run this tutorial before, clean up previous outputs:

```bash
cd examples/get-started

# Remove previous pipeline outputs and generated files
rm -f *.csv
rm -rf pipelines/ build/ aiop/ run_logs/ .osiris/
rm -f osiris.yaml osiris_connections.yaml

echo "✅ Cleanup complete - ready for fresh start!"
```

**Note:** This only removes tutorial outputs, not your Osiris installation or MCP configuration.

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

## Tutorial Prompt

Start Claude Code in this directory:

```bash
cd examples/get-started
claude
```

**Use this prompt:**
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

---

## What Happens

Claude will use Osiris MCP tools to guide you through:

### 1. Get Workflow Guidance
Claude calls `guide_start` MCP tool to understand the workflow and validation requirements.

### 2. Understand OML Schema
Claude calls `oml_schema_get` to get the OML v0.1.0 JSON schema and available components.

### 3. Build Pipeline
Claude creates an OML pipeline definition that:
- Uses `filesystem.csv_reader` component to read CSV files
- Uses `core.filter` to remove records with missing product_id
- Uses `core.join` to join sales with product catalog
- Uses `core.compute` to calculate revenue (quantity × price)
- Uses `core.aggregate` to sum by category and region
- Uses `filesystem.csv_writer` to output results

### 4. Validate Pipeline
Claude calls `oml_validate` to check:
- OML structure is correct
- All required fields are present
- Business logic is valid (e.g., primary_key for upsert modes)
- Connections and components exist

### 5. Save Pipeline
Claude calls `oml_save` to save the validated OML pipeline draft to `pipelines/` directory.

### 6. Result
Creates `category_performance.csv` with results like:

```csv
category,region,total_revenue,order_count,avg_order_value
Electronics,North America,1349.88,9,149.99
Electronics,Europe,1049.91,5,209.98
Furniture,North America,799.96,5,159.99
...
```

**Key Point:** Everything happens through MCP tools. No direct CLI commands needed!

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

## Key Concepts

### OML (Osiris Markup Language)
YAML-based declarative language defining your pipeline:
- **Extractors**: Read data (CSV, databases, APIs)
- **Processors**: Transform data (filter, join, compute, aggregate)
- **Writers**: Output results

### Deterministic Compilation
Same input + same manifest = same output, **always**. No hidden state or randomness.

### MCP (Model Context Protocol)
**Primary interface** for working with Osiris. Claude communicates with Osiris through MCP tools:
- `guide_start` - Get workflow guidance (call this first!)
- `oml_schema_get` - Get OML v0.1.0 JSON schema
- `components_list` - List available extractors/processors/writers
- `oml_validate` - Validate pipeline syntax and business logic
- `oml_save` - Save validated pipeline definition
- `discovery_request` - Analyze database schemas (for database sources)
- `connections_list` - List configured connections
- `aiop_list` / `aiop_show` - Debug previous runs

**The CLI is only for contributors.** Users work through Claude Code + MCP tools.

---

## Exploring Further

After the pipeline runs successfully, try:

**Show me the pipeline:**
```
Can you show me the OML pipeline that was created?
```

**Modify the analysis:**
```
Can you modify the analysis to:
1. Only include orders from January 2024
2. Filter for orders over $50
3. Sort by total_revenue descending
```

**Compare results:**
```
How do the results differ from the original?
```

**Use your own data:**
```
I have my own CSV files at [path]. Can you adapt this pipeline?
```

---

## Troubleshooting

### Issue: "No MCP tools available" or "osiris server not found"

**Fix:**
1. Verify Osiris MCP is configured:
```bash
# Check MCP configuration
cat ~/.config/claude/mcp.json | grep osiris

# If not found, reconfigure:
cd "$(git rev-parse --show-toplevel)"
claude mcp add osiris "$(pwd)/.venv/bin/python" -m osiris.cli.mcp_entrypoint
```

2. Restart Claude Code completely (exit and relaunch)
3. Run `/mcp` in new session to verify "osiris" is listed

### Issue: "Virtual environment not found" in MCP

**Fix:**
```bash
# Reinstall with correct path
cd "$(git rev-parse --show-toplevel)"
python3.11 -m venv .venv
source .venv/bin/activate
pip install -e .

# Reconfigure MCP with absolute path
claude mcp add osiris "$(pwd)/.venv/bin/python" -m osiris.cli.mcp_entrypoint
```

### Issue: MCP tool errors about missing configuration

**Fix:**
```bash
# Verify osiris.yaml exists in examples/get-started
cd examples/get-started
ls -la osiris.yaml

# If missing, initialize:
cd "$(git rev-parse --show-toplevel)"
source .venv/bin/activate
cd examples/get-started
osiris init
```

### Issue: "FileNotFoundError" for CSV files

**Fix:**
```bash
# Verify data files exist
cd examples/get-started
ls -la data/
# Should show: sales_data.csv, product_catalog.csv
```

If problems persist, run cleanup and reinstall: see [SETUP.md](SETUP.md)

---

## Next Steps

🎉 **Congratulations!** You've built your first Osiris pipeline.

**What to try next:**

1. **Modify the pipeline** - Change aggregations, add filters, try different outputs
2. **Use your own data** - Replace the CSV files with your own
3. **Connect to databases** - See `docs/quickstart.md` for MySQL examples
4. **Explore other examples** - Check other tutorials in `examples/`

---

## Support

- **Issues**: [GitHub Issues](https://github.com/keboola/osiris/issues)
- **Discussions**: [GitHub Discussions](https://github.com/keboola/osiris/discussions)
- **Documentation**: [Main README](../../README.md)

---

**Remember:** This tutorial is **idempotent**. You can run it multiple times safely. Just clean up the outputs first if you want a fresh start!
