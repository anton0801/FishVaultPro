import SwiftUI

struct DisconnectedView: View {
    var body: some View {
        GeometryReader { g in
            ZStack {
                Image(g.size.width > g.size.height ? "inet_issue_bgl" : "inet_issue_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: g.size.width, height: g.size.height)
                    .ignoresSafeArea()
                
                Image("inet_issue_d")
                    .resizable()
                    .frame(width: 250, height: 200)
            }
        }
        .ignoresSafeArea()
    }
}
