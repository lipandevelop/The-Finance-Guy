//
//  Coordinates.m
//  StockLine
//
//  Created by Li Pan on 2016-02-08.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "Coordinate.h"

@implementation Coordinate

- (instancetype)initWithPrice: (NSNumber *)price {
    self = [super init];
    if (self) {
        _price = price;
    }
    return self;
}

@end
