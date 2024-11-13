//
//  MethodUtils.swift
//  live_flutter_plugin
//
//  Created by abyyxwang on 2021/12/21.
//

import Foundation
import Flutter
import TXLiteAVSDK_Professional
import TXCustomBeautyProcesserPlugin

/// Flutter方法取值函数
public class MethodUtils {
    public static func getMethodParams<T: Any>(call: FlutterMethodCall, key: String, resultType: T.Type) -> T? {
        guard let arguments = call.arguments as? [String: Any] else { return nil }
        guard let value = arguments[key] else { return nil }
        return value as? T
    }
}

/// Flutter-Result 回调处理
public class FlutterResultUtils {
    
    /// 处理Method-Result
    /// - Parameters:
    ///   - code: 错误码
    ///   - methodName: 接口名称
    ///   - paramKey: 参数key
    ///   - result: flutter回调
    static func handleMethod(code: TXLiveFlutterCode,
                             methodName: String,
                             paramKey: String,
                             result: FlutterResult? = nil) {
        switch code {
        case .paramNotFound:
            handle(code: code, msg: "\(methodName) Can not find param by key: \(paramKey)", details: nil, result: result)
        case .paramTypeError:
            handle(code: code, msg: "\(methodName) param type error key: \(paramKey)", details: nil, result: result)
        default:
            handle(code: code, result: result)
        }
    }
    
    /// 处理result回调
    static func handle(code: TXLiveFlutterCode = .unknown,
                       msg: String = "unknown msg",
                       details: Any? = nil,
                       result: FlutterResult? = nil) {
        Logger.error(content: "flutter error: \(msg)")
        let error = FlutterError(code: "\(code.rawValue)", message: msg, details: details)
        result?(error)
    }
}

/// Flutter-Result 回调处理
public class VideoFrameUtils {
    static func handleVideoFrame(_ videoFrame: V2TXLiveVideoFrame) -> [String: Any] {
        var videoFrameParams: [String: Any] = [:]
        videoFrameParams = ["pixelFormat": videoFrame.pixelFormat.rawValue,
                            "bufferType": videoFrame.bufferType.rawValue,
                            "width": videoFrame.width,
                            "height": videoFrame.height,
                            "rotation": videoFrame.rotation.rawValue,
        ]
        if videoFrame.bufferType == .nsData,
           let videoFrameData = videoFrame.data {
            videoFrameParams["data"] = FlutterStandardTypedData(bytes: videoFrameData)
        } else if videoFrame.bufferType == .texture {
            videoFrameParams["textureId"] = Int(videoFrame.textureId)
        } else if videoFrame.bufferType == .pixelBuffer {
            // TODO: - CVPixelBufferRef 复杂对象
        }
        return videoFrameParams
    }
}

@objc
public class ConvertBeautyFrame: NSObject {
    
    public static func convertToV2LiveBufferType(beautyBufferType: ITXCustomBeautyBufferType) -> V2TXLiveBufferType {
        switch beautyBufferType {
        case .Unknown:
            return .unknown
        case .PixelBuffer:
            return .pixelBuffer
        case .Data:
            return .nsData
        case .Texture:
            return .texture
        }
    }
        
    public static func convertToTRTCBufferType(beautyBufferType: ITXCustomBeautyBufferType) -> TRTCVideoBufferType {
        switch beautyBufferType {
        case .Unknown:
            return .unknown
        case .PixelBuffer:
            return .pixelBuffer
        case .Data:
            return .nsData
        case .Texture:
            return .texture
        }
    }
    
    public static func convertToV2LivePixelFormat(beautyPixelFormat: ITXCustomBeautyPixelFormat) -> V2TXLivePixelFormat {
        switch beautyPixelFormat {
        case .Unknown:
            return .unknown
        case .I420:
            return .I420
        case .Texture2D:
            return .texture2D
        case .BGRA:
            return .BGRA32
        case .NV12:
            return .NV12
        }
    }
    
