# Import get_float from cs50
from cs50 import get_float


def main():
    # Make sure input is valid
    while True:
        dollars = get_float("Change owed: ")
        if dollars >= 0:
            break

    # Better to operate with integers than floats
    cents = round(dollars * 100)

    # Call check on cents number of cents
    numberOfCoins = check(cents, [1, 5, 10, 25])

    # Print result
    print(numberOfCoins)


def check(cents, coins):
    # Initialize counter
    counter = 0
    # Sort the list of coins to biggest first
    coins.sort(reverse=True)

    # For every coin, remove one and one until it doesnt work anymore
    for coin in coins:
        while cents - coin >= 0:
            counter += 1
            cents -= coin

    # Return the counter
    return counter


# Call main (no code has been executed until this very last line)
main()