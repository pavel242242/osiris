#!/bin/bash
# Osiris Get Started Tutorial - Session 1 Verification Script
# This script verifies that Session 1 (Setup & Init) completed successfully

set -e  # Exit on error

echo "🔍 Osiris Get Started - Session 1 Verification"
echo "=============================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FAILED=0

# Helper function for checks
check() {
    local name="$1"
    local command="$2"

    echo -n "Checking: $name... "
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}"
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

echo "Checkpoint 1: Osiris Installation"
echo "-----------------------------------"
if command -v osiris &> /dev/null; then
    VERSION=$(osiris --version 2>&1 | head -1)
    echo -e "${GREEN}✅ osiris command found${NC}"
    echo "   Version: $VERSION"
else
    echo -e "${RED}❌ osiris command not found${NC}"
    echo "   Fix: source your virtual environment: source \$OSIRIS_REPO/.venv/bin/activate"
    FAILED=$((FAILED + 1))
fi
echo ""

echo "Checkpoint 2: MCP Server Selftest"
echo "----------------------------------"
if python -m osiris.cli.mcp_entrypoint --selftest 2>&1 | grep -q "Selftest completed"; then
    echo -e "${GREEN}✅ MCP server selftest passed${NC}"
else
    echo -e "${RED}❌ MCP server selftest failed${NC}"
    echo "   Fix: Check osiris installation and osiris.yaml exists"
    FAILED=$((FAILED + 1))
fi
echo ""

echo "Checkpoint 3: MCP Configuration"
echo "--------------------------------"
if [ -f ~/.config/claude/mcp.json ]; then
    if grep -q "osiris" ~/.config/claude/mcp.json; then
        echo -e "${GREEN}✅ MCP server configured in Claude${NC}"

        # Check OSIRIS_HOME is set
        if grep -q "OSIRIS_HOME" ~/.config/claude/mcp.json; then
            OSIRIS_HOME_PATH=$(grep -A2 "OSIRIS_HOME" ~/.config/claude/mcp.json | grep -v "OSIRIS_HOME" | tr -d ' ",')
            echo "   OSIRIS_HOME: $OSIRIS_HOME_PATH"
        else
            echo -e "${YELLOW}⚠️  OSIRIS_HOME not found in MCP config${NC}"
            echo "   This may cause issues finding osiris.yaml"
            FAILED=$((FAILED + 1))
        fi
    else
        echo -e "${RED}❌ 'osiris' not found in MCP config${NC}"
        echo "   Fix: Run 'claude mcp add osiris...' (see SETUP.md)"
        FAILED=$((FAILED + 1))
    fi
else
    echo -e "${RED}❌ MCP config file not found${NC}"
    echo "   Fix: Run 'claude mcp add osiris...' (see SETUP.md)"
    FAILED=$((FAILED + 1))
fi
echo ""

echo "Checkpoint 4: Project Initialization"
echo "-------------------------------------"
if [ -f "osiris.yaml" ]; then
    echo -e "${GREEN}✅ osiris.yaml exists${NC}"
else
    echo -e "${RED}❌ osiris.yaml not found${NC}"
    echo "   Fix: Run 'osiris init' from examples/get-started directory"
    FAILED=$((FAILED + 1))
fi

if [ -f "osiris_connections.yaml" ]; then
    echo -e "${GREEN}✅ osiris_connections.yaml exists${NC}"
else
    echo -e "${YELLOW}⚠️  osiris_connections.yaml not found${NC}"
    echo "   (Optional - created by 'osiris init')"
fi
echo ""

echo "Checkpoint 5: MCP Logs Directory"
echo "---------------------------------"
if [ -d ".osiris/mcp/logs" ]; then
    echo -e "${GREEN}✅ MCP logs directory exists${NC}"

    # Check subdirectories
    for dir in audit cache telemetry; do
        if [ -d ".osiris/mcp/logs/$dir" ]; then
            echo -e "   ${GREEN}✓${NC} $dir/"
        else
            echo -e "   ${RED}✗${NC} $dir/ missing"
            FAILED=$((FAILED + 1))
        fi
    done
else
    echo -e "${RED}❌ .osiris/mcp/logs directory not found${NC}"
    echo "   Fix: Run 'osiris init' from examples/get-started directory"
    FAILED=$((FAILED + 1))
fi
echo ""

echo "Checkpoint 6: Sample Data"
echo "-------------------------"
if [ -f "data/sales_data.csv" ]; then
    SALES_LINES=$(wc -l < data/sales_data.csv | tr -d ' ')
    echo -e "${GREEN}✅ sales_data.csv exists${NC} ($SALES_LINES lines)"
else
    echo -e "${RED}❌ sales_data.csv not found${NC}"
    FAILED=$((FAILED + 1))
fi

if [ -f "data/product_catalog.csv" ]; then
    PRODUCT_LINES=$(wc -l < data/product_catalog.csv | tr -d ' ')
    echo -e "${GREEN}✅ product_catalog.csv exists${NC} ($PRODUCT_LINES lines)"
else
    echo -e "${RED}❌ product_catalog.csv not found${NC}"
    FAILED=$((FAILED + 1))
fi
echo ""

# Final summary
echo "=============================================="
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All checkpoints passed!${NC}"
    echo ""
    echo "🎉 Session 1 is complete!"
    echo "📝 Next step: Start Session 2 (Build Pipeline)"
    echo "   See README.md for instructions"
    exit 0
else
    echo -e "${RED}❌ $FAILED checkpoint(s) failed${NC}"
    echo ""
    echo "📋 Please fix the issues above before proceeding to Session 2"
    echo "   See SETUP.md for detailed troubleshooting"
    exit 1
fi
