//
//  APIFetcher.m
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/3.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "APIFetcher.h"
#import "GTMHTTPFetcher.h"
// UserDefaults
static NSString *const vServiceProvider = @"Fitbit";
static NSString *const vClientID        = @"229Q8T";
static NSString *const vClientSecret    = @"1515d15713ba40771aee66b4cbc33e9b";

// keys
static NSString *const vOAuth2AccessTokenKey    = @"access_token";
static NSString *const vOAuth2RefreshTokenKey   = @"refresh_token";

@interface APIFetcher ()

@property (strong, nonatomic)NSString *apiBaseURL;

@end

@implementation APIFetcher


+ (APIFetcher *)fetcherWithOAuth2:(OAuth2Authentication *)auth
                      accessToken:(NSString *)accessToken
                     refreshToken:(NSString *)refreshToken {
    APIFetcher *fetcher = [[APIFetcher alloc] init];
    fetcher.auth = auth;
    fetcher.apiBaseURL = auth.apiBaseURL;
    fetcher.refreshToken = refreshToken;
    fetcher.accessToken = accessToken;
    
    return fetcher;
}



// fetch api
- (void)sendCustomizedRquestToAPI:(NSURLRequest *)request onCompletion:(void (^)(NSData *data, NSError *error))handler {
    [self getUserProfile];
}


- (void)sendGetRequestToAPIPath:(NSString *)path onCompletion:(void (^)(NSData *, NSError *))handler {
    
    NSMutableURLRequest *request = [self setCustomURLRequestWithAPIPath:path];
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
            handler(data, error);

            /*
             Print error use the same way as print data
             
            NSError* errorInSerialization;
            NSDictionary *errorDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:kNilOptions
                                                                          error:&errorInSerialization];
            NSLog(@"Error happens during fetching data from %@ : %@",path, errorDictionary);
            */
        
    }];
    
}

- (NSMutableURLRequest *)setCustomURLRequestWithAPIPath:(NSString *)path {
    
    // api resource url
    NSURL *url = [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:self.apiBaseURL]];
    
    // set request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", self.accessToken] forHTTPHeaderField:@"Authorization"];
    return request;
    
}

- (void)getUserProfile {
    // api resource url
    NSURL *url = [NSURL URLWithString:@"/1/user/-/profile.json" relativeToURL:[NSURL URLWithString:self.apiBaseURL]];

    // set request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", self.accessToken] forHTTPHeaderField:@"Authorization"];
    
    [OAuth2Authentication sendCustomizedRquestToAPI:request onCompletion:^(NSData *data, NSError *error) {
        if (error) {
            // failed; either an NSURLConnection error occurred, or the server returned
            // a status value of at least 300
            NSData *errorData = [error.userInfo objectForKey:@"data"];
            NSString *base64Decoded = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
            NSLog(@"The error data : %@", base64Decoded);
            
            [self.auth refreshAccessTokenByRefreshToken:self.refreshToken onCompletion:^(NSData *data, NSError *error) {
                
                NSError* errorInSerialization;
                NSDictionary *fetchResult = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:kNilOptions
                                                                              error:&errorInSerialization];
                
                self.accessToken = [fetchResult objectForKey:vOAuth2AccessTokenKey];
                self.refreshToken = [fetchResult objectForKey:vOAuth2RefreshTokenKey];
                NSLog(@"Refresh Result : %@", fetchResult);
                
            }];
            
        } else {
            NSString *base64Decoded = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"The result data : %@", base64Decoded);
            // fetch succeeded
        }
    }];
}



- (NSString *)description {
    return [NSString stringWithFormat:@""];
}



@end
