//
//  ViewController.h
//  StockLine
//
//  Created by Li Pan on 2016-02-08.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FundsDelegate <NSObject>
- (void)storeCash:(float)cash;

@end

@interface ViewController : UIViewController
@property (nonatomic, weak) id <FundsDelegate> delegate;


@end

