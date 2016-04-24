//
//  ViewController.m
//  WliuUnReadCountLabel
//
//  Created by 6 on 16/4/24.
//  Copyright © 2016年 w66. All rights reserved.
//

#import "ViewController.h"
#import "WliuUnReadContactCountLabel.h"
@interface ViewController ()
{
    WliuUnReadContactCountLabel *lab;
}
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    //     Do any additional setup after loading the view, typically from a nib.
    
    lab = [[WliuUnReadContactCountLabel alloc] initWithFrame:CGRectMake(200, 200, 30, 30)];
    // 设置背景色
    lab.backgroundColor = [UIColor cyanColor];
    // 设置未读数
    lab.unReadCount = 166;
    // 设置删除类型
    lab.removeType = WliuUnReadContactCountLabelPanAndTapRemove;
    // 设置删除图片数组
    UIImage *image0 = [UIImage imageNamed:@"Wliu_UnReadRemove_0"];
    UIImage *image1 = [UIImage imageNamed:@"Wliu_UnReadRemove_1"];
    NSArray<UIImage *> *array = @[image0, image1, @1];
    lab.removeAnimationImagesArray = array;
    // 设置删除动效视图大小
    lab.removeImageViewLengthOfSide = 100.f;
    
    [self.view addSubview:lab];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
