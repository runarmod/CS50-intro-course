// Include the correct libraries
#include <stdio.h>
#include <cs50.h>
#include <math.h>

// Define some global variables I need
void check(int checkCoin, int cashLeft);
int counter = 0;
int cents;
float dollars;

int main(void)
{
    // Make sure the users input is valid
    do
    {
        dollars = get_float("Change owed: ");
    }
    while (dollars <= 0);

    cents = round(dollars * 100);

    /*
    Check for each of the coins
    Could be done better with one function with all the
    coins as an argument but I wasn't capable now
    */

    check(25, cents);
    check(10, cents);
    check(5, cents);
    check(1, cents);

    printf("%i\n", counter);
}

// Fit as many of the highest coins as possible
void check(int checkCoin, int cashLeft)
{
    for (; cashLeft - checkCoin >= 0; counter++)
    {
        cashLeft -= checkCoin;
    }
    cents = cashLeft;
}