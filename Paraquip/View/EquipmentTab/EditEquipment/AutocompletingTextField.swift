//
//  AutocompletingTextField.swift
//  Paraquip
//
//  Created by Simon Seyer on 21.08.22.
//

import SwiftUI

struct AutocompletingTextField: View {

    let label: LocalizedStringKey
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

    init(_ label: LocalizedStringKey, text: Binding<String>, completions: [String]) {
        self.label = label
        self._text = text
        self.completions = completions
        self.completionSlugs = completions.map { $0.slugified() }
    }

    var body: some View {
        LabeledContent(label) {
            TextField("", text: $text)
                #if os(iOS)
                .foregroundColor(matched ? .accentColor : .primary)
                #endif
                .bold(matched)
                .multilineTextAlignment(.trailing)
                .autocorrectionDisabled()
                .focused($focused)
        }.toolbar {
            ToolbarItem(placement: .keyboard) {
                if focused {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(filteredCompletions, id: \.hashValue) { completion in
                                Button {
                                    text = completion
                                } label: {
                                    Text(completion)
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                        #if os(visionOS)
                        .controlSize(.small)
                        .padding(6)
                        #endif
                    }
                    #if os(visionOS)
                    .frame(width: 600)
                    .glassBackgroundEffect()
                    #endif
                }
            }
        }
    }
}

fileprivate struct AutocompletingTextField_PreviewView: View {

    @State var text = ""
    @State var text2 = ""
    let completions = ["test", "Abc", "123", "aBCdef", "test", "Abc", "123", "aBCdef"]

    var body: some View {
        NavigationStack {
            Form {
                AutocompletingTextField("Test", text: $text, completions: completions)
                TextField("Non-completing", text: $text2)
            }
        }
    }
}

struct AutocompletingTextField_Previews: PreviewProvider {

    static var previews: some View {
        AutocompletingTextField_PreviewView()
    }
}
