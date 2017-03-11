//
// RedirectMiddleware.swift
//
// Copyright (c) 2017 Quark
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import HTTP

public struct RedirectMiddleware : Middleware {
    let location: String
    let shouldRedirect: (Request) -> Bool
    
    public init(redirectTo location: String, if shouldRedirect: @escaping (Request) -> Bool) {
        self.location = location
        self.shouldRedirect = shouldRedirect
    }
    
    public func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        if shouldRedirect(request) {
            return Response(redirectTo: location)
        }
    
        return try chain.respond(to: request)
    }
}

extension Response {
    public init(redirectTo location: String, headers: Headers = [:]) {
        var headers = headers
        headers["location"] = location
        self.init(status: .found, headers: headers)
    }
}
