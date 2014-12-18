//
//  Vgrid.m
//  DemoForCard
//
//  Created by darklinden on 14-9-2.
//  Copyright (c) 2014年 darklinden. All rights reserved.
//

#import "Vgrid.h"
#import "LargeImage.h"
#import <CoreGraphics/CoreGraphics.h>

#define Grid_Distance   0.f
#define Grid_x_count    6
#define Grid_y_count    5

#define Cell_Offset     20

@interface DrawView : UIView
@property (nonatomic, copy) NSArray *route;

+ (instancetype)viewWithFrame:(CGRect)frame Route:(NSArray *)route;

@end

@implementation DrawView

+ (instancetype)viewWithFrame:(CGRect)frame Route:(NSArray *)route
{
    DrawView* v = [[DrawView alloc] initWithFrame:frame];
    v.backgroundColor = [UIColor clearColor];
    v.route = route;
    return v;
}

- (void)drawRect:(CGRect)rect
{
    if (_route.count < 2) {
        return;
    }
    
    CGContextRef contxt = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(contxt, 3);
    CGContextSetStrokeColorWithColor(contxt, [UIColor blackColor].CGColor);
    
    for (int i = 0; i < _route.count - 1; i++) {
        CGPoint start = [_route[i] CGPointValue];
        CGPoint end = [_route[i + 1] CGPointValue];
        CGContextMoveToPoint(contxt, start.x, start.y);
        CGContextAddLineToPoint(contxt, end.x, end.y);
    }
    
    CGContextStrokePath(contxt);
    
    //draw arrow
    CGPoint start = [_route[_route.count - 2] CGPointValue];
    CGPoint end = [_route[_route.count - 1] CGPointValue];
    
    if (start.x == end.x) {
        CGContextMoveToPoint(contxt, end.x, end.y);
        CGContextAddLineToPoint(contxt, end.x + 10, end.y > start.y ? end.y - 10 : end.y + 10);
        
        CGContextMoveToPoint(contxt, end.x, end.y);
        CGContextAddLineToPoint(contxt, end.x - 10, end.y > start.y ? end.y - 10 : end.y + 10);
    }
    else {
        CGContextMoveToPoint(contxt, end.x, end.y);
        CGContextAddLineToPoint(contxt, end.x > start.x ? end.x - 10 : end.x + 10, end.y + 10);
        
        CGContextMoveToPoint(contxt, end.x, end.y);
        CGContextAddLineToPoint(contxt, end.x > start.x ? end.x - 10 : end.x + 10, end.y - 10);
    }
    CGContextStrokePath(contxt);
}

@end

@interface Vcell : UIImageView
@property (nonatomic, strong) NSString  *key;

+ (instancetype)cellWithFrame:(CGRect)frame;

@end

@implementation Vcell

+ (instancetype)cellWithFrame:(CGRect)frame
{
    Vcell* cell = [[Vcell alloc] initWithFrame:frame];
    cell.contentMode = UIViewContentModeScaleAspectFill;
    cell.backgroundColor = [UIColor clearColor];
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = frame.size.width * 0.2;
    return cell;
}

@end

@interface Vgrid ()
@property (nonatomic, strong) NSMutableDictionary   *dict_cell;
@property (nonatomic, strong) NSMutableDictionary   *dict_frame;

@property (nonatomic, strong) Vcell                 *cell_pickup;
@property (nonatomic,   weak) Vcell                 *cell_current;

@property (nonatomic, strong) UIImage               *img_fire;
@property (nonatomic, strong) UIImage               *img_wood;
@property (nonatomic, strong) UIImage               *img_water;
@property (nonatomic, strong) UIImage               *img_light;
@property (nonatomic, strong) UIImage               *img_dark;
@property (nonatomic, strong) UIImage               *img_heal;
@property (nonatomic, strong) UIImage               *img_invalid;
@property (nonatomic, strong) UIImage               *img_poison;

@property (nonatomic, assign) int64_t               index;

@property (nonatomic, strong) DrawView              *drawView;

@end

@implementation Vgrid

