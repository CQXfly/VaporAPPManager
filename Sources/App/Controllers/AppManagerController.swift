import Vapor
import Crypto
import FluentMySQL


final class AppManagerController : RouteCollection {
    
    func boot(router: Router) throws {
        
        let group = router.grouped("app")
        
        group.get("todos", use: index)
        group.post("create", use: create)
        group.delete("delete", AppModel.parameter, use: delete)
        group.get("app", use: queryAppName)
        group.get("queryapps", use: queryApps)
        group.get("appStatus", use: queryAppStatus)
        group.post("modifyApp", use: updateAppStatus)
        group.post("uploadAppInfo", use: uploadAppInfo)
        group.get("test", use: testQuery)
    }
}

extension AppManagerController {
    
    func index(_ req: Request) throws -> Future<[AppModel]> {
        return AppModel.query(on: req).all()
    }
    
    func uploadAppInfo(_ req: Request) throws -> Future<AppResult<AppModel>> {
        return try req.content.decode(AppModel.self).flatMap { appModel in
            let cardid = try MD5.hash(appModel.appName! + appModel.bundleid!).hexEncodedString().lowercased()
            appModel.appCardid = cardid
            
            let apps = AppModel.query(on: req).filter(\.appName == appModel.appName)
            
            return apps.first().flatMap{ (pack) in
                guard let pack = pack else {
                    return appModel.save(on: req).map({ model in
                        return AppResult(code: 200, message: "successful", data: model)
                    })
                }
                appModel.id = pack.id
                return appModel.update(on: req).map({ model in
                    return AppResult(code: 200, message: "successful", data: model)
                })
            }
            }.catchMap{ err in
                return AppResult(code:400,message: err.localizedDescription, data: nil)
        }
    }
    
    /// pages query
    func queryApps(_ req: Request) throws -> Future<AppResult<[AppModel]>> {
        
        guard let page = req.query[Int.self,at:"page"] else {
            return AppResultNotFound(type: .param(["page"]), on: req)
        }
        
        guard var num = req.query[Int.self,at:"num"]  else {
            return AppResultNotFound(type: .param(["num"]), on: req)
        }
        
        num = num - 1
        
        let app = AppModel.query(on: req).range(lower: page * num, upper: page * num + num).all()
        
        return app.map({ apps  in
            return AppResult(code: 200, message: "successful", data: apps)
        })
        
    }
    
    
    func queryAppStatus(_ req: Request) throws -> Future<AppResult<QueryStatusReturnModel>> {
        guard let appName = req.query[String.self,at:"appname"] else {
            
            return AppResultNotFound(type: .param(["appname"]), on: req)
        }
        
        let app = AppModel.query(on: req).filter(\.appName == appName)
        
        
        return app.first().map(to: AppResult<QueryStatusReturnModel>.self, { (pack) -> AppResult<QueryStatusReturnModel> in
            guard let pack = pack else {
                throw Abort(.notFound)
            }
            
            let re = QueryStatusReturnModel(appstatus: (pack.appstatus!), validDay: (pack.validDay!),appName:pack.appName!)
            
            return AppResult(code: 200, message: "successful", data: re)
            
        })
    }
    
    func queryAppName(_ req: Request) throws -> Future<AppResult<AppModel>> {
        guard let appName = req.query[String.self,at:"appname"] else {
            throw Abort(.notFound)
        }
        
        let app = AppModel.query(on: req).filter(\.appName == appName)
        
        return app.first().map(to: AppResult<AppModel>.self, { (pack) -> AppResult<AppModel> in
            guard let pack = pack else {
                return AppResultNotFound(type: .model)
            }
            
            return AppResult(code: 200, message: "successful", data: pack)
        })
        
    }
    
