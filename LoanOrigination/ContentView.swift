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
    let creditScore: String
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
            LoanApplicationView(loanApplications: $loanApplications, isPresented: .constant(true))
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

struct CheckBoxView: View {
    @Binding var isChecked: Bool
    
    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(isChecked ? .blue : .gray)
        }
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
                    Text("Credit Score: \(application.creditScore)")
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
    @State private var creditScore = ""
    @State private var purpose = ""
    @Environment(\.dismiss) var dismiss
    @State private var fullNameError = false
    @State private var loanAmountError = false
    @State private var creditScoreError = false
    @State private var purposeError = false
    @State private var agreedToTerms = false
    @Binding var isPresented: Bool // Add binding to control the presentation of the view
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false // Dismiss the view when the close button is tapped
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.title)
                        .foregroundColor(.primaryBlue)
                }
                .padding(.trailing)
            }
            Text("Loan Application Form")
                .font(.appTitleFont(size: 24))
                .foregroundColor(.primaryBlue)
                .padding(.top, 20)
                
            TextField("Full Name*", text: $fullName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: fullName) { newValue, oldValue in
                    fullNameError = newValue.isEmpty
                }
                .modifier(ErrorModifier(showError: fullNameError, errorMessage: "Full name is required"))
            
            TextField("Loan Amount*", text: $loanAmount)
                .keyboardType(.numberPad)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: loanAmount) { newValue, oldValue in
                    loanAmountError = newValue.isEmpty
                }
                .modifier(ErrorModifier(showError: loanAmountError, errorMessage: "Loan amount is required"))
            
            TextField("Purpose*", text: $purpose)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: purpose) { newValue, oldValue in
                    purposeError = newValue.isEmpty
                }
                .modifier(ErrorModifier(showError: purposeError, errorMessage: "Purpose is required"))
            
            TextField("Credit Score (Cibil Score)*", text: $creditScore)
                .keyboardType(.numberPad)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: creditScore) { newValue, oldValue in
                    creditScoreError = newValue.isEmpty
                }
                .modifier(ErrorModifier(showError: creditScoreError, errorMessage: "Credit Score is required"))
            
            //Text("Terms and Conditions")
                            //.font(.title)
                            //.padding()
                        
                        HStack {
                            CheckBoxView(isChecked: $agreedToTerms)
                            Text("I agree to the terms and conditions.")
                                .padding(.leading, 5)
                        }
                        .padding()
            
            Button(action: {
                // Validate fields
                if fullName.isEmpty {
                    fullNameError = true
                }
                if loanAmount.isEmpty {
                    loanAmountError = true
                }
                if purpose.isEmpty {
                    purposeError = true
                }
                if creditScore.isEmpty {
                    creditScoreError = true
                }
                
                // Check if all fields are filled
                if !fullName.isEmpty && !loanAmount.isEmpty && !purpose.isEmpty && !creditScore.isEmpty {
                    // Create a new loan application and add it to the list
                    let newApplication = LoanApplication(id: UUID(), fullName: fullName, loanAmount: loanAmount, purpose: purpose, creditScore: creditScore, status: "Pending")
                    loanApplications.append(newApplication)
                    
                    // Save loan applications to UserDefaults
                    saveLoanApplications()
                    
                    // Dismiss the view
                    isPresented = false
                }
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

// Modifier to show error message for text fields
struct ErrorModifier: ViewModifier {
    var showError: Bool
    var errorMessage: String
    
    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.trailing, 8)
                    .padding(.top, 2)
            }
        }
    }
}


struct LoanApplicationDetailsView: View {
    @State var application: LoanApplication
    
    func takeDecision() {
            if application.loanAmount <= "100000" && application.creditScore >= "500" && application.creditScore <= "800" {
                application.status = "Approved"
            } else {
                application.status = "Rejected"
            }
        }
    
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
            Text("Credit Score: \(application.creditScore)")
                .font(.appSubtitleFont(size: 16))
                .padding()
            Text("Status: \(application.status)")
                .font(.appSubtitleFont(size: 16))
                .padding()
            
            Button(action: {
                self.takeDecision()
                       }) {
                           Text("Take Decision")
                               .padding()
                               .foregroundColor(.white)
                               .background(Color.blue)
                               .cornerRadius(8)
                       }
                       .padding()
            
            Spacer()
        }
        .padding()
    }
}

// Dummy data
//let dummyUser = User(id: UUID(), username: "user123")
//
//var dummyLoanApplications: [LoanApplication] = [
//    LoanApplication(id: UUID(), fullName: "John Doe", loanAmount: "10000", purpose: "Home Renovation", status: "Pending"),
//    LoanApplication(id: UUID(), fullName: "Jane Smith", loanAmount: "5000", purpose: "Car Purchase", status: "Approved"),
//    LoanApplication(id: UUID(), fullName: "Alice Johnson", loanAmount: "20000", purpose: "Debt Consolidation", status: "Rejected")
//]

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

