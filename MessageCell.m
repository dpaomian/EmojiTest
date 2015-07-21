//
//  MessageCell.m
//  EmojiTest
//
//  Created by mac on 15/6/15.
//  Copyright (c) 2015年 wwr. All rights reserved.
//

#define kContentW SCREEN_WIDTH-140 //内容宽度

#define BEGIN_FLAG @"["
#define END_FLAG @"]"

#define KFacialSizeWidth  20
#define KFacialSizeHeight 20
#define MAX_WIDTH  SCREEN_WIDTH - 160

//屏幕尺寸
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width) //屏幕宽度
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height) //屏幕高度

#import "MessageCell.h"

@interface MessageCell()
{
    UIImageView *_headImageView;
    UILabel     *_nameLabel;
    
    UILabel     *_contentLabel;
    UILabel     *_timeLabel;
}

@end

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        //内容label
        self.cellView = [[UIImageView alloc] init];
        [self addSubview:self.cellView];
        [self.contentView addSubview:_contentLabel];
        
        //图片ImageView
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.clipsToBounds = YES;
        [self.contentView addSubview:_headImageView];
        
        //nameLabel
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _headImageView.frame.size.height+_headImageView.frame.origin.y, 50, 20)];
        _nameLabel.font = [UIFont systemFontOfSize:12];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_nameLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.frame.size.width - 10 , 30)];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_timeLabel];
        
       
    }
    return self;
}

-(void)setCellContentWith:(Message *)message
{
    //头像内容
    if (message.icon.length == 0)
    {
        _headImageView.image = [UIImage imageNamed:@"center-logo"];
    }
    else
    {
        //程序里需解注释
        //[_headImageView sd_setImageWithURL:[NSURL URLWithString:message.icon]];
    }
    
    _nameLabel.text = message.phone;
    _timeLabel.text = message.time;
    
    if (_contentLabel)
    {
        [_contentLabel removeFromSuperview];
        
    }
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.backgroundColor = [UIColor clearColor];
    [self.cellView addSubview:_contentLabel];
    
    UIView *returnView =  [self assembleMessageAtIndex:message.content from:YES type:message.type];
    returnView.backgroundColor = [UIColor clearColor];
    returnView.frame= CGRectMake(0.0, 0.0, returnView.frame.size.width, returnView.frame.size.height + 20);
   
    [_contentLabel addSubview:returnView];
    
    
    //修改位置
    if (message.type == MessageTypeMe)
    {
        //右侧
        _headImageView.frame = CGRectMake(SCREEN_WIDTH-50, 0, 40, 40);
        _nameLabel.frame = CGRectMake(SCREEN_WIDTH-60, _headImageView.frame.size.height+_headImageView.frame.origin.y+5, 60, 20);
        
        _contentLabel.frame = CGRectMake(10, 10, returnView.frame.size.width, returnView.frame.size.height);
        
        self.cellView.frame = CGRectMake(SCREEN_WIDTH-(returnView.frame.size.width+20)-60, 0, returnView.frame.size.width+25, returnView.frame.size.height+20);
        self.cellView.image = [UIImage imageNamed:@"liuyan-bg2.png"];
        self.cellView.image = [self.cellView.image stretchableImageWithLeftCapWidth:self.cellView.image.size.width * 0.5 topCapHeight:self.cellView.image.size.height * 0.7];
        
        _timeLabel.frame = CGRectMake(0, self.cellView.frame.size.height+self.cellView.frame.origin.y+5, SCREEN_WIDTH-70, 20);
        _timeLabel.textAlignment = NSTextAlignmentRight;
        
    }
    else
    {
        //左侧
        _headImageView.frame = CGRectMake(10, 0, 40, 40);
        _nameLabel.frame = CGRectMake(0, _headImageView.frame.size.height+_headImageView.frame.origin.y+5, 60, 20);
        
        _contentLabel.frame = CGRectMake(15, 10, returnView.frame.size.width, returnView.frame.size.height);
        
        self.cellView.frame = CGRectMake(60, 0, returnView.frame.size.width+25, returnView.frame.size.height+20);
        self.cellView.image = [UIImage imageNamed:@"liuyan-bg1.png"];
        self.cellView.image = [self.cellView.image stretchableImageWithLeftCapWidth:self.cellView.image.size.width * 0.5 topCapHeight:self.cellView.image.size.height * 0.7];
                                
        _timeLabel.frame = CGRectMake(70, self.cellView.frame.size.height+self.cellView.frame.origin.y+5, SCREEN_WIDTH-70, 20);
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        
    }
  
}



#pragma mark -
#pragma mark 图文混排

