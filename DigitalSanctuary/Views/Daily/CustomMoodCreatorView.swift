import SwiftUI
import SwiftData
import UIKit

// MARK: - UIKit emoji keyboard helper

private class _EmojiTextField: UITextField {
    override var textInputContextIdentifier: String? { "" }
    override var textInputMode: UITextInputMode? {
        .activeInputModes.first(where: { $0.primaryLanguage == "emoji" })
    }
}

private struct EmojiKeyboardField: UIViewRepresentable {
    @Binding var emoji: String
    @Binding var isFocused: Bool
    var onPick: () -> Void

    func makeUIView(context: Context) -> _EmojiTextField {
        let tf = _EmojiTextField()
        tf.delegate = context.coordinator
        tf.tintColor = .clear
        tf.backgroundColor = .clear
        tf.textColor = .clear
        return tf
    }

    func updateUIView(_ uiView: _EmojiTextField, context: Context) {
        // Drive focus from SwiftUI state
        DispatchQueue.main.async {
            if isFocused && !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            } else if !isFocused && uiView.isFirstResponder {
                uiView.resignFirstResponder()
            }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: EmojiKeyboardField
        init(parent: EmojiKeyboardField) { self.parent = parent }

        func textField(_ textField: UITextField,
                       shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool {
            guard !string.isEmpty else { return false }
            // Take the first full grapheme cluster — handles multi-scalar emoji correctly
            if let cluster = string.unicodeScalars.first(where: {
                $0.properties.isEmojiPresentation
            }) {
                // Walk forward collecting the full combined sequence (e.g. 👨‍👩‍👧)
                parent.emoji = String(string[string.startIndex...].prefix(1))
            } else {
                parent.emoji = String(string.prefix(1))
            }
            if !parent.emoji.isEmpty { parent.onPick() }
            return false
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.isFocused = false
        }
    }
}

// MARK: - CustomMoodCreatorView

struct CustomMoodCreatorView: View {
    var onSave: ((CustomMood) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var selectedEmoji = ""
    @State private var label = ""
    @State private var isPositive = true
    @State private var isEmojiFieldFocused = false

    private var isValid: Bool {
        !selectedEmoji.isEmpty && !label.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    emojiSection
                    labelSection
                    saveButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 40)
            }
            .background(Color.dsSurface.ignoresSafeArea())
            .navigationTitle("New Mood")
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

    // MARK: - Emoji section

    private var emojiSection: some View {
        VStack(spacing: 12) {
            Text("PICK AN EMOJI")
                .font(.dsCaption)
                .foregroundStyle(Color.dsOnSurfaceVariant)
                .kerning(1.2)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                // Tappable visual area — sets focus, which drives becomeFirstResponder in EmojiKeyboardField
                Button { isEmojiFieldFocused = true } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.dsSurfaceContainerLow)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .strokeBorder(
                                        isEmojiFieldFocused ? Color.dsPrimary.opacity(0.4) : Color.clear,
                                        lineWidth: 1.5
                                    )
                            )

                        if selectedEmoji.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "face.smiling")
                                    .font(.system(size: 32))
                                    .foregroundStyle(Color.dsOnSurfaceVariant)
                                Text("Tap to open emoji keyboard")
                                    .font(.dsCaption)
                                    .foregroundStyle(Color.dsOnSurfaceVariant)
                            }
                        } else {
                            Text(selectedEmoji)
                                .font(.system(size: 60))
                        }
                    }
                    .frame(height: 110)
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.15), value: isEmojiFieldFocused)

                // Hidden text field — becomes first responder when isFocused is true
                EmojiKeyboardField(
                    emoji: $selectedEmoji,
                    isFocused: $isEmojiFieldFocused,
                    onPick: {
                        isPositive = CustomMood.inferIsPositive(for: selectedEmoji)
                        isEmojiFieldFocused = false
                    }
                )
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .allowsHitTesting(false) // taps pass through to the Button above
            }
        }
    }

    // MARK: - Label section

    private var labelSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("WHAT DOES IT MEAN?")
                .font(.dsCaption)
                .foregroundStyle(Color.dsOnSurfaceVariant)
                .kerning(1.2)

            TextField("e.g. Overwhelmed, Hopeful, Peaceful...", text: $label)
                .font(.dsBody)
                .foregroundStyle(Color.dsOnSurface)
                .padding(16)
                .background(Color.dsSurfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Save button

    private var saveButton: some View {
        Button(action: save) {
            Text("Add Mood")
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
        .animation(.easeInOut(duration: 0.2), value: isValid)
    }

    // MARK: - Save

    private func save() {
        guard isValid else { return }
        let custom = CustomMood(
            emoji: selectedEmoji,
            label: label.trimmingCharacters(in: .whitespaces),
            isPositive: isPositive
        )
        modelContext.insert(custom)
        onSave?(custom)
        dismiss()
    }
}
