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
    @State private var loanApplications: [LoanApplication] = []
    @State private var showingLoanApplication = false // State to control showing loan application view

    // Load saved loan applications and set isAuthenticated to false when the app starts
    init() {
        loadLoanApplications()
        isAuthenticated = false // Set to false to require login every time the app starts
    }

    var body: some View {
        NavigationView {
            if isAuthenticated {
                DashboardView(currentUser: $currentUser, loanApplications: $loanApplications, showingLoanApplication: $showingLoanApplication)
                    .navigationTitle("Dashboard")
            } else {
                AuthenticationView(isAuthenticated: $isAuthenticated, currentUser: $currentUser)
                    .navigationTitle("Authentication")
            }
        }
        .accentColor(.primaryBlue)
        .sheet(isPresented: $showingLoanApplication) {
            LoanApplicationView(loanApplications: $loanApplications)
        }
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

struct AuthenticationView: View {
    @Binding var isAuthenticated: Bool
    @Binding var currentUser: User?
    @State private var showingLoginPage = false // State to control navigation
    
    var body: some View {
        VStack {
            Text("Welcome to Loan App")
                .font(.appTitleFont(size: 24))
                .foregroundColor(.primaryBlue)
                .padding(.top, 20)
            
            Button(action: {
                showingLoginPage = true // Show login page
            }) {
                Text("Login")
                    .font(.appSubtitleFont(size: 18))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.primaryBlue)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $showingLoginPage) {
                LoginPageView(isAuthenticated: $isAuthenticated, currentUser: $currentUser)
            }
        }
        .padding()
    }
}

struct LoginPageView: View {
    @Binding var isAuthenticated: Bool
    @Binding var currentUser: User?
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                // Implement login logic here
                // For demonstration, let's simulate login success
                currentUser = User(id: UUID(), username: username)
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

struct DashboardView: View {
    @Binding var currentUser: User?
    @Binding var loanApplications: [LoanApplication]
    @Binding var showingLoanApplication: Bool // Add binding for showing loan application view
    @State private var selectedApplication: LoanApplication?
    
    var body: some View {
        VStack {
            Text("Loan Application Dashboard")
                .font(.appTitleFont(size: 24))
                .foregroundColor(.primaryBlue)
                .padding(.top, 20)
            
            Button(action: {
                showingLoanApplication.toggle() // Toggle the state to show/hide the loan application view
            }) {
                Text("Apply for Loan")
                    .font(.appSubtitleFont(size: 18))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.primaryBlue)
                    .cornerRadius(8)
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
    
    var body: some View {
        VStack {
            Text("Loan Application Form")
                .font(.appTitleFont(size: 24))
                .foregroundColor(.primaryBlue)
                .padding(.top, 20)
            
            TextField("Full Name", text: $fullName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Loan Amount", text: $loanAmount)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Purpose", text: $purpose)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                // Create a new loan application and add it to the list
                let newApplication = LoanApplication(id: UUID(), fullName: fullName, loanAmount: loanAmount, purpose: purpose, status: "Pending")
                loanApplications.append(newApplication)
                
                // Save loan applications to UserDefaults
                saveLoanApplications()
            }) {
                Text("Submit")
                    .font(.appSubtitleFont(size: 18))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.primaryBlue)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
    
    // Save loan applications to UserDefaults
    private func saveLoanApplications() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(loanApplications) {
            UserDefaults.standard.set(encoded, forKey: "loanApplications")
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

// Dummy data
let dummyUser = User(id: UUID(), username: "user123")

var dummyLoanApplications: [LoanApplication] = [
    LoanApplication(id: UUID(), fullName: "John Doe", loanAmount: "10000", purpose: "Home Renovation", status: "Pending"),
    LoanApplication(id: UUID(), fullName: "Jane Smith", loanAmount: "5000", purpose: "Car Purchase", status: "Approved"),
    LoanApplication(id: UUID(), fullName: "Alice Johnson", loanAmount: "20000", purpose: "Debt Consolidation", status: "Rejected")
]

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

