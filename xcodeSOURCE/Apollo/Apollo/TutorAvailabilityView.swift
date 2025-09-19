import SwiftUI

struct TutorAvailabilityView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var availability: TutorAvailability = .init(availability: [:])
    @State private var addingDay: DayOfWeek?
    @State private var newStartTime = Date()
    @State private var newEndTime = Date()
    @State private var showAddSlotSheet = false

    private var userId: String? {
        authViewModel.currentTutor?.id
    }

    private func userDefaultsKey(for userId: String) -> String {
        "mock.tutor.availability.\(userId)"
    }

    private func loadAvailability() {
        guard let userId = userId else { return }
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey(for: userId)),
           let loaded = try? JSONDecoder().decode(TutorAvailability.self, from: data) {
            availability = loaded
        } else if let current = authViewModel.currentTutor?.availability {
            availability = current
        } else {
            availability = TutorAvailability(availability: [:])
        }
    }

    private func saveAvailability() {
        guard let userId = userId else { return }
        if let encoded = try? JSONEncoder().encode(availability) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey(for: userId))
        }
        authViewModel.currentTutor?.availability = availability
    }

    private func stringToDate(_ time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: time)
    }

    private func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func defaultStartTime() -> Date {
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    private func defaultEndTime() -> Date {
        var components = DateComponents()
        components.hour = 10
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(DayOfWeek.allCases) { day in
                    Section(header: HStack {
                        Text(day.displayName)
                        Spacer()
                        Button {
                            addingDay = day
                            newStartTime = defaultStartTime()
                            newEndTime = defaultEndTime()
                            showAddSlotSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .imageScale(.large)
                        }
                        .buttonStyle(.plain)
                    }) {
                        if let slots = availability.availability[day],
                           !slots.isEmpty {
                            ForEach(slots) { slot in
                                Text("\(slot.start) - \(slot.end)")
                            }
                            .onDelete { indexSet in
                                var slots = availability.availability[day] ?? []
                                slots.remove(atOffsets: indexSet)
                                if slots.isEmpty {
                                    availability.availability[day] = nil
                                } else {
                                    availability.availability[day] = slots
                                }
                            }
                        } else {
                            Text("No slots").foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Tutor Availability")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAvailability()
                        dismiss()
                    }
                    .disabled(userId == nil)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadAvailability()
            }
            .onDisappear {
                saveAvailability()
            }
            .sheet(isPresented: $showAddSlotSheet) {
                if let day = addingDay {
                    NavigationView {
                        Form {
                            Section(header: Text("Start Time")) {
                                DatePicker("Start", selection: $newStartTime, displayedComponents: [.hourAndMinute])
                                    .datePickerStyle(WheelDatePickerStyle())
                            }
                            Section(header: Text("End Time")) {
                                DatePicker("End", selection: $newEndTime, displayedComponents: [.hourAndMinute])
                                    .datePickerStyle(WheelDatePickerStyle())
                            }
                        }
                        .navigationTitle("Add Slot - \(day.displayName)")
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Add") {
                                    let startStr = dateToString(newStartTime)
                                    let endStr = dateToString(newEndTime)
                                    let newSlot = TimeSlot(start: startStr, end: endStr)
                                    var slots = availability.availability[day] ?? []
                                    slots.append(newSlot)
                                    availability.availability[day] = slots.sorted(by: { $0.start < $1.start })
                                    showAddSlotSheet = false
                                }
                                .disabled(newEndTime <= newStartTime)
                            }
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    showAddSlotSheet = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct TutorAvailabilityView_Previews: PreviewProvider {
    class MockAuthVM: AuthenticationViewModel {
        override init() {
            super.init()
            var mockTutor = Tutor(
                userId: "mockTutor123",
                subjects: ["math-advanced", "physics"],
                educationLevel: .university,
                hourlyRate: 45.0,
                deliveryMode: .both,
                suburb: "Bondi"
            )
            mockTutor.availability = TutorAvailability(availability: [
                .monday: [
                    TimeSlot(start: "09:00", end: "10:00"),
                    TimeSlot(start: "14:00", end: "15:30")
                ],
                .wednesday: [
                    TimeSlot(start: "11:00", end: "12:00")
                ]
            ])
            self.currentTutor = mockTutor
        }
    }

    static var previews: some View {
        TutorAvailabilityView()
            .environmentObject(MockAuthVM())
    }
}
