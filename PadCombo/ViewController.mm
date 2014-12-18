//
//  ViewController.m
//  PadCombo
//
//  Created by darklinden on 14-10-8.
//  Copyright (c) 2014年 darklinden. All rights reserved.
//


#import <opencv2/opencv.hpp>
#import "opencv2/highgui/ios.h"
#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "LargeImage.h"
#import "Vgrid.h"
#import "V_loading.h"

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIWebViewDelegate, VgridDelegate>
{
    cv::Mat balls;
}

@property (nonatomic,   weak) IBOutlet UIWebView    *webView;
@property (nonatomic,   weak) IBOutlet UITextField  *pTf_auth;
@property (nonatomic,   weak) IBOutlet UIView       *pV_auth;
@property (nonatomic, strong) Vgrid                 *grid;

@property (nonatomic, strong) NSString              *list;
@property (nonatomic, strong) NSMutableDictionary   *content;
@property (nonatomic, strong) NSMutableArray        *route;

//@property (strong, nonatomic) UIImage               *balls;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIBarButtonItem *loadpic = [[UIBarButtonItem alloc] initWithTitle:@"LoadPic" style:UIBarButtonItemStyleBordered target:self action:@selector(pBtn_show_img_picker_clicked:)];
    self.navigationItem.leftBarButtonItem = loadpic;
    
    UIBarButtonItem *path = [[UIBarButtonItem alloc] initWithTitle:@"Action" style:UIBarButtonItemStyleBordered target:self action:@selector(pBtn_action_clicked:)];
    self.navigationItem.rightBarButtonItem = path;
    
    self.grid = [Vgrid grid];
    _grid.delegate = self;
    [self.view insertSubview:_grid belowSubview:_webView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _grid.frame = CGRectMake(0, self.view.frame.size.height - self.view.frame.size.width, self.view.frame.size.width, self.view.frame.size.width);
}

#pragma mark - pick img
- (void)pBtn_show_img_picker_clicked:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info;
{
    NSLog(@"%@", info);
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self calculateImage:img];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (int64_t)desideBall:(UIImage*)img
{
    if (balls.empty()) {
        UIImage* image = [UIImage imageNamed:@"balls.png"];
        UIImageToMat(image, balls);
    }
    
    //Method: \n 0: SQDIFF \n 1: SQDIFF NORMED \n 2: TM CCORR \n 3: TM CCORR NORMED \n 4: TM COEFF \n 5: TM COEFF NORMED
    const int match_method = CV_TM_SQDIFF_NORMED;
    
    cv::Mat cell;
    UIImageToMat(img, cell);
    
    cv::Mat result;
    
    /// 创建输出结果的矩阵
    int result_cols =  balls.cols - cell.cols + 1;
    int result_rows = balls.rows - cell.rows + 1;
    result.create( result_cols, result_rows, CV_32FC1 );
    
    /// 进行匹配和标准化
    matchTemplate( balls, cell, result, match_method );
    normalize( result, result, 0, 1, cv::NORM_MINMAX, -1, cv::Mat() );
    
    /// 通过函数 minMaxLoc 定位最匹配的位置
    double minVal; double maxVal; cv::Point minLoc; cv::Point maxLoc;
    cv::Point matchLoc;
    
    minMaxLoc( result, &minVal, &maxVal, &minLoc, &maxLoc, cv::Mat() );
    
    /// 对于方法 SQDIFF 和 SQDIFF_NORMED, 越小的数值代表更高的匹配结果. 而对于其他方法, 数值越大匹配越好
    if( match_method  == CV_TM_SQDIFF || match_method == CV_TM_SQDIFF_NORMED )
    { matchLoc = minLoc; }
    else
    { matchLoc = maxLoc; }
    
    /// 让我看看您的最终结果
    int x = matchLoc.x + 50;
    NSLog(@"x: %d y: %d", matchLoc.x, matchLoc.y);
    
    int64_t ret = 0;
    
    if (x >= 0 && x < 100) {
        NSLog(@"火");
        ret = 1;
    }
    else if (x >= 100 && x < 200) {
        NSLog(@"水");
        ret = 3;
    }
    else if (x >= 200 && x < 300) {
        NSLog(@"木");
        ret = 2;
    }
    else if (x >= 300 && x < 400) {
        NSLog(@"光");
        ret = 4;
    }
    else if (x >= 400 && x < 500) {
        NSLog(@"暗");
        ret = 5;
    }
    else if (x >= 500 && x < 600) {
        NSLog(@"回");
        ret = 6;
    }
    else if (x >= 600 && x < 700) {
        NSLog(@"无");
        ret = 7;
    }
    else if (x >= 700 && x < 900) {
        NSLog(@"毒");
        ret = 8;
    }
    
    return ret;
}

