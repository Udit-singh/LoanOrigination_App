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
    @State private var showingSignUpPage = false
    
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
                    .font(.appSubtitleFont(size: 28))
                    .foregroundColor(.blue)
                    .bold()
                    .underline()
                    .padding()
                    .background(Color.primaryBlue)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $showingLoginPage) {
                LoginPageView(isAuthenticated: $isAuthenticated, currentUser: $currentUser)
            }
            
            Button(action: {
                            showingSignUpPage = true // Show sign-up page
                        }) {
                            Text("Sign Up")
                                .font(.appSubtitleFont(size: 28))
                                .foregroundColor(.blue)
                                .bold()
                                .underline()
                                .padding()
                                .background(Color.primaryBlue)
                                .cornerRadius(8)
                        }
                        .sheet(isPresented: $showingSignUpPage) {
                            SignUpPageView(isAuthenticated: $isAuthenticated, currentUser: $currentUser)
                        }
            
        }
        .padding()
    }
}

struct SignUpPageView: View {
    @Binding var isAuthenticated: Bool
    @Binding var currentUser: User?
    @Environment(\.dismiss) var dismiss
    @State private var fullName = ""
    @State private var username = ""
    @State private var dateOfBirth = Date()
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false // State to toggle password visibility
    @State private var showError = false // State to control error message visibility
    @State private var passwordStrength = "" // State to store password strength indicator
    @State private var agreedToTerms = false // State to track agreement to terms
    @State private var isUsernameAvailable = false // State to track username availability
    @State private var isUnder18 = false
    @State private var passwordsMatchError = false
    @State private var showConfirmPassword = false
    
    var body: some View {
        VStack {
            TextField("Full Name", text: $fullName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Username", text: $username, onEditingChanged: { _ in
                // Implement username availability check here
                
                if(!username.isEmpty){
                    isUsernameAvailable = checkUsernameAvailability(username)
                }
            })
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .alert(isPresented: Binding<Bool>(
                get: { isUsernameAvailable },
                set: { _ in isUsernameAvailable = false })) {
                Alert(title: Text("Username Availability"), message: Text(isUsernameAvailable ? "Username is available" : "Username is already taken"), dismissButton: .default(Text("OK")))
            }
            
            DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                            .padding()
                            .onChange(of: dateOfBirth) { newValue, newValue in
                                isUnder18 = calculateAge(birthDate: newValue) < 18
                            }
            
            HStack {
                if showPassword {
                    TextField("Password", text: $password, onEditingChanged: { _ in
                        passwordStrength = passwordStrengthIndicator(password)
                    })
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    SecureField("Password", text: $password, onCommit: {
                        passwordStrength = passwordStrengthIndicator(password)
                    })
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                        .foregroundColor(.secondary)
                        .padding(.trailing, 8)
                }
            }
            
            Text(passwordStrength)
                .foregroundColor(passwordStrengthColor(passwordStrength))
                .padding(.leading)
            
            
            if showPassword {
                TextField("Confirm Password", text: $confirmPassword)
                                        .padding()
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                SecureField("Confirm Password", text: $confirmPassword)
                                        .padding()
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        

            if passwordsMatchError {
                Text("Passwords do not match")
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.trailing, 8)
                    .padding(.top, 2)
            }
            
            HStack {
                CheckBoxView(isChecked: $agreedToTerms)
                Text("I agree to the terms of service and privacy policy.")
                    .foregroundColor(.primary)
            }
            .padding(.horizontal)

            Button(action: {
                              
                let (passwordsMatch, passwordStrength) = validatePasswords(password: password, confirmPassword: confirmPassword, isPasswordVisible: showPassword)

                // Validate fields
                if fullName.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty || !agreedToTerms {
                       showError = true
                    if !passwordsMatch {
                                passwordsMatchError = true
                            }
                    return
                }
                
                // Implement sign-up logic here
                // For demonstration, let's simulate sign-up success by logging in
                currentUser = User(id: UUID(), username: username)
                isAuthenticated = true
                
            }) {
                Text("Sign Up")
                    .font(.appSubtitleFont(size: 18))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.primaryBlue)
                    .cornerRadius(8)
            }
            .alert(isPresented: $showError) {
                            let errorMessage = "Please fill out all required fields"
                                + (isUnder18 ? ", ensure you are at least 18 years old" : "")
                                + (!agreedToTerms ? ", and agree to the terms of service." : "")
                                + (passwordStrength != "Strong" ? ", and use a strong password." : "")
                            return Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                        }
        }
        .padding()
    }
    
    private func validatePasswords(password: String, confirmPassword: String, isPasswordVisible: Bool) -> (isMatch: Bool, strength: String) {
        // Check if passwords match
        let passwordsMatch = password == confirmPassword
        
        // Determine strength of password
        let passwordStrength = passwordStrengthIndicator(password)
        
        return (passwordsMatch, passwordStrength)
    }

    // Function to check username availability (dummy implementation)
    private func checkUsernameAvailability(_ username: String) -> Bool {
        // Dummy implementation: assume username is always available
        return true
    }

    // Function to calculate password strength
    private func passwordStrengthIndicator(_ password: String) -> String {
        let passwordLength = password.count
        switch passwordLength {
        case 0:
            return ""
        case 1..<8:
            return "Weak"
        case 8..<12:
            return "Moderate"
        default:
            return "Strong"
        }
    }

    // Function to determine color based on password strength
    private func passwordStrengthColor(_ strength: String) -> Color {
        switch strength {
        case "Weak":
            return .red
        case "Moderate":
            return .orange
        case "Strong":
            return .green
        default:
            return .primary
        }
    }
}


