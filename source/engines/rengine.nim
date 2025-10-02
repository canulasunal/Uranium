import std/strutils
import sequtils

proc find_arguments*(text: string, start: string, finish: string): seq[string] =
    var document = text.replace(start, "#seperator3092482342234#").replace(finish, "#seperator3092482342234#").split("#seperator3092482342234#")
    var ans: seq[string] = @[]

    for item in document:
        if item.strip() == "":
            discard
        else:
            ans.add(item)

    return ans

proc find_char*(text: string, character: string): seq[string] =

    var document = text.replace("a", "#chr#b#chr#")
    document = document.replace(character, "a")

    var strings: seq[string] = @[]
    var inString = false

    var build: seq[char] = @[]

    for item in document.toSeq:
        if $(item) == "a":
            if inString == false:
                inString = true
            else:
                strings.add(build.join().replace(character, ""))
                build = @[]
                inString = false

        if inString == true:
            build.add(item)

    for x in 0..len(strings)-1:
        strings[x] = strings[x].replace("#chr#b#chr#", "a")

        var item: seq[string] = @[]
        var stringList = strings[x].toSeq

        for x in 1..len(stringList)-1:
            item.add($(stringList[x]))

        strings[x] = item.join()

    return 

proc find_par*(text: string): seq[string] =

    var document = text.replace("a", "#chr#b#chr#")
    document = document.replace("(", "a").replace(")", "a")

    var strings: seq[string] = @[]
    var inString = false

    var build: seq[char] = @[]

    for item in document.toSeq:
        if $(item) == "a":
            if inString == false:
                inString = true
            else:
                strings.add(build.join().replace("(", "").replace(")", ""))
                build = @[]
                inString = false

        if inString == true:
            build.add(item)

    for x in 0..len(strings)-1:
        strings[x] = strings[x].replace("#chr#b#chr#", "a")

        var item: seq[string] = @[]
        var stringList = strings[x].toSeq

        for x in 1..len(stringList)-1:
            item.add($(stringList[x]))

        strings[x] = item.join()

    return strings

proc find_col*(text: string): seq[string] =

    var document = text.replace("a", "#chr#b#chr#")
    document = document.replace("{", "a").replace("}", "a")

    var strings: seq[string] = @[]
    var inString = false

    var build: seq[char] = @[]

    for item in document.toSeq:
        if $(item) == "a":
            if inString == false:
                inString = true
            else:
                strings.add(build.join().replace("{", "").replace("}", ""))
                build = @[]
                inString = false

        if inString == true:
            build.add(item)

    for x in 0..len(strings)-1:
        strings[x] = strings[x].replace("#chr#b#chr#", "a")

        var item: seq[string] = @[]
        var stringList = strings[x].toSeq

        for x in 1..len(stringList)-1:
            item.add($(stringList[x]))

        strings[x] = item.join()

    return strings