//
//  WECodeScannerView.m
//  WECodeScanner
//
//  Created by Werner Altewischer on 10/11/13.
//  Copyright (c) 2013 Werner IT Consultancy. All rights reserved.
//

#import "WECodeScannerView.h"
#import "WECodeScannerMatchView.h"
#import <AVFoundation/AVFoundation.h>

#import <BMF/BMF.h>

@interface WECodeScannerView () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) WECodeScannerMatchView *matchView;
@property (nonatomic, strong) NSDate *lastDetectionDate;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;

@property (nonatomic, assign) BOOL dontWait;

@end

@implementation WECodeScannerView {
    BOOL _scanning;
    BOOL _wasScanning;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.captureSession = [[AVCaptureSession alloc] init];
        [self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
        
        AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        
        if ([videoCaptureDevice lockForConfiguration:&error]) {
            if (videoCaptureDevice.isAutoFocusRangeRestrictionSupported) {
                [videoCaptureDevice setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNear];
            }
            if ([videoCaptureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                [videoCaptureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            }
            [videoCaptureDevice unlockForConfiguration];
        } else {
            NSLog(@"Could not configure video capture device: %@", error);
        }
        
        AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
        if(videoInput) {
            [self.captureSession addInput:videoInput];
        } else {
            NSLog(@"Could not create video input: %@", error);
        }
        
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		self.previewLayer.connection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation];

        [self.layer addSublayer:self.previewLayer];
        
        self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [self.captureSession addOutput:self.metadataOutput];
        [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [self setMetadataObjectTypes:@[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeQRCode]];
        
        self.matchView = [[WECodeScannerMatchView alloc] init];
        [self addSubview:self.matchView];
        self.quietPeriodAfterMatch = 7;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deactivate)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:[UIApplication sharedApplication]];
        
        // Register for notification that app did enter foreground
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(activate)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:[UIApplication sharedApplication]];
		
		[[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
			self.previewLayer.connection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation];
		}];
    }
    return self;
}

- (void)resetTimerAndRestart {
	self.dontWait = YES;
	[self stop];
	[self start];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		self.dontWait = NO;
	});
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (AVCaptureVideoOrientation) videoOrientationFromCurrentDeviceOrientation {
	switch ([[UIDevice currentDevice] orientation]) {
		case UIDeviceOrientationPortrait: {
			return AVCaptureVideoOrientationPortrait;
		}
		case UIDeviceOrientationLandscapeLeft: {
			return AVCaptureVideoOrientationLandscapeRight;
		}
		case UIDeviceOrientationLandscapeRight: {
			return AVCaptureVideoOrientationLandscapeLeft;
		}
		case UIDeviceOrientationPortraitUpsideDown: {
			return AVCaptureVideoOrientationPortraitUpsideDown;
		}
	}
	return AVCaptureVideoOrientationPortrait;
}

- (void)setMetadataObjectTypes:(NSArray *)metaDataObjectTypes {
	NSArray *available = [self.metadataOutput availableMetadataObjectTypes];
	
	[self.metadataOutput setMetadataObjectTypes:[metaDataObjectTypes BMF_filter:^BOOL(id input) {
		return [available containsObject:input];
	}]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.previewLayer.frame = self.bounds;
    self.matchView.frame = self.bounds;
    
    /*
     //Doesn't work for some reason: CGAffineTransform error
    CGRect rect = [self.previewLayer metadataOutputRectOfInterestForRect:self.previewLayer.bounds];
    self.metadataOutput.rectOfInterest = rect;
    */ 
}

- (void)start {
    if (!_scanning) {
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        _scanning = YES;
        [self.matchView reset];
        [self.captureSession startRunning];
        
        if ([self.delegate respondsToSelector:@selector(scannerViewDidStartScanning:)]) {
            [self.delegate scannerViewDidStartScanning:self];
        }
    }
    
}

- (void)stop {
    if (_scanning) {
		[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        _scanning = NO;
        [_timer invalidate];
        _timer = nil;
        [self.captureSession stopRunning];
        
        if ([self.delegate respondsToSelector:@selector(scannerViewDidStopScanning:)]) {
            [self.delegate scannerViewDidStopScanning:self];
        }
    }
}

- (void)deactivate {
    _wasScanning = _scanning;
    [self stop];
}

- (void)activate {
    if (_wasScanning) {
        [self start];
        _wasScanning = NO;
    }
}

- (CGPoint)pointFromArray:(NSArray *)points atIndex:(NSUInteger)index {
    NSDictionary *dict = [points objectAtIndex:index];
    CGPoint point;
    CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)dict, &point);    
    return [self.matchView convertPoint:point fromView:self];
}

- (BOOL)isInQuietPeriod {
	if (self.dontWait) return NO;
    return self.lastDetectionDate != nil && (-[self.lastDetectionDate timeIntervalSinceNow]) <= self.quietPeriodAfterMatch;
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if ([self isInQuietPeriod]) {
		NSLog(@"quiet");
        return;
    }
    for(AVMetadataObject *metadataObject in metadataObjects)
    {
		NSLog(@"scanning");
        if ([metadataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            AVMetadataMachineReadableCodeObject *readableObject = (AVMetadataMachineReadableCodeObject *)[self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
            BOOL foundMatch = readableObject.stringValue != nil;
            NSArray *corners = readableObject.corners;
            if (corners.count == 4 && foundMatch) {
                
                CGPoint topLeftPoint = [self pointFromArray:corners atIndex:0];
                CGPoint bottomLeftPoint = [self pointFromArray:corners atIndex:1];
                CGPoint bottomRightPoint = [self pointFromArray:corners atIndex:2];
                CGPoint topRightPoint = [self pointFromArray:corners atIndex:3];
                
                if (CGRectContainsPoint(self.matchView.bounds, topLeftPoint) &&
                    CGRectContainsPoint(self.matchView.bounds, topRightPoint) &&
                    CGRectContainsPoint(self.matchView.bounds, bottomLeftPoint) &&
                    CGRectContainsPoint(self.matchView.bounds, bottomRightPoint))
                {
                    [self stop];
                    _timer = [NSTimer scheduledTimerWithTimeInterval:self.quietPeriodAfterMatch target:self selector:@selector(start) userInfo:nil repeats:NO];
                    self.lastDetectionDate = [NSDate date];
                    
                    [self.matchView setFoundMatchWithTopLeftPoint:topLeftPoint
                                    topRightPoint:topRightPoint
                                  bottomLeftPoint:bottomLeftPoint
                                 bottomRightPoint:bottomRightPoint];
                    [self.delegate scannerView:self didReadCode:readableObject.stringValue];
                }
            }
        }
    }
}

@end
