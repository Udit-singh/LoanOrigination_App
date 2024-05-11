import SwiftUI

// Custom colors
extension Color {
    static let primaryBlue = Color("PrimaryBlue")
}

// Custom fonts
extension Font {
    static func appTitleFont(size: CGFloat) -> Font {
        return Font.custom("Avenir-Heavy", size: size)
    }
    
    static func appSubtitleFont(size: CGFloat) -> Font {
        return Font.custom("Avenir-Medium", size: size)
    }
}

struct User {
    let id: UUID
    let username: String
}

struct LoanApplication: Identifiable, Codable {
    let id: UUID
    let fullName: String
    let loanAmount: String
    let purpose: String
    var status: String // Change status to var for dynamic updates
}


struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var currentUser: User?
    @State private var fullName = ""
    @State private var loanAmount = ""
    @State private var purpose = ""
    @State private var showingReviewPage = false // State to control navigation
    @State private var loanApplications: [LoanApplication] = []

    // Load saved loan applications when the app starts
    init() {
        loadLoanApplications()
    }

    var body: some View {
        NavigationView {
            if isAuthenticated {
                DashboardView(currentUser: $currentUser, loanApplications: $loanApplications)
                    .navigationTitle("Dashboard")
            } else {
                AuthenticationView(isAuthenticated: $isAuthenticated, currentUser: $currentUser)
                    .navigationTitle("Authentication")
            }
        }
        .accentColor(.primaryBlue)
    }
    
    // Save loan applications to UserDefaults
    private func saveLoanApplications() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(loanApplications) {
            UserDefaults.standard.set(encoded, forKey: "loanApplications")
        }
    }
    
    // Load saved loan applications from UserDefaults
    private func loadLoanApplications() {
        if let data = UserDefaults.standard.data(forKey: "loanApplications") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([LoanApplication].self, from: data) {
                loanApplications = decoded
                return
            }
        }
        // If loading fails or no saved data, initialize with an empty array
        loanApplications = []
    }
}


struct DashboardView: View {
    @Binding var currentUser: User?
    @Binding var loanApplications: [LoanApplication]
    @State private var selectedApplication: LoanApplication?
    @State private var showingLoanApplication = false
    
    var body: some View {
        VStack {
            Text("Loan Application Dashboard")
                .font(.appTitleFont(size: 24))
                .foregroundColor(.primaryBlue)
                .padding(.top, 20)
            
            Button(action: {
                showingLoanApplication.toggle()
            }) {
                Text("Apply for Loan")
                    .font(.appSubtitleFont(size: 18))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.primaryBlue)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $showingLoanApplication) {
                LoanApplicationView(loanApplications: $loanApplications)
            }
            
            List(loanApplications) { application in
                VStack(alignment: .leading) {
                    Text("Applicant: \(application.fullName)")
                        .font(.appSubtitleFont(size: 16))
                    Text("Amount: \(application.loanAmount)")
                        .font(.appSubtitleFont(size: 16))
                    Text("Purpose: \(application.purpose)")
                        .font(.appSubtitleFont(size: 16))
                    Text("Status: \(application.status)")
                        .font(.appSubtitleFont(size: 16))
                }
                .padding()
                .onTapGesture {
                    selectedApplication = application
                }
            }
            .sheet(item: $selectedApplication) { application in
                LoanApplicationDetailsView(application: application)
            }
        }
        .padding()
    }
}


struct LoanApplicationView: View {
    @Binding var loanApplications: [LoanApplication]
    @State private var fullName = ""
    @State private var loanAmount = ""
    @State private var purpose = ""
    @State private var showingReviewPage = false // State to control navigation
    
    var body: some View {
        VStack {
            TextField("Full Name", text: $fullName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Loan Amount", text: $loanAmount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.numberPad)
            
            TextField("Purpose", text: $purpose)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                // Validate form data
                guard !fullName.isEmpty, !loanAmount.isEmpty, !purpose.isEmpty else {
                    return // Add proper validation logic
                }
                
                // Save data to local storage
                let newApplication = LoanApplication(id: UUID(), fullName: fullName, loanAmount: loanAmount, purpose: purpose, status: "Pending")
                loanApplications.append(newApplication)
                
                showingReviewPage = true // Show review page
            }) {
                Text("Submit")
                    .font(.appSubtitleFont(size: 18))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.primaryBlue)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
        .sheet(isPresented: $showingReviewPage) {
            // Display review page
            ReviewPageView(fullName: $fullName, loanAmount: $loanAmount, purpose: $purpose)
        }
    }
}

struct LoanApplicationDetailsView: View {
    let application: LoanApplication
    
    var body: some View {
        VStack {
            Text("Loan Application Details")
                .font(.appTitleFont(size: 24))
                .foregroundColor(.primaryBlue)
                .padding(.top, 20)
            
            Text("Applicant: \(application.fullName)")
                .font(.appSubtitleFont(size: 16))
                .padding()
            Text("Loan Amount: \(application.loanAmount)")
                .font(.appSubtitleFont(size: 16))
                .padding()
            Text("Purpose: \(application.purpose)")
                .font(.appSubtitleFont(size: 16))
                .padding()
            Text("Status: \(application.status)")
                .font(.appSubtitleFont(size: 16))
                .padding()
            
            Spacer()
        }
        .padding()
    }
}

struct AuthenticationView: View {
    @Binding var isAuthenticated: Bool
    @Binding var currentUser: User?
    
    var body: some View {
        VStack {
            Text("Welcome to Loan App")
                .font(.appTitleFont(size: 24))
                .foregroundColor(.primaryBlue)
                .padding(.top, 20)
            
            Button(action: {
                // Simulate login
                currentUser = dummyUser
                isAuthenticated = true
            }) {
                Text("Login")
                    .font(.appSubtitleFont(size: 18))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.primaryBlue)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct ReviewPageView: View {
    @Binding var fullName: String
    @Binding var loanAmount: String
    @Binding var purpose: String
    
    var body: some View {
        VStack {
            Text("Review Page")
                .font(.appTitleFont(size: 24))
                .foregroundColor(.primaryBlue)
                .padding(.top, 20)
            
            Text("Full Name: \(fullName)")
                .font(.appSubtitleFont(size: 16))
                .padding()
            Text("Loan Amount: \(loanAmount)")
                .font(.appSubtitleFont(size: 16))
                .padding()
            Text("Purpose: \(purpose)")
                .font(.appSubtitleFont(size: 16))
                .padding()
            
            Spacer()
        }
        .padding()
    }
}

// Dummy data
let dummyUser = User(id: UUID(), username: "user123")

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
