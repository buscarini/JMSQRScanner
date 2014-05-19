//
//  JMSScannerViewController.m
//  Example
//
//  Created by Jose Manuel Sánchez Peñarroja on 19/05/14.
//  Copyright (c) 2014 jms. All rights reserved.
//

#import "JMSScannerViewController.h"

#import <JMSQRScanner/JMSQRScannerView.h>
#import <BMF/BMFAutoLayoutUtils.h>

#import <ReactiveCocoa/RACEXTScope.h>

@interface JMSScannerViewController ()

@property (nonatomic, strong) JMSQRScannerView *scannerView;

@end

@implementation JMSScannerViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.scannerView = [JMSQRScannerView new];
	[self.view addSubview:self.scannerView];
	[self.view bringSubviewToFront:self.label];
	
	[BMFAutoLayoutUtils fill:self.view with:self.scannerView margin:0];
	
	@weakify(self);
	self.scannerView.codeScannedBlock = ^(id sender, NSString *code) {
		@strongify(self);
		self.label.text = code;
	};
	
	[self.scannerView start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
