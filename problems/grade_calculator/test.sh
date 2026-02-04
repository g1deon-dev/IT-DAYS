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
echo -e "${BLUE}Grade Calculator Tests${NC}"
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

# Test 1: Perfect Score
cat > $TEST_DIR/test1_input.txt << EOF
100
100
100
100
EOF

check_perfect() {
    grep -E "100|A|Excellent" $1
}
run_test "Test 1: Perfect Score" "$TEST_DIR/test1_input.txt" "" "check_perfect"

# Test 2: Passing Grade (High)
cat > $TEST_DIR/test2_input.txt << EOF
85
88
90
87
EOF

check_high() {
    grep -E "8[7-9]|B|Very Good|Good" $1
}
run_test "Test 2: High Pass" "$TEST_DIR/test2_input.txt" "" "check_high"

# Test 3: Passing Grade (Low)
cat > $TEST_DIR/test3_input.txt << EOF
75
76
75
74
EOF

check_low() {
    grep -E "75|7[4-6]|C|Pass" $1
}
run_test "Test 3: Low Pass" "$TEST_DIR/test3_input.txt" "" "check_low"

# Test 4: Failing Grade
cat > $TEST_DIR/test4_input.txt << EOF
65
60
58
62
EOF

check_fail() {
    grep -iE "fail|F" $1
}
run_test "Test 4: Failing Grade" "$TEST_DIR/test4_input.txt" "" "check_fail"

# Test 5: Weighted Calculation
cat > $TEST_DIR/test5_input.txt << EOF
80
85
90
75
EOF

check_weighted() {
    # Expected: 84.0
    grep -E "84|83\.[5-9]|84\.[0-5]" $1
}
run_test "Test 5: Weighted Calc" "$TEST_DIR/test5_input.txt" "" "check_weighted"

# Test 6: Boundary Grade (89.9 vs 90)
cat > $TEST_DIR/test6_input.txt << EOF
90
89
90
89
EOF

check_boundary() {
    # Should be B+, not A (89.7)
    grep -E "89\.[5-9]|B" $1 && ! grep -E "^A$|Grade: A[^+]" $1
}
run_test "Test 6: Grade Boundary" "$TEST_DIR/test6_input.txt" "" "check_boundary"

# Test 7: Invalid Input (Negative)
cat > $TEST_DIR/test7_input.txt << EOF
-10
80
85
90
EOF
run_test "Test 7: Negative Input" "$TEST_DIR/test7_input.txt" "invalid\|error"

# Test 8: Invalid Input (Over 100)
cat > $TEST_DIR/test8_input.txt << EOF
80
150
85
90
EOF
run_test "Test 8: Over 100 Input" "$TEST_DIR/test8_input.txt" "invalid\|error"

# Summary
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}SUMMARY${NC}"
echo -e "${YELLOW}========================================${NC}"
echo "Total: $TOTAL"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo -e "${YELLOW}========================================${NC}\n"

[ $FAILED -eq 0 ]