#include <stdio.h>
#include <cs50.h>

int main(void)
{
    // Asks user for name and greets them
    string name = get_string("What's your name? ");
    printf("Hello, %s\n", name);
}