- (void)calculateImage:(UIImage *)img
{
    [V_loading loadingInView:nil title:@"Calculating" message:nil loadingBlock:^{
        float w = img.size.width;
        float h = img.size.height;
        float sw = floorf(w / 6.0);
        
        NSMutableString *str = [NSMutableString string];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        for (int64_t x = 0; x < 6; x++) {
            for (int64_t y = 5; y > 0; y--) {
                CGRect rect = CGRectMake(x * sw, h - (y * sw), sw, sw);
                rect = CGRectInset(rect, floorf(sw * 0.2), floorf(sw * 0.2));
                CGSize size = CGSizeMake(50, 50);
                UIImage *ball = [LargeImage imageWithImage:img inRect:rect size:&size errMsg:nil];
//                [LargeImage test_save_image:ball];
                int64_t index = [self desideBall:ball];
                
                dict[keyFromPosition(x, (5 - y))] = @(index);
                [str appendFormat:@"%lld", index];
            }
        }
        
        self.list = str;
        self.content = dict;
        
        _grid.content = dict;
        
        [self performSelector:@selector(requestPath) withObject:nil afterDelay:0.01];
    }];
}

#pragma mark - path
- (void)pBtn_action_clicked:(id)sender {
    
    _grid.route = _route;
    
//    [self requestPath];
    
//    NSString* json = @"{\"status\":\"ok\",\"x\":1,\"y\":3,\"route\":\"311413224142441422231\",\"combo\":[{\"type\":4,\"count\":3},{\"type\":4,\"count\":3},{\"type\":6,\"count\":3},{\"type\":6,\"count\":3},{\"type\":1,\"count\":3},{\"type\":3,\"count\":3},{\"type\":1,\"count\":3}],\"elapsed\":1073,\"quality\":4,\"move\":2}";
//    
//    NSError *error = nil;
//    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
//                                                         options:NSJSONReadingAllowFragments
//                                                           error:&error];
//    
//    if (error) {
//        NSLog(@"%@", error);
//    }
//    else {
//        NSLog(@"%@", dict);
//        
//        [self drawPath:dict];
//    }
//    
//    [_pTf_auth resignFirstResponder];
//
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    [self presentViewController:picker animated:YES completion:nil];
}

- (NSDictionary*)syncRequest:(NSURL*)url error:(NSError **)error
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.13) Gecko/20101206 Ubuntu/10.10 (maverick) Firefox/3.6.13" forHTTPHeaderField:@"User-Agent"];
    [request setTimeoutInterval:3.0];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:error];
    
    if (!data) {
        return nil;
    }
    
    if (error) {
        *error = nil;
    }
    
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    json = [self getJson:json];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:NSJSONReadingAllowFragments
                                                           error:error];
    return dict;
}

- (void)requestPath
{
    NSString *url = [NSString stringWithFormat:@"http://pad.forrep.com/api/resolve?field=%@&move=2", _list];
    [V_loading loadingInView:nil title:@"Request Path ..." message:nil loadingBlock:^{
        NSDictionary* dict = [self syncRequest:[NSURL URLWithString:url] error:nil];
        
        if ([[dict[@"status"] lowercaseString] isEqualToString:@"unauthorized"]) {
            [self performSelector:@selector(auth) withObject:nil afterDelay:0.01];
        }
        else {
            [self drawPath:dict];
        }
    }];
}

