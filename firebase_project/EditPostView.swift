//
//  EditPostView.swift
//  PetMoments
//
//  Created by Anirban Roy on 9/1/25.
//
import SwiftUI

struct EditPostView: View {
    let post: Post
    var onSave: (String, UIImage?) -> Void

    @State private var content: String
    @State private var newPhoto: UIImage? = nil
    @State private var showingImagePicker = false

    @Environment(\.dismiss) private var dismiss

    init(post: Post, onSave: @escaping (String, UIImage?) -> Void) {
        self.post = post
        self.onSave = onSave
        self._content = State(initialValue: post.content)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Content")) {
                    TextEditor(text: $content)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                }

                Section(header: Text("Change Photo")) {
                    if let newPhoto = newPhoto {
                        Image(uiImage: newPhoto)
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
            .navigationTitle("Edit Post")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(content, newPhoto)
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $newPhoto)
            }
        }
    }
}