    public static func convertToTRTCPixelFormat(beautyPixelFormat: ITXCustomBeautyPixelFormat) -> TRTCVideoPixelFormat {
        switch beautyPixelFormat {
        case .Unknown:
            return ._Unknown
        case .I420:
            return ._I420
        case .Texture2D:
            return ._Texture_2D
        case .BGRA:
            return ._32BGRA
        case .NV12:
            return ._NV12
        }
    }
    
    public static func convertV2VideoFrame(v2VideoFrame: V2TXLiveVideoFrame) -> ITXCustomBeautyVideoFrame {
        let beautyVideoFrame = ITXCustomBeautyVideoFrame()
        beautyVideoFrame.data = v2VideoFrame.data
        beautyVideoFrame.pixelBuffer = v2VideoFrame.pixelBuffer
        beautyVideoFrame.width = UInt(v2VideoFrame.width)
        beautyVideoFrame.height = UInt(v2VideoFrame.height)
        beautyVideoFrame.textureId = v2VideoFrame.textureId
        switch v2VideoFrame.rotation {
        case .rotation0:
            beautyVideoFrame.rotation = .rotation_0
        case .rotation90:
            beautyVideoFrame.rotation = .rotation_90
        case .rotation180:
            beautyVideoFrame.rotation = .rotation_180
        case .rotation270:
            beautyVideoFrame.rotation = .rotation_270
        default:
            beautyVideoFrame.rotation = .rotation_0
        }
        
        switch v2VideoFrame.pixelFormat {
        case .unknown:
            beautyVideoFrame.pixelFormat = .Unknown
        case .I420:
            beautyVideoFrame.pixelFormat = .I420
        case .texture2D:
            beautyVideoFrame.pixelFormat = .Texture2D
        case .BGRA32:
            beautyVideoFrame.pixelFormat = .BGRA
        case .NV12:
            beautyVideoFrame.pixelFormat = .NV12
        default:
            beautyVideoFrame.pixelFormat = .Unknown
        }
        
        beautyVideoFrame.bufferType = ITXCustomBeautyBufferType(rawValue: v2VideoFrame.bufferType.rawValue) ?? .Unknown
        return beautyVideoFrame
    }
    
    public static func convertTRTCVideoFrame(trtcVideoFrame: TRTCVideoFrame) -> ITXCustomBeautyVideoFrame {
        let beautyVideoFrame = ITXCustomBeautyVideoFrame()
        beautyVideoFrame.data = trtcVideoFrame.data
        beautyVideoFrame.pixelBuffer = trtcVideoFrame.pixelBuffer
        beautyVideoFrame.width = UInt(trtcVideoFrame.width)
        beautyVideoFrame.height = UInt(trtcVideoFrame.height)
        beautyVideoFrame.textureId = trtcVideoFrame.textureId
        
        switch trtcVideoFrame.rotation {
        case ._0:
            beautyVideoFrame.rotation = .rotation_0
        case ._90:
            beautyVideoFrame.rotation = .rotation_90
        case ._180:
            beautyVideoFrame.rotation = .rotation_180
        case ._270:
            beautyVideoFrame.rotation = .rotation_270
        default:
            beautyVideoFrame.rotation = .rotation_0
        }
        
        switch trtcVideoFrame.pixelFormat {
        case ._Unknown:
            beautyVideoFrame.pixelFormat = .Unknown
        case ._I420:
            beautyVideoFrame.pixelFormat = .I420
        case ._Texture_2D:
            beautyVideoFrame.pixelFormat = .Texture2D
        case ._32BGRA:
            beautyVideoFrame.pixelFormat = .BGRA
        case ._NV12:
            beautyVideoFrame.pixelFormat = .NV12
        default:
            beautyVideoFrame.pixelFormat = .Unknown
        }
        
        beautyVideoFrame.bufferType = ITXCustomBeautyBufferType(rawValue: trtcVideoFrame.bufferType.rawValue) ?? .Unknown
        beautyVideoFrame.timestamp = trtcVideoFrame.timestamp
        return beautyVideoFrame
    }
}
