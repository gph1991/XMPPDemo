//
//  ConnectManager.m
//  XMPPTest
//
//  Created by Apple on 16/10/12.
//  Copyright © 2016年 waiguo. All rights reserved.
//

#import "ConnectManager.h"

@interface ConnectManager()<XMPPStreamDelegate,XMPPRosterDelegate>
{
    BOOL isOpen;
}
@property(nonatomic,copy) XMPPRoster *roster;
@property(nonatomic,copy) XMPPStream *stream;

@end

@implementation ConnectManager

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
    [_stream setHostName:@"127.0.0.1"];
    [_stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (BOOL)connect
{
    
    [UIApplication sharedApplication].delegate;
    
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

- (void)disconnect {
    
    [self goOffline];
    [[self stream] disconnect];
}

-(XMPPStream *)stream
{
    if (!_stream)
    {
        _stream = [[XMPPStream alloc] init];
        //设定服务器名称
        [_stream setHostName:@"127.0.0.1"];
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
    isOpen = YES;
    NSError *error = nil;
    [[self stream] authenticateWithPassword:_password error:&error];
}

//认证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    [self goOnline];
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

@end
