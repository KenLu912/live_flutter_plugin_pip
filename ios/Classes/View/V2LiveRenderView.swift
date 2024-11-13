//
//  V2LiveRenderView.swift
//  live_flutter_plugin
//
//  Created by abyyxwang on 2021/12/21.
//

import UIKit
import Flutter

@objc protocol V2LiveRenderViewDelegate: NSObjectProtocol{
    func destroyRenderView(viewId: Int64)
}

class V2LiveRenderView: UIView {
    
    enum V2LiveRenderViewMethod: String {
        case destroyRenderView
    }
    
    weak var delegate: V2LiveRenderViewDelegate? = nil
    
    private let channel: FlutterMethodChannel
    let viewId: Int64
    init(frame: CGRect, messenger: FlutterBinaryMessenger, viewId: Int64) {
        self.channel = FlutterMethodChannel(name: "tx_Live_video_view_\(viewId)", binaryMessenger: messenger)
        self.viewId = viewId
        super.init(frame: frame)
        self.channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            self.handle(call, result: result)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func destroy() {
        channel.setMethodCallHandler(nil)
    }
    
    deinit {
        debugPrint("V2LiveRenderView deinit")
    }
}

extension V2LiveRenderView {
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let method = V2LiveRenderViewMethod(rawValue: call.method) else {
            result(FlutterMethodNotImplemented)
            return
        }
        switch method {
        case .destroyRenderView:
            delegate?.destroyRenderView(viewId: viewId)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension V2LiveRenderView: FlutterPlatformView {
    func view() -> UIView {
        return self
    }
}
