//
//  FilteredProtocol.m
//  NSURLProtocolTest
//
//  Created by 余晔 on 2017/4/10.
//  Copyright © 2017年 余晔. All rights reserved.
//

#import "FilteredProtocol.h"
#import <UIKit/UIKit.h>

static NSString*const sourIconUrl  = @"http://m.baidu.com/static/search/baiduapp_icon.png";
static NSString*const sourUrl  = @"https://m.baidu.com/static/index/plus/plus_logo.png";
static NSString*const localUrl = @"http://mecrm.qa.medlinker.net/public/image?id=57026794&certType=workCertPicUrl&time=1484625241";
static NSString* const KHybridNSURLProtocolHKey = @"KHybridNSURLProtocol";
@interface FilteredProtocol ()<NSURLSessionDelegate>
@property (nonnull,strong) NSURLSessionDataTask *task;

@end

@implementation FilteredProtocol



//这个方法是决定这个 protocol 是否可以处理传入的 request 的如是返回 true 就代表可以处理,如果返回 false 那么就不处理这个 request 。
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
//    NSLog(@"request.URL.absoluteString = %@",request.URL.absoluteString);
//    if([NSURLProtocol propertyForKey:KHybridNSURLProtocolHKey inRequest:request]){
//        return NO;
//    }
//    return YES;
    NSLog(@"request.URL.absoluteString = %@",request.URL.absoluteString);
    NSString *scheme = [[request URL] scheme];
    if ( ([scheme caseInsensitiveCompare:@"http"]  == NSOrderedSame ||
          [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame ))
    {
        //看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:KHybridNSURLProtocolHKey inRequest:request])
            return NO;
        return YES;
    }
    return NO;
}


//这个方法主要是用来返回格式化好的request，如果自己没有特殊需求的话，直接返回当前的request就好了。如果你想做些其他的，比如地址重定向，或者请求头的重新设置，你可以copy下这个request然后进行设置。
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
//    NSLog(@"all request.URL.absoluteString = %@",request.URL.absoluteString);
    NSLog(@"request.URL.host = %@",request.URL.host);
    NSString *originHostString = request.URL.host;
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    
//    //request截取重定向
//    if ([request.URL.absoluteString isEqualToString:sourUrl])
//    {
//        NSURL* url1 = [NSURL URLWithString:localUrl];
//        mutableReqeust = [NSMutableURLRequest requestWithURL:url1];
//    }
    
    if(![originHostString isEqualToString:@"m.youjuke.com"]){
        NSURL* url1 = [NSURL URLWithString:localUrl];
        mutableReqeust = [NSMutableURLRequest requestWithURL:url1];
    }
    
    return mutableReqeust;
}


//该方法主要是判断两个请求是否为同一个请求，如果为同一个请求那么就会使用缓存数据。通常都是调用父类的该方法。
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}


//开始处理这个请求和结束处理这个请求
- (void)startLoading
{
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    //给我们处理过的请求设置一个标识符, 防止无限循环,
    [NSURLProtocol setProperty:@YES forKey:KHybridNSURLProtocolHKey inRequest:mutableReqeust];
    
    //这里最好加上缓存判断，加载本地离线文件， 这个直接简单的例子。
    if ([mutableReqeust.URL.absoluteString isEqualToString:sourIconUrl])
    {
        NSData* data = UIImagePNGRepresentation([UIImage imageNamed:@"medlinker"]);
        NSURLResponse* response = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:@"image/png" expectedContentLength:data.length textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else
    {
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
        self.task = [session dataTaskWithRequest:self.request];
        [self.task resume];
    }

}

- (void)stopLoading
{
    if (self.task != nil)
    {
        [self.task  cancel];
//        self.task = nil;
    }
}



//client  一个协议,里面的方法和NSURLConnection 差不多

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    [self.client URLProtocolDidFinishLoading:self];
}

@end
