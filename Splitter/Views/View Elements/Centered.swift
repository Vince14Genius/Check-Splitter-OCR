//
//  Centered.swift
//  Splitter
//
//  Created by Vincent C. on 9/19/23.
//

import SwiftUI

struct Axis: OptionSet {
    let rawValue: Int
    
    static let horizontal = Axis(rawValue: 1 << 0)
    static let vertical = Axis(rawValue: 1 << 1)
    
    static let all: Axis = [.horizontal, .vertical]
}

struct Centered<T: View>: View {
    var axes: Axis = .all
    var innerView: () -> T
    
    var body: some View {
        switch axes {
        case .horizontal:
            HStack {
                Spacer()
                innerView()
                Spacer()
            }
        case .vertical:
            VStack {
                Spacer()
                innerView()
                Spacer()
            }
        case .all:
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    innerView()
                    Spacer()
                }
                Spacer()
            }
        default:
            fatalError("Unsupported axes")
        }
    }
}

#Preview {
    Centered {
        Text("Hello, World!")
    }
}
