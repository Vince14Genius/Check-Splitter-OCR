//
//  Centered.swift
//  OCRTestApp
//
//  Created by Vincent C. on 9/19/23.
//

import SwiftUI

struct Centered<T: View>: View {
    var innerView: () -> T
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                innerView()
                Spacer()
            }
            Spacer()
        }
    }
}

#Preview {
    Centered {
        Text("Hello, World!")
    }
}
