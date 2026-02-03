#ifndef TEST_FRAMEWORK_H
#define TEST_FRAMEWORK_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// Color codes for output
#define COLOR_RED     "\x1b[31m"
#define COLOR_GREEN   "\x1b[32m"
#define COLOR_YELLOW  "\x1b[33m"
#define COLOR_BLUE    "\x1b[34m"
#define COLOR_RESET   "\x1b[0m"

// Test result counters
typedef struct {
    int total;
    int passed;
    int failed;
    int timeout;
} TestResults;

// Initialize test results
void init_results(TestResults *results) {
    results->total = 0;
    results->passed = 0;
    results->failed = 0;
    results->timeout = 0;
}

// Print test header
void print_test_header(const char *test_name) {
    printf("\n%s========================================%s\n", COLOR_BLUE, COLOR_RESET);
    printf("%sTEST: %s%s\n", COLOR_BLUE, test_name, COLOR_RESET);
    printf("%s========================================%s\n", COLOR_BLUE, COLOR_RESET);
}

// Print test result
void print_test_result(const char *test_case, int passed, const char *message) {
    if (passed) {
        printf("%s[PASS]%s %s\n", COLOR_GREEN, COLOR_RESET, test_case);
    } else {
        printf("%s[FAIL]%s %s\n", COLOR_RED, COLOR_RESET, test_case);
        if (message) {
            printf("       Reason: %s\n", message);
        }
    }
}

// Print final summary
void print_summary(TestResults *results) {
    printf("\n%s========================================%s\n", COLOR_YELLOW, COLOR_RESET);
    printf("%sTEST SUMMARY%s\n", COLOR_YELLOW, COLOR_RESET);
    printf("%s========================================%s\n", COLOR_YELLOW, COLOR_RESET);
    printf("Total Tests: %d\n", results->total);
    printf("%sPassed: %d%s\n", COLOR_GREEN, results->passed, COLOR_RESET);
    printf("%sFailed: %d%s\n", COLOR_RED, results->failed, COLOR_RESET);
    if (results->timeout > 0) {
        printf("%sTimeout: %d%s\n", COLOR_YELLOW, results->timeout, COLOR_RESET);
    }
    printf("Success Rate: %.2f%%\n", 
           (results->total > 0) ? (results->passed * 100.0 / results->total) : 0.0);
    printf("%s========================================%s\n\n", COLOR_YELLOW, COLOR_RESET);
}

#endif