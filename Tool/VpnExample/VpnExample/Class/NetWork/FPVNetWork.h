//
//  FPVNetWork.h
//  Free PPTP VPN
//
//  Created by iwevon on 16/5/12.
//  Copyright © 2016年 iwevon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPVAccountModel.h"


typedef void(^FreeVpnInfoBlock)(NSString *htmlstring, NSString *filePath, FPVAccountModel *accountModel);

@interface FPVNetWork : NSObject

+ (void)getFreeVpnInfoBlock:(FreeVpnInfoBlock)block;

@end
