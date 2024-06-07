import os
import sys
import json
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

folder_path = sys.argv[1] #diretório onde está o projeto a ser analisado (via argumento ao executar o script)

os.system("rm files.txt")
os.system("rm refactorings.txt")

os.system("cp " + folder_path + "/Prints/files.txt /Users/margaridaraposo/Documents/tese/spatial-liveref/scripts")

os.system("cp " + folder_path + "/Prints/refactorings.txt /Users/margaridaraposo/Documents/tese/spatial-liveref/scripts")

os.system("rm -r " + folder_path + "/Prints")

# Firebase initializer
cred = credentials.Certificate("spatial-liveref-firebase-adminsdk-60cy8-515e58503f.json")
firebase_admin.initialize_app(cred)
db = firestore.client()


os.system("firebase firestore:delete -r files")
os.system("firebase firestore:delete -r refactorings")


# ProjectPath
db.collection("project").document("path").set({"value": folder_path})


# Add all files
files = open("files.txt","r")
files_lines = files.readlines()

for id, line in enumerate(files_lines):

    if "File: " in line:
        fileName = line.replace("File: ", "").replace("\n", "").replace(" ", "")
        fileID = files_lines[id+1].replace("File Path: ", "").replace(folder_path, "").replace("\n", "").replace("/", "")
        filePath = files_lines[id+1].replace("File Path: ", "").replace(folder_path, "").replace("\n", "").replace(" ", "").replace("File:", "")
        loc = int(files_lines[id+3].replace("   LOC: ", ""))
        nom = int(files_lines[id+4].replace("   NOM: ", ""))
        nRefactorings = int(files_lines[id+5].replace("   Number of Refactorings: ", ""))

        db.collection("files").document(fileID).set({"fileName" : fileName, "filePath" : filePath, "loc" : loc, "nom": nom, "nRefactorings": nRefactorings})


# Refactorings
refactorings = open("refactorings.txt","r")
refactorings_lines = refactorings.readlines()
counter = 1
for id, line in enumerate(refactorings_lines):

    if "Extract Variable:" in line:
        methodName = refactorings_lines[id+3].replace("Method: ", "")
        
        next_line = id+4
        current_line = ""
        while "File" not in current_line:
            current_line = refactorings_lines[next_line]
            next_line += 1
        
        fileID = refactorings_lines[next_line-1].replace("File Path: ", "").replace(folder_path, "").replace("\n", "").replace("/", "").replace(" ", "").replace("File:", "") + str(counter)
        filePath = refactorings_lines[next_line-1].replace("File: ", "").replace(folder_path, "").replace("\n", "").replace(" ", "").replace("File:", "")
        elements = int(refactorings_lines[next_line].replace("Number of Elements: ", ""))
        severity = float(refactorings_lines[next_line+1].replace("Severity: ", ""))
        locToChange = int(refactorings_lines[next_line+2].replace("LOC To Be Changed: ", ""))

        db.collection("refactorings").document(fileID).set({"refactoringType" : "ExtractVariable", "methodName" : methodName, "filePath" : filePath, "locToChange" : locToChange, "elements": elements, "severity": severity, "className": ""})

    elif "Extract Method:" in line:
        methodName = refactorings_lines[id+2].replace("Method: ", "")
        fileID = refactorings_lines[id+3].replace("File Path: ", "").replace(folder_path, "").replace("\n", "").replace("/", "").replace(" ", "").replace("File:", "") + str(counter)
        filePath = refactorings_lines[id+3].replace("File: ", "").replace(folder_path, "").replace("\n", "").replace(" ", "").replace("File:", "")
        elements = int(refactorings_lines[id+5].replace("Number of Elements: ", ""))
        severity = float(refactorings_lines[id+6].replace("Severity: ", ""))
        locToChange = int(refactorings_lines[id+7].replace("LOC To Be Changed: ", ""))

        db.collection("refactorings").document(fileID).set({"refactoringType" : "ExtractMethod", "methodName" : methodName, "filePath" : filePath, "locToChange" : locToChange, "elements": elements, "severity": severity, "className": ""})
        
    elif "Extract Class:" in line:
        className = refactorings_lines[id+2].replace("Class: ", "")
        fileID = refactorings_lines[id+3].replace("File Path: ", "").replace(folder_path, "").replace("\n", "").replace("/", "").replace(" ", "").replace("File:", "") + str(counter)
        filePath = refactorings_lines[id+3].replace("File: ", "").replace(folder_path, "").replace("\n", "").replace(" ", "").replace("File:", "")
        elements = int(refactorings_lines[id+4].replace("Number of Elements: ", ""))
        severity = float(refactorings_lines[id+5].replace("Severity: ", ""))
        methodName = refactorings_lines[id+7].replace("Method: ", "")
        locToChange = int(refactorings_lines[id+8].replace("LOC To Be Changed: ", ""))

        db.collection("refactorings").document(fileID).set({"refactoringType" : "ExtractClass", "methodName" : methodName, "filePath" : filePath, "locToChange" : locToChange, "elements": elements, "severity": severity, "className": className})
    
    elif "Introduce Parameter Object:" in line:
        methodName = refactorings_lines[id+2].replace("Method: ", "")
        fileID = refactorings_lines[id+3].replace("File Path: ", "").replace(folder_path, "").replace("\n", "").replace("/", "").replace(" ", "").replace("File:", "") + str(counter)
        filePath = refactorings_lines[id+3].replace("File: ", "").replace(folder_path, "").replace("\n", "").replace(" ", "").replace("File:", "")
        elements = int(refactorings_lines[id+4].replace("Number of Elements: ", ""))
        severity = float(refactorings_lines[id+5].replace("Severity: ", ""))
        locToChange = int(refactorings_lines[id+6].replace("LOC To Be Changed: ", ""))

        db.collection("refactorings").document(fileID).set({"refactoringType" : "IntroduceParameterObject", "methodName" : methodName, "filePath" : filePath, "locToChange" : locToChange, "elements": elements, "severity": severity, "className": ""})
        
    elif "Move Method:" in line:
        methodName = refactorings_lines[id+2].replace("Method: ", "")
        fileID = refactorings_lines[id+3].replace("File Path: ", "").replace(folder_path, "").replace("\n", "").replace("/", "").replace(" ", "").replace("File:", "") + str(counter)
        filePath = refactorings_lines[id+3].replace("File: ", "").replace(folder_path, "").replace("\n", "").replace(" ", "").replace("File:", "")
        elements = int(refactorings_lines[id+6].replace("Number of Elements: ", ""))
        severity = float(refactorings_lines[id+7].replace("Severity: ", "").replace("\n", ""))
        locToChange = int(refactorings_lines[id+8].replace("LOC To Be Changed: ", ""))

        db.collection("refactorings").document(fileID).set({"refactoringType" : "MoveMethod", "methodName" : methodName, "filePath" : filePath, "locToChange" : locToChange, "elements": elements, "severity": severity, "className": ""})
    counter += 1
