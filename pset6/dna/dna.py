# Import libraries so i can read arguments and use csv.reader
from sys import argv
import csv


def main():
    # It has to be 3 arguments: pythonfile, databasefile and sequencefile
    if not len(argv) == 3:
        print("Usage: python dna.py data.csv sequence.txt")
        return 1

    # Store the sequence in a list
    sequence = readSequence()

    # Store the STRs and people in lists
    STRs, people = readDatabase()

    # Store the max sequences in a list
    STRsCountMax = countMaxSequence(STRs, sequence)

    # Print the results
    printPerson(people, STRsCountMax)


def readSequence():
    # Literally store the content of the file in a list
    with open(argv[2]) as sequenceFile:
        sequence = sequenceFile.read()
    return sequence


def readDatabase():
    people = []
    STRs = []
    with open(argv[1]) as databaseFile:
        # Read the file and split on ,
        reader = csv.reader(databaseFile, delimiter=',')
        firstLine = True
        for rowArray in reader:
            # Store the first line in an own list
            if firstLine:
                firstLine = False
                for STR in rowArray:
                    STRs.append(STR)
            # Store the other lines in a list "people"
            else:
                people.append(rowArray)
    # Delete 'name'
    del STRs[0]
    return STRs, people


def countMaxSequence(STRs, sequence):
    # Initialize list for the max sums
    STRsCountMax = [0] * len(STRs)
    # Loop thru every STR in STRs
    for i in range(len(STRs)):
        # Loop thru every character in the sequence
        for j in range(len(sequence)):
            # Restart the counter
            counter = 0
            # If the next characters are a STR, add 1 to counter and see if next is also the STR
            while sequence[j:j + len(STRs[i])] == STRs[i]:
                counter += 1
                j += len(STRs[i])
                # If we find a new highest, replace it
                if counter > STRsCountMax[i]:
                    STRsCountMax[i] = counter

    return STRsCountMax


def printPerson(people, STRsCountMax):
    # Loop thru every person
    for person in people:
        # Loop thru the length of STRs
        for k in range(len(STRsCountMax)):
            # If the number of max consecutive STR in DNA equals the persons...
            if int(person[k + 1]) == STRsCountMax[k]:
                # ... then check if k is the last in the list
                if k == len(STRsCountMax) - 1:
                    # If so, print the person, and quit
                    print(person[0])
                    return 0
                continue
            # If it did not match, check the next person
            else:
                break
    # If no one matches, print so
    print("No match")


main()