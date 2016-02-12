//
//  ViewController.h
//  StockLine
//
//  Created by Li Pan on 2016-02-08.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FundsDelegate <NSObject>

- (void)textEntered:(NSString *)text;

@end

@interface ViewController : UIViewController
@property (weak, nonatomic) id <FundsDelegate> delegate;


@end

