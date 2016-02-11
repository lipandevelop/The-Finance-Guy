//
//  DrawingTool.m
//  StockLine
//
//  Created by Li Pan on 2016-02-08.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "GraphTool.h"
#import "Stock.h"
#import "Coordinate.h"

@interface GraphTool ()

@property (nonatomic, assign) CGContextRef context;
@property (nonatomic, strong) Stock *stock;

@end

@implementation GraphTool
static const float kYOffset = 500;
static const float kStockPriceRange = 100;


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.stock = [[Stock alloc] initWithVolatility:10];
        self.stock.stockPrice = arc4random_uniform(kStockPriceRange) + kYOffset;
        self.startingPrice = self.stock.stockPrice;
        _arrayOfCoordinates = [[NSMutableArray alloc]init];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    self.context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(self.context);
    CGContextMoveToPoint(self.context, 0, self.stock.stockPrice);
    NSLog(@"Starting Price: %0.2f", self.stock.stockPrice - kYOffset);
    NSLog(@"Standard Deviation: %0.2f", self.stock.standardDeviation);
    NSLog(@"Volatility: %d", self.stock.volatility);
    NSLog(@"Company State: %0.2f", self.stock.companyState);
    NSLog(@"Value: %0.2f", self.stock.value);
    NSLog(@"Skewness %d", self.stock.skewness);
    NSLog(@"Distribution: 1sd%d, 2sd%d", self.stock.distribution1sd, self.stock.distribution2sd);
    [self simulateStock];
    
    //    CGContextAddLineToPoint(self.context, CGRectGetMaxX(rect), CGRectGetHeight(rect));
    //    CGContextAddLineToPoint(self.context, CGRectGetMinX(rect), CGRectGetHeight(rect));
    //    CGContextClosePath(self.context);
    //    CGPathRef fillPath = CGContextCopyPath(self.context);
    
    //CGContextSetFillColorWithColor(self.context, [UIColor colorWithRed:29.0/255.0 green:82.0/255.0 blue:174.0/255.0 alpha:0.8].CGColor);
    //    CGContextFillPath(self.context);
    //    CGContextAddPath(self.context, fillPath);
    CGContextSetStrokeColorWithColor(self.context, [UIColor colorWithRed:255.0/255.0 green:94.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor);
    //    CGContextSetLineWidth(self.context, 5 * self.stock.standardDeviation);
    
    CGContextSetLineWidth(self.context, 7);
    CGContextSetLineCap(self.context, kCGLineCapRound);
    CGContextStrokePath(self.context);
}

- (void)simulateStock {
    for (int x; x < 2500; x += 5) {
        int f = arc4random_uniform(99);
        float distribution = (float) f;
        
        if (distribution <= self.stock.distribution1sd) {
            [self.stock simulateStockSkewnessWithStandardDeviation:1];
        }
        else if (distribution > self.stock.distribution1sd && distribution <= self.stock.distribution2sd) {
            [self.stock simulateStockSkewnessWithStandardDeviation:2];
        }
        else if (distribution > self.stock.distribution2sd && distribution < 100) {
            [self.stock simulateStockSkewnessWithStandardDeviation:3];
        }
        else {
            int randomeWalk = arc4random_uniform(2);
            if (randomeWalk == 1) {
                [self.stock simulateStockSkewnessWithStandardDeviation:1];
            }
        }
        self.stock.timeVariable = x;
        CGContextAddLineToPoint(self.context, self.stock.timeVariable, self.stock.stockPrice);
        float stockPriceOnGraph = (1000 - self.stock.stockPrice)/20;
        [self.arrayOfCoordinates addObject:[[Coordinate alloc] initWithPrice:@(stockPriceOnGraph)]];
        
//        NSLog(@"$%0.2f, $%0.2f", self.stock.stockPrice, stockPriceOnGraph);
        
//        NSLog(@"count: %lu", (unsigned long)self.arrayOfCoordinates.count);
        //NSLog(@"%@", self.stock.arrayOfCoordinates.description);
    }
}

@end
