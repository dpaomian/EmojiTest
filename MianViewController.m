//
//  MianViewController.m
//  EmojiTest
//
//  Created by mac on 15/7/13.
//  Copyright (c) 2015年 wwr. All rights reserved.
//

#import "MianViewController.h"
#import "ViewController.h"
#import "EmojiOneViewController.h"

@interface MianViewController ()

@end

@implementation MianViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"表情键盘主界面";
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(20, 65, 200, 40);
    btn1.backgroundColor = [UIColor purpleColor];
    [btn1 setTitle:@"表情键盘 模式1" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn1.tag = 100;
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(20, 115, 200, 40);
    btn2.backgroundColor = [UIColor purpleColor];
    [btn2 setTitle:@"表情键盘 模式2" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn2.tag = 101;
    [self.view addSubview:btn2];
    
    
}

-(void)btnClick:(UIButton *)sender
{
    switch (sender.tag)
    {
        case 100:
        {
            ViewController *vc = [[ViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 101:
        {
            EmojiOneViewController *vc = [[EmojiOneViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
