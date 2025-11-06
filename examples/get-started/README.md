# Get Started Tutorial: E-commerce Analytics

**Level:** Beginner
**Time:** 15-30 minutes
**Idempotent:** Yes - safe to run multiple times

Learn to build deterministic data pipelines by describing what you want in plain English.

---

## 🧪 Testing Version

**Clone and setup:**
```bash
git clone -b examples/get-started-tutorial https://github.com/pavel242242/osiris.git
cd osiris

# Session 1: Install Osiris
source .venv/bin/activate || (python3.11 -m venv .venv && source .venv/bin/activate)
pip install -e .

# Session 2: Run tutorial
cd examples/get-started
claude
```

---

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
# Remove previous pipeline outputs
rm -f *.csv *.yaml
rm -rf pipelines/ build/ aiop/ run_logs/ .osiris/

echo "✅ Cleanup complete - ready for fresh start!"
```

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

Please help me:
1. Initialize an Osiris project in this directory (osiris init)
2. Build a pipeline that:
   - Cleans data (remove records with missing product_id)
   - Joins sales with product catalog on product_id
   - Calculates revenue (quantity * price)
   - Aggregates by category and region: total_revenue, order_count, avg_order_value
   - Outputs to category_performance.csv

As we work, please explain:
- Which Osiris MCP tools you're using at each step
- What the OML pipeline structure looks like
- How deterministic compilation works

I want to understand the process, not just see the results.
```

---

## What Happens

Claude will guide you through:

### 1. Initialize Project
```bash
osiris init
```

Creates:
- `osiris.yaml` - Project configuration
- `pipelines/` - Where OML files are saved
- `build/` - Compiled manifests
- `aiop/` - AI Operation Packages
- `run_logs/` - Execution logs

### 2. Build Pipeline

Claude uses Osiris MCP tools to:
- Discover data schemas (`osiris_discovery_run`)
- Get OML syntax guidance (`osiris_oml_schema_get`)
- List available components (`osiris_components_list`)
- Validate the pipeline (`osiris_oml_validate`)
- Save the pipeline (`osiris_oml_save`)

### 3. Execute Pipeline

Creates `category_performance.csv` with results like:

```csv
category,region,total_revenue,order_count,avg_order_value
Electronics,North America,1349.88,9,149.99
Electronics,Europe,1049.91,5,209.98
Furniture,North America,799.96,5,159.99
...
```

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
How Claude communicates with Osiris to build pipelines. Claude calls MCP tools like:
- `osiris_components_list` - List available extractors/processors/writers
- `osiris_oml_schema_get` - Get OML syntax documentation
- `osiris_oml_validate` - Validate pipeline syntax
- `osiris_oml_save` - Save pipeline definition
- `osiris_discovery_run` - Analyze data sources

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

### Issue: "osiris: command not found"

**Fix:**
```bash
# Activate virtual environment
source ../../.venv/bin/activate

# Verify installation
osiris --version
```

If still not working, run setup: see [SETUP.md](SETUP.md)

### Issue: "No MCP tools available"

**Fix:**
1. Verify Osiris is installed: `osiris --version`
2. Restart Claude Code
3. Run `/mcp` to check MCP server status

### Issue: "FileNotFoundError" for CSV files

**Fix:**
```bash
# Verify data files exist
ls -la data/
# Should show: sales_data.csv, product_catalog.csv

# If missing, check you're in examples/get-started directory
pwd  # Should end with: examples/get-started
```

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
