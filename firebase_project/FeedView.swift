//
//  FeedView.swift
//  PetMoments
//
//  Created by Shafi on 12/30/24.
//
import FirebaseFirestore
import SwiftUI

import FirebaseFirestore
import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var showingNewPost = false

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 12) {
                    if viewModel.posts.isEmpty {
                        Text("No posts yet. Add your first post!")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(viewModel.posts) { post in
                            PostCell(post: post)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewPost = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewPost) {
                NewPostView(viewModel: viewModel)
            }
            .onAppear { viewModel.fetchPosts() }
        }
    }
}

struct PostCell: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Display the user's name at the top
            HStack {
                Text(post.userName) // User name displayed here
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text(post.timestamp, style: .relative) // Display relative time (e.g., "5 minutes ago")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Post content
            Text(post.content)
                .font(.body)
                .padding(.bottom, 8)
            
            // Display photo if available
            if let photoURL = post.photoURL, let url = URL(string: photoURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .cornerRadius(10)
                } placeholder: {
                    ProgressView()
                }
            }
            
            // Likes button
            Button(action: {
                print("Like button tapped for post \(post.id)")
            }) {
                Label("\(post.likes)", systemImage: "heart")
            }
            .foregroundColor(.red)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct NewPostView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FeedViewModel
    @State private var content = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var errorMessage: String?
    @State private var isPosting = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Write Something")) {
                    TextEditor(text: $content)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                }

                Section(header: Text("Add a Photo")) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(10)
                    }

                    Button("Select Photo") {
                        showingImagePicker = true
                    }
                }
            }
            .navigationTitle("New Post")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        guard !content.isEmpty else {
                            errorMessage = "Please write something"
                            return
                        }
                        isPosting = true
                        viewModel.createPost(content: content, photo: selectedImage)
                        isPosting = false
                        dismiss()
                    }
                    .disabled(content.isEmpty || isPosting)
                }

            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
}


