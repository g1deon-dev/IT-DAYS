#include <stdio.h>
#include <string.h>

#define MAX_PRODUCTS 100

typedef struct
{
    char id[20];
    char name[100];
    int quantity;
    float price;
} Product;

Product products[MAX_PRODUCTS];
int product_count = 0;

void addProduct()
{
    if (product_count >= MAX_PRODUCTS)
    {
        printf("Error: Maximum products reached\n");
        return;
    }

    printf("Enter Product ID: ");
    scanf("%s", products[product_count].id);
    getchar();

    printf("Enter Product Name: ");
    fgets(products[product_count].name, 100, stdin);
    products[product_count].name[strcspn(products[product_count].name, "\n")] = 0;

    printf("Enter Quantity: ");
    scanf("%d", &products[product_count].quantity);

    printf("Enter Price: ");
    scanf("%f", &products[product_count].price);

    product_count++;
    printf("Product added successfully\n");
}

void updateStock()
{
    char id[20];
    int qty;

    printf("Enter Product ID: ");
    scanf("%s", id);
    printf("Enter quantity: ");
    scanf("%d", &qty);

    for (int i = 0; i < product_count; i++)
    {
        if (strcmp(products[i].id, id) == 0)
        {
            products[i].quantity += qty;
            printf("Updated. New quantity: %d\n", products[i].quantity);
            return;
        }
    }
    printf("Product not found\n");
}

void removeStock()
{
    char id[20];
    int qty;

    printf("Enter Product ID: ");
    scanf("%s", id);
    printf("Enter quantity: ");
    scanf("%d", &qty);

    for (int i = 0; i < product_count; i++)
    {
        if (strcmp(products[i].id, id) == 0)
        {
            if (products[i].quantity < qty)
            {
                printf("Error: Insufficient stock\n");
                return;
            }
            products[i].quantity -= qty;
            printf("Updated. New quantity: %d\n", products[i].quantity);
            return;
        }
    }
    printf("Product not found\n");
}

void displayProducts()
{
    if (product_count == 0)
    {
        printf("No products in inventory\n");
        return;
    }

    printf("\n=== Inventory ===\n");
    for (int i = 0; i < product_count; i++)
    {
        printf("ID: %s | Name: %s | Qty: %d | Price: %.2f",
               products[i].id, products[i].name,
               products[i].quantity, products[i].price);
        if (products[i].quantity == 0)
        {
            printf(" | Out of Stock");
        }
        printf("\n");
    }
}

void searchProduct()
{
    char id[20];
    printf("Enter Product ID: ");
    scanf("%s", id);

    for (int i = 0; i < product_count; i++)
    {
        if (strcmp(products[i].id, id) == 0)
        {
            printf("Found: %s | %s | Qty: %d | Price: %.2f\n",
                   products[i].id, products[i].name,
                   products[i].quantity, products[i].price);
            return;
        }
    }
    printf("Product not found\n");
}

void calculateTotal()
{
    float total = 0;
    for (int i = 0; i < product_count; i++)
    {
        total += products[i].quantity * products[i].price;
    }
    printf("Total Inventory Value: %.2f\n", total);
}

int main()
{
    int choice;

    while (1)
    {
        printf("\n=== Inventory Management ===\n");
        printf("1. Add Product\n");
        printf("2. Update Stock (Add)\n");
        printf("3. Update Stock (Remove)\n");
        printf("4. Display All Products\n");
        printf("5. Search Product\n");
        printf("6. Exit\n");
        printf("7. Calculate Total Value\n");
        printf("Enter choice: ");
        scanf("%d", &choice);

        switch (choice)
        {
        case 1:
            addProduct();
            break;
        case 2:
            updateStock();
            break;
        case 3:
            removeStock();
            break;
        case 4:
            displayProducts();
            break;
        case 5:
            searchProduct();
            break;
        case 6:
            printf("Exiting...\n");
            return 0;
        case 7:
            calculateTotal();
            break;
        default:
            printf("Invalid choice\n");
        }
    }

    return 0;
}