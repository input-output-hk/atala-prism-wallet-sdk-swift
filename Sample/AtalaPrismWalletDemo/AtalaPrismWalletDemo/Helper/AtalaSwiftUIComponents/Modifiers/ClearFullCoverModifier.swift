import Combine
import SwiftUI

private struct ClearFullCoverModifier<Presenting: View>: ViewModifier {
    let animated: Bool
    @Binding var isPresented: Bool
    @ViewBuilder var presenting: () -> Presenting
    @State var contentDisabled = false

    init(
        animated: Bool,
        isPresented: Binding<Bool>,
        @ViewBuilder presenting: @escaping () -> Presenting
    ) {
        self.animated = animated
        _isPresented = isPresented
        self.presenting = presenting
    }

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                ZStack {
                    presenting()
                        .disablePreference($contentDisabled)
                        .onTapGesture {
                            // Funny "hack" so the dismissal tap on the background view
                            // doesnt affect the presented.
                            // Just having this clean tapGesture works
                        }
                }
                .ignoresSafeArea(.container)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    BackgroundClearView(isPresented: $isPresented, isDisabled: contentDisabled)
                )
            }
    }
}

extension View {
    func clearFullScreenCover<Content: View>(
        isPresented: Binding<Bool>,
        animated: Bool = true,
        @ViewBuilder presenting: @escaping () -> Content
    ) -> some View {
        modifier(ClearFullCoverModifier(
            animated: animated,
            isPresented: isPresented,
            presenting: presenting
        ))
    }
}

private struct BackgroundClearView: UIViewRepresentable {
    let isPresented: Binding<Bool>
    let isDisabled: Bool

    @Environment(\.isEnabled) var isEnabled

    class ViewCoordinator {
        let view: BackgroundClearUIView
        init(view: BackgroundClearUIView) {
            self.view = view
        }
    }

    func makeCoordinator() -> ViewCoordinator {
        ViewCoordinator(view: BackgroundClearUIView(action: {
            self.isPresented.wrappedValue = false
        }))
    }

    func makeUIView(context: Context) -> BackgroundClearUIView {
        return context.coordinator.view
    }

    func updateUIView(_ uiView: BackgroundClearUIView, context: Context) {
        uiView.gesture?.isEnabled = !isDisabled
    }
}

private class BackgroundClearUIView: UIView {
    let action: () -> Void
    var gesture: UITapGestureRecognizer?
    var animating = false
    var cancellables = Set<AnyCancellable>()
    var didAppear = false

    init(action: @escaping () -> Void) {
        self.action = action
        super.init(frame: .zero)
        gesture = UITapGestureRecognizer(target: self, action: #selector(didTouchBackground(_:)))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        superview?.superview?.backgroundColor = .clear
        if !UIView.areAnimationsEnabled {
            superview?
                .superview?
                .superview?
                .backgroundColor = .init(red: 0, green: 0, blue: 0, alpha: 0.6)
        }

        superview?.superview?.layer.publisher(for: \.position)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard
                    let self = self,
                    let animation = self.superview?.superview?.layer.animation(forKey: "position")
                else { return }

                if let gesture = self.gesture, gesture.view == nil {
                    self.superview?.superview?.superview?.addGestureRecognizer(gesture)
                    self.superview?.superview?.superview?.isUserInteractionEnabled = true
                }

                UIView.animate(withDuration: animation.duration) { [weak self] in
                    guard let self = self else { return }
                    self.animating = true
                    if self.didAppear {
                        self.superview?
                            .superview?
                            .superview?
                            .backgroundColor = .init(red: 0, green: 0, blue: 0, alpha: 0.0)
                    } else {
                        self.superview?
                            .superview?
                            .superview?
                            .backgroundColor = .init(red: 0, green: 0, blue: 0, alpha: 0.6)
                    }
                } completion: { [weak self] _ in
                    self?.didAppear = true
                    self?.animating = false
                }
            })
            .store(in: &cancellables)
    }

    @objc func didTouchBackground(_ sender: Any?) {
        action()
    }
}
