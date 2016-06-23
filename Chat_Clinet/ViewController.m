//
//  ViewController.m
//  Chat_Clinet
//
//  Created by tarena on 15/4/22.
//  Copyright (c) 2015年 tarena. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSStreamDelegate>
@property (nonatomic, strong) NSInputStream *inputStream;

@property (nonatomic, strong)NSOutputStream *outputStream;
@property (weak, nonatomic) IBOutlet UIView *chatView;


@property (weak, nonatomic) IBOutlet UISwitch *switch1;
@property (weak, nonatomic) IBOutlet UISwitch *switch2;
@property (weak, nonatomic) IBOutlet UISwitch *switch3;
@property (weak, nonatomic) IBOutlet UISwitch *switch4;
@property (weak, nonatomic) IBOutlet UISwitch *switch5;
@property (weak, nonatomic) IBOutlet UISwitch *switch6;
@property (weak, nonatomic) IBOutlet UISwitch *switch7;
@property (weak, nonatomic) IBOutlet UISwitch *switch8;
@property (weak, nonatomic) IBOutlet UISlider *slider1;
@property (weak, nonatomic) IBOutlet UISlider *slider2;

@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UILabel *firstER;
@property (strong, nonatomic) IBOutlet UILabel *secondER;
@property (strong, nonatomic) IBOutlet UILabel *thirdER;


@property(nonatomic,copy)NSString *receivedMessages;




@end
//初始化发送消息的前6个字节
int number1 = 0;
int number2 = 0;
int number3 = 0;
int number4 = 0;
int number5 = 0;
int number6 = 0;
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //  初始化消息数组
    //self.messages = [NSMutableArray new];
    
    // 初始化 Socket 网络连接
    [self initNetWorkCommunication];
    [self startTimer];
}

