//
//  ViewController.m
//  StockLine
//
//  Created by Li Pan on 2016-02-08.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ViewController.h"
#import "GraphTool.h"
#import "Stock.h"
#import "Coordinate.h"

@interface ViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) GraphTool *graphTool;
@property (nonatomic, strong) Coordinate *currentCoordinate;
@property (nonatomic, strong) UIColor *stateColor;
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, strong) CADisplayLink *displaylink;
@property (nonatomic, strong) AVAudioPlayer *backgroundMusicPlayer;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureTool;
@property (nonatomic, strong) UITapGestureRecognizer *buy;
@property (nonatomic, strong) UITapGestureRecognizer *sell;
@property (nonatomic, strong) UISwipeGestureRecognizer *initiateShortSelling;
@property (nonatomic, strong) UITapGestureRecognizer *shortSell;
@property (nonatomic, strong) UISlider *shareSlider;

@property (nonatomic, strong) UILabel *firstBlock;
@property (nonatomic, strong) UILabel *pointBlock;
@property (nonatomic, strong) UILabel *shortSellPremiumLabel;

@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UILabel *infoTextLabel;
@property (nonatomic, strong) UILabel *infoNumberLabel;
@property (nonatomic, strong) UILabel *moneyLabel;
@property (nonatomic, strong) UILabel *shareLabel;
@property (nonatomic, strong) UILabel *holdingsLabel;
@property (nonatomic, strong) UILabel *firstInfoLabel;
@property (nonatomic, strong) UILabel *secondInfoLabel;
@property (nonatomic, strong) UILabel *thirdInfoLabel;

@property (nonatomic, assign) int timeIndex;
@property (nonatomic, assign) float currentPrice;
@property (nonatomic, assign) float boughtPrice;
@property (nonatomic, assign) float netGainLoss;
@property (nonatomic, assign) float shortPrice;

@property (nonatomic, assign) float maxNumberOfShares;
@property (nonatomic, assign) float numberOfShares;
@property (nonatomic, assign) float cash;
@property (nonatomic, assign) float holdingValue;

@property (nonatomic, assign) BOOL bought;
@property (nonatomic, assign) BOOL shorted;

@end

@implementation ViewController

static const float kTotalTime = 49.7;
static const float kUITransitionTime= 1;

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
#pragma mark time
    //    NSLog(@"%f", self.startTime);
    self.displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [self.displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.stateColor = [UIColor colorWithRed:235.0/255.0 green:155.0/255.0 blue:64.0/255.0 alpha:1.0];
    [self loadContent];
}

- (void)loadContent {
    
#pragma mark music
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *backGroundMusicPath = [[NSBundle mainBundle] pathForResource:@"GameMusic_Large" ofType:@"mp3"];
        NSURL *backGroundMusicURL = [NSURL fileURLWithPath:backGroundMusicPath];
        self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backGroundMusicURL error:nil];
        self.backgroundMusicPlayer.numberOfLoops = -1;
        
        [self.backgroundMusicPlayer prepareToPlay];
        [self.backgroundMusicPlayer play];
    });
    
#pragma mark graph
    self.view.backgroundColor = self.stateColor;
    self.graphTool = [[GraphTool alloc] initWithFrame:CGRectMake(0, 0, 2500, 800)];
    self.graphTool.backgroundColor = self.stateColor;
    self.scrollView.backgroundColor = self.stateColor;
    self.graphTool.userInteractionEnabled = YES;
    self.startTime = CACurrentMediaTime();
    self.cash = 0;
    self.numberOfShares = 1000;
    self.holdingValue = self.numberOfShares * self.currentPrice;
    self.maxNumberOfShares = self.cash/self.currentPrice;
    
#pragma mark blocking
    self.pointBlock = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 1, CGRectGetHeight(self.graphTool.frame))];
    self.pointBlock.backgroundColor = [UIColor blackColor];
    self.pointBlock.alpha = 0.15;
    self.timeIndex = self.pointBlock.frame.origin.x;
    self.firstBlock = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame))];
    self.firstBlock.backgroundColor = self.stateColor;
    
    self.shortSellPremiumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.currentPrice, CGRectGetWidth(self.graphTool.frame) - self.timeIndex, 1)];
    self.shortSellPremiumLabel.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:196.0/255.0 alpha:1.0];
    
    self.shortSellPremiumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.currentPrice, CGRectGetWidth(self.graphTool.frame) - self.timeIndex, 1)];
    self.shortSellPremiumLabel.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:196.0/255.0 alpha:1.0];
    [self.scrollView addSubview:self.shortSellPremiumLabel];
    [UIView animateWithDuration:10 animations:^{
        self.shortSellPremiumLabel.frame = CGRectMake(0, self.currentPrice, CGRectGetWidth(self.graphTool.frame) - self.timeIndex, 20);
    }];
    
