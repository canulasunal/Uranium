import std/strutils

proc refresh*(command: string): string =
    var updated = command

    updated = updated.replace("math.pi()", "3.141592653589")

    return updated

