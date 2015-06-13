//
//  OAuth2Authentication.h
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/1.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OAuth2Authentication : NSObject
@property (strong, nonatomic)NSMutableDictionary *parameters;
@property (strong, nonatomic)NSString *clientID;
@property (strong, nonatomic)NSString *clientSecret;
@property (strong, nonatomic)NSString *scope;
@property (strong, nonatomic)NSString *responseType;
@property (strong, nonatomic)NSString *apiBaseURL;

+ (OAuth2Authentication *)authenticationWithServiceProvider:(NSString *)serviceProvider
                                           authorizationURI:(NSString *)authorizationURI
                                             accessTokenURI:(NSString *)accessTokenURI
                                            refreshTokenURI:(NSString *)refreshTokenURI
                                                redirectURI:(NSString *)redirectURI;

- (NSURL *)getAuthorizationPageWithOptions:(NSString *)options;
- (BOOL)authorizationFinishedWithURL:(NSURL *)callbackURL;
- (NSDictionary *)getAuthorizationResultFromURL:(NSURL *)callbackURL;
- (void)getAccessTokenFromAuthorizationCode:(NSString *)code onCompletion:(void (^)(NSData *data, NSError *error))handler;
- (void)refreshAccessTokenByRefreshToken:(NSString *)refreshToken onCompletion:(void (^)(NSData *data, NSError *error))handler;


// fetch api
+ (void)sendCustomizedRquestToAPI:(NSURLRequest *)request onCompletion:(void (^)(NSData *data, NSError *error))handler;


@end
