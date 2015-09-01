//
//  OAuth2Authentication.m
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/1.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "OAuth2Authentication.h"
#import "GTMHTTPFetcher.h"
#import "AppDelegate.h"
// Extern strings

NSString *const kOAuth2ErrorMessageKey = @"error";
NSString *const kOAuth2ErrorRequestKey = @"request";
NSString *const kOAuth2ErrorJSONKey    = @"json";

// UserDefaults
static NSString *const kFitbitServiceProvider   = @"Fitbit";
static NSString *const kFitbitClientID          = @"229Q8T";
static NSString *const kFitbitClientSecret      = @"1515d15713ba40771aee66b4cbc33e9b";
static NSString *const kFitbitAPIBaseURL        = @"https://api.fitbit.com";

// keys
static NSString *const kOAuth2AccessTokenKey    = @"access_token";
static NSString *const kOAuth2RefreshTokenKey   = @"refresh_token";

//// client key/secret
//static NSString *const kOAuth2ClientIDKey              = @"client_id";
//static NSString *const kOAuth2ClientSecretKey          = @"client_secret";

// standard OAuth keys
static NSString *const kOAuth2ServiceProviderKey    = @"serviceProvider";
static NSString *const kOAuth2AuthorizationURIKey   = @"authorization_uri";
static NSString *const kOAuth2AccessTokenURIKey     = @"access_token_uri";
static NSString *const kOAuth2RefreshTokenURIKey    = @"refresh_token_uri";
static NSString *const kOAuth2RedirectURIKey        = @"redirect_uri";
static NSString *const kOAuth2ScopeKey              = @"scope";
static NSString *const kOAuth2ErrorKey              = @"error";
static NSString *const kOAuth2TokenTypeKey          = @"token_type";
static NSString *const kOAuth2ExpiresInKey          = @"expires_in";
static NSString *const kOAuth2CodeKey               = @"code";
static NSString *const kOAuth2AssertionKey          = @"assertion";
static NSString *const kOAuth2RefreshScopeKey       = @"refreshScope";

// additional persistent keys
static NSString *const kUserIDKey              = @"userID";
static NSString *const kUserEmailKey           = @"email";
static NSString *const kUserEmailIsVerifiedKey = @"isVerified";

// fetcher keys
static NSString *const kTokenFetchDelegateKey = @"delegate";
static NSString *const kTokenFetchSelectorKey = @"sel";



@interface OAuth2Authentication ()
@property NSURL *authorizationURL;
@property (strong, nonatomic) NSMutableDictionary *authDictionary;
@property (strong, nonatomic) NSString *authorizationCode;
@end

@implementation OAuth2Authentication

+ (OAuth2Authentication *)authenticationWithServiceProvider:(NSString *)serviceProvider
                                           authorizationURI:(NSString *)authorizationURI
                                             accessTokenURI:(NSString *)accessTokenURI
                                            refreshTokenURI:(NSString *)refreshTokenURI
                                                redirectURI:(NSString *)redirectURI {
    OAuth2Authentication *auth = [[self alloc] init];
    [auth.parameters setValue:serviceProvider forKey:kOAuth2ServiceProviderKey];
    [auth.parameters setValue:accessTokenURI forKey:kOAuth2AccessTokenURIKey];
    [auth.parameters setValue:authorizationURI forKey:kOAuth2AuthorizationURIKey];
    [auth.parameters setValue:redirectURI forKey:kOAuth2RedirectURIKey];
    [auth.parameters setValue:refreshTokenURI forKey:kOAuth2RefreshTokenURIKey];
    [[NSNotificationCenter defaultCenter] addObserver:auth selector:@selector(receiveAuthorizationCodeFromNotification:) name:kAppDelegateCallbackNotificationKey object:nil];
    return auth;
}

+(OAuth2Authentication *)fitbitAuth {
    // create customized OAuth2
    
        NSString *tokenURL = @"https://api.fitbit.com/oauth2/token";
        NSString *authorizeURL = @"https://www.fitbit.com/oauth2/authorize";
        NSString *redirectURI = @"app://uk.ac.sheffield.sleepandsnoring";
        // We'll make up an arbitrary redirectURI.  The controller will watch for
        // the server to redirect the web view to this URI, but this URI will not be
        // loaded, so it need not be for any actual web page.
        
        OAuth2Authentication *auth;
        auth = [OAuth2Authentication authenticationWithServiceProvider:kFitbitServiceProvider
                                                      authorizationURI:authorizeURL
                                                        accessTokenURI:tokenURL
                                                       refreshTokenURI:tokenURL
                                                           redirectURI:redirectURI];
        
        // Specify the appropriate scope string, if any, according to the service's API documentation
        auth.scope = @"activity profile sleep heartrate";
        auth.responseType = @"code";
        auth.clientID = kFitbitClientID;
        auth.clientSecret = kFitbitClientSecret;
        auth.apiBaseURL = kFitbitAPIBaseURL;
        return auth;
}

