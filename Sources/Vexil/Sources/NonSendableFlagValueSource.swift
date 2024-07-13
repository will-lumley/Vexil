//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2024 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

#if !os(Linux)
import Combine
#endif

import Foundation

/// A simple protocol that describes a non-sendable source of `FlagValue`s.
///
/// This protocol is used with types that cannot be made to be `Sendable`, like
/// `UserDefaults`. You can add it to a ``FlagPole`` by wrapping it in a
/// ``FlagValueSourceCoordinator``:
///
/// ```swift
/// let coordinator = FlagValueSourceCoordinator(source: UserDefaults.standard)
/// let pole = FlagPole(hoist: MyFlag.self, sources: [ coordinator ])
/// ```
///
/// - Note: If your flag value source is `Sendable` you should conform directly
/// to ``FlagValueSource`` and skip the coordinator.
///
/// For more information and examples on creating custom `FlagValueSource`s please
/// see the full documentation.
///
public protocol NonSendableFlagValueSource: Identifiable where ID == String {

    associatedtype ChangeStream: AsyncSequence & Sendable where ChangeStream.Element == FlagChange

    /// The name of the source. Used by flag editors like Vexillographer
    var name: String { get }

    /// Provide a way to fetch values. The ``BoxedFlagValue`` type is there to help with boxing and unboxing of flag values.
    func flagValue<Value>(key: String) -> Value? where Value: FlagValue

    /// And to save values – if your source does not support saving just do nothing. The ``BoxedFlagValue`` type is there to
    /// help with boxing and unboxing of flag values.
    ///
    /// It is expected if the value passed in is `nil` then the flag value would be cleared.
    ///
    mutating func setFlagValue(_ value: (some FlagValue)?, key: String) throws

    /// Return an `AsyncSequence` that emits ``FlagChange`` values any time flag values have changed.
    var changeStream: ChangeStream { get }

}

public extension NonSendableFlagValueSource {

    var id: String {
        name
    }

}
