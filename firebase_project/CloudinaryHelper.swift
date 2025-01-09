import Foundation
import Cloudinary
import UIKit

class CloudinaryHelper {
    static let shared = CloudinaryHelper()
    private var cloudinary: CLDCloudinary
    
    private init() {
        let config = CLDConfiguration(
            cloudName: "djdefw3iv",
            apiKey: "421526292735198",
            apiSecret: "XguRsm-SCfsRj-5hvqXOYr5eiJ8"
        )
        cloudinary = CLDCloudinary(configuration: config)
    }
    
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        cloudinary.createUploader().upload(data: imageData, uploadPreset: "PetMoments") { (result, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let result = result, let secureUrl = result.secureUrl {
                completion(.success(secureUrl))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get secure URL"])))
            }
        }
    }
}
