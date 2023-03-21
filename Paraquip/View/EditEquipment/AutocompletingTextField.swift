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
    @State private var isAutocompletionShown = false

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
        VStack {
            HStack {
                Text(label)
                Spacer()
                TextField("", text: $text)
                    .foregroundColor(matched ? .accentColor : .primary)
                    .bold(matched)
                    .multilineTextAlignment(.trailing)
                    .autocorrectionDisabled()
                    .focused($focused)
            }
            if isAutocompletionShown {
                Group {
                    if filteredCompletions.isEmpty {
                        Text("No completions")
                            .foregroundColor(.secondary)
                            .font(.caption)
                            .italic()
                    } else {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(filteredCompletions, id: \.hashValue) { completion in
                                    Button(action:  {
                                        text = completion
                                        focused = false
                                    }) {
                                        Text(completion)
                                    }.buttonStyle(.borderedProminent)
                                }
                            }
                            .padding(8)
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 51)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(6)
            }
        }
        // Fixes cell height animation (makes the cell larger than needed to avoid some strange glitch)
        .animatingCellHeight(isAutocompletionShown ? 88 : 38)
        .onChange(of: focused) { newValue in
            withAnimation {
                isAutocompletionShown = newValue
            }
        }
    }
}

fileprivate struct AutocompletingTextField_PreviewView: View {

    @State var text = ""
    @State var text2 = ""
    let completions = ["test", "Abc", "123", "aBCdef", "test", "Abc", "123", "aBCdef"]

    var body: some View {
        NavigationView {
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
