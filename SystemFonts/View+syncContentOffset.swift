//
//  SystemFonts
//
//  Created by Jérôme Alves on 23/05/2022.
//

import SwiftUI
import UIKit
import RxSwift
import RxCocoa

extension View {
    func syncContentOffset() -> some View {
        modifier(SyncContentOffsetViewModifier())
    }
}

struct SyncContentOffsetViewModifier: ViewModifier {
    @EnvironmentObject var contentOffsetSynchronizer: ContentOffsetSynchronizer

    func body(content: Content) -> some View {
        content.injectViewController { viewController in
            guard let scrollView = viewController.viewIfLoaded?.ascendant(ofType: UIScrollView.self) else {
                return
            }
            contentOffsetSynchronizer.register(scrollView)
        }
    }
}

final class ContentOffsetSynchronizer : ObservableObject {
    private let disposeBag = DisposeBag()
    private let contentOffset = BehaviorSubject<CGPoint>(value: .zero)
    private let registrations = NSHashTable<UIScrollView>.weakObjects()

    func register(_ scrollView: UIScrollView) {
        scrollView.clipsToBounds = false

        guard registrations.contains(scrollView) == false else {
            return
        }

        registrations.add(scrollView)

        // Share the scrollView.contentOffset if it changed because of user dragging it
        scrollView.rx.contentOffset
            .filter { [weak scrollView] _ in scrollView?.isDragging == true || scrollView?.isDecelerating == true }
            .bind(to: contentOffset)
            .disposed(by: disposeBag)

        // When the shared contentOffset changed (or the scrollView.contentSize changed), update the scrollView.contentOffset
        Observable.combineLatest(
            contentOffset.distinctUntilChanged(==),
            scrollView.rx.observe(\.contentSize).startWith(scrollView.contentSize),
            resultSelector: { contentOffset, _ in contentOffset }
        )
        .filter { [weak scrollView] in $0 != scrollView?.contentOffset }
        .bind(to: scrollView.rx.contentOffset)
        .disposed(by: disposeBag)
    }
    
    deinit {
        contentOffset.onCompleted()
    }
}

extension UIView {
    fileprivate func ascendant<T: UIView>(ofType type: T.Type = T.self) -> T? {
        superview as? T ?? superview?.ascendant(ofType: type)
    }
}
