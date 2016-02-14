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
@property (nonatomic, strong) Coordinate *currentPosition;
@property (nonatomic, strong) UIColor *stateColor;
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, strong) CADisplayLink *displaylink;
@property (nonatomic, strong) AVAudioPlayer *backgroundMusicPlayer;


@property (nonatomic, strong) UIPanGestureRecognizer *panGestureTool;
@property (nonatomic, strong) UITapGestureRecognizer *buy;
@property (nonatomic, strong) UITapGestureRecognizer *sell;
@property (nonatomic, strong) UISwipeGestureRecognizer *initiateShortSelling;
@property (nonatomic, strong) UITapGestureRecognizer *shortSell;
@property (nonatomic, strong) UILongPressGestureRecognizer *initiateForward;
@property (nonatomic, strong) UISlider *shareSlider;

@property (nonatomic, strong) UIButton *analysisButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *analysisLabel;
@property (nonatomic, strong) UILabel *backLabel;


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
@property (nonatomic, strong) UILabel *derivativesDetail;


@property (nonatomic, strong) UIImageView *buyPositionIndicator;
@property (nonatomic, strong) UIImageView *shortPositionIndicator;
@property (nonatomic, strong) UIImageView *point;
@property (nonatomic, strong) UIImageView *predictedPricePositionIndicator;
@property (nonatomic, strong) UIImageView *forwardPositionIndicator;



@property (nonatomic, assign) int startingPrice;
@property (nonatomic, assign) int timeIndex;
@property (nonatomic, assign) float currentPrice;
@property (nonatomic, assign) float currentPriceCoordinate;
@property (nonatomic, assign) float boughtPrice;
@property (nonatomic, assign) float netGainLoss;
@property (nonatomic, assign) float shortPrice;
@property (nonatomic, assign) float shortPriceCoordinate;
@property (nonatomic, assign) float forwardPositionInitialized;
@property (nonatomic, assign) float forwardPositionActual;
@property (nonatomic, assign) float predictedPriceCoordinate;
@property (nonatomic, assign) float forwardPositionInitializedCoordinate;

@property (nonatomic, assign) float maxNumberOfShares;
@property (nonatomic, assign) float numberOfShares;
@property (nonatomic, assign) float cash;
@property (nonatomic, assign) float holdingValue;

@property (nonatomic, assign) BOOL boughtEnabled;
@property (nonatomic, assign) BOOL shortingEnabled;
@property (nonatomic, assign) BOOL forwardEnabled;

@end

@implementation ViewController

static const float kTotalTime = 50;
static const float kUITransitionTime= 1;
static const float kPredictedPriceTime = 90;

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
    
#pragma mark graph
    self.view.backgroundColor = self.stateColor;
    self.graphTool = [[GraphTool alloc] initWithFrame:CGRectMake(0, 0, 700, 800)];
    self.graphTool.backgroundColor = self.stateColor;
    self.scrollView.backgroundColor = self.stateColor;
    self.graphTool.userInteractionEnabled = YES;
    self.startTime = CACurrentMediaTime();
    self.cash = 0;
    self.numberOfShares = 1000;
    self.holdingValue = self.numberOfShares * self.currentPrice;
    self.maxNumberOfShares = self.cash/self.currentPrice;
    
#pragma mark indicators
    self.boughtEnabled = NO;
    self.shortingEnabled = NO;
    
#pragma mark music
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *backGroundMusicPath = [[NSBundle mainBundle] pathForResource:@"Movement" ofType:@"mp3"];
        NSURL *backGroundMusicURL = [NSURL fileURLWithPath:backGroundMusicPath];
        self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backGroundMusicURL error:nil];
        self.backgroundMusicPlayer.numberOfLoops = -1;
        [self.backgroundMusicPlayer prepareToPlay];
        [self.backgroundMusicPlayer play];
    });
    
#pragma mark blocking
    self.pointBlock = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 1, CGRectGetHeight(self.graphTool.frame))];
    self.pointBlock.backgroundColor = [UIColor blackColor];
    self.pointBlock.alpha = 0.15;
    self.timeIndex = self.pointBlock.frame.origin.x;
    self.firstBlock = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame))];
    self.firstBlock.backgroundColor = self.stateColor;
    
    self.shortSellPremiumLabel = [[UILabel alloc]init];
    self.shortSellPremiumLabel.backgroundColor = [UIColor colorWithRed:146.0 green:230.0 blue:0.0/255.0 alpha:0.6];
    
