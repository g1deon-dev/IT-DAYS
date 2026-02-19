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
echo -e "${BLUE}Grade Calculator Tests (50 Test Cases)${NC}"
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
# SECTION 1: Perfect and High Scores (Tests 1-5)
# ============================================

# Test 1: Perfect Score
cat > $TEST_DIR/test1_input.txt << EOF
100
100
100
100
EOF
check_perfect() {
    grep -E "100\.00|100\.0|100" $1 && grep -iE "A|Excellent" $1
}
run_test "Test 1: Perfect Score (100/100/100/100)" "$TEST_DIR/test1_input.txt" "" "check_perfect"

# Test 2: All 99s
cat > $TEST_DIR/test2_input.txt << EOF
99
99
99
99
EOF
check_99() {
    grep -E "99\.00|99\.0|99" $1 && grep -iE "A|Excellent" $1
}
run_test "Test 2: All 99s" "$TEST_DIR/test2_input.txt" "" "check_99"

# Test 3: All 95s
cat > $TEST_DIR/test3_input.txt << EOF
95
95
95
95
EOF
check_95() {
    grep -E "95\.00|95\.0|95" $1 && grep -iE "A|Excellent" $1
}
run_test "Test 3: All 95s" "$TEST_DIR/test3_input.txt" "" "check_95"

# Test 4: All 90s (exact boundary)
cat > $TEST_DIR/test4_input.txt << EOF
90
90
90
90
EOF
check_90() {
    grep -E "90\.00|90\.0|90" $1 && grep -iE "A|Excellent" $1
}
run_test "Test 4: All 90s (Grade A boundary)" "$TEST_DIR/test4_input.txt" "" "check_90"

# Test 5: Mixed high scores
cat > $TEST_DIR/test5_input.txt << EOF
98
95
97
96
EOF
check_high_mixed() {
    grep -E "96\.[0-9]|96" $1 && grep -iE "A|Excellent" $1
}
run_test "Test 5: Mixed High Scores (98/95/97/96)" "$TEST_DIR/test5_input.txt" "" "check_high_mixed"

# ============================================
# SECTION 2: B+ Grade Range (Tests 6-10)
# ============================================

# Test 6: Exact 89
cat > $TEST_DIR/test6_input.txt << EOF
89
89
89
89
EOF
check_89() {
    grep -E "89\.00|89\.0|89" $1 && grep -iE "B\+|Very Good" $1
}
run_test "Test 6: All 89s (B+ boundary)" "$TEST_DIR/test6_input.txt" "" "check_89"

# Test 7: Exact 85
cat > $TEST_DIR/test7_input.txt << EOF
85
85
85
85
EOF
check_85() {
    grep -E "85\.00|85\.0|85" $1 && grep -iE "B\+|Very Good" $1
}
run_test "Test 7: All 85s (B+ lower boundary)" "$TEST_DIR/test7_input.txt" "" "check_85"

# Test 8: B+ range mixed
cat > $TEST_DIR/test8_input.txt << EOF
85
88
90
87
EOF
check_b_plus() {
    grep -E "8[7-8]\.[0-9]|8[7-8]" $1 && grep -iE "B|Very Good|Good" $1
}
run_test "Test 8: B+ Range (85/88/90/87)" "$TEST_DIR/test8_input.txt" "" "check_b_plus"

# Test 9: High B+ (89.x)
cat > $TEST_DIR/test9_input.txt << EOF
90
89
90
88
EOF
check_high_b_plus() {
    grep -E "89\.[2-9]|89" $1 && grep -iE "B" $1
}
run_test "Test 9: High B+ (90/89/90/88 = ~89.3)" "$TEST_DIR/test9_input.txt" "" "check_high_b_plus"

# Test 10: Low B+ (85.x)
cat > $TEST_DIR/test10_input.txt << EOF
85
86
85
84
EOF
check_low_b_plus() {
    grep -E "85\.[0-9]|85" $1 && grep -iE "B" $1
}
run_test "Test 10: Low B+ (85/86/85/84 = ~85.2)" "$TEST_DIR/test10_input.txt" "" "check_low_b_plus"

# ============================================
# SECTION 3: B Grade Range (Tests 11-15)
# ============================================

# Test 11: Exact 84
cat > $TEST_DIR/test11_input.txt << EOF
84
84
84
84
EOF
check_84() {
    grep -E "84\.00|84\.0|84" $1 && grep -iE "B|Good" $1
}
run_test "Test 11: All 84s (B upper boundary)" "$TEST_DIR/test11_input.txt" "" "check_84"

# Test 12: Exact 80
cat > $TEST_DIR/test12_input.txt << EOF
80
80
80
80
EOF
check_80() {
    grep -E "80\.00|80\.0|80" $1 && grep -iE "B|Good" $1
}
run_test "Test 12: All 80s (B lower boundary)" "$TEST_DIR/test12_input.txt" "" "check_80"

