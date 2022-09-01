//
//  AutocompletingTextField.swift
//  Paraquip
//
//  Created by Simon Seyer on 21.08.22.
//

import SwiftUI

struct AutocompletingTextField: View {

    let label: String
    @Binding var text: String
    let completions: [String]

    private let completionSlugs: [String]

    @FocusState private var focused: Bool

    private var filteredCompletions: [String] {
        if text.isEmpty {
            return completions
        } else {
            return completions.filter {
                $0.slugified().contains(text.slugified())
            }
        }
    }

    private var matched: Bool {
        completionSlugs.contains(text.slugified())
    }

    init(_ label: String, text: Binding<String>, completions: [String]) {
        self.label = label
        self._text = text
        self.completions = completions
        self.completionSlugs = completions.map { $0.slugified() }
    }

    var body: some View {
        VStack {
            HStack {
                Text(label)
                Spacer()
                TextField("", text: $text)
                    .foregroundColor(matched ? .accentColor : .primary)
                    .font(matched ? .body.bold() : .body)
                    .multilineTextAlignment(.trailing)
                    .autocorrectionDisabled()
                    .focused($focused)
            }
        }
        .frame(height: focused ? 100 : 50)
    }
}

fileprivate struct AutocompletingTextField_PreviewView: View {

    @State var text = ""
    let completions = ["test", "Abc", "123", "aBCdef", "test", "Abc", "123", "aBCdef"]

    var body: some View {
        NavigationView {
            Form {
                AutocompletingTextField("Test", text: $text, completions: completions)
            }
        }
    }
}

struct AutocompletingTextField_Previews: PreviewProvider {

    static var previews: some View {
        AutocompletingTextField_PreviewView()
    }
}
