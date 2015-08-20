//
//  OAuth2ViewController.m
//  OAuthDemo
//
//  Created by Jiao Liu on 15/6/2.
//  Copyright (c) 2015年 Xibo Wang. All rights reserved.
//

#import "OAuth2ViewController.h"
#import "APIFetcher.h"

// UserDefaults
static NSString *const vServiceProvider = @"Fitbit";
static NSString *const vClientID        = @"229Q8T";
static NSString *const vClientSecret    = @"1515d15713ba40771aee66b4cbc33e9b";
static NSString *const vAPIBaseURL      = @"https://api.fitbit.com";

// keys
static NSString *const vOAuth2AccessTokenKey    = @"access_token";
static NSString *const vOAuth2RefreshTokenKey   = @"refresh_token";

@interface OAuth2ViewController ()
@property (nonatomic, strong)UIWebView *webView;
@property (nonatomic, strong)OAuth2Authentication *auth;
@property (nonatomic, strong)NSString *accessToken;
@property (nonatomic, strong)NSString *refreshToken;
@property (nonatomic, strong)NSMutableDictionary *tokens;
@property (nonatomic, strong)UIActivityIndicatorView *indicator;
@property BOOL needIndication;
@end

@implementation OAuth2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self signInToCustomService];
    self.needIndication = NO;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark accessors

-(UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    }
    return _webView;
}

- (OAuth2Authentication *)auth {
    if (!_auth) {
        _auth = [OAuth2ViewController customAuth];
    }
    return _auth;
}

-(UIActivityIndicatorView *)indicator {
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.color = [UIColor grayColor];
        _indicator.center = self.view.center;
        [self.webView addSubview:_indicator];
    }
    return _indicator;
}

- (void)signInToCustomService {
    [self signOut];
    
    // set up url
    NSURL *url = [self.auth getAuthorizationPageWithOptions:@"display=touch"];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    
    // set up webview
    [self.webView setDelegate:self];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
}

// clear cookies to allow sign in
- (void)signOut {
    // clear cookies
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// create customized OAuth2
+ (OAuth2Authentication *)customAuth {
    
    NSString *tokenURL = @"https://api.fitbit.com/oauth2/token";
    NSString *authorizeURL = @"https://www.fitbit.com/oauth2/authorize";
    NSString *redirectURI = @"http://com.sheffield.fitbit";
    // We'll make up an arbitrary redirectURI.  The controller will watch for
    // the server to redirect the web view to this URI, but this URI will not be
    // loaded, so it need not be for any actual web page.
    
    OAuth2Authentication *auth;
    auth = [OAuth2Authentication authenticationWithServiceProvider:vServiceProvider
                                                  authorizationURI:authorizeURL
                                                    accessTokenURI:tokenURL
                                                   refreshTokenURI:tokenURL
                                                       redirectURI:redirectURI];
    
    // Specify the appropriate scope string, if any, according to the service's API documentation
    auth.scope = @"activity profile sleep heartrate";
    auth.responseType = @"code";
    auth.clientID = vClientID;
    auth.clientSecret = vClientSecret;
    auth.apiBaseURL = vAPIBaseURL;
    return auth;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



// update UI methods




// UIWebView Delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    // stop loading the page when sucessful sign in
    NSURL *currentURL = request.URL;
    [self.indicator startAnimating];
    if ([self.auth authorizationFinishedWithURL:currentURL]) {
        
        self.needIndication = YES;
        [self.indicator startAnimating];
        NSLog(@"catch redirect.");
        // authorization result
        NSDictionary *dictionary = [self.auth getAuthorizationResultFromURL:currentURL];
        
        // successful login
        if (![dictionary valueForKey:@"error"]) {
            
            // load customized successful page
            NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"login" ofType:@"html"];
            NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
            NSString *path = [[NSBundle mainBundle] bundlePath];
            NSURL *baseURL = [NSURL fileURLWithPath:path];
            [webView loadHTMLString:htmlString baseURL:baseURL];

            
            // exchange code for access token
            NSString *authorizationCode = [dictionary valueForKey:@"code"];
            [self.auth getAccessTokenFromAuthorizationCode:authorizationCode onCompletion:^(NSData *data, NSError *error) {
                if (error) {
                    // failed; either an NSURLConnection error occurred, or the server returned
                    // a status value of at least 300
                    NSLog(@"Return error : %@", error);
                } else {
                    NSError* errorInSerialization;
                    NSDictionary *fetchResult = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:kNilOptions
                                                                           error:&errorInSerialization];
                    
                    // return the fetcher back to view controller
                    APIFetcher *fetcher = [APIFetcher fetcherWithOAuth2:self.auth
                                                            accessToken:[fetchResult objectForKey:vOAuth2AccessTokenKey]
                                                           refreshToken:[fetchResult objectForKey:vOAuth2RefreshTokenKey]];
                    [self.navigationController popViewControllerAnimated:YES];
                    [self.delegate addItems:fetcher withMessage:@"Successful"];
                    
                    NSLog(@"Fetch Result : successful");
                }
            }];
            
        } else {
            // send error message
            NSString *errorMessage = [dictionary valueForKey:@"error_description"];
            errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            [self.navigationController popViewControllerAnimated:YES];
            [self.delegate addItems:nil withMessage:errorMessage];
            NSLog(@"Error : %@", errorMessage);
        }
        
        return false;
    }
    
    return YES;
}


-(void)webViewDidFinishLoad:(UIWebView *)webView {
    // continue animating when load a local page
    if (!self.needIndication) {
        [self.indicator stopAnimating];
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Error : %@", error);
}



@end
