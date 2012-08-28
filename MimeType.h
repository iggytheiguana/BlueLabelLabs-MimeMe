//
//  MimeType.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/30/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    kFROMFRIENDMIME,
    kRECENTMIME,
    kTOPFAVORITEDMIME,
    kSTAFFPICKEDMIME,
    kSENTMIME,
    kFAVORITEMIME,
    kGUESSEDMIME
} MimeType;
