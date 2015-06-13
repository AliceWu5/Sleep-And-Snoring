//
//  OAuth2Authentication.m
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/1.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "OAuth2Authentication.h"
#import "GTMHTTPFetcher.h"

// Extern strings

NSString *const vOAuth2ErrorMessageKey = @"error";
NSString *const vOAuth2ErrorRequestKey = @"request";
NSString *const vOAuth2ErrorJSONKey    = @"json";

//// client key/secret
//static NSString *const vOAuth2ClientIDKey              = @"client_id";
//static NSString *const vOAuth2ClientSecretKey          = @"client_secret";

// standard OAuth keys
static NSString *const vOAuth2ServiceProviderKey    = @"serviceProvider";
static NSString *const vOAuth2AuthorizationURIKey   = @"authorization_uri";
static NSString *const vOAuth2AccessTokenURIKey     = @"access_token_uri";
static NSString *const vOAuth2RefreshTokenURIKey    = @"refresh_token_uri";
static NSString *const vOAuth2RedirectURIKey        = @"redirect_uri";
static NSString *const vOAuth2ScopeKey              = @"scope";
static NSString *const vOAuth2ErrorKey              = @"error";
static NSString *const vOAuth2TokenTypeKey          = @"token_type";
static NSString *const vOAuth2ExpiresInKey          = @"expires_in";
static NSString *const vOAuth2CodeKey               = @"code";
static NSString *const vOAuth2AssertionKey          = @"assertion";
static NSString *const vOAuth2RefreshScopeKey       = @"refreshScope";

// additional persistent keys
static NSString *const vUserIDKey              = @"userID";
static NSString *const vUserEmailKey           = @"email";
static NSString *const vUserEmailIsVerifiedKey = @"isVerified";

// fetcher keys
static NSString *const vTokenFetchDelegateKey = @"delegate";
static NSString *const vTokenFetchSelectorKey = @"sel";



@interface OAuth2Authentication ()
@property NSURL *authorizationURL;
@property (strong, nonatomic) NSMutableDictionary *authDictionary;

@end

@implementation OAuth2Authentication

+ (OAuth2Authentication *)authenticationWithServiceProvider:(NSString *)serviceProvider
                                           authorizationURI:(NSString *)authorizationURI
                                             accessTokenURI:(NSString *)accessTokenURI
                                            refreshTokenURI:(NSString *)refreshTokenURI
                                                redirectURI:(NSString *)redirectURI {
    OAuth2Authentication *auth = [[self alloc] init];
    [auth.parameters setValue:serviceProvider forKey:vOAuth2ServiceProviderKey];
    [auth.parameters setValue:accessTokenURI forKey:vOAuth2AccessTokenURIKey];
    [auth.parameters setValue:authorizationURI forKey:vOAuth2AuthorizationURIKey];
    [auth.parameters setValue:redirectURI forKey:vOAuth2RedirectURIKey];
    [auth.parameters setValue:refreshTokenURI forKey:vOAuth2RefreshTokenURIKey];
    
    return auth;
}


