//
// SFDYCIClangProxyRecompiler
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/24/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import <AppKit/AppKit.h>
#import "SFDYCIClangProxyRecompiler.h"
#import "DYCI_CCPXCodeConsole.h"


@interface SFDYCIClangProxyRecompiler ()
@property(nonatomic, strong) DYCI_CCPXCodeConsole *console;
@end

@implementation SFDYCIClangProxyRecompiler

- (instancetype)init {
    self = [super init];
    if (self) {
        self.console = [DYCI_CCPXCodeConsole consoleForKeyWindow];
    }

    return self;
}


- (void)recompileFileAtURL:(NSURL *)fileURL completion:(void (^)(NSError * error))completionBlock {
    NSTask * task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/python"]; //执行python代码

    // 这个算是cd命令的效果么
    [task setCurrentDirectoryPath:self.dyciRecompilerDirectoryPath];

    // 设置脚本的参数，第一个是脚本路径（其实就是执行这个脚本），并且传入参数为需要编译的文件url
    NSArray * arguments = @[self.dyciRecompilerPath, [fileURL path]];
    [task setArguments:arguments];

    // Setting up pipes for standart and error outputs
    // 创建管道获取命令执行的
    NSPipe * outputPipe = [NSPipe pipe];
    NSFileHandle * outputFile = [outputPipe fileHandleForReading];
    [task setStandardOutput:outputPipe];

    NSPipe * errorPipe = [NSPipe pipe];
    NSFileHandle * errorFile = [errorPipe fileHandleForReading];
    [task setStandardError:errorPipe];

    // Setting up termination handler
    // 脚本命令执行完毕的操作？
    [task setTerminationHandler:^(NSTask * tsk) {

        // 在console输出标准输出的结果
        NSData * outputData = [outputFile readDataToEndOfFile];
        NSString * outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        if (outputString && [outputString length]) {
            [self.console debug:[NSString stringWithFormat:@"script returned OK:\n%@", outputString]];
        }

        // 在console输出标准错误的输出结果
        NSData * errorData = [errorFile readDataToEndOfFile];
        NSString * errorString = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        if (errorString && [errorString length]) {
            [self.console debug:[NSString stringWithFormat:@"script returned ERROR:\n%@", errorString]];
        }

        // TODO : Need to add correct notification if something went wrong
        if (tsk.terminationStatus != 0) {
            NSError * injectionError =
              [NSError errorWithDomain:@"com.stanfy.dyci" code:-1 userInfo:@{ NSLocalizedDescriptionKey : (errorString ?: @"<Unknown error>") }];
            if (completionBlock) {
                completionBlock(injectionError);
            }

        } else {
            if (completionBlock) {
                completionBlock(nil);
            }
        }

        tsk.terminationHandler = nil;

    }];


    // Starting task 启动脚本任务
    [task launch];

}

- (NSString *)dyciRecompilerDirectoryPath {
    NSString * dyciDirectoryPath = [@"~" stringByExpandingTildeInPath];
    dyciDirectoryPath = [dyciDirectoryPath stringByAppendingPathComponent:@".dyci"];
    dyciDirectoryPath = [dyciDirectoryPath stringByAppendingPathComponent:@"scripts"];
    return dyciDirectoryPath;
}


- (NSString *)dyciRecompilerPath {
    // 这个文件在工程dyci-main里。。。这是为啥。。。
    return [self.dyciRecompilerDirectoryPath stringByAppendingPathComponent:@"dyci-recompile.py"];
}


#pragma mark - SFDYCIRecompilerProtocol

- (BOOL)canRecompileFileAtURL:(NSURL *)fileURL {
    return YES;
}

// 初始化的时候不是赋值了么。为啥要重写get方法。这玩意应该不会被干掉吧？？？
- (DYCI_CCPXCodeConsole *)console {
    if (!_console) {
        _console = [DYCI_CCPXCodeConsole consoleForKeyWindow];
    }
    return _console;
}


@end