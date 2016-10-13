//
//  SMChatDelegate.h
//  XMPPTest
//
//  Created by Apple on 16/10/12.
//  Copyright © 2016年 waiguo. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SMChatDelegate

- (void)newBuddyOnline:(NSString *)buddyName;
- (void)buddyWentOffline:(NSString *)buddyName;
- (void)didDisconnect;

@end
