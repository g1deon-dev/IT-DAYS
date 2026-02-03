#!/bin/bash
# Master test runner for all problems

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo -e "${MAGENTA}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║    DEVELOPMENT CHALLENGE - AUTOMATED TEST SUITE        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

PROBLEMS=("student_records" "inventory_management" "grade_calculator" "todo_list")
FOUND_PROBLEMS=()

echo -e "${BLUE}Checking for solutions...${NC}"
for prob in "${PROBLEMS[@]}"; do
    if [ -f "problems/$prob/solution" ]; then
        echo -e "${GREEN}✓${NC} Found: $prob"
        FOUND_PROBLEMS+=("$prob")
    else
        echo -e "${YELLOW}⚠${NC} Not compiled: $prob (skipping)"
    fi
done
echo ""

if [ ${#FOUND_PROBLEMS[@]} -eq 0 ]; then
    echo -e "${RED}Error: No compiled solutions found${NC}"
    echo "Run ./compile_all.sh first"
    exit 1
fi

for prob in "${FOUND_PROBLEMS[@]}"; do
    TEST_SCRIPT="problems/$prob/test.sh"
    
    if [ -f "$TEST_SCRIPT" ]; then
        echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
        echo -e "${BLUE}Testing: $prob${NC}"
        echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"
        
        cd "problems/$prob"
        chmod +x test.sh
        ./test.sh
        cd ../..
        echo ""
    fi
done

echo -e "${MAGENTA}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║              TESTING COMPLETE                          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo "Check individual problem directories for detailed results"