//
//  SimpleWebServer.swift
//  AVSExample
//

import Foundation
import GCDWebServers

protocol SimpleWebServerDelegate {
    func startupComplete(webServerURL: NSURL)
    func configurationComplete(tokenExpirationTime: NSDate, currentAccessToken: String)
}

class SimpleWebServer: NSObject, GCDWebServerDelegate {
    
    static let instance = SimpleWebServer()
    
    var delegate: SimpleWebServerDelegate?
    
    private let webServer = GCDWebServer()
    private var loginHTML: String?
    
    func startWebServer() {
        
        self.webServer.delegate = self
        
        if loginHTML == nil {
            if let rootPath = NSBundle.mainBundle().resourcePath, let loginData = NSData(contentsOfFile: "\(rootPath)/login.html") {
                var html = NSString(data: loginData, encoding: NSUTF8StringEncoding)
                
                html = html?.stringByReplacingOccurrencesOfString("#{client_id}", withString: Config.LoginWithAmazon.ClientId)
                html = html?.stringByReplacingOccurrencesOfString("#{device_serial_number}", withString: Config.LoginWithAmazon.DeviceSerialNumber)
                html = html?.stringByReplacingOccurrencesOfString("#{product_id}", withString: Config.LoginWithAmazon.ProductId)
                
                loginHTML = html as String?
                
            } else {
                loginHTML = "<html>Error loading login html.</html>"
            }
        }
        
        webServer.addDefaultHandlerForMethod("GET", requestClass: GCDWebServerRequest.self, processBlock: {request in
            return GCDWebServerDataResponse(HTML:self.loginHTML)
        })
        
        webServer.addHandlerForMethod("GET", path: "/complete", requestClass: GCDWebServerRequest.self) { (request:GCDWebServerRequest!) -> GCDWebServerResponse! in
            
            if let expiresIn = request.query["expires_in"] as? String, let accessToken = request.query["access_token"] as? String {
                
                var tokenExpirationTime: NSDate?
                var currentAccessToken: String?
                
                if let eid = Double(expiresIn) {
                    tokenExpirationTime = NSDate().dateByAddingTimeInterval(eid)
                } else {
                    tokenExpirationTime = NSDate()
                }
                currentAccessToken = accessToken
                
                if tokenExpirationTime != nil && currentAccessToken != nil {
                    self.delegate?.configurationComplete(tokenExpirationTime!, currentAccessToken: currentAccessToken!)
                }
                
                return GCDWebServerDataResponse(HTML: "<html><body>Login complete, <a href=\"avsexample:/\">you can go back to the app now</a>.</body></html>")
                
            } else {
                return GCDWebServerDataResponse(HTML: "<html><body>Error logging in, <a href=\"/\">Try again</a></body></html>")
            }

        }
        
        webServer.startWithPort(8777, bonjourName: "GCD Web Server")
    
    }
    
    //
    // GCDWebServerDelegate Impl
    //
    
    func webServerDidStart(server: GCDWebServer!) {
        delegate?.startupComplete(server.serverURL)
    }
    
}