# Main code for the Uranium Object Data Script

import std/strutils
import sequtils
import os

import ../engines/rengine

proc read*(filename: string, title: string): string =

    if filename.replace("\"", "").endsWith(".uods"):
        discard
    else:
        echo "Invalid Uranium Object Data Script file extension, all UODS related files should end with .uods."
        quit()

    var text = readFile(filename).replace("{", "{\n").replace("}", "\n}")

    if text.split("\n")[0] == "<object-data>":
        text = text.replace("<object-data>\n", "")
    else:
        echo "Invalid, cant't execute non Uranium Object Script file in Uranium Object Data Script."
        quit()

    var items = text.split("---")
    var ans: seq[seq[string]] = @[@[]]

    for item in items:
        if item == "":
            items.del(items.find(item))

    for item in items:
        var returnlist: seq[string] = @["", ""]
        var parsed = item.split("\n")

        for x in 0..len(parsed)-1:
            parsed[x] = parsed[x].strip()

        var document: seq[string] = @[]

        for item in parsed:
            if item != "":
                document.add(item)

        var title: string
        var data: seq[string] = @[]

        returnlist[0] = document[0].replace("<item>", "").replace("{", "").strip()
        document.del(document.find("}"))
        document.del(document.find(document[0]))
        returnlist[1] = document.join()

        ans.add(returnlist)

    for item in ans:
        if len(item) != 0:
            if item[0] == title:
                return item[1]

    return "None"

proc write*(filename: string, title: string, contents: string): int =

    var file = open(filename, fmWrite)
    var newitem = true

    if readFile(filename) == "":
        file.writeLine("<object-data>")
        newitem = false

    if newitem == true:
        file.writeLine("---")

    file.writeLine("<item>"&title&"<item> {")
    file.writeLine(contents)
    file.writeLine("}")
    file.close()

    return 0