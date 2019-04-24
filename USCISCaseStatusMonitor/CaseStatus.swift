//
//  CaseStatus.swift
//  USCIS Case Status Checker
//
//  Created by Anton Panferov on 4/18/19.
//  Copyright © 2019 Anton Panferov. All rights reserved.
//

import Foundation
import os
import Kanna

struct CaseStatus: Codable, Equatable {
    let status: String
    let description: String
    
    static func == (objA: CaseStatus, objB: CaseStatus) -> Bool {
        return objA.status == objB.status && objA.description == objB.description;
    }    
}

enum Either<V, E: Error> {
    case value(V)
    case error(E)
}

enum APIError: Error {
    case apiError
    case noStatusError
}

class USCISStatus {
    func fetchCurrentStatus(caseNumber: String) -> Either<CaseStatus, APIError> {
        os_log("Fetching case status for the case #%@", caseNumber)
        var urlComponent: URLComponents {
            var component = URLComponents(string: "https://egov.uscis.gov")
            component?.path = "/casestatus/mycasestatus.do"
            component?.queryItems = [URLQueryItem(name: "appReceiptNum", value: caseNumber)]
            return component!
        }
        
        let request = URLRequest(url: urlComponent.url!)
        var response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
        let data = try? NSURLConnection.sendSynchronousRequest(request, returning: response)
        
        if let doc = try? HTML(html: String(decoding: data!, as: UTF8.self), encoding: .utf8) {
            if doc.at_xpath("//div[@id='formErrorMessages']/h4") != nil {
                return Either.error(.noStatusError)
            }
            guard let status = doc.at_xpath("//div/h1") else {
                return Either.error(.noStatusError)
            }
            guard let description = doc.at_xpath("//div/h1/following-sibling::p") else {
                return Either.error(.noStatusError)
            }
            return Either.value(CaseStatus(status: status.text!, description: description.text!))
        }
        
        return Either.error(.apiError)
    }
}
