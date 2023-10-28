//
//  SourceEditorExtension.swift
//  ZZFormatter
//
//  Created by Yem Zhou on 2023/10/22.
//

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    func extensionDidFinishLaunching() {
        print("加载插件ZZFormatter成功: \(Bundle.main.executablePath ?? "")")
    }
    
}
