//
//  Vgrid.h
//  DemoForCard
//
//  Created by darklinden on 14-9-2.
//  Copyright (c) 2014年 darklinden. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Vgrid;
@protocol VgridDelegate <NSObject>

@optional

@end

#define keyFromPosition(x, y) [NSString stringWithFormat:@"{%ld,%ld}", (long)x, (long)y]

@interface Vgrid : UIView
@property (nonatomic, weak) id<VgridDelegate>       delegate;
@property (nonatomic, copy) NSDictionary            *content;
@property (nonatomic, copy) NSArray                 *route;

+ (id)grid;

@end
