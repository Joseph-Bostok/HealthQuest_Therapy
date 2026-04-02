import SwiftUI

struct RootView: View {
    @EnvironmentObject var session: SessionViewModel

    var body: some View {
        Group {
            if session.isLoading {
                ProgressView("Loading...")
            } else if let user = session.user {
                NavigationBarView(firstName: user.firstName)
            } else {
                LoginView()
            }
        }
    }
}
