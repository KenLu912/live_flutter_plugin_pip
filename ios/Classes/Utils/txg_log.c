//
//  txg_log.c
//  trtc_cloud_plugin
//
//  Created by jack on 2022/3/17.
//

#include "txg_log.h"

void txf_log_swift(TXELogLevel level, const char *file, int line, const char *func, const char *content) {
	txf_log(level, file, line, func, content);
}
