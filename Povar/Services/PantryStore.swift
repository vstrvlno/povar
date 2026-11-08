import Foundation
import Observation

/// Продукты, которые есть у пользователя. Сохраняются между запусками.
@Observable
final class PantryStore {
    private(set) var items: Set<String> = []

    private let storageKey = "pantry.items"

    init() {
        if let saved = UserDefaults.standard.stringArray(forKey: storageKey) {
            items = Set(saved)
        }
    }

    /// Есть ли продукт (базовые — соль, вода и т.п. — считаются имеющимися всегда)
    func has(_ id: String) -> Bool {
        items.contains(id) || (IngredientCatalog.byId[id]?.isStaple ?? false)
    }

    func toggle(_ id: String) {
        if items.contains(id) { items.remove(id) } else { items.insert(id) }
        save()
    }

    func add<S: Sequence>(_ ids: S) where S.Element == String {
        items.formUnion(ids)
        save()
    }

    func remove(_ id: String) {
        items.remove(id)
        save()
    }

    func clear() {
        items.removeAll()
        save()
    }

    private func save() {
        UserDefaults.standard.set(Array(items), forKey: storageKey)
    }
}
