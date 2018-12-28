//
//  ZZXcodeFormatHelper.h
//  ZZXcodeFormat
//
//  Created by zmz on 2018/12/28.
//  Copyright © 2018年 zmz. All rights reserved.
//

#import "ZZXcodePrivateAPI.h"

@interface ZZXcodeFormatHelper : NSObject

+ (IDEEditorContext *)editorContext;

/**
 获取选中文件
 */
+ (NSArray *)selectedFiles;

/*
 获取选中行range, 选中整行字符range
 */
+ (BOOL)getsLineRange:(NSRange *)lineRange
       characterRange:(NSRange *)characterRange
           inDocument:(IDEEditorDocument *)document
          selectRange:(NSRange)selectRange;

@end
