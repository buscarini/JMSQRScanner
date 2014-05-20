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
@property (nonatomic, assign) BOOL dismissing;

@end

@implementation JMSQRScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.scannerView = [JMSQRScannerView new];
	[self.view addSubview:self.scannerView];
	
	[BMFAutoLayoutUtils fill:self.view with:self.scannerView margin:0];
	
	@weakify(self);
	self.scannerView.codeScannedBlock = ^(id sender, NSString *code) {
		if (self.dismissing) return;
		
		@strongify(self);
		self.code = code;
		[self.scannerView stop];
		self.dismissing = YES;
		[self dismissViewControllerAnimated:YES completion:^{
			self.dismissing = NO;
		}];
	};
	
	[self.scannerView start];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close:)];
}

- (void) close: (id) sender {
	[self.scannerView stop];
	self.dismissing = YES;
	@weakify(self);
	[self dismissViewControllerAnimated:YES completion:^{
		@strongify(self);
		self.dismissing = NO;
	}];
}

@end
