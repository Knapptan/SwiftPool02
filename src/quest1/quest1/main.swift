//
//  main.swift
//  quest1
//
//  Created by Knapp Tania on 1/18/24.
//

import Foundation

// Енам для описания сфер деятельности
enum Activity {
    case IT
    case Banking
    case PublicServices
}

// Енам для описания профессий
enum Profession {
    case Developer
    case QA
    case ProjectManager
    case Analyst
    case Designer
}

// Енам для описания уровней квалификации
enum Level {
    case Junior
    case Middle
    case Senior
}

// Класс для описания компаний
class Company {
    let Name: String
    let Activity: Activity
    let Description: String?
    let Jobs: [Vacancy]
    let Skills: Set<String>
    let Contacts: String
    
    init(_ name: String, _ activity: Activity, _ description: String, _ contacts: String, _ skills: Set<String>, _ jobs: [Vacancy]) {
        self.Name = name
        self.Activity = activity
        self.Contacts = contacts
        self.Description = description
        self.Skills = skills
        self.Jobs = jobs
    }
    
    func interview(_ jobIndex: Int, _ candidate: Candidate) -> Bool {
        guard jobIndex >= 0, jobIndex < Jobs.count else {
            print("Invalid job index.")
            return false
        }

        let job = Jobs[jobIndex]

        let matchingSkills = Set(candidate.Skills).intersection(job.Skills)
        let matchPercentage = Double(matchingSkills.count) / Double(job.Skills.count) * 100

        if matchPercentage < 50 {
            print("Candidate doesn't have enough skills for the job.")
            return false
        }

        let randomResult = Bool.random()
        if randomResult {
            print("Success, candidate was hired.")
        } else {
            print("Unfortunately, candidate wasn't hired.")
        }

        return randomResult
    }
}

// Класс для описания кандидатов
class Candidate {
    let Name: String
    let Profession: Profession
    let Level: Level
    let Salary: Int
    let Skills: Set<String>
    
    init(_ name: String, _ profession: Profession, _ level: Level, _ salary: Int, _ skills: Set<String>) {
        self.Name = name
        self.Profession = profession
        self.Level = level
        self.Salary = salary
        self.Skills = skills
    }
}

// Класс для описания вакансий
class Vacancy {
    let Profession: Profession
    let Level: Level
    let Salary: Int
    let Skills: Set<String>
    
    init(_ profession: Profession, _ level: Level, _ salary: Int, _ skills: Set<String>) {
        self.Profession = profession
        self.Level = level
        self.Salary = salary
        self.Skills = skills
    }
}

func main() {
    let Vasya = Candidate("Vasyliy", .Developer, .Junior, 90000, ["Swift", "SQL", "Bash", "Git", "С++", "QT", "Python", "Linux", "Xcode"])

    var Companies = [Company]() // Создание пустого массива
    
    // Создание вакансий для разных компаний
    let vacancy1 = Vacancy(.Developer, .Junior, 100000, ["Swift", "SQL", "Git"])
    let vacancy2 = Vacancy(.QA, .Middle, 90000, ["Manual Testing", "Automation Testing", "Jira"])
    let vacancy3 = Vacancy(.Analyst, .Senior, 120000, ["Python", "SQL", "Excel"])
    let vacancy4 = Vacancy(.ProjectManager, .Senior, 180000, ["Python", "SQL", "Excel", "Jira", "Git"])

    // Создание компаний
    let company1 = Company("Ondex", .IT, "Description1", "Contacts1", ["Swift", "SQL", "Git"], [vacancy1, vacancy2])
    let company2 = Company("Sbur", .Banking, "Description2", "Contacts2", ["Java", "C#", "SQL"], [vacancy3, vacancy4])

    Companies.append(company1)
    Companies.append(company2)
    
    // Вывод кандидата
    print("""
    Candidate:
    - Name: \(Vasya.Name)
    - Profession: \(Vasya.Profession)
    - Level: \(Vasya.Level)
    - Salary: \(Vasya.Salary)
    - Skills: \(Vasya.Skills)
    
    """)
    
    // Вывод подходящих вакансий для кандидата
    print("IT/Banking. \(Vasya.Profession). \(Vasya.Level). >=  \(Vasya.Salary)")
    print("The list of suitable vacancies:")
    for (index, company) in Companies.enumerated() {
        print("\(index + 1).")
        for job in company.Jobs {
            print("\(job.Level) \(job.Profession)     ---      >= \(job.Salary)")
            print("  \(company.Name)")
            print("  \(company.Activity)")
            print("  \(job.Skills)")
            print("---------------------------------------")
        }
    }

    // Пользовательский ввод номера вакансии
    print("Enter the number of the job for interview:")
    guard var jobIndex = Int(readLine() ?? ""), jobIndex > 0 else {
        print("It doesn't look like a correct input.")
        return
    }

    // Проведение собеседования
    var companyForInterview: Company?

    for company in Companies {
        if jobIndex <= company.Jobs.count {
            companyForInterview = company
            break
        } else {
            jobIndex -= company.Jobs.count
        }
    }

    guard let selectedCompany = companyForInterview else {
        print("Invalid job index.")
        return
    }

    _ = selectedCompany.interview(jobIndex - 1, Vasya)}

main()
