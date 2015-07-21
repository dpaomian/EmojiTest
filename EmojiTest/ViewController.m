//
//  ViewController.m
//  EmojiTest
//
//  Created by wwr on 15/6/12.
//  Copyright (c) 2015年 wwr. All rights reserved.
//

#import "ViewController.h"
#import "HPGrowingTextView.h"
#import "FaceToolBar.h"
#import "MessageCell.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width) //屏幕宽度
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height) //屏幕高度

#define kTextInputViewHeight 50
#define kChatToolViewHeight 200
#define NAV_HEIGHT 64


@interface ViewController ()<FaceToolBarDelegate,HPGrowingTextViewDelegate,UITableViewDataSource, UITableViewDelegate>
{
    UITableView        *myTableView;
    NSMutableArray     *_allMessagesFrame;//数据源
    
    UIView              *textInputView;
    UIImageView         *backImageView;//整个消息条背景
    HPGrowingTextView   *_textview;
    UIImageView         *entryImageView;//消息框背景
    
    BOOL isMove;//键盘是否获取第一响应
    
    FaceToolBar         *emojiBar;//表情模板
    UIButton            *expressionButton;//表情按钮
    
    NSDictionary *_expressionDic;//key是[f001],value是[汉字]
    NSDictionary *_dicExpression;//key是[汉字],value是[f001]
    NSRegularExpression *_customEmojiRegular;
    NSRegularExpression *_otherRegular;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.title = @"模式一";
    
    _allMessagesFrame  = [[NSMutableArray alloc]init];
    [self setMyTableView];
    [self getUseData];
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    
    isMove = NO;
    
    NSString *expressionPlist = [[NSBundle mainBundle] pathForResource:@"expression2" ofType:@"plist"];
    _expressionDic = [[NSDictionary alloc] initWithContentsOfFile:expressionPlist];
    
    expressionPlist = [[NSBundle mainBundle] pathForResource:@"expression1" ofType:@"plist"];
    _dicExpression = [[NSDictionary alloc] initWithContentsOfFile:expressionPlist];
    
    _customEmojiRegular = [[NSRegularExpression alloc] initWithPattern:@"\\[[A-Z\\u4e00-\\u9fa5\\~]+\\]" options:NSRegularExpressionCaseInsensitive error:nil];
    _otherRegular = [[NSRegularExpression alloc] initWithPattern:@"\\[f0[0-9]{2}\\]|\\[f10[0-6]\\]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    [self initWithTextView];
    [self setEmojiTool];
    
    //用于监听键盘的状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardUp:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDown:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)setMyTableView
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAV_HEIGHT) style:UITableViewStyleGrouped];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.backgroundView = nil;
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:myTableView];
}

//测试数据 需删除
-(void)getUseData
{
    Message *useMessage1 = [[Message alloc]init];
    useMessage1.icon = @"";
    useMessage1.time = @"2015-06-15 12:16:08";
    useMessage1.content = @"我的在么 哈哈哈哈[f001][f066] 😄";
    useMessage1.phone = @"3561";
    useMessage1.type = 0;
    [_allMessagesFrame addObject:useMessage1];
    
    Message *useMessage2 = [[Message alloc]init];
    useMessage2.icon = @"";
    useMessage2.time = @"2015-06-15 13:16:08";
    useMessage2.content = @"我哈哈哈[f031][f066] 😄我哈哈哈[f031][f066]我哈哈哈[f031][f066]";
    useMessage2.phone = @"3561";
    useMessage2.type = 1;
    [_allMessagesFrame addObject:useMessage2];
    
    [_allMessagesFrame addObject:useMessage1];
    [_allMessagesFrame addObject:useMessage2];
    [_allMessagesFrame addObject:useMessage1];
    [_allMessagesFrame addObject:useMessage2];
    [_allMessagesFrame addObject:useMessage1];
    
    Message *useMessage3 = [[Message alloc]init];
    useMessage3 = useMessage2;
    useMessage3.type = 0;
    useMessage3.content = @"我不知道这真的是什么在那里的，写也我哈哈哈[f031][f066]我哈哈哈[f031][f066]写不清楚找也找不到";
    [_allMessagesFrame addObject:useMessage3];
    [_allMessagesFrame addObject:useMessage1];
    useMessage3.type = 1;
    [_allMessagesFrame addObject:useMessage3];
    [_allMessagesFrame addObject:useMessage1];
    [_allMessagesFrame addObject:useMessage2];
    useMessage3.type = 1;
    [_allMessagesFrame addObject:useMessage3];
    
    [myTableView reloadData];
    
}