#pragma mark label
    
    self.stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(1, 30, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame))];
    self.stateLabel.text = @"WATCHING";
    self.stateLabel.font = [UIFont fontWithName:(@"AvenirNextCondensed-Heavy") size:42];
    self.stateLabel.alpha = 0.2;
    
    self.derivativesDetail = [[UILabel alloc]init];
    self.derivativesDetail.font = [UIFont fontWithName:(@"AvenirNextCondensed-Heavy") size:28];
    self.derivativesDetail.alpha = 0.15;
    
    self.analysisButton = [[UIButton alloc]init];
    self.analysisButton.titleLabel.text = @"Stock Analysis";
    self.analysisButton.backgroundColor = [UIColor colorWithRed:13.0/255.0 green:40.0/255.0 blue:63.0/255.0 alpha:0.5];
    [self.analysisButton addTarget:self action:@selector(runAnalysis) forControlEvents:UIControlEventTouchUpInside];
    
    self.analysisLabel = [[UILabel alloc]init];
    self.analysisLabel.text = @"Predict For: $1k";
    self.analysisLabel.font = [UIFont fontWithName:(@"AvenirNextCondensed-Medium") size:12];
    self.analysisLabel.textAlignment = NSTextAlignmentRight;
    self.analysisLabel.textColor = [UIColor whiteColor];
    self.analysisLabel.alpha = 0.5;
    
    self.backLabel = [[UILabel alloc]init];
    self.backLabel.text = @"Cash Out";
    self.backLabel.font = [UIFont fontWithName:(@"AvenirNextCondensed-Heavy") size:16];
    self.backLabel.textAlignment = NSTextAlignmentRight;
    self.backLabel.alpha = 0.4;
    
    self.backButton = [[UIButton alloc]init];
    self.backButton.titleLabel.text = @"Back";
    self.backButton.backgroundColor = [UIColor colorWithRed:110.0/255.0 green:25.0/255.0 blue:0.0/255.0 alpha:0.4];
    [self.backButton addTarget:self action:@selector(endGame) forControlEvents:UIControlEventTouchUpInside];
    
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
    self.infoTextLabel.font = [UIFont fontWithName:(@"AvenirNext-Regular") size:12];
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
    
    self.secondInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(420, -90, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame))];
    self.secondInfoLabel.font = [UIFont fontWithName:(@"AvenirNextCondensed-Regular") size:24];
    self.secondInfoLabel.textColor = [UIColor colorWithRed:200.0/255.0 green:50/255.0 blue:0.0/255.0 alpha:0.5];
    
    self.thirdInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(420, -120, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame))];
    self.thirdInfoLabel.font = [UIFont fontWithName:(@"AvenirNextCondensed-Regular") size:28];
    self.thirdInfoLabel.textColor = [UIColor colorWithRed:200.0/255.0 green:0.0/255.0 blue:140.0/255.0 alpha:0.6];
    
    self.forwardPositionIndicator = [[UIImageView alloc]initWithFrame:CGRectZero];

    self.shareSlider = [[UISlider alloc]init];
    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * 1.5);
    self.shareSlider.transform = trans;
    [self.shareSlider setUserInteractionEnabled:YES];
    [self.shareSlider setMaximumValue:5000];
    [self.shareSlider setMinimumValue:1];
    [self.shareSlider addTarget:self action:@selector(adjustShares:) forControlEvents:UIControlEventTouchDragInside];
    self.shareSlider.value = 1000;
    self.shareSlider.tintColor = [UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:1.0];
    
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
    
    self.initiateForward = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(forwardPositionActionInitiated:)];
    self.initiateForward.delaysTouchesBegan = YES;
    self.initiateForward.minimumPressDuration = 0.5;
    self.initiateForward.enabled = YES;
    
    
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
    [self.scrollView addGestureRecognizer:self.initiateForward];
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
    [self.scrollView addSubview:self.analysisButton];
    [self.scrollView addSubview:self.analysisLabel];
    [self.scrollView addSubview:self.backButton];
    [self.scrollView addSubview:self.backLabel];
    [self.scrollView addSubview:self.derivativesDetail];
    
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
    UILabel *point = [[UILabel alloc]initWithFrame:CGRectMake(self.timeIndex, self.currentPriceCoordinate - 25, 15.0, 50.0)];
    point.backgroundColor = [UIColor colorWithRed:(150.0 + (self.currentPrice * 2.0))/255.0 green:10.0/255.0 blue:0.0 alpha:0.0];
    point.backgroundColor = [UIColor colorWithRed:180.0/255.0 green:10.0/255.0 blue:0.0 alpha:0.0];
    [UIView animateWithDuration:1.5 animations:^{
        point.frame = CGRectMake(self.timeIndex, self.currentPriceCoordinate, 3.0, 4.5);
        point.backgroundColor = [UIColor colorWithRed:(150.0 + (self.currentPrice * 2.0))/255.0 green:10.0/255.0 blue:0.0 alpha:0.4];
        
    }];
    
    [self.scrollView addSubview:point];
    
    [self.scrollView setNeedsDisplay];
    
    self.timeIndex = ((self.displaylink.timestamp - self.startTime)/0.1);
    if (self.displaylink.timestamp - self.startTime >= kTotalTime) {
        self.displaylink.paused = YES;
    }
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        self.currentPosition = [self.graphTool.arrayOfCoordinates objectAtIndex:self.timeIndex];
        self.currentPrice = [(self.currentPosition.price)floatValue];
        self.currentPriceCoordinate = [(self.currentPosition.priceCoordinate)floatValue];
        Coordinate *predicted = [self.graphTool.arrayOfCoordinates objectAtIndex:self.timeIndex + kPredictedPriceTime];
        self.predictedPriceCoordinate = [(predicted.priceCoordinate)floatValue];
    });
    
    self.pointBlock.frame = CGRectMake(self.timeIndex, 0, 1, CGRectGetHeight(self.graphTool.frame));
    self.firstBlock.frame = CGRectMake(self.timeIndex, 0, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
    
    self.analysisButton.frame = CGRectMake(self.timeIndex -599, 489, 600, 20);
    self.analysisLabel.frame = CGRectMake(self.timeIndex - 100, 98, 100, CGRectGetHeight(self.graphTool.frame));
    
    self.backButton.frame = CGRectMake(self.timeIndex -599, 632, 600, 30);
    self.backLabel.frame = CGRectMake(((self.timeIndex - 100) - (self.timeIndex * 0.50)), 248, 100, CGRectGetHeight(self.graphTool.frame));
    
    self.shareSlider.frame = CGRectMake(520, 400, 20, 200);
    
    self.stateLabel.frame = CGRectMake(self.timeIndex * 0.3, 30, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
    
    self.infoTextLabel.frame = CGRectMake(self.timeIndex - 100, 70, 100, CGRectGetHeight(self.graphTool.frame));
    [self.scrollView bringSubviewToFront:self.analysisLabel];
    
    self.infoNumberLabel.frame = CGRectMake(self.timeIndex + 5, 70, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.graphTool.frame));
    self.infoNumberLabel.text = [NSString stringWithFormat:@"%0.2f\n", self.currentPrice];
    
    self.shareLabel.frame = CGRectMake(self.timeIndex, 152, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
    self.holdingsLabel.frame = CGRectMake(self.timeIndex, 172, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
    
    self.moneyLabel.frame = CGRectMake(self.timeIndex, 202, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
    
    self.shareLabel.text = [NSString stringWithFormat:@"%0.2f", self.shareSlider.value];
    self.holdingsLabel.text = [NSString stringWithFormat:@"$%0.2f", self.shareSlider.value * self.currentPrice];
    self.moneyLabel.text = [NSString stringWithFormat:@"$%0.2f", self.cash];
    
    
    if (self.shortingEnabled) {
        self.shortSellPremiumLabel.frame = CGRectMake(0, self.shortPriceCoordinate + (1.0 + self.currentPrice)/10.0, self.timeIndex, 1.0 + (self.currentPrice/20.0));
    }
    //    NSLog(@"Time:%d, %f, Price: $%0.2f, %f" ,self.timeIndex, self.displaylink.timestamp - self.startTime, self.currentPrice, self.currentPriceCoordinate);
}

- (void)buyAction:(UITapGestureRecognizer *)sender {
    self.boughtPrice = self.currentPrice;
    NSLog(@"%f, %d, %f, Bought At: $%f", CACurrentMediaTime() - self.startTime, self.timeIndex, self.displaylink.timestamp - self.startTime, self.currentPrice);
    self.buyPositionIndicator = [[UIImageView alloc]initWithFrame:CGRectMake(self.timeIndex-5, self.currentPriceCoordinate-5, 10, 10)];
    self.buyPositionIndicator.contentMode = UIViewContentModeScaleAspectFit;
    self.buyPositionIndicator.image = [UIImage imageNamed:@"BuyPositionIndicator2"];
    self.buyPositionIndicator.alpha = 0.6;
    [self.scrollView addSubview:self.buyPositionIndicator];
    [self.scrollView bringSubviewToFront:self.buyPositionIndicator];
    UIImageView *buyPositionAnimationView = [[UIImageView alloc]initWithFrame:CGRectMake(self.timeIndex-6.5, self.currentPriceCoordinate-6.5, 13, 13)];
    buyPositionAnimationView.image = [UIImage imageNamed:@"BuyPositionIndicator2"];
    buyPositionAnimationView.alpha = 0.5;
    [self.scrollView addSubview:buyPositionAnimationView];
    [UIView animateWithDuration:kUITransitionTime animations:^{
        buyPositionAnimationView.frame = CGRectMake(self.timeIndex-25, self.currentPriceCoordinate-25, 50, 50);
        buyPositionAnimationView.alpha = 0.0;
    }];
    
    self.boughtEnabled = YES;
    self.buy.enabled = NO;
    self.sell.enabled = YES;
    self.stateLabel.text = [NSString stringWithFormat:@"BOUGHT@$%0.2f",self.boughtPrice];
    self.stateLabel.alpha = 0;
    self.stateLabel.textColor = [UIColor colorWithRed:192.0/255.0 green:14.0/255.0 blue:14.0/255.0 alpha:1.0];
    
    [UIView animateWithDuration:kUITransitionTime animations:^{
        self.stateLabel.alpha = 0.2;
        self.holdingsLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:229.0/255.0 blue:54.0/255.0 alpha:0.55];
        
    }];
    
}
- (void)sellAction:(UITapGestureRecognizer *)sender {
    self.netGainLoss =  -(self.boughtPrice - self.currentPrice);
    self.cash += self.netGainLoss * self.numberOfShares;
    //    NSLog(@"%f, %d, Sold At: $%f, Net: %0.2f", CACurrentMediaTime() - self.startTime, self.timeIndex, self.currentPrice, self.netGainLoss);
    
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
    
    self.boughtEnabled = NO;
    self.sell.enabled = NO;
    self.buy.enabled = YES;
    
}
- (void)shortSellingActionInitiated:(UITapGestureRecognizer *)sender {
    self.shortPrice = self.currentPrice;
    self.shortPriceCoordinate = self.currentPriceCoordinate;
    self.shortingEnabled = YES;
    
    self.shortPositionIndicator = [[UIImageView alloc]initWithFrame:CGRectMake(self.timeIndex-5, self.currentPriceCoordinate-5, 10, 10)];
    self.shortPositionIndicator.contentMode = UIViewContentModeScaleAspectFit;
    self.shortPositionIndicator.image = [UIImage imageNamed:@"ShortSellIndicator2"];
    self.shortPositionIndicator.alpha = 0.6;
    [self.scrollView addSubview:self.shortPositionIndicator];
    UIImageView *shortPositionAnimationView = [[UIImageView alloc]initWithFrame:CGRectMake(self.timeIndex-6.5, self.currentPriceCoordinate-6.5, 13, 13)];
    shortPositionAnimationView.image = [UIImage imageNamed:@"ShortSellIndicator2"];
    shortPositionAnimationView.alpha = 0.5;
    [self.scrollView addSubview:shortPositionAnimationView];
    [UIView animateWithDuration:kUITransitionTime animations:^{
        shortPositionAnimationView.frame = CGRectMake(self.timeIndex-25, self.currentPriceCoordinate-25, 50, 50);
        shortPositionAnimationView.alpha = 0.0;
    }];
    //    NSLog(@"%f, %d, Short At: $%f", CACurrentMediaTime() - self.startTime, self.timeIndex, self.currentPrice);
    
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
    self.shortingEnabled = NO;
    
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
- (void)forwardPositionActionInitiated:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint p = [sender locationInView:self.scrollView];
    if (p.x >= self.timeIndex) {
        Coordinate *fpc = [self.graphTool.arrayOfCoordinates objectAtIndex:p.x];
        self.forwardPositionInitialized = (1000 - p.y)/20;
        self.forwardPositionInitializedCoordinate = p.y;
        self.forwardPositionActual = [(fpc.price)floatValue];
        NSLog(@"forward: %f, $%0.2f, $%0.2f", p.x, self.forwardPositionInitialized, self.forwardPositionActual);
        
        self.forwardPositionIndicator.frame = CGRectMake(p.x - 10, p.y - 105, 20, 20);
        self.forwardPositionIndicator.contentMode = UIViewContentModeScaleAspectFit;
        self.forwardPositionIndicator.image = [UIImage imageNamed:@"FowardPositionIndicator"];
        self.forwardPositionIndicator.alpha = 0.6;
        [self.scrollView addSubview:self.forwardPositionIndicator];
        [UIView animateWithDuration:0.5 animations:^{
            self.forwardPositionIndicator.frame = CGRectMake(p.x - 5, p.y - 5, 20, 20);
        }];
        
        UIImageView *forwardPositionAnimationView = [[UIImageView alloc]initWithFrame:CGRectMake(p.x - 10, p.y - 20, 20, 20)];
        forwardPositionAnimationView.image = [UIImage imageNamed:@"FowardPositionIndicator"];
        forwardPositionAnimationView.alpha = 0.5;
        [self.scrollView addSubview:forwardPositionAnimationView];
        [UIView animateWithDuration:1.5 animations:^{
            forwardPositionAnimationView.frame = CGRectMake(p.x - 25, p.y - 25, 50, 50);
            forwardPositionAnimationView.alpha = 0.0;
        }];
    }
    
    self.initiateForward.enabled = NO;
    self.shortSell.enabled = YES;
    self.buy.enabled = NO;
    
    self.derivativesDetail.frame = CGRectMake(1, 50, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));

    self.derivativesDetail.text = [NSString stringWithFormat:@"SHORTED@$%0.2f",self.shortPrice];
    self.derivativesDetail.alpha = 0;
    self.derivativesDetail.textColor = [UIColor colorWithRed:192.0/255.0 green:14.0/255.0 blue:14.0/255.0 alpha:1.0];
    
    [UIView animateWithDuration:kUITransitionTime animations:^{
        self.stateLabel.alpha = 0.2;
    }];
    
}

- (void)cancelForward {
    [self.derivativesDetail removeFromSuperview];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)adjustShares: (UISlider *)sliderValue {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        sliderValue.value = self.numberOfShares;
        self.holdingsLabel.text = [NSString stringWithFormat:@"$%f", self.holdingValue];
        self.shareLabel.text = [NSString stringWithFormat:@"%f", self.numberOfShares];
    });
}

