//
//  BiometricAuthenticaiton.swift
//  iOSBiometric
//
//  Created by Suman on 16/08/2021.
//
//wrapper file
//Advantage of having a wrapper is that, we don’t need to keep importing the dependencies everywhere else in the App, where it’s used by the clients.

import Foundation
import LocalAuthentication

class BiometricAuthenticaiton {
    
    //let’s add two enums:
    enum BiometricType{
        case none
        case touchID
        case faceID
        case unknown
    }
    
    enum BiometricError: LocalizedError{
        case authenticaitonFailed
        case userCancel
        case userFallback
        case biometryNotAvailable
        case biometryNotEnrolled
        case biometryLockout
        case unknown
        
        var errorDescription: String?{
            switch self {
            case .authenticaitonFailed: return "There was a problem verifying your identity."
            case .userCancel: return "You pressed cancel."
            case .biometryNotAvailable: return "Face ID/Touch ID is not available."
            case .biometryNotEnrolled: return "Face ID/Touch ID is not set up."
            case .biometryLockout: return "Face ID/Touch ID is locked."
            case .unknown: return "Face ID/Touch ID may not be configured"
            case .userFallback: return "You pressed password."
            }
        }
        
    }
    
    
    private let context = LAContext()
    private let policy: LAPolicy
    private let localizedReason: String
    private var error: NSError?
    
    init(policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics,
         localizedReason: String = "Verify your Identity",
         localizedFallbackTitle: String = "Enter App Password") {
        
        self.policy = policy
        self.localizedReason = localizedReason
        self.context.localizedFallbackTitle = localizedFallbackTitle
        self.context.localizedCancelTitle = "Touch me not"
    }
    
    //Below are the two main functions which we have been waiting for, which will do the magic for our Face-ID/Touch ID authentication. i.e canEvaluatePolicy & evaluatePolicy
    
    func canEvalute(completion: (Bool, BiometricType, BiometricError?) -> Void){
        // Asks Context if it can evaluate a Policy
        // Passes an Error pointer to get error code in case of failure
        
        guard context.canEvaluatePolicy(policy, error: &error) else {
            // Extracts the LABiometryType from Context
            // Maps it to our BiometryType
            let type = biometricType(for: context.biometryType)
            
            // Unwraps Error
            // If not available, sends false for Success & nil in BiometricError
            guard let error = error else {
                return completion(false, type, nil)
            }
            
            // Maps error to our BiometricError
            return completion(false, type, biometricError(from: error))
        }
        
        // Context can evaluate the Policy
        completion(true, biometricType(for: context.biometryType), nil)
    }
    
    func evaluate(completion: @escaping (Bool, BiometricError?) -> Void){
        // Asks Context to evaluate a Policy with a LocalizedReason
        
        self.context.evaluatePolicy(policy, localizedReason: localizedReason) { [weak self] success, error in
            // Moves to the main thread because completion triggers UI changes
            DispatchQueue.main.async {
                if success {
                    // Context successfully evaluated the Policy
                    completion(true, nil)
                } else {
                    // Unwraps Error
                    // If not available, sends false for Success & nil for BiometricError
                    guard let error = error else {
                        return completion(false, nil)
                    }
                    // Maps error to our BiometricError
                    completion(false, self?.biometricError(from: error as NSError))
                }
            }
        }
    }
    
   // Below methods that will actually do this mapping for enum's defined above
    private func biometricType(for type: LABiometryType) -> BiometricType {
        switch type {
        case .none:
            return .none
        case .touchID:
            return .touchID
        default:
            return .unknown
        }
    }
    
    private func biometricError(from nsError: NSError) -> BiometricError {
        
        let error: BiometricError
        
        switch nsError {
        case LAError.authenticationFailed:
            error = .authenticaitonFailed
        case LAError.userCancel:
            error = .userCancel
        case LAError.userFallback:
                error = .userFallback
        case LAError.biometryNotAvailable:
                error = .biometryNotAvailable
        case LAError.biometryNotEnrolled:
                error = .biometryNotEnrolled
        case LAError.biometryLockout:
                error = .biometryLockout
        default:
                error = .unknown
            
        }
        return error
    }
}
