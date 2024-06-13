//
//  ViewController.m
//  VideoPlayer-IOS
//
//  Created by 尹玉 on 2024/6/12.
//

#import "ViewController.h"
#import "CommonUtil.h"
#import "PngPreviewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // ---3.自定义播放按钮，点击后执行forwardToPlayer这个函数。
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(20, 100, 100, 50)];
    [btn addTarget:self action:@selector(display:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"视频播放" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:btn];
}

//这行代码定义了display方法，这是一个交互式方法，它通常与用户界面上的某个元素（如按钮）相关联。id参数sender是触发交互的对象，通常是指向那个按钮的引用。
- (IBAction)display:(id)sender {
    //这行代码在控制台打印了一条日志消息，表示用户请求显示图片。`
    NSLog(@"Display Pic...");
    //这行代码调用CommonUtil类的bundlePath:方法，传入文件名@"1.png"，获取了包含1.png文件的路径。这个路径是在应用程序包（bundle）中，因此图片文件应该位于应用程序的资源目录下
    NSString* pngFilePath = [CommonUtil bundlePath:@"1.png"];
    //这行代码创建了一个新的PngPreviewController对象，并将其设置为self的vc属性。PngPreviewController是一个控制器，用于预览图片。
    //viewControllerWithContentPath:contentFrame:是PngPreviewController的一个初始化方法，它接受图片文件的路径和预览内容的框架作为参数。
    PngPreviewController *vc = [PngPreviewController viewControllerWithContentPath:pngFilePath contentFrame:self.view.bounds];
    //这行代码将vc对象推送到self的navigationController栈中。这意味着一个新的视图控制器将被添加到导航控制器栈的顶部，并且通过过渡动画显示出来。
    [[self navigationController] pushViewController:vc animated:YES];
}

//这个方法在收到内存警告时被调用
- (void)didReceiveMemoryWarning {
    //确保父类的内存警告处理也被执行。注释提示说，这里应该释放可以重新创建的资源，以减少内存使用。
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
