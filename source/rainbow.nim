import sequtils
import terminal
import random

proc print*(text: string) =

    var text_list = text.toSeq
    
    for item in text_list:
        var choice = rand(6)

        if choice == 0:
            setForegroundColor(fgBlue)
        elif choice == 1:
            setForegroundColor(fgGreen)
        elif choice == 2:
            setForegroundColor(fgRed)
        elif choice == 3:
            setForegroundColor(fgYellow)
        elif choice == 4:
            setForegroundColor(fgCyan)
        elif choice == 5:
            setForegroundColor(fgMagenta)

        stdout.write(item)
        resetAttributes()