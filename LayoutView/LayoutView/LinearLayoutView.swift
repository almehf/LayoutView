//
//  LinearLayoutView.swift
//
//  Created by Fahad Almehawas on 2019/1/18.
//  Copyright © 2019 Fahad Almehawas. All rights reserved.
//

import UIKit

class LinearLayoutView: UIView {

    private(set) var direction: LayoutDirection = .horizontal

    private override init(frame: CGRect) {
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(direction: LayoutDirection = .horizontal, contentGravity: LayoutGravity = .none, width: LayoutSize = .fill, height: LayoutSize = .fill) {
        super.init(frame: .zero)
        self.direction = direction
        self.lv.contentGravity = contentGravity
        self.lv.width = width
        self.lv.height = height
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setChildViewSize()
        setLayoutViewFrame()
        setChildViewOrigin()
    }
}

extension LinearLayoutView {

    private func setChildViewSize() {
        let parentSize = CGSize(width: getViewWidth(self), height: getViewHeight(self))
        let totalWeight = subviews.reduce(CGFloat(0)) { (value, view) in
            view.frame = .zero
            return value + view.lv.weight
        }
        let surplusSize = subviews.reduce(CGSize.zero) { (value, view) in
            if view.lv.weight > 0 {
                return CGSize(width: value.width + (view.lv.margin * 2 + view.lv.marginLeft + view.lv.marginRight),
                    height: value.height + (view.lv.margin * 2 + view.lv.marginTop + view.lv.marginBottom))
            } else {
                return CGSize(width: value.width + getViewWidth(view) + (view.lv.margin * 2 + view.lv.marginLeft + view.lv.marginRight),
                    height: value.height + getViewHeight(view) + (view.lv.margin * 2 + view.lv.marginTop + view.lv.marginBottom))
            }
        }
        for view in subviews {
            view.frame.size = CGSize(width: getViewWidth(view), height: getViewHeight(view))
            if view.lv.weight > 0 {
                if direction == .horizontal {
                    view.frame.size.width = max((view.lv.weight * (parentSize.width - surplusSize.width) / totalWeight), 0)
                } else {
                    view.frame.size.height = max((view.lv.weight * (parentSize.height - surplusSize.height) / totalWeight), 0)
                }
            }
        }
    }

    private func setLayoutViewFrame() {
        if frame == .zero {
            frame.size = CGSize(width: getViewWidth(self), height: getViewHeight(self))
            frame.origin = CGPoint(x: lv.margin + lv.marginLeft, y: lv.margin + lv.marginTop)
        }
    }

    private func setChildViewOrigin() {
        var lastView: UIView?
        for view in subviews {
            var size = CGSize.zero
            if let value = lastView {
                size = CGSize(width: value.frame.maxX + value.lv.margin + value.lv.marginRight, height: value.frame.maxY + value.lv.margin + value.lv.marginBottom)
            }
            if direction == .horizontal {
                view.frame.origin.x = view.lv.margin + view.lv.marginLeft + size.width
                switch lv.contentGravity {
                case .center, .centerVertical:
                    view.frame.origin.y = ((frame.height - view.frame.height) / 2) + (view.lv.marginTop - view.lv.marginBottom)
                case .bottom:
                     view.frame.origin.y = frame.height - view.frame.height - view.lv.margin - view.lv.marginBottom
                default:
                    view.frame.origin.y = view.lv.margin + view.lv.marginTop
                    break
                }
                switch view.lv.gravity {
                case .center, .centerVertical:
                    view.frame.origin.y = ((frame.height - view.frame.height) / 2) + (view.lv.marginTop - view.lv.marginBottom)
                case .centerHorizontal:
                    view.frame.origin.y = view.lv.margin + view.lv.marginTop
                case .bottom:
                    view.frame.origin.y = frame.height - view.frame.height - view.lv.margin - view.lv.marginBottom
                default:
                    break
                }
            } else {
                view.frame.origin.y = view.lv.margin + view.lv.marginTop + size.height
                switch lv.contentGravity {
                case .center, .centerHorizontal:
                    view.frame.origin.x = ((frame.width - view.frame.width) / 2) + (view.lv.marginLeft - view.lv.marginRight)
                case .right:
                    view.frame.origin.x = frame.width - view.frame.width - view.lv.margin - view.lv.marginRight
                default:
                    view.frame.origin.x = view.lv.margin + view.lv.marginLeft
                    break
                }
                switch view.lv.gravity {
                case .center, .centerHorizontal:
                    view.frame.origin.x = ((frame.width - view.frame.width) / 2) + (view.lv.marginLeft - view.lv.marginRight)
                case .centerVertical:
                    view.frame.origin.x = view.lv.margin + view.lv.marginLeft
                case .right:
                    view.frame.origin.x = frame.width - view.frame.width - view.lv.margin - view.lv.marginRight
                default:
                    break
                }
            }
            lastView = view
        }
        let childTotalSize = getViewChildTotalSize(self)
        for view in subviews {
            if direction == .horizontal {
                if lv.contentGravity == .center{
                    view.frame.origin.x = view.frame.origin.x + (frame.width - childTotalSize.width) / 2
                }
            } else {
                if lv.contentGravity == .center{
                    view.frame.origin.y = view.frame.origin.y + (frame.height - childTotalSize.height) / 2
                }
            }
        }
    }

