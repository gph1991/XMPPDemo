//
//  ConnectManager.h
//  XMPPTest
//
//  Created by Apple on 16/10/12.
//  Copyright © 2016年 waiguo. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ContactViewController.h"
#import "SMChatDelegate.h"
#import "SMMessageDelegate.h"


@interface ConnectManager : NSObject
{
    __weak id<SMChatDelegate> _chatDelegate;
    __weak id<SMMessageDelegate> _messageDelegate;
    
    UIWindow *window;
}

@property(nonatomic,copy)NSString *password;
@property(nonatomic,copy)NSString *username;

- (BOOL)connect;
- (void)disconnect;
- (void)setupStream;
- (void)goOnline;
- (void)goOffline;

@end
