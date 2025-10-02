import std/strutils
import terminal

proc helpmode*(): int =

    echo "Welcome to Uranium's assistance program!"
    echo "The the name of any keyword or module without parenthesis or arguments to learn more about it."
    echo "Type exit to exit"

    echo ""
    echo "See https://uranium.42web.io/docs.html for more help"
    echo ""

    while true:

        setForegroundColor(fgBlue)
        stdout.write("help> ")
        resetAttributes()

        var prompt = readLine(stdin).strip()

        if prompt == "exit":

            echo "You are now exiting the help utility to the Uranium Language live runtime environment (REPL)."

            break

        elif prompt == "println":
            echo "Function: println()"
            echo "Arguments: 1"
            echo "Usage: println(arguments)"
            echo "Accepts: Addition, variables, strings, integers, floats"
            echo "Description: Prints a line to the console with newline."

        elif prompt == "print":
            echo "Function: print()"
            echo "Arguments: 1"
            echo "Usage: print(arguments)"
            echo "Accepts: Addition, variables, strings, integers, floats"
            echo "Description: Prints a line to the console without newline."

        elif prompt == "os.system":
            echo "Function: os.system()"
            echo "Arguments: 1"
            echo "Usage: os.system(command)"
            echo "Accepts: Addition, variables, strings, integers, floats"
            echo "Description: Runs a command on the system shell."

        elif prompt == "time.sleep":
            echo "Function: time.sleep()"
            echo "Arguments: 1"
            echo "Usage: time.sleep(seconds)"
            echo "Accepts: Addition, variables, integers, floats"
            echo "Description: Sleeps for the desired amount of seconds."

        elif prompt == "var":
            echo "Keyword: var"
            echo "Arguments: 2"
            echo "Usage: var name = contents"
            echo "Accepts: Addition, variables, strings, integers, floats"
            echo "Description: Used to declare local variables."

        elif prompt == "global":
            echo "Keyword: global"
            echo "Arguments: 2"
            echo "Usage: global name = contents"
            echo "Accepts: Addition, variables, strings, integers, floats"
            echo "Description: Used to declare global variables."

        elif prompt == "include":
            echo "Keyword: include"
            echo "Arguments: 1"
            echo "Usage: include name"
            echo "Accepts: Standard library modules or Magnesium scripts."
            echo "Description: Used to globally import libraries or modules."

        elif prompt == "function":
            echo "Keyword: function"
            echo "Arguments: 1"
            echo "Usage: declare a function"
            echo "Accepts: Name and arguments."
            echo "Description: Used to declare functions."
            echo "Example: function main(name) {"

    return 0