- (NSURL *)getAuthorizationPageWithOptions:(NSString *)options {
    
    NSString *authrizeURL = [self.parameters objectForKey:vOAuth2AuthorizationURIKey];
    NSString *params = @"";
    if (options) {
        params = [params stringByAppendingFormat:@"%@&client_id=%@", options, self.clientID];
    } else {
        params = [params stringByAppendingFormat:@"client_id=%@", self.clientID];

    }
    
    if (self.clientID && self.scope && self.responseType) {
        params = [params stringByAppendingFormat:@"&scope=%@", self.scope];
        params = [params stringByAppendingFormat:@"&redirect_uri=%@", [self.parameters objectForKey:vOAuth2RedirectURIKey]];
        params = [params stringByAppendingFormat:@"&response_type=%@", self.responseType];
    } else if (self.clientID && self.scope) {
        params = [params stringByAppendingFormat:@"&scope=%@", self.scope];
        params = [params stringByAppendingFormat:@"&redirect_uri=%@", [self.parameters objectForKey:vOAuth2RedirectURIKey]];
    }
    
    NSString *escapedParams = [params stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    authrizeURL = [authrizeURL stringByAppendingFormat:@"?%@",escapedParams];
    NSLog(@"The authorization page : %@", authrizeURL);
    return [NSURL URLWithString:authrizeURL];
}


// check if the authrization is finished
- (BOOL)authorizationFinishedWithURL:(NSURL *)callbackURL {
    
    NSString *urlString = [callbackURL absoluteString];
    if ([urlString hasPrefix:[self.parameters objectForKey:vOAuth2RedirectURIKey]]) {
        return true;
    }
    return false;
}


// get authorization result in NSDictionary
- (NSDictionary *)getAuthorizationResultFromURL:(NSURL *)callbackURL {
    
    // use urlcomponent to parse parameters from url
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:callbackURL resolvingAgainstBaseURL:NO];
    NSArray *queryItems = urlComponents.queryItems;
    
    // store result to dictionary
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    for (NSURLQueryItem *item in queryItems) {
        [dictionary setValue:item.value forKey:item.name];
    }
    return dictionary;
}


// exchange token from service provider
- (void)getAccessTokenFromAuthorizationCode:(NSString *)code
                               onCompletion:(void (^)(NSData *data, NSError *error))handler {
    
    // exchange token from this url
    NSURL *accessTokenURL = [NSURL URLWithString:[self.parameters valueForKey:vOAuth2AccessTokenURIKey]];
    
    // redirect url
    NSString *redirectURI = [self.parameters valueForKey:vOAuth2RedirectURIKey];
    
    // set up customized request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:accessTokenURL];
    
    // create NSData object
    NSData *nsdata = [[NSString stringWithFormat:@"%@:%@", self.clientID, self.clientSecret] dataUsingEncoding:NSUTF8StringEncoding];
    
    // get NSString from NSData object in Base64
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    
    // set post content
    NSString *postBody = [NSString stringWithFormat:@"code=%@&grant_type=%@&client_id=%@&redirect_uri=%@",
                          code, @"authorization_code", self.clientID, redirectURI];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Basic %@", base64Encoded] forHTTPHeaderField:@"Authorization"];
    
    // check the post content
    //    NSString *base64Decoded = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    //    NSLog(@"The http body : %@", base64Decoded);
    
    // fetch data using GTMHTTPFetcher
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    
    // callback for user
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        handler(data, error);
    }];
}

// refresh access token
- (void)refreshAccessTokenByRefreshToken:(NSString *)refreshToken
                          onCompletion:(void (^)(NSData *, NSError *))handler {
    
    // exchange token from this url
    NSURL *refreshTokenURL = [NSURL URLWithString:[self.parameters valueForKey:vOAuth2RefreshTokenURIKey]];

    // set up customized request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:refreshTokenURL];
    
    // create NSData object
    NSData *nsdata = [[NSString stringWithFormat:@"%@:%@", self.clientID, self.clientSecret] dataUsingEncoding:NSUTF8StringEncoding];
    
    // get NSString from NSData object in Base64
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    
    // set post content
    NSString *postBody = [NSString stringWithFormat:@"grant_type=%@&refresh_token=%@", @"refresh_token", refreshToken];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Basic %@", base64Encoded] forHTTPHeaderField:@"Authorization"];

    // fetch data using GTMHTTPFetcher
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    
    // callback for user
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        handler(data, error);
    }];
    
}




// fetch data from API
+ (void)sendCustomizedRquestToAPI:(NSURLRequest *)request
                    onCompletion:(void (^)(NSData *data, NSError *error))handler {
    
    // fetch data using GTMHTTPFetcher
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        handler(data, error);
    }];
    
}





- (NSMutableDictionary *)parameters {
    if (!_parameters) {
        _parameters = [[NSMutableDictionary alloc] init];
    }
    return _parameters;
}



@end
