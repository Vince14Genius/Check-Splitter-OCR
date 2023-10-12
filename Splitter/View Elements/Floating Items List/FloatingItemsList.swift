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
    let shouldReturnToItemListSheet: Bool
    
    var body: some View {
        HStack {
            Spacer(minLength: 0)
            HStack {
                if state == .minimized {
                    Spacer()
                }
                InnerBar(items: $items, state: $state, currency: currency, shouldReturnToItemListSheet: shouldReturnToItemListSheet)
            }
            .frame(maxWidth: 500)
        }
    }
}

private struct InnerBar: View {
    @Binding var items: [Item]
    @Binding var state: FloatingBarState
    let currency: Currency
    let shouldReturnToItemListSheet: Bool
    
    @State private var isPresentingListSheet = false
    
    @State private var scale = 1.0
    
    private var shouldShowRedIndicator: Bool {
        switch state {
        case .minimized:
            items.isEmpty
        case .focused(_):
            false
        }
    }
    
    private func presentListSheetIfNeeded() {
        if shouldReturnToItemListSheet {
            isPresentingListSheet = true
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if case .focused(let item) = state {
                FloatingFocusedBar(
                    item: item,
                    items: $items,
                    state: $state,
                    currency: currency,
                    presentListSheetIfNeeded: presentListSheetIfNeeded
                )
            } else {
                Button {
                    isPresentingListSheet.toggle()
                } label: {
                    HStack {
                        Text("**\(items.count)** items")
                            .scaleEffect(scale)
                            .animation(.easeInOut, value: scale)
                        Image(systemName: "list.bullet")
                    }
                    .foregroundStyle(Color(.label))
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
            ItemsListSheet(
                items: $items,
                state: $state,
                currency: currency,
                shouldShowRedTitle: shouldShowRedIndicator,
                isPresented: $isPresentingListSheet
            )
            .presentationDetents([.fraction(0.75)])
            .presentationBackground(.thinMaterial)
        }
        .onChange(of: items.count) { oldCount, newCount in
            if newCount > oldCount {
                // item appended, play animation
                scale = 1.2
                _ = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                    scale = 1.0
                }
            }
        }
    }
}

#Preview {
    StageSwitcherView(flowState: .sampleData)
}
