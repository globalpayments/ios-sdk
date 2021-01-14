import Foundation

public protocol TrackData: class {
    var expiry: String? { get set }
    var pan: String? { get set }
    var trackNumber: TrackNumber? { get set }
    var trackData: String? { get set }
    var discretionaryData: String? { get set }
    var value: String? { get set }
    var entryMethod: EntryMethod? { get set }
}
