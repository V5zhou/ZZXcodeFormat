//
//  SourceEditorCommand.swift
//  ZZFormatter
//
//  Created by Yem Zhou on 2023/10/22.
//

import Foundation
import UniformTypeIdentifiers
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        // 提取
        guard let tail = invocation.commandIdentifier.components(separatedBy: ".").last, let id = ZZXcodeFormatID(rawValue: tail) else {
            completionHandler(nil)
            return
        }
        
        let buffer = invocation.buffer
        let parserType = buffer.parserType // 解析器类型
        let sections = id == .text ? buffer.selections as? [XCSourceTextRange] : nil // 被选中的文本
        
        var running = true
        format(parserType: parserType, sourceText: buffer.completeBuffer, selections: sections) { result in
            switch result {
            case .succeed(let text):
                buffer.lines.removeAllObjects()
                buffer.completeBuffer = text
                print("格式化完成")
            case .error(let desc):
                print("格式化失败：\(desc)")
            }
            completionHandler(nil)
            running = false
        }
        
        // 10s还未执行完，则停止
        DispatchQueue.global().asyncAfter(deadline: .now() + 10, execute: DispatchWorkItem(block: {
            if running {
                completionHandler(nil)
                running = false
            }
        }))
    }
}

extension SourceEditorCommand {
    private func format(parserType: ZZXcodeFormatType, sourceText: String, selections: [XCSourceTextRange]?, completed: (ZZXcodeFormatResult) -> Void) {
        switch parserType {
        case .none:
            completed(.error("未识别的文件类型"))
        case .swift:
            self.formatTask(info: self.swiftTaskInfo(selections: selections), sourceText: sourceText, completed: completed)
        case .oc:
            self.formatTask(info: self.ocTaskInfo(selections: selections), sourceText: sourceText, completed: completed)
        }
    }
    
    private func formatTask(info: ZZXcodeFormatTaskInfo, sourceText: String, completed: (ZZXcodeFormatResult) -> Void) {
        if let message = info.errorMessage {
            completed(.error(message))
            return
        }
        guard let excuteUrl = info.excuteURL else {
            completed(.error("参数异常"))
            return
        }
        
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        let task = Process()
        task.standardInput = inputPipe
        task.standardOutput = outputPipe
        task.executableURL = excuteUrl
        if let args = info.args {
            task.arguments = args
        }
        
        do {
            try task.run()
        } catch {
            completed(.error(error.localizedDescription))
            return
        }
        
        // 向命令的标准输入写入输入文本
        guard let inputData = sourceText.data(using: .utf8) else {
            completed(.error("输入文件非utf8"))
            return
        }
        inputPipe.fileHandleForWriting.write(inputData)
        inputPipe.fileHandleForWriting.closeFile()
        
        // 读取命令的标准输出
        guard let data = try? outputPipe.fileHandleForReading.readToEnd(),
              let formattedString = String(data: data, encoding: .utf8),
              !formattedString.isEmpty
        else {
            try? outputPipe.fileHandleForReading.close()
            completed(.error("导出空文件"))
            return
        }
        guard formattedString != sourceText else {
            completed(.error("无变化"))
            return
        }
        try? outputPipe.fileHandleForReading.close()
        completed(.succeed(formattedString))
    }
    
    private func ocTaskInfo(selections: [XCSourceTextRange]?) -> ZZXcodeFormatTaskInfo {
        guard let url = Bundle.main.url(forResource: "clang-format", withExtension: nil) else {
            return ("找不到clang-format", nil, nil)
        }
        guard let style = Bundle.main.path(forResource: ".clang-format", ofType: nil) else {
            return ("找不到.clang-format", nil, nil)
        }
        
        var arguments = ["-style=file:\(style)"]
        if let selections {
            for r in selections {
                arguments.append("-linerange=\(r.start.line):\(r.end.line)")
            }
        }
        return (nil, url, arguments)
    }
    
    private func swiftTaskInfo(selections: [XCSourceTextRange]?) -> ZZXcodeFormatTaskInfo {
        guard let url = Bundle.main.url(forResource: "swiftformat", withExtension: nil) else {
            return ("找不到swiftFormat", nil, nil)
        }
        guard let style = Bundle.main.path(forResource: ".swiftformat", ofType: nil) else {
            return ("找不到.swiftFormat", nil, nil)
        }
        
        var arguments = ["-config", style]
        if let selections {
            for r in selections {
                arguments.append("-linerange")
                arguments.append("\(r.start.line + 1),\(r.end.line + 1)")
            }
        }
        return (nil, url, arguments)
    }
}

// MARK: - 文件类型

extension XCSourceTextBuffer {
    /// 已知UTIS
    enum ZZCodeFormatUTIs {
        static let ocSet: Set<UTType> = [.objectiveCSource, .objectiveCPlusPlusSource, .cHeader, .cSource, .cPlusPlusSource]
        static let swiftSet: Set<UTType> = [.swiftSource]
    }
    
    /// 根据UTI判断格式化策略
    var parserType: ZZXcodeFormatType {
        if let cur = UTType(contentUTI) {
            if ZZCodeFormatUTIs.ocSet.contains(cur) {
                return .oc
            }
            if ZZCodeFormatUTIs.swiftSet.contains(cur) {
                return .swift
            }
        }
        return .none
    }
}
