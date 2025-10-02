import os
import shutil

os.chdir("..")
os.chdir("source")

os.system("nim c uranium.nim")
shutil.move("uranium", "..")

os.chdir("..")
os.mkdir("bin")

shutil.move("uranium", "bin")

print("Done. Results can be found in ./bin")