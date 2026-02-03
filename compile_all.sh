#!/bin/bash
# Compile all problem solutions

echo "╔════════════════════════════════════════╗"
echo "║  Compiling All Solutions               ║"
echo "╚════════════════════════════════════════╝"
echo ""

PROBLEMS=("student_records" "inventory_management" "grade_calculator" "todo_list")
SUCCESS=0
FAILED=0

for prob in "${PROBLEMS[@]}"; do
    SOLUTION_FILE="problems/$prob/solution.c"
    OUTPUT_FILE="problems/$prob/solution"
    
    if [ -f "$SOLUTION_FILE" ]; then
        echo -n "Compiling $prob... "
        gcc -Wall -o "$OUTPUT_FILE" "$SOLUTION_FILE" 2>/dev/null
        
        if [ -f "$OUTPUT_FILE" ]; then
            echo "✓ SUCCESS"
            SUCCESS=$((SUCCESS + 1))
        else
            echo "✗ FAILED"
            FAILED=$((FAILED + 1))
        fi
    else
        echo "⚠ Skipping $prob (solution.c not found)"
    fi
done

echo ""
echo "Results: $SUCCESS compiled, $FAILED failed"
echo ""

if [ $SUCCESS -gt 0 ]; then
    echo "Run ./test_runner.sh to test all solutions"
fi