//
//  Coordinates.m
//  StockLine
//
//  Created by Li Pan on 2016-02-08.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "Coordinate.h"

@implementation Coordinate

- (instancetype)initWithPrice: (NSNumber *)price coordinate:(NSNumber *)coordinate {
    self = [super init];
    if (self) {
        _priceCoordinate = coordinate;
        _price = price;
        
    }
    return self;
}

@end
