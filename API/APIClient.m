#import "APIClient.h"
#import <UIKit/UIKit.h>

static NSString *_apiToken = nil;
static NSString *_language = @"en";
static NSString *const kAPIBaseURL = @"https://web-design-tool--hynlkong.replit.app";
static NSString *const kKeySaveKey = @"AlQhtani_LicenseKey";

static void showKeyAlert(void (^onValid)(void));
static void validateKey(NSString *key, void (^onValid)(void));
static void showError(NSString *msg, void (^onValid)(void));
static void showMessage(NSString *msg, void (^onValid)(void));

void apiclient_set_token(const char *token) {
    if (token) _apiToken = [NSString stringWithUTF8String:token];
}

void apiclient_set_language(const char *lang) {
    if (lang) _language = [NSString stringWithUTF8String:lang];
}

static void showKeyAlert(void (^onValid)(void)) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Al-Qhtani"
            message:@"Enter your license key to continue"
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
            tf.placeholder = @"ELBASANLLIU1010-XXXX-XXXX-XXXX";
            tf.autocorrectionType = UITextAutocorrectionTypeNo;
            tf.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
            NSString *saved = [[NSUserDefaults standardUserDefaults] stringForKey:kKeySaveKey];
            if (saved) tf.text = saved;
        }];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Activate" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
            NSString *key = alert.textFields.firstObject.text;
            if (!key || key.length < 5) { showKeyAlert(onValid); return; }
            validateKey(key, onValid);
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:ok];
        [alert addAction:cancel];
        UIViewController *root = [UIApplication sharedApplication].windows.firstObject.rootViewController;
        while (root.presentedViewController) root = root.presentedViewController;
        [root presentViewController:alert animated:YES completion:nil];
    });
}

static void validateKey(NSString *key, void (^onValid)(void)) {
    NSURL *url = [NSURL URLWithString:[kAPIBaseURL stringByAppendingString:@"/api/auth/validate"]];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    body[@"key"] = key;
    body[@"device"] = [[UIDevice currentDevice] name];
    if (_apiToken) body[@"token"] = _apiToken;
    req.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    [[NSURLSession.sharedSession dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *resp, NSError *error) {
        if (error || !data) {
            dispatch_async(dispatch_get_main_queue(), ^{ showError(@"Network error. Check your connection.", onValid); });
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([json[@"valid"] boolValue]) {
            [[NSUserDefaults standardUserDefaults] setObject:key forKey:kKeySaveKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSString *msg = json[@"message"];
            if (msg.length > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{ showMessage(msg, onValid); });
            } else {
                dispatch_async(dispatch_get_main_queue(), onValid);
            }
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kKeySaveKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            dispatch_async(dispatch_get_main_queue(), ^{ showError(@"Invalid or expired key. Try again.", onValid); });
        }
    }] resume];
}

static void showError(NSString *msg, void (^onValid)(void)) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Al-Qhtani" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a){ showKeyAlert(onValid); }]];
    UIViewController *root = [UIApplication sharedApplication].windows.firstObject.rootViewController;
    while (root.presentedViewController) root = root.presentedViewController;
    [root presentViewController:alert animated:YES completion:nil];
}

static void showMessage(NSString *msg, void (^onValid)(void)) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Al-Qhtani" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a){ if (onValid) onValid(); }]];
    UIViewController *root = [UIApplication sharedApplication].windows.firstObject.rootViewController;
    while (root.presentedViewController) root = root.presentedViewController;
    [root presentViewController:alert animated:YES completion:nil];
}

void apiclient_paid(void (^callback)(void)) {
    NSString *saved = [[NSUserDefaults standardUserDefaults] stringForKey:kKeySaveKey];
    if (saved.length > 5) {
        validateKey(saved, callback);
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{ showKeyAlert(callback); });
    }
}