    private func getViewWidth(_ from: UIView) -> CGFloat {
        if from.frame.width > 0 {
            return from.frame.width
        } else {
            var width = from.frame.width
            switch from.lv.width {
            case .fill:
                if let value = from.superview {
                    width = value.frame.width - from.lv.margin * 2 - from.lv.marginLeft - from.lv.marginRight
                    if value is LinearLayoutView || value is RelativeLayoutView || value is FlowLayoutView {
                        width = getViewWidth(value) - from.lv.margin * 2 - from.lv.marginLeft - from.lv.marginRight
                        if let child = value as? LinearLayoutView {
                            if child.direction == .horizontal {
                                for view in child.subviews {
                                    if view == from {
                                        break
                                    }
                                    width -= view.frame.width + view.lv.margin * 2 + view.lv.marginLeft + view.lv.marginRight
                                }
                            }
                        }
                    }
                }
            case .px(let value):
                width = value
            case .wrap:
                if let child = from as? LinearLayoutView {
                    width = getLayoutWrapViewSize(child).width
                }
            }
            return width
        }
    }

    private func getViewHeight(_ from: UIView) -> CGFloat {
        if from.frame.height > 0 {
            return from.frame.height
        } else {
            var height = from.frame.height
            switch from.lv.height {
            case .fill:
                if let value = from.superview {
                    height = value.frame.height - from.lv.margin * 2 - from.lv.marginTop - from.lv.marginBottom
                    if value is LinearLayoutView || value is RelativeLayoutView || value is FlowLayoutView {
                        height = getViewHeight(value) - from.lv.margin * 2 - from.lv.marginTop - from.lv.marginBottom
                        if let child = value as? LinearLayoutView {
                            if child.direction == .vertical {
                                for view in child.subviews {
                                    if view == from {
                                        break
                                    }
                                    height -= view.frame.height + view.lv.margin * 2 + view.lv.marginTop + view.lv.marginBottom
                                }
                            }
                        }
                    }
                }
            case .px(let value):
                height = value
            case .wrap:
                if let child = from as? LinearLayoutView {
                    height = getLayoutWrapViewSize(child).height
                }
            }
            return height
        }
    }

    private func getLayoutWrapViewSize(_ from: LinearLayoutView) -> CGSize {
        var size = CGSize.zero
        for view in from.subviews {
            if from.direction == .horizontal {
                size.width += getViewWidth(view) + view.lv.margin * 2 + view.lv.marginLeft + view.lv.marginRight
                let height = getViewHeight(view) + view.lv.margin * 2 + view.lv.marginTop + view.lv.marginBottom
                if height > size.height {
                    size.height = height
                }
            } else {
                size.height += getViewHeight(view) + view.lv.margin * 2 + view.lv.marginTop + view.lv.marginBottom
                let width = getViewWidth(view) + view.lv.margin * 2 + view.lv.marginLeft + view.lv.marginRight
                if width > size.width {
                    size.width = width
                }
            }
        }
        return size
    }

    private func getViewChildTotalSize(_ from: LinearLayoutView) -> CGSize {
        var size = CGSize.zero
        for view in from.subviews {
            if from.direction == .horizontal {
                size.width += view.frame.width + view.lv.margin * 2 + view.lv.marginLeft + view.lv.marginRight
                size.height = view.frame.maxY + view.lv.margin + view.lv.marginBottom
            } else {
                size.height += view.frame.height + view.lv.margin * 2 + view.lv.marginTop + view.lv.marginBottom
                size.width = view.frame.maxX + view.lv.margin + view.lv.marginRight
            }
        }
        return size
    }
}