# Test 13: B range mixed
cat > $TEST_DIR/test13_input.txt << EOF
82
83
81
80
EOF
check_b_range() {
    grep -E "8[1-2]\.[0-9]|8[1-2]" $1 && grep -iE "B|Good" $1
}
run_test "Test 13: B Range (82/83/81/80)" "$TEST_DIR/test13_input.txt" "" "check_b_range"

# Test 14: High B
cat > $TEST_DIR/test14_input.txt << EOF
84
85
83
84
EOF
check_high_b() {
    grep -E "84\.[0-9]|84" $1 && grep -iE "B" $1
}
run_test "Test 14: High B (84/85/83/84 = ~84.1)" "$TEST_DIR/test14_input.txt" "" "check_high_b"

# Test 15: Low B
cat > $TEST_DIR/test15_input.txt << EOF
80
81
80
79
EOF
check_low_b() {
    grep -E "80\.[0-9]|80" $1 && grep -iE "B|C" $1
}
run_test "Test 15: Low B (80/81/80/79 = ~80.1)" "$TEST_DIR/test15_input.txt" "" "check_low_b"

# ============================================
# SECTION 4: C Grade Range (Tests 16-20)
# ============================================

# Test 16: Exact 79
cat > $TEST_DIR/test16_input.txt << EOF
79
79
79
79
EOF
check_79() {
    grep -E "79\.00|79\.0|79" $1 && grep -iE "C|Pass" $1
}
run_test "Test 16: All 79s (C upper boundary)" "$TEST_DIR/test16_input.txt" "" "check_79"

# Test 17: Exact 75
cat > $TEST_DIR/test17_input.txt << EOF
75
75
75
75
EOF
check_75() {
    grep -E "75\.00|75\.0|75" $1 && grep -iE "C|Pass" $1
}
run_test "Test 17: All 75s (C lower boundary)" "$TEST_DIR/test17_input.txt" "" "check_75"

# Test 18: C range mixed
cat > $TEST_DIR/test18_input.txt << EOF
75
76
75
74
EOF
check_c_range() {
    grep -E "75\.[0-9]|75" $1 && grep -iE "C|Pass" $1
}
run_test "Test 18: C Range (75/76/75/74)" "$TEST_DIR/test18_input.txt" "" "check_c_range"

# Test 19: High C
cat > $TEST_DIR/test19_input.txt << EOF
78
79
77
78
EOF
check_high_c() {
    grep -E "7[7-8]\.[0-9]|7[7-8]" $1 && grep -iE "C|Pass" $1
}
run_test "Test 19: High C (78/79/77/78 = ~77.9)" "$TEST_DIR/test19_input.txt" "" "check_high_c"

# Test 20: Low C
cat > $TEST_DIR/test20_input.txt << EOF
75
76
75
74
EOF
check_low_c() {
    grep -E "75\.[0-9]|75" $1 && grep -iE "C|Pass" $1
}
run_test "Test 20: Low C (75/76/75/74 = ~75.2)" "$TEST_DIR/test20_input.txt" "" "check_low_c"

# ============================================
# SECTION 5: D Grade Range (Tests 21-25)
# ============================================

# Test 21: Exact 74
cat > $TEST_DIR/test21_input.txt << EOF
74
74
74
74
EOF
check_74() {
    grep -E "74\.00|74\.0|74" $1 && grep -iE "D|Pass" $1
}
run_test "Test 21: All 74s (D upper boundary)" "$TEST_DIR/test21_input.txt" "" "check_74"

# Test 22: Exact 70
cat > $TEST_DIR/test22_input.txt << EOF
70
70
70
70
EOF
check_70() {
    grep -E "70\.00|70\.0|70" $1 && grep -iE "D|Pass" $1
}
run_test "Test 22: All 70s (D lower boundary)" "$TEST_DIR/test22_input.txt" "" "check_70"

# Test 23: D range mixed
cat > $TEST_DIR/test23_input.txt << EOF
72
73
71
70
EOF
check_d_range() {
    grep -E "7[1-2]\.[0-9]|7[1-2]" $1 && grep -iE "D|Pass" $1
}
run_test "Test 23: D Range (72/73/71/70)" "$TEST_DIR/test23_input.txt" "" "check_d_range"

# Test 24: High D
cat > $TEST_DIR/test24_input.txt << EOF
74
75
73
74
EOF
check_high_d() {
    grep -E "7[3-4]\.[0-9]|7[3-4]" $1 && grep -iE "D|C" $1
}
run_test "Test 24: High D (74/75/73/74 = ~74.1)" "$TEST_DIR/test24_input.txt" "" "check_high_d"

