//
//  ChatViewController.h
//  XMPPTest
//
//  Created by Apple on 16/10/12.
//  Copyright © 2016年 waiguo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController

-(instancetype)initWithUser:(NSString*)userName;

@property(nonatomic,copy) NSString *userID;
@property(nonatomic,copy) XMPPRoster *roster;
@property(nonatomic,copy) XMPPStream *stream;

@end
