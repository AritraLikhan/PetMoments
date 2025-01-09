//
//  ProfileView.swift
//  PetMoments
//
//  Created by Anirban Roy 9/1/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @State private var userName = ""
    @State private var email = ""
    @State private var userPosts: [Post] = []
    @State private var editingPost: Post? = nil 
    @State private var showingEditUserInfo = false
    private let db = Firestore.firestore()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // User info section
                VStack(alignment: .leading) {
                    HStack {
                        Text("Profile")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                        Button("Edit") {
                            showingEditUserInfo = true
                        }
                    }

                    Text("Name: \(userName)")
                        .font(.headline)

                    Text("Email: \(email)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()

                Divider()

                // User's posts section
                Text("My Posts")
                    .font(.headline)
                    .padding(.horizontal)

                if userPosts.isEmpty {
                    Text("You haven't posted anything yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(userPosts) { post in
                        VStack(alignment: .leading) {
                            
                            PostCell(post: post)
                                .padding(.horizontal)
                           
                           
                            HStack {
                                Spacer()
                                Button(action: {
                                   
                                    editingPost = post
                                }) {
                                    Text("Edit Post")
                                        .foregroundColor(.blue)
                                        .font(.subheadline)
                                }
                                .padding([.top, .trailing], 8)
                            }
                        
                            
                            HStack {
                                Spacer()
                                Button(action: {
                                    deletePost(post: post)
                                }) {
                                    Text("Delete Post")
                                        .foregroundColor(.red)
                                        .font(.subheadline)
                                }
                                .padding([.bottom, .trailing], 8)
                            }
                        }
                    }

                }
            }
        }
        .onAppear(perform: fetchProfileData)
        .navigationTitle("Profile")
        .sheet(item: $editingPost) { post in
            EditPostView(post: post) { updatedContent, updatedPhoto in
                updatePost(post, withContent: updatedContent, newPhoto: updatedPhoto)
            }
        }
        .sheet(isPresented: $showingEditUserInfo) {
            EditUserInfoView(userName: $userName, email: $email) { newName, newEmail in
                updateUserInfo(name: newName, email: newEmail)
            }
        }
    }

    func fetchProfileData() {
        guard let currentUser = Auth.auth().currentUser else { return }

       
        let userRef = db.collection("users").document(currentUser.uid)
        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }

            if let document = document, let data = document.data() {
                self.userName = data["name"] as? String ?? "Unknown User"
                self.email = data["email"] as? String ?? "Unknown Email"
            }
        }

       
        db.collection("posts")
            .whereField("userId", isEqualTo: currentUser.uid) 
            .order(by: "timestamp", descending: true) 
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching user posts: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.userPosts = []
                    return
                }

                self.userPosts = documents.compactMap { document -> Post? in
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

    func updateUserInfo(name: String, email: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let userRef = db.collection("users").document(currentUser.uid)

        userRef.updateData([
            "name": name,
            "email": email
        ]) { error in
            if let error = error {
                print("Error updating user info: \(error.localizedDescription)")
            } else {
                print("User info updated successfully.")
                self.userName = name
                self.email = email
            }
        }
    }

    func deletePost(post: Post) {
        let postRef = db.collection("posts").document(post.id)
        postRef.delete { error in
            if let error = error {
                print("Error deleting post: \(error.localizedDescription)")
            } else {
                print("Post deleted successfully.")
            }
        }
    }

    func updatePost(_ post: Post, withContent content: String, newPhoto: UIImage?) {
        let postRef = db.collection("posts").document(post.id)

        var updates: [String: Any] = ["content": content]

        if let newPhoto = newPhoto {
            CloudinaryHelper.shared.uploadImage(newPhoto) { result in
                switch result {
                case .success(let imageUrl):
                    updates["photoURL"] = imageUrl
                    postRef.updateData(updates) { error in
                        if let error = error {
                            print("Error updating post: \(error.localizedDescription)")
                        } else {
                            print("Post updated successfully.")
                        }
                    }
                case .failure(let error):
                    print("Failed to upload photo: \(error.localizedDescription)")
                }
            }
        } else {
            postRef.updateData(updates) { error in
                if let error = error {
                    print("Error updating post: \(error.localizedDescription)")
                } else {
                    print("Post updated successfully.")
                }
            }
        }
    }
}
