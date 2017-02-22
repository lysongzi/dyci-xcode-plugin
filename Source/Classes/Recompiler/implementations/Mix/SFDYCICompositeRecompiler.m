//
// Created by Paul Taykalo on 11/1/14.
//

#import "SFDYCICompositeRecompiler.h"
#import "SFDYCIErrorFactory.h"
#import "DYCI_CCPXCodeConsole.h"


@implementation SFDYCICompositeRecompiler

- (instancetype)initWithCompilers:(NSArray *)compilers {
    self = [super init];
    if (self) {
        _compilers = compilers;
    }
    return self;
}

- (void)recompileFileAtURL:(NSURL *)fileURL completion:(void (^)(NSError *error))completionBlock {
    [self recompileFileAtURL:fileURL completion:completionBlock recompilers:self.compilers];
}


- (void)recompileFileAtURL:(NSURL *)fileURL completion:(void (^)(NSError *error))completionBlock recompilers:(NSArray *)recompilers {
    DYCI_CCPXCodeConsole *console = [DYCI_CCPXCodeConsole consoleForKeyWindow];
    NSMutableArray *availableRecompilers = [recompilers mutableCopy];
    for (id<SFDYCIRecompilerProtocol> recompiler in recompilers) {
        [availableRecompilers removeObject:recompiler];
        if ([recompiler canRecompileFileAtURL:fileURL]) {
            [recompiler recompileFileAtURL:fileURL completion:^(NSError *error) {
                // Fallback
                if (error) {
                    [console log:[NSString stringWithFormat:@"%@ failed to recompile file. Trying other available recompilers %@", recompiler, availableRecompilers]];
                    // 专门编译oc文件的不成功，在使用通用编译对象再编一次哈哈哈哈哈
                    [self recompileFileAtURL:fileURL completion:completionBlock recompilers:availableRecompilers];
                } else {
                    if (completionBlock) {
                        completionBlock(error);
                    }
                }
            }];
            return;
        }
    }

    if (completionBlock) {
        completionBlock([SFDYCIErrorFactory noRecompilerFoundErrorForFileURL:fileURL]);
    }
}


- (BOOL)canRecompileFileAtURL:(NSURL *)fileURL {
    // 你这么循环的判断，不就是说上面那个if判断几乎就是必进的了。。。
    for (id<SFDYCIRecompilerProtocol> recompiler in self.compilers) {
        if ([recompiler canRecompileFileAtURL:fileURL]) {
            return YES;
        }
    }
    return NO;
}


@end