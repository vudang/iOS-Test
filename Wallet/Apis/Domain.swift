//
//  Domain.swift
//  Wallet
//
//  Created by Vu Dang on 7/20/21.
//  Copyright © 2021 Vu Dang. All rights reserved.
//

import Foundation

public class API: NSObject {
    internal static var customPath: String?
    internal static var port: Int = 9000
    
    /// Change Port For Debug Mode
    ///
    /// - Parameter port: 11000: driver 9000: client
    public static func changePort(modeDev port: Int) {
        self.port = port
    }
    
    /// Set custom debug mode with custom url
    ///
    /// - Parameter pathURL: full url path with scheme
    public static func customPathForDebug(pathURL: String) {
        self.customPath = pathURL
    }
    
    private override init() {
        super.init()
    }
    
    internal static let domain: String = {
        let path = "https://www.coinhako.com"
        return path
    }()
}