# Test 25: Low D
cat > $TEST_DIR/test25_input.txt << EOF
70
71
70
69
EOF
check_low_d() {
    grep -E "70\.[0-9]|70|69\.[0-9]|69" $1
}
run_test "Test 25: Low D (70/71/70/69 = ~70.1)" "$TEST_DIR/test25_input.txt" "" "check_low_d"

# ============================================
# SECTION 6: Failing Grades (Tests 26-30)
# ============================================

# Test 26: Just below passing (69.9)
cat > $TEST_DIR/test26_input.txt << EOF
69
70
69
70
EOF
check_near_fail() {
    grep -E "69\.[0-9]|69" $1 && grep -iE "F|Fail|D" $1
}
run_test "Test 26: Near Fail (69/70/69/70 = ~69.5)" "$TEST_DIR/test26_input.txt" "" "check_near_fail"

# Test 27: Clear failure
cat > $TEST_DIR/test27_input.txt << EOF
65
60
58
62
EOF
check_fail() {
    grep -E "6[0-5]\.[0-9]|6[0-5]" $1 && grep -iE "F|Fail" $1
}
run_test "Test 27: Failing Grade (65/60/58/62)" "$TEST_DIR/test27_input.txt" "" "check_fail"

# Test 28: Very low scores
cat > $TEST_DIR/test28_input.txt << EOF
50
55
45
60
EOF
check_very_low() {
    grep -E "5[0-5]\.[0-9]|5[0-5]" $1 && grep -iE "F|Fail" $1
}
run_test "Test 28: Very Low (50/55/45/60)" "$TEST_DIR/test28_input.txt" "" "check_very_low"

# Test 29: Extremely low
cat > $TEST_DIR/test29_input.txt << EOF
30
40
35
45
EOF
check_extreme_low() {
    grep -E "[3-4][0-9]\.[0-9]|[3-4][0-9]" $1 && grep -iE "F|Fail" $1
}
run_test "Test 29: Extremely Low (30/40/35/45)" "$TEST_DIR/test29_input.txt" "" "check_extreme_low"

# Test 30: All zeros
cat > $TEST_DIR/test30_input.txt << EOF
0
0
0
0
EOF
check_zeros() {
    grep -E "0\.00|0\.0|^0$" $1 && grep -iE "F|Fail" $1
}
run_test "Test 30: All Zeros" "$TEST_DIR/test30_input.txt" "" "check_zeros"

# ============================================
# SECTION 7: Weighted Calculation Tests (Tests 31-35)
# ============================================

# Test 31: Quiz weighted heavily (high quiz)
cat > $TEST_DIR/test31_input.txt << EOF
100
80
80
80
EOF
check_quiz_weight() {
    grep -E "8[4-5]\.[0-9]|8[4-5]" $1
}
run_test "Test 31: High Quiz Weight (100/80/80/80 = 84)" "$TEST_DIR/test31_input.txt" "" "check_quiz_weight"

# Test 32: Midterm/Finals weighted heavily
cat > $TEST_DIR/test32_input.txt << EOF
70
95
95
70
EOF
check_midterm_finals() {
    grep -E "8[7-9]\.[0-9]|8[7-9]" $1
}
run_test "Test 32: High Midterm/Finals (70/95/95/70 = 87)" "$TEST_DIR/test32_input.txt" "" "check_midterm_finals"

# Test 33: Project weighted (high project)
cat > $TEST_DIR/test33_input.txt << EOF
80
80
80
100
EOF
check_project_weight() {
    grep -E "8[4-5]\.[0-9]|8[4-5]" $1
}
run_test "Test 33: High Project Weight (80/80/80/100 = 84)" "$TEST_DIR/test33_input.txt" "" "check_project_weight"

# Test 34: Exact weighted calculation
cat > $TEST_DIR/test34_input.txt << EOF
80
85
90
75
EOF
check_exact_weighted() {
    # Quiz: 80*0.2=16, Mid: 85*0.3=25.5, Finals: 90*0.3=27, Proj: 75*0.2=15 = 83.5
    grep -E "83\.[5-9]|84\.[0-5]" $1
}
run_test "Test 34: Exact Weighted (80/85/90/75 = 83.5)" "$TEST_DIR/test34_input.txt" "" "check_exact_weighted"

# Test 35: Another weighted test
cat > $TEST_DIR/test35_input.txt << EOF
90
85
80
95
EOF
check_weighted_35() {
    # 90*0.2 + 85*0.3 + 80*0.3 + 95*0.2 = 86.5
    grep -E "86\.[0-9]|86|87\.[0-9]" $1
}
run_test "Test 35: Weighted Test (90/85/80/95 = 86.5)" "$TEST_DIR/test35_input.txt" "" "check_weighted_35"

# ============================================
# SECTION 8: Boundary Tests (Tests 36-40)
# ============================================

