//
//  MetalLogging.h
//  Compositor-Services-Interaction
//
//  Created by AidanCarrier on 11/19/25.
//  Copyright © 2025 Apple. All rights reserved.
//
#pragma once

#include "MetalHeader.h"

#ifndef MetalLogging_h
#define MetalLogging_h

/// A logger for debugging Metal code
constant metal::os_log logger(/*subsytem*/"output_logger", /*category*/"category");

/// - Warning: Not Implemented Yet
class OutputMetalLogger {
    private:
        bool verbose;
    
    public:
    // Constructor
    OutputMetalLogger(bool verbose = false) : verbose(verbose) {
        
    }
    //Destructor
    ~OutputMetalLogger(){
        
    }
    /// - Warning: Not Implemented Yet
    void log() {
        if (verbose) {
//            logger.log_info(<#const constant char *format, ...#>)
        }
    }
};

#endif /* MetalLogging_h */
