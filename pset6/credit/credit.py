from cs50 import get_int

# Get number from user (as int) but turn it to a string, and a length
number = get_int("Number: ")
numberString = str(number)
numberLength = len(numberString)

checksum = 0

# Get startposition in the string/number/array
i = numberLength % 2

# Loop thru the number and add to checksum
while i < numberLength:
    # Add all the digits in twice the value in position i
    checksum += sum(map(int, str(int(numberString[i]) * 2)))
    i += 2

# Turn the startposition to the 1 if 0 and other way...
i = 1 if numberLength % 2 == 0 else 0

while i < numberLength:
    checksum += int(numberString[i])
    i += 2

# Check for valid checksum
valid = True if checksum % 10 == 0 else False

# MASTERCARD if 16 digits and starting from 51 to 55
if numberLength == 16 and int(numberString[0]) == 5 and int(numberString[1]) >= 1 and int(numberString[1]) <= 5 and valid:
    print("MASTERCARD")
# AMEX if 15 digits and starting with 34 or 37
elif numberLength == 15 and int(numberString[0]) == 3 and (int(numberString[1]) == 4 or int(numberString[1]) == 7) and valid:
    print("AMEX")
# VISA if 16 or 13 digits and starting with 4
elif (numberLength == 16 or numberLength == 13) and int(numberString[0]) == 4 and valid:
    print("VISA")
else:
    print("INVALID")
