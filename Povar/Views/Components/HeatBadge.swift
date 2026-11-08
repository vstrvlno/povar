import SwiftUI

/// Индикатор силы огня: 🔥🔥🔥 + подпись
struct HeatBadge: View {
    let heat: HeatLevel
    var temperature: Int? = nil
    var large = false

    var body: some View {
        HStack(spacing: 2) {
            if heat == .oven {
                Image(systemName: "thermometer.medium")
                    .foregroundStyle(heat.color)
            } else {
                ForEach(0..<4, id: \.self) { index in
                    Image(systemName: "flame.fill")
                        .foregroundStyle(index < heat.flames ? heat.color : Color.secondary.opacity(0.25))
                }
            }
            Text(label)
                .fontWeight(.semibold)
                .padding(.leading, 4)
        }
        .font(large ? .headline : .caption)
        .padding(.horizontal, large ? 14 : 8)
        .padding(.vertical, large ? 8 : 4)
        .background(heat.color.opacity(0.14), in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
    }

    private var label: String {
        if heat == .oven, let temperature { return "Духовка \(temperature) °C" }
        return heat.title
    }
}

struct CategoryChip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(selected ? Color.orange : Color(.secondarySystemBackground), in: Capsule())
                .foregroundStyle(selected ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
    }
}
