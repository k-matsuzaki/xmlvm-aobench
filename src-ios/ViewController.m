//
//  ViewController.m
//  TemplateSingle
//
//  Created by matsuzaki on 12/08/01.
//  Copyright (c) 2012 KITec Inc. All rights reserved.
//

#import "ViewController.h"
#import "org_xmlvm_demo_aobench_AO.h"

void* renderProc(void *data);
static JAVA_OBJECT aoRender;
static int imageWidth, imageHeight;
static volatile Boolean stopRendering;

@implementation ViewController
@synthesize image;
@synthesize activityIndicator;
@synthesize progress;
@synthesize subsampling;
@synthesize aosubsumpling;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    printf("run\n");
    pthread_t pt;

    imageWidth = (int)image.bounds.size.width;
    imageHeight = (int)image.bounds.size.height;
        
    aoRender = __NEW_org_xmlvm_demo_aobench_AO();
    org_xmlvm_demo_aobench_AO___INIT____int_int(aoRender, imageWidth, imageHeight);
    org_xmlvm_demo_aobench_AO_setup__(aoRender);
    
    [self renderFull];
}

- (void)viewDidUnload
{
    [self setImage:nil];
    [self setActivityIndicator:nil];
    [self setProgress:nil];
    [self setSubsampling:nil];
    [self setNaosub:nil];
    [self setSubsampling:nil];
    [self setAosubsumpling:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)run:(id)sender {
    if (running) {
        stopRendering = true;
        while (running) {
            sleep(1);
        }
    }
    
    org_xmlvm_demo_aobench_AO_setup__(aoRender);
    [self renderFull];
}

- (void)renderFull {
    pthread_t pt;

    start.x = 0;
    start.y = 0;
    end.x = imageWidth;
    end.y = imageHeight;
    running = true;
    stopRendering = false;
    [activityIndicator startAnimating];
    
    pthread_create(&pt, NULL, &renderProc, self);
}

- (void)dealloc {
    [image release];
    [activityIndicator release];
    [progress release];
    [subsampling release];
    [subsampling release];
    [aosubsumpling release];
    [super dealloc];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch.view == image) {
        CGPoint p = [touch locationInView:image];
        NSLog(@"begin %f %f", p.x, p.y);
//        [self moreSample:(int)p.x:(int)p.y:10];
        start.x = p.x;
        start.y = p.y;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch.view == image) {
        CGPoint p = [touch locationInView:image];
        NSLog(@"move %f %f", p.x, p.y);
//        [self moreSample:(int)p.x:(int)p.y:10];
        end.x = p.x;
        end.y = p.y;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (start.x != end.x && start.y != end.y) {
        if (running) {
            stopRendering = true;
            while (running) {
                usleep(100);
            }
        }
        running = true;
        stopRendering = false;
        pthread_t pt;
        pthread_create(&pt, NULL, &renderProc, self);
    }
}

- (void)setRenderResult:(UIImage*)img:(Boolean)complete {
    [image performSelectorOnMainThread:@selector(setImage:)
                             withObject:img
                          waitUntilDone:false];
//    image.image = img;
    if (complete) {
        running = false;
        [activityIndicator stopAnimating];
        progress.progress = 1;
    }
}

-(CGRect)updateRect {
    return CGRectMake(MIN(start.x, end.x), MIN(start.y, end.y), abs(end.x - start.x), abs(end.y - start.y));
}

void* renderProc(void *data) {
    @autoreleasepool {
    ViewController *vc = (ViewController*)data;
    XMLVM_TRY_BEGIN(a)
        
        int NSUBSAMPLES = vc.subsampling.on ? 2 : 1;//2;
        int NAO_SAMPLES = (int)vc.aosubsumpling.value;//8;
        
        JAVA_OBJECT ao = aoRender;
        
        JAVA_OBJECT pixels = ((org_xmlvm_demo_aobench_AO*)ao)->fields.org_xmlvm_demo_aobench_AO.pixels_;
        //XMLVMArray_createSingleDimension(__CLASS_int, imageWidth * 3);
        JAVA_ARRAY_BYTE* ptr = ((JAVA_ARRAY_BYTE*) (((org_xmlvm_runtime_XMLVMArray*)pixels)->fields.org_xmlvm_runtime_XMLVMArray.array_));
        
        UIGraphicsBeginImageContext(CGSizeMake(imageWidth, imageHeight));
        
        [vc.image.image drawAtPoint:CGPointMake(0, 0)];
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        
        //    JAVA_BYTE* buffer = malloc(IMAGE_WIDTH * IMAGE_HEIGHT * 4);
        CGContextRef ctx = CGBitmapContextCreate(ptr, imageWidth, imageHeight,
                                                 8, imageWidth * 4, space, kCGImageAlphaNoneSkipLast);
        CGRect rect = [vc updateRect];
        for (int y = 0; y < rect.size.height; y++) {
            if (stopRendering)
                break;
            printf("%d/%d\n", y + 1, (int)rect.size.height);
            for (int x = 0; x < rect.size.width; x++) {
                if (x < 0 || x >= imageWidth || y < 0 || y >= imageHeight)
                    continue;
                org_xmlvm_demo_aobench_AO_pointRender___int_int_int_int(aoRender,
                                                                        (int)rect.origin.x + x, (int)rect.origin.y + y,
                                                                        NSUBSAMPLES, NAO_SAMPLES);
            }
            
            CGImageRef cimg = CGBitmapContextCreateImage(ctx);
            CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), cimg);
            [vc setRenderResult:UIGraphicsGetImageFromCurrentImageContext():false];
            CGImageRelease(cimg);
//            vc.progress.progress = (y + 1) / (float)rect.size.height;
            [vc.progress performSelectorOnMainThread:@selector(setProgress:)
                                          withObject:[NSNumber numberWithFloat:100.0 * (y + 1) / (float)rect.size.height]
                                       waitUntilDone:false];

        }
        printf("%d * %d\n", imageWidth, imageHeight);
        
        
        CGImageRef cimg = CGBitmapContextCreateImage(ctx);
        CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), cimg);
        [vc setRenderResult:UIGraphicsGetImageFromCurrentImageContext():true];
        
        CGImageRelease(cimg);
        
        CGColorSpaceRelease(space);
        
        XMLVM_TRY_END
        XMLVM_CATCH_BEGIN(a)
        XMLVM_CATCH_SPECIFIC(a,java_lang_Object,0)
        XMLVM_CATCH_END(a)
        XMLVM_RESTORE_EXCEPTION_ENV(a)
    label0:;
    }
    return NULL;
}
@end