//设置底部发送栏
- (void)initWithTextView
{
    float yh = SCREEN_HEIGHT - NAV_HEIGHT - kTextInputViewHeight;
  
    textInputView = [[UIView alloc] initWithFrame:CGRectMake(0, yh, SCREEN_WIDTH, kTextInputViewHeight)];
    textInputView.layer.contents = (__bridge id)([UIImage imageNamed:@"message_sendBar_bg.png"].CGImage);
    _textview = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(11, 7.5, SCREEN_WIDTH-104, 34)];
    _textview.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    _textview.isScrollable = NO;
    _textview.minNumberOfLines = 1;
    _textview.maxNumberOfLines = 2;
    _textview.returnKeyType = UIReturnKeySend;
    _textview.enablesReturnKeyAutomatically = YES;
    _textview.font = [UIFont systemFontOfSize:15.0f];
    _textview.delegate = self;
    _textview.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    _textview.backgroundColor = [UIColor clearColor];
    
    UIImage *rawEntryBackground = [UIImage imageNamed:@"message_input_bg.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(10, 7.5, SCREEN_WIDTH-70-34,34);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    //表情按钮
    expressionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    expressionButton.frame = CGRectMake(SCREEN_WIDTH-85, 7.5, 21, 34);
    expressionButton.tag = 0;
    expressionButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [expressionButton addTarget:self action:@selector(faceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [expressionButton setBackgroundImage:[UIImage imageNamed:@"message_ico_face.png"] forState:UIControlStateNormal];
    [expressionButton setBackgroundImage:[UIImage imageNamed:@"message_ico_face.png"] forState:UIControlStateHighlighted];
    [textInputView addSubview:expressionButton];
    
    //表情按钮
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(SCREEN_WIDTH-60, 7.5, 50, 34);
    expressionButton.tag = 0;
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    sendButton.backgroundColor = [UIColor clearColor];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [sendButton setTitle:@"发送" forState:UIControlStateHighlighted];
    [sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [textInputView addSubview:sendButton];
    
    [textInputView addSubview:entryImageView];
    [textInputView addSubview:_textview];
    [self.view addSubview:textInputView];
}

//设置表情模板
- (void)setEmojiTool
{
    emojiBar=[[FaceToolBar alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT- toolBarHeight,SCREEN_WIDTH,toolBarHeight) superView:self.view];
    emojiBar.delegate=self;
    [self.view addSubview:emojiBar];
}
#pragma mark -键盘操作
//表情按钮的启用
- (void)faceButtonClicked:(UIButton*)sender
{
    if (sender.tag == 0)
    {
        [_textview resignFirstResponder];
        [emojiBar showFaceKeyboard];
        [self showFaceKeyBoardMode];
        expressionButton.tag = 1;
        [expressionButton setBackgroundImage:[UIImage imageNamed:@"message_ico_keyboard.png"] forState:UIControlStateNormal];
    }
    else
    {
        [emojiBar disFaceKeyboard];
        expressionButton.tag = 0;
        [expressionButton setBackgroundImage:[UIImage imageNamed:@"message_ico_face.png"] forState:UIControlStateNormal];
        [_textview becomeFirstResponder];
    }
}
//显示表情键盘
- (void)showFaceKeyBoardMode
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.5];
    textInputView.frame = CGRectMake(textInputView.frame.origin.x, SCREEN_HEIGHT - NAV_HEIGHT - 216, textInputView.frame.size.width, textInputView.frame.size.height);
    [UIView commitAnimations];
    
     NSLog(@"显示表情键盘textInputView  %f,%f,%f,%f",textInputView.frame.origin.x,textInputView.frame.origin.y,textInputView.frame.size.width,textInputView.frame.size.height);
}

//隐藏表情键盘
- (void)hideFaceKeyBoardMode
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.5];
    float heights = SCREEN_HEIGHT - NAV_HEIGHT;
    textInputView.frame = CGRectMake(textInputView.frame.origin.x, heights - textInputView.frame.size.height, textInputView.frame.size.width, textInputView.frame.size.height);
    [UIView commitAnimations];
    
    NSLog(@"隐藏表情键盘textInputView  %f,%f,%f,%f",textInputView.frame.origin.x,textInputView.frame.origin.y,textInputView.frame.size.width,textInputView.frame.size.height);
}