//图文混排
-(void)getImageRange:(NSString*)message andMutableArray:(NSMutableArray*)array
{
    NSLog(@"message = %@",message);
    NSRange range=[message rangeOfString: BEGIN_FLAG];
    NSRange range1=[message rangeOfString: END_FLAG];
    //判断当前字符串是否还有表情的标志。
    if (range.length>0 && range1.length>0)
    {
        if (range.location > 0)
        {
            NSString *str;
            if (range1.location > range.location)
            {
                if (range1.location - range.location > 6)
                {
                    NSString *beginS = [message substringWithRange:NSMakeRange(range1.location - 6 + 1, 1)];
                    if ([beginS isEqualToString:BEGIN_FLAG])
                    {
                        [array addObject:[message substringToIndex:range1.location - 6 + 1 ]];
                        str = [message substringFromIndex:range1.location - 6 + 1];
                    }
                    else
                    {
                        [array addObject:[message substringToIndex:range1.location + 1]];
                        str = [message substringFromIndex:range1.location + 1];
                    }
                }
                else
                {
                    [array addObject:[message substringToIndex:range.location]];
                    [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
                    str = [message substringFromIndex:range1.location+1];
                }
            }
            else
            {
                [array addObject:[message substringToIndex:range1.location + 1]];
                str = [message substringFromIndex:range1.location+1];
            }
            [self getImageRange:str andMutableArray:array];
        }
        else
        {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的
            if (![nextstr isEqualToString:@""])
            {
                NSString *str;
                if (range1.location - range.location > 6)
                {
                    NSString *beginS = [message substringWithRange:NSMakeRange(range1.location - 6 + 1, 1)];
                    if ([beginS isEqualToString:BEGIN_FLAG])
                    {
                        [array addObject:[message substringToIndex:range1.location - 6 + 1 ]];
                        str = [message substringFromIndex:range1.location - 6 + 1];
                    }
                    else
                    {
                        [array addObject:[message substringToIndex:range1.location + 1]];
                        str = [message substringFromIndex:range1.location + 1];
                    }
                }
                else
                {
                    //                    [array addObject:[message substringToIndex:range.location]];
                    [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
                    str = [message substringFromIndex:range1.location+1];
                }
                [self getImageRange:str andMutableArray:array];
            }
            else
            {
                return;
            }
        }
        
    }
    else if (message != nil)
    {
        [array addObject:message];
    }
}

-(UIView *)assembleMessageAtIndex:(NSString *) message from:(BOOL)fromself type:(MessageType)type
{
    //表情字典
    NSString *expressionPlist = [[NSBundle mainBundle] pathForResource:@"expression2" ofType:@"plist"];
    NSDictionary *expressionDic = [[NSDictionary alloc] initWithContentsOfFile:expressionPlist];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self getImageRange:message andMutableArray:array];
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    NSArray *data = array;
    UIFont *fon = [UIFont fontWithName:@"Helvetica" size:15.0];
    CGFloat upX = 0;
    CGFloat upY = 0;
    CGFloat X = 0;
    CGFloat Y = 0;
    if (data)
    {
        for (int i=0;i < [data count];i++)
        {
            NSString *str=[data objectAtIndex:i];
            //从字典中找到[f001];
            NSString *useStr = [expressionDic objectForKey:str];
            if (useStr.length>0)
            {
                if (upX >= MAX_WIDTH)
                {
                    upY = upY + KFacialSizeHeight;
                    upX = 0;
                    X = MAX_WIDTH + 10;
                    Y = upY;
                }
                NSString *imageName=[str substringWithRange:NSMakeRange(1, str.length - 2)];
                imageName = [NSString stringWithFormat:@"%@.png",imageName];
                UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
                img.frame = CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight);
                [returnView addSubview:img];
                upX=KFacialSizeWidth+upX;
                if (X<MAX_WIDTH) X = upX;
            }
            else
            {
                NSLog(@"str = %@",str);
                for (int j = 0; j < [str length]; j++)
                {
                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                    NSString *tempStr;
                    if (j<str.length-1)
                    {
                        tempStr = [str substringWithRange:NSMakeRange(j, 2)];
                        if ([self stringContainsEmoji:tempStr]==YES)
                        {
                            temp = tempStr;
                            j++;
                        }
                    }
                    if (upX >= MAX_WIDTH)
                    {
                        upY = upY + KFacialSizeHeight;
                        upX = 0;
                        X = MAX_WIDTH + 10;
                        Y =upY;
                    }
                    CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(MAX_WIDTH + 10, 20) lineBreakMode:NSLineBreakByWordWrapping];
                    
                    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY,size.width,size.height)];
                    la.font = fon;
                    la.text = temp;
                    if (type == MessageTypeMe)
                    {
                        la.textColor = [UIColor blackColor];
                    }
                    else
                    {
                        la.textColor = [UIColor whiteColor];
                    }
                    la.backgroundColor = [UIColor clearColor];
                    [returnView addSubview:la];
                    upX=upX+size.width;
                    if (X<MAX_WIDTH)
                    {
                        X = upX;
                    }
                }
            }
        }
    }
    returnView.frame = CGRectMake(0.0f,0.0f, X, Y); //@ 需要将该view的尺寸记下，方便以后使用
    //    DLog(@"%.1f %.1f", X, Y);
    return returnView;
}

-(BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
     {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff)
         {
             if (substring.length > 1)
             {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f)
                 {
                     returnValue = YES;
                 }
             }
         }
         else if (substring.length > 1)
         {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3)
             {
                 returnValue = YES;
             }
             
         }
         else
         {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff)
             {
                 returnValue = YES;
             }
             else if (0x2B05 <= hs && hs <= 0x2b07)
             {
                 returnValue = YES;
             }
             else if (0x2934 <= hs && hs <= 0x2935)
             {
                 returnValue = YES;
             }
             else if (0x3297 <= hs && hs <= 0x3299)
             {
                 returnValue = YES;
             }
             else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50)
             {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
