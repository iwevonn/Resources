//
//  FPVAccountModel.m
//  Free PPTP VPN
//
//  Created by iwevon on 16/5/12.
//  Copyright © 2016年 iwevon. All rights reserved.
//

#import "FPVAccountModel.h"

@implementation FPVAccountModel


+ (FPVAccountModel *)accountModelWithIpStr:(NSString *)ipStr
                                accountStr:(NSString *)accountStr
                               passwordStr:(NSString *)passwordStr {
    
    FPVAccountModel *accountModel = [[self alloc] init];
    accountModel.ipStr = ipStr;
    accountModel.accountStr = accountStr;
    accountModel.passwordStr = passwordStr;
    return accountModel;
}
@end
