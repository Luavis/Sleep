//
//  main.m
//  Sleep
//
//  Created by Luavis on 2014. 8. 2..
//  Copyright (c) 2014년 Luavis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

OSStatus SendAppleEventToSystemProcess(AEEventID EventToSend)
{
    AEAddressDesc targetDesc;
    static const ProcessSerialNumber kPSNOfSystemProcess = { 0, kSystemProcess };
    AppleEvent eventReply = {typeNull, NULL};
    AppleEvent appleEventToSend = {typeNull, NULL};
    
    OSStatus error = noErr;
    
    error = AECreateDesc(typeProcessSerialNumber, &kPSNOfSystemProcess,
                         sizeof(kPSNOfSystemProcess), &targetDesc);
    
    if (error != noErr)
    {
        return(error);
    }
    
    error = AECreateAppleEvent(kCoreEventClass, EventToSend, &targetDesc,
                               kAutoGenerateReturnID, kAnyTransactionID, &appleEventToSend);
    
    AEDisposeDesc(&targetDesc);
    if (error != noErr)
    {
        return(error);
    }
    
    error = AESend(&appleEventToSend, &eventReply, kAENoReply,
                   kAENormalPriority, kAEDefaultTimeout, NULL, NULL);
    
    AEDisposeDesc(&appleEventToSend);
    if (error != noErr)
    {
        return(error);
    }
    
    AEDisposeDesc(&eventReply);
    
    return(error); 
}

int help(void) {
    printf("how to use\n");
    printf("sleep [-h hour] | [-m min] | [-s sec]\n");
    
    return -1;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        int wating_sec = 0;
        
        if(argc == 0) {
            wating_sec = 0;
        }
        else if(argc < 3) {
            return help();
        }
        else if(argc == 3) {
            
            if(!strcmp(argv[1], "-h")) {
                wating_sec = atoi(argv[2]) * 60 * 60;
            }
            else if(!strcmp(argv[1], "-m")) {
                wating_sec = atoi(argv[2]) * 60;
            }
            else if(!strcmp(argv[1], "-s")) {
                wating_sec = atoi(argv[2]);
            }
            else {
                return help();
            }
        }
        else {
            return help();
        }
        
        if(wating_sec < 0) {
            wating_sec = 0;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(wating_sec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            SendAppleEventToSystemProcess(kAESleep);
            exit(0);
        });
        
        dispatch_main();
    }
    return 0;
}
