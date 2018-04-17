//
//  MUEPaymentManager.m
//  Pods
//
//  Created by Jekity on 2017/8/25.
//
//

#import "MUEPaymentManager.h"
#import "MULoadingModel.h"
#import "MUHookMethodHelper.h"
#import "MUEAliPayModel.h"
#import "MUEWeChatPayModel.h"
#import <objc/runtime.h>
#import "MUSharedObject.h"

static MULoadingModel *model;
void initializationLoading(){//initalization loading model
    
    if (model == nil) {
        unsigned int outCount;
        Class *classes = objc_copyClassList(&outCount);
        for (int i = 0; i < outCount; i++) {
            if (class_getSuperclass(classes[i]) == [MULoadingModel class]){
                Class object = classes[i];
                model = (MULoadingModel *)[[object alloc]init];
                break;
            }
        }
        free(classes); // 12
    }
}

@implementation MUEPaymentManager
+(void)load{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        initializationLoading();
        if (model == nil) {
            NSLog(@"you can't use 'MUEPayment' because you haven't a subclass of 'MULoadingModel' or you don't init a subclass of 'MULoadingModel'");
            return ;
        }
        //Alipay
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [[[MUSharedObject alloc]init]registerApiKeysWithWeChatKey:model.weChatPayID QQKey:model.QQID weibokey:model.weiboID];
        //    [MUHookMethodHelper muHookMethod:model.AppDelegateName orignalSEL:@selector(application:didFinishLaunchingWithOptions:) defalutSEL:@selector(defaultApplication:didFinishLaunchingWithOptions:) newClassName:NSStringFromClass([MUEAliPayModel class]) newSEL:@selector(muHookedApplication:didFinishLaunchingWithOptions:)];
        [MUHookMethodHelper muHookMethod:model.AppDelegateName orignalSEL:@selector(application:openURL:sourceApplication:annotation:) defalutSEL:@selector(muDefalutEAlipayApplication:openURL:sourceApplication:annotation:) newClassName:NSStringFromClass([MUEAliPayModel class]) newSEL:@selector(muEAlipayApplication:openURL:sourceApplication:annotation:)];
        [MUHookMethodHelper muHookMethod:model.AppDelegateName orignalSEL:@selector(application:openURL:options:) defalutSEL:@selector(muDefalutEAlipayApplication:openURL:options:) newClassName:NSStringFromClass([MUEAliPayModel class]) newSEL:@selector(muEAlipayApplication:openURL:options:)];
        
        //weChat
        [MUHookMethodHelper muHookMethod:model.AppDelegateName orignalSEL:@selector(application:openURL:sourceApplication:annotation:) defalutSEL:@selector(muDefalutEWeChatPayApplication:openURL:sourceApplication:annotation:) newClassName:NSStringFromClass([MUEWeChatPayModel class]) newSEL:@selector(muEWeChatPayApplication:openURL:sourceApplication:annotation:)];
        //    [MUHookMethodHelper muHookMethod:model.AppDelegateName orignalSEL:@selector(application:openURL:options:) defalutSEL:@selector(muDefalutEWeChatPayApplication:openURL:options:) newClassName:NSStringFromClass([MUEWeChatPayModel class]) newSEL:@selector(muEWeChatPayApplication:openURL:options:)];
        
        [MUHookMethodHelper muHookMethod:model.AppDelegateName orignalSEL:@selector(application:handleOpenURL:) defalutSEL:@selector(muDefalutEWeChatPayapplication: handleOpenURL:) newClassName:NSStringFromClass([MUEWeChatPayModel class]) newSEL:@selector(muEWeChatPayapplication:handleOpenURL:)];
#pragma clang diagnostic pop
        
        
    });
    
}
#pragma mark -AliPay
+(void)muEPaymentManagerWithAliPay:(NSString *)privateKey result:(void(^)(NSDictionary *))result{
    [[[MUEAliPayModel alloc]init] performAliPayment:privateKey appScheme:model.alipayScheme result:result];
}

#pragma mark -WeChat
+(void)muEPaymentManagerWithWeChatPay:(void (^)(PayReq *))req result:(void (^)(PayResp *))result{
    [[[MUEWeChatPayModel alloc]init] performWeChatPayment:req result:result];
}
-(BOOL)muHookedApplication:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)dictionary
{
    
    NSLog(@"muHooked didFinishLaunchingWithOptions-------%@",model.alipayScheme);
    [WXApi registerApp:model.weChatPayID];
//    [WXApi registerApp:model.weChatPayID withDescription:model.weChatPayScheme];
    [self muHookedApplication:application didFinishLaunchingWithOptions:dictionary];
    return YES;
}
- (BOOL)defaultApplication:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)dictionary{
    
    return YES;
}

@end