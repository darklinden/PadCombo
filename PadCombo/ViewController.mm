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

const static int adjustWindow = 2;

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIWebViewDelegate> {
    cv::Mat balls;
}

@property (nonatomic,   weak) IBOutlet UIWebView    *webView;
@property (nonatomic,   weak) IBOutlet UITextField  *pTf_auth;
@property (nonatomic,   weak) IBOutlet UIView       *pV_auth;
//@property (strong, nonatomic) UIImage               *balls;
@property (strong, nonatomic) NSString              *list;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIBarButtonItem *auth = [[UIBarButtonItem alloc] initWithTitle:@"Auth" style:UIBarButtonItemStyleBordered target:self action:@selector(pBtn_auth_show_img_clicked:)];
    self.navigationItem.leftBarButtonItem = auth;
    
    UIBarButtonItem *path = [[UIBarButtonItem alloc] initWithTitle:@"Path" style:UIBarButtonItemStyleBordered target:self action:@selector(pBtn_get_path_clicked:)];
    self.navigationItem.rightBarButtonItem = path;
}

- (void)pBtn_get_path_clicked:(id)sender {
    NSString* json = @"{\"status\":\"ok\",\"x\":1,\"y\":3,\"route\":\"311413224142441422231\",\"combo\":[{\"type\":4,\"count\":3},{\"type\":4,\"count\":3},{\"type\":6,\"count\":3},{\"type\":6,\"count\":3},{\"type\":1,\"count\":3},{\"type\":3,\"count\":3},{\"type\":1,\"count\":3}],\"elapsed\":1073,\"quality\":4,\"move\":2}";
    
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:NSJSONReadingAllowFragments
                                                           error:&error];
    
    if (error) {
        NSLog(@"%@", error);
    }
    else {
        NSLog(@"%@", dict);
        
        [self drawPath:dict];
    }
    
    [_pTf_auth resignFirstResponder];
//
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    [self presentViewController:picker animated:YES completion:nil];
}