#pragma mark label
    
    self.stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(1, 30, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame))];
    self.stateLabel.text = @"WATCHING";
    self.stateLabel.font = [UIFont fontWithName:(@"AvenirNextCondensed-Heavy") size:42];
    self.stateLabel.alpha = 0.2;
    
    self.shareLabel = [[UILabel alloc]init];
    self.shareLabel.font = [UIFont fontWithName:(@"AvenirNextCondensed-Heavy") size:20];
    self.shareLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:229.0/255.0 blue:54.0/255.0 alpha:0.30];
    
    self.holdingsLabel = [[UILabel alloc]init];
    self.holdingsLabel.font = [UIFont fontWithName:(@"AvenirNextCondensed-Heavy") size:20];
    self.holdingsLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:229.0/255.0 blue:54.0/255.0 alpha:0.10];
    
    self.moneyLabel = [[UILabel alloc]init];
    self.moneyLabel.text = [NSString stringWithFormat:@"$%0.2f",self.cash];
    self.moneyLabel.textColor = [UIColor colorWithRed:200.0/255.0 green:0.0/255.0 blue:140.0/255.0 alpha:0.4];
    self.moneyLabel.font = [UIFont fontWithName:(@"AvenirNextCondensed-Heavy") size:36];
    
    self.infoTextLabel = [[UILabel alloc]init];
    self.infoTextLabel.text = @"Current Price $\nVolitility";
    self.infoTextLabel.font = [UIFont fontWithName:(@"AvenirNext-Regular") size:14];
    self.infoTextLabel.numberOfLines = 0;
    self.infoTextLabel.alpha = 0.25;
    self.infoTextLabel.textAlignment = NSTextAlignmentRight;
    
    self.infoNumberLabel = [[UILabel alloc]init];
    self.infoNumberLabel.text = [NSString stringWithFormat:@"%f\n", self.currentPrice];
    self.infoNumberLabel.font = [UIFont fontWithName:(@"AvenirNext-Regular") size:14];
    self.infoNumberLabel.numberOfLines = 0;
    self.infoNumberLabel.alpha = 0.6;
    self.infoNumberLabel.textAlignment = NSTextAlignmentLeft;
    
    self.firstInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(420, -80, 100, CGRectGetHeight(self.graphTool.frame))];
    self.firstInfoLabel.font = [UIFont fontWithName:(@"AvenirNextCondensed-Regular") size:24];
    self.firstInfoLabel.textColor = [UIColor colorWithRed:200.0/255.0 green:100.0/255.0 blue:0.0/255.0 alpha:0.5];
    //self.firstInfoLabel.text = [NSString stringWithFormat:@" $%0.2f", self.boughtPrice];
    
    self.secondInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(420, -90, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame))];
    self.secondInfoLabel.font = [UIFont fontWithName:(@"AvenirNextCondensed-Regular") size:24];
    self.secondInfoLabel.textColor = [UIColor colorWithRed:200.0/255.0 green:50/255.0 blue:0.0/255.0 alpha:0.5];
    //self.secondInfoLabel.text = [NSString stringWithFormat:@"-$%0.2f", self.currentPrice];
    
    self.thirdInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(420, -120, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame))];
    self.thirdInfoLabel.font = [UIFont fontWithName:(@"AvenirNextCondensed-Regular") size:28];
    self.thirdInfoLabel.textColor = [UIColor colorWithRed:200.0/255.0 green:0.0/255.0 blue:140.0/255.0 alpha:0.6];
    //self.thirdInfoLabel.text = [NSString stringWithFormat:@" $%0.2f", self.netGainLoss];
    
    self.shareSlider = [[UISlider alloc]initWithFrame:CGRectMake(520, 100, 50, 160)];
    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * 1.5);
    self.shareSlider.transform = trans;
    [self.shareSlider setUserInteractionEnabled:YES];
    [self.shareSlider setMaximumValue:5000];
    [self.shareSlider setMinimumValue:1];
    [self.shareSlider addTarget:self action:@selector(adjustShares:) forControlEvents:UIControlEventTouchDragInside];
    self.shareSlider.value = 1000;
    
