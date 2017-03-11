//
// ResponseMiddleware.swift
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

public struct ResponseMiddleware: Middleware {
    
    let token: String
    let response: SKResponse
    
    public init(token: String, response: SKResponse) {
        self.token = token
        self.response = response
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if let respondable = Respondable(request: request), respondable.token == token {
            return Response(response: response)
        }
        return Response(status: .badRequest)
    }
    
    private struct Respondable {
        
        let token: String
        
        init?(request: Request) {
            if let webhook = WebhookRequest(request: request), let token = webhook.token {
                self.token = token
            } else if let action = MessageActionRequest(request: request), let token = action.token {
                self.token = token
            } else {
                return nil
            }
        }
    }
}

extension WebhookRequest {
    public init?(request: Request) {
        do {
            var req = request
            let body = try req.body.becomeBuffer(deadline: 3.seconds).bytes
            guard
                let queryString = String(data: Data(body), encoding: .utf8),
                let proto = req.headers["X-Forwarded-Proto"],
                let host = req.headers["Host"]
            else {
                return nil
            }
            let requestString = proto + host + req.url.relativeString + "?" + queryString
            let components = URLComponents(string: requestString)
            var dict = [String: Any]()
            _ = components?.queryItems.flatMap {$0.map({dict[$0.name]=$0.value})}
            self.init(request: dict)
        } catch let error {
            print(error)
            return nil
        }
    }
}

extension Response {
    public init(response: SKResponse) {
        if let text = response.text.data(using: .utf8), response.attachments == nil, response.responseType == nil {
            self.init(body: Buffer([UInt8](text)))
        } else if let data = try? JSONSerialization.data(withJSONObject: response.json, options: []) {
            self.init(status: .ok, headers: ["content-type":"application/json"], body: Buffer([UInt8](data)))
        } else {
            self.init(status: .badRequest)
        }
    }
}
