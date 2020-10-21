#include <stdio.h>
#include <cs50.h>

void hashtags(int k);

int main(void)
{
    // Get the desired height
    int height;
    do
    {
        height = get_int("Width: ");
    }
    while (height < 1 || height > 8);

    // Loop thru height
    for (int i = 0; i < height; i++)
    {
        // Print height minus linenumber amount of spaces
        for (int j = 0; j < height - i - 1; j++)
        {
            printf(" ");
        }

        hashtags(i);
        printf("\n");
    }
}

// Print right amount of hashtags according to line number
void hashtags(int k)
{
    for (int j = 0; j < k + 1; j++)
    {
        printf("#");
    }
}