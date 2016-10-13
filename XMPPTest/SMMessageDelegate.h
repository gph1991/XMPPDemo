//
//  SMMessageDelegate
//  XMPPTest
//
//  Created by Apple on 16/10/12.
//  Copyright © 2016年 waiguo. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SMMessageDelegate

- (void)newMessageReceived:(NSDictionary *)messageContent;

@end
