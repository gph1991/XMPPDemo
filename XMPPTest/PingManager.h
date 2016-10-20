//
//  PingManager.h
//  XMPPTest
//
//  Created by Apple on 16/10/14.
//  Copyright © 2016年 waiguo. All rights reserved.
//

enum
{
    SocketOfflineByServer,// 服务器掉线，默认为0
    SocketOfflineByUser,  // 用户主动cut
};

#import "AsyncSocket.h"
#import "AsyncUdpSocket.h"
#import <Foundation/Foundation.h>

@interface PingManager : NSObject<XMPPStreamDelegate,XMPPRosterDelegate>

@property (nonatomic, strong) AsyncSocket    *socket;       // socket
@property (nonatomic, copy  ) NSString       *socketHost;   // socket的Host
@property (nonatomic, assign) UInt16         socketPort;    // socket的prot
@property (nonatomic, retain) NSTimer        *connectTimer; // 计时器

+(PingManager*)sharedInstance;
- (void)socketConnectHost;// socket连接
- (void)cutOffSocket; // 断开socket连接
@end