//把表情文字转成通用的表情图片，例:[调皮]-> [f001]
- (NSMutableAttributedString *)expressionTransform
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
    NSString *msg = _textview.text;
    NSUInteger location = 0;
    NSArray *emjios = nil;
    emjios = [_customEmojiRegular matchesInString:msg options:NSMatchingWithTransparentBounds range:NSMakeRange(0, msg.length)];
    for (NSTextCheckingResult *result in emjios)
    {
        NSRange range = result.range;
        NSString *subStr = [msg substringWithRange:NSMakeRange(location, range.location - location)];
        NSMutableAttributedString *attSubStr = [[NSMutableAttributedString alloc] initWithString:subStr];
        [attrStr appendAttributedString:attSubStr];
        
        location = range.location + range.length;
        
        NSString *emojiKey = [msg substringWithRange:range];
        NSString *imageName = _dicExpression[emojiKey];
        if (imageName)
        {
            NSMutableAttributedString *replaceStr = [[NSMutableAttributedString alloc] initWithString:imageName];
            //            NSRange __range = NSMakeRange([attSubStr length], 1);
            [attrStr appendAttributedString:replaceStr];
        }
        else
        {
            NSMutableAttributedString *originalStr = [[NSMutableAttributedString alloc] initWithString:emojiKey];
            [attrStr appendAttributedString:originalStr];
        }
    }
    if (location < [msg length])
    {
        NSRange range = NSMakeRange(location, [msg length] - location);
        NSString *subStr = [msg substringWithRange:range];
        NSMutableAttributedString *attrSubStr = [[NSMutableAttributedString alloc] initWithString:subStr];
        [attrStr appendAttributedString:attrSubStr];
    }
    return attrStr;
}

//把通用的表情图片转成表情文字，例:[f001]-> [调皮]
- (NSString *)transformExpression:(NSString *)textString
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
    NSString *msg = textString;
    NSUInteger location = 0;
    NSArray *emjios = nil;
    emjios = [_otherRegular matchesInString:msg options:NSMatchingWithTransparentBounds range:NSMakeRange(0, msg.length)];
    for (NSTextCheckingResult *result in emjios)
    {
        NSRange range = result.range;
        NSString *subStr = [msg substringWithRange:NSMakeRange(location, range.location - location)];
        NSMutableAttributedString *attSubStr = [[NSMutableAttributedString alloc] initWithString:subStr];
        [attrStr appendAttributedString:attSubStr];
        
        location = range.location + range.length;
        
        NSString *emojiKey = [msg substringWithRange:range];
        NSString *imageName = _expressionDic[emojiKey];
        if (imageName)
        {
            NSMutableAttributedString *replaceStr = [[NSMutableAttributedString alloc] initWithString:imageName];
            //            NSRange __range = NSMakeRange([attSubStr length], 1);
            [attrStr appendAttributedString:replaceStr];
        }
        else
        {
            NSMutableAttributedString *originalStr = [[NSMutableAttributedString alloc] initWithString:emojiKey];
            [attrStr appendAttributedString:originalStr];
        }
    }
    if (location < [msg length])
    {
        NSRange range = NSMakeRange(location, [msg length] - location);
        NSString *subStr = [msg substringWithRange:range];
        NSMutableAttributedString *attrSubStr = [[NSMutableAttributedString alloc] initWithString:subStr];
        [attrStr appendAttributedString:attrSubStr];
    }
    return [attrStr string];
}

#pragma mark - FaceToolBarDelegate
//添加表情
- (void)emojiString:(NSString *)inputText
{
    NSString *inputExpression = [_expressionDic objectForKey:inputText];
    NSString *newStr=[NSString stringWithFormat:@"%@%@",_textview.text,inputExpression];
    [_textview setText:newStr];
    
    NSLog(@"newStr = %@",newStr);
    
}
//删除表情
- (void)deleteString
{
    NSString *newStr;
    if (_textview.text.length>=4)
    {
        NSString *emojiKey = [_textview.text substringFromIndex:(_textview.text.length - 4)];
        NSString *emojiStr = [_dicExpression objectForKey:emojiKey];
        //第三方表情
        if ([[EmojiNew allEmoji] containsObject:emojiStr])
        {
            //            DLog(@"删除emoji %@",[_textview.text substringFromIndex:_textview.text.length-6]);
            newStr=[_textview.text substringToIndex:_textview.text.length-4];
        }
        else
        {
            //苹果输入法表情
            if ([self stringContainsEmoji:[_textview.text substringFromIndex:_textview.text.length-2]]==YES)
            {
                newStr=[_textview.text substringToIndex:_textview.text.length-2];
            }
            else
            {
                newStr=[_textview.text substringToIndex:_textview.text.length-1];
            }
        }
    }
    else if (_textview.text.length >= 2 &&_textview.text.length<4)
    {
        if ([self stringContainsEmoji:[_textview.text substringFromIndex:_textview.text.length-2]]==YES)
        {
            newStr=[_textview.text substringToIndex:_textview.text.length-2];
        }
        else
        {
            newStr=[_textview.text substringToIndex:_textview.text.length-1];
        }
    }
    else if (_textview.text.length>0)
    {
        newStr=[_textview.text substringToIndex:_textview.text.length-1];
    }
    _textview.text=newStr;
}

