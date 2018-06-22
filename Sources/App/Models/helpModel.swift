//
//  helpModel.swift
//  App
//
//  Created by ytx on 2018/6/21.
//

import FluentMySQL
import Vapor

enum NotFoundType{
    case param([String])
    case model
}

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

func AppResultNotFound<T>(type:NotFoundType,on: Worker) -> Future<AppResult<T>> {
    return Future.map(on: on, {
        
        return AppResultNotFound(type: type)
    })
}

func AppResultNotFound<T>(type: NotFoundType) -> AppResult<T>{
    var message = "error"
    switch type {
    case .model:
        message = "has no data in database"
    case .param(let s):
        message = s.reduce("", {
            $0 + ("has no params \($1) \n")
        })
    }
    
    return AppResult(code: 400, message: message, data:nil )
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






