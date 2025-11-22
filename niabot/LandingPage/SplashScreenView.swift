import SwiftUI

struct SplashScreenView: View {
    @State private var animateImage = false
    @State private var animateButton = false
    
    // These will come from ContentView
    @Binding var isAuthenticated: Bool
    @Binding var needsOTP: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 15) {
                    Spacer(minLength: 30)

                    // Animated Image
                    Image("SplashImage")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 415)
                        .opacity(animateImage ? 1 : 0.95)
                        .offset(y: animateImage ? 0 : -20)
                        .shadow(radius: 8)
                        .animation(.easeOut(duration: 1.0), value: animateImage)

                    Text("NiaBot")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                        .shadow(radius: 5)

                    Text("Conversations that care, answers that matter.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 200)
                        .padding(.horizontal, 20)

                    Spacer(minLength: 10)

                    // Pass the bindings to AuthView
                    NavigationLink(destination: AuthView(needsOTP: $needsOTP,isAuthenticated: $isAuthenticated)) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(animateButton ? Color.purple.opacity(0.9) : Color.purple)
                            .cornerRadius(12)
                            .shadow(color: Color.purple.opacity(0.5), radius: animateButton ? 12 : 8)
                            .scaleEffect(animateButton ? 1.05 : 1)
                            .padding(.horizontal, 30)
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            animateButton.toggle()
                        }
                    })

                    Spacer(minLength: 30)
                }
                .onAppear {
                    animateImage = true
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView(
            isAuthenticated: .constant(false),
            needsOTP: .constant(false)
        )
    }
}

