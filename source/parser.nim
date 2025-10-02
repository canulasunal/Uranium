import std/strutils
import os

proc parse*(filename: string): string =

    try:
        var document = readFile(filename)

        document = document.replace("\t", "")
        document = document.replace(";", "#semicolon#")

        var parsed: seq[string] = @[]
        var finished: seq[string] = @[]
        var counter = 0

        for item in document.split("\n"):

            counter = 0

            for character in item.split():
                if character == "":
                    counter += 1
                else:
                    break

            parsed.add($(counter) & "#indent#" & item.strip())

        var x = ""

        for instance in parsed:

            x = instance.split("#indent#")[1]

            for iteration in x.split("#semicolon#"):

                finished.add(instance.split("#indent#")[0] & "#indent#" & iteration)

        var toreturn: seq[string] = @[]
        var commands = finished

        var final = ""
        var indent = 0

        for command in commands:
            indent = parseInt(command.split("#indent#")[0])
            final = repeat(":*#$?!>-+ ", indent) & command.replace("#indent#", "").replace(command.split("#indent#")[0], "")
            toreturn.add(final)

        return toreturn.join("\n")

    except:
        echo "E: File does not exist"
        quit(1)

proc parserepl*(documentx: string): string =

    try:

        var document = documentx.replace("\t", "")
        document = document.replace(";", "#semicolon#").replace("0", "#zerochar#")

        var parsed: seq[string] = @[]
        var finished: seq[string] = @[]
        var counter = 0

        for item in document.split("\n"):

            counter = 0

            for character in item.split():
                if character == "":
                    counter += 1
                else:
                    break

            parsed.add($(counter) & "#indent#" & item.strip())

        var x = ""

        for instance in parsed:

            x = instance.split("#indent#")[1]

            for iteration in x.split("#semicolon#"):

                finished.add(instance.split("#indent#")[0] & "#indent#" & iteration)

        var toreturn: seq[string] = @[]
        var commands = finished

        var final = ""
        var indent = 0

        for command in commands:
            indent = parseInt(command.split("#indent#")[0])
            final = repeat(":*#$?!>-+ ", indent) & command.replace("#indent#", "").replace(command.split("#indent#")[0], "")
            toreturn.add(final)

        return toreturn.join("\n").replace("#zerochar#", "0")

    except:
        echo "E: File does not exist"
        quit(1)
