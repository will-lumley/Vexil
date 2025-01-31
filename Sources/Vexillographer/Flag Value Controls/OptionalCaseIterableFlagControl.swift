//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2023 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

// Optional Case Iterable Flags
//
// For those whose flag value is optional and conform to `CaseIterable`

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
struct OptionalCaseIterableFlagControl<Value>: View
    where Value: OptionalFlagValue, Value.WrappedFlagValue: CaseIterable,
    Value.WrappedFlagValue: Hashable, Value.WrappedFlagValue.AllCases: RandomAccessCollection
{

    // MARK: - Properties

    let label: String
    @Binding
    var value: Value

    let hasChanges: Bool
    let isEditable: Bool
    @Binding
    var showDetail: Bool

    @Binding
    var showPicker: Bool

    // MARK: - View Body

    var content: some View {
        HStack {
            Text(self.label).font(.headline)
            Spacer()
            FlagDisplayValueView(value: self.value.wrapped)
        }
    }

    var body: some View {
        HStack {
            if self.isEditable {
                NavigationLink(destination: self.selector, isActive: self.$showPicker) {
                    self.content
                }
            } else {
                self.content
            }
            DetailButton(hasChanges: self.hasChanges, showDetail: self.$showDetail)
        }
    }

#if os(iOS)

    var selector: some View {
        return self.selectorList
            .navigationBarTitle(Text(self.label), displayMode: .inline)
    }

#else

    var selector: some View {
        return self.selectorList
    }

#endif

    var selectorList: some View {
        Form {
            Section {
                Button(
                    action: {
                        self.valueSelected(nil)
                    },
                    label: {
                        Text("None")
                            .foregroundColor(.primary)
                        Spacer()

                        if self.value.wrapped == nil {
                            self.checkmark
                        }
                    }
                )
            }

            ForEach(Value.WrappedFlagValue.allCases, id: \.self) { value in
                Button(
                    action: {
                        self.valueSelected(value)
                    },
                    label: {
                        FlagDisplayValueView(value: value)
                        Spacer()

                        if value == self.value.wrapped {
                            self.checkmark
                        }
                    }
                )
            }
        }
    }

#if os(macOS)

    var checkmark: some View {
        return Text("✓")
    }

#else

    var checkmark: some View {
        return Image(systemName: "checkmark")
    }

#endif

    func valueSelected(_ value: Value.WrappedFlagValue?) {
        self.value.wrapped = value
        showPicker = false
    }

}


// MARK: - Creating CaseIterableFlagControls

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
protocol OptionalCaseIterableEditableFlag {
    func control<RootGroup>(label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>, showPicker: Binding<Bool>) -> AnyView where RootGroup: FlagContainer
}

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
extension UnfurledFlag: OptionalCaseIterableEditableFlag
    where Value: OptionalFlagValue, Value.WrappedFlagValue: CaseIterable,
    Value.WrappedFlagValue.AllCases: RandomAccessCollection, Value.WrappedFlagValue: RawRepresentable,
    Value.WrappedFlagValue.RawValue: FlagValue, Value.WrappedFlagValue: Hashable
{
    func control<RootGroup>(label: String, manager: FlagValueManager<RootGroup>, showDetail: Binding<Bool>, showPicker: Binding<Bool>) -> AnyView where RootGroup: FlagContainer {
        let key = info.key

        return OptionalCaseIterableFlagControl<Value>(
            label: label,
            value: Binding(
                get: { Value(manager.flagValue(key: key)) },
                set: { newValue in
                    do {
                        try manager.setFlagValue(newValue.wrapped, key: key)

                    } catch {
                        print("[Vexilographer] Could not set flag with key \"\(key)\" to \"\(newValue)\"")
                    }
                }
            ),
            hasChanges: manager.hasValueInSource(flag: flag),
            isEditable: manager.isEditable,
            showDetail: showDetail,
            showPicker: showPicker
        )
        .eraseToAnyView()
    }
}

#endif