#pragma mark userActions
    
    self.buy = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buyAction:)];
    [self.buy setNumberOfTapsRequired:1];
    self.buy.enabled = YES;
    
    self.sell = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sellAction:)];
    [self.sell setNumberOfTapsRequired:2];
    self.sell.enabled = NO;
    
    self.initiateShortSelling = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(shortSellingActionInitiated:)];
    [self.initiateShortSelling setDirection:UISwipeGestureRecognizerDirectionDown];
    self.initiateShortSelling.enabled = YES;
    
    self.shortSell = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shortSell:)];
    [self.shortSell setNumberOfTapsRequired:2];
    self.shortSell.enabled = NO;
    
    
#pragma mark addingViews
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView setContentOffset:CGPointMake(0, self.graphTool.startingPrice - 600)];
    
    //    if ((self.scrollEnabled == YES && (self.displaylink.timestamp - self.startTime) >= 10)) {
    //        [UIView animateWithDuration:kTotalTime animations:^{
    //            self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.graphTool.frame) - 500, self.currentprice + 500);
    //    }];
    //    }
    self.view.opaque = YES;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.bounces = NO;
    self.scrollView.clipsToBounds = YES;
    //    [self.scrollView setZoomScale:1.5];
    [self.scrollView setMaximumZoomScale:4.0];
    [self.scrollView setMinimumZoomScale:1.0];
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
    [self.view addSubview:self.scrollView];
    self.scrollView.clipsToBounds = YES;
    self.scrollView.bounces = NO;
    self.scrollView.delegate = self;
    [self.scrollView addSubview:self.graphTool];
    [self.scrollView addSubview:self.firstBlock];
    [self.scrollView addSubview:self.pointBlock];
    
    [self.scrollView addGestureRecognizer:self.buy];
    [self.scrollView addGestureRecognizer:self.sell];
    [self.scrollView addGestureRecognizer:self.initiateShortSelling];
    [self.scrollView addGestureRecognizer:self.shortSell];
    [self.scrollView addSubview:self.stateLabel];
    [self.scrollView addSubview:self.infoTextLabel];
    [self.scrollView addSubview:self.infoNumberLabel];
    [self.scrollView addSubview:self.moneyLabel];
    [self.scrollView addSubview:self.shareLabel];
    [self.scrollView addSubview:self.holdingsLabel];
    [self.scrollView addSubview:self.shareSlider];
    [self.scrollView addSubview:self.firstInfoLabel];
    [self.scrollView addSubview:self.secondInfoLabel];
    [self.scrollView addSubview:self.thirdInfoLabel];
    [self.scrollView addSubview:self.shortSellPremiumLabel];
    
#pragma mark constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:1000]];
}

#pragma mark methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.graphTool;
}

#pragma mark update

