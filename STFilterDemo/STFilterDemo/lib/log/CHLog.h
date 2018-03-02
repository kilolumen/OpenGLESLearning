//
//  CHLog.h
//  WeiBo
//
//  Created by Seamus on 11-5-5.
//  Copyright 2011年 Seamus. All rights reserved.
//

#import "ExtendNSLogFunctionality.h"

#ifdef DEBUG
#define devLog(args...) ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args)
#else
#define devLog(...)
#endif
