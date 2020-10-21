// Include the correct libraries
#include <stdio.h>
#include <cs50.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>

int main(void)
{
    // Define some global variables
    long number;
    char numberString[16];
    int digits;
    bool valid = true;

    number = get_long("Number: ");

    // Turn the number to a string
    sprintf(numberString, "%ld", number);
    digits = strlen(numberString);

    int checksum = 0;

    // Get startposition in the string/number/array
    int i = digits % 2 == 0 ? 0 : 1;

    for (; i < digits; i += 2)
    {
        // Double and adding all digits to checksum
        // Could have done it better, but thought it would take some time to figure out how to add the digits of
        // 10, 12, 14, 16 and 18 together
        switch (numberString[i])
        {
            case '1' :
                checksum += 2;
                break;
            case '2' :
                checksum += 4;
                break;
            case '3' :
                checksum += 6;
                break;
            case '4' :
                checksum += 8;
                break;
            case '5' :
                checksum += 1;
                break;
            case '6' :
                checksum += 3;
                break;
            case '7' :
                checksum += 5;
                break;
            case '8' :
                checksum += 7;
                break;
            case '9' :
                checksum += 9;
                break;
        }
    }

    // Turn the startplace to the 1 if 0 and other way...
    i = digits % 2 == 0 ? 1 : 0;
    // ... and add the unadded numbers
    for (; i < digits; i += 2)
    {
        checksum += (int) numberString[i] - 48;
    }

    valid = checksum % 10 == 0 ? true : false;

    // MASTERCARD if 16 digits and starting from 51 to 55
    if (digits == 16 && (int) numberString[0] - 48 == 5 && (int) numberString[1] - 48 >= 1 && (int) numberString[1] - 48 <= 5 && valid)
    {
        printf("MASTERCARD\n");
    }
    // AMEX if 15 digits and starting with 34 or 37
    else if (digits == 15 && (int) numberString[0] - 48 == 3 && ((int) numberString[1] - 48 == 4 || (int) numberString[1] - 48 == 7)
             && valid)
    {
        printf("AMEX\n");
    }
    // VISA if 16 or 13 digits and starting with 4
    else if ((digits == 16 || digits == 13) && (int) numberString[0] - 48 == 4 && valid)
    {
        printf("VISA\n");
    }
    else
    {
        printf("INVALID\n");
    }
}