+ (id)grid
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    Vgrid *grid = [[Vgrid alloc] initWithFrame:CGRectMake(0.f, 0.f, size.width, size.width)];
    grid.backgroundColor = [UIColor clearColor];
//    [grid setup];
    return grid;
}

- (UIImage *)imgWithIndex:(int64_t)index
{
    CGRect rect;
    UIImage *img = [UIImage imageNamed:@"balls.png"];
    CGSize size = CGSizeMake(100, 100);
    
    switch (index) {
        case 1:
        {
            if (!_img_fire) {
                rect = CGRectMake(0, 0, 100, 100);
                _img_fire = [LargeImage imageWithImage:img inRect:rect size:&size errMsg:nil];
            }
            return _img_fire;
        }
            break;
        case 2:
        {
            if (!_img_wood) {
                rect = CGRectMake(200, 0, 100, 100);
                _img_wood = [LargeImage imageWithImage:img inRect:rect size:&size errMsg:nil];
            }
            return _img_wood;
        }
            break;
        case 3:
        {
            if (!_img_water) {
                rect = CGRectMake(100, 0, 100, 100);
                _img_water = [LargeImage imageWithImage:img inRect:rect size:&size errMsg:nil];
            }
            return _img_water;
        }
            break;
        case 4:
        {
            if (!_img_light) {
                rect = CGRectMake(300, 0, 100, 100);
                _img_light = [LargeImage imageWithImage:img inRect:rect size:&size errMsg:nil];
            }
            return _img_light;
        }
            break;
        case 5:
        {
            if (!_img_dark) {
                rect = CGRectMake(400, 0, 100, 100);
                _img_dark = [LargeImage imageWithImage:img inRect:rect size:&size errMsg:nil];
            }
            return _img_dark;
        }
            break;
        case 6:
        {
            if (!_img_heal) {
                rect = CGRectMake(500, 0, 100, 100);
                _img_heal = [LargeImage imageWithImage:img inRect:rect size:&size errMsg:nil];
            }
            return _img_heal;
        }
            break;
        case 7:
        {
            if (!_img_invalid) {
                rect = CGRectMake(600, 0, 100, 100);
                _img_invalid = [LargeImage imageWithImage:img inRect:rect size:&size errMsg:nil];
            }
            return _img_invalid;
        }
            break;
        case 8:
        {
            if (!_img_poison) {
                rect = CGRectMake(700, 0, 100, 100);
                _img_poison = [LargeImage imageWithImage:img inRect:rect size:&size errMsg:nil];
            }
            return _img_poison;
        }
            break;
        default:
            NSLog(@"index %lld not allowed", index);
            NSAssert(0, @"");
            break;
    }
    
    return nil;
}

- (void)setContent:(NSDictionary *)content
{
    _content = [content copy];
    NSLog(@"%@", content);
    [self setup];
}

- (void)setRoute:(NSArray *)route
{
    _route = [route copy];
    
    [self route_animate];
}

- (void)setup
{
    for (UIView * v in self.subviews) {
        [v removeFromSuperview];
    }
    
    CGSize size = CGSizeMake(floorf(self.frame.size.width / Grid_x_count), floorf(self.frame.size.width / Grid_x_count));
    
    self.dict_cell = [NSMutableDictionary dictionary];
    self.dict_frame = [NSMutableDictionary dictionary];
    
    for (NSInteger ix = 0; ix < Grid_x_count; ix++) {
        for (NSInteger iy = 0; iy < Grid_y_count; iy++) {
            CGFloat x = ix * (size.width + Grid_Distance) + Grid_Distance;
            CGFloat y = iy * (size.height + Grid_Distance) + Grid_Distance;
            CGRect rect = CGRectMake(x, y, size.width, size.height);
            
            Vcell *cell = [Vcell cellWithFrame:rect];
            [self addSubview:cell];
            
            NSString *key = keyFromPosition(ix, iy);
            cell.key = key;
            cell.image = [self imgWithIndex:[_content[key] longLongValue]];
            
            [_dict_cell setObject:cell forKey:key];
            [_dict_frame setObject:[NSValue valueWithCGRect:rect] forKey:key];
        }
    }
}