- (void)drawPath:(NSDictionary* )route
{
    NSMutableArray *array = [NSMutableArray array];
    
    int64_t x = [route[@"x"] longLongValue];
    int64_t y = [route[@"y"] longLongValue];
    
    [array addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    
    int64_t lastOperation;
    
    NSString* s_route = route[@"route"];
    for (int64_t i = 0; i < s_route.length; i++) {
        lastOperation = [[s_route substringWithRange:NSMakeRange(i, 1)] longLongValue];
        switch (lastOperation) {
            case 1:
                --y;
                break;
            case 2:
                ++y;
                break;
            case 3:
                --x;
                break;
            case 4:
                ++x;
                break;
        }
        NSLog(@"x: %lld y: %lld", x, y);
        
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    
    _route = array;
}

- (void)auth
{
    _webView.hidden = NO;
    [V_loading showLoadingView:nil title:@"Pepare Auth ..." message:nil];
    [_pTf_auth resignFirstResponder];
    _pV_auth.hidden = YES;
    
    NSString *authImgUrl = [NSString stringWithFormat:@"http://pad.forrep.com/api/captcha?reload&%ld", (long)floorf([[NSDate date] timeIntervalSince1970] * 1000)];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:authImgUrl]];
    [_webView loadRequest:request];
}

- (IBAction)pBtn_load_clicked:(id)sender
{
    [_pTf_auth resignFirstResponder];
    
    NSString *authImgUrl = [NSString stringWithFormat:@"http://pad.forrep.com/api/captcha/answer?answer=%@", _pTf_auth.text];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:authImgUrl]];
    [_webView loadRequest:request];
}

- (NSString *)getJson:(NSString *)src
{
    NSString *str = [src copy];
    NSRange r = [str rangeOfString:@">" options:NSLiteralSearch];
    
    if (r.location != NSNotFound && r.location < str.length) {
        str = [str substringFromIndex:r.location + 1];
    }
    
    r = [str rangeOfString:@"<" options:NSBackwardsSearch];
    if (r.location != NSNotFound && r.location < str.length && r.location > 0) {
        str = [str substringToIndex:r.location];
    }
    
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return str;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@, %@", webView.request.URL.absoluteString, error);
    [V_loading removeLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [V_loading removeLoading];
    //"captcha?reload"
    if ([webView.request.URL.absoluteString rangeOfString:@"captcha?reload"].location != NSNotFound) {
        NSLog(@"auth image");
        NSLog(@"%@",
              [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"]);
        _pV_auth.hidden = NO;
    }
    
    //"captcha/answer"
    else if ([webView.request.URL.absoluteString rangeOfString:@"captcha/answer"].location != NSNotFound) {
        NSLog(@"auth status");
        NSLog(@"%@",
              [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"]);
        _pV_auth.hidden = YES;
        _webView.hidden = YES;
        
        NSString *json = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
        json = [self getJson:json];
        
        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
        else {
            NSLog(@"%@", dict);
            
            if ([[dict[@"status"] lowercaseString] isEqualToString:@"ok"]) {
                [self requestPath];
            }
            else {
                [self performSelector:@selector(auth) withObject:nil afterDelay:0.01];
            }
        }
    }
    
    else {
//        //        NSLog(@"%@", [_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"]);
//        
//        //        [webView stringByEvaluatingJavaScriptFromString:@"var fs = document.getElementById('field_string');"
//        //         "fs.style = 'display: true;';"];
//        
//        NSString *change = [NSString stringWithFormat:@"var fs = document.getElementById('field_string');"
//                            "fs.value = '%@';", _list];
//        [webView stringByEvaluatingJavaScriptFromString:change];
//        
//        //        NSLog(@"%@", [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('field_string').value"]);
//        NSString *json = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
//        json = [self getJson:json];
//        
//        NSError *error = nil;
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
//                                                             options:NSJSONReadingAllowFragments
//                                                               error:&error];
//        
//        if (error) {
//            NSLog(@"%@", error);
//        }
//        else {
//            NSLog(@"%@", dict);
//            
//            //        if(data.status == "unauthorized")
//            
//            [self drawPath:dict];
//        }
    }
}

@end
