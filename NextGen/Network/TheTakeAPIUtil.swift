//
//  TheTakeAPIUtil.swift
//

import Foundation
import NextGenDataManager

public class TheTakeAPIUtil: NextGenDataManager.APIUtil, ProductAPIUtil {
    
    public static var APIDomain = "https://thetake.p.mashape.com"
    public static var APINamespace = "thetake.com"
    
    public var featureAPIID: String?
    
    public var productCategories: [ProductCategory]?
    
    private var frameTimes = [Double: NSDictionary]()
    private var _frameTimeKeys = [Double]()
    private var frameTimeKeys: [Double] {
        if _frameTimeKeys.count == 0 {
            _frameTimeKeys = frameTimes.keys.sorted()
        }
        
        return _frameTimeKeys
    }
    
    public convenience init(apiKey: String) {
        self.init(apiDomain: TheTakeAPIUtil.APIDomain)
        
        self.customHeaders["X-Mashape-Key"] = apiKey
        self.customHeaders["Accept"] = "application/json"
    }
    
    public func closestFrameTime(_ timeInSeconds: Double) -> Double {
        let timeInMilliseconds = timeInSeconds * 1000
        var closestFrameTime = -1.0
        
        if frameTimes.count > 0 && frameTimes[timeInMilliseconds] == nil {
            if let frameIndex = frameTimeKeys.index(where: { $0 > timeInMilliseconds }) {
                closestFrameTime = frameTimeKeys[max(frameIndex - 1, 0)]
            }
        } else {
            closestFrameTime = timeInMilliseconds
        }
        
        return closestFrameTime
    }
    
    public func getProductFrameTimes(completion: @escaping (_ frameTimes: [Double]?) -> Void) -> URLSessionDataTask? {
        if let apiID = featureAPIID {
            return getJSONWithPath("/frames/listFrames", parameters: ["media": apiID, "start": "0", "limit": "10000"], successBlock: { (result) -> Void in
                if let frames = result["result"] as? [NSDictionary] {
                    var frameTimes = [Double]()
                    for frameInfo in frames {
                        if let frameTime = frameInfo["frameTime"] as? Double {
                            frameTimes.append(frameTime)
                        }
                    }
                    
                    completion(frameTimes)
                } else {
                    completion(nil)
                }
            }, errorBlock: { (error) in
                print("Error fetching product frame times: \(error)")
                completion(nil)
            })
        }
        
        return nil
    }
    
    public func getProductCategories(completion: ((_ productCategories: [ProductCategory]?) -> Void)?) -> URLSessionDataTask? {
        if productCategories != nil {
            completion?(productCategories)
            return nil
        }
        
        if let apiID = featureAPIID {
            productCategories = [TheTakeCategory]()
            return getJSONWithPath("/categories/listProductCategories", parameters: ["media": apiID], successBlock: { [weak self] (result) in
                if let categories = result["result"] as? [NSDictionary] {
                    for categoryInfo in categories {
                        self?.productCategories?.append(TheTakeCategory(info: categoryInfo))
                    }
                }
                
                completion?(self?.productCategories)
            }, errorBlock: { [weak self] (error) in
                print("Error fetching product categories: \(error)")
                completion?(self?.productCategories)
            })
        }
        
        return nil
    }
    
    public func getFrameProducts(_ frameTime: Double, completion: @escaping (_ products: [ProductItem]?) -> Void) -> URLSessionDataTask? {
        if let apiID = featureAPIID, frameTime >= 0 && frameTimes[frameTime] != nil {
            return getJSONWithPath("/frameProducts/listFrameProducts", parameters: ["media": apiID, "time": String(frameTime)], successBlock: { (result) -> Void in
                if let productList = result["result"] as? NSArray {
                    var products = [TheTakeProduct]()
                    for productInfo in productList {
                        if let productData = productInfo as? NSDictionary {
                            products.append(TheTakeProduct(data: productData))
                        }
                    }
                    
                    completion(products)
                }
            }) { (error) -> Void in
                print("Error fetching products for frame \(frameTime): \(error)")
                completion(nil)
            }
        } else {
            completion(nil)
        }
        
        return nil
    }
    
    public func getCategoryProducts(_ categoryID: String?, completion: @escaping (_ products: [ProductItem]?) -> Void) -> URLSessionDataTask? {
        if let apiID = featureAPIID {
            var parameters: [String: String] = ["media": apiID, "limit": "100"]
            if let categoryID = categoryID {
                parameters["category"] = categoryID
            }
            
            return getJSONWithPath("/products/listProducts", parameters: parameters, successBlock: { (result) -> Void in
                if let productList = result["result"] as? NSArray {
                    var products = [TheTakeProduct]()
                    for productInfo in productList {
                        if let productData = productInfo as? NSDictionary {
                            products.append(TheTakeProduct(data: productData))
                        }
                    }
                    
                    completion(products)
                }
            }) { (error) -> Void in
                print("Error fetching products for category ID \(categoryID): \(error)")
                completion(nil)
            }
        } else {
            completion(nil)
        }
        
        return nil
    }
    
    public func getProductDetails(_ productID: String, completion: @escaping (_ product: ProductItem?) -> Void) -> URLSessionDataTask {
        return getJSONWithPath("/products/productDetails", parameters: ["product": productID], successBlock: { (result) -> Void in
            completion(TheTakeProduct(data: result))
        }) { (error) -> Void in
            print("Error fetching product details for product ID \(productID): \(error)")
            completion(nil)
        }
    }
    
}
