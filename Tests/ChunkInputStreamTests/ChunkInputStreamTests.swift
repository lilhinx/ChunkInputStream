import XCTest
@testable import ChunkInputStream

final class ChunkInputStreamTests:XCTestCase
{
    override func setUp( )
    {
        super.setUp( )
    }
    
    override func tearDown( )
    {
        super.tearDown( )
    }

    func createTempFile( prefix:String = "tmpfile" )->URL
    {
        return FileManager.default.temporaryDirectory.appendingPathComponent( "\( prefix )-\( UUID.init( ).uuidString )" )
    }

    func filePutContents( file:URL, contents:String )->Bool
    {
        guard let data = contents.data( using:.utf8 ) else
        {
            return false
        }

        try? FileManager.default.createDirectory( at:file.deletingLastPathComponent( ), withIntermediateDirectories:true, attributes:nil )
        return FileManager.default.createFile( atPath:file.path, contents:data, attributes:nil )
    }

    func testExample( )
    {
        let tmpFile = createTempFile( )
        let testData = "HELLO123TEST"
        let testDataLen = UInt( testData.lengthOfBytes( using:.ascii ) )
        guard filePutContents( file:tmpFile, contents:testData ) else
        {
            fatalError( )
        }

        let bufSize = 1
        var buf = [UInt8]( repeating:0, count:bufSize )

        // Read full stream

        var fileInputStream = InputStream( fileAtPath:tmpFile.path )
        var inputStream = ChunkInputStream( inputStream:fileInputStream )!
        inputStream.startPosition = 0
        inputStream.readMax = testDataLen
        inputStream.open( )

        var readData = NSMutableData( )
        var bytesRead = 0
        repeat
        {
            bytesRead = inputStream.read( &buf, maxLength:bufSize )
            if bytesRead > 0
            {
                readData.append( buf, length:bytesRead )
            }
        }
        while bytesRead > 0

        XCTAssertEqual( testDataLen, UInt( readData.length ) )
        XCTAssertEqual( testData, String( data:readData as Data, encoding:.ascii ) )

        // Read part of stream

        fileInputStream = InputStream( fileAtPath:tmpFile.path )
        inputStream = ChunkInputStream( inputStream:fileInputStream )
        inputStream.startPosition = 5
        inputStream.readMax = 3
        inputStream.open( )

        readData = NSMutableData( )
        bytesRead = 0
        repeat
        {
            bytesRead = inputStream.read( &buf, maxLength:bufSize )
            if bytesRead > 0
            {
                readData.append( buf, length:bytesRead )
            }
        }
        while bytesRead > 0

        XCTAssertEqual( 3, UInt( readData.length ) )
        XCTAssertEqual( "123", String( data:readData as Data, encoding:.ascii ) )

        try? FileManager.default.removeItem( atPath:tmpFile.path )
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
