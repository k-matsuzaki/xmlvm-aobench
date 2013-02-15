//
//  ViewController.h
//  TemplateSingle
//
//  Created by matsuzaki on 12/08/01.
//  Copyright (c) 2012 KITec Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    CGPoint start, end;
    volatile Boolean running;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
-(CGRect)updateRect;
- (IBAction)run:(id)sender;
- (IBAction)aaChanged:(id)sender;
- (IBAction)naoChanged:(id)sender;
@property (retain, nonatomic) IBOutlet UIImageView *image;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) IBOutlet UIProgressView *progress;
@property (retain, nonatomic) IBOutlet UISwitch *subsampling;
@property (retain, nonatomic) IBOutlet UISlider *aosubsumpling;

@end
