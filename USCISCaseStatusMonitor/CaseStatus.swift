//
//  CaseStatus.swift
//  USCIS Case Status Checker
//
//  Created by Anton Panferov on 4/18/19.
//  Copyright © 2019 Anton Panferov. All rights reserved.
//

import Foundation
import Kanna

struct CaseStatus: Codable {
    let status: String
    let description: String
}

enum Either<V, E: Error> {
    case value(V)
    case error(E)
}

enum APIError: Error {
    case apiError
}

class USCISStatus {
    func fetchCurrentStatus() -> Either<CaseStatus, APIError> {
        var urlComponent: URLComponents {
            var component = URLComponents(string: "https://egov.uscis.gov")
            component?.path = "/casestatus/mycasestatus.do"
            component?.queryItems = [URLQueryItem(name: "appReceiptNum", value: "")]
            return component!
        }
        
        let request = URLRequest(url: NSURL(string: "https://egov.uscis.gov/casestatus/mycasestatus.do?appReceiptNum=")! as URL)
        var response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
        let data = try? NSURLConnection.sendSynchronousRequest(request, returning: response)
        
        if let doc = try? HTML(html: String(decoding: data!, as: UTF8.self), encoding: .utf8) {
            let status = doc.xpath("//div/h1")
            let description = doc.xpath("//div/h1/following-sibling::p")
            
            return Either.value(CaseStatus(status: status.first!.text!,
                                           description: description.first!.text!))
        }
        
        return Either.error(.apiError)
    }
}
