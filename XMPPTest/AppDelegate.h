//
//  AppDelegate.h
//  XMPPTest
//
//  Created by Apple on 16/10/12.
//  Copyright © 2016年 waiguo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactViewController.h"
#import "SMChatDelegate.h"
#import "SMAuthDelegate.h"
#import "SMMessageDelegate.h"
#import "XMPPFramework.h"
#import "XMPPAutoPing.h"
#import "XMPPRosterCoreDataStorage.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) UIWindow *window;

@property(nonatomic,strong) XMPPRoster *roster;
@property(nonatomic,strong) XMPPStream *stream;
@property(nonatomic,copy)NSString *password;
@property(nonatomic,copy)NSString *username;
@property(nonatomic,assign)id<SMChatDelegate> chatDelegate;
@property(nonatomic,assign)id<SMMessageDelegate> messageDelegate;
@property(nonatomic,assign)id<SMAuthDelegate> authDelegate;

- (BOOL)connect;
- (void)disconnect;
- (void)setupStream;
- (void)goOnline;
- (void)goOffline;
- (void)login;
- (void)reg;
- (void)addFriend:(NSString *)name;
@end

