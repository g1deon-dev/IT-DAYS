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
echo -e "${BLUE}To-Do List Tests${NC}"
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

# Test 1: Add Single Task
cat > $TEST_DIR/test1_input.txt << EOF
1
Complete project documentation
High
6
EOF
run_test "Test 1: Add Task" "$TEST_DIR/test1_input.txt" "added successfully\|Task added"

# Test 2: Add Multiple Tasks
cat > $TEST_DIR/test2_input.txt << EOF
1
Task 1
High
1
Task 2
Medium
1
Task 3
Low
1
Task 4
High
1
Task 5
Medium
6
EOF

check_multiple() {
    local count=$(grep -c "added\|Task" $1)
    [ $count -ge 5 ]
}
run_test "Test 2: Add Multiple Tasks" "$TEST_DIR/test2_input.txt" "" "check_multiple"

# Test 3: Mark Task Complete
cat > $TEST_DIR/test3_input.txt << EOF
1
Complete documentation
High
3
1
6
EOF
run_test "Test 3: Mark Complete" "$TEST_DIR/test3_input.txt" "completed\|marked"

# Test 4: Display All Tasks
cat > $TEST_DIR/test4_input.txt << EOF
1
Task 1
High
1
Task 2
Medium
1
Task 3
Low
3
1
2
6
EOF

check_display() {
    grep -q "Task 1" $1 && grep -q "Task 2" $1 && grep -q "Task 3" $1
}
run_test "Test 4: Display All" "$TEST_DIR/test4_input.txt" "" "check_display"

# Test 5: Display Pending Only
cat > $TEST_DIR/test5_input.txt << EOF
1
Pending Task
High
1
Another Pending
Medium
3
1
4
6
EOF

check_pending() {
    grep -iq "pending" $1
}
run_test "Test 5: Display Pending" "$TEST_DIR/test5_input.txt" "" "check_pending"

# Test 6: Display by Priority
cat > $TEST_DIR/test6_input.txt << EOF
1
High Priority Task 1
High
1
Medium Priority Task
Medium
1
High Priority Task 2
High
1
Low Priority Task
Low
5
High
6
EOF

check_priority() {
    local high_count=$(grep -ic "High Priority" $1)
    [ $high_count -ge 2 ]
}
run_test "Test 6: Filter Priority" "$TEST_DIR/test6_input.txt" "" "check_priority"

# Test 7: Delete Task
cat > $TEST_DIR/test7_input.txt << EOF
1
Task to delete
High
1
Task to keep
Medium
1
Another task
Low
7
2
2
6
EOF

check_delete() {
    grep -iq "deleted\|removed" $1
}
run_test "Test 7: Delete Task" "$TEST_DIR/test7_input.txt" "" "check_delete"

# Test 8: Delete Non-existent Task
cat > $TEST_DIR/test8_input.txt << EOF
1
Sample Task
High
7
999
6
EOF
run_test "Test 8: Delete Invalid" "$TEST_DIR/test8_input.txt" "not found\|invalid\|error"

# Summary
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}SUMMARY${NC}"
echo -e "${YELLOW}========================================${NC}"
echo "Total: $TOTAL"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo -e "${YELLOW}========================================${NC}\n"

[ $FAILED -eq 0 ]