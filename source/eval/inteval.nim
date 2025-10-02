import std/strutils
import sequtils

proc old_evaluate*(expression: string): float =

    var parsed = expression

    parsed = parsed.replace("+", " + ")
    parsed = parsed.replace("-", " - ")
    parsed = parsed.replace("*", " * ")
    parsed = parsed.replace("/", " / ")

    var command = parsed.split()
    var final: seq[string] = @[]

    for item in command:
        if item != "":
            final.add(item)

    var base = parseFloat(final[0])

    var counter = 0

    for item in final:
        if item == "+":
            base += parseFloat(final[counter + 1])
        elif item == "-":
            base -= parseFloat(final[counter + 1])
        elif item == "/":
            base = base / parseFloat(final[counter + 1])
        elif item == "*":
            base = base * parseFloat(final[counter + 1])

        counter += 1

    return base

proc evaluate_float*(expression: string): float =
    var parsed = expression.strip().replace(" ", "").split("+")
    var ans = 0.0
    for item in parsed:
        ans += parseFloat(item)
    return ans

proc new_evaluate*(item: string): float =
    var changed = item.replace(" ", "").replace("/", " / ").replace("+", " + ").replace("*", " * ").replace("-", " - ")
    var parsed = changed.split(" ")

    for x in 0..len(parsed)-1:
        if parsed[x] == "*":
            parsed[x] = $(parseFloat(parsed[x-1]) * parseFloat(parsed[x+1]))
            parsed[x-1] = ""
            parsed[x+1] = ""

        elif parsed[x] == "/":
            parsed[x] = $(parseFloat(parsed[x-1]) / parseFloat(parsed[x+1]))
            parsed[x-1] = ""
            parsed[x+1] = ""

    var newparsed: seq[string] = @[]

    for item in parsed:
        if item != "":
            newparsed.add(item)

    var ans = parseFloat(newparsed[0])

    for item in 0 .. len(newparsed)-1:
        if newparsed[item] == "+":
            ans += parseFloat(newparsed[item+1])
        if newparsed[item] == "-":
            ans -= parseFloat(newparsed[item+1])

    return ans

proc evaluatex*(text: string): float =
    var parsed = text.split("+")

    for item in 0..len(parsed)-1:
        parsed[item] = $(old_evaluate(parsed[item]))

    var ans = 0.0

    for item in parsed:
        ans = ans+parseFloat(item)

    return ans

proc evaluate*(text: string): float =

    var valid_chars: seq[char] = @['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '-', '/', '*', '.']

    for item in text:
        if item in valid_chars:
            discard
        else:
            raise newException(ValueError, "Alphanumeric strings can not be evaluated")

    var symbols: seq[string] = @[]

    for item in text.toSeq:
        if $(item) == "-":
            symbols.add("-")
        elif $(item) == "+":
            symbols.add("+")

    var parsed = text.replace(" ", "").replace("+", " + ").replace("-", " - ")
    var document: seq[string] = @[]

    var parsedx = parsed.replace(" - ", "a").replace(" + ", "a").split("a")

    symbols.add("+")

    for x in 0..len(parsedx)-1:
        document.add(parsedx[x])
        document.add(symbols[x])

    document.add("0")

    for x in 0..len(document)-1:
        if document[x] != "+" and document[x] != "-":
            document[x] = $(old_evaluate(document[x]))

    var ans = parseFloat(document[0])

    for x in 0..len(document)-1:
        if document[x] == "+":
            ans += parseFloat(document[x+1])
        elif document[x] == "-":
            ans -= parseFloat(document[x+1])

    return ans