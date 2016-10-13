//
//  ContactViewController.m
//  XMPPTest
//
//  Created by Apple on 16/10/12.
//  Copyright © 2016年 waiguo. All rights reserved.
//

#import "ChatViewController.h"

#import "ContactViewController.h"

@interface ContactViewController ()<UITableViewDelegate,UITableViewDataSource,XMPPStreamDelegate,XMPPRosterDelegate,SMChatDelegate>
{
    NSMutableArray *onlineBuddies;
}

@property(nonatomic,strong)UITableView *tableView;

@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    onlineBuddies = [[NSMutableArray alloc]init];
    self.title = @"好友";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
    AppDelegate *del = [self appDelegate];
    del.chatDelegate = self;
    
    //show buddy list
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [_stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    [_roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    [_roster fetchRoster];
    
}


- (void)newBuddyOnline:(NSString *)buddyName
{
    if ([onlineBuddies containsObject:buddyName])
    {
        [onlineBuddies addObject:buddyName];
        [self.tableView reloadData];
    }
}

- (void)buddyWentOffline:(NSString *)buddyName
{
    if ([onlineBuddies containsObject:buddyName])
    {
        [onlineBuddies removeObject:buddyName];
        [self.tableView reloadData];
    }
}

- (void)didDisconnect
{
    
}

-(AppDelegate *)appDelegate
{
    return (AppDelegate*)[[UIApplication sharedApplication]delegate];
}

-(XMPPStream*)smppStream
{
    return [[self appDelegate]stream];
}






- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSString *presenceType = [presence type]; // online/offline
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:myUsername])
    {
        if ([presenceType isEqualToString:@"available"])
        {
//            [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"jerry.local"]];
        }
        else if ([presenceType isEqualToString:@"unavailable"])
        {
//            [_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"jerry.local"]];
        }
    }
}


//获取到一个好友节点
- (void)xmppRoster:(XMPPRoster *)sender didRecieveRosterItem:(NSXMLElement *)item
{
    
}
//获取完好友列表
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{

}

//到服务器上请求联系人名片信息
- (void)fetchvCardTempForJID:(XMPPJID *)jid
{
    
}


//请求联系人的名片，如果数据库有就不请求，没有就发送名片请求
- (void)fetchvCardTempForJID:(XMPPJID *)jid ignoreStorage:(BOOL)ignoreStorage
{
    
}


/*
//获取联系人的名片，如果数据库有就返回，没有返回空，并到服务器上抓取
- (XMPPvCardTemp *)vCardTempForJID:(XMPPJID *)jid shouldFetch:(BOOL)shouldFetch
{
    
}
//更新自己的名片信息
- (void)updateMyvCardTemp:(XMPPvCardTemp *)vCardTemp
{
    
}

//获取到一盒联系人的名片信息的回调
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid
{
    
}
*/


-(UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, DEVICE_SCREEN_W, DEVICE_SCREEN_H-64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}
#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
    return onlineBuddies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"UserCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = @"gph1991";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *userName = (NSString *) [onlineBuddies objectAtIndex:indexPath.row];
    ChatViewController *chatVC = [[ChatViewController alloc]initWithUser:@"gph1991"];
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
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
