//
//  helpModel.swift
//  App
//
//  Created by ytx on 2018/6/21.
//

import FluentMySQL
import Vapor

struct  QueryStatusReturnModel: Content {
    var appstatus: Int
    var validDay: Int
    var appName: String
}

struct AppResult<T>:Content where T : Codable{
    var code: Int
    var message: String
    var data:T?
}

struct PageQueryModel: Content {
    var num: Int
    var page: Int
}

func FoxParamtersAbort(_ input:String ...) -> Abort {
    var fox = Abort(.badRequest)
    fox.reason = input.reduce("", {
        $0 + ("has no params \($1)")
    })
    return fox
}




