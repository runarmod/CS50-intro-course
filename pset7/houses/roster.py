# Import important stuff
from cs50 import SQL
from sys import exit, argv
import csv

# Create a database-variable i can execute SQL on
db = SQL("sqlite:///students.db")

# Exit if not right usage
if len(argv) != 2:
    print("Usage: python roster.py Housename")
    exit(1)

house = argv[1]

# Get all the people in a house and order them by lastname, then firstname
people = db.execute("SELECT first, middle, last, birth FROM students WHERE house LIKE ? ORDER BY last, first", house)

# Loop thru every person
for person in people:
    # Check if the person has a middlename
    middle = "" if person['middle'] == None else person['middle'] + " "
    # Convert first, middle and lastname to just name
    name = person['first'] + " " + middle + person['last']
    # Print the name, with the birth-year
    print(name + ", born " + str(person['birth']))
