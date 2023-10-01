//
//  FloatingItemsList.swift
//  Splitter
//
//  Created by Vincent C. on 9/3/23.
//

import SwiftUI

struct FloatingItemsList: View {
    @Binding var items: [Item]
    @Binding var state: FloatingBarState
    let currency: Currency
    
    var body: some View {
        HStack {
            Spacer(minLength: 0)
            HStack {
                if state == .minimized {
                    Spacer()
                }
                InnerBar(items: $items, state: $state, currency: currency)
            }
            .frame(maxWidth: 500)
        }
    }
}

private struct InnerBar: View {
    @Binding var items: [Item]
    @Binding var state: FloatingBarState
    let currency: Currency
    
    @State private var isPresentingListSheet = false
    
    private var shouldShowRedIndicator: Bool {
        switch state {
        case .minimized:
            items.isEmpty
        case .focused(_):
            false
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if case .focused(let item) = state {
                FloatingFocusedBar(
                    item: item,
                    items: $items,
                    state: $state,
                    currency: currency
                )
            } else {
                Button {
                    isPresentingListSheet.toggle()
                } label: {
                    HStack {
                        Text("**\(items.count)** items")
                        Image(systemName: "list.bullet")
                    }
                    .foregroundColor(Color(.label))
                    .font(.title3)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .stroke(shouldShowRedIndicator ? Color.red : .primary.opacity(0.1))
        )
        .sheet(isPresented: $isPresentingListSheet) {
            FloatingExpandedList(
                items: $items,
                state: $state,
                currency: currency,
                shouldShowRedTitle: shouldShowRedIndicator,
                isPresented: $isPresentingListSheet
            )
            .presentationDetents([.fraction(0.75)])
            .presentationBackground(.thinMaterial)
        }
    }
}

private struct FoldButton: View {
    @Binding var isPresentingListSheet: Bool
    
    var body: some View {
        Button {
            isPresentingListSheet.toggle()
        } label: {
            Image(systemName: "list.bullet")
                .font(.body)
        }
    }
}

#Preview {
    StageSwitcherView(flowState: .sampleData)
}
