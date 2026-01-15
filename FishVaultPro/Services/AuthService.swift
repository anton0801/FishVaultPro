// Services/AuthService.swift
import Foundation
import FirebaseAuth
import Combine

class AuthService: ObservableObject {
    static let shared = AuthService()
    @Published var currentUserId: String?
    @Published var isAuthenticated = false
    
    private init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let user = Auth.auth().currentUser {
            currentUserId = user.uid
            isAuthenticated = true
        } else {
            signInAnonymously()
        }
    }
    
    func signInAnonymously() {
        Auth.auth().signInAnonymously { [weak self] result, error in
            if let user = result?.user {
                self?.currentUserId = user.uid
                self?.isAuthenticated = true
            }
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        currentUserId = nil
        isAuthenticated = false
    }
}
