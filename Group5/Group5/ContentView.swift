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
    
    var body: some View {
        
        Text("$\(viewModel.todayTotal, specifier: "%.2f")")
        
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.backgroundColour)
                .ignoresSafeArea()
            VStack {
                switch selectedTab {
                case .home:
                    ContentView(viewModel: viewModel)
                case .addExpense:
                    AddExpenseView(viewModel: viewModel)
                case .budget:
                    BudgetView()
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
