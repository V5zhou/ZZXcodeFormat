//
//  ZZFormatterConstant.swift
//  ZZFormatter
//
//  Created by Yem Zhou on 2023/10/22.
//

import Foundation

enum ZZXcodeFormatID: String {
    case text = "formatSelectedText"
    case file = "formatSelectedFile"
}

enum ZZXcodeFormatType {
    case none
    case oc
    case swift
}

enum ZZXcodeFormatResult {
    case succeed(String)
    case error(String)
}

typealias ZZXcodeFormatTaskInfo = (errorMessage: String?, excuteURL: URL?, args: [String]?)
