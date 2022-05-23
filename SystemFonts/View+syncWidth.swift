//
//  SystemFonts
//
//  Created by Jérôme Alves on 23/05/2022.
//

import Foundation
import SwiftUI

extension View {
    func syncWidth(key: String) -> some View {
        modifier(SyncWidthsViewModifier(key: key))
    }
}

private struct SyncWidthsViewModifier: ViewModifier {
    let key: String
    var alignment: SwiftUI.Alignment = .leading

    @EnvironmentObject var widthsStore: WidthsStore

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: GeometryWidthKey.self,
                            value: geometry.size.width
                        )
                        .onPreferenceChange(GeometryWidthKey.self) { width in
                            guard let width = width else { return }
                            widthsStore.registerWidth(width, for: key)
                        }
                }
            )
            .frame(minWidth: widthsStore.width(for: key), alignment: alignment)
    }
}

final class WidthsStore: ObservableObject {
    @Published private var store: [String: CGFloat] = [:]

    func width(for property: String) -> CGFloat? {
        store[property]
    }

    func registerWidth(_ width: CGFloat, for property: String) {
        let width = (width / 10).rounded(.up) * 10
        guard let currentWidth = store[property] else {
            store[property] = width
            return
        }
        if width > currentWidth {
            store[property] = width
        }
    }
}

private struct GeometryWidthKey: PreferenceKey {
    static var defaultValue: CGFloat? { nil }
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = nextValue()
    }
}
