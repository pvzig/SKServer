//
// MessageActionMiddleware.swift
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

public struct MessageActionMiddleware: Middleware {
    
    let token: String
    let responder: MessageActionResponder

    public init(token: String, responder: MessageActionResponder) {
        self.token = token
        self.responder = responder
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if let action = MessageActionRequest(request: request), let middleware = responder.routes(action), action.token == token {
            return try middleware.respond(to: request, chainingTo: next)
        }
        return Response(status: .badRequest)
    }
}

extension MessageActionRequest {
    public init?(request: Request) {
        var req = request
        let encoded = try? URLEncodedFormMapParser.parse(try req.body.becomeBuffer(deadline: 3.seconds))
        guard
            let response = encoded?.dictionary?["payload"]?.string,
            let data = response.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        else {
            return nil
        }
        self.init(response: json)
    }
}
