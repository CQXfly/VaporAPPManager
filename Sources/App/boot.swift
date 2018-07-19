import Vapor
import QXTCPServer
/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    // your code here
    let tcp = TCPServer(host: "127.0.0.1", port: 3000, eventLoop: app.eventLoop);
    tcp.onRead = { x, y in
        var z = ByteBufferAllocator().buffer(capacity: 20)
        z.write(string: "123")
        x.write(z).mapIfError({ (e) in
            print(e)
        })
        
        
    }
    tcp.listen()
}
