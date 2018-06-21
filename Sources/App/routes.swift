import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Example of configuring a controller
    let appManagerController = AppManagerController()
    router.get("todos", use: appManagerController.index)
    router.post("create", use: appManagerController.create)
    router.delete("delete", AppModel.parameter, use: appManagerController.delete)
    router.get("app", use: appManagerController.queryAppName)
    router.get("queryapps", use: appManagerController.queryApps)
    router.get("appStatus", use: appManagerController.queryAppStatus)
    router.post("modifyApp", use: appManagerController.updateAppStatus)
    router.post("uploadAppInfo", use: appManagerController.uploadAppInfo)
    

    
}
