//
//  main.swift
//  quest5
//
//  Created by Knapptan on 24.01.2024.
//

import Foundation


// Функция для сравнения содержимого двух файлов
func compareFiles(filePath1: String, filePath2: String) -> String {
    do {
        let content1 = try String(contentsOfFile: filePath1, encoding: .utf8)
        let content2 = try String(contentsOfFile: filePath2, encoding: .utf8)

        if content1 == content2 {
            return "Resumes are identical"
        } else {
            return "Resumes have differences"
        }
    } catch {
        return "Error reading files: \(error)"
    }
}

// Функция для проверки пути
func isDirectory(_ path: String) -> Bool {
    var isDirectory: ObjCBool = false
    let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
    
    return exists && isDirectory.boolValue
}

func writeToFile(filePath: String, content: String) {
    do {
        try content.write(toFile: filePath, atomically: true, encoding: .utf8)
    } catch {
        print("Error writing to file: \(error)")
    }
}


func main() {
    
    // зпрашиваем путь
    print("For using In/out: Enter files path without file name: ")
    guard let filePath = readLine() else {
        print("Error reading from files.")
        return
    }
    // проверяем что это путь
    if !isDirectory(filePath) {
        print("The '\(filePath)' is not directory")
        return
    } else {
        
        let resumeFilePath = "\(filePath)resume.txt"
        let exportFilePath = "\(filePath)export.txt"
        
        // Сравниваем файлы
        let result = compareFiles(filePath1: resumeFilePath, filePath2: exportFilePath)
        
        // Выводим результат
        print("Text comparator: \(result)")
    }
    return
}

main()

///Users/knapptan/Desktop/Projects/Swift_Bootcamp.Day02-1/src/quest2/quest2/
