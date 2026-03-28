import SwiftUI
import SwiftData

struct AddMessageView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var text = ""
    @State private var author = ""

    private let maxChars = 200
    private var isValid: Bool {
        !text.trimmingCharacters(in: .whitespaces).isEmpty &&
        !author.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("YOUR MESSAGE")
                            .font(.dsCaption)
                            .foregroundStyle(Color.dsOnSurfaceVariant)
                            .kerning(1.2)

                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $text)
                                .font(.dsBody)
                                .foregroundStyle(Color.dsOnSurface)
                                .frame(minHeight: 120, maxHeight: 180)
                                .padding(12)
                                .scrollContentBackground(.hidden)
                                .background(Color.dsSurfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .onChange(of: text) { _, v in
                                    if v.count > maxChars { text = String(v.prefix(maxChars)) }
                                }

                            if text.isEmpty {
                                Text("Share a gentle word for someone who needs it today…")
                                    .font(.dsBody)
                                    .foregroundStyle(Color.dsOnSurfaceVariant)
                                    .padding(.top, 20)
                                    .padding(.leading, 16)
                                    .allowsHitTesting(false)
                            }
                        }

                        HStack {
                            Spacer()
                            Text("\(text.count)/\(maxChars)")
                                .font(.dsCaption)
                                .foregroundStyle(text.count >= maxChars
                                                 ? Color.red.opacity(0.6)
                                                 : Color.dsOnSurfaceVariant)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("SIGN AS")
                            .font(.dsCaption)
                            .foregroundStyle(Color.dsOnSurfaceVariant)
                            .kerning(1.2)

                        TextField("e.g. Anonymous Soul, A Traveler…", text: $author)
                            .font(.dsBody)
                            .foregroundStyle(Color.dsOnSurface)
                            .padding(14)
                            .background(Color.dsSurfaceContainerLow)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button(action: save) {
                        Text("Share with the Sanctuary")
                            .font(.dsSubtitle)
                            .foregroundStyle(isValid ? .white : Color.dsOnSurfaceVariant)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                isValid
                                    ? AnyShapeStyle(LinearGradient.dsPrimaryGradient)
                                    : AnyShapeStyle(Color.dsSurfaceContainerHigh)
                            )
                            .clipShape(Capsule())
                    }
                    .disabled(!isValid)
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.2), value: isValid)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
            .background(Color.dsSurface.ignoresSafeArea())
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.dsLabel)
                        .foregroundStyle(Color.dsOnSurfaceVariant)
                }
            }
        }
    }

    private func save() {
        guard isValid else { return }
        let msg = CommunityMessage(
            text: text.trimmingCharacters(in: .whitespaces),
            author: author.trimmingCharacters(in: .whitespaces),
            isUserCreated: true
        )
        modelContext.insert(msg)
        dismiss()
    }
}
