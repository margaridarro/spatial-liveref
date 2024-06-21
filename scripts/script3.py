import os
import sys
import os.path
import glob
import time
import json
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from google.cloud.firestore_v1.base_query import FieldFilter
'''from pathlib import Path

folder_path = sys.argv[1] #diretório onde está o projeto a ser analisado (via argumento ao executar o script)

if os.path.isfile("files.txt"):
    os.system("rm files.txt")
    
if os.path.isfile("refactorings.txt"):
    os.system("rm refactorings.txt")


# Firebase initializer
cred = credentials.Certificate("spatial-liveref-firebase-adminsdk-60cy8-515e58503f.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

files_documents = db.collection("files").get()
java_files = []
for file_doc in files_documents:
    java_files.append(file_doc.to_dict()["filePath"])

time_counter = 0
lastOpenedFile = ""
stopFlag = False
printsPath = Path(folder_path + "/Prints")

while(True):
    time.sleep(1)
    time_counter += 1
    if printsPath.is_dir():
        os.system("cp " + folder_path + "/Prints/files.txt /Users/margaridaraposo/Documents/tese/spatial-liveref/scripts")
        os.system("cp " + folder_path + "/Prints/refactorings.txt /Users/margaridaraposo/Documents/tese/spatial-liveref/scripts")
        os.system("rm -r " + folder_path + "/Prints")
    updatedFilePaths = []
    
    if time_counter % 2:
    
        openFilesDocs = db.collection("openFiles").get()
        print(len(openFilesDocs))
        
        for id, doc in enumerate(openFilesDocs):
            doc.reference.delete()
            if id == 0 :
                print(doc.id)
                lastOpenedFile = doc.to_dict()["filePath"]
                os.system("idea --line 1 " + folder_path + doc.to_dict()["filePath"])
        time.sleep(3)
        if (len(openFilesDocs) != 0):
            if printsPath.is_dir():
                os.system("rm -r " + folder_path + "/Prints")
                lastOpenedFile = ""
    
    if time_counter % 8 == 0:
        subfolders = [f.path for f in os.scandir(folder_path) if f.is_dir()]
        new_java_files = []
        for curr_folder_path in subfolders:
            new_java_files += glob.glob(curr_folder_path + "/**/*.java", recursive=True)
            
        new_java_files1 = [file.replace(folder_path, "") for file in new_java_files if "/src/" in file and "/test/" not in file]
        
        files_diff = [file for file in java_files if file not in new_java_files1]
        print("\nDIFF:\n", files_diff)
        time_counter += 1
        for deleted_file_path in files_diff:
            # Delete removed files
            docs = db.collection("files").where(filter=FieldFilter("filePath", "==", deleted_file_path)).get()
            for doc in docs:
                doc.reference.delete()
    
    if os.path.isfile("files.txt"):
        
        print("New files")
        # Update files
        files = open("files.txt","r")
        files_lines = files.readlines()

        for id, line in enumerate(files_lines):
            if "File: " in line:
                fileName = line.replace("File: ", "").replace("\n", "").replace(" ", "")
                fileID = files_lines[id+1].replace("File Path: ", "").replace(folder_path, "").replace("\n", "").replace("/", "")
                filePath = files_lines[id+1].replace("File Path: ", "").replace(folder_path, "").replace("\n", "").replace(" ", "").replace("File:", "")
                if filePath == lastOpenedFile:
                    print("New file opened through visualization")
                    os.system("rm -r " + folder_path + "/Prints")
                    lastOpenedFile = ""
                    stopFlag = True
                    break
                loc = int(files_lines[id+3].replace("   LOC: ", "").replace("\n", ""))
                nom = int(files_lines[id+4].replace("   NOM: ", "").replace("\n", ""))
                nRefactorings = int(files_lines[id+5].replace("   Number of Refactorings: ", ""))

                db.collection("files").document(fileID).set({"fileName" : fileName, "filePath" : filePath, "loc" : loc, "nom": nom, "nRefactorings": nRefactorings})
                updatedFilePaths.append(filePath)

        if stopFlag:
            os.system("rm files.txt")
            os.system("rm refactorings.txt")
            stopFlag = False
            continue;

        # Refactorings

        # Delete old refactorings from edited files
        for updatedFilePath in updatedFilePaths:

            # Delete updated refactorings
            docs = db.collection("refactorings").where(filter=FieldFilter("filePath", "==", updatedFilePath)).get()
            for doc in docs:
                doc.reference.delete()


        # Add new refactorings for edited files
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
                elements = int(refactorings_lines[next_line].replace("Number of Elements: ", "").replace("Number Elements: ", "").replace("\n", ""))
                severity = float(refactorings_lines[next_line+1].replace("Severity: ", ""))
                locToChange = int(refactorings_lines[next_line+2].replace("LOC To Be Changed: ", ""))

                db.collection("refactorings").document(fileID).set({"refactoringType" : "ExtractVariable", "methodName" : methodName, "filePath" : filePath, "locToChange" : locToChange, "elements": elements, "severity": severity, "className": ""})

            elif "Extract Method:" in line:
                methodName = refactorings_lines[id+2].replace("Method: ", "")
                fileID = refactorings_lines[id+3].replace("File Path: ", "").replace(folder_path, "").replace("\n", "").replace("/", "").replace(" ", "").replace("File:", "") + str(counter)
                filePath = refactorings_lines[id+3].replace("File: ", "").replace(folder_path, "").replace("\n", "").replace(" ", "").replace("File:", "")
                elements = int(refactorings_lines[id+5].replace("Number of Elements: ", "").replace("Number Elements: ", "").replace("\n", ""))
                severity = float(refactorings_lines[id+6].replace("Severity: ", ""))
                locToChange = int(refactorings_lines[id+7].replace("LOC To Be Changed: ", ""))

                db.collection("refactorings").document(fileID).set({"refactoringType" : "ExtractMethod", "methodName" : methodName, "filePath" : filePath, "locToChange" : locToChange, "elements": elements, "severity": severity, "className": ""})
                
            elif "Extract Class:" in line:
                className = refactorings_lines[id+2].replace("Class: ", "")
                fileID = refactorings_lines[id+3].replace("File Path: ", "").replace(folder_path, "").replace("\n", "").replace("/", "").replace(" ", "").replace("File:", "") + str(counter)
                filePath = refactorings_lines[id+3].replace("File: ", "").replace(folder_path, "").replace("\n", "").replace(" ", "").replace("File:", "")
                elements = int(refactorings_lines[id+4].replace("Number of Elements: ", "").replace("Number Elements: ", "").replace("\n", ""))
                severity = float(refactorings_lines[id+5].replace("Severity: ", ""))
                methodName = refactorings_lines[id+7].replace("Method: ", "")
                locToChange = int(refactorings_lines[id+8].replace("LOC To Be Changed: ", ""))

                db.collection("refactorings").document(fileID).set({"refactoringType" : "ExtractClass", "methodName" : methodName, "filePath" : filePath, "locToChange" : locToChange, "elements": elements, "severity": severity, "className": className})
            
            elif "Introduce Parameter Object:" in line:
                methodName = refactorings_lines[id+2].replace("Method: ", "")
                fileID = refactorings_lines[id+3].replace("File Path: ", "").replace(folder_path, "").replace("\n", "").replace("/", "").replace(" ", "").replace("File:", "") + str(counter)
                filePath = refactorings_lines[id+3].replace("File: ", "").replace(folder_path, "").replace("\n", "").replace(" ", "").replace("File:", "")
                elements = int(refactorings_lines[id+4].replace("Number of Elements: ", "").replace("Number Elements: ", "").replace("\n", ""))
                severity = float(refactorings_lines[id+5].replace("Severity: ", ""))
                locToChange = int(refactorings_lines[id+6].replace("LOC To Be Changed: ", ""))

                db.collection("refactorings").document(fileID).set({"refactoringType" : "IntroduceParameterObject", "methodName" : methodName, "filePath" : filePath, "locToChange" : locToChange, "elements": elements, "severity": severity, "className": ""})
                
            elif "Move Method:" in line:
                methodName = refactorings_lines[id+2].replace("Method: ", "")
                fileID = refactorings_lines[id+3].replace("File Path: ", "").replace(folder_path, "").replace("\n", "").replace("/", "").replace(" ", "").replace("File:", "") + str(counter)
                filePath = refactorings_lines[id+3].replace("File: ", "").replace(folder_path, "").replace("\n", "").replace(" ", "").replace("File:", "")
                elements = int(refactorings_lines[id+6].replace("Number of Elements: ", "").replace("Number Elements: ", "").replace("\n", ""))
                severity = float(refactorings_lines[id+7].replace("Severity: ", "").replace("\n", ""))
                locToChange = int(refactorings_lines[id+8].replace("LOC To Be Changed: ", ""))

                db.collection("refactorings").document(fileID).set({"refactoringType" : "MoveMethod", "methodName" : methodName, "filePath" : filePath, "locToChange" : locToChange, "elements": elements, "severity": severity, "className": ""})
            counter += 1
        os.system("rm files.txt")
        os.system("rm refactorings.txt")
'''

