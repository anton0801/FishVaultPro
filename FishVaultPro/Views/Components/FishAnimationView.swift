// Views/Components/FishAnimationView.swift
import SwiftUI

struct FishAnimationView: View {
    let speed: Double
    @State private var xOffset: CGFloat = 0
    @State private var isFlipped = false
    
    var body: some View {
        Image(systemName: "drop.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(AppColors.primaryAccent)
            .scaleEffect(x: isFlipped ? -1 : 1, y: 1)
            .offset(x: xOffset)
            .onAppear {
                startSwimming()
            }
    }
    
    private func startSwimming() {
        let duration = 3.0 / speed
        
        withAnimation(
            Animation.linear(duration: duration)
                .repeatForever(autoreverses: false)
        ) {
            xOffset = 20
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration / 2) {
            isFlipped.toggle()
        }
    }
}
