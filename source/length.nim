import std/strutils

proc length*(command: string, line: int): float =
    try:
        discard parseInt(command)
        discard parseFloat(command)
        echo "Uranium: Error on line " & $(line) & ". " & command & " does not support the len() function due to type errors."
        quit(1)
    except:
        return float(len(command))

    return 0