- (void)route_animate
{
    _index = 0;
    [self refresh];
    [self draw_path];
    [self route_one_by_one];
}

float frand()
{
    return ((float)rand() - ((float)RAND_MAX) * 0.5) / (float)RAND_MAX;
}

- (void)draw_path
{
    //bring
    CGPoint cp = [_route[_index] CGPointValue];
    Vcell* current = _dict_cell[keyFromPosition(cp.x, cp.y)];
    current.backgroundColor = [UIColor redColor];
    [self bringSubviewToFront:current];
    
    if (self.drawView) {
        [_drawView removeFromSuperview];
        self.drawView = nil;
    }
    
    NSMutableArray* array = [NSMutableArray array];
    for (int i = 0; i < _route.count; i++) {
        if (i == 0) {
            CGPoint p = [_route[i] CGPointValue];
            
            CGRect r = [_dict_frame[keyFromPosition(p.x, p.y)] CGRectValue];
            
            CGPoint rp = CGPointMake(r.origin.x + (r.size.width * 0.5),
                                     r.origin.y + (r.size.height * 0.5));
            
            [array addObject:[NSValue valueWithCGPoint:rp]];
        }
        else {
            CGPoint lp = [_route[i - 1] CGPointValue];
            CGPoint p = [_route[i] CGPointValue];
            CGRect r = [_dict_frame[keyFromPosition(p.x, p.y)] CGRectValue];
            
            if (lp.x == p.x) {
                CGPoint rp = CGPointMake([array[i - 1] CGPointValue].x,
                                         r.origin.y + (r.size.height * 0.5) + (frand() * r.size.height * 0.8));
                [array addObject:[NSValue valueWithCGPoint:rp]];
            }
            else {
                CGPoint rp = CGPointMake(r.origin.x + (r.size.width * 0.5) + (frand() * r.size.width * 0.8),
                                         [array[i - 1] CGPointValue].y);
                [array addObject:[NSValue valueWithCGPoint:rp]];
            }
        }
    }
    
    _drawView = [DrawView viewWithFrame:self.bounds Route:array];
    
    [self addSubview:_drawView];
}

- (void)route_one_by_one
{
    if (_index < _route.count - 1) {
        CGPoint cp = [_route[_index] CGPointValue];
        CGPoint np = [_route[_index + 1] CGPointValue];
        
        Vcell* current = _dict_cell[keyFromPosition(cp.x, cp.y)];
        Vcell* next = _dict_cell[keyFromPosition(np.x, np.y)];
        
        CGRect cr = [_dict_frame[keyFromPosition(cp.x, cp.y)] CGRectValue];
        CGRect nr = [_dict_frame[keyFromPosition(np.x, np.y)] CGRectValue];
        
        if (_index == 0) {
            [UIView animateWithDuration:0.5 animations:^{
                current.alpha = 0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5 animations:^{
                    current.alpha = 1;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.5 animations:^{
                        current.alpha = 0;
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.5 animations:^{
                            current.alpha = 1;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:0.5 animations:^{
                                current.frame = nr;
                                next.frame = cr;
                            } completion:^(BOOL finished) {
                                next.key = keyFromPosition(cp.x, cp.y);
                                _dict_cell[keyFromPosition(cp.x, cp.y)] = next;
                                current.key = keyFromPosition(np.x, np.y);
                                _dict_cell[keyFromPosition(np.x, np.y)] = current;
                                
                                _index++;
                                [self performSelector:@selector(route_one_by_one) withObject:nil afterDelay:0.01];
                            }];
                        }];
                    }];
                }];
            }];
        }
        else {
            [UIView animateWithDuration:0.5 animations:^{
                current.frame = nr;
                next.frame = cr;
            } completion:^(BOOL finished) {
                next.key = keyFromPosition(cp.x, cp.y);
                _dict_cell[keyFromPosition(cp.x, cp.y)] = next;
                current.key = keyFromPosition(np.x, np.y);
                _dict_cell[keyFromPosition(np.x, np.y)] = current;
                
                _index++;
                [self performSelector:@selector(route_one_by_one) withObject:nil afterDelay:0.01];
            }];
        }
    }
    else {
        
    }
}

