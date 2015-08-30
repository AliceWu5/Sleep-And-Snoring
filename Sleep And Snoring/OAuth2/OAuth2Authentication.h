//
//  OAuth2Authentication.h
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/1.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "APIFetcher.h"
@class SecViewController;
@protocol OAuth2Delegate <NSObject>

@required
-(void)getAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken;
@end

@interface OAuth2Authentication : NSObject


@property (strong, nonatomic)NSMutableDictionary *parameters;
@property (strong, nonatomic)NSString *clientID;
@property (strong, nonatomic)NSString *clientSecret;
@property (strong, nonatomic)NSString *scope;
@property (strong, nonatomic)NSString *responseType;
@property (strong, nonatomic)NSString *apiBaseURL;

@property (weak, nonatomic)id<OAuth2Delegate> delegate;

+ (OAuth2Authentication *)authenticationWithServiceProvider:(NSString *)serviceProvider
                                           authorizationURI:(NSString *)authorizationURI
                                             accessTokenURI:(NSString *)accessTokenURI
                                            refreshTokenURI:(NSString *)refreshTokenURI
                                                redirectURI:(NSString *)redirectURI;
+ (OAuth2Authentication *)fitbitAuth;
-(BOOL)openAuthorizationPage;



// method for authorization code flow
- (NSURL *)getAuthorizationPageWithOptions:(NSString *)options;
- (BOOL)authorizationFinishedWithURL:(NSURL *)callbackURL;
- (NSDictionary *)getAuthorizationResultFromURL:(NSURL *)callbackURL;
- (void)getAccessTokenFromAuthorizationCode:(NSString *)code onCompletion:(void (^)(NSData *data, NSError *error))handler;
- (void)refreshAccessTokenByRefreshToken:(NSString *)refreshToken onCompletion:(void (^)(NSData *data, NSError *error))handler;


// fetch api
+ (void)sendCustomizedRquestToAPI:(NSURLRequest *)request onCompletion:(void (^)(NSData *data, NSError *error))handler;


@end
