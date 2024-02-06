//
//  Onboarding.swift
//  Cork
//
//  Created by David Bureš on 21.10.2023.
//

import SwiftUI

enum OnboardingState
{
    case complexitySelector, socials
}

struct OnboardingView: View
{
    @Environment(\.dismiss) var dismiss
    
    @State private var onboardingState: OnboardingState = .complexitySelector
    
    @State private var areDetailsExpanded: Bool = false

    var body: some View
    {
        VStack(alignment: .center, spacing: 20)
        {
            switch onboardingState {
                case .complexitySelector:
                    ComplexitySelectorView(onboardingState: $onboardingState, areDetailsExpanded: $areDetailsExpanded)
                case .socials:
                    OnboardingSocialsView()
            }
        }
        .fixedSize()
        .padding()
        .animation(.none, value: areDetailsExpanded)
    }
}
