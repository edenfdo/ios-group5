//
//  TabBar.swift
//  Group5
//
//  Created by chuyue zhang on 2/5/2026.
//

import SwiftUI

//Bottom Tab Bar view
struct TabBar: View {
    @Binding var selectedTab: AppTab
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.gray.opacity(0.25))
                .frame(height: 1)
            
            HStack {
                tabButton(
                    tab: .home,
                    icon: "house.fill",
                    label: "Home"
                )
                
                Spacer()
                
                tabButton(
                    tab: .addExpense,
                    icon: "plus.circle.fill",
                    label: "Add Expense"
                )
                
                Spacer()
                
                tabButton(
                    tab: .budget,
                    icon: "dollarsign.circle.fill",
                    label: "Budget"
                )
                
                Spacer()
                
                tabButton(
                    tab: .analytics,
                    icon: "chart.xyaxis.line",
                    label: "Analytics"
                )
                
            }
            .padding(.horizontal, 28)
            .padding(.top, 8)
            .padding(.bottom, 20)
//                    .background(Color(.white))
        }
    }
    
    func tabButton(tab: AppTab, icon: String, label: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .scaleEffect(selectedTab == tab ? 1.20 : 1.0)
                Text(label)
                    .font(.system(size: 14))
                    .fontWeight(selectedTab == tab ? .bold : .regular)
                    
            }
            .foregroundStyle(selectedTab == tab ? .chart : .gray)
        }
    }

}

#Preview {
    TabBar(selectedTab: .constant(.home))
}
