//
//  OpeningScreen.m
//  StockLine
//
//  Created by Li Pan on 2016-02-10.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "OpeningScreen.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ViewController.h"

@interface OpeningScreen () <UIScrollViewDelegate, AVAudioPlayerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) AVPlayer *backGroundImagePlayer;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *quoteLabel;

@end

@implementation OpeningScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadContent];
}

- (void) loadContent {
    
    self.view.backgroundColor = [UIColor blackColor];
    //    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 120, CGRectGetWidth(self.view.frame), 500)];
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView setContentOffset:CGPointMake(300, 0)];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"OpenSceen3" ofType:@"gif"];
    NSData *gif = [NSData dataWithContentsOfFile:filePath];
    UIWebView *webViewBG = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 746, 381)];
    
    [webViewBG loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    webViewBG.userInteractionEnabled = NO;
    webViewBG.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(71, 70, 600, 100)];
    self.titleLabel.font = [UIFont fontWithName:(@"AvenirNextCondensed-Heavy") size:32];
    self.titleLabel.text = @"THE FINANCE GUY";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.alpha = 0.25;
    [UIView animateWithDuration:150 animations:^{
        self.titleLabel.frame = CGRectMake(-220, 70, 600, 100);
    }];

    self.quoteLabel = [[UILabel alloc]initWithFrame:CGRectMake(111, 89, 600, 100)];
    self.quoteLabel.font = [UIFont fontWithName:(@"AvenirNextCondensed-Medium") size:12];
    self.quoteLabel.text = @"Be Greedy When Others Are Fearful";
    self.quoteLabel.textAlignment = NSTextAlignmentCenter;
    self.quoteLabel.alpha = 0.55;
    [UIView animateWithDuration:40 animations:^{
        self.quoteLabel.frame = CGRectMake(150, 89, 600, 100);
        self.quoteLabel.alpha = 0.15;
    }];

//    NSString *backGroundImagePath = [[NSBundle mainBundle] pathForResource:@"OpenSceen3" ofType:@"mp4"];
//    NSURL *backGroundMusicURL = [NSURL fileURLWithPath:backGroundImagePath];
//    self.backGroundImagePlayer = [[AVPlayer alloc]initWithURL:backGroundMusicURL];
//    [self.backGroundImagePlayer play];
    
    UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(115, 215, 140, 30)];
    playBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    playBtn.layer.borderWidth = 2.0;
    playBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [playBtn setTintColor:[UIColor whiteColor]];
    [playBtn setTitle:@"Play" forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(presentGameController) forControlEvents:UIControlEventTouchUpInside];
    //playBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(webViewBG.frame), CGRectGetHeight(webViewBG.frame));
    self.scrollView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:webViewBG];
    self.scrollView.clipsToBounds = YES;
    self.scrollView.bounces = NO;
    [self.scrollView addSubview:self.titleLabel];
    [self.scrollView addSubview:self.quoteLabel];
    [self.view addSubview:playBtn];
    [self.view bringSubviewToFront:playBtn];
    
    self.scrollView.delegate = self;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:440]];
    
}
- (void)presentGameController {
    ViewController *viewController = [[ViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

@end
