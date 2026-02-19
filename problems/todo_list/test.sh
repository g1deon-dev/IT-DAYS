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
            cat $TEST_DIR/output.txt
            FAILED=$((FAILED + 1))
        fi
    elif grep -iq "$expected" $TEST_DIR/output.txt; then
        echo -e "${GREEN}[PASS]${NC}\n"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}[FAIL]${NC}\n"
        cat $TEST_DIR/output.txt
        FAILED=$((FAILED + 1))
    fi
}

# ─────────────────────────────────────────────
# TEST 1: Add Single Task
# ─────────────────────────────────────────────
cat > $TEST_DIR/test1_input.txt << EOF
1
Complete project documentation
High
6
EOF
run_test "Test 1: Add Single Task" "$TEST_DIR/test1_input.txt" "added successfully\|Task added"

# ─────────────────────────────────────────────
# TEST 2: Add Multiple Tasks (5 tasks)
# ─────────────────────────────────────────────
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

check_test2() {
    local count=$(grep -c "added\|Task" $1)
    [ $count -ge 5 ]
}
run_test "Test 2: Add Multiple Tasks" "$TEST_DIR/test2_input.txt" "" "check_test2"

# ─────────────────────────────────────────────
# TEST 3: Mark Task Complete
# ─────────────────────────────────────────────
cat > $TEST_DIR/test3_input.txt << EOF
1
Complete documentation
High
3
1
6
EOF
run_test "Test 3: Mark Task Complete" "$TEST_DIR/test3_input.txt" "completed\|marked"

# ─────────────────────────────────────────────
# TEST 4: Display All Tasks
# ─────────────────────────────────────────────
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

check_test4() {
    grep -q "Task 1" $1 && grep -q "Task 2" $1 && grep -q "Task 3" $1
}
run_test "Test 4: Display All Tasks" "$TEST_DIR/test4_input.txt" "" "check_test4"

# ─────────────────────────────────────────────
# TEST 5: Display Pending Tasks
# ─────────────────────────────────────────────
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

check_test5() {
    grep -iq "pending" $1
}
run_test "Test 5: Display Pending Tasks" "$TEST_DIR/test5_input.txt" "" "check_test5"

# ─────────────────────────────────────────────
# TEST 6: Filter Tasks by High Priority
# ─────────────────────────────────────────────
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

check_test6() {
    local high_count=$(grep -ic "High Priority" $1)
    [ $high_count -ge 2 ]
}
run_test "Test 6: Filter by High Priority" "$TEST_DIR/test6_input.txt" "" "check_test6"

# ─────────────────────────────────────────────
# TEST 7: Delete Task
# ─────────────────────────────────────────────
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

check_test7() {
    grep -iq "deleted\|removed" $1
}
run_test "Test 7: Delete Task" "$TEST_DIR/test7_input.txt" "" "check_test7"

# ─────────────────────────────────────────────
# TEST 8: Delete Non-existent Task
# ─────────────────────────────────────────────
cat > $TEST_DIR/test8_input.txt << EOF
1
Sample Task
High
7
999
6
EOF
run_test "Test 8: Delete Non-existent Task" "$TEST_DIR/test8_input.txt" "not found\|invalid\|error"

# ─────────────────────────────────────────────
# TEST 9: Add Task with Low Priority
# ─────────────────────────────────────────────
cat > $TEST_DIR/test9_input.txt << EOF
1
Low priority chore
Low
6
EOF
run_test "Test 9: Add Low Priority Task" "$TEST_DIR/test9_input.txt" "added successfully\|Task added"

# ─────────────────────────────────────────────
# TEST 10: Add Task with Medium Priority
# ─────────────────────────────────────────────
cat > $TEST_DIR/test10_input.txt << EOF
1
Medium priority errand
Medium
6
EOF
run_test "Test 10: Add Medium Priority Task" "$TEST_DIR/test10_input.txt" "added successfully\|Task added"

# ─────────────────────────────────────────────
# TEST 11: Mark Second Task Complete
# ─────────────────────────────────────────────
cat > $TEST_DIR/test11_input.txt << EOF
1
First task
High
1
Second task
Medium
3
2
6
EOF
run_test "Test 11: Mark Second Task Complete" "$TEST_DIR/test11_input.txt" "completed\|marked"

