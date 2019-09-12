import XCTest
@testable import gif_h

final class gif_hTests: XCTestCase {
    
    let outURL=URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("gif-h").appendingPathExtension("gif")
    let timeInterval:TimeInterval=0.1
    
    #if SWIFT_PACKAGE
    lazy var imageURLS:[URL]={
        let currentURL=URL(fileURLWithPath: #file).deletingLastPathComponent()
        let imageURL=currentURL.appendingPathComponent("testData", isDirectory: true)
        let imageURLs=try! FileManager.default.contentsOfDirectory(at: imageURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            .sorted(by: {u1,u2 in
                return u1.lastPathComponent.compare(u2.lastPathComponent, options:[.numeric]) == .orderedAscending
                
            })
        
        XCTAssertGreaterThan(imageURLs.count, 1, "insufficient images loaded")

        return imageURLs
    }()
    
    #else
    lazy var imageURLS:[URL]={
        guard let urls=Bundle(for: type(of: self)).urls(forResourcesWithExtension: nil, subdirectory: "testData")?.sorted(by: {u1,u2 in
            return u1.lastPathComponent.compare(u2.lastPathComponent, options:[.numeric]) == .orderedAscending
        }) else{
            XCTFail("No Images Loaded")
            return [URL]()
        }
        XCTAssertGreaterThan(urls.count, 1, "insufficient images loaded")
        return urls
    }()
    #endif
    
    override func tearDown() {
        do{
            try FileManager.default.removeItem(at: self.outURL)
        }
        catch let error{
            print(error)
        }
        
        super.tearDown()
    }
    
    
   func testEncoding(){
        self.encodeGIF(completion: {url in
            XCTAssertNotNil(url, "encoding failed")
            if let number=self.testDecoding(url: url!){
                XCTAssertGreaterThan(number, 0)
            }
            else{
                XCTFail("images not properly encoded")
            }
        })
    }
    
    func testDecoding(url:URL)->Int?{
        guard let source=CGImageSourceCreateWithURL(url as CFURL,nil) else{
            XCTFail("Image Source Creation failed")
            return nil}
        
        let count=CGImageSourceGetCount(source)
        XCTAssert(count == self.imageURLS.count)
        
        let success=[0..<count].indices.reduce(true, {result, idx in
            let image=CGImageSourceCreateImageAtIndex(source, idx, nil)
            
            if let properties=CGImageSourceCopyPropertiesAtIndex(source, idx, nil) as? [String:Any],
                let pngProperties=properties[kCGImagePropertyGIFDictionary as String] as? [String:Any],
                let delay=pngProperties[kCGImagePropertyGIFDelayTime as String] as? Double{
                    XCTAssertEqual(delay, self.timeInterval, accuracy: (self.timeInterval/100), "Encoded Delay Time Wrong")
                
            }
            else{
                
            }
            
            XCTAssertNotNil(image, "image creation failed at index \(idx)")
            return image != nil && result
        })
        return success == true ? count : nil
    }
    
    func encodeGIF(completion:@escaping (_ url:URL?)->Void) {
        let images=self.imageURLS.compactMap({url->CGImage? in
        guard let source=CGImageSourceCreateWithURL(url as CFURL, nil) else{return nil}
            XCTAssert(CGImageSourceGetCount(source) == 1, "Image Source has image count too high")
            return CGImageSourceCreateImageAtIndex(source, 0, nil)
       })
        XCTAssertEqual(images.count, self.imageURLS.count)
        let encoder=GifEncoder(url: self.outURL)
        
        for image in images{
            let success=encoder.addFrame(image, withDelay: self.timeInterval)
            XCTAssert(success, "Image Encoding failed")
        }
        XCTAssertTrue(encoder.finalize())
        completion(outURL)
    }
    

    static var allTests = [
        ("test Encoding", testEncoding),
    ]
}
