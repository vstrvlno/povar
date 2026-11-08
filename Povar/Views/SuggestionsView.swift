import SwiftUI

/// Что можно приготовить из имеющихся продуктов + советы
struct SuggestionsView: View {
    var openPantry: () -> Void = {}
    @Environment(PantryStore.self) private var pantry

    var body: some View {
        NavigationStack {
            Group {
                if pantry.items.isEmpty {
                    ContentUnavailableView {
                        Label("Добавьте продукты", systemImage: "refrigerator")
                    } description: {
                        Text("Отметьте, что есть дома, или сфотографируйте холодильник — и я подскажу, что приготовить.")
                    } actions: {
                        Button("Перейти к продуктам", action: openPantry)
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    let all = SuggestionEngine.matches(pantry: pantry)
                    let ready = all.filter { $0.missing.isEmpty }
                    let almost = all.filter { (1...2).contains($0.missing.count) }
                    let rest = all.filter { $0.missing.count > 2 && !$0.have.isEmpty }

                    List {
                        Section {
                            AdviceCard(lines: SuggestionEngine.advice(for: all, pantry: pantry))
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
                        if !ready.isEmpty {
                            Section("✅ Можно приготовить прямо сейчас") {
                                ForEach(ready) { MatchRow(match: $0) }
                            }
                        }
                        if !almost.isEmpty {
                            Section("🛒 Не хватает 1–2 продуктов") {
                                ForEach(almost) { MatchRow(match: $0) }
                            }
                        }
                        if !rest.isEmpty {
                            Section("Нужно докупить больше") {
                                ForEach(rest) { MatchRow(match: $0) }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Что приготовить")
            .navigationDestination(for: Recipe.self) { RecipeDetailView(recipe: $0) }
        }
    }
}

private struct AdviceCard: View {
    let lines: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Совет повара", systemImage: "sparkles")
                .font(.headline)
            ForEach(lines, id: \.self) { line in
                Text(line).font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(colors: [Color.orange.opacity(0.25), Color.yellow.opacity(0.15)],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 16)
        )
    }
}

private struct MatchRow: View {
    let match: RecipeMatch

    var body: some View {
        NavigationLink(value: match.recipe) {
            HStack(alignment: .top, spacing: 12) {
                Text(match.recipe.emoji).font(.system(size: 32))
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(match.recipe.name).font(.headline)
                        Spacer()
                        Text(formatMinutes(match.recipe.totalMinutes))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: match.ratio)
                        .tint(match.missing.isEmpty ? .green : .orange)
                    if match.missing.isEmpty {
                        Text("Все продукты есть").font(.caption).foregroundStyle(.green)
                    } else {
                        Text("Не хватает: " + match.missing.map { IngredientCatalog.name(for: $0).lowercased() }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundStyle(.orange)
                        ForEach(match.missing.filter { SuggestionEngine.substitutes[$0] != nil }, id: \.self) { id in
                            Text("💡 \(IngredientCatalog.name(for: id)): \(SuggestionEngine.substitutes[id] ?? "")")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}
