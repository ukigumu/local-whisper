#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#endif

public enum Stderr {
    public static func write(_ message: String) {
        var text = message
        if !text.hasSuffix("\n") {
            text.append("\n")
        }
        fputs(text, stderr)
    }
}
