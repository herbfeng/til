import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TILPost.createdAt, order: .reverse) private var posts: [TILPost]
    
    @State private var isAddingNew = false
    @State private var newContent = ""
    @State private var searchText = "" // New: Search support
    @FocusState private var isInputFocused: Bool

    // Filtered posts based on search text
    var filteredPosts: [TILPost] {
        if searchText.isEmpty {
            return posts
        } else {
            return posts.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                List {
                    if filteredPosts.isEmpty && !searchText.isEmpty {
                        Text("No results for \"\(searchText)\"")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                            .listRowBackground(Color.clear)
                    } else if filteredPosts.isEmpty {
                        emptyStateView.listRowBackground(Color.clear).listRowSeparator(.hidden)
                    } else {
                        ForEach(filteredPosts) { post in
                            TILCard(post: post)
                                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) { deletePost(post) } label: { Label("Delete", systemImage: "trash") }
                                }
                        }
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search insights")
                .blur(radius: isAddingNew ? 20 : 0)
                .scaleEffect(isAddingNew ? 0.96 : 1.0)

                // MARK: - Right-Handed FAB
                VStack {
                    Spacer()
                    HStack {
                        Spacer() // Pushes the button to the right
                        if !isAddingNew {
                            Button(action: {
                                triggerHaptic()
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    isAddingNew = true
                                    isInputFocused = true
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                    .frame(width: 64, height: 64)
                                    .background(Circle().fill(Color.blue))
                                    .shadow(color: .blue.opacity(0.3), radius: 12, y: 6)
                            }
                            .padding(.trailing, 25) // Right side padding
                            .padding(.bottom, 30)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                }

                if isAddingNew { inputOverlay }
            }
            .navigationTitle("Today I Learned")
        }
    }

    // MARK: - Subviews & Logic
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "lightbulb.fill").font(.largeTitle).foregroundColor(.blue.opacity(0.2))
            Text("No Insights").foregroundColor(.secondary)
        }.frame(maxWidth: .infinity).padding(.top, 100)
    }

    private var inputOverlay: some View {
        ZStack {
            Color.black.opacity(0.2).ignoresSafeArea().onTapGesture { dismissInput() }
            VStack(spacing: 20) {
                HStack {
                    Text("New Insight").font(.title3.bold())
                    Spacer()
                    Button("Post") { saveEntry() }
                        .buttonStyle(.borderedProminent).clipShape(Capsule())
                }
                TextEditor(text: $newContent)
                    .focused($isInputFocused)
                    .frame(minHeight: 150)
                    .scrollContentBackground(.hidden)
                    .padding()
                    .background(Color(uiColor: .tertiarySystemFill)).cornerRadius(16)
            }
            .padding(24).background(.ultraThinMaterial).cornerRadius(32).padding(.horizontal, 20)
        }
    }

    private func saveEntry() {
        let contentToSave = newContent
        dismissInput()
        Task {
            let post = TILPost(content: contentToSave)
            modelContext.insert(post)
            try? modelContext.save()
        }
    }

    private func deletePost(_ post: TILPost) { withAnimation { modelContext.delete(post) } }
    private func dismissInput() { withAnimation { isAddingNew = false; newContent = ""; isInputFocused = false } }
    private func triggerHaptic() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
}

// MARK: - Components
struct TILCard: View {
    let post: TILPost
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()
                Text(post.createdAt, style: .time).font(.system(size: 10, weight: .bold)).foregroundColor(.secondary.opacity(0.6))
            }
            Text(post.content).font(.system(size: post.content.count < 60 ? 26 : 17, weight: post.content.count < 60 ? .bold : .regular, design: .rounded))
            HStack {
                Text(post.createdAt.formatted(.dateTime.day().month())).font(.system(size: 10))
                Spacer()
                Menu { ShareLink(item: post.content) } label: { Image(systemName: "ellipsis").padding(8) }
            }
            .foregroundColor(.secondary.opacity(0.6))
        }
        .padding(24).background(RoundedRectangle(cornerRadius: 28).fill(Color(uiColor: .secondarySystemGroupedBackground)))
    }
}
