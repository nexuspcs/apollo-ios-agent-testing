import SwiftUI
import MapKit

struct TutorSearchView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var searchFilter = TutorSearchFilter()
    @State private var selectedTutor: Tutor?
    @State private var showingMap = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093), // Sydney CBD
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var filteredTutors: [Tutor] {
        appViewModel.tutors.filter { tutor in
            if !searchText.isEmpty {
                let subjectNames = tutor.subjects.compactMap { subjectId in
                    Subject.hscSubjects.first(where: { $0.id == subjectId })?.name
                }
                let searchInSubjects = subjectNames.contains { $0.localizedCaseInsensitiveContains(searchText) }
                let searchInSuburb = tutor.suburb.localizedCaseInsensitiveContains(searchText)
                
                if !searchInSubjects && !searchInSuburb {
                    return false
                }
            }
            
            if !searchFilter.subjects.isEmpty {
                if !tutor.subjects.contains(where: { searchFilter.subjects.contains($0) }) {
                    return false
                }
            }
            
            if let maxRate = searchFilter.maxHourlyRate, tutor.hourlyRate > maxRate {
                return false
            }
            
            if let minRating = searchFilter.minRating, tutor.rating < minRating {
                return false
            }
            
            if let deliveryMode = searchFilter.deliveryMode {
                if tutor.deliveryMode != deliveryMode && tutor.deliveryMode != .both {
                    return false
                }
            }
            
            return true
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search header
                searchHeader
                
                if showingMap {
                    // Map view
                    mapView
                } else {
                    // List view
                    tutorList
                }
            }
            .navigationTitle("Find Tutors")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: { showingMap.toggle() }) {
                            Image(systemName: showingMap ? "list.bullet" : "map")
                        }
                        
                        Button(action: { showingFilters = true }) {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                TutorFiltersView(filter: $searchFilter)
            }
            .sheet(item: $selectedTutor) { tutor in
                TutorDetailView(tutor: tutor)
            }
            .onAppear {
                Task {
                    await appViewModel.searchTutors(filter: searchFilter)
                }
            }
        }
    }
    
    private var searchHeader: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search subjects or suburbs...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Quick filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickFilterChip(title: "Available Today", isSelected: searchFilter.availableToday) {
                        searchFilter.availableToday.toggle()
                        Task {
                            await appViewModel.searchTutors(filter: searchFilter)
                        }
                    }
                    
                    QuickFilterChip(title: "This Week", isSelected: searchFilter.availableThisWeek) {
                        searchFilter.availableThisWeek.toggle()
                        Task {
                            await appViewModel.searchTutors(filter: searchFilter)
                        }
                    }
                    
                    QuickFilterChip(title: "Online", isSelected: searchFilter.deliveryMode == .online) {
                        searchFilter.deliveryMode = searchFilter.deliveryMode == .online ? nil : .online
                        Task {
                            await appViewModel.searchTutors(filter: searchFilter)
                        }
                    }
                    
                    QuickFilterChip(title: "In Person", isSelected: searchFilter.deliveryMode == .inPerson) {
                        searchFilter.deliveryMode = searchFilter.deliveryMode == .inPerson ? nil : .inPerson
                        Task {
                            await appViewModel.searchTutors(filter: searchFilter)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    private var tutorList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredTutors) { tutor in
                    TutorCard(tutor: tutor) {
                        selectedTutor = tutor
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }
    
    private var mapView: some View {
        Map(coordinateRegion: $region, annotationItems: filteredTutors) { tutor in
            MapAnnotation(coordinate: CLLocationCoordinate2D(
                latitude: tutor.latitude ?? -33.8688,
                longitude: tutor.longitude ?? 151.2093
            )) {
                Button(action: { selectedTutor = tutor }) {
                    VStack(spacing: 4) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                        
                        Text("$\(Int(tutor.hourlyRate))/hr")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}

struct QuickFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

struct TutorCard: View {
    let tutor: Tutor
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    // Profile image placeholder
                    AsyncImage(url: URL(string: tutor.profileImageUrl ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("First Name") // In real app, would show tutor's first name
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("$\(Int(tutor.hourlyRate))/hr")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        
                        Text(tutor.suburb)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(tutor.rating) ? "star.fill" : "star")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                            }
                            
                            Text("(\(tutor.totalSessions) sessions)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Subjects
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tutor.subjects.prefix(3), id: \.self) { subjectId in
                            if let subject = Subject.hscSubjects.first(where: { $0.id == subjectId }) {
                                Text(subject.name)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // Availability and delivery mode
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: tutor.deliveryMode == .online ? "video" : tutor.deliveryMode == .inPerson ? "person.2" : "globe")
                            .font(.caption)
                        Text(tutor.deliveryMode.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Available Today")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TutorSearchView()
        .environmentObject(AppViewModel())
}