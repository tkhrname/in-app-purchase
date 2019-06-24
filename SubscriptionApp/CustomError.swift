//
//  CustomError.swift
//  SubscriptionApp
//
//  Created by 渡邊丈洋 on 2019/06/24.
//  Copyright © 2019 渡邊丈洋. All rights reserved.
//

import Foundation

struct CustomError: Error {
    let code: Int
    let domain: String
    let description: String
}

extension Error {
    var nserror: CustomError {
        let nserror = self as NSError
        return CustomError(code: nserror.code, domain: nserror.domain, description: nserror.localizedDescription)
    }
}
