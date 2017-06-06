//
//  ViewController.m
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2017/6/6.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "ViewController.h"
#import "PhotoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)photoClick:(id)sender {
    PhotoViewController *photoVC = [PhotoViewController new];
    [self.navigationController pushViewController:photoVC animated:YES];
}

- (IBAction)videoClick:(id)sender {
}

@end
