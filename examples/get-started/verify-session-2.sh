#!/bin/bash
# Osiris Get Started Tutorial - Session 2 Verification Script
# This script verifies that Session 2 (Build Pipeline) completed successfully

set -e  # Exit on error

echo "🔍 Osiris Get Started - Session 2 Verification"
echo "=============================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FAILED=0

echo "Checkpoint 1: Pipeline File Exists"
echo "-----------------------------------"
if [ -f "pipelines/category_performance.oml.yaml" ]; then
    SIZE=$(wc -c < pipelines/category_performance.oml.yaml | tr -d ' ')
    echo -e "${GREEN}✅ Pipeline file exists${NC}"
    echo "   Location: pipelines/category_performance.oml.yaml"
    echo "   Size: $SIZE bytes"

    if [ "$SIZE" -eq 0 ]; then
        echo -e "${RED}❌ Pipeline file is empty${NC}"
        FAILED=$((FAILED + 1))
    fi
else
    echo -e "${RED}❌ Pipeline file not found${NC}"
    echo "   Expected: pipelines/category_performance.oml.yaml"
    echo "   Fix: Re-run Session 2 in Claude Code"
    FAILED=$((FAILED + 1))
fi
echo ""

echo "Checkpoint 2: Pipeline Contains Valid YAML"
echo "-------------------------------------------"
if [ -f "pipelines/category_performance.oml.yaml" ]; then
    # Check for required OML fields
    if grep -q "oml_version" pipelines/category_performance.oml.yaml; then
        echo -e "${GREEN}✅ oml_version found${NC}"
    else
        echo -e "${RED}❌ oml_version missing${NC}"
        FAILED=$((FAILED + 1))
    fi

    if grep -q "^id:" pipelines/category_performance.oml.yaml; then
        echo -e "${GREEN}✅ pipeline id found${NC}"
    else
        echo -e "${RED}❌ pipeline id missing${NC}"
        FAILED=$((FAILED + 1))
    fi

    if grep -q "^steps:" pipelines/category_performance.oml.yaml; then
        echo -e "${GREEN}✅ steps section found${NC}"
    else
        echo -e "${RED}❌ steps section missing${NC}"
        FAILED=$((FAILED + 1))
    fi
fi
echo ""

echo "Checkpoint 3: MCP Audit Logs"
echo "-----------------------------"
if [ -d ".osiris/mcp/logs/audit" ]; then
    # Find most recent audit log
    LATEST_LOG=$(ls -t .osiris/mcp/logs/audit/*.jsonl 2>/dev/null | head -1)

    if [ -n "$LATEST_LOG" ]; then
        echo -e "${GREEN}✅ MCP audit logs found${NC}"
        echo "   Latest: $(basename "$LATEST_LOG")"

        # Check if recent (within last hour)
        if [ -n "$(find .osiris/mcp/logs/audit -name "*.jsonl" -mmin -60)" ]; then
            echo -e "   ${GREEN}✓${NC} Recent activity detected (within last hour)"
        else
            echo -e "   ${YELLOW}⚠️${NC}  No recent activity (last hour)"
        fi
    else
        echo -e "${YELLOW}⚠️  No audit log files found${NC}"
        echo "   This is unusual - MCP operations should create logs"
    fi
else
    echo -e "${RED}❌ MCP audit logs directory not found${NC}"
    FAILED=$((FAILED + 1))
fi
echo ""

echo "Checkpoint 4: Pipeline Directory Structure"
echo "-------------------------------------------"
if [ -d "pipelines" ]; then
    echo -e "${GREEN}✅ pipelines/ directory exists${NC}"

    # Count OML files
    OML_COUNT=$(find pipelines -name "*.oml.yaml" 2>/dev/null | wc -l | tr -d ' ')
    echo "   OML files: $OML_COUNT"
else
    echo -e "${RED}❌ pipelines/ directory not found${NC}"
    FAILED=$((FAILED + 1))
fi
echo ""

# Final summary
echo "=============================================="
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All checkpoints passed!${NC}"
    echo ""
    echo "🎉 Session 2 is complete!"
    echo "📝 Next step: Start Session 3 (Execute Pipeline)"
    echo "   Run: osiris compile pipelines/category_performance.oml.yaml"
    exit 0
else
    echo -e "${RED}❌ $FAILED checkpoint(s) failed${NC}"
    echo ""
    echo "📋 Recommended actions:"
    echo "   1. Check Claude Code conversation for errors"
    echo "   2. Re-run Session 2 with the tutorial prompt"
    echo "   3. Ensure MCP tools were available in Claude"
    echo ""
    echo "   See README.md Session 2 troubleshooting for details"
    exit 1
fi
