//
//  SystemFonts
//
//  Created by Jérôme Alves on 23/05/2022.
//

import SwiftUI
import UIKit

extension View {
    func syncContentOffset() -> some View {
        modifier(SyncContentOffsetViewModifier())
    }
}

struct SyncContentOffsetViewModifier: ViewModifier {
    @EnvironmentObject var contentOffsetSynchronizer: ContentOffsetSynchronizer

    func body(content: Content) -> some View {
        content.injectViewController { viewController in
            // If we find an UIScrollView ancestor...
            guard let scrollView = viewController.viewIfLoaded?.ascendant(ofType: UIScrollView.self) else {
                return
            }
            // ...we register it for sync
            contentOffsetSynchronizer.register(scrollView)
        }
    }
}

final class ContentOffsetSynchronizer : ObservableObject {
    private var observations: [NSKeyValueObservation] = []
    private let registrations = NSHashTable<UIScrollView>.weakObjects()

    private var contentOffset: CGPoint = .zero {
        didSet {
            // Sync all scrollviews with to the new content offset
            for scrollView in registrations.allObjects where scrollView.isInteracting == false {
                scrollView.contentOffset = contentOffset
            }
        }
    }

    func register(_ scrollView: UIScrollView) {
        scrollView.clipsToBounds = false

        guard registrations.contains(scrollView) == false else {
            return
        }

        registrations.add(scrollView)

        // When a user is interacting with the scrollView, we store its contentOffset
        observations.append(
            scrollView.observe(\.contentOffset, options: [.initial, .new]) { [weak self] scrollView, change in
                guard let newValue = change.newValue, scrollView.isInteracting else {
                    return
                }
                self?.contentOffset = newValue
            }
        )
        
        // If a contentSize changes, we need to re-sync it with the current contentOffset
        observations.append(
            scrollView.observe(\.contentSize, options: [.initial, .new]) { [weak self] scrollView, change in
                guard let contentOffset = self?.contentOffset else {
                    return
                }
                scrollView.contentOffset = contentOffset
            }
        )
    }
    
    deinit {
        observations.forEach { $0.invalidate() }
    }
}

extension UIView {
    fileprivate func ascendant<T: UIView>(ofType type: T.Type = T.self) -> T? {
        superview as? T ?? superview?.ascendant(ofType: type)
    }
}

extension UIScrollView {
    fileprivate var isInteracting: Bool {
        isDragging || isDecelerating
    }
}