struct PasswordToggleModifier: ViewModifier {
    @Binding var isPasswordVisible: Bool
    
    func body(content: Content) -> some View {
        HStack {
            content
            
            Button(action: {
                isPasswordVisible.toggle()
            }) {
                Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                    .foregroundColor(.secondary)
                    .padding(.trailing, 8)
            }
        }
    }
}

// Function to calculate password strength
private func passwordStrengthIndicator(_ password: String) -> String {
    let passwordLength = password.count
    let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
    let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
    let hasNumbers = password.rangeOfCharacter(from: .decimalDigits) != nil
    let hasSpecialCharacters = password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?")) != nil
    
    if passwordLength < 8 || !hasUppercase || !hasLowercase || !hasNumbers || !hasSpecialCharacters {
        return "Weak"
    } else if passwordLength < 12 {
        return "Moderate"
    } else {
        return "Strong"
    }
}


    
    // Function to determine color based on password strength
    private func passwordStrengthColor(_ strength: String) -> Color {
        switch strength {
        case "Weak":
            return .red
        case "Moderate":
            return .orange
        case "Strong":
            return .green
        default:
            return .primary
        }
    }
    
private func calculateAge(birthDate: Date) -> Int {
       let calendar = Calendar.current
       let currentDate = Date()
       let ageComponents = calendar.dateComponents([.year], from: birthDate, to: currentDate)
       let age = ageComponents.year ?? 0
       return age
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
    @Binding var showingLoanApplication: Bool
    @State private var selectedApplication: LoanApplication?
    @State private var showingAboutPage = false
    
    // Function to handle opening the About page
        private func openAboutPage() {
            showingAboutPage = true
        }

    func getStatus(for application: LoanApplication) -> String {
        if let index = loanApplications.firstIndex(where: { $0.id == application.id }) {
            return loanApplications[index].status
        }
        return "Pending"
    }

    var body: some View {
        VStack {
            Text("Loan App Dashboard")
                .font(.appTitleFont(size: 20))
                .foregroundColor(.primaryBlue)
                .padding(.top, 20)
            
            
            Button(action: {
                            openAboutPage()
                        }) {
                            Image(systemName: "info.circle")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .sheet(isPresented: $showingAboutPage) {
                            AboutView()
                        }
            
            Button(action: {
                self.showingLoanApplication.toggle()
            }) {
                Text("Apply for Loan")
                    .font(.appSubtitleFont(size: 18))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.primaryBlue)
                    .cornerRadius(8)
            }
            .padding()

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
                    Text("Status: \(self.getStatus(for: application))")
                        .font(.appSubtitleFont(size: 16))
                }
                .padding()
                .onTapGesture {
                    selectedApplication = application
                }
            }
            .sheet(item: $selectedApplication) { application in
                let index = getIndex(for: application)
                LoanApplicationDetailsView(application: $loanApplications[index], status: self.$loanApplications[index].status)
            }

        }
        .padding()
        .navigationBarTitle("Loan App Dashboard")
    }

    func getIndex(for application: LoanApplication) -> Int {
        if let index = loanApplications.firstIndex(where: { $0.id == application.id }) {
            return index
        }
        return 0 // Default value to return if index is not found
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        // Create an empty array of LoanApplication objects
        let loanApplications: [LoanApplication] = []
        
        // Pass the loanApplications array to the DashboardView in the preview
        return DashboardView(currentUser: .constant(nil), loanApplications: .constant(loanApplications), showingLoanApplication: .constant(false))
    }
}