- (void)update {
    self.timeIndex = ((self.displaylink.timestamp - self.startTime)/0.1);
    if (self.displaylink.timestamp - self.startTime >= kTotalTime) {
        self.displaylink.paused = YES;
    }
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        self.currentCoordinate = [self.graphTool.arrayOfCoordinates objectAtIndex:self.timeIndex];
        self.currentPrice = [(self.currentCoordinate.price)floatValue];
    });
    
    self.pointBlock.frame = CGRectMake(self.timeIndex, 0, 1, CGRectGetHeight(self.graphTool.frame));
    self.firstBlock.frame = CGRectMake(self.timeIndex, 0, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
    
    self.stateLabel.frame = CGRectMake(self.timeIndex * 0.3, 30, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
    
    self.infoTextLabel.frame = CGRectMake(self.timeIndex - 100, 70, 100, CGRectGetHeight(self.graphTool.frame));
    
    self.infoNumberLabel.frame = CGRectMake(self.timeIndex + 5, 70, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.graphTool.frame));
    self.infoNumberLabel.text = [NSString stringWithFormat:@"%0.2f\n", self.currentPrice];
    
    self.shareLabel.frame = CGRectMake(self.timeIndex, 152, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
    self.holdingsLabel.frame = CGRectMake(self.timeIndex, 172, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
    
    self.moneyLabel.frame = CGRectMake(self.timeIndex, 202, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
    
    self.shareLabel.text = [NSString stringWithFormat:@"%0.2f", self.shareSlider.value];
    self.holdingsLabel.text = [NSString stringWithFormat:@"%0.2f", self.shareSlider.value * self.currentPrice];
    self.moneyLabel.text = [NSString stringWithFormat:@"$0.20,000%0.2f", self.cash];
    
    //    NSLog(@"Time:%d, %f, $%0.2f" ,self.timeIndex, self.displaylink.timestamp - self.startTime, self.currentPrice);
}

- (void)buyAction:(UITapGestureRecognizer *)sender {
    self.boughtPrice = self.currentPrice;
    NSLog(@"%f, %d, %f, Bought At: $%f", CACurrentMediaTime() - self.startTime, self.timeIndex, self.displaylink.timestamp - self.startTime, self.currentPrice);
    
    
    self.buy.enabled = NO;
    self.sell.enabled = YES;
    self.stateLabel.text = [NSString stringWithFormat:@"BOUGHT@$%0.2f",self.boughtPrice];
    self.stateLabel.alpha = 0;
    self.stateLabel.textColor = [UIColor colorWithRed:192.0/255.0 green:14.0/255.0 blue:14.0/255.0 alpha:1.0];
    
    [UIView animateWithDuration:kUITransitionTime animations:^{
        self.stateLabel.alpha = 0.2;
        self.holdingsLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:229.0/255.0 blue:54.0/255.0 alpha:0.55];
        
    }];
    //    self.infoLabel.text = [NSString stringWithFormat:@"Bought at Time%f\nPrice: $0.2%f", CACurrentMediaTime() - self.startTime, self.currentPrice];
    //    self.infoLabel.alpha = 0.3;
    //    [UIView animateWithDuration:kUITransitionTime animations:^{
    //        self.infoLabel.alpha = 1.0;
    
}
- (void)sellAction:(UITapGestureRecognizer *)sender {
    self.netGainLoss =  -(self.boughtPrice - self.currentPrice);
    self.cash += self.netGainLoss * self.numberOfShares;
    
    NSLog(@"%f, %d, Sold At: $%f, Net: %0.2f", CACurrentMediaTime() - self.startTime, self.timeIndex, self.currentPrice, self.netGainLoss);
    
    self.stateLabel.text = [NSString stringWithFormat:@"WATCHING"];
    self.stateLabel.alpha = 0;
    self.stateLabel.textColor = [UIColor blackColor];
    [UIView animateWithDuration:kUITransitionTime animations:^{
        self.stateLabel.alpha = 0.2;
        self.holdingsLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:229.0/255.0 blue:54.0/255.0 alpha:0.10];
        
    }];
    
    self.firstInfoLabel.frame = CGRectMake(320, 50, 100, CGRectGetHeight(self.graphTool.frame));
    self.firstInfoLabel.text = [NSString stringWithFormat:@"  $%0.2f", self.currentPrice * self.numberOfShares];
    
    self.secondInfoLabel.frame = CGRectMake(320, 80, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
    self.secondInfoLabel.text = [NSString stringWithFormat:@"- $%0.2f", self.boughtPrice * self.numberOfShares];
    
    self.thirdInfoLabel.frame = CGRectMake(330, 120, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
    self.thirdInfoLabel.text = [NSString stringWithFormat:@"  $%0.2f", self.netGainLoss * self.numberOfShares];
    
    [UIView animateWithDuration:4.5 animations:^{
        self.firstInfoLabel.frame = CGRectMake(320, 50, 100, CGRectGetHeight(self.graphTool.frame));
        self.firstInfoLabel.alpha = 1;
        self.secondInfoLabel.frame = CGRectMake(320, 80, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
        self.secondInfoLabel.alpha = 1;
        self.thirdInfoLabel.frame = CGRectMake(320, 120, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
        self.thirdInfoLabel.alpha = 1;
        
        [UIView animateWithDuration:2 animations:^{
            self.firstInfoLabel.frame = CGRectMake(650, 50, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
            self.firstInfoLabel.alpha = 0.0;
            self.secondInfoLabel.frame = CGRectMake(610, 80, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
            self.secondInfoLabel.alpha = 0.0;
            self.thirdInfoLabel.frame = CGRectMake(570, 120, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
            self.thirdInfoLabel.alpha = 0.0;
        }];
    }];
    
    self.sell.enabled = NO;
    self.buy.enabled = YES;
    
}
- (void)shortSellingActionInitiated:(UITapGestureRecognizer *)sender {
    self.shortPrice = self.currentPrice;
    
    NSLog(@"%f, %d, Short At: $%f", CACurrentMediaTime() - self.startTime, self.timeIndex, self.currentPrice);
    
    self.initiateShortSelling.enabled = NO;
    self.shortSell.enabled = YES;
    self.buy.enabled = NO;
    
    self.stateLabel.text = [NSString stringWithFormat:@"SHORTED@$%0.2f",self.shortPrice];
    self.stateLabel.alpha = 0;
    self.stateLabel.textColor = [UIColor colorWithRed:192.0/255.0 green:14.0/255.0 blue:14.0/255.0 alpha:1.0];
    
    [UIView animateWithDuration:kUITransitionTime animations:^{
        self.stateLabel.alpha = 0.2;
    }];
    
}
- (void)shortSell:(UITapGestureRecognizer *)sender {
    self.netGainLoss = (self.shortPrice - self.currentPrice);
    self.cash += self.netGainLoss * self.numberOfShares;
    
    self.initiateShortSelling.enabled = YES;
    
    NSLog(@"%f, %d, Shorted At: $%f, Net: %0.2f", CACurrentMediaTime() - self.startTime, self.timeIndex, self.currentPrice, self.netGainLoss);
    
    self.shortSell.enabled = NO;
    self.buy.enabled = YES;
    
    self.stateLabel.text = [NSString stringWithFormat:@"WATCHING"];
    self.stateLabel.alpha = 0;
    self.stateLabel.textColor = [UIColor blackColor];
    [UIView animateWithDuration:kUITransitionTime animations:^{
        self.stateLabel.alpha = 0.2;
    }];
    
    self.firstInfoLabel.frame = CGRectMake(320, 50, 100, CGRectGetHeight(self.graphTool.frame));
    self.firstInfoLabel.text = [NSString stringWithFormat:@"  $%0.2f", self.currentPrice * self.numberOfShares];
    
    self.secondInfoLabel.frame = CGRectMake(320, 80, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
    self.secondInfoLabel.text = [NSString stringWithFormat:@"- $%0.2f", self.shortPrice * self.numberOfShares];
    
    self.thirdInfoLabel.frame = CGRectMake(330, 120, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
    self.thirdInfoLabel.text = [NSString stringWithFormat:@"  $%0.2f", self.netGainLoss * self.numberOfShares];
    
    [UIView animateWithDuration:4.5 animations:^{
        self.firstInfoLabel.frame = CGRectMake(320, 50, 100, CGRectGetHeight(self.graphTool.frame));
        self.firstInfoLabel.alpha = 1;
        self.secondInfoLabel.frame = CGRectMake(320, 80, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
        self.secondInfoLabel.alpha = 1;
        self.thirdInfoLabel.frame = CGRectMake(320, 120, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
        self.thirdInfoLabel.alpha = 1;
        
        [UIView animateWithDuration:2 animations:^{
            self.firstInfoLabel.frame = CGRectMake(650, 50, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
            self.firstInfoLabel.alpha = 0.0;
            self.secondInfoLabel.frame = CGRectMake(610, 80, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
            self.secondInfoLabel.alpha = 0.0;
            self.thirdInfoLabel.frame = CGRectMake(570, 120, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
            self.thirdInfoLabel.alpha = 0.0;
        }];
    }];
    
}
- (void)adjustShares: (UISlider *)sliderValue {
    sliderValue.value = self.numberOfShares;
    self.holdingsLabel.text = [NSString stringWithFormat:@"$%f", self.holdingValue];
    self.shareLabel.text = [NSString stringWithFormat:@"%f", self.numberOfShares];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

//-(void) loadBackgroundMusic {
//    NSError *error;
//    NSURL *url = [[NSBundle mainBundle]
//                  URLForResource: @"GameMusic_Large" withExtension:@"mp3"];
//    NSData *soundData = [NSData dataWithContentsOfURL:url];
//
//    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithData:soundData error:&error];
//    self.backgroundMusicPlayer.numberOfLoops = -1; //Set to loop until stopped
//    self.backgroundMusicPlayer.volume = 0;
//
//    if (error) {
//        NSLog(@"Error in audioPlayer: %@",
//              [error localizedDescription]);
//    }
//}

@end

