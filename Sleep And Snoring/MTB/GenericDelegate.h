//
//  GenericDelegate.h
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/3.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol GenericDelegate <NSObject>


@optional
- (void)addItems:(id)item withMessage:(NSString *)message;


@end