//
//  ViewController.m
//  NSURLProtocolTest
//
//  Created by 余晔 on 2017/4/10.
//  Copyright © 2017年 余晔. All rights reserved.
//

#import "ViewController.h"
#define zScreenHeight [[UIScreen mainScreen] bounds].size.height

#define zScreenWidth [[UIScreen mainScreen] bounds].size.width

#define zNavigationHeight  64

@interface ViewController ()<UIWebViewDelegate>
@property(nonatomic,strong)UIWebView    *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView = [[UIWebView alloc] init];
    _webView.scalesPageToFit = YES;
    self.webView.frame = CGRectMake(0, 0, zScreenWidth, zScreenHeight);
    self.webView.delegate = self;
    //http://m.youjuke.com/tg/youguanjia.html?putin=yzapp&platform=app
    NSString *url = @"http://m.youjuke.com/tg/youguanjia.html?putin=yzapp&platform=app";
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [self.view addSubview:self.webView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
