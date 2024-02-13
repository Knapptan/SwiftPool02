//
//  main.swift
//  quest2
//
//  Created by Knapptan on 22.01.2024.
//

import Foundation

// Расширение для массива - безопасный доступ по индексу
extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// Енам для описания пола
enum Gender: String {
    case Male
    case Female
}

// Енам для описания профессий
enum Profession: String {
    case Developer
    case QA
    case ProjectManager
    case Analyst
    case Designer
}

// Структура описания информации о кандидате
struct CandidateInfo {
    var FullName: String
    var Profession: Profession
    var Gender: Gender
    var BirthDate: String
    var Contacts: String

    init(FullName: String, Profession: Profession, Gender: Gender, BirthDate: String, Contacts: String) {
        self.FullName = FullName
        self.Profession = Profession
        self.Gender = Gender
        self.BirthDate = BirthDate
        self.Contacts = Contacts
    }
}

// Структура описания образвания кандидата
struct EducationInfo {
    var TypeEducation: String
    var YearsOfStudy: String
    var Description: String
}

// Структура описания опыта работы кандидата
struct WorkExperience {
    var WorkingPeriod: String
    var CompanyName: String
    var Contacts: String
    var Description: String
}

// Структура описания шаблона резюме
struct Resume {
    var CandidateInfo: CandidateInfo
    var EducationInfo: [EducationInfo]
    var WorkExperience: [WorkExperience]
    var AboutYourself: String
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

// Функция для чтения файла
func readFileContent(_ path: String) -> String? {
    guard let fileHandle = FileHandle(forReadingAtPath: path) else {
        print("The file at path '\(path)' could not be opened for reading.")
        return nil
    }

    defer {
        fileHandle.closeFile()
    }

    let data = fileHandle.readDataToEndOfFile()

    guard let content = String(data: data, encoding: .utf8) else {
        print("Failed to convert data to string for file at path '\(path)'.")
        return nil
    }

    return content
}

func parseCandidateInfo(_ components: [String]) -> CandidateInfo? {
    let fullName = components[safe: 0] ?? ""
    let professionString = components[safe: 1] ?? ""
    let genderString = components[safe: 2] ?? ""
    let birthDate = components[safe: 3] ?? ""
    let contacts = components[safe: 4] ?? ""

    guard let profession = Profession(rawValue: professionString) else {
        print("Invalid profession: \(professionString)")
        return nil
    }

    guard let gender = Gender(rawValue: genderString) else {
        print("Invalid gender: \(genderString)")
        return nil
    }

    return CandidateInfo(FullName: fullName, Profession: profession, Gender: gender, BirthDate: birthDate, Contacts: contacts)
}


func parseEduInfo(_ components: [String]) -> EducationInfo? {
    let type = components[safe: 0] ?? ""
    let yearsOfStudy = components[safe: 1] ?? ""
    let description = components[safe: 2] ?? ""
    
    return EducationInfo(TypeEducation: type, YearsOfStudy: yearsOfStudy, Description: description)
}

func parseJobInfo(_ components: [String]) -> [WorkExperience]? {
    var workExperienceArray = [WorkExperience]()
    var currentIndex = 0

    while currentIndex < components.count {
        guard components[safe: currentIndex] == "##" else {
            print("Invalid job info format.")
            return nil
        }

        let workingPeriod = components[safe: currentIndex + 1] ?? ""
        let companyName = components[safe: currentIndex + 2] ?? ""
        let contacts = components[safe: currentIndex + 3] ?? ""
        let description = components[safe: currentIndex + 4] ?? ""

        let jobInfo = WorkExperience(WorkingPeriod: workingPeriod,
                                     CompanyName: companyName,
                                     Contacts: contacts,
                                     Description: description)
        workExperienceArray.append(jobInfo)

        // Переходим к следующей группе данных (следующему "##")
        currentIndex += 5
    }

    return workExperienceArray
}

// Функция для разделения блоков на основе заголовков
func splitResumeBlocks(_ content: String) -> [String: [String]] {
    var result = [String: [String]]()
    var currentBlock: String?

    let lines = content.components(separatedBy: .newlines)

    for line in lines {
        if line.isEmpty || line == "..." {
            continue
        } else if line.starts(with: "# ") {
            currentBlock = String(line.dropFirst(2))
            result[currentBlock!] = []
        } else if let currentBlock = currentBlock {
            result[currentBlock, default: []].append(line)
        }
    }

    return result
}

func parseResume(resumeText: String) -> Resume? {
    // Функция для разделения блоков на основе заголовков
    let resumeBlocks = splitResumeBlocks(resumeText)

    // Парсинг информации о кандидате
    guard let candidateInfoBlock = resumeBlocks["Candidate info"],
          let candidateInformation = parseCandidateInfo(candidateInfoBlock) else {
        print("Failed to parse candidate information.")
        return nil
    }

    // Парсинг информации об образовании
    guard let educationBlock = resumeBlocks["Education"],
          let educationInformation = parseEduInfo(educationBlock) else {
        print("Failed to parse education information.")
        return nil
    }

    // Парсинг информации об опыте работы
    guard let experienceBlock = resumeBlocks["Job experience"],
          let experienceInformation = parseJobInfo(experienceBlock) else {
        print("Failed to parse job experience information.")
        return nil
    }

    // Парсинг информации о свободном блоке
    guard let freeInformation = resumeBlocks["Free block"] else {
        print("Failed to parse job free block information.")
        return nil
    }

    // Создание объекта Resume
    let resume = Resume(CandidateInfo: candidateInformation,
                        EducationInfo: [educationInformation],
                        WorkExperience: experienceInformation,
                        AboutYourself: freeInformation.joined(separator: "\n"))
    return resume
}

func exportResume(_ resume: Resume,_ filePath: String) {
    let exportString1 = "# Candidate info\n\(resume.CandidateInfo.FullName)\n\(resume.CandidateInfo.Profession)\n\(resume.CandidateInfo.Gender)\n\(resume.CandidateInfo.BirthDate)\n\(resume.CandidateInfo.Contacts)\n...\n\n"
    
    var exportString2 = "# Education"
    for education in resume.EducationInfo {
        exportString2 += "\n\(education.TypeEducation)\n\(education.YearsOfStudy)\n\(education.Description)\n"
    }
    exportString2 += "...\n"
    
    var exportString3 = "\n# Job experience\n"
    for experience in resume.WorkExperience {
        exportString3 += "##\n\(experience.WorkingPeriod)\n\(experience.CompanyName)\n\(experience.Contacts)\n\(experience.Description)\n"
    }
    let exportString4 = "...\n\n# Free block\n\(resume.AboutYourself)\n...\n"
    
    let exportString = exportString1 + exportString2 + exportString3 + exportString4
    
    writeToFile(filePath: "\(filePath)export.txt", content: exportString)
}

func extractWords(text: String) -> [String] {
    return text.components(separatedBy: CharacterSet.whitespacesAndNewlines).filter { !$0.isEmpty }
}

func countWordOccurrences(words: [String]) -> [String: Int] {
    var wordOccurrences: [String: Int] = [:]
    for word in words {
        wordOccurrences[word, default: 0] += 1
    }
    return wordOccurrences
}

func findMatchingTags(words: [String], tags: [String]) -> [String] {
    let matchingTags = Set(words).intersection(Set(tags))
    return Array(matchingTags)
}

func analyzeResume(_ resumeText: String,_ tags: [String],_ filePath: String) {
    let words = extractWords(text: resumeText)
    let wordOccurrences = countWordOccurrences(words: words)
    let matchingTags = findMatchingTags(words: words, tags: tags)
    
    let sortedWordOccurrences = wordOccurrences.sorted { $0.value > $1.value }
    var content = "# Words\n"
    for (word, count) in sortedWordOccurrences { content += "\(word) - \(count)\n" }
    
    content += "\n# Matched Tags\n"
    for tag in matchingTags { content += "\(tag)\n" }
    
    writeToFile(filePath: "\(filePath)analysis.txt", content: content)
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
        // считываем весь файл резюме
        let resumePath = filePath + "resume.txt"
        guard let resumeContent = readFileContent(resumePath) else {
            print("Error reading from resume.txt.")
            return
        }
        // парсим в объект резюме
        guard let resume = parseResume(resumeText: resumeContent)else {
            print("Error parsing resume.")
            return
        }
        print("File resume.txt has been converted in object: \n\(resume)")
        // экспортируем в файл экспорта
        exportResume(resume, filePath)
        print("Object resume has been converted in file: \n\(filePath)export.txt")
        // считываем весь файл тегов
        let tagsPath = filePath + "tags.txt"
        guard let tagsContent = readFileContent(tagsPath) else {
            print("Error reading from tags.txt.")
            return
        }
        // парсим теги в массив
        let tags = tagsContent.components(separatedBy: CharacterSet.newlines).filter { !$0.isEmpty && $0 != "..." }
        print("File tags.txt has been converted in arr : \n\(tags)" )
        
        // ищем свопадения тегов с резюме и записываем в файл анализа
        analyzeResume(resumeContent, tags, filePath)
        print("Arr tags has been converted in file: \n\(filePath)analysis.txt")
    }
}
    
main()

// /Users/knapptan/Desktop/Projects/Swift_Bootcamp.Day02-1/src/quest2/quest2/
