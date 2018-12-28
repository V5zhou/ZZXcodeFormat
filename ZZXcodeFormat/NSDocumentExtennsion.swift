//
//  NSDocumentExtennsion.swift
//  ZZXcodeFormat
//
//  Created by zmz on 2018/12/27.
//  Copyright © 2018年 zmz. All rights reserved.
//

import Cocoa

// MARK: -------------- 格式化类型 --------------

enum ZZFormatType {
    case none
    case oc
    case swift
}

// MARK: -------------- 支持格式化的文件类型 --------------

extension NSDocument {
    /// 由文件类型，得到格式化类型
    func checkFormat() -> ZZFormatType {
        let tail = fileURL?.pathExtension.lowercased()
        let ocSet: Set = ["c", "h", "cpp", "cc", "cxx", "hh", "hpp", "hxx", "ipp", "m", "mm", "metal"]
        switch tail {
        case "swift":
            return .swift
        case let oc where ocSet.contains(oc!):
            return .oc
        default:
            return .none
        }
    }
}

// MARK: -------------- Format Document --------------

extension IDEEditorDocument {
    /// 开始格式化，如range未传，则格式化整个页面
    func format(range: NSRange?) {
        // 检查是否是支持的类型
        let type = checkFormat()
        guard type != .none else {
            return
        }
        // 创建Fragment
        let originRange = range ?? NSRange(location: 0, length: editedContents.count)
        let fragment = ZZXcodeFormatFragment(document: self, orginRange: originRange)
        fragment.startFormat { result in
            // 拿这个结果做什么呢？现在用不到
        }
    }
}
