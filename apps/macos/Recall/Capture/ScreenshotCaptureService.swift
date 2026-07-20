@preconcurrency import AppKit
import Foundation

struct ScreenshotSnapshot: Equatable, Sendable {
    let imageData: Data
    let mediaType: String
    let sourceApplication: String?
}

enum ScreenshotCaptureError: Error, LocalizedError, Equatable {
    case cancelled
    case unavailable
    case emptyImage

    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Screenshot selection was cancelled."
        case .unavailable:
            return "Recall could not start macOS screenshot selection."
        case .emptyImage:
            return "The selected screenshot was empty. Try selecting the region again."
        }
    }
}

@MainActor
protocol ScreenshotCaptureServing {
    func captureInteractive() throws -> ScreenshotSnapshot
}

@MainActor
struct SystemScreenshotCaptureService: ScreenshotCaptureServing {
    func captureInteractive() throws -> ScreenshotSnapshot {
        let frontmostApplication = NSWorkspace.shared.frontmostApplication
        let sourceApplication = frontmostApplication?.bundleIdentifier == Bundle.main.bundleIdentifier
            ? nil
            : frontmostApplication?.localizedName
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("recall-screenshot-\(UUID().uuidString.lowercased())")
            .appendingPathExtension("png")
        defer { try? FileManager.default.removeItem(at: outputURL) }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        process.arguments = ["-i", "-x", "-t", "png", outputURL.path]

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            throw ScreenshotCaptureError.unavailable
        }

        guard process.terminationStatus == 0 else {
            throw ScreenshotCaptureError.cancelled
        }
        guard let data = try? Data(contentsOf: outputURL), !data.isEmpty else {
            throw ScreenshotCaptureError.emptyImage
        }
        return ScreenshotSnapshot(
            imageData: data,
            mediaType: "image/png",
            sourceApplication: sourceApplication?.nonEmptyTrimmed ?? "Screenshot"
        )
    }
}