# ─────────────────────────────────────────────
# TEST 12: Mark Already-Completed Task
# ─────────────────────────────────────────────
cat > $TEST_DIR/test12_input.txt << EOF
1
Already done
High
3
1
3
1
6
EOF
run_test "Test 12: Mark Already-Completed Task" "$TEST_DIR/test12_input.txt" "already\|completed\|marked"

# ─────────────────────────────────────────────
# TEST 13: Display Empty Task List
# ─────────────────────────────────────────────
cat > $TEST_DIR/test13_input.txt << EOF
2
6
EOF
run_test "Test 13: Display Empty List" "$TEST_DIR/test13_input.txt" "empty\|no tasks\|none"

# ─────────────────────────────────────────────
# TEST 14: Pending List After All Complete
# ─────────────────────────────────────────────
cat > $TEST_DIR/test14_input.txt << EOF
1
Only task
High
3
1
4
6
EOF
run_test "Test 14: Pending List When All Done" "$TEST_DIR/test14_input.txt" "empty\|no pending\|none\|0"

# ─────────────────────────────────────────────
# TEST 15: Filter by Low Priority
# ─────────────────────────────────────────────
cat > $TEST_DIR/test15_input.txt << EOF
1
Low task alpha
Low
1
High task beta
High
5
Low
6
EOF

check_test15() {
    grep -iq "Low task alpha" $1 && ! grep -iq "High task beta" $1
}
run_test "Test 15: Filter by Low Priority" "$TEST_DIR/test15_input.txt" "" "check_test15"

# ─────────────────────────────────────────────
# TEST 16: Filter by Medium Priority
# ─────────────────────────────────────────────
cat > $TEST_DIR/test16_input.txt << EOF
1
Medium task one
Medium
1
Low task two
Low
5
Medium
6
EOF

check_test16() {
    grep -iq "Medium task one" $1 && ! grep -iq "Low task two" $1
}
run_test "Test 16: Filter by Medium Priority" "$TEST_DIR/test16_input.txt" "" "check_test16"

# ─────────────────────────────────────────────
# TEST 17: Delete First Task, Verify Remaining
# ─────────────────────────────────────────────
cat > $TEST_DIR/test17_input.txt << EOF
1
Delete me
High
1
Keep me
Medium
7
1
2
6
EOF

check_test17() {
    grep -iq "Keep me" $1 && ! grep -iq "Delete me" $1
}
run_test "Test 17: Delete First Task, Verify Remaining" "$TEST_DIR/test17_input.txt" "" "check_test17"

# ─────────────────────────────────────────────
# TEST 18: Delete Last Task
# ─────────────────────────────────────────────
cat > $TEST_DIR/test18_input.txt << EOF
1
Alpha
High
1
Beta
Medium
1
Gamma
Low
7
3
2
6
EOF

check_test18() {
    grep -iq "deleted\|removed" $1
}
run_test "Test 18: Delete Last Task" "$TEST_DIR/test18_input.txt" "" "check_test18"

# ─────────────────────────────────────────────
# TEST 19: Add Task with Long Name
# ─────────────────────────────────────────────
cat > $TEST_DIR/test19_input.txt << EOF
1
This is a very long task name to test whether the program handles lengthy descriptions properly without truncation
High
6
EOF
run_test "Test 19: Add Task with Long Name" "$TEST_DIR/test19_input.txt" "added successfully\|Task added"

# ─────────────────────────────────────────────
# TEST 20: Add Task with Special Characters
# ─────────────────────────────────────────────
cat > $TEST_DIR/test20_input.txt << EOF
1
Buy milk & eggs @ store #2
Medium
6
EOF
run_test "Test 20: Add Task with Special Characters" "$TEST_DIR/test20_input.txt" "added successfully\|Task added"

# ─────────────────────────────────────────────
# TEST 21: Invalid Menu Option
# ─────────────────────────────────────────────
cat > $TEST_DIR/test21_input.txt << EOF
99
6
EOF
run_test "Test 21: Invalid Menu Option" "$TEST_DIR/test21_input.txt" "invalid\|error\|unknown\|choose"

# ─────────────────────────────────────────────
# TEST 22: Mark Task Complete with Invalid ID
# ─────────────────────────────────────────────
cat > $TEST_DIR/test22_input.txt << EOF
1
A task
High
3
999
6
EOF
run_test "Test 22: Mark Complete with Invalid ID" "$TEST_DIR/test22_input.txt" "not found\|invalid\|error"

