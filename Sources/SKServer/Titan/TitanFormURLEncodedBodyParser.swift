//
// TitanFormURLEncodedBodyParser.swift
//
// Copyright 2017 Enervolution GmbH
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

public extension RequestType {
  public var formURLEncodedBody: [(name: String, value: String)] {
    return parse(body: self.body)
  }
  public var postParams: [String : String] {
    var ret = [String : String]()
    let keys = parse(body: self.body)
    for (k, v) in keys {
      ret[k] = v
    }
    return ret
  }
}

/*
 Parse application/x-www-form-urlencoded bodies
 Returns as many name-value pairs as possible
 Liberal in what it accepts, any failures to delimit pairs or decode percent
 encoding will result in empty strings
 */
func parse(body: String) -> [(name: String, value: String)] {
  var retValue = [(name: String, value: String)]()

  let pairs = body.components(separatedBy: "&") // Separate the tuples

  for element in pairs {
    let pair = element.components(separatedBy: "=")
      .map { $0.replacingOccurrences(of: "+", with: " ") } // Plus becomes a space, no %20 here
      .map { $0.removingPercentEncoding ?? "" } // Remove percent encoding, failure to remove percent encoding is replaced with empty string
    if pair.count == 2 {
      retValue.append((pair[0], pair[1]))
    } else if pair.count == 1 { // support ?key=&key2=string
      retValue.append((pair[0], ""))
    } else {
      break
    }
  }
  return retValue
}
