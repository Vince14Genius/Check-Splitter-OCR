//
//  FloatingBarState+Equatable.swift
//  Splitter
//
//  Created by Vincent C. on 9/3/23.
//

import Foundation

enum FloatingBarState {
    case minimized
    case focused(item: Item.Initiation)
}

extension FloatingBarState: Equatable {
    static func == (lhs: FloatingBarState, rhs: FloatingBarState) -> Bool {
        switch lhs {
        case .minimized:
            switch rhs {
            case .minimized: return true
            default: return false
            }
        case .focused(let itemA):
            switch rhs {
            case .focused(let itemB): return itemA == itemB
            default: return false
            }
        }
    }
}
