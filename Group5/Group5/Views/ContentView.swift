//
//  ContentView.swift
//  Group5
//
//  Created by Eden Fernando on 21/4/2026.
//

import SwiftUI

enum AppTab {
    case home
    case addExpense
    case budget
    case analytics
}

struct ContentView: View {
//    @StateObject private var addExpenseView =
    @State private var selectedTab: AppTab = .home
    @StateObject var viewModel = ExpenseViewModel()
    @StateObject var budgetViewModel = BudgetViewModel()
    
    var body: some View {        
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.backgroundColour)
                .ignoresSafeArea()
            VStack {
                switch selectedTab {
                case .home:
                    HomeView(viewModel: viewModel)
                case .addExpense:
                    AddExpenseView(viewModel: viewModel)
                case .budget:
                    BudgetView(viewModel: budgetViewModel, expenseViewModel: viewModel)
                case .analytics:
                    AnalyticsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            TabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
