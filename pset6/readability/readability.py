def main():
    # Prompt to get text
    text = input("Text: ")

    letters, words, sentences = count(text)

    # l is the average number of letters per 100 words in the text
    l = 100 * letters / words

    # s is the average number of sentences per 100 words in the text
    s = 100 * sentences / words

    # Coleman-Liau index
    index = round(0.0588 * l - 0.296 * s - 15.8)

    maxx = 16

    # Print results
    if index >= maxx:
        print(f"Grade {maxx}+")
    elif index < 1:
        print("Before Grade 1")
    else:
        print(f"Grade {index}")


def count(text):
    letters = sentences = 0

    # There will be 1 more word than space in the text (except 0 length string)
    words = 1

    for c in text:

        # If alpha-character, add 1 to letters
        letters += c.isalpha()

        # If space, add 1 to words
        words += 1 if c == " " else 0

        # If sentence ending, add 1 to sentences
        sentences += 1 if c == "." or c == "!" or c == "?" else 0

    return letters, words, sentences


main()