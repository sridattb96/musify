//
//  ViewController.h
//  ACRCloudDemo
//
//  Created by olym on 15/3/29.
//  Copyright (c) 2015年 ACRCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet UILabel *stateLable;
@property (weak, nonatomic) IBOutlet UILabel *volumeLable;
@property (weak, nonatomic) IBOutlet UILabel *costLable;
@property (weak, nonatomic) IBOutlet UITextView *resultView;

- (IBAction)startRecognition:(id)sender;

- (IBAction)stopRecognition:(id)sender;

- (IBAction)connectMyo:(id)sender;

@end

