//
//  CalendarPopUp.swift
//  Group5
//
//  Created by Eden Fernando on 8/5/2026.
//

import Foundation
import SwiftUI

struct DayDetailPopup: View {
    let date: Date
    let expenses: [ExpenseItem] 
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
           
            Text(date.formatted(.dateTime.day().month().year()))
                .font(.title2.bold())
                .padding(.bottom, 10)
            
           
            ScrollView {
                if expenses.isEmpty {
                    VStack(spacing: 10) {
            
                        Text("No expenses recorded for this day.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                } else {
                    VStack(spacing: 25) {
                        ForEach(expenses) { item in
                            expenseRow(item)
                        }
                    }
                }
            }
            
            
            HStack {
                Spacer()
                Button(action: { withAnimation { isPresented = false } }) {
                    HStack {
                        Text("Close").bold()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.black)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 25)
                    .background(Color(red: 255/255, green: 185/255, blue: 135/255))
                    .clipShape(Capsule())
                }
            }
        }
        .padding(30)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(radius: 20)
    }
    
    func expenseRow(_ item: ExpenseItem) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: item.category.icon)
                .foregroundColor(.orange)
                .frame(width: 45, height: 45)
                .background(Color.orange.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.category.rawValue).bold()
                
                if let note = item.note, !note.isEmpty {
                    Text("Notes: \(note)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            
            Text("$\(item.spending, specifier: "%.2f")")
                .bold()
        }
    }
}
