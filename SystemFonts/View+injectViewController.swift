//
//  SystemFonts
//
//  Created by Jérôme Alves on 23/05/2022.
//

import SwiftUI
import RxSwift
import RxRelay

extension View {
    func injectViewController(_ handler: @escaping (UIViewController) -> Void) -> some View {
        background(
            InjectedViewControllerRepresentable(handler).opacity(0)
        )
    }
}

private struct InjectedViewControllerRepresentable: UIViewControllerRepresentable {
    let handler: (UIViewController) -> Void

    init(_ handler: @escaping (UIViewController) -> Void) {
        self.handler = handler
    }

    func makeUIViewController(context: Context) -> InjectedViewController {
        InjectedViewController(handler: handler)
    }

    func updateUIViewController(_ viewController: InjectedViewController, context: Context) {
        viewController.handler = handler
    }
}

private final class InjectedViewController: UIViewController {
    
    init(handler: @escaping (UIViewController) -> Void) {
        self.handler = handler
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var handler: (UIViewController) -> Void {
        didSet { performHandlerIfNeeded() }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performHandlerIfNeeded()
    }

    private func performHandlerIfNeeded() {
        guard isViewLoaded else { return }
        handler(self)
    }
}
