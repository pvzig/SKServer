//
// SlackKitResponder.swift
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

#if os(Linux)
import Dispatch
#endif
import Foundation
import HTTP

public struct SlackKitResponder: Responder {
    
    public var routes: [RequestRoute]
    
    public init(routes: [RequestRoute]) {
        self.routes = routes
    }
    
    public func respond(to request: Request) throws -> Response {
        guard sslCheck(request: request) == false else {
            return Response(status: .ok)
        }
        // Timeout
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 3 * UInt64.nanosecondsPerSecond), execute: {
            return Response(status:.ok)
        })
        return try self.routes.filter{$0.path == request.path}.first?.middleware.respond(to: request, chainingTo: self) ?? Response(status: .badRequest)
    }
    
    private func sslCheck(request: Request) -> Bool {
        var req = request
        let encoded = try? URLEncodedFormMapParser.parse(try req.body.becomeBuffer(deadline: 3.seconds))
        if encoded?.dictionary?["ssl_check"]?.string == "1" {
            return true
        }
        return false
    }
}
