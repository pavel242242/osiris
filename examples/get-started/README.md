# Get Started with Osiris

**Time:** 15-30 minutes
**Level:** Beginner

Learn to build deterministic data pipelines by describing what you want in plain English.

---

## 🧪 Testing Version

**Clone the test branch:**
```bash
git clone -b examples/get-started-tutorial https://github.com/pavel242242/osiris.git
cd osiris/examples/get-started
claude
```

Then use the prompt:
```
I want to learn Osiris by building my first data pipeline following the tutorial in examples/get-started/README.md

Please read this README and guide me through:
1. Installing Osiris
2. Building the category performance pipeline
3. Explaining MCP tools and OML as we work
```

---

## What You'll Build

A data pipeline that answers: **"Which product categories are performing best by region?"**

The pipeline will:
- Read sales and product data from CSV files
- Clean data (remove missing values)
- Join datasets on product_id
- Calculate revenue (quantity × price)
- Aggregate by category and region
- Output results to CSV

---

## Quick Start

### Prerequisites

- Python 3.11+
- Claude Code CLI

### Initial Prompt

Start Claude Code in this directory and use this prompt:

```
I want to learn Osiris by building my first data pipeline.

I'm in the examples/get-started directory which contains:
- data/sales_data.csv - transaction records
- data/product_catalog.csv - product details

Please help me:
1. Install Osiris (pip install from the repo root)
2. Initialize an Osiris project here
3. Build a pipeline that analyzes category performance by region

As we work, explain:
- Which Osiris MCP tools you're using
- What the OML pipeline structure looks like
- How deterministic compilation works

The business question: Which product categories perform best by region?

Required pipeline steps:
1. Clean data (remove records with missing product_id)
2. Join sales with product catalog on product_id
3. Calculate revenue (quantity * price)
4. Aggregate by category and region: total_revenue, order_count, avg_order_value
5. Output to category_performance.csv
```

---

## What Happens

Claude will guide you through:

1. **Install Osiris**

   Since you cloned the repo, install in development mode:
   ```bash
   cd ../..  # Go to repo root
   pip install -e .  # Install from cloned repo
   ```

   (Alternative: If you didn't clone the repo, just run `pip install osiris-pipeline`)

2. **Initialize Project**
   ```bash
   cd examples/get-started
   osiris init
   ```

3. **Build Pipeline**
   - Claude uses Osiris MCP tools to create OML manifest
   - Validates and executes the pipeline
   - Shows you results and explains each step

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

## Expected Output

After running the pipeline, you'll get `category_performance.csv`:

```csv
category,region,total_revenue,order_count,avg_order_value
Electronics,North America,1349.88,9,149.99
Electronics,Europe,1049.91,5,209.98
Furniture,North America,799.96,5,159.99
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
Same input + same manifest = same output, **always**.

### MCP (Model Context Protocol)
How Claude communicates with Osiris to build pipelines.

---

## Next Steps

After completing this tutorial:

1. **Modify the pipeline**:
   - Filter by date range
   - Add more aggregations
   - Output to different formats

2. **Use your own data**:
   - Replace the CSV files
   - Tell Claude about your data structure
   - Build custom analyses

3. **Explore advanced features**:
   - Database connections
   - API extractors
   - Custom processors
   - Scheduled pipelines

---

## Troubleshooting

### Issue: "osiris: command not found"
```bash
# Make sure you're in a venv and Osiris is installed
pip install osiris-pipeline
# or from repo root
pip install -e .
```

### Issue: "No MCP tools available"
- Check MCP server is configured in `.mcp.json`
- Restart Claude Code
- Run `/mcp` to verify connection

---

## Support

- **Osiris Issues**: [GitHub Issues](https://github.com/keboola/osiris/issues)
- **Discussions**: [GitHub Discussions](https://github.com/keboola/osiris/discussions)
- **Documentation**: [Main README](../../README.md)

Happy learning! 🚀