//判断是否是系统表情
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

#pragma mark HPGrowingTextViewDelegate
- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    if (expressionButton.tag == 1)
    {
        [emojiBar disFaceKeyboard];
        expressionButton.tag = 0;
        [expressionButton setBackgroundImage:[UIImage imageNamed:@"message_ico_face.png"] forState:UIControlStateNormal];
    }
}
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    NSLog(@"初始 %f,%f,%f,%f height = %f",growingTextView.frame.origin.x,growingTextView.frame.origin.y,growingTextView.frame.size.width,growingTextView.frame.size.height,height);
    
    float diff = (growingTextView.frame.size.height - height);
    CGRect r = textInputView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    textInputView.frame = r;
    
    NSLog(@"结束textInputView  %f,%f,%f,%f",textInputView.frame.origin.x,textInputView.frame.origin.y,textInputView.frame.size.width,textInputView.frame.size.height);
}
- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@""])
    {
        NSLog(@"删除键");
        //第三方表情
        if ([_textview.text length] >= 4)
        {
            NSString *emojiKey = [_textview.text substringFromIndex:(_textview.text.length - 4)];
            NSString *emojiStr = [_dicExpression objectForKey:emojiKey];
            if ([[EmojiNew allEmoji] containsObject:emojiStr])
            {
                _textview.text=[_textview.text substringToIndex:_textview.text.length-4];
                return NO;
            }
        }
    }
    if ([text isEqualToString:@"\n"])
    {
        [self sendButtonPressed:nil];//发送消息按钮实现
        
        return NO;
    }
    return YES;
}
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    if (growingTextView.returnKeyType == UIReturnKeyGo)
    {
        [_textview resignFirstResponder];
        NSLog(@"123");
    }
    return NO;
}

#pragma mark 键盘变化
- (void)keyBoardUp:(NSNotification *)notification
{
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    NSValue *rectValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect rect = [rectValue CGRectValue];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    textInputView.frame = CGRectMake(textInputView.frame.origin.x, rect.origin.y - textInputView.frame.size.height - 64, textInputView.frame.size.width, textInputView.frame.size.height);
    [UIView commitAnimations];
}

- (void)keyBoardDown:(NSNotification *)notification
{
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    float heights = SCREEN_HEIGHT - NAV_HEIGHT;
    textInputView.frame = CGRectMake(textInputView.frame.origin.x, heights - textInputView.frame.size.height, textInputView.frame.size.width, textInputView.frame.size.height);
    [UIView commitAnimations];
}


#pragma mark -发送文本消息

- (void)sendButtonPressed:(UIButton*)sender
{
    [_textview resignFirstResponder];
    [emojiBar disFaceKeyboard];
    [self hideFaceKeyBoardMode];
    expressionButton.tag = 0;
    
    NSString *msg = _textview.text;
    msg = [msg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (msg.length > 0)
    {
        NSString *textContent = [[self expressionTransform] string];
        NSLog(@"文本内容 ＝ %@",textContent);
        
        Message *useMessage2 = [[Message alloc]init];
        useMessage2.icon = @"";
        useMessage2.time = @"2015-06-15 13:16:08";
        useMessage2.content = textContent;
        useMessage2.phone = @"3561";
        useMessage2.type = 0;
        [_allMessagesFrame addObject:useMessage2];
        [myTableView reloadData];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_allMessagesFrame.count - 1 inSection:0];
        [myTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        _textview.text = @"";
    }
    else
    {
        NSLog(@"发送内容为空");
        
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _allMessagesFrame.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MessageCell *cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    Message *message = _allMessagesFrame[indexPath.row];
    [cell setCellContentWith:message];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell *cell = (MessageCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.cellView.frame.origin.y + cell.cellView.frame.size.height + 45;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
