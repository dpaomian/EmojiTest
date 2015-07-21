//
//  FaceToolBar.h
//  TestKeyboard
//
//  Created by wangjianle on 13-2-26.
//  Copyright (c) 2013年 wangjianle. All rights reserved.
//
#define Time  0.25
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define  keyboardHeight 216
#define  toolBarHeight 45
#define  choiceBarHeight 35
#define  facialViewWidth SCREEN_WIDTH - 20
#define  facialViewHeight 140
#define  buttonWh 34
#import <UIKit/UIKit.h>
#import "FacialView.h"
#import "UIExpandingTextView.h"

@protocol FaceToolBarDelegate <NSObject>
- (void)emojiString:(NSString *)inputText;
- (void)deleteString;
@end

@interface FaceToolBar : UIView<facialViewDelegate,UIExpandingTextViewDelegate,UIScrollViewDelegate>
{
    UIScrollView *scrollView;//表情滚动视图
    UIPageControl *pageControl;//页面显示控件
    UIButton      *sendButton;//发送按钮
    
    UIView *theSuperView;

}
@property (nonatomic,retain)  UIView    *theSuperView;
@property (nonatomic,assign) id<FaceToolBarDelegate> delegate;

-(id)initWithFrame:(CGRect)frame superView:(UIView *)superView;
- (void)showFaceKeyboard;//显示表情键盘
-(void)disFaceKeyboard;//隐藏表情键盘

@end
