//
//  JMSQRScannerView.h
//  Pods
//
//  Created by Jose Manuel Sánchez Peñarroja on 19/05/14.
//
//

#import <UIKit/UIKit.h>

typedef void(^JMSScannerCodeScannedBlock)(id scannerView,NSString *code);
typedef void(^JMSScannerEventBlock)(id scannerView,NSError *error);

@interface JMSQRScannerView : UIView

@property (nonatomic, copy) JMSScannerCodeScannedBlock codeScannedBlock;
@property (nonatomic, copy) JMSScannerEventBlock scanStartedBlock;
@property (nonatomic, copy) JMSScannerEventBlock scanStoppedBlock;

- (void) start;
- (void) stop;

@end
