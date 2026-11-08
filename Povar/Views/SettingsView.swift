import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PantryStore.self) private var pantry
    @AppStorage("recognitionMode") private var modeRaw = RecognitionMode.onDevice.rawValue
    @AppStorage("claudeModel") private var model = IngredientRecognizer.defaultClaudeModel
    @State private var apiKey = Keychain.get(IngredientRecognizer.claudeKeychainKey)

    private var mode: RecognitionMode { RecognitionMode(rawValue: modeRaw) ?? .onDevice }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Распознавание фото", selection: $modeRaw) {
                        ForEach(RecognitionMode.allCases) { item in
                            Text(item.title).tag(item.rawValue)
                        }
                    }
                } footer: {
                    Text(mode.details)
                }

                if mode == .claude {
                    Section {
                        SecureField("API‑ключ (sk-ant-…)", text: $apiKey)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        TextField("Модель", text: $model)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    } header: {
                        Text("Claude API")
                    } footer: {
                        Text("Ключ хранится в Связке ключей iOS и отправляется только на api.anthropic.com. Получить ключ: console.anthropic.com.")
                    }
                }

                Section("Данные") {
                    Button("Очистить список продуктов", role: .destructive) { pantry.clear() }
                }

                Section("О приложении") {
                    LabeledContent("Рецептов", value: "\(RecipeBook.all.count)")
                    LabeledContent("Продуктов в справочнике", value: "\(IngredientCatalog.all.count)")
                    LabeledContent("Версия", value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
            .onChange(of: apiKey) { _, newValue in
                Keychain.set(newValue.trimmingCharacters(in: .whitespacesAndNewlines),
                             for: IngredientRecognizer.claudeKeychainKey)
            }
        }
    }
}
