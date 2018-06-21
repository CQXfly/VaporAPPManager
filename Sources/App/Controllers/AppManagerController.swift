import Vapor
import Crypto
import FluentMySQL

final class AppManagerController {
    
    func index(_ req: Request) throws -> Future<[AppModel]> {
        return AppModel.query(on: req).all()
    }

    
    func uploadAppInfo(_ req: Request) throws -> Future<AppModel> {
        return try req.content.decode(AppModel.self).flatMap { appModel in
            let cardid = try MD5.hash(appModel.APPName! + appModel.bundleid!).hexEncodedString().lowercased()
            appModel.APPCardid = cardid
            
            let apps = AppModel.query(on: req).filter(\.APPName == appModel.APPName)
            
            return apps.first().flatMap({ (pack) -> EventLoopFuture<AppModel> in
                guard let pack = pack else {
                    return appModel.save(on: req)
                }
                appModel.id = pack.id
                return appModel.update(on: req)
            })
        }
    }
    
    /// pages query 
    func queryApps(_ req: Request) throws -> Future<[AppModel]> {
        
        guard let page = req.query[Int.self,at:"page"] else {
            throw FoxParamtersAbort("page")
        }
        
        guard var num = req.query[Int.self,at:"num"]  else {
            throw FoxParamtersAbort("num")
        }
        
        num = num - 1
        
        let app = AppModel.query(on: req).range(lower: page * num, upper: page * num + num).all()
        
        return app
        
    }
    
    
    func queryAppStatus(_ req: Request) throws -> Future<QueryStatusReturnModel> {
        guard let appName = req.query[String.self,at:"appname"] else {
            var abort = Abort.init(.badRequest)
            abort.reason = "no appname param"
            throw abort
        }
        
        let app = AppModel.query(on: req).filter(\.APPName == appName)
        
        
        return app.first().map(to: QueryStatusReturnModel.self, { (pack) -> QueryStatusReturnModel in
            guard let pack = pack else {
                throw Abort(.notFound)
            }
            
            let re = QueryStatusReturnModel(appstatus: (pack.appstatus!), validDay: (pack.validDay!),appName:pack.APPName!)
            
            return re

        })
    }
    
    func queryAppName(_ req: Request) throws -> Future<AppModel> {
        guard let appName = req.query[String.self,at:"appname"] else {
            throw Abort(.notFound)
        }
        
        let app = AppModel.query(on: req).filter(\.APPName == appName)
        
        return app.first().map(to: AppModel.self, { (pack) -> AppModel in
            guard let pack = pack else {
                throw Abort(.notFound)
            }
            
            return pack
        })
        
    }
    
    /// gengxin xinshuju
    func update(_ req: Request) throws -> Future<[String:String]> {
//        AppModel.update(AppModel.self)
        return try req.content.decode(AppModel.self).flatMap { appModel in
            let cardid = try MD5.hash(appModel.APPName! + appModel.bundleid!).hexEncodedString().lowercased()
            appModel.APPCardid = cardid
            appModel.appstatus = 0
            appModel.appstatus = 2
            let model = appModel.save(on: req)
            print(model)
            return Future.map(on: req, {
                var result = [String:String]()
                result["result"] = "ok"
                return result
            })
        }
    }
    
    func create(_ req: Request) throws -> Future<AppModel> {
        return try req.content.decode(AppModel.self).flatMap { appModel in
            
            guard let appname = appModel.APPName , let bundlid = appModel.bundleid else {
                throw Abort(.notFound)
            }
            let cardid = try MD5.hash(appname + bundlid).hexEncodedString().lowercased()
            appModel.APPCardid = cardid
            appModel.appstatus = 0
            let model = appModel.save(on: req)
            return model
        }
    }

    func updateAppStatus(_ req: Request) throws -> Future<AppModel> {
        
        let deviceID = try req.content.decode(QueryStatusReturnModel.self)
        
        
        return deviceID.flatMap { param in
            print(param)
            
            let apps = AppModel.query(on: req).filter(\.APPName == param.appName).all()
            
            return apps.flatMap(to: AppModel.self, { models in
    
                guard let model = models.first else {
                    throw Abort(.notFound)
                }
                model.validDay = param.validDay
                model.appstatus = param.appstatus
                return model.update(on: req)
                
            })
        }

    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(AppModel.self).flatMap { model in
            return model.delete(on: req)
        }.transform(to: .ok)
    }
}