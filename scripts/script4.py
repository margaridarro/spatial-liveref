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

folder_path = sys.argv[1] #diretório onde está o projeto a ser analisado (via argumento ao executar o script)

cred = credentials.Certificate("spatial-liveref-firebase-adminsdk-60cy8-515e58503f.json")
firebase_admin.initialize_app(cred)
db = firestore.client()


while(True):
    openFilesDocs = db.collection("openFiles").get()
    print(len(openFilesDocs))
    
    for id, doc in enumerate(openFilesDocs):
        doc.reference.delete()
        if id == 0 :
            print(doc.id)
            print(doc.to_dict()["filePath"])
            os.system("idea " + folder_path + doc.to_dict()["filePath"])
    time.sleep(1)
    if (len(openFilesDocs) != 0):
        os.system("rm -r " + folder_path + "/Prints")
        
    



