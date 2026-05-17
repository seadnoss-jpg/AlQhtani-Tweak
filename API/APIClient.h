#pragma once
#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

void apiclient_set_token(const char *token);
void apiclient_set_language(const char *lang);
void apiclient_paid(void (^callback)(void));

#ifdef __cplusplus
}
#endif
