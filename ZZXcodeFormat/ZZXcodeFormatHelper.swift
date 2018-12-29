//
//  ZZXcodeFormatHelper.swift
//  ZZXcodeFormat
//
//  Created by zmz on 2018/12/29.
//  Copyright © 2018年 zmz. All rights reserved.
//

import Cocoa

class ZZXcodeFormatHelper: NSObject {
    
    class func windowController() -> IDEWorkspaceWindowController? {
        return NSApp.keyWindow?.windowController as? IDEWorkspaceWindowController
    }
    
    public class func editorContext() -> IDEEditorContext? {
        guard let window = windowController() else {
            return nil
        }
        let editorArea = window.editorArea()
        let editorContext = editorArea?.lastActiveEditorContext()
        return editorContext
    }
    
    class func selectedFiles() -> [IDEFileNavigableItem]? {
        guard let window = windowController() else {
            return nil
        }
        //左上代码区域
        let tab = window.activeWorkspaceTabController
        let navigatorArea = tab?.navigatorArea
        guard let currentNavigator = navigatorArea?.currentNavigator() else {
            return nil
        }
        
        //取出放入数组
        var selectFiles:[IDEFileNavigableItem] = []
        for fileNavigableItem in currentNavigator.selectedObjects {
            guard let item = fileNavigableItem as? IDEFileNavigableItem else {
                continue
            }
            let uti = item.documentType.identifier
            if NSWorkspace.shared.type(uti!, conformsToType: kUTTypeSourceCode as String) {
                selectFiles.append(item)
            }
        }
        return selectFiles
    }
}
