//
//  PickerOverlay.swift
//  Paraquip
//
//  Created by Simon Seyer on 16.05.21.
//

import SwiftUI

struct PickerOverlay : UIViewRepresentable {

    @Binding var options: [String]
    @Binding var selectionIndex: Int
    @Binding var isVisible: Bool

    func makeCoordinator() -> PickerOverlay.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<PickerOverlay>) -> PickerOverlayView {
        let view = PickerOverlayView()
        view.picker.delegate = context.coordinator
        view.picker.dataSource = context.coordinator
        view.picker.tintColor = UIColor(Color.accentColor)
        view.textField.inputView = view.picker
        view.textField.delegate = context.coordinator
        view.textField.layer.opacity = 0
        return view
    }

    func updateUIView(_ uiView: PickerOverlayView, context: UIViewRepresentableContext<PickerOverlay>) {
        context.coordinator.options = options
        uiView.picker.reloadComponent(0)

        uiView.picker.selectRow(selectionIndex, inComponent: 0, animated: false)

        if isVisible {
            uiView.textField.becomeFirstResponder()
        } else {
            uiView.textField.resignFirstResponder()
        }
    }

    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate , UITextFieldDelegate {

        private let parent : PickerOverlay

        var options: [String]

        init(_ parent: PickerOverlay) {
            self.parent = parent
            self.options = parent.options
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }

        func pickerView(_ pickerView: UIPickerView,
                        numberOfRowsInComponent component: Int) -> Int {
            return options.count
        }

        func pickerView(_ pickerView: UIPickerView,
                        titleForRow row: Int,
                        forComponent component: Int) -> String? {
            return options[row]
        }

        func pickerView(_ pickerView: UIPickerView,
                        didSelectRow row: Int,
                        inComponent component: Int) {
            parent.$selectionIndex.wrappedValue = row
        }

        func textField(_ textField: UITextField,
                       shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool {
            return false
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            self.parent.$isVisible.wrappedValue = false
        }
    }
}

class PickerOverlayView: UIView {
    fileprivate let textField = UITextField()
    fileprivate let picker = UIPickerView()

    init() {
        super.init(frame: CGRect.zero)
        addSubview(textField)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
