import SwiftUI
import FirebaseCore
//import FirebaseFirestore // For Firestore functionality

struct LoanApplicationView: View {
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
                // Handle form submission
                submitLoanApplication()
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
        .onAppear {
            FirebaseApp.configure() // Initialize Firebase when the view appears
        }
    }
    
//    func submitLoanApplication() {
//        let db = Firestore.firestore()
//        
//        // Add data to Firestore
//        db.collection("loanApplications").addDocument(data: [
//            "fullName": fullName,
//            "loanAmount": loanAmount,
//            "purpose": purpose
//        ]) { error in
//            if let error = error {
//                print("Error adding document: \(error)")
//            } else {
//                print("Loan application submitted successfully")
//            }
//        }
//    }
}

struct LoanApplicationView_Previews: PreviewProvider {
    static var previews: some View {
        LoanApplicationView()
    }
}
