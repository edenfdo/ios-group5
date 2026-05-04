//
//  HomeView.swift
//  Group5
//
//  Created by chuyue zhang on 2/5/2026.
//

import SwiftUI

//Home Page
struct HomeView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    
    var body: some View {
        VStack {
            Text("Today's Total")
            Text("$\(viewModel.todayTotal, specifier: "%.2f")")
                .font(.largeTitle)
        }
    }
}

#Preview {
    HomeView(viewModel: ExpenseViewModel())
}
