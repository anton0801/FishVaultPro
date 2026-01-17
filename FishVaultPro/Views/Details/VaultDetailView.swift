import SwiftUI

struct VaultDetailView: View {
    @StateObject private var viewModel: VaultDetailViewModel
    @State private var showingAddEntry = false
    
    @State var showingStatistics = false
    @State var showingAddMilestone = false
    
    init(vault: Vault) {
        _viewModel = StateObject(wrappedValue: VaultDetailViewModel(vault: vault))
    }
    
    var body: some View {
        ZStack {
            AppColors.deepOcean.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Progress overview
                    ProgressOverviewView(vault: viewModel.vault)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    
                    // Entries section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Entries")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Spacer()
                            
                            Button(action: { showingAddEntry = true }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.secondaryAccent)
                            }
                        }
                        
                        if viewModel.vault.entries.isEmpty {
                            EmptyEntriesView()
                        } else {
                            ForEach(viewModel.vault.entries.sorted(by: { $0.date > $1.date })) { entry in
                                EntryRowView(
                                    entry: entry,
                                    vaultType: viewModel.vault.type,
                                    onToggle: { viewModel.toggleEntryCompletion(entry) },
                                    onDelete: { viewModel.deleteEntry(entry) }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle(viewModel.vault.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddEntry) {
            AddEntryView(vault: viewModel.vault, viewModel: viewModel)
        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: { showingStatistics = true }) {
//                    Image(systemName: "chart.bar.fill")
//                        .foregroundColor(AppColors.primaryAccent)
//                }
//            }
//        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingStatistics = true }) {
                        Label("Statistics", systemImage: "chart.bar.fill")
                    }
                    
                    Button(action: { showingAddMilestone = true }) {
                        Label("Add Milestone", systemImage: "flag.fill")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(AppColors.primaryAccent)
                }
            }
        }
        .sheet(isPresented: $showingStatistics) {
            NavigationView {
                StatisticsView(vault: viewModel.vault)
            }
        }
        .sheet(isPresented: $viewModel.showCelebration) {
            if let milestone = viewModel.celebrationMilestone {
                CelebrationView(
                    milestone: milestone,
                    newFish: viewModel.celebrationFish,
                    isPresented: $viewModel.showCelebration
                )
            }
        }
        .sheet(isPresented: $showingAddMilestone) {
            AddMilestoneView(viewModel: viewModel)
        }
    }
}

struct EntryRowView: View {
    let entry: VaultEntry
    let vaultType: VaultType
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            if vaultType == .checklist {
                Button(action: onToggle) {
                    Image(systemName: entry.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(entry.isCompleted ? AppColors.secondaryAccent : AppColors.textSecondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if vaultType != .checklist {
                    Text("\(Int(entry.value))")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                if let note = entry.note, !note.isEmpty {
                    Text(note)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Text(entry.date, style: .date)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct EmptyEntriesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(AppColors.textSecondary.opacity(0.5))
            
            Text("No entries yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
