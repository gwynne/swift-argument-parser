//===----------------------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Argument Parser open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// A type that can be executed as part of a nested tree of commands, synchronous variant.
public protocol ParsableCommand: BaseParsableCommand {
  /// Runs this command.
  ///
  /// After implementing this method, you can run your command-line
  /// application by calling the static `main()` method on the root type.
  /// This method has a default implementation that prints help text
  /// for this command.
  mutating func run() throws
}

extension ParsableCommand {
  public mutating func run() throws {
    throw CleanExit.helpRequest(self)
  }
}

// MARK: - API

extension ParsableCommand {
  /// Parses an instance of this type, or one of its subcommands, from
  /// the given arguments and calls its `run()` method, exiting with a
  /// relevant error message if necessary.
  ///
  /// - Parameter arguments: An array of arguments to use for parsing. If
  ///   `arguments` is `nil`, this uses the program's command-line arguments.
  public static func main(_ arguments: [String]?) {
    do {
      let command = try parseAsRoot(arguments)
      if var syncCommand = command as? ParsableCommand {
        try syncCommand.run()
      } else {
        // TODO: We can't execute an async command here, and what to do in the case of something else?
        fatalError()
      }
    } catch {
      exit(withError: error)
    }
  }

  /// Parses an instance of this type, or one of its subcommands, from
  /// command-line arguments and calls its `run()` method, exiting with a
  /// relevant error message if necessary.
  public static func main() {
    self.main(nil)
  }
}
