import std/strutils

proc check*(expression: string): bool =
    if "=" in expression:
        var parsed = expression.replace("if ", "").replace("{", "").replace("}", "").strip().split("=")
        var final: seq[string] = @[]

        for item in parsed:
            final.add(item.strip().replace("\"", ""))
            
        if final[0] == final[1]:
            return true
        else:
            return false

    elif ">" in expression:
        var parsed = expression.replace("if ", "").replace("{", "").replace("}", "").strip().split(">")
        var final: seq[string] = @[]

        for item in parsed:
            final.add(item.strip())

        if final[0] > final[1]:
            return true
        else:
            return false

    elif "<" in expression:
        var parsed = expression.replace("if ", "").replace("{", "").replace("}", "").strip().split("<")
        var final: seq[string] = @[]

        for item in parsed:
            final.add(item.strip())

        if final[0] < final[1]:
            return true
        else:
            return false