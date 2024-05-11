import SwiftUI

struct User {
    let id: UUID
    let username: String
}

struct LoanApplication {
    let id: UUID
    let fullName: String
    let loanAmount: String
    let purpose: String
    var status: String // Change status to var for dynamic updates
}

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var currentUser: User?
    
    var body: some View {
        NavigationView {
            if isAuthenticated {
                DashboardView(currentUser: $currentUser)
                    .navigationTitle("Dashboard")
            } else {
                AuthenticationView(isAuthenticated: $isAuthenticated, currentUser: $currentUser)
                    .navigationTitle("Authentication")
            }
        }
    }
}

struct DashboardView: View {
    @Binding var currentUser: User?
    @State private var showingLoanApplication = false
    
    var body: some View {
        VStack {
            Text("Loan Application Dashboard")
                .font(.title)
            
            Button(action: {
                showingLoanApplication.toggle()
            }) {
                Text("Apply for Loan")
            }
            .sheet(isPresented: $showingLoanApplication) {
                LoanApplicationView(currentUser: $currentUser)
            }
            
            List(dummyLoanApplications, id: \.id) { application in
                VStack(alignment: .leading) {
                    Text("Applicant: \(application.fullName)")
                    Text("Amount: \(application.loanAmount)")
                    Text("Purpose: \(application.purpose)")
                    Text("Status: \(application.status)")
                }
                .padding()
            }
        }
        .padding()
    }
}

struct LoanApplicationView: View {
    @Binding var currentUser: User?
    @State private var fullName = ""
    @State private var loanAmount = ""
    @State private var purpose = ""
    
    var body: some View {
        VStack {
            TextField("Full Name", text: $fullName)
                .padding()
            
            TextField("Loan Amount", text: $loanAmount)
                .padding()
                .keyboardType(.numberPad)
            
            TextField("Purpose", text: $purpose)
                .padding()
            
            Button(action: {
                // Validate form data
                guard !fullName.isEmpty, !loanAmount.isEmpty, !purpose.isEmpty else {
                    return // Add proper validation logic
                }
                
                // Handle form submission (dummy)
                let newApplication = LoanApplication(id: UUID(), fullName: fullName, loanAmount: loanAmount, purpose: purpose, status: "Pending")
                dummyLoanApplications.append(newApplication)
            }) {
                Text("Submit")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
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
                .font(.title)
            
            Button(action: {
                // Simulate login
                currentUser = dummyUser
                isAuthenticated = true
            }) {
                Text("Login")
            }
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
