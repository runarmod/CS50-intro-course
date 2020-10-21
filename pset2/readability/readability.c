// Include used libraries
#include <stdio.h>
#include <cs50.h>
#include <string.h>
#include <ctype.h>
#include <math.h>

// Define functions
int count_letters(string text);
int count_words(string text);
int count_sentences(string text);

int main(void)
{
    // Prompt to get text
    string text = get_string("Text: ");

    // Count everything
    int letters_in_text = count_letters(text);
    int words_in_text = count_words(text);
    int sentences_in_text = count_sentences(text);

    // L is the average number of letters per 100 words in the text
    float L = 100 * (float) letters_in_text / (float) words_in_text;

    // S is the average number of sentences per 100 words in the text
    float S = 100 * (float) sentences_in_text / (float) words_in_text;

    // Coleman-Liau index
    int index = round(0.0588 * L - 0.296 * S - 15.8);

    int max = 16;
    // Print results
    if (index >= max)
    {
        printf("Grade %i+\n", max);
    }
    else if (index < 1)
    {
        printf("Before Grade 1\n");
    }
    else
    {
        printf("Grade %i\n", index);
    }
}

// Loop thru string and find alphanumerical characters
int count_letters(string text)
{
    int letters = 0;
    int length = strlen(text);
    for (int i = 0; i < length; i++)
    {
        letters += isalpha(text[i]) ? 1 : 0;
    }
    return letters;
}

// Loop thru string and find words (spaces + 1)
int count_words(string text)
{
    int words = 0;
    int length = strlen(text);
    for (int i = 0; i < length; i++)
    {
        words += text[i] == ' ' ? 1 : 0;
    }

    // One more word than spaces
    words++;

    return words;
}

// Loop thru string and find sentence-endings
int count_sentences(string text)
{
    int sentences = 0;
    int length = strlen(text);
    for (int i = 0; i < length; i++)
    {
        if (text[i] == '.' || text[i] == '!' || text[i] == '?')
        {
            sentences++;
        }
    }
    return sentences;
}