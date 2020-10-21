// Implements a dictionary's functionality
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <ctype.h>

#include "dictionary.h"

// Represents a node in a hash table
typedef struct node
{
    char word[LENGTH + 1];
    struct node *next;
}
node;

// Number of buckets in hash table
const unsigned int N = 214636;

// Number of words in dictionary
unsigned int word_count = 0;

// Hash table
node *table[N];

// Returns true if word is in dictionary else false
bool check(const char *word)
{
    // Hash word
    int h = hash(word);
    // Create a cursor, and let it start at the hashposition in table
    node *cursor = table[h];

    // While there still is another node
    while (cursor != NULL)
    {
        // Compare the words, if the same, return true. Else go to next node
        if (strcasecmp(word, cursor->word) == 0)
        {
            return true;
        }
        else
        {
            cursor = cursor->next;
        }
    }
    return false;
}

// Hashes word to a number
unsigned int hash(const char *word)
{
    int len = strlen(word);

    // Copy the word, so I can work with it
    char *tmp = malloc((len + 1) * sizeof(char));
    strcpy(tmp, word);
    tmp[len] = '\0';


    // Modified djb2: http://www.cse.yorku.ca/~oz/hash.html
    unsigned int hash = 5381;
    int c;
    while ((c = *tmp++))
    {
        // To lowercase
        if (c >= 'A' && c <= 'Z')
        {
            c += 32;
        }
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
    }

    // Free the memory
    free(tmp - len - 1);
    // Return the hash within the size of N by mod
    return hash % N;
}

// Loads dictionary into memory, returning true if successful else false
bool load(const char *dictionary)
{
    // Open file
    FILE *file = fopen(dictionary, "r");
    if (file == NULL)
    {
        return false;
    }

    char word[LENGTH + 1];
    // Scan one and one word as "word"
    while (fscanf(file, "%s", word) != EOF)
    {
        // Prepare for size function
        word_count++;
        // Create a node n
        node *n = malloc(sizeof(node));
        if (n == NULL)
        {
            return false;
        }

        // Copy current word in dictionary to the node
        strcpy(n->word, word);

        // Hash the word
        int h = hash(word);

        // Put the node in the beginning of the linked list
        n->next = table[h];
        table[h] = n;
    }

    // Close file and return success
    fclose(file);
    return true;
}

// Returns number of words in dictionary if loaded else 0 if not yet loaded
unsigned int size(void)
{
    return word_count;
}

// Unloads dictionary from memory, returning true if successful else false
bool unload(void)
{
    // Loop thru the table
    for (int i = 0; i < N; i++)
    {
        // Create a pointer that starts at the pointer in i position of table
        node *pointer = table[i];
        while (pointer != NULL)
        {
            // Create a temporary pointer, move pointer one time, and free the temporary pointer
            node *tmp = pointer;
            pointer = pointer->next;
            free(tmp);
        }
    }

    // Return success
    return true;
}
