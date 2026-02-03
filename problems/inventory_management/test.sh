#!/bin/bash

PROGRAM="./solution"
TEST_DIR="test_output"
TIMEOUT=5

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

mkdir -p $TEST_DIR
TOTAL=0
PASSED=0
FAILED=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Inventory Management Tests${NC}"
echo -e "${BLUE}========================================${NC}\n"

run_test() {
    local test_name=$1
    local input_file=$2
    local expected=$3
    local check_func=$4
    
    TOTAL=$((TOTAL + 1))
    echo -e "${YELLOW}Running: $test_name${NC}"
    
    timeout $TIMEOUT $PROGRAM < $input_file > $TEST_DIR/output.txt 2>&1
    
    if [ $? -eq 124 ]; then
        echo -e "${RED}[FAIL]${NC} Timeout\n"
        FAILED=$((FAILED + 1))
        return 1
    fi
    
    if [ -n "$check_func" ]; then
        $check_func "$TEST_DIR/output.txt"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[PASS]${NC}\n"
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}[FAIL]${NC}\n"
            FAILED=$((FAILED + 1))
        fi
    elif grep -iq "$expected" $TEST_DIR/output.txt; then
        echo -e "${GREEN}[PASS]${NC}\n"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}[FAIL]${NC}\n"
        FAILED=$((FAILED + 1))
    fi
}

# Test 1: Add New Product
cat > $TEST_DIR/test1_input.txt << EOF
1
P001
Laptop
10
25000.00
6
EOF
run_test "Test 1: Add Product" "$TEST_DIR/test1_input.txt" "added successfully"

# Test 2: Update Stock (Add)
cat > $TEST_DIR/test2_input.txt << EOF
1
P001
Laptop
10
25000.00
2
P001
5
6
EOF

check_stock_add() {
    grep -E "15|Updated" $1
}
run_test "Test 2: Update Stock Add" "$TEST_DIR/test2_input.txt" "" "check_stock_add"

# Test 3: Update Stock (Remove)
cat > $TEST_DIR/test3_input.txt << EOF
1
P001
Laptop
15
25000.00
3
P001
3
6
EOF

check_stock_remove() {
    grep -E "12|Updated" $1
}
run_test "Test 3: Update Stock Remove" "$TEST_DIR/test3_input.txt" "" "check_stock_remove"

# Test 4: Insufficient Stock
cat > $TEST_DIR/test4_input.txt << EOF
1
P001
Laptop
12
25000.00
3
P001
20
6
EOF
run_test "Test 4: Insufficient Stock" "$TEST_DIR/test4_input.txt" "insufficient\|not enough\|error"

# Test 5: Display All Products
cat > $TEST_DIR/test5_input.txt << EOF
1
P001
Laptop
10
25000
1
P002
Mouse
50
500
1
P003
Keyboard
30
1500
4
6
EOF

check_display() {
    local count=$(grep -c "P00[1-3]" $1)
    [ $count -ge 3 ]
}
run_test "Test 5: Display Products" "$TEST_DIR/test5_input.txt" "" "check_display"

# Test 6: Search Product
cat > $TEST_DIR/test6_input.txt << EOF
1
P001
Laptop
10
25000
5
P001
6
EOF
run_test "Test 6: Search Product" "$TEST_DIR/test6_input.txt" "Laptop"

# Test 7: Calculate Total Value
cat > $TEST_DIR/test7_input.txt << EOF
1
P001
Item1
10
500
1
P002
Item2
5
1000
1
P003
Item3
2
3000
7
6
EOF

check_total() {
    grep -E "16000|16,000" $1
}
run_test "Test 7: Total Value" "$TEST_DIR/test7_input.txt" "" "check_total"

# Test 8: Zero Quantity
cat > $TEST_DIR/test8_input.txt << EOF
1
P001
Laptop
0
25000
4
6
EOF
run_test "Test 8: Zero Quantity" "$TEST_DIR/test8_input.txt" "out of stock\|0"

# Summary
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}SUMMARY${NC}"
echo -e "${YELLOW}========================================${NC}"
echo "Total: $TOTAL"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo -e "${YELLOW}========================================${NC}\n"

[ $FAILED -eq 0 ]