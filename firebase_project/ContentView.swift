import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isLoggedIn = false
    @State private var isSignUp = true
    @State private var userName = ""
    @State private var errorMessage: String? = nil
    
    let db = Firestore.firestore()

    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    if isLoggedIn {
                        Text("Welcome,\n \(userName)!")
                            .foregroundColor(.white)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .offset(x: -100, y: -100)
                        
                        Button(action: logOut) {
                            Text("Log Out")
                                .bold()
                                .frame(width: 200, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(.linearGradient(colors: [.pink, .red], startPoint: .top, endPoint: .bottomTrailing)))
                                .foregroundColor(.white)
                        }
                        .padding(.top)
                    } else {
                        if isSignUp {
                            Text("Sign Up")
                                .foregroundColor(.white)
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .offset(x: -100, y: -100)
                            
                            TextField("Name", text: $name)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .frame(width: 350)
                            
                            TextField("Email", text: $email)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .frame(width: 350)
                            
                            SecureField("Password", text: $password)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .frame(width: 350)
                            
                            Button {
                                signUp()
                            } label: {
                                Text("Sign Up")
                                    .bold()
                                    .frame(width: 200, height: 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(.linearGradient(colors: [.pink, .red], startPoint: .top, endPoint: .bottomTrailing)))
                                    .foregroundColor(.white)
                            }
                            
                            Button {
                                isSignUp = false
                            } label: {
                                Text("Already have an account?")
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            .padding(.top)
                            .offset(y: 110)
                        } else {
                            Text("Login")
                                .foregroundColor(.white)
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .offset(x: -100, y: -100)
                            
                            TextField("Email", text: $email)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .frame(width: 350)
                            
                            SecureField("Password", text: $password)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .frame(width: 350)
                            
                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.subheadline)
                                    .padding(.top, 10)
                            }
                            
                            Button {
                                login()
                            } label: {
                                Text("Login")
                                    .bold()
                                    .frame(width: 200, height: 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(.linearGradient(colors: [.pink, .red], startPoint: .top, endPoint: .bottomTrailing)))
                                    .foregroundColor(.white)
                            }
                            
                            Button {
                                isSignUp = true
                            } label: {
                                Text("Don't have an account?")
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            .padding(.top)
                            .offset(y: 110)
                        }
                    }
                }
                .frame(width: 350)
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                MainView()
            }
        }
    }
    
    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            } else {
                let userRef = db.collection("users").document(result!.user.uid)
                userRef.setData([
                    "name": name,
                    "email": email
                ]) { err in
                    if let err = err {
                        print("Error saving user data: \(err.localizedDescription)")
                        errorMessage = err.localizedDescription
                    } else {
                        isLoggedIn = true
                        userName = name
                    }
                }
            }
        }
    }
    
    func login() {
        // Show loading state (if applicable in your app)
        errorMessage = nil

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                self.errorMessage = "Invalid credentials. Please try again."
                return
            }
            
            guard let userId = result?.user.uid else {
                self.errorMessage = "An unexpected error occurred. Please try again."
                return
            }
            
            // Fetch user data from Firestore
            self.db.collection("users").document(userId).getDocument { document, error in
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                    self.errorMessage = "Failed to fetch user data. Please try again later."
                    return
                }
                
                guard let document = document, document.exists else {
                    print("User document does not exist.")
                    self.errorMessage = "User data not found. Please contact support."
                    return
                }
                
                // Extract user name
                if let name = document.data()?["name"] as? String {
                    self.userName = name
                    
                    // Save userName locally
                    UserDefaults.standard.set(name, forKey: "userName")
                    UserDefaults.standard.synchronize()
                    
                    self.isLoggedIn = true
                } else {
                    print("Name field is missing in the user document.")
                    self.errorMessage = "User name not found. Please contact support."
                }
            }
        }
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            userName = ""
        } catch {
            print("Error logging out: \(error.localizedDescription)")
        }
    }
}
#Preview {
    ContentView()
}
