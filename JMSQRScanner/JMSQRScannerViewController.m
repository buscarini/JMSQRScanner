//
//  JMSQRScannerViewController.m
//  Pods
//
//  Created by Jose Manuel Sánchez Peñarroja on 19/05/14.
//
//

#import "JMSQRScannerViewController.h"
#import <JMSQRScanner/JMSQRScannerView.h>
#import <BMF/BMFAutoLayoutUtils.h>

#import <ReactiveCocoa/RACEXTScope.h>

@interface JMSQRScannerViewController ()

@property (nonatomic, strong) JMSQRScannerView *scannerView;

@end

@implementation JMSQRScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.scannerView = [JMSQRScannerView new];
	[self.view addSubview:self.scannerView];
	
	[BMFAutoLayoutUtils fill:self.view with:self.scannerView margin:0];
	
	@weakify(self);
	self.scannerView.codeScannedBlock = ^(id sender, NSString *code) {
		@strongify(self);
		self.code = code;
		[self.scannerView stop];
		[self dismissViewControllerAnimated:YES completion:nil];
	};
	
	[self.scannerView start];
}

@end
