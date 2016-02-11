//
//  Coordinates.h
//  StockLine
//
//  Created by Li Pan on 2016-02-08.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Coordinate : NSObject
@property (nonatomic, strong) NSNumber *priceCoordinate;
@property (nonatomic, strong) NSNumber *price;
- (instancetype)initWithPrice: (NSNumber *)price coordinate:(NSNumber *)coordinate;



@end
