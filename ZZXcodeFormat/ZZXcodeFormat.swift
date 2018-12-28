//
//  ZZXcodeFormat.swift
//  ZZXcodeFormat
//
//  Created by zmz on 2018/12/27.
//  Copyright © 2018年 zmz. All rights reserved.
//

import Cocoa

class ZZXcodeFormat: NSObject {
    @objc static let share = ZZXcodeFormat()
    @objc var bundle: Bundle?

    // 一旦项目中出现一个.m文件，就不会走swift的这个方法？？？？？？有知道原因的可以告诉我
//    @objc class func pluginDidLoad(_ bundle: Bundle) {
//        //注册通知，当app加载完成时，再加载此插件
//        NotificationCenter.default.addObserver(share, selector: #selector(didFinishLaunch), name: NSApplication.didFinishLaunchingNotification, object: nil)
//    }
    @objc func didFinishLaunch() {
        addOperations()
        NotificationCenter.default.removeObserver(ZZXcodeFormat.share, name: NSApplication.didFinishLaunchingNotification, object: nil)
    }
}

// MARK: 添加操作按钮

extension ZZXcodeFormat {
    private func addOperations() {
        // Edite栏
        guard let editeMenu = NSApp.mainMenu?.item(withTitle: "Edit") else {
            return
        }

        // 添加分隔线与ZZXcodeFormat按钮
        editeMenu.submenu?.addItem(NSMenuItem.separator())
        let formatMenu = NSMenuItem(title: "ZZXcodeFormat", action: nil, keyEquivalent: "")
        editeMenu.submenu?.addItem(formatMenu)

        // 子级按钮
        let childMenus = NSMenu()
        formatMenu.submenu = childMenus
        let items = [("选择format类型☟", "", ""),
                     ("FocusFile", "formatFocusFile", "i"),
                     ("SelectFiles", "formatSelectFiles", "o"),
                     ("SelectText", "formatSelectText", "p")]
        for (index, (title, action, key)) in items.enumerated() {
            let actionItem = NSMenuItem(title: title, action: NSSelectorFromString(action), keyEquivalent: key)
            actionItem.keyEquivalentModifierMask = NSEvent.ModifierFlags(rawValue: NSEvent.ModifierFlags.control.rawValue | NSEvent.ModifierFlags.command.rawValue |
                NSEvent.ModifierFlags.option.rawValue)
            actionItem.target = self
            childMenus.addItem(actionItem)
            if index == 0 {
                childMenus.addItem(NSMenuItem.separator())
            }
        }
    }
}

// MARK: 三大格式化方法

extension ZZXcodeFormat {
    @objc private func formatFocusFile() {
        let document = ZZXcodeFormatHelper.editorContext()?.greatestDocumentAncestor.document
        document?.format(range: nil)
    }

    @objc private func formatSelectFiles() {
        ZZXcodeFormatHelper.selectedFiles()?.forEach({ fileNavigableItem in
            let document = IDEDocumentController.retainedEditorDocument(forNavigableItem: fileNavigableItem, forUseWithWorkspaceDocument: nil, error: nil)
            (document as? IDEEditorDocument)?.format(range: nil)
            IDEDocumentController.releaseEditorDocument(document)
        })
    }

    @objc private func formatSelectText() {
        let document = ZZXcodeFormatHelper.editorContext()?.greatestDocumentAncestor.document
        guard let ranges = document?.sdefSupport_selectedCharacterRange(), ranges.count == 2 else {
            print("无选中区域")
            return
        }
        let range = NSRange(location: Int(truncating: ranges[0]) - 1, length: Int(truncating: ranges[1]) - Int(truncating: ranges[0]) + 1)
        document?.format(range: range)
    }
}
