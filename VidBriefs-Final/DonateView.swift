import SwiftUI
import PassKit

// Separate class to handle payment authorization
class PaymentHandler: NSObject, PKPaymentAuthorizationViewControllerDelegate {
    var onPaymentAuthorized: ((PKPayment, @escaping (PKPaymentAuthorizationStatus) -> Void) -> Void)?
    var onPaymentFinished: (() -> Void)?

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: onPaymentFinished)
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        onPaymentAuthorized?(payment, completion)
    }
}

struct DonateView: View {
    @Binding var currentPath: AppNavigationPath
    @State private var showingPaymentSheet = false
    @State private var showingApplePayNotAvailableAlert = false
    @State private var paymentHandler = PaymentHandler()
    @State private var donationAmount: NSDecimalNumber = NSDecimalNumber(string: "5.00") // Default amount
    @State private var customDonationAmount: String = ""

    var paymentRequest: PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "your.merchant.id"
        request.supportedNetworks = [.visa, .masterCard, .amex]
        request.merchantCapabilities = .threeDSecure
        request.countryCode = "UK"
        request.currencyCode = "GBP"
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Donation", amount: donationAmount)
        ]
        return request
    }

    // This method presents the Apple Pay sheet
    private func presentApplePay() {
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentRequest.supportedNetworks) {
            showingPaymentSheet = true
        } else {
            showingApplePayNotAvailableAlert = true
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                currentPath = .settings
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.black)
                    .font(.system(size: 24))
                    .padding()
            }

            Text("Support Our Work")
                .font(.title)
                .fontWeight(.bold)

            Text("If you enjoy using the app, please consider supporting with a donation. Your support helps me to keep improving the app and add new features!")
                .multilineTextAlignment(.center)
                .padding()
            
            // Donation options
            HStack {
                ForEach(["5.00", "10.00", "20.00"], id: \.self) { amount in
                    Button("£\(amount)") {
                        self.donationAmount = NSDecimalNumber(string: amount)
                        self.presentApplePay()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }

            // Custom donation amount
            HStack {
                TextField("Custom amount", text: $customDonationAmount)
                    .keyboardType(.decimalPad)
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Donate Custom") {
                    let amount = NSDecimalNumber(string: self.customDonationAmount)
                    if amount != NSDecimalNumber.notANumber {
                        self.donationAmount = amount
                        self.presentApplePay()
                    } else {
                        // Handle invalid number entry
                        self.showingApplePayNotAvailableAlert = true // Use a different alert to show the error
                    }
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Button("Donate with Apple Pay", action: presentApplePay)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .sheet(isPresented: $showingPaymentSheet) {
                    ApplePayController(paymentRequest: paymentRequest, onPaymentAuthorized: { payment, completion in
                        // Handle the authorized payment, send to your server for processing, and then call the completion handler
                        completion(.success)
                    }, onPaymentFinished: {
                        // Handle the finished payment process
                    })
                }
        }
        .navigationBarTitle("Donate", displayMode: .inline)
        .alert(isPresented: $showingApplePayNotAvailableAlert) {
            Alert(
                title: Text("Can't access Apple Pay"),
                message: Text("Apple Pay is not available on this device. Please set up Apple Pay in Wallet or use another payment method."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// UIViewControllerRepresentable to present the Apple Pay sheet
struct ApplePayController: UIViewControllerRepresentable {
    var paymentRequest: PKPaymentRequest
    var onPaymentAuthorized: ((PKPayment, @escaping (PKPaymentAuthorizationStatus) -> Void) -> Void)?
    var onPaymentFinished: (() -> Void)?

    func makeUIViewController(context: Context) -> PKPaymentAuthorizationViewController {
        if let controller = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) {
            controller.delegate = context.coordinator
            return controller
        } else {
            fatalError("Unable to create PKPaymentAuthorizationViewController.")
        }
    }

    func updateUIViewController(_ uiViewController: PKPaymentAuthorizationViewController, context: Context) {
        // This method is required but can be left empty if there's no need to update the view controller.
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(handler: PaymentHandler())
    }

    class Coordinator: NSObject, PKPaymentAuthorizationViewControllerDelegate {
        let handler: PaymentHandler

        init(handler: PaymentHandler) {
            self.handler = handler
        }

        func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
            handler.paymentAuthorizationViewControllerDidFinish(controller)
        }

        func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
            handler.paymentAuthorizationViewController(controller, didAuthorizePayment: payment, completion: completion)
        }
    }
}
