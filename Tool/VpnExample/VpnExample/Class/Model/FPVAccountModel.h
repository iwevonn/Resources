//
//  FPVAccountModel.h
//  Free PPTP VPN
//
//  Created by iwevon on 16/5/12.
//  Copyright © 2016年 iwevon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPVAccountModel : NSObject

@property (copy, nonatomic)  NSString *ipStr;
@property (copy, nonatomic)  NSString *accountStr;
@property (copy, nonatomic)  NSString *passwordStr;

+ (FPVAccountModel *)accountModelWithIpStr:(NSString *)ipStr
                                accountStr:(NSString *)accountStr
                               passwordStr:(NSString *)passwordStr;

@end
