//
//  AddExpenseViewModel.swift
//  Group5
//
//  Created by Eden Fernando on 3/5/2026.
//

import Foundation
import Combine

class ExpenseViewModel: ObservableObject {
    
    @Published var chatMessages: [ChatMessage] = []
    
    // expenses
    @Published var expenses: [ExpenseItem] = [] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    // total monthly budget amount
    @Published var monthlyBudget: Double = 0
    {
        didSet
        {
            saveMonthlyBudget()
        }
    }
    
    //  budget limit information for all categories
    @Published var categoryLimits: [CategoryLimit] = ExpenseCategory.allCases.map
    {
        CategoryLimit(category: $0)
    }
    {
        didSet
        {
            saveCategoryLimits()
        }
    }
    
    // total amount spent
    @Published var monthlySpent: Double = 0
    
    // calculate total for the current month
    var currentMonthTotal: Double {
        let calendar = Calendar.current
        return expenses
            .filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
            .reduce(0) { $0 + $1.spending }
    }
    
    // calculate the total category budget limit
    var totalCategoryLimit: Double
    {
        categoryLimits.reduce(0) { $0 + $1.limit }
    }
    
    // calculate the total for the "Today" tab
    var todayTotal: Double {
        let calendar = Calendar.current
        return expenses
            .filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.spending }
    }
    
    // calculate remaining budget
    var remainingMonthlyBudget: Double {
        return monthlyBudget - currentMonthTotal
    }
    
    // UserDefaults storage
    private let monthlyBudgetKey = "SavedMonthlyBudget"
    private let categoryLimitsKey = "SavedCategoryLimits"
    private let saveKey = "SavedExpenses"
    

    // initialiser
    init()
    {
        loadBudgetData()
        loadFromUserDefaults()
    }
    
    // set the total monthly budget amount
    func setMonthlyBudget(_ amount: Double)
    {
        monthlyBudget = amount
    }
    
    // update the budget limit for a specific category
    // returns true if the update succeeds
    // returns false if the total category limit exceeds the monthly budget
    func setCategoryLimit(category: ExpenseCategory, limit: Double) -> Bool {
        guard let index = categoryLimits.firstIndex(where: { $0.category == category })
        else
        {
            return false
        }
        
        let currentLimit = categoryLimits[index].limit
        let newTotalLimit = totalCategoryLimit - currentLimit + limit
        
        if newTotalLimit > monthlyBudget
        {
            return false
        }
        
        var updatedLimits = categoryLimits
        updatedLimits[index].limit = limit
        
        // reassign the whole array so didSet runs and UserDefaults saves
        categoryLimits = updatedLimits
        
        return true
    }
    
    // calculates the total amount of money spent on a specific day
    func totalFor(day: Date) -> Double {
        let calendar = Calendar.current
        return expenses
            .filter { calendar.isDate($0.date, inSameDayAs: day) }
            .reduce(0) { $0 + $1.spending }
    }
    
    // delete an expense
    func deleteExpense(_ item: ExpenseItem) {
        expenses.removeAll { $0.id == item.id }
    }
    
    // save monthly budget to UserDefaults
    private func saveMonthlyBudget()
    {
        UserDefaults.standard.set(monthlyBudget, forKey: monthlyBudgetKey)
    }
    
    // save data using JSON encoding
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    // load monthly budget and category limits from UserDefaults
    private func loadBudgetData()
    {
        monthlyBudget = UserDefaults.standard.double(forKey: monthlyBudgetKey)
        
        if let data = UserDefaults.standard.data(forKey: categoryLimitsKey),
           let decoded = try? JSONDecoder().decode([CategoryLimit].self, from: data)
        {
            categoryLimits = decoded
        }
    }
    
    
    // save category limits to UserDefaults
    private func saveCategoryLimits()
    {
        if let encoded = try? JSONEncoder().encode(categoryLimits)
        {
            UserDefaults.standard.set(encoded, forKey: categoryLimitsKey)
        }
    }
   
    // expenses for a specifc date
    func expensesFor(day: Date) -> [ExpenseItem] {
        let calendar = Calendar.current
        return expenses.filter { calendar.isDate($0.date, inSameDayAs: day) }
    }

    
    // load data using JSON decoding
    private func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([ExpenseItem].self, from: data) {
            self.expenses = decoded
        }
    }

}

extension ExpenseViewModel {

    // Call the Gemini Web API using a standard HTTP POST network request
    func sendToGemini(userMessage: String) async {
        let currentYear = Calendar.current.component(.year, from: Date())
        var dataContext = "Context: Local spending history for year \(currentYear):\n"


        for expense in self.expenses {
            dataContext += "- \(expense.category.rawValue.capitalized): $\(Int(expense.spending)) on \(expense.date.formatted(date: .abbreviated, time: .omitted))\n"
        }

        let urlString = Env.apiURL
        
        print(urlString)


        guard let url = URL(string: urlString) else { return }

        //  Correct Gemini request format
        let jsonPayload: [String: Any] = [
                "contents": [
                    [
                        "role": "user",
                        "parts": [
                            ["text": "\(dataContext)\n\nUser Question: \(userMessage)"]
                        ]
                    ]
                ]
            ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonPayload) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            // 🔍 Print raw response for debugging
            if let raw = String(data: data, encoding: .utf8) {
                print("RAW RESPONSE:", raw)
            }

            // Parse Gemini response
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = json["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let firstPart = parts.first,
               let responseText = firstPart["text"] as? String {

                await MainActor.run {
                    self.chatMessages.append(
                        ChatMessage(text: responseText.trimmingCharacters(in: .whitespacesAndNewlines), isUser: false)
                    )
                }
            }

            //  Handle API errors
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = json["error"] as? [String: Any],
               let message = error["message"] as? String {

                await MainActor.run {
                    self.chatMessages.append(ChatMessage(text: "API Error: \(message)", isUser: false))
                }
            }

        } catch {
            await MainActor.run {
                self.chatMessages.append(ChatMessage(text: "Network error.", isUser: false))
            }
        }
    }

}
