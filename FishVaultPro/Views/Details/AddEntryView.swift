// Views/Detail/AddEntryView.swift
import SwiftUI

struct AddEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    let vault: Vault
    @ObservedObject var viewModel: VaultDetailViewModel
    
    @State private var value: String = ""
    @State private var note: String = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.deepOcean.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if vault.type != .checklist {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Value")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                TextField("Enter value", text: $value)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .accentColor(AppColors.primaryAccent)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Note (Optional)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            TextEditor(text: $note)
                                .frame(height: 100)
                                .padding(12)
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        Spacer(minLength: 40)
                        
                        Button(action: saveEntry) {
                            Text("Save Entry")
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
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Add Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
    
    private func saveEntry() {
        let entry = VaultEntry(
            value: Double(value) ?? 0,
            date: date,
            note: note.isEmpty ? nil : note,
            isCompleted: vault.type == .checklist
        )
        
        viewModel.addEntry(entry)
        presentationMode.wrappedValue.dismiss()
    }
}
