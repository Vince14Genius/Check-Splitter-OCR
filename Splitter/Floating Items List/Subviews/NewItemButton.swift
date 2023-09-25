//
//  NewItemButton.swift
//  Splitter
//
//  Created by Vincent C. on 9/23/23.
//

import SwiftUI

struct NewItemButton: View {
    @Binding var state: FloatingBarState
    
    var body: some View {
        Button {
            state = .focused(item: .init())
        } label: {
            HStack {
                Spacer()
                Image(systemName: "plus")
                Spacer()
            }
            .padding(.top, 10)
        }
    }
}

#Preview {
    NewItemButton(state: .constant(.focused(item: .init())))
}
