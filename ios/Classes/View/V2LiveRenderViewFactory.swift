//
//  V2LiveRenderViewFactory.swift
//  live_flutter_plugin
//
//  Created by abyyxwang on 2021/12/21.
//

import Foundation
import Flutter

class V2LiveRenderViewFactory: NSObject {
    static public let SIGN: String = "v2_live_view_factory"
    private let messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }
    
    private(set) var viewMap: [Int64: FlutterPlatformView] = [:]
}

extension V2LiveRenderViewFactory: V2LiveRenderViewDelegate {
    
    func destroyRenderView(viewId: Int64) {
        guard let view = viewMap.removeValue(forKey: viewId) as? V2LiveRenderView else {
            return
        }
        view.destroy()
    }
}

extension V2LiveRenderViewFactory: FlutterPlatformViewFactory {
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        if let platformView = viewMap[viewId] {
            return platformView
        }
        let platformView = V2LiveRenderView(frame: frame, messenger: self.messenger, viewId: viewId)
        platformView.delegate = self
        viewMap[viewId] = platformView
        return platformView
    }
}

extension V2LiveRenderViewFactory: PlatformViewProvider {
    func getViewBy(viewID: Int64) -> FlutterPlatformView? {
        return viewMap[viewID]
    }
}
