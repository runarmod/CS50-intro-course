// Define important libraries
#include <stdio.h>
#include <cs50.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[])
{
    // Discard anyone who tries too many/few arguments and/or too long/short key
    if (argc != 2 || strlen(argv[1]) != 26)
    {
        printf("Usage: ./caesar key\n");
        return 1;
    }

    for (int i = 0; argv[1][i] != '\0'; i++)
    {
        // Check for duplicates
        for (int j = 0; j < i; j++)
        {
            if (argv[1][i] == argv[1][j])
            {
                printf("No duplicates!\n");
                return 1;
            }
        }

        // Check that all the characters are alphanumerical
        if (isalpha(argv[1][i]))
        {
            continue;
        }
        else
        {
            printf("Usage: ./caesar key\n");
            return 1;
        }
    }

    char *key = argv[1];

    // Get the text that is to be converted
    char *plaintext = get_string("plaintext: ");

    for (int i = 0, n = strlen(plaintext); i < n; i++)
    {
        // Skip this iteration if plaintextcharacter is not in the alphabet
        if (!isalpha(plaintext[i]))
        {
            continue;
        }

        bool lower = islower(plaintext[i]);

        // A and a will be 0, B and b will be 1 and so on. Then turn it to the new alphabet
        plaintext[i] = key[plaintext[i] % 32 - 1];

        // If the character was lowercase, keep it that way, else change
        plaintext[i] = lower ? tolower(plaintext[i]) : toupper(plaintext[i]);
    }

    printf("ciphertext: %s\n", plaintext);
}