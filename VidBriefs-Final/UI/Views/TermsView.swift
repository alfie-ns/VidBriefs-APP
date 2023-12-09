import SwiftUI



struct TermsView: View {
    
    @EnvironmentObject var settings: SharedSettings
    
    @Binding var currentPath: AppNavigationPath
    @State private var termsAccepted: Bool = UserDefaults.standard.bool(forKey: "termsAccepted")

    var termsText: String {
        
        let rawText = """
                
        Last Updated: 7/11/23

        Welcome to VidBriefs

        These terms and conditions outline the rules and regulations for the use of VidBriefs's mobile application, available on iOS.

        By accessing and using VidBriefs, you accept these terms and conditions in full. Do not continue to use VidBriefs if you do not accept all of the terms and conditions stated on this page.
        
        0. Disclaimer

        VidBriefs provides an AI-powered video summarization service utilizing publicly accessible YouTube video content. The AI technology processes video transcripts to deliver concise summaries and responses to user queries. VidBriefs is not responsible for the accuracy, completeness, or reliability of the information provided by the AI, as it relies on external content sources.

        The summaries and insights generated by VidBriefs are intended for informational purposes only. Users are advised to exercise their own judgment and discretion while interpreting and using the information provided by the app. VidBriefs does not guarantee the validity or utility of the information provided and is not liable for any decisions made based on such information.

        The use of VidBriefs and its AI-generated content is at the sole risk of the user. VidBriefs does not endorse, support, represent, or guarantee the completeness, truthfulness, accuracy, or reliability of any content or communications provided through the service. The app should not be used as the sole basis for any serious, legal, or critical decisions.

        Users are responsible for ensuring that their use of the app and its content complies with YouTube's terms of service and all applicable laws and regulations. VidBriefs disclaims all liability for any harm, loss, or damage of any kind arising from the use of the app, including but not limited to direct, indirect, incidental, punitive, and consequential damages."

        This disclaimer is designed to clearly state the limitations of your service and the user's responsibility in using the app. It's important to have such disclaimers reviewed by a legal professional to ensure they are compliant with local laws and effectively limit your liability.
        
        

        1. Intellectual Property Rights

        Other than the content you own, which you may have opted to include on this Application, under these Terms, VidBriefs and/or its licensors own all rights to the intellectual property and material contained in this Application, and all such rights are reserved.

        2. Restrictions

        You are expressly restricted from all of the following:

        Publishing any Application material in any media without prior consent;
        Selling, sublicensing, and/or otherwise commercializing any Application material;
        Publicly performing and/or showing any Application material;
        Using this Application in any way that is, or may be, damaging to this Application;
        Using this Application in any way that impacts user access to this Application;
        Using this Application contrary to applicable laws and regulations, or in a way that causes, or may cause, harm to the Application, or to any person or business entity;
        Engaging in any data mining, data harvesting, data extracting, or any other similar activity in relation to this Application, or while using this Application;
        Using this Application to engage in any advertising or marketing without prior written consent.

        3. Content

        In these Terms and Conditions, “Content” shall mean any audio, video, text, images, or other material you choose to display on this Application. With respect to your Content, by displaying it, you grant VidBriefs a non-exclusive, worldwide, irrevocable, royalty-free, sublicensable license to use, reproduce, adapt, publish, translate, and distribute it in any and all media.

        Your Content must be your own and must not be infringing on any third party’s rights. VidBriefs reserves the right to remove any of your Content from this Application at any time, and for any reason, without notice.

        4. Service Description and Content Disclaimer

        VidBriefs provides an AI-powered summarization service for YouTube content. The Application uses publicly available APIs to scrape data from YouTube videos to create concise summaries. That service is provided free of charge to any person who'd pip install the module(youtube_transcript_api)

        VidBriefs is not affiliated, associated, authorized, endorsed by, or in any way officially connected with YouTube, or any of its subsidiaries or its affiliates. The official YouTube website can be found at http://www.youtube.com. The name “YouTube” as well as related names, marks, emblems, and images are registered trademarks of their respective owners.

        All content made available through VidBriefs is provided by YouTube and is they're sole responsibility of the entity that makes it available. We claim no ownership over the content provided and are not responsible for any content, including but not limited to any summaries, alterations, or representations of the content provided through our Application.

        5. No warranties

        This Application is provided “as is,” with all faults, and VidBriefs makes no express or implied representations or warranties, of any kind related to this Application or the materials contained on this Application.

        6. Limitation of liability

        In no event shall VidBriefs, nor any of its officers, directors, and employees, be liable for anything arising out of or in any way connected with your use of this Application, whether such liability is under contract, tort, or otherwise, and VidBriefs, including its officers, directors, and employees, shall not be liable for any indirect, consequential, or special liability arising out of or in any way related to your use of this Application.

        7. Indemnification

        You hereby indemnify to the fullest extent VidBriefs from and against any and all liabilities, costs, demands, causes of action, damages, and expenses (including reasonable attorney’s fees) arising out of or in any way related to your breach of any of the provisions of these Terms.

        8. Severability

        If any provision of these Terms is found to be unenforceable or invalid under any applicable law, such unenforceability or invalidity shall not render these Terms unenforceable or invalid as a whole, and such provisions shall be deleted without affecting the remaining provisions herein.

        9. Variation of Terms

        VidBriefs is permitted to revise these Terms at any time as it sees fit, and by using this Application you are expected to review such Terms on a regular basis to ensure you understand all terms and conditions governing the use of this Application.

        10. Assignment

        VidBriefs shall be permitted to assign, transfer, and subcontract its rights and/or obligations under these Terms without any notification or consent required. However, you shall not be permitted to assign, transfer, or subcontract any of your rights and/or obligations under these Terms.

        11. Entire Agreement

        These Terms, including any legal notices and disclaimers contained on this Application, constitute the entire agreement between VidBriefs and you in relation to your use of this Application, and supersede all prior agreements and understandings with respect to the same.

        Governing Law & Jurisdiction

        These Terms will be governed by and construed in accordance with the laws of the country of the United Kingdom, and you submit to the non-exclusive jurisdiction of the state and federal courts located in United Kingdom for the resolution of any disputes.

        Contact Information

        For any inquiries or complaints regarding the service or these terms and conditions, please contact vidbriefs@gmail.com

        """

        var lines = rawText.components(separatedBy: .newlines)
        for i in 0..<lines.count-1 {
            lines[i] = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
            if !lines[i].isEmpty {
                lines[i] += ","
            }
        }
        return lines.joined(separator: "\n")
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Button(action: {
                    currentPath = .settings
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundStyle(.white)
                        .font(.system(size: 24))
                        .padding()
                }
                
                Text("TERMS AND CONDITIONS")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Text(termsText)
                    .padding()
                    .foregroundStyle(.white)
                
                // Inside the VStack of your TermsView
                Button(action: {
                    settings.termsAccepted = true
                    currentPath = .insights
                }) {
                    Text("Accept Terms")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(settings.termsAccepted ? Color.green : Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

            }
        }
    }
}