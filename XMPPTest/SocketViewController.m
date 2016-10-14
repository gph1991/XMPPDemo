//
//  SocketViewController.m
//  XMPPTest
//
//  Created by Apple on 16/10/14.
//  Copyright © 2016年 waiguo. All rights reserved.
//

#define _IP_ADDRESS_V4_ @"192.168.1.68"
#define _SERVER_PORT_ 6666

#import "AsyncSocket.h"
#import "AsyncUdpSocket.h"
#import "SocketViewController.h"

@interface SocketViewController ()<AsyncSocketDelegate,UITextFieldDelegate>
{
    AsyncSocket *socket;
}

@property (strong, nonatomic)  UITextField *clientIPAddress;
@property (strong, nonatomic)  UITextView *receiveData;
@property (strong, nonatomic)  UITextField *inputField;
@property (strong, nonatomic)  UILabel *status;

@end

@implementation SocketViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Socket";
    self.view.backgroundColor = [UIColor whiteColor];
    _receiveData.editable = NO;
    
    [self createSubviews];
}

-(void)createSubviews
{
    [self.view addSubview:self.clientIPAddress];
    self.clientIPAddress.text = @"192.168.1.68";
    [self.view addSubview:self.status];
    self.status.text = @"Off";
    [self.view addSubview:self.receiveData];
    [self.view addSubview:self.inputField];
    
    UIButton *connectbtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [connectbtn setTitle:@"连接" forState:UIControlStateNormal];
    connectbtn.frame = CGRectMake(DEVICE_SCREEN_W-60, 64, 40, 40);
    [connectbtn addTarget:self action:@selector(connectToServer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:connectbtn];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"发送" forState:UIControlStateNormal];
    btn.frame = CGRectMake(DEVICE_SCREEN_W-60, 280, 40, 40);
    [btn addTarget:self action:@selector(sendBtnDown) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

-(void)sendBtnDown
{
    if(![_inputField.text isEqualToString:@""] && ![_clientIPAddress.text isEqualToString:@""])
    {
        NSString *message = _inputField.text;
        if(socket == nil)
        {
            socket = [[AsyncSocket alloc]initWithDelegate:self];
        }
        
        //NSString *content=[message stringByAppendingString:@"\r\n"];
        [socket writeData:[message dataUsingEncoding:NSUTF8StringEncoding]withTimeout:-1 tag:0];
        _receiveData.text = [NSString stringWithFormat:@"%@\nme:%@",_receiveData.text,_inputField.text];
        _inputField.text = @"";
    }
}

-(void)connectToServer
{
    if(!socket)
    {
        socket = [[AsyncSocket alloc]initWithDelegate:self];
        
        NSError *error = nil;
        if(![socket connectToHost:_IP_ADDRESS_V4_ onPort:_SERVER_PORT_ error:&error])
        {
            _status.text = @"失败!";
        }
        else
        {
            _status.text = @"已连接!";
        }
    }
    else
    {
        _status.text = @"已连接!";
    }
}


#pragma AsyncScoket Delagate
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"onSocket:%p didConnectToHost:%@ port:%hu",sock,host,port);
    [sock readDataWithTimeout:1 tag:0];
}
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [sock readDataWithTimeout: -1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString* aStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    self.receiveData.text = [NSString stringWithFormat:@"%@\n%@:%@",self.receiveData.text,sock.connectedHost,aStr];
    [socket readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didSecure:(BOOL)flag
{
    NSLog(@"onSocket:%p didSecure:YES", sock);
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"onSocket:%p willDisconnectWithError:%@", sock, err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    //断开连接了
    NSLog(@"onSocketDidDisconnect:%p", sock);
    NSString *msg = @"Off";
    _status.text = msg;
    socket = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(UITextField *)clientIPAddress
{
    if (!_clientIPAddress)
    {
        _clientIPAddress = [[UITextField alloc]initWithFrame:CGRectMake(0, 64, DEVICE_SCREEN_W-70-70, 35)];
        _clientIPAddress.delegate = self;
        _clientIPAddress.backgroundColor = [UIColor cyanColor];
        _clientIPAddress.tag = 1;
        _clientIPAddress.placeholder = @"IP";
    }
    
    return _clientIPAddress;
}

-(UITextField *)inputField
{
    if (!_inputField)
    {
        _inputField = [[UITextField alloc]initWithFrame:CGRectMake(0, 280, DEVICE_SCREEN_W-70, 35)];
        _inputField.backgroundColor = [UIColor cyanColor];
        _inputField.delegate = self;
        _inputField.tag = 1;
        _inputField.placeholder = @"Message";
    }
    
    return _inputField;
}

-(UILabel *)status
{
    if (!_status)
    {
        _status = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_SCREEN_W-60-70, 64, DEVICE_SCREEN_W, 40)];
    }
    
    return _status;
}

-(UITextView *)receiveData
{
    if (!_receiveData)
    {
        _receiveData = [[UITextView alloc]initWithFrame:CGRectMake(0, 64+40, DEVICE_SCREEN_W, 160)];
    }
    
    return _receiveData;
}

@end
