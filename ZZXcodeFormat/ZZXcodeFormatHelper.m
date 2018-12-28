//
//  ZZXcodeFormatHelper.m
//  ZZXcodeFormat
//
//  Created by zmz on 2018/12/28.
//  Copyright © 2018年 zmz. All rights reserved.
//

#import "ZZXcodeFormatHelper.h"
#import "ZZXcodeFormat-Swift.h"

@implementation ZZXcodeFormatHelper

+ (void)pluginDidLoad:(NSBundle *)bundle {
    [ZZXcodeFormat share].bundle = bundle;
    //注册通知，当app加载完成时，再加载此插件
    [[NSNotificationCenter defaultCenter] addObserver:[ZZXcodeFormat share]
                                             selector:@selector(didFinishLaunch)
                                                 name:NSApplicationDidFinishLaunchingNotification
                                               object:nil];
}

#pragma mark - 公共方法

+ (NSWindowController *)windowController {
    return [[NSApp keyWindow] windowController];
}

+ (IDEEditorContext *)editorContext {
    NSWindowController *window = [self windowController];
    if (![window isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        NSLog(@"当前非IDEWorkspaceWindowController");
        return nil;
    }

    IDEEditorArea *editorArea       = [(IDEWorkspaceWindowController *)window editorArea];
    IDEEditorContext *editorContext = [editorArea lastActiveEditorContext];
    return editorContext;
}

/**
 获取选中文件
 */
+ (NSArray *)selectedFiles {
    NSWindowController *window = [self windowController];
    if (![window isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) return nil;

    //左上代码区域
    IDEWorkspaceTabController *workspaceTabController =
        [(IDEWorkspaceWindowController *)window activeWorkspaceTabController];
    IDENavigatorArea *navigatorArea         = [workspaceTabController navigatorArea];
    IDEStructureNavigator *currentNavigator = [navigatorArea currentNavigator];

    //取出放入数组
    NSMutableArray *selectFiles = [NSMutableArray array];
    [[currentNavigator selectedObjects] enumerateObjectsUsingBlock:^(
                                            IDEFileNavigableItem *fileNavigableItem, NSUInteger idx,
                                            BOOL *_Nonnull stop) {
        if (![fileNavigableItem isKindOfClass:NSClassFromString(@"IDEFileNavigableItem")]) return;

        NSString *uti = fileNavigableItem.documentType.identifier;
        if ([[NSWorkspace sharedWorkspace] type:uti conformsToType:(NSString *)kUTTypeSourceCode]) {
            [selectFiles addObject:fileNavigableItem];
        }
    }];
    return [selectFiles copy];
}

//获取选中行range,选中整行字符range
+ (BOOL)getsLineRange:(NSRange *)lineRange
       characterRange:(NSRange *)characterRange
           inDocument:(IDEEditorDocument *)document
          selectRange:(NSRange)selectRange {
    NSRange LR      = [document lineRangeForCharacterRange:selectRange];
    NSRange CR      = [document characterRangeForLineRange:LR];
    *lineRange      = LR;
    *characterRange = CR;
    return YES;
}

@end
