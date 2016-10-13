//
//  ChatViewController.m
//  XMPPTest
//
//  Created by Apple on 16/10/12.
//  Copyright © 2016年 waiguo. All rights reserved.
//


#import "ChatViewController.h"

@interface ChatViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,SMMessageDelegate>
{
    UITextField *inputField;
    NSMutableArray  *messages;
    NSString *chatWithUser;
    
    UIView *inputView;
}
@property(nonatomic,strong)UITableView *tableView;
@end

@implementation ChatViewController
-(instancetype)initWithUser:(NSString*)userName
{
    if (self = [super init])
    {
        chatWithUser = userName;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    messages = [[NSMutableArray alloc]init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = chatWithUser;
    [self createSubview];
    AppDelegate *del = [self appDelegate];
    del.messageDelegate = self;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyHide:(NSNotification*)notify
{
    inputView.frame = CGRectMake(0, DEVICE_SCREEN_H-40, DEVICE_SCREEN_W, 40);
    self.tableView.frame = CGRectMake(0, 64, DEVICE_SCREEN_W, DEVICE_SCREEN_H-64-40);
    if(messages.count > 0)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)keyShow:(NSNotification*)notify
{
    NSDictionary *dic = notify.userInfo;
    NSValue *t = [dic objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect rect = [t CGRectValue] ;
    inputView.frame = CGRectMake(0, rect.origin.y-40, DEVICE_SCREEN_W, 40);
    self.tableView.frame = CGRectMake(0, 64, DEVICE_SCREEN_W, rect.origin.y-40-64);
    if(messages.count > 0)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)newMessageReceived:(NSDictionary *)messageContent
{
    [messages addObject:messageContent];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(AppDelegate *)appDelegate
{
    return (AppDelegate*)[[UIApplication sharedApplication]delegate];
}

-(XMPPStream*)xmppStream
{
    return [[self appDelegate]stream];
}


-(void)sendMessage
{
    NSString *messageStr = inputField.text;
    
    if([messageStr length] > 0)
    {
        inputField.text = @"";
                
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        NSString *to = [NSString stringWithFormat:@"%@@%@", chatWithUser,HOST];
        [message addAttributeWithName:@"to" stringValue:to];
        [message addChild:body];
        [self.xmppStream sendElement:message];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:messageStr forKey:@"msg"];
        [dic setObject:@"you" forKey:@"sender"];
        
        [messages addObject:dic];
        
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)createSubview
{
    inputView = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_SCREEN_H-40, DEVICE_SCREEN_W, 40)];
    [self.view addSubview:inputView];
    
    inputField = [[UITextField alloc]initWithFrame:CGRectMake(5, 0, DEVICE_SCREEN_W-70, 40)];
    inputField.backgroundColor = [UIColor whiteColor];
    inputField.layer.cornerRadius = 5;
    inputField.layer.masksToBounds = YES;
    inputField.delegate = self;
    inputField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    inputField.layer.borderWidth = 1;
    inputField.placeholder = @" 请输入";
    [inputView addSubview:inputField];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"Send" forState:UIControlStateNormal];
    btn.frame = CGRectMake(DEVICE_SCREEN_W-50, 0, 40, 35);
    [inputView addSubview:btn];
    [btn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.tableView];
}


-(UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, DEVICE_SCREEN_W, DEVICE_SCREEN_H-64-40) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return _tableView;
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *s = (NSDictionary *) [messages objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"MessageCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        UILabel *content = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, DEVICE_SCREEN_W, 40)];
        content.font = [UIFont systemFontOfSize:13];
        content.backgroundColor = [UIColor lightGrayColor];
        content.layer.masksToBounds = YES;
        content.layer.cornerRadius = 5;
        content.numberOfLines = 0;
        content.tag = 'cont';
        [cell.contentView addSubview:content];

        UILabel *sender = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, DEVICE_SCREEN_W, 15)];
        sender.tag = 'send';
        sender.font = [UIFont systemFontOfSize:10];
        [cell.contentView addSubview:sender];

        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
    }
    
    UILabel *contentLabel = (UILabel*)[cell.contentView viewWithTag:'cont'];
    UILabel *senderLabel = (UILabel*)[cell.contentView  viewWithTag:'send'];
    NSString *sendStr = [s objectForKey:@"sender"];
    contentLabel.text = [s objectForKey:@"msg"];
//    senderLabel.text = sendStr;
    
    if ([sendStr isEqualToString:@"you"])
    {
        contentLabel.frame = CGRectMake(DEVICE_SCREEN_W/2, 0, DEVICE_SCREEN_W/2-10, 30);
        senderLabel.frame = CGRectMake(DEVICE_SCREEN_W/2, 30, DEVICE_SCREEN_W/2, 13);
        
//        senderLabel.textAlignment = NSTextAlignmentRight;
//        contentLabel.textAlignment = NSTextAlignmentRight;
    }
    else
    {
        contentLabel.frame = CGRectMake(10, 0, DEVICE_SCREEN_W/2-10, 30);
        senderLabel.frame = CGRectMake(0, 30, DEVICE_SCREEN_W/2, 13);
        
//        senderLabel.textAlignment = NSTextAlignmentLeft;
//        contentLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
