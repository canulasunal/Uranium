import std/strutils
import times
import os

##########################################################################################

proc year(): int =
    var dateTime = $(now())
    return parseInt(dateTime.split("-")[0])

proc month(): int =
    var dateTime = $(now())
    return parseInt(dateTime.split("-")[1])

proc day(): int =
    var dateTime = $(now())
    return parseInt(dateTime.split("-")[2].split("T")[0])

##########################################################################################

proc runtime*(command: string): string =
    if command.strip().startsWith("sleep(") and command.endsWith(")"):
        sleep(int(parseFloat(command.replace("sleep(", "").replace(")", "").strip())*1000.0))

    return ""

proc refresh*(command: string): string =
    var updated = command

    updated = updated.replace("time.month()", $(month()))
    updated = updated.replace("time.day()", $(day()))
    updated = updated.replace("time.year()", $(year()))

    return updated