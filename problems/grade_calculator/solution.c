#include <stdio.h>

int main()
{
    float quiz, midterm, finals, project;
    float final_grade;

    printf("Enter Quiz score (0-100): ");
    scanf("%f", &quiz);

    if (quiz < 0 || quiz > 100)
    {
        printf("Error: Invalid score\n");
        return 1;
    }

    printf("Enter Midterm score (0-100): ");
    scanf("%f", &midterm);

    if (midterm < 0 || midterm > 100)
    {
        printf("Error: Invalid score\n");
        return 1;
    }

    printf("Enter Finals score (0-100): ");
    scanf("%f", &finals);

    if (finals < 0 || finals > 100)
    {
        printf("Error: Invalid score\n");
        return 1;
    }

    printf("Enter Project score (0-100): ");
    scanf("%f", &project);

    if (project < 0 || project > 100)
    {
        printf("Error: Invalid score\n");
        return 1;
    }

    // Calculate weighted average
    // Quiz: 20%, Midterm: 30%, Finals: 30%, Project: 20%
    final_grade = (quiz * 0.20) + (midterm * 0.30) + (finals * 0.30) + (project * 0.20);

    // Determine letter grade and remarks
    printf("\nFinal Grade: %.2f\n", final_grade);

    if (final_grade >= 90)
    {
        printf("Letter Grade: A\n");
        printf("Remarks: Excellent\n");
    }
    else if (final_grade >= 85)
    {
        printf("Letter Grade: B+\n");
        printf("Remarks: Very Good\n");
    }
    else if (final_grade >= 80)
    {
        printf("Letter Grade: B\n");
        printf("Remarks: Good\n");
    }
    else if (final_grade >= 75)
    {
        printf("Letter Grade: C\n");
        printf("Remarks: Passed\n");
    }
    else if (final_grade >= 70)
    {
        printf("Letter Grade: D\n");
        printf("Remarks: Passed\n");
    }
    else
    {
        printf("Letter Grade: F\n");
        printf("Remarks: Failed\n");
    }

    return 0;
}