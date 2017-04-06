//
// PathParameterSupport.swift
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

func toFunction(_ handler: @escaping (RequestType, String, ResponseType) -> (RequestType, ResponseType), with pathTemplate: String) -> Function {
  return { req, res in
    let param = extractParameters(from: req.path, with: pathTemplate)
    return handler(req, param[0], res)
  }
}

func toFunction(_ handler: @escaping (RequestType, String, String, ResponseType) -> (RequestType, ResponseType), with pathTemplate: String) -> Function {
  return { req, res in
    let param = extractParameters(from: req.path, with: pathTemplate)
    return handler(req, param[0], param[1], res)
  }
}

func toFunction(_ handler: @escaping (RequestType, String, String, String, ResponseType) -> (RequestType, ResponseType), with pathTemplate: String) -> Function {
  return { req, res in
    let param = extractParameters(from: req.path, with: pathTemplate)
    return handler(req, param[0], param[1], param[2], res)
  }
}

func toFunction(_ handler: @escaping (RequestType, String, String, String, String, ResponseType) -> (RequestType, ResponseType), with pathTemplate: String) -> Function {
  return { req, res in
    let param = extractParameters(from: req.path, with: pathTemplate)
    return handler(req, param[0], param[1], param[2], param[3], res)
  }
}

func toFunction(_ handler: @escaping (RequestType, String, String, String, String, String, ResponseType) -> (RequestType, ResponseType), with pathTemplate: String) -> Function {
  return { req, res in
    let param = extractParameters(from: req.path, with: pathTemplate)
    return handler(req, param[0], param[1], param[2], param[3], param[4], res)
  }
}

/// Where the `path` is /users/567/email
/// Where the `template` is /users/*/email
/// return [567]

func extractParameters(from path: String, with template: String) -> [String] {
  let pathComps = path.splitOnSlashes()
  let templateComps = template.splitOnSlashes()
  let z = zip(pathComps, templateComps)
  var ret: [String] = []
  for (pathComp, templateComp) in z {
    guard templateComp == "*" else {
      continue
    }
    ret.append(pathComp)
  }
  return ret
}

extension String {
  var wildcards: Int {
    return self.characters.reduce(0) { (count, char) in
      if char == "*" {
        return count + 1
      } else {
        return count
      }
    }
  }
}
