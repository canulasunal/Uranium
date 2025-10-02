import os
import parser
import std/strutils
import interpreter
import terminal
import help
import version
import httpclient
import sequtils
import celebrations

if paramCount() < 1:
    celebrations.celebrate()

    echo "Uranium Runtime " & version.version() & " (" &  version.compiler() & ")"
    echo "Type \"help\" for more information"

    var variables: seq[string] = @[]
    var functions: seq[string] = @[]
    var function_names: seq[string] = @[]

    while true:

        setForegroundColor(fgYellow)
        stdout.write(">>> ")
        resetAttributes()

        var repl = readLine(stdin)

        if repl.strip() == "help":
            discard helpmode()

        if repl.startsWith("var "):
            variables.add(repl)
        elif repl.startsWith("list "):
            variables.add(repl)
        elif repl.startsWith("include "):
            variables.add(repl)

        elif repl.startsWith("os.chdir("):
            variables.add(repl)

        elif repl.startsWith("function "):

            var function: seq[string] = @[repl]
            var indentation = 1

            while true:
                setForegroundColor(fgYellow)
                stdout.write("...")
                for x in 0..indentation:
                    stdout.write("   ")
                resetAttributes()
                var line = readLine(stdin)

                if "{" in line:
                    indentation += 1

                if line.startsWith("}"):
                    indentation -= 1
                    
                    if indentation == 0:
                        function.add(line)
                        break

                else:
                    function.add(line)

            functions.add(function.join(";"))
            function_names.add(repl.replace("function ", "").split("(")[0])
            continue

        elif function_names.anyIt(repl.startsWith(it)):
            var functionSep = functions[function_names.find(repl.split("(")[0])].split(";")
            var fetchedContent: seq[string] = @[]

            for x in 1..len(functionSep)-2:
                fetchedContent.add(functionSep[x])

            discard interpret(parserepl(fetchedContent.join("\n")))
            continue

        elif repl.startsWith("exit ") or repl.strip() == "exit":
            echo "Use exit() or Ctrl-Z to exit"
            continue

        for item in variables:
            repl = variables.join("\n") & "\n" & repl
            repl = repl.replace(";", "\n")

        discard interpret(parserepl(repl))


let command = paramStr(1)

if command == "--version" or command == "-V":
    echo "Uranium Runtime Version " & version()

elif command == "-c":
    var argument: seq[string] = @[]

    for x in 0..paramCount():
        argument.add(paramStr(x))

    var commandline = argument.join(" ")

    if commandline.startsWith("./uranium"):
        commandline = commandline.replace("./uranium -c ", "")
    elif commandline.startsWith("uranium"):
        commandline = commandline.replace("uranium -c ", "")

    discard interpret(parserepl(commandline))

elif command == "--help" or command == "-h":
    echo "--version or -V -> Print the current Uranium version information."
    echo "--help or -h -> Print this dialog."
    echo "-c -> Run the passed string argument."
    echo "No arguments -> Launch REPL mode."
    echo "Filename -> Execute Uranium source file."

else:
    
    let filename = paramStr(1)

    if filename.endsWith(".u"):
        discard
    elif filename.endsWith(".uranium"):
        discard
    else:
        echo "E: Incorrect file extension. Uranium source files need to end with .u or .uranium"
        quit(1)

    var document = parse(filename)

    discard interpret(document)
