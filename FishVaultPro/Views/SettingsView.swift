import SwiftUI
import StoreKit

struct SettingsView: View {
    
    @Environment(\.requestReview) var requestReview
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAbout = false
    @State private var showingPrivacy = false
    @State private var showingExport = false
    @State private var showingReset = false
    @State private var notificationsEnabled = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.deepOcean.ignoresSafeArea()
                
                List {
                    // App Settings Section
                    Section(header: Text("App Settings").foregroundColor(AppColors.textSecondary)) {
                        Toggle(isOn: $notificationsEnabled) {
                            HStack(spacing: 12) {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(AppColors.primaryAccent)
                                    .frame(width: 24)
                                Text("Notifications")
                                    .foregroundColor(AppColors.textPrimary)
                            }
                        }
                        .tint(AppColors.primaryAccent)
                    }
                    .listRowBackground(AppColors.cardBackground)
                    
                    // Data Section
                    Section(header: Text("Data").foregroundColor(AppColors.textSecondary)) {
                        Button(action: { showingExport = true }) {
                            SettingsRow(
                                icon: "arrow.up.doc",
                                title: "Export Data",
                                color: AppColors.primaryAccent
                            )
                        }
                        
                        Button(action: { showingReset = true }) {
                            SettingsRow(
                                icon: "trash",
                                title: "Reset All Data",
                                color: AppColors.warning
                            )
                        }
                    }
                    .listRowBackground(AppColors.cardBackground)
                    
                    // About Section
                    Section(header: Text("About").foregroundColor(AppColors.textSecondary)) {
                        Button(action: { showingAbout = true }) {
                            SettingsRow(
                                icon: "info.circle",
                                title: "About Fish Vault Pro",
                                color: AppColors.secondaryAccent
                            )
                        }
                        
                        Button(action: { showingPrivacy = true }) {
                            SettingsRow(
                                icon: "lock.shield",
                                title: "Privacy Policy",
                                color: AppColors.textSecondary
                            )
                        }
                        
                        Button(action: { requestReview() }) {
                            SettingsRow(
                                icon: "star.fill",
                                title: "Rate App",
                                color: Color(hex: "FFD700")
                            )
                        }
                    }
                    .listRowBackground(AppColors.cardBackground)
                    
                    // Version
                    Section {
                        HStack {
                            Spacer()
                            VStack(spacing: 4) {
                                Text("Fish Vault Pro")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppColors.textPrimary)
                                Text("Version 2.0")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppColors.primaryAccent)
                }
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(isPresented: $showingPrivacy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showingExport) {
                ExportDataView()
            }
            .alert("Reset All Data", isPresented: $showingReset) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will permanently delete all your vaults and entries. This action cannot be undone.")
            }
        }
    }
    
    private func resetAllData() {
        // Clear Firebase data
        let vaults = VaultListViewModel().vaults
        for vault in vaults {
            FirebaseService.shared.deleteVault(vault.id) { _ in }
        }
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        
        // Sign out
        AuthService.shared.signOut()
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 32)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.vertical, 8)
    }
}

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.deepOcean.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // App Icon & Name
                        VStack(spacing: 16) {
                            Image(systemName: "drop.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(AppColors.primaryAccent)
                                .padding(30)
                                .background(
                                    Circle()
                                        .fill(AppColors.cardBackground)
                                        .shadow(color: AppColors.primaryAccent.opacity(0.3), radius: 20)
                                )
                            
                            VStack(spacing: 8) {
                                Text("Fish Vault Pro")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Text("Version 1.0.0")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        .padding(.top, 40)
                        
                        // Description
                        VStack(alignment: .leading, spacing: 16) {
                            Text("About")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Fish Vault Pro transforms habit tracking into an enchanting underwater experience. Watch your progress come alive as animated fish swim faster with every milestone you achieve.")
                                .font(.system(size: 16))
                                .foregroundColor(AppColors.textSecondary)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cardStyle()
                        .padding(.horizontal, 24)
                        
                        // Features
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Features")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            FeatureRow(icon: "chart.bar.fill", title: "Track Anything", description: "Numeric tracking, checklists, progress goals, and counters")
                            FeatureRow(icon: "sparkles", title: "Gamified Progress", description: "Watch fish swim faster as you progress")
                            FeatureRow(icon: "flag.fill", title: "Milestones", description: "Set goals and unlock new fish types")
                            FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Statistics", description: "Detailed analytics and progress charts")
                            FeatureRow(icon: "folder.fill", title: "Categories", description: "Organize vaults by categories and tags")
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cardStyle()
                        .padding(.horizontal, 24)
                        
                        // Credits
                        VStack(spacing: 8) {
                            Text("Made with 💙 for productivity enthusiasts")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                            
                            Text("© 2026 Fish Vault Pro")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary.opacity(0.7))
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppColors.primaryAccent)
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.primaryAccent)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.deepOcean.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Privacy Policy")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Last Updated: January 15, 2026")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.top, 20)
                        
                        // Sections
                        PrivacySection(
                            title: "Our Commitment",
                            content: "Fish Vault Pro is committed to protecting your privacy. This policy explains how we collect, use, and safeguard your information."
                        )
                        
                        PrivacySection(
                            title: "Information We Collect",
                            content: """
                            • Vault names and descriptions
                            • Tracking entries (numbers, notes, dates)
                            • Goal settings and preferences
                            • Anonymous user ID for authentication
                            • App usage analytics (crash reports, performance)
                            """
                        )
                        
                        PrivacySection(
                            title: "How We Use Your Information",
                            content: """
                            We use your data solely to:
                            • Provide and improve app functionality
                            • Sync your data across devices
                            • Diagnose technical issues
                            • Enhance user experience
                            """
                        )
                        
                        PrivacySection(
                            title: "What We DON'T Do",
                            content: """
                            • Sell your data to third parties
                            • Use your data for advertising
                            • Share your personal information
                            • Track your location
                            • Access your contacts or photos
                            """
                        )
                        
                        PrivacySection(
                            title: "Data Storage & Security",
                            content: """
                            • Data encrypted in transit (SSL/TLS)
                            • Stored on secure Firebase servers
                            • Protected by industry-standard security
                            • Access restricted to your account only
                            """
                        )
                        
                        PrivacySection(
                            title: "Your Rights",
                            content: """
                            You have the right to:
                            • Access your data
                            • Correct inaccurate data
                            • Delete your data
                            • Export your data
                            • Opt-out of analytics
                            """
                        )
                        
                        PrivacySection(
                            title: "Contact Us",
                            content: """
                            Questions about privacy?
                            Email: fishvaultpro@support.com
                            Response time: Within 48 hours
                            """
                        )
                        
                        // Footer
                        Text("By using Fish Vault Pro, you agree to this Privacy Policy.")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary.opacity(0.7))
                            .padding(.top, 16)
                            .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppColors.primaryAccent)
                }
            }
        }
    }
}

