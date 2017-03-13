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

import Foundation
import HTTP
import Swifter

class SwifterServer: SlackKitServer {
    
    let server: Swifter
    
    init?(port: in_port_t = 8080, responder: SlackKitResponder) {
        do {
            server = try Swifter(port)
            for route in responder.routes {
                server[route.path] = { _, request, response in
                    do {
                        response(try route.middleware.respond(to: request.request, chainingTo: responder).response)
                    } catch let error {
                        response(TextResponse(400, error.localizedDescription))
                    }
                }
            }
        } catch let error {
            print("Server failed to initalize with error: \(error)")
            return nil
        }
    }
    
    public func start() {
        do {
            try server.loop()
        } catch let error {
            print("Server failed to start with error: \(error)")
        }
    }
}

extension HttpRequest: RequestRepresentable {
    
    public var request: HTTP.Request {
        let method = HTTP.Request.Method(self.method)
        let url = URL(string:self.path)
        var headers = [CaseInsensitiveString: String]()
        _ = self.headers.map{headers[CaseInsensitiveString($0.0)] = $0.1}
        let body = Body.buffer(Buffer(self.body))
        return Request(method: method, url: url!, headers: Headers(headers), body: body)
    }
}

extension HTTP.Request.Method {
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

extension HTTP.Response {

    public var response: HttpResponse {
        switch self.status {
        case .ok where contentType == nil:
            do {
                var req = self
                let text = try String(buffer: try req.body.becomeBuffer(deadline: 3.seconds))
                return TextResponse(stringLiteral: text)
            } catch let error {
                return TextResponse(400, error.localizedDescription)
            }
        case .ok where contentType == MediaType(type: "application", subtype: "json"):
            do {
                var req = self
                return HttpResponse(try req.body.becomeBuffer(deadline: 3.seconds).bytes)
            } catch let error {
                return TextResponse(400, error.localizedDescription)
            }
        case .badRequest:
            return TextResponse(400, "Bad Request")
        default:
            return Response(200)
        }
    }
}
