#import "PubgLoad.h"
#import <UIKit/UIKit.h>
#import "JHPP.h"
#import "JHDragView.h"
#import "ImGuiLoad.h"
#import "ImGuiDrawView.h"
#import "UIManager.h"
#import "../API/APIClient.h"

@interface PubgLoad()
@property (nonatomic, strong) ImGuiDrawView *vna;
@end

@implementation PubgLoad
static PubgLoad *extraInfo;
UIWindow *mainWindow;

+ (void)load {
    [super load];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        mainWindow = [UIApplication sharedApplication].keyWindow;
        extraInfo = [PubgLoad new];
        apiclient_set_token("363f50e525ad5acd2e8fa5cfd8b232f981a214fea6328fe3862f4bb8cefbcd53");
        apiclient_set_language("en");
        apiclient_paid(^{
            [extraInfo initTapGes];
            [extraInfo tapIconView];
            [extraInfo initTapGes2];
            [extraInfo tapIconView2];
        });
    });
}

-(void)initTapGes {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.numberOfTapsRequired = 2;
    tap.numberOfTouchesRequired = 3;
    [[JHPP currentViewController].view addGestureRecognizer:tap];
    [tap addTarget:self action:@selector(tapIconView)];
}

-(void)initTapGes2 {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.numberOfTapsRequired = 2;
    tap.numberOfTouchesRequired = 2;
    [[JHPP currentViewController].view addGestureRecognizer:tap];
    [tap addTarget:self action:@selector(tapIconView2)];
}

-(void)tapIconView2 {
    if (!_vna) { _vna = [[ImGuiDrawView alloc] init]; }
    [ImGuiDrawView showChange:false];
    [[UIApplication sharedApplication].windows[0].rootViewController.view addSubview:_vna.view];
    [[UIManager shared] hideMenu];
}

-(void)tapIconView {
    if (!_vna) { _vna = [[ImGuiDrawView alloc] init]; }
    [ImGuiDrawView showChange:false];
    [[UIApplication sharedApplication].windows[0].rootViewController.view addSubview:_vna.view];
    [[UIManager shared] setupUI];
    [[UIManager shared] showMenu];
}
@end
