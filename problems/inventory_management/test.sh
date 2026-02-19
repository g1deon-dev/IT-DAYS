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
echo -e "${BLUE}Inventory Management Tests (50 Test Cases)${NC}"
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

# ============================================
# SECTION 1: Basic Add Product Tests (Tests 1-8)
# ============================================

# Test 1: Add Single Product
cat > $TEST_DIR/test1_input.txt << EOF
1
P001
Laptop
10
25000.00
6
EOF
run_test "Test 1: Add Single Product" "$TEST_DIR/test1_input.txt" "added successfully"

# Test 2: Add Product with Spaces in Name
cat > $TEST_DIR/test2_input.txt << EOF
1
P002
Gaming Laptop
5
45000.00
6
EOF
run_test "Test 2: Add Product with Spaces" "$TEST_DIR/test2_input.txt" "added successfully"

# Test 3: Add Multiple Products
cat > $TEST_DIR/test3_input.txt << EOF
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
6
EOF

check_multiple_products() {
    local count=$(grep -c "added successfully" $1)
    [ $count -eq 3 ]
}
run_test "Test 3: Add Multiple Products" "$TEST_DIR/test3_input.txt" "" "check_multiple_products"

# Test 4: Add Product with Zero Price
cat > $TEST_DIR/test4_input.txt << EOF
1
P004
Free Sample
100
0.00
6
EOF
run_test "Test 4: Add Product Zero Price" "$TEST_DIR/test4_input.txt" "added successfully"

# Test 5: Add Product with High Quantity
cat > $TEST_DIR/test5_input.txt << EOF
1
P005
USB Cable
1000
50.00
6
EOF
run_test "Test 5: Add High Quantity Product" "$TEST_DIR/test5_input.txt" "added successfully"

# Test 6: Add Product with High Price
cat > $TEST_DIR/test6_input.txt << EOF
1
P006
Server
2
500000.00
6
EOF
run_test "Test 6: Add High Price Product" "$TEST_DIR/test6_input.txt" "added successfully"

# Test 7: Add Product with Decimal Price
cat > $TEST_DIR/test7_input.txt << EOF
1
P007
Pen
100
15.50
6
EOF
run_test "Test 7: Add Product Decimal Price" "$TEST_DIR/test7_input.txt" "added successfully"

# Test 8: Add Product Starting with Zero Quantity
cat > $TEST_DIR/test8_input.txt << EOF
1
P008
Pre-order Item
0
1999.00
6
EOF
run_test "Test 8: Add Product Zero Quantity" "$TEST_DIR/test8_input.txt" "added successfully"

# ============================================
# SECTION 2: Stock Addition Tests (Tests 9-16)
# ============================================

# Test 9: Add Stock to Existing Product
cat > $TEST_DIR/test9_input.txt << EOF
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

check_stock_add_15() {
    grep -E "15|Updated" $1
}
run_test "Test 9: Add 5 to Stock (10→15)" "$TEST_DIR/test9_input.txt" "" "check_stock_add_15"

# Test 10: Add Large Quantity
cat > $TEST_DIR/test10_input.txt << EOF
1
P002
Mouse
10
500
2
P002
100
6
EOF

check_large_add() {
    grep -E "110|Updated" $1
}
run_test "Test 10: Add 100 to Stock (10→110)" "$TEST_DIR/test10_input.txt" "" "check_large_add"

# Test 11: Add Stock Multiple Times
cat > $TEST_DIR/test11_input.txt << EOF
1
P003
Keyboard
10
1500
2
P003
5
2
P003
10
6
EOF

check_multiple_adds() {
    grep -E "25|Updated" $1
}
run_test "Test 11: Add Stock Twice (10→15→25)" "$TEST_DIR/test11_input.txt" "" "check_multiple_adds"

# Test 12: Add Stock to Zero Quantity Product
cat > $TEST_DIR/test12_input.txt << EOF
1
P004
Monitor
0
8000
2
P004
20
6
EOF

check_from_zero() {
    grep -E "20|Updated" $1
}
run_test "Test 12: Add to Zero Stock (0→20)" "$TEST_DIR/test12_input.txt" "" "check_from_zero"

# Test 13: Add 1 to Stock
cat > $TEST_DIR/test13_input.txt << EOF
1
P005
Cable
50
100
2
P005
1
6
EOF

check_add_one() {
    grep -E "51|Updated" $1
}
run_test "Test 13: Add 1 to Stock (50→51)" "$TEST_DIR/test13_input.txt" "" "check_add_one"

# Test 14: Add Stock to Non-existent Product
cat > $TEST_DIR/test14_input.txt << EOF
1
P006
Item
10
500
2
P999
5
6
EOF
run_test "Test 14: Add to Non-existent Product" "$TEST_DIR/test14_input.txt" "not found"

