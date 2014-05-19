//
//  JMSQRScannerView.m
//  Pods
//
//  Created by Jose Manuel Sánchez Peñarroja on 19/05/14.
//
//

#import "JMSQRScannerView.h"

#import <ZBarSDK/ZBarReaderView.h>
#import "WECodeScannerView.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@interface JMSQRScannerView() <ZBarReaderViewDelegate,WECodeScannerViewDelegate>

@property (nonatomic, strong) WECodeScannerView *codeScannerView;
@property (nonatomic, strong) ZBarReaderView *codeScannerViewLegacy;

@end

@implementation JMSQRScannerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
			[self initScannerReader];
		}
		else {
			[self initScannerReaderLegacy];
		}
    }
    return self;
}

- (void)initScannerReader {
	self.codeScannerView = [WECodeScannerView new];
	self.codeScannerView.frame = self.bounds;
	self.codeScannerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.codeScannerView.delegate = self;
	[self addSubview:self.codeScannerView];
}

- (void)initScannerReaderLegacy {
    self.codeScannerViewLegacy = [ZBarReaderView new];
    ZBarImageScanner * scanner = [ZBarImageScanner new];
    [scanner setSymbology:ZBAR_PARTIAL config:0 to:0];
    self.codeScannerViewLegacy = [self.codeScannerViewLegacy initWithImageScanner:scanner];
    self.codeScannerViewLegacy.readerDelegate = self;
	
    self.codeScannerViewLegacy.frame = self.bounds;
    self.codeScannerViewLegacy.backgroundColor = [UIColor redColor];
    [self.codeScannerViewLegacy start];
    
    [self addSubview:self.codeScannerViewLegacy];
}

- (void) start {
	[self.codeScannerView start];
	[self.codeScannerViewLegacy start];
}

- (void) stop {
	[self.codeScannerView stop];
	[self.codeScannerViewLegacy stop];
}

#pragma mark WECodeScannerViewDelegate

- (void)scannerView:(WECodeScannerView *)scannerView didReadCode:(NSString *)code {
	if (self.codeScannedBlock) self.codeScannedBlock(self,code);
}
- (void)scannerViewDidStartScanning:(WECodeScannerView *)scannerView {
	if (self.scanStartedBlock) self.scanStartedBlock(self,nil);
}

- (void)scannerViewDidStopScanning:(WECodeScannerView *)scannerView {
	if (self.scanStoppedBlock) self.scanStoppedBlock(self,nil);
}


#pragma mark ZBarReaderViewDelegate

- (void) readerView: (ZBarReaderView*) readerView
     didReadSymbols: (ZBarSymbolSet*) symbols
          fromImage: (UIImage*) image {

	if (!self.codeScannedBlock) return;
	
	ZBarSymbol * s = nil;
	for (s in symbols) {
		self.codeScannedBlock(self,s.data);
	}
}

- (void) readerViewDidStart: (ZBarReaderView*) readerView {
	if (self.scanStartedBlock) self.scanStartedBlock(self,nil);
}

- (void) readerView: (ZBarReaderView*) readerView didStopWithError: (NSError*) error {
	if (self.scanStoppedBlock) self.scanStoppedBlock(self,error);
}


@end
