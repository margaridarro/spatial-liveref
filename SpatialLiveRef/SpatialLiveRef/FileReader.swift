//
//  FileReader.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 25/03/2024.
//

import Foundation

func getProjectFiles (file_path : String, refactorings_path : String) -> ([[String]], [[String]]) {

    /*
    // LPOO project
    let file = "projects/feup-lpoo/proj/Prints/files.txt"
    let refactorings_file = "projects/feup-lpoo/proj/Prints/refactorings.txt"
    */
    
    var file_list: [[String]] = []
    var refactorings_list: [[String]] = []
  
    let fileURL = Bundle.main.url(forResource: "Prints/files", withExtension: "txt")
   
    do {
        let text = try String(contentsOf: fileURL!, encoding: .utf8)
        //print("text:", text)
        let lines = text.components(separatedBy: "\n")
        //print("lines:", lines)
        
        for (id, line) in lines.enumerated() {
            
            if line.contains("File: ") {
                
                let file_name = lines[id].replacingOccurrences(of: "File: ", with: "")
                let file_path = lines[id+1].replacingOccurrences(of: "File Path: ", with: "")
                let loc = lines[id+3].replacingOccurrences(of: "   LOC: ", with: "")
                let nom = lines[id+4].replacingOccurrences(of: "   NOM: ", with: "")
                let n_refactorings = lines[id+5].replacingOccurrences(of: "   Number of Refactorings: ", with: "")
                
                file_list.append([file_name, file_path, loc, nom, n_refactorings])
                
            }
            
        }
    } catch {
        print("\nFiles Error info: \(error)\n")
        return ([["0"]], [["0"]])
    }
    
    let refactoringsURL = Bundle.main.url(forResource: "Prints/refactorings", withExtension: "txt")

    do {
        let text_refactorings = try String(contentsOf: refactoringsURL!, encoding: .utf8)
        let lines = text_refactorings.components(separatedBy: "\n")
        //print(lines)
        
        for (id, line) in lines.enumerated() {
            
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
                let refactoring = line.replacingOccurrences(of: ":", with: "")
                let method_name =  lines[id+3].replacingOccurrences(of: "Method: ", with: "")
                let file_path = lines[id+5].replacingOccurrences(of: "File: ", with: "")
                let n_elements = lines[id+6].replacingOccurrences(of: "Number of Elements: ", with: "")
                let severity = lines[id+7].replacingOccurrences(of: "Severity: ", with: "")
                let loc_to_change = lines[id+8].replacingOccurrences(of: "LOC To Be Changed: ", with: "")
                
                refactorings_list.append([refactoring, method_name, file_path, n_elements, severity, loc_to_change])
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
                let refactoring = line.replacingOccurrences(of: ":", with: "")
                let method_name =  lines[id+2].replacingOccurrences(of: "Method: ", with: "")
                let file_path = lines[id+3].replacingOccurrences(of: "File: ", with: "")
                let n_elements = lines[id+5].replacingOccurrences(of: "Number of Elements: ", with: "")
                let severity = lines[id+6].replacingOccurrences(of: "Severity: ", with: "")
                let loc_to_change = lines[id+7].replacingOccurrences(of: "LOC To Be Changed: ", with: "")
                
                refactorings_list.append([refactoring, method_name, file_path, n_elements, severity, loc_to_change])
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
                let refactoring = line.replacingOccurrences(of: ":", with: "")
                let class_name =  lines[id+2].replacingOccurrences(of: "Class: ", with: "")
                let file_path = lines[id+3].replacingOccurrences(of: "File: ", with: "")
                let n_elements = lines[id+4].replacingOccurrences(of: "Number of Elements: ", with: "")
                let severity = lines[id+5].replacingOccurrences(of: "Severity: ", with: "")
                let method_name = lines[id+7].replacingOccurrences(of: "Method: ", with: "")
                let loc_to_change = lines[id+8].replacingOccurrences(of: "LOC To Be Changed: ", with: "")
                
                refactorings_list.append([refactoring, method_name, file_path, n_elements, severity, loc_to_change, class_name])
                
            } else if line.contains("Introduce Parameter Object:") {
                /*
                 Introduce Parameter Object:
                 
                 Method: zip
                 File:/Users/margaridaraposo/Documents/projects/RxJava/src/main/java/io/reactivex/rxjava3/core/Single.java
                 Number Elements: 10
                 Severity: 10.0
                 LOC To Be Changed: 0
                 */
                let refactoring = line.replacingOccurrences(of: ":", with: "")
                let method_name =  lines[id+2].replacingOccurrences(of: "Method: ", with: "")
                let file_path = lines[id+3].replacingOccurrences(of: "File:", with: "")
                let n_elements = lines[id+4].replacingOccurrences(of: "Number of Elements: ", with: "")
                let severity = lines[id+5].replacingOccurrences(of: "Severity: ", with: "")
                let loc_to_change = lines[id+6].replacingOccurrences(of: "LOC To Be Changed: ", with: "")
                
                refactorings_list.append([refactoring, method_name, file_path, n_elements, severity, loc_to_change])
            }
        }
    } catch {
        print("\nRefactorings Error info: \(error)\n")
        return (file_list, [["1"]])
    }
   
    return (file_list, refactorings_list)
}
