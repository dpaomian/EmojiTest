//
//  FaceToolBar.m
//  TestKeyboard
//
//  Created by wangjianle on 13-2-26.
//  Copyright (c) 2013年 wangjianle. All rights reserved.
//

#import "FaceToolBar.h"

//屏幕尺寸
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width) //屏幕宽度
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height) //屏幕高度

//判断系统版本是ios7以上
#define IOS7   ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)

@implementation FaceToolBar
@synthesize theSuperView,delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame superView:(UIView *)superView
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.theSuperView = superView;
        //创建表情键盘
        if (scrollView==nil)
        {
            scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, superView.frame.size.height, superView.frame.size.width, keyboardHeight)];
            [scrollView setBackgroundColor:[UIColor whiteColor]];
            for (int i=0; i<4; i++)
            {
                FacialView *fview=[[FacialView alloc] initWithFrame:CGRectMake(10+SCREEN_WIDTH*i, 0, facialViewWidth, facialViewHeight)];
                [fview setBackgroundColor:[UIColor clearColor]];
                [fview loadFacialView:i size:CGSizeMake(28, 28)];
                fview.delegate=self;
                [scrollView addSubview:fview];
                [fview release];
            }
        }
        [scrollView setShowsVerticalScrollIndicator:NO];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        scrollView.contentSize=CGSizeMake(SCREEN_WIDTH*4, keyboardHeight);
        scrollView.pagingEnabled=YES;
        scrollView.delegate=self;
        [superView addSubview:scrollView];
        [scrollView release];
       
        pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 150) / 2.0, superView.frame.size.height-20, 150, 30)];
        [pageControl setCurrentPage:0];
        pageControl.pageIndicatorTintColor=RGBACOLOR(195, 179, 163, 1);
        pageControl.currentPageIndicatorTintColor=RGBACOLOR(132, 104, 77, 1);
        pageControl.numberOfPages = 4;//指定页面个数
        [pageControl setBackgroundColor:[UIColor clearColor]];
        [pageControl addTarget:self action:@selector(changePage:)forControlEvents:UIControlEventValueChanged];
        [superView addSubview:pageControl];
        [pageControl release];
        
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    int page = scrollView.contentOffset.x / SCREEN_WIDTH;//通过滚动的偏移量来判断目前页面所对应的小白点
    pageControl.currentPage = page;//pagecontroll响应值的变化
}

//pagecontroll的委托方法
- (void)changePage:(id)sender
{
    NSInteger page = pageControl.currentPage;//获取当前pagecontroll的值
    [scrollView setContentOffset:CGPointMake(SCREEN_WIDTH * page, 0)];//根据pagecontroll的值来改变scrollview的滚动位置，以此切换到指定的页面
}
#pragma mark -
#pragma mark 表情键盘

//显示表情键盘
- (void)showFaceKeyboard
{
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.5];
    
    scrollView.frame = CGRectMake(0, self.theSuperView.frame.size.height-216+50, self.theSuperView.frame.size.width, keyboardHeight);
    pageControl.frame = CGRectMake((SCREEN_WIDTH - 150) / 2.0, self.theSuperView.frame.size.height - 30, 150, 30);//120
    [UIView commitAnimations];
}
//隐藏表情键盘
-(void)disFaceKeyboard
{
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.5];
    scrollView.frame = CGRectMake(0, theSuperView.frame.size.height + (IOS7?64:44), theSuperView.frame.size.width, keyboardHeight);
    pageControl.frame = CGRectMake(98, theSuperView.frame.size.height, 150, 30);
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark facialView delegate 点击表情键盘上的文字
-(void)selectedFacialView:(NSString*)str
{
    //NSLog(@"进代理了");
    if ([str isEqualToString:@"删除"])
    {
        if ([delegate respondsToSelector:@selector(deleteString)])
        {
            [delegate deleteString];
        }
    }
    else
    {
        NSString *newStr=[NSString stringWithFormat:@"%@",str];
       
        NSLog(@"点击其他后更新%lu,%@",(unsigned long)newStr.length,newStr);
        if ([delegate respondsToSelector:@selector(emojiString:)])
        {
            [delegate emojiString:newStr];
        }
    }
    //NSLog(@"出代理了");
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
