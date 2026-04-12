import TipKit

extension View {
    @ViewBuilder
    func compatPopoverTip<TipContent: Tip>(
        _ tip: TipContent?,
        arrowEdge: Edge = .top
    ) -> some View {
        if #available(iOS 26.0, *) {
            popoverTip(tip, arrowEdge: arrowEdge)
        } else {
            if let tip {
                popoverTip(tip, arrowEdge: arrowEdge)
            } else {
                self
            }
        }
    }
}
