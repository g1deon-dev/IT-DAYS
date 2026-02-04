#include <stdio.h>
#include <string.h>
#include <strings.h>

#define MAX_TASKS 100

typedef struct
{
    int id;
    char description[200];
    char priority[20];
    int completed;
} Task;

Task tasks[MAX_TASKS];
int task_count = 0;

void addTask()
{
    if (task_count >= MAX_TASKS)
    {
        printf("Error: Maximum tasks reached\n");
        return;
    }

    tasks[task_count].id = task_count + 1;

    printf("Enter task description: ");
    getchar();
    fgets(tasks[task_count].description, sizeof(tasks[task_count].description), stdin);
    tasks[task_count].description[strcspn(tasks[task_count].description, "\n")] = 0;

    printf("Enter priority (High/Medium/Low): ");
    scanf("%s", tasks[task_count].priority);

    tasks[task_count].completed = 0;
    task_count++;

    printf("Task added successfully\n");
}

void displayTasks()
{
    if (task_count == 0)
    {
        printf("No tasks found\n");
        return;
    }

    printf("\n=== All Tasks ===\n");
    for (int i = 0; i < task_count; i++)
    {
        printf("ID: %d | %s | Priority: %s | Status: %s\n",
               tasks[i].id, tasks[i].description, tasks[i].priority,
               tasks[i].completed ? "Completed" : "Pending");
    }
}

void markComplete()
{
    int id;
    printf("Enter task ID to mark as complete: ");
    scanf("%d", &id);

    for (int i = 0; i < task_count; i++)
    {
        if (tasks[i].id == id)
        {
            tasks[i].completed = 1;
            printf("Task marked as completed\n");
            return;
        }
    }

    printf("Task not found\n");
}

void displayPending()
{
    int found = 0;
    printf("\n=== Pending Tasks ===\n");
    for (int i = 0; i < task_count; i++)
    {
        if (!tasks[i].completed)
        {
            printf("ID: %d | %s | Priority: %s\n",
                   tasks[i].id, tasks[i].description, tasks[i].priority);
            found = 1;
        }
    }
    if (!found)
    {
        printf("No pending tasks\n");
    }
}

void displayByPriority()
{
    char priority[20];
    printf("Enter priority (High/Medium/Low): ");
    scanf("%s", priority);

    int found = 0;
    printf("\n=== Tasks with %s Priority ===\n", priority);
    for (int i = 0; i < task_count; i++)
    {
        if (strcasecmp(tasks[i].priority, priority) == 0)
        {
            printf("ID: %d | %s | Status: %s\n",
                   tasks[i].id, tasks[i].description,
                   tasks[i].completed ? "Completed" : "Pending");
            found = 1;
        }
    }
    if (!found)
    {
        printf("No tasks found with this priority\n");
    }
}

void deleteTask()
{
    int id;
    printf("Enter task ID to delete: ");
    scanf("%d", &id);

    for (int i = 0; i < task_count; i++)
    {
        if (tasks[i].id == id)
        {
            // Shift tasks
            for (int j = i; j < task_count - 1; j++)
            {
                tasks[j] = tasks[j + 1];
            }
            task_count--;
            printf("Task deleted successfully\n");
            return;
        }
    }

    printf("Error: Task not found\n");
}

int main()
{
    int choice;

    while (1)
    {
        printf("\n=== To-Do List ===\n");
        printf("1. Add Task\n");
        printf("2. Display All Tasks\n");
        printf("3. Mark Task Complete\n");
        printf("4. Display Pending Tasks\n");
        printf("5. Display by Priority\n");
        printf("6. Exit\n");
        printf("7. Delete Task\n");
        printf("Enter choice: ");
        scanf("%d", &choice);

        switch (choice)
        {
        case 1:
            addTask();
            break;
        case 2:
            displayTasks();
            break;
        case 3:
            markComplete();
            break;
        case 4:
            displayPending();
            break;
        case 5:
            displayByPriority();
            break;
        case 6:
            printf("Exiting...\n");
            return 0;
        case 7:
            deleteTask();
            break;
        default:
            printf("Invalid choice\n");
        }
    }

    return 0;
}