//  处理Socket 的回调事件
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream 打开了");
            //self.returnedMessage.text = @"已成功连接";
            break;
        // 处理服务器返回的数据
        case NSStreamEventHasBytesAvailable:
            //  1.先判断是否为输入流
            if(aStream == self.inputStream){
            //  2. 为读取数据准备缓冲
                unsigned char buffer[1024];
                long len;
            //  有数据就循环读取
                while([self.inputStream hasBytesAvailable]){
            //  3.  把流里面的数据读取到缓冲区
                    len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
                // 4. 判断实际是否写入了数据
                if (len > 0) {
                    //  5. 从缓冲区中读取，创建oc的字符串
                    NSString *text = [[NSString alloc] initWithBytes:buffer length:len encoding:NSUTF8StringEncoding];
                    self.receivedMessages = text;
                    if (text != nil) {
                        NSLog(@"收到服务器的消息:%@",text);
                        [self readReceivedMessages];
                        //self.returnedMessage.text = [NSString stringWithFormat:@"%@",text];
                        // 存入字符串数组
                        //[self.messages addObject:text];
                        // 刷新tableView
                        //[self.tView reloadData];
                    }
                }
            }
        }
            break;
        default:
            break;
    }
}
- (void)initNetWorkCommunication{
    //  1. 准备输入/输出流
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    // 2. 与服务器建立 Socket 连接
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)@"192.168.4.1",5000 , &readStream, &writeStream);
    
    self.inputStream = (__bridge NSInputStream *)(readStream);
    self.outputStream = (__bridge NSOutputStream *)(writeStream);
    
    // 3. 设置代理，用于接收服务器发送的消息
    self.inputStream.delegate = self;
    self.outputStream.delegate = self;
    
    // 4. 将输入/输出流注册到系统的RunLoop中
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    
    //  5. 打开输入/输出流
    [self.inputStream open];
    [self.outputStream open];
    
}
//启动定时器，每秒向服务器发送信息
-(void)startTimer{
      //NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendMessage) userInfo:nil repeats:YES];
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(sendMessage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
}
//客户端向服务器发送的具体信息
-(void)sendMessage{
    if ([self.switch1 isOn]) number1 += 8;
    if ([self.switch2 isOn]) number1 += 4;
    if ([self.switch3 isOn]) number1 += 2;
    if ([self.switch4 isOn]) number1 += 1;
    if ([self.switch5 isOn]) number2 += 8;
    if ([self.switch6 isOn]) number2 += 4;
    if ([self.switch7 isOn]) number2 += 2;
    if ([self.switch8 isOn]) number2 += 1;
    number3 = (int)self.slider1.value/16;
    number4 = (int)self.slider1.value%16;
    number5 = (int)self.slider2.value/16;
    number6 = (int)self.slider2.value%16;
    NSString *messaage1 = [NSString stringWithFormat:@"%X",number1];
    NSString *messaage2 = [NSString stringWithFormat:@"%X",number2];
    NSString *messaage3 = [NSString stringWithFormat:@"%X",number3];
    NSString *messaage4 = [NSString stringWithFormat:@"%X",number4];
    NSString *messaage5 = [NSString stringWithFormat:@"%X",number5];
    NSString *messaage6 = [NSString stringWithFormat:@"%X",number6];
    NSString *otherMessages = @"1111111111";
    //将各段字节的数据拼接在一起(不知为何initWithFormat:方法在这里不能用,所以采用下面的笨方法)
    NSString *sendMessage = [[[[[[messaage1 stringByAppendingString:messaage2]stringByAppendingString:messaage3]stringByAppendingString:messaage4]stringByAppendingString:messaage5]stringByAppendingString:messaage6]stringByAppendingString:otherMessages];
    //将要输入的信息转成NSData类
    NSLog(@"要发送的信息：%@",sendMessage);
    NSLog(@"第一项信息：%@",messaage1);
    NSLog(@"第二项信息：%@",messaage2);
    NSLog(@"第三项信息：%@",messaage3);
    NSLog(@"第四项信息：%@",messaage4);
    NSLog(@"第五项信息：%@",messaage5);
    NSLog(@"第六项信息：%@",messaage6);
    
    NSData *data = [sendMessage dataUsingEncoding:NSUTF8StringEncoding];
    //将数据写进输出流
    [self.outputStream write:[data bytes] maxLength:[data length]];
    NSLog(@"第一个数据：%d,%@",number1,messaage1);
    number1 = 0;
    number2 = 0;
    number3 = 0;
    number4 = 0;
    number5 = 0;
    number6 = 0;
}

//解析从服务器获取的信息
-(void)readReceivedMessages{
    //截取返回数据的后4位，表示模拟机运行的时长
    NSRange r1 = {12,2};
    NSString *date1 = [self.receivedMessages substringWithRange:r1];
    NSLog(@"收到的第一个字节的数据:%@",date1);
    [self analysis:date1];
    NSRange r2 = {14,2};
    NSString *date2 = [self.receivedMessages substringWithRange:r2];
    NSLog(@"收到的第二个字节的数据:%@",date2);
    [self analysis:date2];
    NSInteger time = ([self analysis:date1]<<8) | [self analysis:date2];
    NSInteger hours = time/3600;
    NSInteger minutes = (time/60)%60;
    NSInteger seconds = time%60;
    self.time.text = [NSString stringWithFormat:@"%ld时 %ld分 %ld秒",hours,minutes,seconds];
    //截取返回数据的前两位，表示第一个电位器的数值
    NSString *firstRheostat = [self.receivedMessages substringToIndex:2];
    NSLog(@"收到的第三个字节的数据:%@",firstRheostat);
    [self analysis:firstRheostat];
    self.firstER.text = [NSString stringWithFormat:@"%ld",(long)[self analysis:firstRheostat]];
    //截取返回数据的3-4位，表示第二个电位器的数值
    NSRange r3 = {2,2};
    NSString *secondRheostat = [self.receivedMessages substringWithRange:r3];
    NSLog(@"收到的第四个字节的数据:%@",secondRheostat);
    [self analysis:secondRheostat];
    self.secondER.text = [NSString stringWithFormat:@"%ld",(long)[self analysis:secondRheostat]];
    //截取返回数据的5-6位，表示第三个电位器的数值
    NSRange r4 = {4,2};
    NSString *thirdRheostat = [self.receivedMessages substringWithRange:r4];
    NSLog(@"收到的第五个字节的数据:%@",thirdRheostat);
    [self analysis:thirdRheostat];
    self.thirdER.text = [NSString stringWithFormat:@"%ld",(long)[self analysis:thirdRheostat]];
}

//解析从服务器传回的数据细节
-(NSInteger )analysis:(NSString *)string{
    int firstNumber = 0;
    int secondNumber = 0;
    //解析第一个数据
    char a = [string characterAtIndex:0];
    if (a >= '0' && a <= '9') {
        firstNumber = a-'0';
    }
    else if (a>='A'&&a<='F'){
        firstNumber = a-'A'+10;
    }
    //解析第二个数据
    char b = [string characterAtIndex:1];
    if (b>='0'&&b<='9') {
        secondNumber = b-'0';
    }
    else if (b>='A'&&b<='F'){
        secondNumber = b-'A'+10;
    }
    return (firstNumber<<4) | secondNumber;
}








@end
