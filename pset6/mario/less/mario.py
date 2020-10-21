# Import get_int from cs50
from cs50 import get_int

# Check if height is between 1 and 8. Else repeat
while True:
    height = get_int("Height: ")
    if height >= 1 and height <= 8:
        break

# Print spaces and hashtags "the python way"
for i in range(1, height + 1):
    print(" " * (height - i) + "#" * i)