# ─────────────────────────────────────────────
# TEST 23: Display After Deleting All Tasks
# ─────────────────────────────────────────────
cat > $TEST_DIR/test23_input.txt << EOF
1
Solo task
High
7
1
2
6
EOF
run_test "Test 23: Display After Deleting All" "$TEST_DIR/test23_input.txt" "empty\|no tasks\|none\|0"

# ─────────────────────────────────────────────
# TEST 24: Add 10 Tasks and Display All
# ─────────────────────────────────────────────
cat > $TEST_DIR/test24_input.txt << EOF
1
Task A
High
1
Task B
High
1
Task C
Medium
1
Task D
Medium
1
Task E
Low
1
Task F
Low
1
Task G
High
1
Task H
Medium
1
Task I
Low
1
Task J
High
2
6
EOF

check_test24() {
    local count=$(grep -ic "Task" $1)
    [ $count -ge 10 ]
}
run_test "Test 24: Add 10 Tasks and Display All" "$TEST_DIR/test24_input.txt" "" "check_test24"

# ─────────────────────────────────────────────
# TEST 25: Complete Multiple Tasks and Check Pending
# ─────────────────────────────────────────────
cat > $TEST_DIR/test25_input.txt << EOF
1
Task One
High
1
Task Two
Medium
1
Task Three
Low
3
1
3
2
4
6
EOF

check_test25() {
    grep -iq "Task Three" $1
}
run_test "Test 25: Pending Shows Uncompleted Only" "$TEST_DIR/test25_input.txt" "" "check_test25"

# ─────────────────────────────────────────────
# TEST 26: Add Task with Numeric Name
# ─────────────────────────────────────────────
cat > $TEST_DIR/test26_input.txt << EOF
1
12345
High
6
EOF
run_test "Test 26: Add Task with Numeric Name" "$TEST_DIR/test26_input.txt" "added successfully\|Task added"

# ─────────────────────────────────────────────
# TEST 27: Delete Task ID 0 (boundary)
# ─────────────────────────────────────────────
cat > $TEST_DIR/test27_input.txt << EOF
1
Boundary test task
High
7
0
6
EOF
run_test "Test 27: Delete Task ID 0 (Boundary)" "$TEST_DIR/test27_input.txt" "not found\|invalid\|error"

# ─────────────────────────────────────────────
# TEST 28: Delete Negative Task ID
# ─────────────────────────────────────────────
cat > $TEST_DIR/test28_input.txt << EOF
1
Another task
High
7
-1
6
EOF
run_test "Test 28: Delete Negative Task ID" "$TEST_DIR/test28_input.txt" "not found\|invalid\|error"

# ─────────────────────────────────────────────
# TEST 29: Mark Complete ID 0 (boundary)
# ─────────────────────────────────────────────
cat > $TEST_DIR/test29_input.txt << EOF
1
Some task
Medium
3
0
6
EOF
run_test "Test 29: Mark Complete ID 0 (Boundary)" "$TEST_DIR/test29_input.txt" "not found\|invalid\|error"

# ─────────────────────────────────────────────
# TEST 30: Filter Priority with No Matches
# ─────────────────────────────────────────────
cat > $TEST_DIR/test30_input.txt << EOF
1
Only high task
High
5
Low
6
EOF
run_test "Test 30: Filter Priority with No Matches" "$TEST_DIR/test30_input.txt" "empty\|no tasks\|none\|0"

# ─────────────────────────────────────────────
# TEST 31: Add Task with Minimum Name (1 char)
# ─────────────────────────────────────────────
cat > $TEST_DIR/test31_input.txt << EOF
1
X
High
6
EOF
run_test "Test 31: Add Task with 1-Char Name" "$TEST_DIR/test31_input.txt" "added successfully\|Task added"

# ─────────────────────────────────────────────
# TEST 32: Re-add Task After Deleting It
# ─────────────────────────────────────────────
cat > $TEST_DIR/test32_input.txt << EOF
1
Recycled task
High
7
1
1
Recycled task
High
2
6
EOF

check_test32() {
    grep -iq "Recycled task" $1
}
run_test "Test 32: Re-add Task After Delete" "$TEST_DIR/test32_input.txt" "" "check_test32"