-(BOOL)openAuthorizationPage {
    NSURL *authorizationURL = [self getAuthorizationPageWithOptions:@"display=touch"];
    if (![[UIApplication sharedApplication] openURL:authorizationURL]) {
        NSLog(@"%@%@",@"Failed to open url:",[authorizationURL description]);
        return NO;
    }
    return YES;
}

-(void)receiveAuthorizationCodeFromNotification:(NSNotification *)notification {
    NSURL *url = notification.object;
    NSDictionary *result = [self getAuthorizationResultFromURL:url];
    // successful login
    if (![result valueForKey:@"error"]) {
        
        // exchange code for access token
        NSString *authorizationCode = [result valueForKey:@"code"];
        [self getAccessTokenFromAuthorizationCode:authorizationCode onCompletion:^(NSData *data, NSError *error) {
            if (error) {
                // failed; either an NSURLConnection error occurred, or the server returned
                // a status value of at least 300
                NSLog(@"Return error : %@", error);
            } else {
                NSError* errorInSerialization;
                NSDictionary *fetchResult = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:kNilOptions
                                                                              error:&errorInSerialization];
                // return access token and refresh token
                NSString *accessToken = [fetchResult objectForKey:kOAuth2AccessTokenKey];
                NSString *refreshToken = [fetchResult objectForKey:kOAuth2RefreshTokenKey];
                [self.delegate getAccessToken:accessToken refreshToken:refreshToken];
                NSLog(@"Fetch Result : login successful");
            }
        }];
        
    } else {
        // send error message
        NSString *errorMessage = [result valueForKey:@"error_description"];
        errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        NSLog(@"Error : %@", errorMessage);
    }
}



- (NSURL *)getAuthorizationPageWithOptions:(NSString *)options {
    
    NSString *authrizeURL = [self.parameters objectForKey:kOAuth2AuthorizationURIKey];
    NSString *params = @"";
    if (options) {
        params = [params stringByAppendingFormat:@"%@&client_id=%@", options, self.clientID];
    } else {
        params = [params stringByAppendingFormat:@"client_id=%@", self.clientID];

    }
    
    if (self.clientID && self.scope && self.responseType) {
        params = [params stringByAppendingFormat:@"&scope=%@", self.scope];
        params = [params stringByAppendingFormat:@"&redirect_uri=%@", [self.parameters objectForKey:kOAuth2RedirectURIKey]];
        params = [params stringByAppendingFormat:@"&response_type=%@", self.responseType];
    } else if (self.clientID && self.scope) {
        params = [params stringByAppendingFormat:@"&scope=%@", self.scope];
        params = [params stringByAppendingFormat:@"&redirect_uri=%@", [self.parameters objectForKey:kOAuth2RedirectURIKey]];
    }
    params = [params stringByAppendingFormat:@"&prompt=login"];
    
    
    NSString *escapedParams = [params stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    authrizeURL = [authrizeURL stringByAppendingFormat:@"?%@",escapedParams];
    NSLog(@"The authorization page : %@", authrizeURL);
    return [NSURL URLWithString:authrizeURL];
}


// check if the authrization is finished
- (BOOL)authorizationFinishedWithURL:(NSURL *)callbackURL {
    
    NSString *urlString = [callbackURL absoluteString];
    if ([urlString hasPrefix:[self.parameters objectForKey:kOAuth2RedirectURIKey]]) {
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
    NSURL *accessTokenURL = [NSURL URLWithString:[self.parameters valueForKey:kOAuth2AccessTokenURIKey]];
    
    // redirect url
    NSString *redirectURI = [self.parameters valueForKey:kOAuth2RedirectURIKey];
    
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
    NSURL *refreshTokenURL = [NSURL URLWithString:[self.parameters valueForKey:kOAuth2RefreshTokenURIKey]];

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
    
    NSLog(@"%@", request);
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

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[super dealloc];
    
}



- (NSMutableDictionary *)parameters {
    if (!_parameters) {
        _parameters = [[NSMutableDictionary alloc] init];
    }
    return _parameters;
}



@end
