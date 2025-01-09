//
//  EditUserInfoView.swift
//  PetMoments
//
//  Created by Anirban Roy on 9/1/25.
//
import SwiftUI

struct EditUserInfoView: View {
    @Binding var userName: String
    @Binding var email: String
    var onSave: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Profile")) {
                    TextField("Name", text: $userName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(userName, email)
                        dismiss()
                    }
                }
            }
        }
    }
}

