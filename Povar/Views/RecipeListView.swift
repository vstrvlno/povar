import SwiftUI

struct RecipeListView: View {
    @Environment(PantryStore.self) private var pantry
    @State private var search = ""
    @State private var category: RecipeCategory?

    private var filtered: [Recipe] {
        RecipeBook.all.filter { recipe in
            let categoryOK = category == nil || recipe.category == category
            let searchOK = search.isEmpty
                || recipe.name.localizedCaseInsensitiveContains(search)
                || recipe.ingredients.contains { IngredientCatalog.name(for: $0.id).localizedCaseInsensitiveContains(search) }
            return categoryOK && searchOK
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(title: "Все", selected: category == nil) { category = nil }
                        ForEach(RecipeCategory.allCases) { item in
                            CategoryChip(title: item.title, selected: category == item) { category = item }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                ForEach(filtered) { recipe in
                    NavigationLink(value: recipe) {
                        RecipeRow(recipe: recipe)
                    }
                }

                if filtered.isEmpty {
                    Text("Ничего не найдено")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Рецепты")
            .searchable(text: $search, prompt: "Блюдо или продукт")
            .navigationDestination(for: Recipe.self) { RecipeDetailView(recipe: $0) }
        }
    }
}

struct RecipeRow: View {
    let recipe: Recipe
    @Environment(PantryStore.self) private var pantry

    var body: some View {
        let keys = recipe.keyIngredients
        let haveCount = keys.filter { pantry.has($0.id) }.count

        HStack(spacing: 14) {
            Text(recipe.emoji)
                .font(.system(size: 34))
                .frame(width: 54, height: 54)
                .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name).font(.headline)
                HStack(spacing: 10) {
                    Label(formatMinutes(recipe.totalMinutes), systemImage: "clock")
                    Label("\(recipe.baseServings)", systemImage: "person.2")
                    Text(recipe.difficulty.rawValue)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                if !pantry.items.isEmpty {
                    Text("Есть \(haveCount) из \(keys.count) продуктов")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(haveCount == keys.count ? .green : .orange)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
