//
//  SwifterServer.swift
//
// Copyright © 2017 Peter Zignego. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import HTTP
import Swifter

class SwifterServer: SlackKitServer {
    
    let server = HttpServer()
    let port: in_port_t
    let forceIPV4: Bool
    
    init(port: in_port_t = 8080, forceIPV4: Bool = false, responder: SlackKitResponder) {
        self.port = port
        self.forceIPV4 = forceIPV4
        
        for route in responder.routes {
            server[route.path] = { request in
                do {
                    return try route.middleware.respond(to: request.request, chainingTo: responder).httpResponse
                } catch let error {
                    print(error)
                    return .badRequest(.text(error.localizedDescription))
                }
            }
        }
    }
    
    public func start() {
        do {
            try server.start(port, forceIPv4: forceIPV4)
        } catch let error as NSError {
            print("Server failed to start with error: \(error)")
        }
    }
    
    public func stop() {
        server.stop()
    }
}

extension Response {

    public var httpResponse: HttpResponse {
        switch self.status {
        case .ok where contentType == nil:
            do {
                var req = self
                let text = try String(buffer: try req.body.becomeBuffer(deadline: 3.seconds))
                return .ok(.text(text))
            } catch let error {
                print(error)
                return .badRequest(.text(error.localizedDescription))
            }
        case .ok where contentType == MediaType(type: "application", subtype: "json"):
            do {
                var req = self
                let data = Data(try req.body.becomeBuffer(deadline: 3.seconds).bytes)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                return .ok(.json(json as AnyObject))
            } catch let error {
                print(error)
                return .badRequest(.text(error.localizedDescription))
            }
        case .badRequest:
            return .badRequest(.text("Bad request."))
        default:
            return .ok(.text("ok"))
        }
    }
}

extension HttpRequest: RequestRepresentable {

    public var request: Request {
        let method = Request.Method(self.method)
        let url = URL(string:self.path)
        var headers = [CaseInsensitiveString: String]()
        _ = self.headers.map{headers[CaseInsensitiveString($0.key)] = $0.value}
        let body = Body.buffer(Buffer(self.body))
        return Request(method: method, url: url!, headers: Headers(headers), body: body)
    }
}

extension Request.Method {
    init(_ rawValue: String) {
        let method = rawValue.uppercased()
        switch method {
        case "DELETE":  self = .delete
        case "GET":     self = .get
        case "HEAD":    self = .head
        case "POST":    self = .post
        case "PUT":     self = .put
        case "CONNECT": self = .connect
        case "OPTIONS": self = .options
        case "TRACE":   self = .trace
        case "PATCH":   self = .patch
        default:        self = .other(method: method)
        }
    }
}
#endif
