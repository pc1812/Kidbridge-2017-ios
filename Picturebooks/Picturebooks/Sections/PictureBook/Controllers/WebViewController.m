//
//  WebViewController.m
//  Picturebooks
//
//  Created by Yasin on 2017/8/10.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()<UIWebViewDelegate>

@property (nonatomic, retain) UIWebView *web;
@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (IOS7) {
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }

    self.view.backgroundColor = [UIColor whiteColor];
//    self.navigationItem.titleView = [UINavigationItem titleViewForTitle:@"详情"];
    self.web=[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-PBNew64)];
    
    self.web.scalesPageToFit = YES;
    self.web.scrollView.showsHorizontalScrollIndicator = NO;
    [self.web sizeToFit];
    self.web.userInteractionEnabled=YES;
    self.web.delegate = self;
    self.web.backgroundColor=[UIColor clearColor];
    [self.view addSubview:self.web];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame : CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)] ;
    [self.activityIndicatorView setCenter: self.web.center] ;
    [self.activityIndicatorView setActivityIndicatorViewStyle: UIActivityIndicatorViewStyleGray] ;
    [self.view addSubview : self.activityIndicatorView] ;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60.0];
    [self.web loadRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self.activityIndicatorView startAnimating] ;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.activityIndicatorView stopAnimating];
#pragma Jxd-修改->获取HTML 中的标题
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.navigationItem.title = title;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self.activityIndicatorView stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
