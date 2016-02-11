//
//  DrawingTool.h
//  StockLine
//
//  Created by Li Pan on 2016-02-08.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface GraphTool : UIView
@property (nonatomic, assign) int startingPrice;
@property (nonatomic, strong) NSMutableArray *arrayOfCoordinates;


@end