//
//struct DashboardView_Previews: PreviewProvider {
//    static var previews: some View {
//        return DashboardView(currentUser: .constant(nil), loanApplications: .constant(LoanApplication), showingLoanApplication: .constant(false))
//    }
//}

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
            Text("Apply For Loan")
                .font(.appTitleFont(size: 24))
                .foregroundColor(.blue)
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
                            Text(agreedToTerms ? "You have to agree the terms and conditions." : "Please agree to the terms and conditions.")
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
                if !fullName.isEmpty && !loanAmount.isEmpty && !purpose.isEmpty && !creditScore.isEmpty && agreedToTerms {
                    // Create a new loan application and add it to the list
                    let newApplication = LoanApplication(id: UUID(), fullName: fullName, loanAmount: loanAmount, purpose: purpose, creditScore: creditScore, status: "Pending")
                    loanApplications.append(newApplication)
                    
                    // Save loan applications to UserDefaults
                    saveLoanApplications()
                    
                    // Dismiss the view
                    isPresented = false
                    
                    dismiss()
                }
                else{
                    agreedToTerms = false;
                }
            }) {
                Text("Submit")
                    .font(.appSubtitleFont(size: 24))
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }.buttonStyle(.borderedProminent)
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
    @Binding var application: LoanApplication
    @Binding var status: String
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
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
                .foregroundColor(.blue)
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
                dismiss()
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
        .navigationBarItems(trailing: Button(action: {
            self.presentationMode.wrappedValue.dismiss()

        }) {
            Text("Close")
                .foregroundColor(.primary)
        }
                            )};
}


struct AboutView: View {
    var body: some View {
        VStack {
            Text("About Loan App")
                .font(.title)
                .padding()
            
            Text("The Loan Origination App is a mobile application that allows users to apply for loans conveniently from their smartphones. The app streamlines the loan application process, making it easier for individuals to access credit facilities, especially those who may have limited access to traditional banking services..")
                .padding()
            
            Divider()
            
            Text("Developers:")
                .font(.title2)
                .padding()
            
            DeveloperRow(name: "Udit Singh")
            DeveloperRow(name: "Kumaravel")
            DeveloperRow(name: "Shiva Ganesh")
            DeveloperRow(name: "Deepak Puram")
            
            Spacer()
        }
        .navigationBarTitle("About")
    }
}

struct DeveloperRow: View {
    var name: String
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.title)
            Text(name)
                .font(.headline)
                .padding()
            Spacer()
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
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

