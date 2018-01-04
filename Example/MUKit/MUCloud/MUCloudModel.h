//
//  MUCloudModel.h
//  MUKit_Example
//
//  Created by Jekity on 2018/1/4.
//  Copyright © 2018年 Jeykit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUCloudModel : NSObject

+(instancetype)initWithRetainObject:(NSObject *)object keyPath:(NSString *)keyPath;

/** 获取已实例化*/
+(instancetype)cloudModel;

/** 释放实例*/
+(void)releaseModel;



@property(nonatomic, copy)NSString *name;
@property(nonatomic, copy)NSString *sex;
@property(nonatomic, copy)NSString *age;
@end
