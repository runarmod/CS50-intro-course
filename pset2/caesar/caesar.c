// Define important libraries
#include <stdio.h>
#include <cs50.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

int digits_only(const char *s);

int main(int argc, string argv[])
{
    // Discard anyone who tries too many/few arguments and/or non-numerical argument
    if (argc != 2 || !digits_only(argv[1]))
    {
        printf("Usage: ./caesar key\n");
        return 1;
    }

    int alphabetlength = 26;

    // Turn a key of 63 to a key of 11
    int key = atoi(argv[1]) % alphabetlength;

    // Get the text that is to be converted
    string plaintext = get_string("plaintext: ");

    // Loop thru the string and add the key to the plaintext integer if it is a alphanumerical character
    for (int i = 0; i < strlen(plaintext); i++)
    {
        if (isalpha(plaintext[i]))
        {
            plaintext[i] = (int) plaintext[i] + key;

            // If the NEW character is not in the alphabet, loop it to the start again
            if (!isalpha(plaintext[i]))
            {
                plaintext[i] = (int) plaintext[i] - alphabetlength;
            }
        }
    }

    printf("ciphertext: %s\n", plaintext);

}

// Copied from user529758 on stackoverflow
int digits_only(const char *s)
{
    while (*s)
    {
        if (isdigit(*s++) == 0)
        {
            return 0;
        }
    }

    return 1;
}