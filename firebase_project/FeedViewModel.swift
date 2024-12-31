import SwiftUI
import FirebaseFirestore
import FirebaseAuth


class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    private let db = Firestore.firestore()
    
    // Fetch posts from Firestore
    func fetchPosts() {
        db.collection("posts")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else { return }
                
                self.posts = documents.compactMap { document -> Post? in
                    let data = document.data()
                    return Post(
                        id: document.documentID,
                        userId: data["userId"] as? String ?? "",
                        userName: data["userName"] as? String ?? "",
                        content: data["content"] as? String ?? "",
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                        likes: data["likes"] as? Int ?? 0,
                        photoURL: data["photoURL"] as? String
                    )
                }
            }
    }
    
    // Create a new post with optional photo
    func createPost(content: String, photo: UIImage?) {
        guard let currentUser = Auth.auth().currentUser else {
            print("User not authenticated.")
            return
        }

        // Fetch the user's display name from Firestore
        var userName = currentUser.displayName ?? "Anonymous"
        
        // Fetch user's name from Firestore if displayName is nil
        let userRef = db.collection("users").document(currentUser.uid)
        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                userName = document.data()?["name"] as? String ?? "Anonymous"
            }

            // Proceed to create post after fetching userName
            let postRef = self.db.collection("posts").document()
            var post: [String: Any] = [
                "userId": currentUser.uid,
                "userName": userName,
                "content": content,
                "timestamp": Timestamp(date: Date()),
                "likes": 0
            ]
            
            if let photo = photo {
                CloudinaryHelper.shared.uploadImage(photo) { result in
                    switch result {
                    case .success(let imageUrl):
                        post["photoURL"] = imageUrl
                        self.savePost(post: post, postRef: postRef)
                    case .failure(let error):
                        print("Failed to upload image: \(error.localizedDescription)")
                        self.savePost(post: post, postRef: postRef)
                    }
                }
            } else {
                self.savePost(post: post, postRef: postRef)
            }
        }
    }

    // Helper function to save post data to Firestore
    private func savePost(post: [String: Any], postRef: DocumentReference) {
        postRef.setData(post) { error in
            if let error = error {
                print("Failed to save post: \(error.localizedDescription)")
            } else {
                print("Post successfully saved.")
            }
        }
    }
}
//  FeedViewModel.swift
//  PetMoments
//
//  Created by Shafi on 12/30/24.
//

