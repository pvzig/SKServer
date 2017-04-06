//
// TitanQueryString.swift
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

import class Foundation.NSString

public extension RequestType {
  public var queryPairs: [(key: String, value: String)] {
    let chars = self.path.characters
    guard let indexOfQuery = chars.index(of: "?") else {
      return []
    }
    let query = chars.suffix(from: indexOfQuery).dropFirst()
    let pairs = query.split(separator: "&")
    return pairs.map { pair -> (key: String, value: String) in
      let comps = pair.split(separator: "=").map { chars -> String in
        return String(chars).removingPercentEncoding ?? ""
      }
      switch comps.count {
      case 1:
        return (key: String(comps[0]), value: "")
      case 2:
        return (key: String(comps[0]), value: String(comps[1]))
      default:
        return (key: "", value: "")
      }
    }
  }
  public var query: [String:String] {
    var query: [String:String] = [:]
    for (name, value) in self.queryPairs {
      query[name] = value
    }
    return query
  }
}
