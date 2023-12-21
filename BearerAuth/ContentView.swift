//
//  ContentView.swift
//  BearerAuth
//
//  Created by Shigenari Oshio on 2023/12/21.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    
    @State private var showingAlert = false
    @State private var message = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextField("メールアドレス", text: $email)
                    .textFieldStyle(.roundedBorder)
                SecureField("パスワード", text: $password)
                    .textFieldStyle(.roundedBorder)
                Button("アカウント作成") {
                    createAccount()
                }
                Button("ログイン") {
                    signIn()
                }
                Button("検証") {
                    verify()
                }
                Button(
                    role: .destructive,
                    action: {
                        signOut()
                    },
                    label: { Text("ログアウト") }
                )
            }
            .font(.title)
        }
        .alert(message, isPresented: $showingAlert) {}
        .padding()
    }
    
    private func createAccount() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            message = {
                if let error = error {
                    return "作成失敗: \(error.localizedDescription)"
                } else {
                    return "アカウント作成しました: \(authResult?.user.email ?? "")"
                }
            }()
            showingAlert = true
        }
    }
    
    private func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            message = {
                if let error = error {
                    return "ログイン失敗: \(error.localizedDescription)"
                } else {
                    return "ログインしました: \(authResult?.user.email ?? "")"
                }
            }()
            showingAlert = true
        }
    }
    
    private func verify() {
        Task {
            do {
                guard let token = try await getIDToken() else {
                    message = "ログインして下さい"
                    showingAlert = true
                    return
                }

                var request = URLRequest(url: url)
                request.addValue(token, forHTTPHeaderField: "FIREBASE-AUTH-ID-TOKEN")
                
                let (data, _) = try await URLSession.shared.data(for: request)
                
                message = String(data: data, encoding: .utf8) ?? "エンコード失敗"
                showingAlert = true
            } catch {
                message = "エラー: " + error.localizedDescription
                showingAlert = true
            }
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            message = "ログアウトしました"
        } catch let error {
            message = "ログアウト失敗: \(error.localizedDescription)"
        }
        showingAlert = true
    }
    
    private func getIDToken() async throws -> String? {
        var token: String?
        if let user = Auth.auth().currentUser {
            token = try await withCheckedThrowingContinuation { continuation in
                user.getIDToken { token, _ in
                    if let token {
                        continuation.resume(returning: token)
                    }
                }
            }
        }
        return token
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
