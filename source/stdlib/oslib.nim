import os
import std/strutils

proc runtime*(command: string): string =
    if command.startsWith("system(") and command.endsWith(")"):
        when defined(windows):
            discard os.execShellCmd("powershell -Command " & command.replace("system(", "").replace(")", "").strip())
        else:
            discard os.execShellCmd(command.replace("system(", "").replace(")", "").strip())

    elif command.startsWith("chdir(") and command.endsWith(")"):
        os.setCurrentDir(command.replace("chdir(", "").replace(")", "").replace("\"", "").strip())

    elif command.startsWith("remove("):
        let removeArguments = command.replace("remove(", "").replace(")", "").replace("\"", "")

        try:
            removeDir(removeArguments)
        except:
            removeFile(removeArguments)

    elif command.startsWith("new(") and command.endsWith(")"):
        writeFile(command.replace("new(", "").replace(")", "").strip(), "")

    elif command.startsWith("write(") and command.endsWith(")"):
        var arguments = command.replace("write(", "").replace(")", "").strip()

        var contents = arguments.split(":")[1]
        var file = arguments.split(":")[0]
        writeFile(file, contents)

    else:
        var executable = command.split("(")[0]
        var sysrun = command.split("(")[1].replace(")", "")

        when defined(windows):
            discard os.execShellCmd("powershell -Command " & executable & " " & sysrun)
        else:
            discard os.execShellCmd(executable & " " & sysrun)

proc refresh*(command: string): string =
    var updated = command

    updated = updated.replace("os.path()", os.getCurrentDir())
    updated = updated.replace("~", os.getHomeDir())

    return updated
