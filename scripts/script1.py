import subprocess
import glob
import os
import time
import sys

import datetime

folder_path = sys.argv[1] #diretório onde está o projeto a ser analisado (via argumento ao executar o script)

command_remove_Prints = "rm -r " + folder_path + "/Prints"
os.system(command_remove_Prints)

os.system("idea " + folder_path)
print(folder_path)
time.sleep(90)

subfolders = [f.path for f in os.scandir(folder_path) if f.is_dir()]
printFileName = folder_path + "/Prints/files.txt"

timeoutFiles = []

counter = 1
for folder_path in subfolders:
    java_files = glob.glob(folder_path + "/**/*.java", recursive=True)
    for file_path in java_files:
        print(file_path)
        if "/src/" in file_path and "/test/" not in file_path:
            if "package-info.java" not in file_path:
                '''
                if counter % 5 == 0:
                    time.sleep(5)
                else:
                    time.sleep(1)
                   '''
                command = "idea --line 1 " + file_path
                print("command return value: ", os.system(command)) # opens java file
                
                found = False
                time0 = datetime.datetime.now()
                counter += 1
                while not found:
                    time.sleep(0.5)
                    if os.path.exists(printFileName):
                        expected_print = file_path #+ " DONE."
                        with open(printFileName, "r") as filePrints:
                            #print("opened ", printFileName)
                            prints = filePrints.readlines()
                            for p in prints:
                                #print("\t", p)
                                if expected_print in p:
                                    print("Found the specific print: ", p)
                                    found = True
                                    break
                            
                            if found:
                                break
                            
                            if datetime.datetime.now() > time0 + datetime.timedelta(seconds = 40):
                                timeoutFiles.append(file_path)
                                print("\nTIMEOUT FILES:", timeoutFiles, "\n")
                                # time.sleep(5)
                                break
                            
                    
#os.system("cp -R Prints /Users/margaridaraposo/Documents/tese/spatial-liveref/SpatialLiveRef/SpatialLiveRef/Prints")

# breaking