- (void)refresh
{
    for (UIView* v in self.subviews) {
        if ([v isKindOfClass:[Vcell class]]) {
            Vcell* cell = (Vcell*)v;
            cell.backgroundColor = [UIColor clearColor];
            _dict_cell[cell.key] = cell;
            cell.image = [self imgWithIndex:[_content[cell.key] longLongValue]];
            cell.frame = [_dict_frame[cell.key] CGRectValue];
        }
    }
}

- (Vcell *)viewFromTouchPoint:(CGPoint)p
{
    Vcell *cell = nil;
    
    for (NSString *key in _dict_cell.allKeys) {
        NSLog(@"%@", key);
        UIView *v = _dict_cell[key];
        if (CGRectContainsPoint(v.frame, p)) {
            cell = (Vcell *)v;
            break;
        }
    }
    
    return cell;
}

- (CGRect)frameFromTouchPoint:(CGPoint)p
{
    CGRect rect;
    
    for (NSString *key in _dict_frame.allKeys) {
        NSValue *v = _dict_frame[key];
        if (CGRectContainsPoint(v.CGRectValue, p)) {
            rect = v.CGRectValue;
            break;
        }
    }
    
    return rect;
}

- (void)putDownCurrentCell
{
//    [_cell_pickup removeFromSuperview];
//    _cell_current.alpha = 1.f;
//    
//    _cell_pickup = nil;
//    _cell_current = nil;
}

- (void)pickUpCurrentCellWithPoint:(CGPoint)p
{
//    if (_cell_pickup) {
//        [_cell_pickup removeFromSuperview];
//        _cell_pickup = nil;
//    }
//    
//    _cell_current.alpha = 0.5f;
//    
//    _cell_pickup = [_cell_current copy];
//    [self addSubview:_cell_pickup];
//    
//    [_cell_pickup setAlpha:0.7];
//    _cell_pickup.transform = CGAffineTransformMakeScale(1.2, 1.2);
//    _cell_pickup.center = CGPointMake(p.x - Cell_Offset, p.y - Cell_Offset);
}