# Test 15: Add Very Large Quantity
cat > $TEST_DIR/test15_input.txt << EOF
1
P007
Widget
100
10
2
P007
9900
6
EOF

check_very_large() {
    grep -E "10000|Updated" $1
}
run_test "Test 15: Add 9900 (100→10000)" "$TEST_DIR/test15_input.txt" "" "check_very_large"

# Test 16: Add Stock After Display
cat > $TEST_DIR/test16_input.txt << EOF
1
P008
Product
15
200
4
2
P008
10
6
EOF

check_after_display() {
    grep -E "25|Updated" $1
}
run_test "Test 16: Add After Display (15→25)" "$TEST_DIR/test16_input.txt" "" "check_after_display"

# ============================================
# SECTION 3: Stock Removal Tests (Tests 17-24)
# ============================================

# Test 17: Remove Stock Successfully
cat > $TEST_DIR/test17_input.txt << EOF
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

check_stock_remove_12() {
    grep -E "12|Updated" $1
}
run_test "Test 17: Remove 3 from Stock (15→12)" "$TEST_DIR/test17_input.txt" "" "check_stock_remove_12"

# Test 18: Remove All Stock
cat > $TEST_DIR/test18_input.txt << EOF
1
P002
Mouse
20
500
3
P002
20
6
EOF

check_remove_all() {
    grep -E "^0$|: 0|Updated" $1
}
run_test "Test 18: Remove All Stock (20→0)" "$TEST_DIR/test18_input.txt" "" "check_remove_all"

# Test 19: Insufficient Stock Error
cat > $TEST_DIR/test19_input.txt << EOF
1
P003
Keyboard
12
1500.00
3
P003
20
6
EOF
run_test "Test 19: Remove More Than Available" "$TEST_DIR/test19_input.txt" "insufficient\|not enough\|error"

# Test 20: Remove from Zero Stock
cat > $TEST_DIR/test20_input.txt << EOF
1
P004
Monitor
0
8000
3
P004
1
6
EOF
run_test "Test 20: Remove from Zero Stock" "$TEST_DIR/test20_input.txt" "insufficient\|not enough\|error"

# Test 21: Remove Exact Amount
cat > $TEST_DIR/test21_input.txt << EOF
1
P005
Cable
50
100
3
P005
50
6
EOF

check_exact_remove() {
    grep -E "^0$|: 0|Updated" $1
}
run_test "Test 21: Remove Exact Amount (50→0)" "$TEST_DIR/test21_input.txt" "" "check_exact_remove"

# Test 22: Remove 1 from Stock
cat > $TEST_DIR/test22_input.txt << EOF
1
P006
Widget
100
50
3
P006
1
6
EOF

check_remove_one() {
    grep -E "99|Updated" $1
}
run_test "Test 22: Remove 1 (100→99)" "$TEST_DIR/test22_input.txt" "" "check_remove_one"

# Test 23: Remove from Non-existent Product
cat > $TEST_DIR/test23_input.txt << EOF
1
P007
Item
10
500
3
P888
5
6
EOF
run_test "Test 23: Remove from Non-existent" "$TEST_DIR/test23_input.txt" "not found"

# Test 24: Remove Large Quantity (Insufficient)
cat > $TEST_DIR/test24_input.txt << EOF
1
P008
Product
50
1000
3
P008
1000
6
EOF
run_test "Test 24: Remove 1000 from 50" "$TEST_DIR/test24_input.txt" "insufficient\|not enough\|error"

# ============================================
# SECTION 4: Display Tests (Tests 25-32)
# ============================================

# Test 25: Display Empty Inventory
cat > $TEST_DIR/test25_input.txt << EOF
4
6
EOF
run_test "Test 25: Display Empty Inventory" "$TEST_DIR/test25_input.txt" "no products\|empty"

# Test 26: Display Single Product
cat > $TEST_DIR/test26_input.txt << EOF
1
P001
Laptop
10
25000
4
6
EOF

check_display_single() {
    grep -q "P001" $1 && grep -q "Laptop" $1
}
run_test "Test 26: Display Single Product" "$TEST_DIR/test26_input.txt" "" "check_display_single"

# Test 27: Display Multiple Products
cat > $TEST_DIR/test27_input.txt << EOF
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

check_display_multiple() {
    local count=$(grep -c "P00[1-3]" $1)
    [ $count -ge 3 ]
}
run_test "Test 27: Display 3 Products" "$TEST_DIR/test27_input.txt" "" "check_display_multiple"

# Test 28: Display Shows All Fields
cat > $TEST_DIR/test28_input.txt << EOF
1
P001
Test Product
15
999.99
4
6
EOF