struct PrivacySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.primaryAccent)
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(AppColors.textSecondary)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

struct ExportDataView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isExporting = false
    @State private var showingShareSheet = false
    @State private var exportURL: URL?
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.deepOcean.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Icon
                    Image(systemName: "arrow.up.doc.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppColors.primaryAccent)
                        .padding(.top, 60)
                    
                    VStack(spacing: 16) {
                        Text("Export Your Data")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Export all your vaults and entries as a JSON file")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    
                    if isExporting {
                        ProgressView()
                            .tint(AppColors.primaryAccent)
                            .scaleEffect(1.5)
                    } else {
                        Button(action: exportData) {
                            Text("Export Data")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.deepOcean)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [AppColors.secondaryAccent, AppColors.primaryAccent],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 40)
                    }
                    
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
    
    private func exportData() {
        isExporting = true
        
        FirebaseService.shared.fetchVaults { result in
            switch result {
            case .success(let vaults):
                do {
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    encoder.dateEncodingStrategy = .iso8601
                    
                    let data = try encoder.encode(vaults)
                    
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let fileName = "FishVaultPro_Export_\(Date().formatted(date: .numeric, time: .omitted)).json"
                    let fileURL = documentsPath.appendingPathComponent(fileName)
                    
                    try data.write(to: fileURL)
                    
                    DispatchQueue.main.async {
                        self.exportURL = fileURL
                        self.isExporting = false
                        self.showingShareSheet = true
                    }
                } catch {
                    print("Error exporting: \(error)")
                    DispatchQueue.main.async {
                        self.isExporting = false
                    }
                }
                
            case .failure(let error):
                print("Error fetching vaults: \(error)")
                DispatchQueue.main.async {
                    self.isExporting = false
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
