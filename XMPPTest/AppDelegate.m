//
//  AppDelegate.m
//  XMPPTest
//
//  Created by Apple on 16/10/12.
//  Copyright © 2016年 waiguo. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()<XMPPStreamDelegate,XMPPRosterDelegate,XMPPAutoPingDelegate>

{
    BOOL isOpen;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self autoPingProxyServer:@"http://www.baidu.com/"];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma -mark XMPP

- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence];
    [[self stream] sendElement:presence];
}

- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self stream] sendElement:presence];
    [[self stream] disconnect];
}

- (void)setupStream
{
    _stream = [[XMPPStream alloc] init];
    //设定服务器名称
    [_stream setHostName:HOST];
    [_stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

-(void)login
{
    if ([[self stream]isConnected])
    {
        [self goOffline];
    }
    
    if(_username.length > 0 && _password.length > 0)
    {
        //设置账号
        [_stream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", _username, HOST]]];
        _stream.tag = @"登录";
        [_stream connectWithTimeout:30 error:nil];
    }
}

-(void)reg
{
    if ([[self stream]isConnected])
    {
        [self goOffline];
    }
    
    if(_username.length > 0 && _password.length > 0)
    {
        //设置账号
        [_stream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", _username, HOST]]];
        _stream.tag = @"注册";
        [_stream connectWithTimeout:30 error:nil];
    }
}

- (BOOL)connect
{
    if ([[self stream]isConnected])
    {
        return YES;
    }
    
    //设置账号
    [_stream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", _username, HOST]]];
    _stream.tag = @"注册";
    //连接
    [_stream connectWithTimeout:30 error:nil];
    
    return YES;
}

- (void)disconnect
{
    [self goOffline];
    [[self stream] disconnect];
}

-(void)addFriend:(NSString *)name
{
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",name,HOST]];
    [[self roster] subscribePresenceToUser:jid];
}

-(XMPPStream *)stream
{
    if (!_stream)
    {
        _stream = [[XMPPStream alloc] init];
        //设定服务器名称
        [_stream setHostName:HOST];
        [_stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    return _stream;
}

-(XMPPRoster *)roster
{
    if (!_roster)
    {
        _roster = [[XMPPRoster alloc] initWithRosterStorage:[[XMPPRosterCoreDataStorage alloc] init]];
        [_roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_roster activate:self.stream];
    }
    
    return _roster;
}


- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"连接成功");
    //注册
    if ([sender.tag isEqualToString:@"注册"])
    {
        [_stream registerWithPassword:_password error:nil];
    }
    
    isOpen = YES;
    //登陆
    if ([sender.tag isEqualToString:@"登录"])
    {
        [[self stream] authenticateWithPassword:_password error:nil];
    }
}

//认证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    [self goOnline];
    [_authDelegate loginDidFinish:nil];
}

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    //取得好友状态
    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]]; //online/offline
    //请求的用户
    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
    NSLog(@"presenceType:%@",presenceType);
    NSLog(@"presence2:%@  sender2:%@",presence,sender);
    
    XMPPJID *jid = [XMPPJID jidWithString:presenceFromUser];
    //接收添加好友请求
    [[self roster] acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
}

//认证未通过
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    [_authDelegate loginDidFinish:@"密码错误"];
}

//注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"注册成功");
     [_authDelegate regDidFinish:nil];
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
    [_authDelegate regDidFinish:@"已存在"];
}

//连接超时
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    NSLog(@"连接超时");
}

//新消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    [m setObject:msg forKey:@"msg"];
    [m setObject:from forKey:@"sender"];
    
    [_messageDelegate newMessageReceived:m];
}


//好友状态
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSString *presenceType = [presence type]; // online/offline
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:myUsername])
    {
        if ([presenceType isEqualToString:@"available"])
        {
            [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, HOST]];
        }
        else if ([presenceType isEqualToString:@"unavailable"])
        {
            [_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, HOST]];
        }
    }
    
    //添加好友
    //    if ([presence.fromStr isEqualToString:HOST])
    //    {
    //        return;
    //    }
    //
    //    [_roster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:NO];
    //    NSLog(@"同意添加%@为好友", presence.fromStr);
    
    // a buddy went offline/online
}


//初始化并启动ping
-(void)autoPingProxyServer:(NSString*)strProxyServer
{
    XMPPAutoPing *_xmppAutoPing = [[XMPPAutoPing alloc] init];
    [_xmppAutoPing activate:[self stream]];
    [_xmppAutoPing addDelegate:self delegateQueue: dispatch_get_main_queue()];
    _xmppAutoPing.respondsToQueries = YES;
    _xmppAutoPing.pingInterval = 2;//ping 间隔时间
    if (nil != strProxyServer)
    {
        _xmppAutoPing.targetJID = [XMPPJID jidWithString: strProxyServer ];
        //设置ping目标服务器，如果为nil,则监听socketstream当前连接上的那个服务器
    }
    
    //卸载监听
//    [_xmppAutoPing  deactivate];
//    [_xmppAutoPing  removeDelegate:self];
//    _xmppAutoPing = nil;
}

//ping XMPPAutoPingDelegate的委托方法:
- (void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender
{
    NSLog(@"- (void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender");
}
- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender
{
    NSLog(@"- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender");
}

- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender
{
    NSLog(@"- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender");
}

@end
