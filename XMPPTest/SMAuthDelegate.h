//
//  SMAuthDelegate.h
//  XMPPTest
//
//  Created by Apple on 16/10/13.
//  Copyright © 2016年 waiguo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMAuthDelegate

- (void)loginDidFinish:(NSString*)error;
- (void)regDidFinish:(NSString*)error;

@end