- (void)pBtn_auth_show_img_clicked:(id)sender {
    
    [_pTf_auth resignFirstResponder];
    
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

- (int8_t)desideBall:(UIImage*)img
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
    
    int8_t ret = 0;
    
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
    float w = img.size.width;
    float h = img.size.height;
    float sw = floorf(w / 6.0);
    
    NSMutableString *str = [NSMutableString string];
    
    for (int8_t x = 0; x < 6; x++) {
        for (int8_t y = 5; y > 0; y--) {
            CGRect rect = CGRectMake(x * sw, h - (y * sw), sw, sw);
            rect = CGRectInset(rect, floorf(sw * 0.2), floorf(sw * 0.2));
            CGSize size = CGSizeMake(50, 50);
            UIImage *ball = [LargeImage imageWithImage:img inRect:rect size:&size errMsg:nil];
            [LargeImage test_save_image:ball];
            [str appendFormat:@"%d",
             [self desideBall:ball]];
        }
    }
    
    self.list = str;
    
    NSLog(@"%@", str);
    
    NSString *url = [NSString stringWithFormat:@"http://pad.forrep.com/api/resolve?field=%@&move=2", _list];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    
    //style="display: none;"
    
    
    //    [_webView reload];
    
    //    NSString *url = @"http://pad.forrep.com";
    //    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

int64_t adjust()
{
    return floor((double)random() / (double)RAND_MAX * (adjustWindow * 2 + 1));
}

int64_t adjustPixel(int64_t adjust)
{
    return (adjust - adjustWindow) * 7;
}

- (NSDictionary* )getRouteAdjust:(NSDictionary*)route
{
    NSMutableDictionary* foundRoute = [NSMutableDictionary dictionary];
    int64_t width = adjustWindow * 2 + 1;
    int64_t minConflict = 999;
    
    for (int64_t trys = 0; trys < 100; ++trys) {
        NSMutableDictionary* intField = [NSMutableDictionary dictionary];
        for (int64_t x = 0; x < width * 6; ++x) {
            intField[@(x)] = [NSMutableDictionary dictionary];
            for (int64_t y = 0; y < width * 5; ++y) {
                intField[@(x)][@(y)] = @(0);
            }
        }
        
        int64_t startAdjustX = adjust();
        int64_t startAdjustY = adjust();
        int64_t currentAdjustX = startAdjustX;
        int64_t currentAdjustY = startAdjustY;
        
        NSMutableArray* adjustX = [NSMutableArray array];
        NSMutableArray* adjustY = [NSMutableArray array];
        
        int64_t pointX = [route[@"x"] longLongValue];
        int64_t pointY = [route[@"y"] longLongValue];
        
        int64_t currentX = pointX * width + currentAdjustX;
        int64_t currentY = pointY * width + currentAdjustY;
        
        NSString* s_route = route[@"route"];
        for (int64_t i = 0; i < s_route.length; i++) {
            int64_t process = [[s_route substringWithRange:NSMakeRange(i, 1)] longLongValue];
            switch (process) {
                case '1': // up
                --pointY;
                currentAdjustY = adjust();
                break;
                case '2': // down
                ++pointY;
                currentAdjustY = adjust();
                break;
                case '3': // left
                --pointX;
                currentAdjustX = adjust();
                break;
                case '4': // right
                ++pointX;
                currentAdjustX = adjust();
                break;
            }
            
            [adjustX addObject:@(currentAdjustX)];
            [adjustY addObject:@(currentAdjustY)];
            
            int64_t endX = pointX * width + currentAdjustX;
            int64_t endY = pointY * width + currentAdjustY;
            int64_t moveX = endX - currentX;
            
            if (moveX > 0) {
                moveX = 1;
            } else if (moveX < 0) {
                moveX = -1;
            }
            
            int64_t moveY = endY - currentY;
            if (moveY > 0) {
                moveY = 1;
            } else if (moveY < 0) {
                moveY = -1;
            }
            
            for (int64_t x = currentX, y = currentY; x != endX || y != endY; x += moveX, y += moveY) {
                int64_t tmp = [intField[@(x)][@(y)] longLongValue];
                ++tmp;
                intField[@(x)][@(y)] = @(tmp);
            }
            
            currentX = endX;
            currentY = endY;
        }
        
        int64_t conflict = 0;
        for (int64_t x = 0; x < width * 6; ++x) {
            for (int64_t y = 0; y < width * 5; ++y) {
                int64_t value = [intField[@(x)][@(y)] longLongValue];
                conflict += value > 1 ? value - 1 : 0;
            }
        }
        
        if (minConflict > conflict) {
            foundRoute[@"startAdjustX"] = @(startAdjustX);
            foundRoute[@"startAdjustY"] = @(startAdjustY);
            foundRoute[@"adjustX"] = adjustX;
            foundRoute[@"adjustY"] = adjustY;
            minConflict = conflict;
        }
        
        if (minConflict <= 0) {
            break;
        }
    }
    
    return foundRoute;
}

- (void)drawPath:(NSDictionary* )route
{
    int64_t x = [route[@"x"] longLongValue];
    int64_t y = [route[@"y"] longLongValue];
    
//    NSDictionary* adjusts = [self getRouteAdjust:route];
//    int64_t adjustX = adjustPixel([adjusts[@"startAdjustX"] longLongValue]);
//    int64_t adjustY = adjustPixel([adjusts[@"startAdjustY"] longLongValue]);
//    
//    int64_t lastX = 0;
//    int64_t lastY = 0;
    int64_t lastOperation;
//
//    //    routeCtx.beginPath();
//    //    routeCtx.fillStyle = 'rgb(0, 0, 0)';
//    //    routeCtx.arc(x * dropSize * 2 + dropSize + adjustX, y * dropSize * 2 + dropSize + adjustY, dropSize / 10, 0, Math.PI * 2, false);
//    //    routeCtx.fill();
//    
//    //    routeCtx.beginPath();
//    int64_t dropSize = 1;
//    NSLog(@"x: %lld y: %lld", x * dropSize * 2 + dropSize + adjustX, y * dropSize * 2 + dropSize + adjustY);
    //    routeCtx.moveTo(x * dropSize * 2 + dropSize + adjustX, y * dropSize * 2 + dropSize + adjustY);
    NSString* s_route = route[@"route"];
    for (int64_t i = 0; i < s_route.length; i++) {
        lastOperation = [[s_route substringWithRange:NSMakeRange(i, 1)] longLongValue];
        switch (lastOperation) {
            case 1:
            --y;
            //            adjustY = adjustPixel([adjusts[@"adjustY"][i] longLongValue]);
            break;
            case 2:
            ++y;
            //            adjustY = adjustPixel([adjusts[@"adjustY"][i] longLongValue]);
            break;
            case 3:
            --x;
            //            adjustX = adjustPixel([adjusts[@"adjustX"][i] longLongValue]);
            break;
            case 4:
            ++x;
            //            adjustX = adjustPixel([adjusts[@"adjustX"][i] longLongValue]);
            break;
        }
        
//        lastX = x * dropSize * 2 + dropSize + adjustX;
//        lastY = y * dropSize * 2 + dropSize + adjustY;
        //        routeCtx.lineTo(lastX, lastY);
        NSLog(@"x: %lld y: %lld", x, y);
    }
    //    routeCtx.stroke();
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
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
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
        }
    }
    
    else {
        //        NSLog(@"%@", [_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"]);
        
        //        [webView stringByEvaluatingJavaScriptFromString:@"var fs = document.getElementById('field_string');"
        //         "fs.style = 'display: true;';"];
        
        NSString *change = [NSString stringWithFormat:@"var fs = document.getElementById('field_string');"
                            "fs.value = '%@';", _list];
        [webView stringByEvaluatingJavaScriptFromString:change];
        
        //        NSLog(@"%@", [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('field_string').value"]);
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
            
            
            
            [self drawPath:dict];
        }
    }
}

@end
