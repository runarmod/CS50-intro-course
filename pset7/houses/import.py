# Import important stuff
from cs50 import SQL
from sys import exit, argv
import csv

# Create a database-variable i can execute SQL on
db = SQL("sqlite:///students.db")

# Exit if not right usage
if len(argv) != 2:
    print("Usage: python import.py [csvfile].csv")
    exit(1)

csvFilename = argv[1]

# Open the csv, read it and turn each line to a dict
with open(csvFilename) as csvFile:
    reader = csv.DictReader(csvFile)
    for row in reader:
        # Turn name to first, middle (if possible) and last
        name = row['name']
        name = name.split()
        firstName = name[0]
        middleName = None if len(name) == 2 else name[1]
        lastName = name[1] if len(name) == 2 else name[2]
        house = row['house']
        birth = row['birth']

        # Insert the current person
        db.execute("INSERT INTO students (first, middle, last, house, birth) VALUES (?, ?, ?, ?, ?)",
                   firstName, middleName, lastName, house, birth)
