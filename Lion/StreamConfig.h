//
//  StreamConfig.h
//  Lion
//
//  Created by Bebek, Taha on 10/23/12.
//  Copyright (c) 2012 Bebek, Taha. All rights reserved.
//

#ifndef Lion_StreamConfig_h
#define Lion_StreamConfig_h

#ifdef __i386__
#define BROADCAST_URL @"rtmp://localhost:1935/Live_Broadcast"
#else
#define BROADCAST_URL @"rtmp://192.168.112.108:1935/Live_Broadcast"
#endif

#define STREAM_NAME @"mpegts.stream"

#endif
