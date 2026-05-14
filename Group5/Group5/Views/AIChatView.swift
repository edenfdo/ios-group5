//  AIChatView.swift
//  Group5
//
//  Created by Eden Fernando on 14/5/2026.
//

import Foundation
import SwiftUI

struct AIChatView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var inputMessage: String = ""
    @State private var isWaitingForAI: Bool = false
    
    // 1. Controls dismissal of fullScreenCover
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Screen Header title block with Close Button
            HStack {
                Button(action: {
                    dismiss() // API command that closes the sheet popup instantly
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.down")
                        Text("Close")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
                }
                
                Spacer()
                
                Text("Financial Advisor AI")
                    .font(.headline)
                    .fontWeight(.bold)
                    // Visual offset to keep title centred relative to the screen width
                    .padding(.trailing, 45)
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
            }
            .padding()
            .background(Color.white)

            // Chat bubble stream
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        if viewModel.chatMessages.isEmpty {
                            Text("Ask me anything about your current expenses, spending categories, or budget health analysis calculations.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .padding(.top, 40)
                        }

                        ForEach(viewModel.chatMessages) { message in
                            chatBubble(msg: message)
                        }

                        if isWaitingForAI {
                            HStack {
                                ProgressView()
                                    .padding(.leading, 12)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.chatMessages) { _ in
                    if let lastMessage = viewModel.chatMessages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Text Input Footer toolbar dock
            HStack(spacing: 10) {
                TextField("Ask about your budget limits...", text: $inputMessage)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .disabled(isWaitingForAI)

                Button(action: sendMessageAction) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(inputMessage.isEmpty ? .gray : .purple)
                        .font(.system(size: 18))
                        .padding(12)
                        .background(inputMessage.isEmpty ? Color(.systemGray5) : Color.purple.opacity(0.15))
                        .clipShape(Circle())
                }
                .disabled(inputMessage.isEmpty || isWaitingForAI)
            }
            .padding()
            .background(Color.white)
        }
        .background(Color("BackgroundColour").ignoresSafeArea())
    }

    @ViewBuilder
    func chatBubble(msg: ChatMessage) -> some View {
        HStack {
            if msg.isUser { Spacer() }

            Text(.init(msg.text))
                .font(.subheadline)
                .padding(12)
                .background(msg.isUser ? Color.purple : Color(.systemGray5))
                .foregroundColor(msg.isUser ? .white : .black)
                // FIXED: Uses standard RoundedRectangle which supports iOS 13, 14, 15, 16, and 17+
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .frame(maxWidth: 280, alignment: msg.isUser ? .trailing : .leading)
                .id(msg.id)

            if !msg.isUser { Spacer() }
        }
    }


    func sendMessageAction() {
        let textToSend = inputMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textToSend.isEmpty else { return }

        let userMsg = ChatMessage(text: textToSend, isUser: true)
        viewModel.chatMessages.append(userMsg)
        inputMessage = ""
        isWaitingForAI = true

        Task {
            await viewModel.sendToGemini(userMessage: textToSend)
            await MainActor.run {
                isWaitingForAI = false
            }
        }
    }
}