# Test 36: 89.9 vs 90 boundary
cat > $TEST_DIR/test36_input.txt << EOF
90
89
90
89
EOF
check_boundary_89() {
    grep -E "89\.[5-9]" $1 && grep -iE "B" $1 && ! grep -E "Grade:\s*A[^+]|^A$" $1
}
run_test "Test 36: Boundary 89.9 (should be B+, not A)" "$TEST_DIR/test36_input.txt" "" "check_boundary_89"

# Test 37: 84.9 vs 85 boundary
cat > $TEST_DIR/test37_input.txt << EOF
85
84
85
84
EOF
check_boundary_84() {
    grep -E "84\.[0-9]" $1
}
run_test "Test 37: Boundary 84.9 (B vs B+)" "$TEST_DIR/test37_input.txt" "" "check_boundary_84"

# Test 38: 79.9 vs 80 boundary
cat > $TEST_DIR/test38_input.txt << EOF
80
79
80
79
EOF
check_boundary_79() {
    grep -E "79\.[0-9]" $1
}
run_test "Test 38: Boundary 79.9 (C vs B)" "$TEST_DIR/test38_input.txt" "" "check_boundary_79"

# Test 39: 74.9 vs 75 boundary
cat > $TEST_DIR/test39_input.txt << EOF
75
74
75
74
EOF
check_boundary_74() {
    grep -E "74\.[0-9]" $1
}
run_test "Test 39: Boundary 74.9 (D vs C)" "$TEST_DIR/test39_input.txt" "" "check_boundary_74"

# Test 40: 69.9 vs 70 boundary
cat > $TEST_DIR/test40_input.txt << EOF
70
69
70
69
EOF
check_boundary_69() {
    grep -E "69\.[0-9]" $1
}
run_test "Test 40: Boundary 69.9 (F vs D)" "$TEST_DIR/test40_input.txt" "" "check_boundary_69"

# ============================================
# SECTION 9: Input Validation Tests (Tests 41-45)
# ============================================

# Test 41: Negative Quiz score
cat > $TEST_DIR/test41_input.txt << EOF
-10
80
85
90
EOF
run_test "Test 41: Negative Quiz (-10)" "$TEST_DIR/test41_input.txt" "invalid\|error"

# Test 42: Negative Midterm score
cat > $TEST_DIR/test42_input.txt << EOF
80
-50
85
90
EOF
run_test "Test 42: Negative Midterm (-50)" "$TEST_DIR/test42_input.txt" "invalid\|error"

# Test 43: Negative Finals score
cat > $TEST_DIR/test43_input.txt << EOF
80
85
-20
90
EOF
run_test "Test 43: Negative Finals (-20)" "$TEST_DIR/test43_input.txt" "invalid\|error"

# Test 44: Negative Project score
cat > $TEST_DIR/test44_input.txt << EOF
80
85
90
-100
EOF
run_test "Test 44: Negative Project (-100)" "$TEST_DIR/test44_input.txt" "invalid\|error"

# Test 45: Over 100 Quiz
cat > $TEST_DIR/test45_input.txt << EOF
150
85
90
80
EOF
run_test "Test 45: Over 100 Quiz (150)" "$TEST_DIR/test45_input.txt" "invalid\|error"

# ============================================
# SECTION 10: Additional Validation & Edge Cases (Tests 46-50)
# ============================================

# Test 46: Over 100 Midterm
cat > $TEST_DIR/test46_input.txt << EOF
80
150
90
80
EOF
run_test "Test 46: Over 100 Midterm (150)" "$TEST_DIR/test46_input.txt" "invalid\|error"

# Test 47: Over 100 Finals
cat > $TEST_DIR/test47_input.txt << EOF
80
85
200
80
EOF
run_test "Test 47: Over 100 Finals (200)" "$TEST_DIR/test47_input.txt" "invalid\|error"

# Test 48: Over 100 Project
cat > $TEST_DIR/test48_input.txt << EOF
80
85
90
120
EOF
run_test "Test 48: Over 100 Project (120)" "$TEST_DIR/test48_input.txt" "invalid\|error"

# Test 49: Decimal precision test
cat > $TEST_DIR/test49_input.txt << EOF
88.5
91.3
87.7
89.2
EOF
check_decimal() {
    grep -E "89\.[0-9]" $1
}
run_test "Test 49: Decimal Inputs (88.5/91.3/87.7/89.2)" "$TEST_DIR/test49_input.txt" "" "check_decimal"

# Test 50: Another decimal test
cat > $TEST_DIR/test50_input.txt << EOF
92.8
94.5
93.2
91.7
EOF
check_decimal_high() {
    grep -E "93\.[0-9]|92\.[5-9]" $1 && grep -iE "A|Excellent" $1
}
run_test "Test 50: High Decimals (92.8/94.5/93.2/91.7)" "$TEST_DIR/test50_input.txt" "" "check_decimal_high"

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