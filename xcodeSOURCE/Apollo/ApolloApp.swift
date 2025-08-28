import SwiftUI

@main
struct ApolloApp: App {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var appViewModel = AppViewModel()
    
    init() {
        // Firebase configuration would be initialized here
        // FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(appViewModel)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .onAppear {
            authViewModel.checkAuthenticationStatus()
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            if authViewModel.currentUser?.userType == .student {
                // Student tabs
                TutorSearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .tag(0)
                
                StudentMessagesView()
                    .tabItem {
                        Image(systemName: "message")
                        Text("Messages")
                    }
                    .tag(1)
                
                StudentDashboardView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Sessions")
                    }
                    .tag(2)
                
                StudentProfileView()
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    .tag(3)
            } else {
                // Tutor tabs
                TutorDashboardView()
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Dashboard")
                    }
                    .tag(0)
                
                TutorMessagesView()
                    .tabItem {
                        Image(systemName: "message")
                        Text("Messages")
                    }
                    .tag(1)
                
                TutorScheduleView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Schedule")
                    }
                    .tag(2)
                
                TutorProfileView()
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    .tag(3)
            }
        }
        .accentColor(.blue)
    }
}