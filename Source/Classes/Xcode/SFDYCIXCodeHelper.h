//
// SFDYCIXCodeHelper
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/24/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "CDRSXcodeInterfaces.h"
#import "CDRSXcodeDevToolsInterfaces.h"

@class DYCI_CCPXCodeConsole;

/*
This is the helper that should know about xcode project.
No other parts of this project should know about Xcode project structure, about active targers whatever
 */
@interface SFDYCIXCodeHelper : NSObject

+ (SFDYCIXCodeHelper *)instance;

/*
 Current editor context
 当前编辑器上下文环境
 */
- (XC(IDEEditorContext))activeEditorContext;

/*
 Currently active opened file
 当前正在打开编辑的文件
 */
- (NSURL *)activeDocumentFileURL;

/*
 Returns target for specified fileURL
 指定文件路径的target
 */
- (XC(PBXTarget))targetInOpenedProjectForFileURL:(NSURL *)fileURL;

/*
 Returns active workspace window controller, if any
 返回当前工作空间控制器对象
 */
- (XC(IDEWorkspaceWindowController))workspaceWindowController;

/*
 Current editing document
 当前编辑的文档对象
 */
- (XC(IDEEditorDocument))currentDocument;


@end