# ─────────────────────────────────────────────
# TEST 33: Verify Completed Tasks Not in Pending
# ─────────────────────────────────────────────
cat > $TEST_DIR/test33_input.txt << EOF
1
Done task
High
1
Not done task
Low
3
1
4
6
EOF

check_test33() {
    grep -iq "Not done task" $1 && ! grep -iq "Done task" $1
}
run_test "Test 33: Completed Tasks Not in Pending" "$TEST_DIR/test33_input.txt" "" "check_test33"

# ─────────────────────────────────────────────
# TEST 34: Display Completed Tasks
# ─────────────────────────────────────────────
cat > $TEST_DIR/test34_input.txt << EOF
1
Complete this one
High
1
Leave this pending
Medium
3
1
2
6
EOF

check_test34() {
    grep -iq "Complete this one" $1
}
run_test "Test 34: Display Shows Completed Status" "$TEST_DIR/test34_input.txt" "" "check_test34"

# ─────────────────────────────────────────────
# TEST 35: Add Task, Delete, Add Same Name Again
# ─────────────────────────────────────────────
cat > $TEST_DIR/test35_input.txt << EOF
1
Reuse name
Medium
7
1
1
Reuse name
Medium
2
6
EOF

check_test35() {
    grep -iq "Reuse name" $1
}
run_test "Test 35: Add Same Name After Delete" "$TEST_DIR/test35_input.txt" "" "check_test35"

# ─────────────────────────────────────────────
# TEST 36: Verify Task Count After Multiple Adds/Deletes
# ─────────────────────────────────────────────
cat > $TEST_DIR/test36_input.txt << EOF
1
Keep 1
High
1
Delete me
High
1
Keep 2
Medium
7
2
2
6
EOF

check_test36() {
    grep -iq "Keep 1" $1 && grep -iq "Keep 2" $1 && ! grep -iq "Delete me" $1
}
run_test "Test 36: Correct Tasks Remain After Delete" "$TEST_DIR/test36_input.txt" "" "check_test36"

# ─────────────────────────────────────────────
# TEST 37: Filter High Priority Shows All High Tasks
# ─────────────────────────────────────────────
cat > $TEST_DIR/test37_input.txt << EOF
1
High One
High
1
High Two
High
1
High Three
High
1
Medium One
Medium
5
High
6
EOF

check_test37() {
    grep -iq "High One" $1 && grep -iq "High Two" $1 && grep -iq "High Three" $1
}
run_test "Test 37: Filter High Shows All High Tasks" "$TEST_DIR/test37_input.txt" "" "check_test37"

# ─────────────────────────────────────────────
# TEST 38: Filter Medium Excludes High and Low
# ─────────────────────────────────────────────
cat > $TEST_DIR/test38_input.txt << EOF
1
High task
High
1
Medium task
Medium
1
Low task
Low
5
Medium
6
EOF

check_test38() {
    grep -iq "Medium task" $1 && ! grep -iq "High task" $1 && ! grep -iq "Low task" $1
}
run_test "Test 38: Filter Medium Excludes Others" "$TEST_DIR/test38_input.txt" "" "check_test38"

# ─────────────────────────────────────────────
# TEST 39: Add Task with Spaces in Name
# ─────────────────────────────────────────────
cat > $TEST_DIR/test39_input.txt << EOF
1
   Leading and trailing spaces   
Medium
6
EOF
run_test "Test 39: Add Task with Leading/Trailing Spaces" "$TEST_DIR/test39_input.txt" "added successfully\|Task added"

# ─────────────────────────────────────────────
# TEST 40: Quit Immediately
# ─────────────────────────────────────────────
cat > $TEST_DIR/test40_input.txt << EOF
6
EOF
run_test "Test 40: Quit Immediately" "$TEST_DIR/test40_input.txt" "bye\|exit\|goodbye\|quit\|end"

# ─────────────────────────────────────────────
# TEST 41: Menu Is Displayed
# ─────────────────────────────────────────────
cat > $TEST_DIR/test41_input.txt << EOF
6
EOF
run_test "Test 41: Menu Is Displayed on Start" "$TEST_DIR/test41_input.txt" "1\. \|menu\|option\|add\|choice"

# ─────────────────────────────────────────────
# TEST 42: Add Task Then Verify in Display
# ─────────────────────────────────────────────
cat > $TEST_DIR/test42_input.txt << EOF
1
Unique verification task
High
2
6
EOF