    /// gengxin xinshuju
    func update(_ req: Request) throws -> Future<[String:String]> {
        //        AppModel.update(AppModel.self)
        return try req.content.decode(AppModel.self).flatMap { appModel in
            let cardid = try MD5.hash(appModel.appName! + appModel.bundleid!).hexEncodedString().lowercased()
            appModel.appCardid = cardid
            appModel.appstatus = 0
            appModel.validDay = 2
            let model = appModel.save(on: req)
            print(model)
            return Future.map(on: req, {
                var result = [String:String]()
                result["result"] = "ok"
                return result
            })
        }
    }
    
    func create(_ req: Request) throws -> Future<AppResult<AppModel>> {
        return try req.content.decode(AppModel.self).flatMap { appModel in
            
            guard let appname = appModel.appName , let bundlid = appModel.bundleid else {
                throw Abort(.notFound)
            }
            let cardid = try MD5.hash(appname + bundlid).hexEncodedString().lowercased()
            appModel.appCardid = cardid
            appModel.appstatus = 0
            let model = appModel.save(on: req)
            return model.map(to:AppResult<AppModel>.self , { model in
                
                return AppResult(code: 200, message: "successful", data: model)
                
            }).catchMap({ (err) -> (AppResult<AppModel>) in
                return AppResult(code: 400, message: "error", data:nil )
            })
        }
    }
    
    func updateAppStatus(_ req: Request) throws -> Future<AppResult<AppModel>> {
        
        let query = try req.content.decode(QueryStatusReturnModel.self)
        
        
        return query.flatMap { param in
            print(param)
            
            let apps = AppModel.query(on: req).filter(\.appName == param.appName).all()
            
            return apps.flatMap { models in
                
                guard let model = models.first else {
                    return AppResultNotFound(type: .model, on: req)
                }
                model.validDay = param.validDay
                model.appstatus = param.appstatus
                return model.update(on: req).map(to:AppResult<AppModel>.self , { model in
                    
                    return AppResult(code: 200, message: "successful", data: model)
                }).catchMap({ (err) -> (AppResult<AppModel>) in
                    return AppResult(code: 400, message: err.localizedDescription, data:nil )
                })
            }
        }
        
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(AppModel.self).flatMap { model in
            return model.delete(on: req)
            }.transform(to: .ok)
    }
    
    func testQuery(_ req: Request) throws -> Future<AppResult<[AppModel]>> {
        
        let q = req.withPooledConnection(to: .mysql, closure: { conn in
            return conn.query("select * from appmodel")
        })
        
        return q.map({ rows in
            
            let new = rows.map({ z -> AppModel in
                
                let a = AppModel()
               
                // 比较丑陋 可以做个映射 但实际情况 复杂查询的返回字段很少不需要很多信息
                z.keys.forEach({ key in
                    let x = z[key]
                    let k = key.name
                    switch k {
                    case "id" , "appstatus", "validDay" :
                        do{
                            let r = try x?.decode(Int.self)
                            print(r!)
                            if (key.name == "id"){
                                a.id = r
                            } else if (key.name == "appstatus") {
                                a.appstatus = r
                            } else {
                                a.validDay = r
                            }
                            
                        } catch {
                            
                        }
                        break
                    case "startTime", "endTime":
                        do {
                            let r = try x?.decode(Date.self)
                            print(r!)
                            if (key.name == "startTime"){
                                a.startTime = r
                            }
                            
                        } catch {
                            
                        }
                    default:
                        do{
                            let r = try x?.decode(String.self)
                            print(r!)
                            if (key.name == "appCardid"){
                                a.appCardid = r
                            } else if (key.name == "appName" ) {
                                a.appName = r
                            } else if (key.name == "bundleid") {
                                a.bundleid = r
                            } else if (key.name == "bundleVersion") {
                                a.bundleVersion = r
                            } else if (key.name == "provisionName" ) {
                                a.provisionName = r
                            } else {
                                a.markMessage = r
                            }
                        } catch {
                            
                        }
                        break
                    }
                })
                return a
            })
        
            return AppResult(code: 200, message: "", data: new)
        })
        
    }
}

