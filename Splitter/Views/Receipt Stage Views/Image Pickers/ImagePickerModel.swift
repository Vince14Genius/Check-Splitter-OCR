//
//  ImagePickerModel.swift
//  Splitter
//
//  Created by Vincent C. on 8/30/23.
//

import Foundation
import UIKit

enum ImagePickerItem: Equatable {
    case empty
    case loading(Progress)
    case success(image: UIImage)
    case failure(Error)
    
    var hasDisplayImage: Bool {
        switch self {
        case .success(_):
            true
        default: 
            false
        }
    }
    
    static func == (lhs: ImagePickerItem, rhs: ImagePickerItem) -> Bool {
        switch lhs {
        case .empty:
            switch rhs {
            case .empty: true
            default: false
            }
        case .loading(_):
            switch rhs {
            case .loading(_): true
            default: false
            }
        case .success(let lhsImage):
            switch rhs {
            case .success(let rhsImage): lhsImage == rhsImage
            default: false
            }
        case .failure(_):
            switch rhs {
            case .failure(_): true
            default: false
            }
        }
    }
}
