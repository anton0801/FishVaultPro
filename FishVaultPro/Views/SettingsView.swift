// Views/Settings/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.deepOcean.ignoresSafeArea()
                
                List {
                    Section {
                        SettingsRow(icon: "arrow.up.doc", title: "Export Data", color: AppColors.primaryAccent)
                        SettingsRow(icon: "trash", title: "Reset Vault", color: AppColors.warning)
                    }
                    
                    Section {
                        SettingsRow(icon: "paintbrush", title: "Theme", color: AppColors.secondaryAccent)
                    }
                    
                    Section {
                        SettingsRow(icon: "info.circle", title: "About", color: AppColors.textSecondary)
                        SettingsRow(icon: "lock.shield", title: "Privacy", color: AppColors.textSecondary)
                    }
                    
                    Section {
                        HStack {
                            Spacer()
                            Text("Fish Vault Pro v1.0")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
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
        }
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
        .listRowBackground(AppColors.cardBackground)
    }
}
