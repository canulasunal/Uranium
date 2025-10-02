import times
import std/strutils
import rainbow

proc celebrate*() =
    var dateTime = $(now())

    var year = parseInt(dateTime.split("-")[0])
    var month = parseInt(dateTime.split("-")[1])
    var day = parseInt(dateTime.split("-")[2].split("T")[0])

    if month == 4 and day == 1:
        rainbow.print("Happy April Fools!")
        echo ""
        echo ""

    elif month == 1 and day == 1:
        echo "Happy New Year!"
        echo ""

    elif month == 12 and day == 31:
        echo "Happy New Year's Eve!"
        echo ""

    elif month == 1 and day == 1:
        echo "Happy New Year!"
        echo ""

    elif month == 10 and day == 29:
        echo "Happy Turkish Republic Day"
        echo "Celebrate the " & $(year-1923) & "th of the republic!"
        echo ""