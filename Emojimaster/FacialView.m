//
//  FacialView.m
//  KeyBoardTest
//
//  Created by wangqiulei on 11-8-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FacialView.h"

//屏幕尺寸
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width) //屏幕宽度
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height) //屏幕高度

@implementation FacialView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        faces=[EmojiNew allEmoji];
    }
    return self;
}

-(void)loadFacialView:(int)page size:(CGSize)size
{
	//row number
	for (int i=0; i<3; i++)
    {
		//column numer
		for (int y=0; y<7; y++)
        {
            float spaceWidth = (SCREEN_WIDTH - 20 - size.width * 7) / 8.0;
			UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundColor:[UIColor clearColor]];
            [button setFrame:CGRectMake(spaceWidth + y * (size.width + spaceWidth), 22+i*(size.height+12), size.width, size.height)];
            if (i==2&&y==6)
            {
                [button setImage:[UIImage imageNamed:@"iOS-faceList-delN_big.png"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"iOS-faceList-delD_big.png"] forState:UIControlStateHighlighted];
                button.tag=10000;
                
            }
            else
            {
                if ((page==3&&i==2&&y!=6)||(page==3&&i==1))
                {
                    //表情键盘一共有71个加上每个页面都有个删除键6个页面 一共77个
                    button.userInteractionEnabled = NO;
                }
                else
                {
                    button.userInteractionEnabled = YES;
                    
                    [button.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:29.0]];
                    int btnTag = i*7+y+(page*20);
                    
                    NSString *imageStr = [faces objectAtIndex:btnTag];
                    imageStr = [imageStr substringToIndex:5];
                    imageStr = [imageStr substringFromIndex:1];
                    imageStr = [NSString stringWithFormat:@"%@.png",imageStr];
                    
                    [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageStr ofType:nil]] forState:UIControlStateNormal];
                    [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageStr ofType:nil]] forState:UIControlStateHighlighted];
                    [button setTitle: [faces objectAtIndex:btnTag] forState:UIControlStateNormal];
                    button.tag=btnTag;
                    
                }
            }
			[button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
          
			[self addSubview:button];
		}
	}
}


-(void)selected:(UIButton*)bt
{
    if (bt.tag==10000)
    {
        NSLog(@"点击删除");
        [delegate selectedFacialView:@"删除"];
    }
    else
    {
        faces=[EmojiNew allEmoji];
        NSString *str=[faces objectAtIndex:bt.tag];
        NSLog(@"点击其他%@",str);
        [delegate selectedFacialView:str];
    }	
}

- (void)dealloc {
    [super dealloc];
}
@end