check_all_fields() {
    grep -q "P001" $1 && grep -q "Test Product" $1 && grep -q "15" $1 && grep -q "999" $1
}
run_test "Test 28: Display Shows All Fields" "$TEST_DIR/test28_input.txt" "" "check_all_fields"

# Test 29: Display After Add
cat > $TEST_DIR/test29_input.txt << EOF
1
P001
Item1
10
100
1
P002
Item2
20
200
4
6
EOF

check_display_after_add() {
    grep -q "Item1" $1 && grep -q "Item2" $1
}
run_test "Test 29: Display After Multiple Adds" "$TEST_DIR/test29_input.txt" "" "check_display_after_add"

# Test 30: Display After Stock Update
cat > $TEST_DIR/test30_input.txt << EOF
1
P001
Product
10
500
2
P001
5
4
6
EOF

check_updated_display() {
    grep -q "15" $1
}
run_test "Test 30: Display After Stock Update" "$TEST_DIR/test30_input.txt" "" "check_updated_display"

# Test 31: Display Zero Quantity Products
cat > $TEST_DIR/test31_input.txt << EOF
1
P001
Out of Stock Item
0
1000
4
6
EOF
run_test "Test 31: Display Zero Quantity" "$TEST_DIR/test31_input.txt" "out of stock\|0"

# Test 32: Display Many Products
cat > $TEST_DIR/test32_input.txt << EOF
1
P001
Item1
10
100
1
P002
Item2
20
200
1
P003
Item3
30
300
1
P004
Item4
40
400
1
P005
Item5
50
500
4
6
EOF

check_many_products() {
    local count=$(grep -c "Item[1-5]" $1)
    [ $count -ge 5 ]
}
run_test "Test 32: Display 5 Products" "$TEST_DIR/test32_input.txt" "" "check_many_products"

# ============================================
# SECTION 5: Search Tests (Tests 33-38)
# ============================================

# Test 33: Search Existing Product
cat > $TEST_DIR/test33_input.txt << EOF
1
P001
Laptop
10
25000
5
P001
6
EOF
run_test "Test 33: Search Existing Product" "$TEST_DIR/test33_input.txt" "Laptop"

# Test 34: Search Non-existent Product
cat > $TEST_DIR/test34_input.txt << EOF
1
P001
Item
10
500
5
P999
6
EOF
run_test "Test 34: Search Non-existent Product" "$TEST_DIR/test34_input.txt" "not found"

# Test 35: Search Shows All Details
cat > $TEST_DIR/test35_input.txt << EOF
1
P001
Gaming Mouse
25
1500
5
P001
6
EOF

check_search_details() {
    grep -q "P001" $1 && grep -q "Gaming Mouse" $1 && grep -q "25" $1 && grep -q "1500" $1
}
run_test "Test 35: Search Shows All Details" "$TEST_DIR/test35_input.txt" "" "check_search_details"

# Test 36: Search After Multiple Adds
cat > $TEST_DIR/test36_input.txt << EOF
1
P001
Item1
10
100
1
P002
Item2
20
200
1
P003
Item3
30
300
5
P002
6
EOF
run_test "Test 36: Search Among Multiple" "$TEST_DIR/test36_input.txt" "Item2"

# Test 37: Search Zero Quantity Product
cat > $TEST_DIR/test37_input.txt << EOF
1
P001
Sold Out
0
999
5
P001
6
EOF
run_test "Test 37: Search Zero Quantity" "$TEST_DIR/test37_input.txt" "Sold Out"

# Test 38: Search After Stock Update
cat > $TEST_DIR/test38_input.txt << EOF
1
P001
Product
10
500
2
P001
15
5
P001
6
EOF

check_search_updated() {
    grep -q "25" $1
}
run_test "Test 38: Search After Update" "$TEST_DIR/test38_input.txt" "" "check_search_updated"

# ============================================
# SECTION 6: Total Value Tests (Tests 39-44)
# ============================================

# Test 39: Calculate Total Value (Basic)
cat > $TEST_DIR/test39_input.txt << EOF
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

check_total_16000() {
    grep -E "16000|16,000" $1
}
run_test "Test 39: Total Value = 16000" "$TEST_DIR/test39_input.txt" "" "check_total_16000"

# Test 40: Total Value with Zero Quantity
cat > $TEST_DIR/test40_input.txt << EOF
1
P001
Item1
0
1000
1
P002
Item2
10
500
7
6
EOF

check_total_5000() {
    grep -E "5000|5,000" $1
}
run_test "Test 40: Total with Zero Qty = 5000" "$TEST_DIR/test40_input.txt" "" "check_total_5000"

# Test 41: Total Value Empty Inventory
cat > $TEST_DIR/test41_input.txt << EOF
7
6
EOF

