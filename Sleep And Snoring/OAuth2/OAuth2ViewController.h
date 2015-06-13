//
//  OAuth2ViewController.h
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/2.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericDelegate.h"
@interface OAuth2ViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic, weak) id <GenericDelegate> delegate;
- (void)signOut;

@end