- (void)runAnalysis {
    self.cash -= 1000;
    self.predictedPricePositionIndicator = [[UIImageView alloc]initWithFrame:CGRectMake(self.timeIndex + kPredictedPriceTime - 120, self.predictedPriceCoordinate -120, 240, 240)];
    self.predictedPricePositionIndicator.contentMode = UIViewContentModeScaleAspectFit;
    self.predictedPricePositionIndicator.image = [UIImage imageNamed:@"PredictedPriceIndicator"];
    self.predictedPricePositionIndicator.alpha = 0.0;
    [self.scrollView addSubview:self.predictedPricePositionIndicator];
    [UIView animateWithDuration:3 animations:^{
        self.predictedPricePositionIndicator.frame = CGRectMake(self.timeIndex + kPredictedPriceTime  - 10, self.predictedPriceCoordinate - arc4random_uniform(25), 20, 20);
        self.predictedPricePositionIndicator.alpha = 0.3;
    }];
    [UIView animateWithDuration:6 animations:^{
        self.predictedPricePositionIndicator.frame = CGRectMake(self.timeIndex + kPredictedPriceTime  - 10, self.predictedPriceCoordinate - arc4random_uniform(25), 20, 20);
        self.predictedPricePositionIndicator.alpha = 0.0;
    }];
    
    self.thirdInfoLabel.frame = CGRectMake(330, 120, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
    self.thirdInfoLabel.text = @"Analysis cost: -$1000";
    
    [UIView animateWithDuration:4.5 animations:^{
        self.thirdInfoLabel.frame = CGRectMake(320, 120, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
        self.thirdInfoLabel.alpha = 1;
        
        [UIView animateWithDuration:2 animations:^{
            self.thirdInfoLabel.frame = CGRectMake(570, 120, CGRectGetWidth(self.graphTool.frame), CGRectGetHeight(self.graphTool.frame));
            self.thirdInfoLabel.alpha = 0.0;
        }];
    }];
}

- (void)endGame {
    [self.delegate storeCash:self.cash];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.backgroundMusicPlayer pause];
    //    NSLog(@"Ended");
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