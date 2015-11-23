//
//  ViewController.m
//  Example
//
//  Created by muyexi on 11/19/15.
//  Copyright © 2015 Jianshu. All rights reserved.
//

#import "ViewController.h"
#import "MXNetworkDiagnoser.h"

@interface ViewController () <MXNetworkDiagnoserDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) MXNetworkDiagnoser *diagnoser;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *domains = @[@"baidu.com"];
    self.diagnoser = [[MXNetworkDiagnoser alloc] initWithUserID:@"USER_ID" domains:domains];;
    self.diagnoser.delegate = self;
    [self.diagnoser startDiagnose];
}

#pragma mark - HGNetworkDiagnoserDelegate
- (void)startDiagnose {
    
}

- (void)addDiagnoseLogLine:(NSString *)string {
    self.textView.text = [self.textView.text stringByAppendingString:string];
    NSLog(@"%@",string);
}

- (void)endDiagnoseWithLog:(NSString *)string {
    
}

@end
