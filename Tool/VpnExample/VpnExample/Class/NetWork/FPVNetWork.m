//
//  FPVNetWork.m
//  Free PPTP VPN
//
//  Created by iwevon on 16/5/12.
//  Copyright © 2016年 iwevon. All rights reserved.
//

#import "FPVNetWork.h"
#import "RegexKitLite.h"

static NSInteger recordIndex = 0;

@interface FPVNetWork ()

@property (copy, nonatomic) FreeVpnInfoBlock freeVpnInfoBlock;
@property (strong, nonatomic) NSArray *qaptchaArray;
@property (strong, nonatomic) NSArray *serviceArray;

@end


@implementation FPVNetWork

- (NSArray *)qaptchaArray {
    if (!_qaptchaArray) {
        _qaptchaArray =@[@"http://www.govpn.win/service/php/Qaptcha.jquery.php",
                         @"http://www.playvpn.top/freevpnusa/php/Qaptcha.jquery.php",
                         @"http://www.playvpn.top/freevpnchina/php/Qaptcha.jquery.php"];
    }
    return _qaptchaArray;
}

- (NSArray *)serviceArray {
    if (!_serviceArray) {
        _serviceArray =@[@"http://www.govpn.win/service/",
                         @"http://www.playvpn.top/freevpnusa/",
                         @"http://www.playvpn.top/freevpnchina/"];
    }
    return _serviceArray;
}

+ (void)getFreeVpnInfoBlock:(void(^)(NSString *htmlstring, NSString *filePath, FPVAccountModel *accountModel))block {
    
    FPVNetWork *netWork = [[self alloc] init];
    netWork.freeVpnInfoBlock = block;
    [netWork getAuthorization];
}


- (void)getAuthorization {
    
    NSURL *url = [NSURL URLWithString:self.qaptchaArray[recordIndex%3]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [@"action=qaptcha" dataUsingEncoding:NSUTF8StringEncoding];
    request.timeoutInterval = 30;
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self downloadFreeVpnFile];
    }];
    // 启动任务
    [task resume];
}

- (void)downloadFreeVpnFile {
    
    NSURL *url = [NSURL URLWithString:self.serviceArray[(recordIndex++)%3]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [@"iQapTcha=&submit=Get+VPN+info" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            
            // location是沙盒中tmp文件夹下的一个临时url,文件下载后会存到这个位置,由于tmp中的文件随时可library能被删除,所以我们需要自己需要把下载的文件挪到需要的地方
            NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
            
            // 删除文件
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            // 剪切文件
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:nil];
            
            NSString *htmlstring=[NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
            htmlstring = [htmlstring stringByReplacingOccurrencesOfString:@"\0" withString:@""];
            NSString *regexString = @"Ip: (\\S+)<br />Account: (\\S+)<br />Password: (\\S+)<br />";
            NSArray *matchArray = [htmlstring  componentsSeparatedByRegex:regexString];
            
            if (matchArray.count>=3) {
                
                NSString *ipStr = [matchArray objectAtIndex:1];
                NSString *accountStr = [matchArray objectAtIndex:2];
                NSString *passwordStr = [matchArray objectAtIndex:3];
                
                FPVAccountModel *accountModel = [FPVAccountModel accountModelWithIpStr:ipStr accountStr:accountStr passwordStr:passwordStr];
                
                //避免显示延时,需要切换到主线程刷新UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.freeVpnInfoBlock ? self.freeVpnInfoBlock(htmlstring, filePath, accountModel) : nil;
                });
                return;
            }
        }
        
        self.freeVpnInfoBlock(nil, nil, nil);
    }];
    // 启动任务
    [task resume];
}


@end
