//
//  FileReader.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 25/03/2024.
//

import Foundation

func getProjectFiles () -> ([String : BuildingEntity], [[String]], [[String]]) {

    /*
    // LPOO project
    let file = "projects/feup-lpoo/proj/Prints/files.txt"
    let refactorings_file = "projects/feup-lpoo/proj/Prints/refactorings.txt"
    */
    var buildingEntities : [String: BuildingEntity] = [:]
    var file_list: [[String]] = []
    var refactorings_list: [[String]] = []
  
    let fileURL = Bundle.main.url(forResource: "Prints/files", withExtension: "txt")
   
    do {
        let text = try String(contentsOf: fileURL!, encoding: .utf8)
        let lines = text.components(separatedBy: "\n")
        
        for (id, line) in lines.enumerated() {
            
            if line.contains("File: ") {
                
                let file_name = lines[id].replacingOccurrences(of: "File: ", with: "")
                let file_path = lines[id+1].replacingOccurrences(of: "File Path: ", with: "")
                let loc_string = lines[id+3].replacingOccurrences(of: "   LOC: ", with: "")
                let nom_string = lines[id+4].replacingOccurrences(of: "   NOM: ", with: "")
                let n_refactorings_string = lines[id+5].replacingOccurrences(of: "   Number of Refactorings: ", with: "")
                
                let loc : Int! = Int(loc_string)
                let nom : Int! = Int(nom_string)
                let n_refactorings : Int! = Int(n_refactorings_string)
                
                file_list.append([file_name, file_path, loc_string, nom_string, n_refactorings_string])
                buildingEntities[file_path] = BuildingEntity(fileName: file_name, filePath: file_path, loc: loc, nom: nom, numberRefactorings: n_refactorings, refactorings: [])
            }
        }
    } catch {
        print("\nFiles Error info: \(error)\n")
        return ([:], [["0"]], [["0"]])
    }
    
    let refactoringsURL = Bundle.main.url(forResource: "Prints/refactorings", withExtension: "txt")

    do {
        let text_refactorings = try String(contentsOf: refactoringsURL!, encoding: .utf8)
        let lines = text_refactorings.components(separatedBy: "\n")
        
        for (id, line) in lines.enumerated() {
            
            var refactoring_type : RefactoringType = RefactoringType.ExtractVariable
            var refactoring_name : String = ""
            var method_name : String = ""
            var file_path : String = ""
            var n_elements_string : String = ""
            var severity_string : String = ""
            var loc_to_change_string : String = ""
            var class_name : String = ""
            
            var refactoring_found = false
            
            if line.contains("Extract Variable:") {
                /*
                 Extract Variable:
                 
                 Range: LogicalPosition: (2453, 15) -> LogicalPosition: (2453, 125)
                 Method: zip
                 Node: zipArray(Functions.toFunction(zipper), source1, source2, source3, source4, source5, source6, source7, source8)
                 File:/Users/margaridaraposo/Documents/projects/RxJava/src/main/java/io/reactivex/rxjava3/core/Single.java
                 Number of Elements: 110
                 Severity: 9.863636363636363
                 LOC To Be Changed: 1
                 */
            
                refactoring_type = RefactoringType.ExtractVariable
                refactoring_name = line.replacingOccurrences(of: ":", with: "")
                method_name =  lines[id+3].replacingOccurrences(of: "Method: ", with: "")
                
                var next_line_id = id+4
                var current_line = ""
                while !current_line.contains("File") {
                    current_line = lines[next_line_id]
                    next_line_id += 1
                }
                file_path = lines[next_line_id-1].replacingOccurrences(of: "File: ", with: "")
                n_elements_string = lines[next_line_id].replacingOccurrences(of: "Number of Elements: ", with: "")
                severity_string = lines[next_line_id+1].replacingOccurrences(of: "Severity: ", with: "")
                loc_to_change_string = lines[next_line_id+2].replacingOccurrences(of: "LOC To Be Changed: ", with: "")
  
                refactoring_found = true
                // TODO verify file "DONE" message
                // TODO verify number of refactoring when "DONE"
                
            } else if line.contains("Extract Method:") {
                /*
                 Extract Method:
                 
                 Method: test
                 File:/Users/margaridaraposo/Documents/projects/RxJava/src/main/java/io/reactivex/rxjava3/core/Single.java
                 Range: LogicalPosition: (5577, 8) -> LogicalPosition: (5579, 9)
                 Number of Elements: 3
                 Severity: 10.0
                 LOC To Be Changed: 6
                 */
                refactoring_type = RefactoringType.ExtractMethod
                refactoring_name = line.replacingOccurrences(of: ":", with: "")
                method_name =  lines[id+2].replacingOccurrences(of: "Method: ", with: "")
                file_path = lines[id+3].replacingOccurrences(of: "File: ", with: "")
                n_elements_string = lines[id+5].replacingOccurrences(of: "Number of Elements: ", with: "")
                severity_string = lines[id+6].replacingOccurrences(of: "Severity: ", with: "")
                loc_to_change_string = lines[id+7].replacingOccurrences(of: "LOC To Be Changed: ", with: "")
                
                refactoring_found = true
                // TODO verify file "DONE" message
                // TODO verify number of refactoring when "DONE"
                
            } else if line.contains("Extract Class:") {
                /*
                 Extract Class:
                 
                 Class: SpscLinkedArrayQueue
                 File: /Users/margaridaraposo/Documents/projects/RxJava/src/main/java/io/reactivex/rxjava3/operators/SpscLinkedArrayQueue.java
                 Number of Elements: 0
                 Severity: 10.0
                 ----------- Entities -----------
                 Method: resize   Method: lvNextBufferAndUnlink   Method: peek   Method: size
                 LOC To Be Changed: 21
                 */
                refactoring_type = RefactoringType.ExtractClass
                refactoring_name = line.replacingOccurrences(of: ":", with: "")
                class_name =  lines[id+2].replacingOccurrences(of: "Class: ", with: "")
                file_path = lines[id+3].replacingOccurrences(of: "File: ", with: "")
                n_elements_string = lines[id+4].replacingOccurrences(of: "Number of Elements: ", with: "")
                severity_string = lines[id+5].replacingOccurrences(of: "Severity: ", with: "")
                method_name = lines[id+7].replacingOccurrences(of: "Method: ", with: "")
                loc_to_change_string = lines[id+8].replacingOccurrences(of: "LOC To Be Changed: ", with: "")
                               
                refactoring_found = true
                
            } else if line.contains("Introduce Parameter Object:") {
                /*
                 Introduce Parameter Object:
                 
                 Method: zip
                 File:/Users/margaridaraposo/Documents/projects/RxJava/src/main/java/io/reactivex/rxjava3/core/Single.java
                 Number Elements: 10
                 Severity: 10.0
                 LOC To Be Changed: 0
                 */
                refactoring_type = RefactoringType.IntroduceParameterObject
                refactoring_name = line.replacingOccurrences(of: ":", with: "")
                method_name =  lines[id+2].replacingOccurrences(of: "Method: ", with: "")
                file_path = lines[id+3].replacingOccurrences(of: "File:", with: "")
                n_elements_string = lines[id+4].replacingOccurrences(of: "Number Elements: ", with: "")
                severity_string = lines[id+5].replacingOccurrences(of: "Severity: ", with: "")
                loc_to_change_string = lines[id+6].replacingOccurrences(of: "LOC To Be Changed: ", with: "")
                
                refactoring_found = true
            }
            
            if refactoring_found {
                
                refactorings_list.append([refactoring_name, method_name, file_path, n_elements_string, severity_string, loc_to_change_string, class_name])
                
                let n_elements : Int! = Int(n_elements_string)
                let severity : Float! = Float(severity_string)
                let loc_to_change : Int! = Int(loc_to_change_string)
                
                let refactoring = Refactoring(refactoringType: refactoring_type, methodName: method_name, elements: n_elements, severity: severity, locToChange: loc_to_change, className: class_name)
                
                if buildingEntities.keys.contains(file_path) {
                    buildingEntities[file_path]!.addRefactoring(refactoring: refactoring)
                }
            }
        
        }
    } catch {
        print("\nRefactorings Error info: \(error)\n")
        return (buildingEntities, file_list, [["1"]])
    }
    return (buildingEntities, file_list, refactorings_list)
}



