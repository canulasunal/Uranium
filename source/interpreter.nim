import std/strutils
import httpclient
import sequtils
import tables
import typelib
import os
import parser
import length
import rainbow

import uods/uods

import eval/inteval
import eval/ifeval

import stdlib/oslib
import stdlib/timelib
import stdlib/mathlib
import stdlib/browserlib

import engines/rengine

const bootstrap_mathlib = staticRead("stdlib/bootstrap/math.u")
const bootstrap_repllib = staticRead("stdlib/bootstrap/repl.u")

proc interpret*(codeContent: string): string =

    var oslib_imported = false
    var timelib_imported = false
    var mathlib_imported = false
    var repllib_imported = false
    var uodslib_imported = false
    var browserlib_imported = false

    var document = codeContent
    var libraries: seq[string] = @[]

    for line in codeContent.split("\n"):
        if line.startswith("include "):
            if line.strip() == "include os":
                oslib_imported = true
                
            elif line.strip() == "include time":
                timelib_imported = true

            elif line.strip() == "include browser":
                browserlib_imported = true

            elif line.strip() == "include math":
                if mathlib_imported == false:
                    mathlib_imported = true
                    document = bootstrap_mathlib & "\n" & document
                else:
                    discard

            elif line.strip() == "include repl":
                if repllib_imported == false:
                    repllib_imported = true
                    document = bootstrap_repllib & "\n" & document
                else:
                    discard
                    
            elif line.strip() == "include uods":
                uodslib_imported = true

    var customLibs: seq[string] = @[]
    var stdlibs: seq[string] = @["math", "os", "time", "repl", "uods", "browser"]

    for line in codeContent.split("\n"):
        if line.startsWith("include "):
            if line.replace("include ", "") in stdlibs:
                discard
            else:
                customLibs.add(line.replace("include ", ""))

    for item in customLibs:
        try:
            document = readFile(item&".u") & "\n" & document
        except:
            document = readFile(getHomeDir()&"/.uranium/"&item&".u") & "\n" & document

    var functions: seq[string] = @[]
    var function_names: Table[string, int]

    var functioncounter = 0

    var ifs: seq[string] = @[]
    var if_names: Table[string, int]

    var ifcounter = 0

    var whiles: seq[string] = @[]
    var while_names: Table[string, int]

    var whilecounter = 0

    var fors: seq[string] = @[]
    var for_names: Table[string, int]

    var forcounter = 0

    var strings: Table[string, string]
    var floats: Table[string, float]
    var lists = [("#example#table#tag", "a")].toOrderedTable

    var globals: seq[string] = @[]

    var code = document.split("\n")

    var counter = 0
    var forbidden: seq[int] = @[]

    for command in code:

        if counter in forbidden:
            discard

        else:

            var indentation = 0

            for item in command.split():
                if item == ":*#$?!>-+":
                    indentation += 1

            var indent = $(indentation)
            var statement = command.replace(":*#$?!>-+ ", "").replace("\'", "\"").strip()

            if oslib_imported == true:
                statement = oslib.refresh(statement)
            if mathlib_imported == true:
                statement = mathlib.refresh(statement)
            if timelib_imported == true:
                statement = timelib.refresh(statement)

            # start main eval checks

            var function_names_seq: seq[string] = @[]

            for item in function_names.keys:
                function_names_seq.add(item)

            if statement.startsWith("var "):
                var contentsParse = statement.replace("var ", "").replace(statement.replace("var ", "").split("=")[0], "").replace("=", " = ").split()

                for x in 0..len(contentsParse)-1:
                    contentsParse[x] = contentsParse[x].strip()

                var contentsList: seq[string] = @[]

                for item in contentsParse:
                    if item != "":
                        contentsList.add(item)
                
                var contents = contentsList.join(" ").replace(" = ", "#plus#tag#12134").replace("= ", "").replace( "#plus#tag#12134", " = ")

                var name = statement.replace("var ", "").split("=")[0].strip()
                var vartype = types(contents)

                if "prompt(" in contents:
                    var prompts = find_arguments(contents, "prompt(", ")")

                    for item in prompts:
                        var parsedItem = item.replace("\"", "")

                        stdout.write(parsedItem)
                        var question = readLine(stdin)

                        contents = contents.replace("prompt("&item&")", question)

                elif contents.startsWith("browser.read("):
                    if browserlib_imported == true:
                        var url = contents.replace("browser.read(", "").replace(")", "").replace("\"", "")

                        var fetcher = newHttpClient()

                        try:
                            contents = fetcher.getContent(url)
                        except:
                            echo "Uranium: Error, browser module could not fetch contents of url."

                        fetcher.close()

                elif contents.startsWith("uods.read("):
                    if uodslib_imported == true:
                        var filename = contents.replace("uods.read(", "").replace(")", "").split(",")[0].replace("\"", "").strip()
                        var section = contents.replace("uods.read(", "").replace(")", "").split(",")[1].replace("\"", "").strip()
                        contents = uods.read(filename, section)

                elif contents.startswith("length(") and contents.endsWith(")"):
                    contents =contents.replace("\"", "").replace("length(")[0 ..^ 2]
                    floats[name] = length.length(contents, counter)
                    continue

                for item in function_names_seq:
                    for name_token in find_arguments(contents, item&"(", ")"):
                        var extraLines = name_token.split(",")

                        var fetchedFunction = functions[function_names[item]]
                        var functionCallVariables: seq[string] = @[]

                        for item in fetchedFunction.split("\n"):
                            if item.startsWith("funcvar "):
                                functionCallVariables.add(item.replace("funcvar ", ""))

                        for x in 0..len(extraLines)-1:
                            fetchedFunction = "var " & functionCallVariables[x] & "=" & extraLines[x] & "\n" & fetchedFunction

                        contents = contents.replace(item&"("&name_token&")", interpret(fetchedFunction))

                for item in strings.keys:
                    var modifier = "$"&item
                    contents = contents.replace(modifier, $(strings[item]))

                for item in floats.keys:
                    var modifier = "$"&item
                    contents = contents.replace(modifier, $(floats[item]))

                var isfloat = false

                try:
                    contents = $(evaluate(contents))
                except:
                    discard

                if vartype == "String":
                    strings[name] = contents.replace("\"", "")
                else:
                    try:
                        discard evaluate(contents)
                        floats[name] = evaluate(contents)
                    except:
                        strings[name] = contents

            elif statement.startsWith("del "):
                var name = statement.replace("del ", "")

                floats[name] = 0.0
                strings[name] = ""
                lists[name] = ""

            elif statement.startsWith("uods.write("):

                if uodslib_imported == true:
                    var stripped = statement.replace("uods.write(", "").replace(")", "").replace("\"", "").split(",")
                    var writefilename = stripped[0].strip()
                    var writetitle = stripped[1].strip()
                    var writecontents = stripped[2].strip()

                    discard uods.write(writefilename, writetitle, writecontents)

            elif statement.startsWith("list "):
                var parsed = statement.replace("list ", "")
                var expression = parsed.split("=")
                
                for x in 0..len(expression)-1:
                    expression[x] = expression[x].strip()

                var name = expression[0]
                var contents = expression[1]

                var list = contents.replace("[", "").replace("]", "").split(",")

                for x in 0..len(list)-1:
                    list[x] = list[x].strip()

                for x in 0..len(list)-1:
                    var counter = $(x)
                    var iterName = name&"["&counter&"]"
                    lists[iterName] = list[x]

            elif statement.startsWith("global "):
                var contentsParse = statement.replace("global ", "").replace(statement.replace("global ", "").split("=")[0], "").replace("=", " = ").split()

                for x in 0..len(contentsParse)-1:
                    contentsParse[x] = contentsParse[x].strip()

                var contentsList: seq[string] = @[]

                for item in contentsParse:
                    if item != "":
                        contentsList.add(item)
                
                var contents = contentsList.join(" ").replace(" = ", "#plus#tag#12134").replace("= ", "").replace( "#plus#tag#12134", " = ")

                var name = statement.replace("global ", "").split("=")[0].strip()
                var vartype = types(contents)

                if "prompt(" in contents:
                    var prompts = find_arguments(contents, "prompt(", ")")

                    for item in prompts:
                        var parsedItem = item.replace("\"", "")

                        stdout.write(parsedItem)
                        var question = readLine(stdin)

                        contents = contents.replace("prompt("&item&")", question)

                for item in function_names_seq:
                    for name_token in find_arguments(contents, item&"(", ")"):
                        var extraLines = name_token.split(",")

                        var fetchedFunction = functions[function_names[item]]

                        if extraLines.join().strip() == "":
                            for item in extraLines:
                                fetchedFunction = item & "\n" & fetchedFunction
                        else:

                            for item in extraLines:
                                fetchedFunction = "global " & item & "\n" & fetchedFunction

                        contents = contents.replace(item&"("&name_token&")", interpret(fetchedFunction))

                if contents.startswith("length(") and contents.endsWith(")"):
                    contents =contents.replace("\"", "").replace("length(")[0 ..^ 2]
                    floats[name] = length.length(contents, counter)
                    continue

                for item in strings.keys:
                    var modifier = "$"&item
                    contents = contents.replace(modifier, $(strings[item]))

                for item in floats.keys:
                    var modifier = "$"&item
                    contents = contents.replace(modifier, $(floats[item]))

                try:
                    contents = $(evaluate(contents))
                except:
                    discard

                if vartype == "String":
                    strings[name] = contents.replace("\"", "")
                else:
                    floats[name] = evaluate(contents)

                globals.add("global " & name & " = " & contents)

            elif statement.startsWith("list "):
                var parsed = statement.replace("list ", "")
                var expression = parsed.split("=")
                
                for x in 0..len(expression)-1:
                    expression[x] = expression[x].strip()

                var name = expression[0]
                var contents = expression[1]

                var list = contents.replace("[", "").replace("]", "").split(",")

                for x in 0..len(list)-1:
                    list[x] = list[x].strip()

                for x in 0..len(list)-1:
                    var counter = $(x)
                    var iterName = name&"["&counter&"]"
                    lists[iterName] = list[x]

                globals.add(statement)

            elif statement.startsWith("print"):
                var newline = false

                if statement.startsWith("println(") and statement.endsWith(")"):
                    newline = true
                
                elif statement.startsWith("print(") and statement.endsWith(")"):
                    newline = false

                var parameters = statement.replace("println(", "").replace("print(", "").replace(")", "").strip()

                for item in strings.keys:
                    var modifier = "$"&item
                    parameters = parameters.replace(modifier, $(strings[item]))

                for item in floats.keys:
                    var modifier = "$"&item
                    parameters = parameters.replace(modifier, $(floats[item]))

                for item in lists.keys:
                    var modifier = "$"&item
                    parameters = parameters.replace(modifier, $(lists[item]))

                var toprint: string

                try:

                    if newline == true:
                        toprint = $(evaluate(parameters.replace("\"", "")))
                        
                        if toprint.endsWith(".0"):
                            toprint = toprint.replace(".0", "")

                        echo toprint
                    else:
                        stdout.write(evaluate(parameters.replace("\"", "")))

                except:
                    if newline == true:
                        echo parameters.replace("\"", "")
                    else:
                        stdout.write(parameters.replace("\"", ""))

            elif statement.startsWith("rainbow("):

                var parameters = statement.replace("rainbow(", "").replace(")", "").strip()

                for item in strings.keys:
                    var modifier = "$"&item
                    parameters = parameters.replace(modifier, $(strings[item]))

                for item in floats.keys:
                    var modifier = "$"&item
                    parameters = parameters.replace(modifier, $(floats[item]))

                for item in lists.keys:
                    var modifier = "$"&item
                    parameters = parameters.replace(modifier, $(lists[item]))

                try:
                    rainbow.print($(evaluate(parameters.replace("\"", ""))))

                except:
                    rainbow.print(parameters.replace("\"", ""))

                echo ""

            elif statement.startsWith("exec(") and statement.endsWith(")"):
                statement = statement.replace("\\\"", "#quote#tag#uranium#")
                var parameters = statement.replace("exec(", "").strip()[0 ..^ 2]
                parameters = parameters.replace("#quote#tag#uranium#", "")

                for item in strings.keys:
                    var modifier = "$"&item
                    parameters = parameters.replace(modifier, $(strings[item]))

                for item in floats.keys:
                    var modifier = "$"&item
                    parameters = parameters.replace(modifier, $(floats[item]))

                for item in lists.keys:
                    var modifier = "$"&item
                    parameters = parameters.replace(modifier, $(lists[item]))

                try:
                    discard interpret(parserepl($(evaluate(parameters.replace("\"", "")))))
                except:
                    discard interpret(parserepl($(parameters.replace("\"", ""))))
                    
            elif statement.startsWith("function "):
                var name = statement.strip().replace("function ", "").split("(")[0]
                var funcVars = statement.split("(")[1].replace(")", "").split(",")

                function_names[name] = functioncounter

                var index = code.find(statement)
                var functioncontent: seq[string] = @[]

                if oslib_imported == true:
                    functioncontent.add("include os")
                if timelib_imported == true:
                    functioncontent.add("include time")

                for item in libraries:
                    functioncontent.add("include " & item)

                for item in globals:
                    functioncontent.add(item)

                var indentation = 1

                for i in index + 1 ..< code.len:

                    var line = code[i]

                    var check = line.replace(":*#$?!>-+ ", "").strip()

                    if  "}" in check.strip().split():
                        indentation -= 1
                        if indentation == 0:
                            break
                    elif "{" in check.strip():
                        indentation += 1
                    if check.strip() == "{":
                        discard
                    else:
                        functioncontent.add(check)
                        forbidden.add(i)

                for item in funcVars:
                    functioncontent.add("funcvar " & item.replace("{", "").strip())

                functions.add(functioncontent.join("\n"))

                functioncounter += 1


            elif statement.startsWith("if "):
                var name = statement.strip().replace("if ", "").replace("()", "").replace("{", "").strip()

                for item in strings.keys:
                    var modifier = "$"&item
                    name = name.replace(modifier, $(strings[item]))

                for item in floats.keys:
                    var modifier = "$"&item
                    name = name.replace(modifier, $(floats[item]))

                for item in lists.keys:
                    var modifier = "$"&item
                    name = name.replace(modifier, $(lists[item]))

                if_names[name] = ifcounter

                var index = code.find(statement)
                var ifcontent: seq[string] = @[]

                if oslib_imported == true:
                    ifcontent.add("include os")
                if timelib_imported == true:
                    ifcontent.add("include time")
                if browserlib_imported == true:
                    ifcontent.add("include browser")

                for item in libraries:
                    ifcontent.add("include " & item)

                for item in globals:
                    ifcontent.add(item)

                for i in index + 1 ..< code.len:

                    var line = code[i]

                    var check = line.replace(":*#$?!>-+ ", "").strip()

                    if  "}" in check.strip().split():
                        break
                    if check.strip() == "{":
                        discard
                    else:
                        ifcontent.add(check)
                        forbidden.add(i)

                ifs.add(ifcontent.join("\n"))

                ifcounter += 1

                if check(name) == true:
                    discard interpret(ifs[if_names[name]])
                else:
                    discard

            elif statement.startsWith("for "):

                var numbers: seq[string] = @["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

                var variable = statement.strip().replace("for ", "").replace("()", "").replace("{", "").strip().split(" in ")[0]
                var list = statement.strip().replace("for ", "").replace("()", "").replace("{", "").strip().split(" in ")[1]

                if numbers.anyIt(list.startsWith(it)):
                    for x in 1..parseInt(list):
                        var iterName = list & "[" & $(x) & "]"
                        lists[iterName] = $(x)

                var index = code.find(statement)
                var forcontent: seq[string] = @[]

                if oslib_imported == true:
                    forcontent.add("include os")
                if timelib_imported == true:
                    forcontent.add("include time")

                for item in libraries:
                    forcontent.add("include " & item)

                for item in globals:
                    forcontent.add(item)

                for i in index + 1 ..< code.len:

                    var line = code[i]

                    var check = line.replace(":*#$?!>-+ ", "").strip()

                    if  "}" in check.strip().split():
                        break
                    if check.strip() == "{":
                        discard
                    else:
                        forcontent.add(check)
                        forbidden.add(i)

                var loop = forcontent.join("\n")
                var listItems: seq[string] = @[]

                for listItem in lists.keys:

                    if listItem.startsWith(list&"["):
                        listItems.add(lists[listItem].replace(list&"[", "").replace("]", ""))

                for x in 0..len(listItems)-1:
                    discard interpret("global " & variable & " = " & listItems[x] & "\n" & loop)

            elif statement.startsWith("while "):
                var name = statement.strip().replace("while ", "").replace("()", "").replace("{", "").strip()

                for item in strings.keys:
                    var modifier = "$"&item
                    name = name.replace(modifier, $(strings[item]))

                for item in floats.keys:
                    var modifier = "$"&item
                    name = name.replace(modifier, $(floats[item]))

                for item in lists.keys:
                    var modifier = "$"&item
                    name = name.replace(modifier, $(lists[item]))

                while_names[name] = whilecounter

                var index = code.find(statement)
                var whilecontent: seq[string] = @[]

                if oslib_imported == true:
                    whilecontent.add("include os")
                if timelib_imported == true:
                    whilecontent.add("include time")

                for item in libraries:
                    whilecontent.add("include " & item)

                for item in globals:
                    whilecontent.add(item)

                for i in index + 1 ..< code.len:

                    var line = code[i]

                    var check = line.replace(":*#$?!>-+ ", "").strip()

                    if check.strip().startsWith("global "):
                        globals.add(check.strip())

                    if  "}" in check.strip().split():
                        break
                    if check.strip() == "{":
                        discard
                    else:
                        whilecontent.add(check)
                        forbidden.add(i)

                whiles.add(whilecontent.join("\n"))

                whilecounter += 1

                while check(name) == true:
                    discard interpret(whiles[while_names[name]])

            elif function_names_seq.anyIt(statement.startsWith(it)):
                var name = statement.strip().replace("call ", "").split("(")[0]

                var extraLines = statement.split("(")[1].replace(")", "").split(",")

                for x in 0..len(extraLines)-1:

                    for item in strings.keys:
                        var modifier = "$"&item
                        extraLines[x] = extraLines[x].replace(modifier, $(strings[item]))

                    for item in floats.keys:
                        var modifier = "$"&item
                        extraLines[x] = extraLines[x].replace(modifier, $(floats[item]))

                    for item in lists.keys:
                        var modifier = "$"&item
                        extraLines[x] = extraLines[x].replace(modifier, $(lists[item]))

                var fetchedContent = functions[function_names[name]]
                var functionVars: seq[string] = @[]

                for item in fetchedContent.split("\n"):
                    if item.startsWith("funcvar "):
                        functionVars.add(item.replace("funcvar ", ""))

                var arguments = 0

                for item in fetchedContent.split("\n"):
                    if item.startsWith("funcvar "):
                        arguments = arguments + 1

                if len(extraLines) == arguments:
                    discard
                else:
                    echo "Error: Does not match arguments count in function: " & name
                    quit()

                for x in 0..len(extraLines)-1:
                    fetchedContent = "var " & functionVars[x].replace("funcvar", "") & " = " & extraLines[x] & "\n" & fetchedContent

                discard interpret(parserepl(fetchedContent))

            elif statement.startsWith("call "):
                var name = statement.strip().replace("call ", "").split("(")[0]

                var extraLines = statement.split("(")[1].replace(")", "").split(",")

                for x in 0..len(extraLines)-1:

                    for item in strings.keys:
                        var modifier = "$"&item
                        extraLines[x] = extraLines[x].replace(modifier, $(strings[item]))

                    for item in floats.keys:
                        var modifier = "$"&item
                        extraLines[x] = extraLines[x].replace(modifier, $(floats[item]))

                    for item in lists.keys:
                        var modifier = "$"&item
                        extraLines[x] = extraLines[x].replace(modifier, $(lists[item]))

                var fetchedContent = functions[function_names[name]]
                var functionVars: seq[string] = @[]

                for item in fetchedContent.split("\n"):
                    if item.startsWith("funcvar "):
                        functionVars.add(item.replace("funcvars ", ""))

                var arguments = 0

                for item in fetchedContent.split("\n"):
                    if item.startsWith("funcvar "):
                        arguments = arguments + 1

                if len(extraLines) == arguments:
                    discard
                else:
                    echo "Error: Does not match arguments count in function: " & name
                    quit()

                for x in 0..len(extraLines)-1:
                    fetchedContent = "var " & functionVars[x].replace("funcvar", "") & " = " & extraLines[x] & "\n" & fetchedContent

                try:
                    lists[name] = interpret(fetchedContent)
                except:
                    echo "Uranium: Error on line " & $(counter) & ". Function does not exist."
                    quit(1)

            elif statement.startsWith("os."):
                discard
            elif statement.startsWith("time."):
                discard
            elif statement.startsWith("math."):
                discard
            elif statement.startsWith("browser."):
                discard
                
            elif statement.startswith("include "):
                discard

            elif statement.startsWith("return "):
                var toReturn = statement.replace("return ", "")

                for item in strings.keys:
                    var modifier = "$"&item
                    toReturn = toReturn.replace(modifier, $(strings[item]))

                for item in floats.keys:
                    var modifier = "$"&item
                    toReturn = toReturn.replace(modifier, $(floats[item]))

                for item in lists.keys:
                    var modifier = "$"&item
                    toReturn = toReturn.replace(modifier, $(lists[item]))

                return toReturn

            elif statement.startswith("//"):
                discard
            elif "}" in statement:
                discard
            elif statement == "":
                discard
            elif statement == "exit()":
                quit(1)

            elif statement.startsWith("funcvar"):
                discard

            else:
                echo "Error: invalid command: " & statement
                quit(1)

            if oslib_imported == true:
                if statement.startsWith("os."):
                    var functionName = statement.replace("os.", "")

                    for item in strings.keys:
                        var modifier = "$"&item
                        functionName = functionName.replace(modifier, $(strings[item]))

                    for item in floats.keys:
                        var modifier = "$"&item
                        functionName = functionName.replace(modifier, $(floats[item]))

                    for item in lists.keys:
                        var modifier = "$"&item
                        functionName = functionName.replace(modifier, $(lists[item]))

                    functionName = functionName.replace("\"", "")

                    discard oslib.runtime(functionName)

            if browserlib_imported == true:
                if statement.startsWith("browser."):
                    var functionName = statement.replace("browser.", "")

                    for item in strings.keys:
                        var modifier = "$"&item
                        functionName = functionName.replace(modifier, $(strings[item]))

                    for item in floats.keys:
                        var modifier = "$"&item
                        functionName = functionName.replace(modifier, $(floats[item]))

                    for item in lists.keys:
                        var modifier = "$"&item
                        functionName = functionName.replace(modifier, $(lists[item]))

                    functionName = functionName.replace("\"", "")

                    discard browserlib.runtime(functionName)

            if timelib_imported == true:
                if statement.startsWith("time."):
                    var functionName = statement.replace("time.", "")

                    for item in strings.keys:
                        var modifier = "$"&item
                        functionName = functionName.replace(modifier, $(strings[item]))

                    for item in floats.keys:
                        var modifier = "$"&item
                        functionName = functionName.replace(modifier, $(floats[item]))

                    for item in lists.keys:
                        var modifier = "$"&item
                        functionName = functionName.replace(modifier, $(lists[item]))

                    functionName = functionName.replace("\"", "")

                    discard timelib.runtime(functionName)

            if statement == "exit()":
                quit(1)
                    
        counter += 1

    return ""
