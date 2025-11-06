#!/bin/bash
# Osiris Get Started Tutorial - Session 3 Verification Script
# This script verifies that Session 3 (Execute Pipeline) completed successfully

set -e  # Exit on error

echo "🔍 Osiris Get Started - Session 3 Verification"
echo "=============================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FAILED=0

echo "Checkpoint 1: Manifest Compiled"
echo "--------------------------------"
if [ -d "build" ]; then
    MANIFEST_COUNT=$(find build -name "*.manifest.yaml" 2>/dev/null | wc -l | tr -d ' ')

    if [ "$MANIFEST_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✅ Compiled manifest found${NC}"
        echo "   Manifest files: $MANIFEST_COUNT"

        # Show most recent manifest
        LATEST_MANIFEST=$(ls -t build/*.manifest.yaml 2>/dev/null | head -1)
        if [ -n "$LATEST_MANIFEST" ]; then
            echo "   Latest: $(basename "$LATEST_MANIFEST")"
        fi
    else
        echo -e "${RED}❌ No manifest files found in build/${NC}"
        echo "   Fix: Run 'osiris compile pipelines/category_performance.oml.yaml'"
        FAILED=$((FAILED + 1))
    fi
else
    echo -e "${RED}❌ build/ directory not found${NC}"
    echo "   Fix: Run 'osiris compile pipelines/category_performance.oml.yaml'"
    FAILED=$((FAILED + 1))
fi
echo ""

echo "Checkpoint 2: Pipeline Executed"
echo "--------------------------------"
# Check if osiris command is available
if command -v osiris &> /dev/null; then
    # Try to get logs
    if osiris logs list &> /dev/null; then
        LOG_OUTPUT=$(osiris logs list 2>&1)
        if echo "$LOG_OUTPUT" | grep -q "completed\|running"; then
            echo -e "${GREEN}✅ Pipeline execution found in logs${NC}"

            # Check for completed runs
            if echo "$LOG_OUTPUT" | grep -q "completed"; then
                echo -e "   ${GREEN}✓${NC} Found 'completed' run(s)"
            else
                echo -e "   ${YELLOW}⚠️${NC}  No 'completed' runs found"
            fi
        else
            echo -e "${YELLOW}⚠️  No execution logs found${NC}"
            echo "   Run: osiris run --last-compile --verbose"
        fi
    else
        echo -e "${YELLOW}⚠️  Could not access logs${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  osiris command not found${NC}"
    echo "   Activate venv: source \$OSIRIS_REPO/.venv/bin/activate"
fi
echo ""

echo "Checkpoint 3: Output File Created"
echo "----------------------------------"
if [ -f "category_performance.csv" ]; then
    SIZE=$(wc -c < category_performance.csv | tr -d ' ')
    LINES=$(wc -l < category_performance.csv | tr -d ' ')

    echo -e "${GREEN}✅ Output file exists${NC}"
    echo "   File: category_performance.csv"
    echo "   Size: $SIZE bytes"
    echo "   Lines: $LINES"

    if [ "$SIZE" -eq 0 ]; then
        echo -e "${RED}❌ Output file is empty${NC}"
        FAILED=$((FAILED + 1))
    elif [ "$LINES" -lt 2 ]; then
        echo -e "${RED}❌ Output file has no data rows${NC}"
        FAILED=$((FAILED + 1))
    fi
else
    echo -e "${RED}❌ Output file not found${NC}"
    echo "   Expected: category_performance.csv"
    echo "   Fix: Run 'osiris run --last-compile --verbose'"
    FAILED=$((FAILED + 1))
fi
echo ""

echo "Checkpoint 4: Output Has Expected Structure"
echo "--------------------------------------------"
if [ -f "category_performance.csv" ]; then
    HEADER=$(head -1 category_performance.csv)
    EXPECTED="category,region,total_revenue,order_count,avg_order_value"

    if [ "$HEADER" = "$EXPECTED" ]; then
        echo -e "${GREEN}✅ Header matches expected structure${NC}"
        echo "   $HEADER"
    else
        echo -e "${RED}❌ Header doesn't match expected structure${NC}"
        echo "   Expected: $EXPECTED"
        echo "   Got: $HEADER"
        FAILED=$((FAILED + 1))
    fi
fi
echo ""

echo "Checkpoint 5: Output Has Data Rows"
echo "-----------------------------------"
if [ -f "category_performance.csv" ]; then
    DATA_LINES=$(tail -n +2 category_performance.csv | wc -l | tr -d ' ')

    if [ "$DATA_LINES" -ge 5 ]; then
        echo -e "${GREEN}✅ Output has data rows${NC}"
        echo "   Data rows: $DATA_LINES"

        # Show sample of output
        echo ""
        echo "   Sample output (first 3 data rows):"
        tail -n +2 category_performance.csv | head -3 | while read line; do
            echo "   $line"
        done
    else
        echo -e "${YELLOW}⚠️  Expected at least 5 data rows, got $DATA_LINES${NC}"
        echo "   This may indicate data processing issues"
    fi
fi
echo ""

echo "Checkpoint 6: Execution Logs Exist"
echo "-----------------------------------"
if [ -d "run_logs" ] || [ -d "logs" ]; then
    echo -e "${GREEN}✅ Execution logs directory found${NC}"

    # Count log files
    LOG_COUNT=0
    if [ -d "run_logs" ]; then
        LOG_COUNT=$(find run_logs -type f 2>/dev/null | wc -l | tr -d ' ')
    elif [ -d "logs" ]; then
        LOG_COUNT=$(find logs -type f 2>/dev/null | wc -l | tr -d ' ')
    fi

    echo "   Log files: $LOG_COUNT"
else
    echo -e "${YELLOW}⚠️  No execution logs directory found${NC}"
    echo "   (Optional - used for debugging)"
fi
echo ""

# Final summary
echo "=============================================="
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All checkpoints passed!${NC}"
    echo ""
    echo "🎉 Session 3 is complete!"
    echo "🎊 Congratulations! You've successfully:"
    echo "   • Built a pipeline with Claude (Session 2)"
    echo "   • Compiled and executed it (Session 3)"
    echo "   • Generated category_performance.csv"
    echo ""
    echo "📝 Next steps:"
    echo "   • Modify the pipeline in Session 2"
    echo "   • Re-run Session 3 to see new results"
    echo "   • Try your own data!"
    echo ""
    echo "   See README.md 'Iterating' section for ideas"
    exit 0
else
    echo -e "${RED}❌ $FAILED checkpoint(s) failed${NC}"
    echo ""
    echo "📋 Recommended actions:"
    echo "   1. Check execution logs: osiris logs list"
    echo "   2. View HTML report: osiris logs html --open"
    echo "   3. Verify input data files exist: ls -la data/"
    echo "   4. Re-run: osiris run --last-compile --verbose"
    echo ""
    echo "   See README.md Session 3 troubleshooting for details"
    exit 1
fi
