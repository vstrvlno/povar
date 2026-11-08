import SwiftUI

struct ContentView: View {
    @Environment(TimerManager.self) private var timers
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            RecipeListView()
                .tabItem { Label("Рецепты", systemImage: "book") }
                .tag(0)
            PantryView()
                .tabItem { Label("Продукты", systemImage: "refrigerator") }
                .tag(1)
            SuggestionsView(openPantry: { tab = 1 })
                .tabItem { Label("Что приготовить", systemImage: "lightbulb") }
                .tag(2)
            TimersView()
                .tabItem { Label("Таймеры", systemImage: "timer") }
                .badge(timers.activeCount)
                .tag(3)
        }
        .alert("⏰ Таймер готов!",
               isPresented: Binding(get: { timers.lastFinished != nil },
                                    set: { if !$0 { timers.lastFinished = nil } }),
               presenting: timers.lastFinished) { finished in
            Button("+1 минута") { timers.addMinute(finished.id) }
            Button("OK", role: .cancel) {}
        } message: { finished in
            Text(finished.title)
        }
    }
}
