//
//  ZZXcodeFormatFragment.swift
//  ZZXcodeFormat
//
//  Created by zmz on 2018/12/28.
//  Copyright © 2018年 zmz. All rights reserved.
//

import Cocoa
import Foundation

// MARK: -------------- 为格式化准备数据 --------------

class ZZXcodeFormatFragment: NSObject {
    init(document: IDEEditorDocument, orginRange: NSRange) {
        self.document = document
        self.orginRange = orginRange
        super.init()
    }

    // MARK: 属性列表

    var document: IDEEditorDocument
    var orginRange: NSRange

    lazy var launchPath: String? = {
        switch formatType {
        case .none:
            return nil
        case .oc:
            return ZZXcodeFormat.share.bundle?.path(forResource: "clang-format", ofType: nil)
        case .swift:
            return ZZXcodeFormat.share.bundle?.path(forResource: "swiftformat", ofType: nil)
        }
    }()

    lazy var formatType: ZZFormatType = {
        document.checkFormat()
    }()

    lazy var args: [String] = {
        switch formatType {
        case .none:
            return []
        case .swift:
            // 目前我的配置太垃圾难看了，直接就默认的吧
            return [tempFileURL?.path ?? ""]
        case .oc:
            return ["-lines=\(markedLineRange.location + 1):\(markedLineRange.location + markedLineRange.length)",
                    "-style=file",
                    "-i",
                    tempFileURL?.path ?? ""]
        }
    }()

    lazy var markedLineRange: NSRange = {
        document.lineRange(forCharacterRange: orginRange)
    }()

    lazy var markedCharRange: NSRange = {
        document.characterRange(forLineRange: markedLineRange)
    }()

    lazy var markedText: String = {
        guard let contents = document.editedContents else {
            return ""
        }
        let start = contents.index(contents.startIndex, offsetBy: markedCharRange.location)
        let end = contents.index(start, offsetBy: markedCharRange.length)
        return String(contents[start ..< end])
    }()

    // 输出内容
    var tempFileURL: URL?
    var outText = ""
}

// MARK: -------------- 格式化结果 --------------

enum ZZXcodeFormatResult {
    case succeed
    case error(String)
}

// MARK: -------------- 格式化方法主体 --------------

extension ZZXcodeFormatFragment {
    /// 开始执行格式化
    public func startFormat(_ callback: ((ZZXcodeFormatResult) -> Void)?) {
        // 拿到tempFile，执行格式化
        prepareFormatTempFile { [unowned self] _ in
            runTask(args: self.args, { result in
                // 替换文本区域
                self.document.replaceText(withContentsOfURL: self.tempFileURL, error: nil)

                if callback != nil {
                    callback!(result)
                }
            })
        }
    }

    /// 创建与删除temp文件
    private func prepareFormatTempFile(_ formatBlock: (URL) -> Void) {
        guard let fileName = document.fileURL?.lastPathComponent else {
            return
        }
        // 如果不存在文件夹，则创建
        guard let tempDir = ZZXcodeFormat.share.bundle?.bundleURL.appendingPathComponent(".XcodeFormatTempDir") else {
            return
        }
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)

        // 创建临时文件，执行format，结束后删除
        tempFileURL = tempDir.appendingPathComponent(fileName)
//        try? markedText.write(to: tempFileURL!, atomically: true, encoding: .utf8)
        try? document.editedContents?.write(to: tempFileURL!, atomically: true, encoding: .utf8)
        formatBlock(tempFileURL!)
        try? FileManager.default.removeItem(at: tempFileURL!)
    }

    // MARK: task执行shell

    private func runTask(args: [String], _ finished: ((ZZXcodeFormatResult) -> Void)?) {
        let outPipe = Pipe()
        let errorPipe = Pipe()
        outPipe.fileHandleForReading.readInBackgroundAndNotify()

        let process = Process()
        process.standardOutput = outPipe
        process.standardError = errorPipe
        process.launchPath = launchPath
        process.arguments = args
        process.launch()
        process.waitUntilExit()

        // 读取格式化后文本
        outText = try! String(contentsOf: tempFileURL!, encoding: .utf8)
        // 读取错误信息
        let errorDesc = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
        if finished != nil {
            if errorDesc != nil, errorDesc!.count > 0 {
                finished!(.error(errorDesc!))
            } else {
                finished!(.succeed)
            }
        }
    }
}
