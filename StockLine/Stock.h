//
//  Stock.h
//  StockLine
//
//  Created by Li Pan on 2016-02-08.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Stock : NSObject

extern const int kNORMAL_DISTRIBUTION_1SD;
extern const int kNORMAL_DISTRIBUTION_2SD;

@property (nonatomic, assign) float stockPrice;

#pragma mark - Dependent
@property (nonatomic, assign) int volatility;
@property (nonatomic, assign) float standardDeviation;

#pragma mark - Systematic Risk
@property (nonatomic, assign) float companyState;
@property (nonatomic, assign) float value;

#pragma mark - Distribution
@property (nonatomic, assign) int distribution1sd;
@property (nonatomic, assign) int distribution2sd;
@property (nonatomic, assign) int skewness;

#pragma mark - graph
@property (nonatomic, assign) CGPoint coordinates;
@property (nonatomic, assign) int timeVariable;


//- (void)simulateStockPrice;
- (instancetype) initWithVolatility: (int)volatility;
- (void)simulateStockSkewnessWithStandardDeviation: (int)sd;



@end
