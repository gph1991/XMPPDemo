//
//  ViewController.m
//  XMPPTest
//
//  Created by Apple on 16/10/12.
//  Copyright © 2016年 waiguo. All rights reserved.
//

#import "ViewController.h"
#import "ContactViewController.h"


@interface ViewController ()<XMPPStreamDelegate,XMPPRosterDelegate,SMAuthDelegate>
{
    IBOutlet UITextField* _nameField;
    IBOutlet UITextField* _passwordField;
    IBOutlet UITextField* _friendField;
    IBOutlet UITextField* _messageField;
    XMPPStream *_stream;
    XMPPRoster *_roster;
}

- (IBAction)login:(id)sender;
- (IBAction)reg:(id)sender;
- (IBAction)addFriend:(id)sender;
- (IBAction)sendMessage:(id)sender;
- (IBAction)getFriendList:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"XMPP";
    AppDelegate *del = [self appDelegate];
    del.authDelegate = self;
    
//    //stream流
//    _stream = [[XMPPStream alloc] init];
//    //设定服务器名称
//    [_stream setHostName:HOST];
//    [_stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    
//    _roster = [[XMPPRoster alloc] initWithRosterStorage:[[XMPPRosterCoreDataStorage alloc] init]];
//    [_roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    [_roster activate:_stream];
}

-(AppDelegate *)appDelegate
{
    return (AppDelegate*)[[UIApplication sharedApplication]delegate];
}

-(XMPPStream*)xmppStream
{
    return [[self appDelegate]stream];
}

- (void)loginDidFinish:(NSString*)error
{
    if (!error)
    {
        ContactViewController *conVC = [[ContactViewController alloc]init];
        [self.navigationController pushViewController:conVC animated:YES];
    }
    else
    {
        NSLog(@"%@",error);
    }
}

- (void)regDidFinish:(NSString*)error
{
    if (!error)
    {
        
    }
    else
    {
        NSLog(@"%@",error);
    }
}

//上线
- (void)goOnline
{
    //<presence/>
    XMPPPresence* presence = [XMPPPresence presence];
    [_stream sendElement:presence];
    
    ContactViewController *conVC = [[ContactViewController alloc]init];
//    conVC.roster = _roster;
//    conVC.stream = _stream;
    [self.navigationController pushViewController:conVC animated:YES];
}

//下线
- (void)goOffline
{
    //<presence type="unavailable"/>
    XMPPPresence* presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_stream sendElement:presence];
    [_stream disconnect];
}

//注册
- (void)reg:(id)sender
{
    if (_stream.isConnected)
    {
        [self goOffline];
    }
    
    //设置账号
    [_stream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", _nameField.text, HOST]]];
    _stream.tag = @"注册";
    //连接
    [_stream connectWithTimeout:30 error:nil];
}

//登陆
- (void)login:(id)sender
{
    AppDelegate *del = [self appDelegate];
    del.username =  _nameField.text;
    del.password = _passwordField.text;
    [del login];
    return;
    if (_stream.isConnected)
    {
        [self goOffline];
    }
    
    //设置账号
    [_stream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", _nameField.text, HOST]]];
    
    _stream.tag = @"登陆";
    
    //连接
    [_stream connectWithTimeout:30 error:nil];
}

//添加好友
- (void)addFriend:(id)sender
{
    /*
     <presence type="subscribe" to="添加的jid" />
     XMPPPresence* presence = [XMPPPresence presenceWithType:@"subscribe" to:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", _friendField.text, HOST]]];
     [_stream sendElement:presence];
     */
    [_roster subscribePresenceToUser:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", _friendField.text, HOST]]];
}

//同意添加好友
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    if ([presence.fromStr isEqualToString:HOST])
    {
        return;
    }
    
    [_roster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:NO];
    NSLog(@"同意添加%@为好友", presence.fromStr);
}

//连接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"连接成功");
    //注册
    if ([sender.tag isEqualToString:@"注册"])
    {
        [_stream registerWithPassword:_passwordField.text error:nil];
    }
    //登陆
    if ([sender.tag isEqualToString:@"登陆"])
    {
        [_stream authenticateWithPassword:_passwordField.text error:nil];
    }
}

//登陆成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"登陆成功");
    [self goOnline];
}

//注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"注册成功");
}

//连接超时
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    NSLog(@"连接超时");
}
@end