import FluentMySQL
import Vapor


final class AppModel: MySQLModel {
    
    var id: Int?
    
    var APPCardid: String?
    
    var APPName: String?
    
    var bundleid: String?
    
    var bundleVersion: String?
    
    var provisionName: String?
    
    var appstatus: Int? = 0
    
    var validDay: Int? = 2
    
    var markMessage: String?
    
    init(id: Int? = nil, APPCardid: String? ,APPName: String?,  bundleid: String?,bundleVersion: String?,provisionName: String?,appstatus: Int? = 0,validDay: Int?, markmessage: String? ) {
        self.id = id
        self.APPName = APPName
        self.APPCardid = APPCardid
        self.bundleid = bundleid
        self.bundleVersion = bundleVersion
        self.provisionName = provisionName
        self.appstatus = appstatus
        self.validDay = validDay
        self.markMessage = markmessage
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension AppModel: Migration { }

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension AppModel: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension AppModel: Parameter { }
