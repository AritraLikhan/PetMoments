import Foundation

struct Post: Identifiable {
    let id: String
    let userId: String
    let userName: String
    let content: String
    let timestamp: Date
    let likes: Int
    let photoURL: String? // Optional to handle posts without photos
}
