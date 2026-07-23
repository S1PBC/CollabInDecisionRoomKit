#  OutputLogger

A custom logging class that emulates [roslog](https://wiki.ros.org/roscpp/Overview/Logging)

## Implementation

To implement, first add this folder directly in your repository. Ensure targets are correct. 

This file depends on JSONLoader.swift for functionality to work. You can manually add the needed code for this by copying and pasting the below into the global scope:

```swift

/// JSON error handling
public enum JSONLoaderError: Error, CustomStringConvertible {
    case fileNotFound(resource: String, ext: String)
    case unreadableData(underlying: Error)
    case decodingFailed(expectedType: String, underlying: Error)
    case topLevelNotObject(expected: String)

    public var description: String {
        switch self {
        case let .fileNotFound(resource, ext):
            return "Could not find \(resource).\(ext) in the specified Bundle."
        case let .unreadableData(underlying):
            return "Failed to read data from file. Underlying error: \(underlying)"
        case let .decodingFailed(expectedType, underlying):
            return "JSON decoding failed for expected type \(expectedType). Underlying error: \(underlying)"
        case let .topLevelNotObject(expected):
            return "Top-level JSON is not an object. Expected \(expected)."
        }
    }
}

/// Generic typed function to load a homogenous dictionary from the bundle with the given resource name and generic type,, throwing a ``JSONLoaderError`` on failure
@inlinable
public func loadJSON<T: Decodable>(
    resourceName: String,
    withExtension: String = "json",
    bundle: Bundle = .main
) throws -> T {
    guard let url = bundle.url(forResource: resourceName, withExtension: withExtension) else {
        throw JSONLoaderError.fileNotFound(resource: resourceName, ext: withExtension)
    }
    let data: Data
    do {
        data = try Data(contentsOf: url, options: [.mappedIfSafe])
    } catch {
        throw JSONLoaderError.unreadableData(underlying: error)
    }
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        throw JSONLoaderError.decodingFailed(expectedType: String(describing: T.self), underlying: error)
    }
}

```

This code is also contained in: ExampleJSONLoader.swift, uncomment it and copy it into your own file.

In your observable AppModel which maintains app-wide state on the @MainActor (which is required for interacting with SwiftUI views) add: 

```swift
    //MARK: custom logger
    
    /// Custom logging console with verbose toggle.
    let logger: OutputLogger = .shared
    
    /// A set of all enabled priorities for filtering logged entries in  ``TerminalView``
    var enabledPriorities: Set<Priority> = Set(Priority.allCases)

    /// A set of all enabled tags for filtering logged entries in ``TerminalView``
    var enabledTags: Set<String> = []

    /// A boolean for setting the state of a filter in ``TerminalView`` such that only tagged log entries show
    var onlyTagged: Bool = false

    /// A boolean for setting the state of a filter in ``TerminalView`` such that only untagged log entries show
    var onlyUntagged: Bool = false
```

In a view of your choice in a window, such as a NavigationSplitView or NavigationStack, add: 

```swift
   TerminalView(appModel) // where appModel is the AppModel() the above code was placed in
```

You can find an example of this in: Views > ExampleNavigationSplitView.swift

## Enabling [Metal Logging](https://developer.apple.com/documentation/metal/logging-shader-debug-messages?)

In Project > Targets > Build Settings > Search: Other Metal Compiler Flags:

Add as a compiler flag: 
```
-fmetal-enable-logging
```
OR through commandline run:

```bash
xcrun metal -std=metal3.2 -fmetal-enable-logging -o helloTriangle.metallib helloTriangle.metal
```

In Project > XCode Menu > Product > Scheme > Edit Scheme:
In the popup window: Run > Arguments
Click "+" button under "Environment Variables"
Add:
```
MTL_LOG_LEVEL           MTLLogLevelDebug
MTL_LOG_BUFFER_SIZE     2048
MTL_LOG_TO_STDERR       1
```

## Usage

In Logging/Resources/LoggingConfiguration.json, set the verbosity and coalescing behavior of the logger. 
Verbosity determines whether or not logs are outputted to the TerminalView and the XCode debugging console.
Coalescing determines whether repeat logs are coalesced into one summary. Note that this behavior may have unpredicted behaviour if the CPU is being used too heavily.

## Planned improvements

Currently throttle and throttleIdentical functionality is unimplemented. See https://wiki.ros.org/roscpp/Overview/Logging for more information.