folder_path = sys.argv[1] #diretório onde está o projeto a ser analisado (via argumento ao executar o script)

os.system("rm files.txt")
os.system("rm refactorings.txt")


# Firebase initializer
cred = credentials.Certificate("spatial-liveref-firebase-adminsdk-60cy8-515e58503f.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

files_documents = db.collection("files").get()
java_files = []
for file_doc in files_documents:
    java_files.append(file_doc.to_dict()["filePath"])

time_counter = 0
lastOpenedFile = ""
stopFlag = False

while(True):
    time.sleep(1)
    time_counter += 1
    os.system("cp " + folder_path + "/Prints/files.txt /Users/margaridaraposo/Documents/tese/spatial-liveref/scripts")
    os.system("cp " + folder_path + "/Prints/refactorings.txt /Users/margaridaraposo/Documents/tese/spatial-liveref/scripts")
    os.system("rm -r " + folder_path + "/Prints")
    updatedFilePaths = []
    
    if time_counter % 2:
    
        openFilesDocs = db.collection("openFiles").get()
        print(len(openFilesDocs))
        
        for id, doc in enumerate(openFilesDocs):
            doc.reference.delete()
            if id == 0 :
                print(doc.id)
                print(doc.to_dict()["filePath"])
                lastOpenedFile = doc.to_dict()["filePath"]
                os.system("idea --line 1 " + folder_path + doc.to_dict()["filePath"])
        time.sleep(3)
        if (len(openFilesDocs) != 0):
            os.system("rm -r " + folder_path + "/Prints")
    
    if time_counter % 8 == 0:
        subfolders = [f.path for f in os.scandir(folder_path) if f.is_dir()]
        new_java_files = []
        for curr_folder_path in subfolders:
            new_java_files += glob.glob(curr_folder_path + "/**/*.java", recursive=True)
            
        new_java_files1 = [file.replace(folder_path, "") for file in new_java_files if "/src/" in file and "/test/" not in file]
        
        files_diff = [file for file in java_files if file not in new_java_files1]
        print("\nDIFF:\n", files_diff)
        time_counter += 1
        for deleted_file_path in files_diff:
            # Delete removed files
            docs = db.collection("files").where(filter=FieldFilter("filePath", "==", deleted_file_path)).get()
            for doc in docs:
                doc.reference.delete()
    
    if os.path.isfile("files.txt"):
        
        print("New files")
        # Update files
        files = open("files.txt","r")
        files_lines = files.readlines()

        for id, line in enumerate(files_lines):
            print("file: " + line)
            if "File: " in line:
                fileName = line.replace("File: ", "").replace("\n", "").replace(" ", "")
                fileID = files_lines[id+1].replace("File Path: ", "").replace(folder_path, "").replace("\n", "").replace("/", "")
                filePath = files_lines[id+1].replace("File Path: ", "").replace(folder_path, "").replace("\n", "").replace(" ", "").replace("File:", "")
                if filePath == lastOpenedFile:
                    print("New file opened through visualization")
                    os.system("rm -r " + folder_path + "/Prints")
                    lastOpenedFile = ""
                    stopFlag = True
                    break
                loc = int(files_lines[id+3].replace("   LOC: ", "").replace("\n", ""))
                nom = int(files_lines[id+4].replace("   NOM: ", "").replace("\n", ""))
                nRefactorings = int(files_lines[id+5].replace("   Number of Refactorings: ", ""))

                db.collection("files").document(fileID).set({"fileName" : fileName, "filePath" : filePath, "loc" : loc, "nom": nom, "nRefactorings": nRefactorings})
                updatedFilePaths.append(filePath)

        if stopFlag:
            os.system("rm files.txt")
            os.system("rm refactorings.txt")
            stopFlag = False
            continue;

        # Refactorings

        # Delete old refactorings from edited files
        for updatedFilePath in updatedFilePaths:

            # Delete updated refactorings
            docs = db.collection("refactorings").where(filter=FieldFilter("filePath", "==", updatedFilePath)).get()
            for doc in docs:
                print("refID: " + doc.id)
                doc.reference.delete()


        # Add new refactorings for edited files
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
                elements = int(refactorings_lines[next_line].replace("Number of Elements: ", "").replace("Number Elements: ", "").replace("\n", ""))
                severity = float(refactorings_lines[next_line+1].replace("Severity: ", ""))
                locToChange = int(refactorings_lines[next_line+2].replace("LOC To Be Changed: ", ""))

                db.collection("refactorings").document(fileID).set({"refactoringType" : "ExtractVariable", "methodName" : methodName, "filePath" : filePath, "locToChange" : locToChange, "elements": elements, "severity": severity, "className": ""})

            elif "Extract Method:" in line:
                methodName = refactorings_lines[id+2].replace("Method: ", "")
                fileID = refactorings_lines[id+3].replace("File Path: ", "").replace(folder_path, "").replace("\n", "").replace("/", "").replace(" ", "").replace("File:", "") + str(counter)
                filePath = refactorings_lines[id+3].replace("File: ", "").replace(folder_path, "").replace("\n", "").replace(" ", "").replace("File:", "")
                elements = int(refactorings_lines[id+5].replace("Number of Elements: ", "").replace("Number Elements: ", "").replace("\n", ""))
                severity = float(refactorings_lines[id+6].replace("Severity: ", ""))
                locToChange = int(refactorings_lines[id+7].replace("LOC To Be Changed: ", ""))

                db.collection("refactorings").document(fileID).set({"refactoringType" : "ExtractMethod", "methodName" : methodName, "filePath" : filePath, "locToChange" : locToChange, "elements": elements, "severity": severity, "className": ""})
                
            elif "Extract Class:" in line:
                className = refactorings_lines[id+2].replace("Class: ", "")
                fileID = refactorings_lines[id+3].replace("File Path: ", "").replace(folder_path, "").replace("\n", "").replace("/", "").replace(" ", "").replace("File:", "") + str(counter)
                filePath = refactorings_lines[id+3].replace("File: ", "").replace(folder_path, "").replace("\n", "").replace(" ", "").replace("File:", "")
                elements = int(refactorings_lines[id+4].replace("Number of Elements: ", "").replace("Number Elements: ", "").replace("\n", ""))
                severity = float(refactorings_lines[id+5].replace("Severity: ", ""))
                methodName = refactorings_lines[id+7].replace("Method: ", "")
                locToChange = int(refactorings_lines[id+8].replace("LOC To Be Changed: ", ""))

                db.collection("refactorings").document(fileID).set({"refactoringType" : "ExtractClass", "methodName" : methodName, "filePath" : filePath, "locToChange" : locToChange, "elements": elements, "severity": severity, "className": className})
            
            elif "Introduce Parameter Object:" in line:
                methodName = refactorings_lines[id+2].replace("Method: ", "")
                fileID = refactorings_lines[id+3].replace("File Path: ", "").replace(folder_path, "").replace("\n", "").replace("/", "").replace(" ", "").replace("File:", "") + str(counter)
                filePath = refactorings_lines[id+3].replace("File: ", "").replace(folder_path, "").replace("\n", "").replace(" ", "").replace("File:", "")
                elements = int(refactorings_lines[id+4].replace("Number of Elements: ", "").replace("Number Elements: ", "").replace("\n", ""))
                severity = float(refactorings_lines[id+5].replace("Severity: ", ""))
                locToChange = int(refactorings_lines[id+6].replace("LOC To Be Changed: ", ""))

                db.collection("refactorings").document(fileID).set({"refactoringType" : "IntroduceParameterObject", "methodName" : methodName, "filePath" : filePath, "locToChange" : locToChange, "elements": elements, "severity": severity, "className": ""})
                
            elif "Move Method:" in line:
                methodName = refactorings_lines[id+2].replace("Method: ", "")
                fileID = refactorings_lines[id+3].replace("File Path: ", "").replace(folder_path, "").replace("\n", "").replace("/", "").replace(" ", "").replace("File:", "") + str(counter)
                filePath = refactorings_lines[id+3].replace("File: ", "").replace(folder_path, "").replace("\n", "").replace(" ", "").replace("File:", "")
                elements = int(refactorings_lines[id+6].replace("Number of Elements: ", "").replace("Number Elements: ", "").replace("\n", ""))
                severity = float(refactorings_lines[id+7].replace("Severity: ", "").replace("\n", ""))
                locToChange = int(refactorings_lines[id+8].replace("LOC To Be Changed: ", ""))

                db.collection("refactorings").document(fileID).set({"refactoringType" : "MoveMethod", "methodName" : methodName, "filePath" : filePath, "locToChange" : locToChange, "elements": elements, "severity": severity, "className": ""})
            counter += 1
        os.system("rm files.txt")
        os.system("rm refactorings.txt")


