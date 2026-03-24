import SwiftUI
import PhotosUI

struct PhotoGridView: View {
    @Binding var photoData: [Data]
    let maxPhotos: Int
    let maxBytes: Int

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showSizeAlert = false
    @State private var isLoading = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Photos")
                    .font(.dsSubtitle)
                    .foregroundStyle(Color.dsOnSurface)
                Spacer()
                Text("\(photoData.count)/\(maxPhotos)")
                    .font(.dsCaption)
                    .foregroundStyle(Color.dsOnSurfaceVariant)
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(photoData.enumerated()), id: \.offset) { index, data in
                    if let image = UIImage(data: data) {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .frame(height: 140)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 16))

                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    photoData.remove(at: index)
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 2)
                                    .padding(6)
                            }
                        }
                    }
                }

                if photoData.count < maxPhotos {
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: maxPhotos - photoData.count,
                        matching: .images
                    ) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.dsSurfaceContainerLow)
                                .frame(height: 140)

                            if isLoading {
                                ProgressView()
                                    .tint(Color.dsPrimary)
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 26, weight: .medium))
                                        .foregroundStyle(Color.dsPrimary)
                                    Text("Add Photo")
                                        .font(.dsLabel)
                                        .foregroundStyle(Color.dsOnSurfaceVariant)
                                }
                            }
                        }
                    }
                    .onChange(of: selectedItems) { _, newItems in
                        Task { await loadPhotos(from: newItems) }
                    }
                }
            }
        }
        .alert("Photos Too Large", isPresented: $showSizeAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Total photo size cannot exceed \(maxBytes / (1024 * 1024)) MB. Try choosing smaller photos.")
        }
    }

    private func loadPhotos(from items: [PhotosPickerItem]) async {
        await MainActor.run { isLoading = true }
        defer { Task { await MainActor.run { isLoading = false } } }

        for item in items {
            guard photoData.count < maxPhotos else { break }

            if let raw = try? await item.loadTransferable(type: Data.self),
               let compressed = UIImage(data: raw)?.jpegData(compressionQuality: 0.75) {
                let currentTotal = photoData.reduce(0) { $0 + $1.count }
                if currentTotal + compressed.count <= maxBytes {
                    await MainActor.run { photoData.append(compressed) }
                } else {
                    await MainActor.run { showSizeAlert = true }
                    break
                }
            }
        }

        await MainActor.run { selectedItems = [] }
    }
}
