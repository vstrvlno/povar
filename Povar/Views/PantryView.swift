import SwiftUI
import PhotosUI

struct ScanImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

/// «Холодильник»: что есть дома. Можно отметить вручную или по фото.
struct PantryView: View {
    @Environment(PantryStore.self) private var pantry
    @State private var search = ""
    @State private var showCamera = false
    @State private var cameraImage: UIImage?
    @State private var photoItem: PhotosPickerItem?
    @State private var scan: ScanImage?
    @State private var showSettings = false

    private func ingredients(in category: IngredientCategory) -> [IngredientInfo] {
        IngredientCatalog.all.filter {
            $0.category == category && !$0.isStaple
                && (search.isEmpty || $0.name.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        Button { showCamera = true } label: {
                            ScanButtonLabel(title: "Сфотографировать", icon: "camera.fill")
                        }
                        .buttonStyle(.plain)

                        PhotosPicker(selection: $photoItem, matching: .images) {
                            ScanButtonLabel(title: "Из галереи", icon: "photo.on.rectangle")
                        }
                        .buttonStyle(.plain)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                } footer: {
                    Text("Сфотографируйте открытый холодильник или продукты на столе — приложение определит, что у вас есть.")
                }

                if !pantry.items.isEmpty && search.isEmpty {
                    Section("У меня есть · \(pantry.items.count)") {
                        Text(pantry.items.sorted().map { id in
                            "\(IngredientCatalog.byId[id]?.emoji ?? "") \(IngredientCatalog.name(for: id))"
                        }.joined(separator: ",  "))
                        .font(.subheadline)
                    }
                }

                ForEach(IngredientCategory.allCases.filter { $0 != .basics }) { category in
                    let list = ingredients(in: category)
                    if !list.isEmpty {
                        Section(category.title) {
                            ForEach(list) { info in
                                Button {
                                    pantry.toggle(info.id)
                                } label: {
                                    HStack(spacing: 12) {
                                        Text(info.emoji)
                                        Text(info.name).foregroundStyle(Color.primary)
                                        Spacer()
                                        Image(systemName: pantry.items.contains(info.id) ? "checkmark.circle.fill" : "circle")
                                            .foregroundStyle(pantry.items.contains(info.id) ? Color.green : Color.secondary.opacity(0.4))
                                            .font(.title3)
                                    }
                                }
                            }
                        }
                    }
                }

                if search.isEmpty {
                    Section {
                        Text(IngredientCatalog.staples.map { "\($0.emoji) \($0.name)" }.joined(separator: ",  "))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } header: {
                        Text(IngredientCategory.basics.title)
                    }
                }
            }
            .navigationTitle("Мои продукты")
            .searchable(text: $search, prompt: "Найти продукт")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: { Image(systemName: "gearshape") }
                        .accessibilityLabel("Настройки")
                }
                if !pantry.items.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Очистить", role: .destructive) { pantry.clear() }
                    }
                }
            }
            .fullScreenCover(isPresented: $showCamera, onDismiss: {
                if let image = cameraImage {
                    scan = ScanImage(image: image)
                    cameraImage = nil
                }
            }) {
                CameraPicker { cameraImage = $0 }
                    .ignoresSafeArea()
            }
            .sheet(item: $scan) { item in
                ScanResultView(image: item.image)
                    .environment(pantry)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView().environment(pantry)
            }
            .onChange(of: photoItem) { _, item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        scan = ScanImage(image: image)
                    }
                    photoItem = nil
                }
            }
        }
    }
}

private struct ScanButtonLabel: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title)
            Text(title).font(.subheadline.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .foregroundStyle(.white)
        .background(
            LinearGradient(colors: [.orange, .red.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 16)
        )
    }
}

/// Обёртка над системной камерой
struct CameraPicker: UIViewControllerRepresentable {
    var onPick: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onPick(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