- (void)moveCurrentCellToPoint:(CGPoint)p
{
//    if (CGRectContainsPoint(_cell_current.frame, p)) {
//        _cell_pickup.center = CGPointMake(p.x - Cell_Offset, p.y - Cell_Offset);
//    }
//    else {
//        Vcell *des_cell = [self viewFromTouchPoint:p];
//        Vcell *src_cell = _cell_current;
//        
//        if (des_cell) {
//            if (!des_cell.destroyed) {
//                
//                NSString *des_key = [des_cell.key copy];
//                NSString *src_key = [_cell_current.key copy];
//                
//                CGPoint des_position = [Vcell positionFromKey:des_key];
//                CGPoint src_position = [Vcell positionFromKey:src_key];
//                
//                BOOL moveable = NO;
//                
//                //move up
//                if (des_position.x == src_position.x
//                    && des_position.y < src_position.y) {
//                    
//                    des_position = CGPointMake(src_position.x, src_position.y - 1);
//                    des_key = [Vcell keyFromPosition:des_position];
//                    des_cell = [_dict_cell objectForKey:des_key];
//                    
//                    if (des_cell.iBottom < src_cell.iTop && des_cell.iBottom != Top_Limit) {
//                        src_cell.bEatenTop = YES;
//                        moveable = YES;
//                    }
//                }
//                //move down
//                else if (des_position.x == src_position.x
//                    && des_position.y > src_position.y) {
//                    
//                    des_position = CGPointMake(src_position.x, src_position.y + 1);
//                    des_key = [Vcell keyFromPosition:des_position];
//                    des_cell = [_dict_cell objectForKey:des_key];
//                    
//                    if (des_cell.iTop < src_cell.iBottom && des_cell.iTop != Top_Limit) {
//                        src_cell.bEatenBottom = YES;
//                        moveable = YES;
//                    }
//                }
//                //move left
//                else if (des_position.y == src_position.y
//                         && des_position.x < src_position.x) {
//                    
//                    des_position = CGPointMake(src_position.x - 1, src_position.y);
//                    des_key = [Vcell keyFromPosition:des_position];
//                    des_cell = [_dict_cell objectForKey:des_key];
//                    
//                    if (des_cell.iRight < src_cell.iLeft && des_cell.iRight != Top_Limit) {
//                        src_cell.bEatenLeft = YES;
//                        moveable = YES;
//                    }
//                }
//                //move right
//                else if (des_position.y == src_position.y
//                         && des_position.x > src_position.x) {
//                    
//                    des_position = CGPointMake(src_position.x + 1, src_position.y);
//                    des_key = [Vcell keyFromPosition:des_position];
//                    des_cell = [_dict_cell objectForKey:des_key];
//                    
//                    if (des_cell.iLeft < src_cell.iRight && des_cell.iRight != Top_Limit) {
//                        src_cell.bEatenRight = YES;
//                        moveable = YES;
//                    }
//                }
//                
//                if (moveable) {
//                    des_cell.destroyed = YES;
//                    _move_length++;
//                    
//                    if (_delegate) {
//                        if ([_delegate respondsToSelector:@selector(gridMoving:combo:)]) {
//                            [_delegate gridMoving:self combo:_move_length];
//                        }
//                    }
//                    
//                    _cell_pickup.center = CGPointMake(p.x - Cell_Offset, p.y - Cell_Offset);
//                    
//                    _cell_current.key = des_key;
//                    _cell_pickup.key = des_key;
//                    [_dict_cell setObject:_cell_current forKey:des_key];
//                    [_cell_current setFrame:[[_dict_frame objectForKey:des_key] CGRectValue]];
//                    
//                    des_cell.key = src_key;
//                    [_dict_cell setObject:des_cell forKey:src_key];
//                    [des_cell setFrame:[[_dict_frame objectForKey:src_key] CGRectValue]];
//                }
//            }
//        }
//    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    if (_cell_pickup || _cell_current) {
//        [self putDownCurrentCell];
//        return;
//    }
//    
//    if (touches.count != 1) {
//        return;
//    }
//    
//    UITouch *t = [touches anyObject];
//    CGPoint p = [t locationInView:self];
//    
//    _cell_current = [self viewFromTouchPoint:p];
//    
//    if (!_cell_current.destroyed && _cell_current.pickupable) {
//        [self pickUpCurrentCellWithPoint:p];
//    }
//    else {
//        _cell_pickup = nil;
//        _cell_current = nil;
//    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    if (!_cell_pickup || !_cell_current) {
//        return;
//    }
//    
//    if (touches.count != 1) {
//        return;
//    }
//    
//    UITouch *t = [touches anyObject];
//    CGPoint p = [t locationInView:self];
//    
//    [self moveCurrentCellToPoint:p];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    if (touches.count != 1) {
//        if (_cell_pickup || _cell_current) {
//            [self putDownCurrentCell];
//            return;
//        }
//        return;
//    }
//    
//    UITouch *t = [touches anyObject];
//    CGPoint p = [t locationInView:self];
//    
//    if (_cell_pickup || _cell_current) {
//        [self moveCurrentCellToPoint:p];
//        [self putDownCurrentCell];
//    }
//    
//    [self performSelector:@selector(refresh_eaten_cell) withObject:nil afterDelay:0.01];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [self touchesEnded:touches withEvent:event];
}

- (void)refresh_eaten_cell
{
//    if (_move_length > 0) {
//        _move_count--;
//    }
//    
//    if (_move_length >= 3) {
//        _move_count += floor(_move_length / 3);
//    }
//    
//    _move_length = 0;
//    
//    if (_delegate) {
//        if ([_delegate respondsToSelector:@selector(gridDidMove:)]) {
//            [_delegate gridDidMove:self];
//        }
//    }
//    
//    for (NSString *key in _dict_cell.allKeys) {
//        Vcell *cell = _dict_cell[key];
//        
//        if (cell.destroyed) {
//            [cell random_values];
//            [UIView animateWithDuration:0.3 animations:^{
//                cell.destroyed = NO;
//            }];
//        }
//    }
}

@end