check_test42() {
    grep -iq "Unique verification task" $1
}
run_test "Test 42: Added Task Appears in Display" "$TEST_DIR/test42_input.txt" "" "check_test42"

# ─────────────────────────────────────────────
# TEST 43: Completed Task Shows Completed Status in Display
# ─────────────────────────────────────────────
cat > $TEST_DIR/test43_input.txt << EOF
1
Mark me done
High
3
1
2
6
EOF

check_test43() {
    grep -iq "completed\|done\|finished\|\[x\]\|✓" $1
}
run_test "Test 43: Completed Status Shown in Display" "$TEST_DIR/test43_input.txt" "" "check_test43"

# ─────────────────────────────────────────────
# TEST 44: Priority Shown in Display
# ─────────────────────────────────────────────
cat > $TEST_DIR/test44_input.txt << EOF
1
Priority check task
High
2
6
EOF
run_test "Test 44: Priority Shown in Display" "$TEST_DIR/test44_input.txt" "High\|high"

# ─────────────────────────────────────────────
# TEST 45: Multiple Operations Sequence
# ─────────────────────────────────────────────
cat > $TEST_DIR/test45_input.txt << EOF
1
Alpha task
High
1
Beta task
Medium
1
Gamma task
Low
3
1
7
3
2
4
6
EOF

check_test45() {
    grep -iq "Beta task" $1
}
run_test "Test 45: Complex Multi-operation Sequence" "$TEST_DIR/test45_input.txt" "" "check_test45"

# ─────────────────────────────────────────────
# TEST 46: Non-numeric Input for Task ID
# ─────────────────────────────────────────────
cat > $TEST_DIR/test46_input.txt << EOF
1
A task
High
3
abc
6
EOF
run_test "Test 46: Non-numeric Task ID for Mark Complete" "$TEST_DIR/test46_input.txt" "invalid\|error\|not found"

# ─────────────────────────────────────────────
# TEST 47: Non-numeric Input for Delete ID
# ─────────────────────────────────────────────
cat > $TEST_DIR/test47_input.txt << EOF
1
A task
High
7
xyz
6
EOF
run_test "Test 47: Non-numeric Task ID for Delete" "$TEST_DIR/test47_input.txt" "invalid\|error\|not found"

# ─────────────────────────────────────────────
# TEST 48: Task Name with Numbers and Letters
# ─────────────────────────────────────────────
cat > $TEST_DIR/test48_input.txt << EOF
1
Task99 version2
High
6
EOF
run_test "Test 48: Task Name with Numbers and Letters" "$TEST_DIR/test48_input.txt" "added successfully\|Task added"

# ─────────────────────────────────────────────
# TEST 49: Large Batch - Add and Complete All
# ─────────────────────────────────────────────
cat > $TEST_DIR/test49_input.txt << EOF
1
Batch 1
High
1
Batch 2
High
1
Batch 3
Medium
3
1
3
2
3
3
4
6
EOF

check_test49() {
    ! grep -iq "Batch 1\|Batch 2\|Batch 3" $1 || grep -iq "empty\|no pending\|none" $1
}
run_test "Test 49: All Tasks Completed, Pending Empty" "$TEST_DIR/test49_input.txt" "" "check_test49"

# ─────────────────────────────────────────────
# TEST 50: Stress Test - 15 Tasks, Mixed Operations
# ─────────────────────────────────────────────
cat > $TEST_DIR/test50_input.txt << EOF
1
Stress 1
High
1
Stress 2
Medium
1
Stress 3
Low
1
Stress 4
High
1
Stress 5
Medium
1
Stress 6
Low
1
Stress 7
High
1
Stress 8
Medium
1
Stress 9
Low
1
Stress 10
High
1
Stress 11
Medium
1
Stress 12
Low
1
Stress 13
High
1
Stress 14
Medium
1
Stress 15
Low
3
1
3
5
3
9
7
3
7
7
2
6
EOF

check_test50() {
    local count=$(grep -ic "Stress" $1)
    [ $count -ge 5 ]
}
run_test "Test 50: Stress Test - 15 Tasks Mixed Operations" "$TEST_DIR/test50_input.txt" "" "check_test50"

# ─────────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────────
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}SUMMARY${NC}"
echo -e "${YELLOW}========================================${NC}"
echo "Total:  $TOTAL"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo -e "${YELLOW}========================================${NC}\n"

[ $FAILED -eq 0 ]