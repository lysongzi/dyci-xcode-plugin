//
// SFDYCIClangParams
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/27/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import <Foundation/Foundation.h>

/*
 一个对象保存了后续用于编译动态库所需要的参数信息
Object that represent parameters those will be used to perform compilation of .dylib
 */
@interface SFDYCIClangParams : NSObject

/*
 Object that is under compilation
 Object.mm
 Object.m
 */
@property(nonatomic, copy) NSString *compilationObjectName;

/*
Full Path to the object file
  ~/somePath/Object.o
 */
@property(nonatomic, copy) NSString *objectCompilationPath;
/*
 Architecture parameter
 -arch <value>
 */
@property(nonatomic, copy) NSString *arch;
/*
 sysroot parameter passed to clang
 -isysroot <value>
 */
@property(nonatomic, copy) NSString *isysroot;

@property(nonatomic, strong) NSArray *LParams;
@property(nonatomic, strong) NSArray *FParams;
@property(nonatomic, copy) NSString *minOSParams;

- (NSString *)description;

@end