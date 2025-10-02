import strutils
import browsers

proc runtime*(command: string): string =
    if command.startsWith("open("):
        openDefaultBrowser(command.replace("open(", "").replace(")", ""))