import FluentMySQL
import Vapor


final class AppModel: MySQLModel {
    
    static let name = "appmodel"
    
    var id: Int?
    
    var appCardid: String?
    
    var appName: String?
    
    var bundleid: String?
    
    var bundleVersion: String?
    
    var provisionName: String?
    
    var appstatus: Int? = 0
    
    var validDay: Int? = 2
    
    var markMessage: String?
    
    var startTime:Date? {
        didSet{
            self.endTime = self.startTime! + TimeInterval(self.validDay! * 60 * 60 * 24)
        }
    }
    
    var endTime: Date?
    
    static var createdAtKey:TimestampKey? {return \.startTime}
    
    init() {
        
    }
    
    init(id: Int? = nil, appCardid: String? ,appName: String?,  bundleid: String?,bundleVersion: String?,provisionName: String?,appstatus: Int? = 0,validDay: Int? = 2, markmessage: String?,_ startime:Date?,_ endTime: Date?) {
        self.id = id
        self.appName = appName
        self.appCardid = appCardid
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


extension AppModel {
//    func willCreate(on conn: MySQLConnection) throws -> EventLoopFuture<AppModel> {
//
//    }
}