check_total_zero() {
    grep -E "^0$|0\.00" $1
}
run_test "Test 41: Total Empty = 0" "$TEST_DIR/test41_input.txt" "" "check_total_zero"

# Test 42: Total Value Single Product
cat > $TEST_DIR/test42_input.txt << EOF
1
P001
Laptop
5
20000
7
6
EOF

check_total_100000() {
    grep -E "100000|100,000" $1
}
run_test "Test 42: Total Single = 100000" "$TEST_DIR/test42_input.txt" "" "check_total_100000"

# Test 43: Total Value with Decimals
cat > $TEST_DIR/test43_input.txt << EOF
1
P001
Item
10
99.99
7
6
EOF

check_total_decimal() {
    grep -E "999\.9|999\.90" $1
}
run_test "Test 43: Total with Decimals" "$TEST_DIR/test43_input.txt" "" "check_total_decimal"

# Test 44: Large Total Value
cat > $TEST_DIR/test44_input.txt << EOF
1
P001
Server
10
500000
1
P002
Workstation
20
100000
7
6
EOF

check_large_total() {
    grep -E "7000000|7,000,000" $1
}
run_test "Test 44: Large Total = 7000000" "$TEST_DIR/test44_input.txt" "" "check_large_total"

# ============================================
# SECTION 7: Complex Workflows (Tests 45-50)
# ============================================

# Test 45: Add, Display, Search, Calculate
cat > $TEST_DIR/test45_input.txt << EOF
1
P001
Laptop
10
25000
4
5
P001
7
6
EOF

check_workflow_1() {
    grep -q "Laptop" $1 && grep -q "250000\|250,000" $1
}
run_test "Test 45: Complete Workflow 1" "$TEST_DIR/test45_input.txt" "" "check_workflow_1"

# Test 46: Add Multiple, Update, Display
cat > $TEST_DIR/test46_input.txt << EOF
1
P001
Item1
10
100
1
P002
Item2
20
200
2
P001
10
3
P002
5
4
6
EOF

check_workflow_2() {
    grep -q "20" $1 && grep -q "15" $1
}
run_test "Test 46: Add, Update, Display" "$TEST_DIR/test46_input.txt" "" "check_workflow_2"

# Test 47: Stock Depletion Scenario
cat > $TEST_DIR/test47_input.txt << EOF
1
P001
Product
50
100
3
P001
30
3
P001
20
4
6
EOF

check_depletion() {
    grep -E "^0$|: 0|Out of Stock" $1
}
run_test "Test 47: Full Stock Depletion" "$TEST_DIR/test47_input.txt" "" "check_depletion"

# Test 48: Restock After Depletion
cat > $TEST_DIR/test48_input.txt << EOF
1
P001
Product
10
500
3
P001
10
2
P001
25
4
6
EOF

check_restock() {
    grep -q "25" $1
}
run_test "Test 48: Restock After Depletion" "$TEST_DIR/test48_input.txt" "" "check_restock"

# Test 49: Multiple Operations on Same Product
cat > $TEST_DIR/test49_input.txt << EOF
1
P001
Widget
100
50
2
P001
50
3
P001
20
2
P001
30
5
P001
7
6
EOF

check_multiple_ops() {
    grep -q "160" $1 && grep -q "8000" $1
}
run_test "Test 49: Multiple Ops Same Product" "$TEST_DIR/test49_input.txt" "" "check_multiple_ops"

# Test 50: Stress Test - Many Products
cat > $TEST_DIR/test50_input.txt << EOF
1
P001
Item1
10
100
1
P002
Item2
20
200
1
P003
Item3
30
300
1
P004
Item4
40
400
1
P005
Item5
50
500
1
P006
Item6
60
600
1
P007
Item7
70
700
1
P008
Item8
80
800
1
P009
Item9
90
900
1
P010
Item10
100
1000
4
7
6
EOF

check_stress_test() {
    local count=$(grep -c "Item" $1)
    [ $count -ge 10 ] && grep -E "385000|385,000" $1
}
run_test "Test 50: Stress Test 10 Products" "$TEST_DIR/test50_input.txt" "" "check_stress_test"

# ============================================
# FINAL SUMMARY
# ============================================

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}FINAL TEST SUMMARY${NC}"
echo -e "${YELLOW}========================================${NC}"
echo "Total Tests: $TOTAL"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
if [ $TOTAL -gt 0 ]; then
    SUCCESS_RATE=$(echo "scale=2; $PASSED * 100 / $TOTAL" | bc)
    echo "Success Rate: $SUCCESS_RATE%"
fi
echo -e "${YELLOW}========================================${NC}\n"

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Some tests failed. Check test_output/ for details.${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed! Excellent work!${NC}"
    exit 0
fi