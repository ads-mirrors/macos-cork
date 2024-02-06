//
//  Socials View.swift
//  Cork
//
//  Created by David Bureš on 22.01.2024.
//

import SwiftUI

struct OnboardingSocialsView: View
{
    var body: some View
    {
        VStack
        {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .frame(width: 100, height: 100)

            VStack(alignment: .center, spacing: 5, content: {
                Text("onboarding.socials.title")
                    .font(.title)

                Text("onboarding.socials.subtitle")
                    .frame(maxWidth: 300)
            })
            
            Grid {
                <#code#>
            }
        }
    }
}
