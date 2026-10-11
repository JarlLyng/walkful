// loopkit: cut, encode and check the site's hero loop (#200). AVFoundation only,
// so it needs nothing installed beyond Xcode. See appstore/site/README.md.
//   swift loopkit.swift sheet  <src> <dst.jpg> <start> <end> <step> <columns>   contact sheet, to find the cut
//   swift loopkit.swift frames <src> <outdir> <step-seconds>                     single preview frames
//   swift loopkit.swift encode <src> <dst.mp4> <start> <duration> <width> <height> <bitsPerSecond>
//   swift loopkit.swift poster <src> <dst.jpg> <time> <width> <height> <quality>
// encode also paints out the Dynamic Island, which a simulator recording draws
// and a screenshot doesn't: the site's phone is generic, per Apple's rules.
import AVFoundation
import CoreImage
import ImageIO
import UniformTypeIdentifiers

let args = CommandLine.arguments
func fail(_ m: String) -> Never { FileHandle.standardError.write((m + "\n").data(using: .utf8)!); exit(1) }

func image(_ asset: AVAsset, at t: Double, maxSize: CGSize? = nil) -> CGImage {
    let gen = AVAssetImageGenerator(asset: asset)
    gen.appliesPreferredTrackTransform = true
    gen.requestedTimeToleranceBefore = .zero
    gen.requestedTimeToleranceAfter = .zero
    if let m = maxSize { gen.maximumSize = m }
    do { return try gen.copyCGImage(at: CMTime(seconds: t, preferredTimescale: 600), actualTime: nil) }
    catch { fail("frame at \(t): \(error)") }
}

func writeJPEG(_ img: CGImage, to path: String, quality: Double) {
    let url = URL(fileURLWithPath: path) as CFURL
    guard let dest = CGImageDestinationCreateWithURL(url, UTType.jpeg.identifier as CFString, 1, nil) else { fail("dest") }
    CGImageDestinationAddImage(dest, img, [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary)
    guard CGImageDestinationFinalize(dest) else { fail("finalize") }
}


// The simulator's recording draws the Dynamic Island; a screenshot doesn't.
// Find the black pill near the top centre once, then paint it in the status
// bar's own colour on every frame, so the phone reads as generic.
var islandRect: (x0: Int, y0: Int, x1: Int, y1: Int, b: UInt8, g: UInt8, r: UInt8)? = nil
func hideIsland(_ pb: CVPixelBuffer) {
    CVPixelBufferLockBaseAddress(pb, [])
    defer { CVPixelBufferUnlockBaseAddress(pb, []) }
    guard let base = CVPixelBufferGetBaseAddress(pb)?.assumingMemoryBound(to: UInt8.self) else { return }
    let w = CVPixelBufferGetWidth(pb), h = CVPixelBufferGetHeight(pb), row = CVPixelBufferGetBytesPerRow(pb)
    func px(_ x: Int, _ y: Int) -> UnsafeMutablePointer<UInt8> { base + y * row + x * 4 }
    if islandRect == nil {
        var x0 = w, y0 = h, x1 = -1, y1 = -1
        for y in 0..<(h / 12) { for x in (w * 30 / 100)..<(w * 70 / 100) {
            let p = px(x, y)
            if p[0] < 40 && p[1] < 40 && p[2] < 40 { x0 = min(x0, x); y0 = min(y0, y); x1 = max(x1, x); y1 = max(y1, y) }
        } }
        guard x1 > x0, (x1 - x0) > w / 6 else { return }
        x0 = max(0, x0 - 3); y0 = max(0, y0 - 3); x1 = min(w - 1, x1 + 3); y1 = min(h - 1, y1 + 3)
        let c = px(max(0, x0 - 8), (y0 + y1) / 2)
        islandRect = (x0, y0, x1, y1, c[0], c[1], c[2])
        FileHandle.standardError.write("island at \(x0),\(y0)-\(x1),\(y1)\n".data(using: .utf8)!)
    }
    guard let r = islandRect else { return }
    for y in r.y0...r.y1 { for x in r.x0...r.x1 { let p = px(x, y); p[0] = r.b; p[1] = r.g; p[2] = r.r } }
}

let asset = AVURLAsset(url: URL(fileURLWithPath: args[2]))

switch args[1] {
case "frames":
    let out = args[3], step = Double(args[4])!
    let dur = CMTimeGetSeconds(asset.duration)
    var t = 0.0, i = 0
    while t < dur {
        writeJPEG(image(asset, at: t, maxSize: CGSize(width: 240, height: 520)), to: "\(out)/f\(String(format: "%03d", i))_\(String(format: "%.2f", t)).jpg", quality: 0.6)
        t += step; i += 1
    }
    print("duration \(dur)s, \(i) frames")

case "sheet":
    // sheet <src> <dst.jpg> <start> <end> <step> <cols>
    let a = Double(args[4])!, b = Double(args[5])!, step = Double(args[6])!, cols = Int(args[7])!
    let tw = 180, th = 392
    var times: [Double] = []; var t = a; while t <= b + 0.001 { times.append(t); t += step }
    let rows = (times.count + cols - 1) / cols
    let W = cols * tw, H = rows * (th + 20)
    let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: 0,
                        space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    ctx.setFillColor(gray: 1, alpha: 1); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
    for (i, tt) in times.enumerated() {
        let img = image(asset, at: tt, maxSize: CGSize(width: tw, height: th))
        let x = (i % cols) * tw, y = H - (i / cols + 1) * (th + 20)
        ctx.draw(img, in: CGRect(x: x, y: y + 20, width: tw - 4, height: th))
    }
    writeJPEG(ctx.makeImage()!, to: args[3], quality: 0.7)
    print("sheet: \(times.count) frames, \(String(format: "%.2f", a))s to \(String(format: "%.2f", b))s")

case "poster":
    let t = Double(args[4])!, w = Int(args[5])!, h = Int(args[6])!, q = Double(args[7])!
    let full = image(asset, at: t)
    guard let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                              space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { fail("ctx") }
    ctx.interpolationQuality = .high
    ctx.draw(full, in: CGRect(x: 0, y: 0, width: w, height: h))
    writeJPEG(ctx.makeImage()!, to: args[3], quality: q)

case "encode":
    let dst = URL(fileURLWithPath: args[3])
    let start = Double(args[4])!, duration = Double(args[5])!
    let w = Int(args[6])!, h = Int(args[7])!, bps = Int(args[8])!
    try? FileManager.default.removeItem(at: dst)
    guard let track = asset.tracks(withMediaType: .video).first else { fail("no video track") }
    let reader = try! AVAssetReader(asset: asset)
    reader.timeRange = CMTimeRange(start: CMTime(seconds: start, preferredTimescale: 600),
                                   duration: CMTime(seconds: duration, preferredTimescale: 600))
    // Let the reader scale: request BGRA at the target size via a video composition.
    let comp = AVMutableVideoComposition(propertiesOf: asset)
    comp.renderSize = CGSize(width: w, height: h)
    comp.frameDuration = CMTime(value: 1, timescale: 30)
    let instr = AVMutableVideoCompositionInstruction()
    instr.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
    let layer = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
    let nat = track.naturalSize
    layer.setTransform(CGAffineTransform(scaleX: CGFloat(w) / nat.width, y: CGFloat(h) / nat.height), at: .zero)
    instr.layerInstructions = [layer]
    comp.instructions = [instr]
    let out = AVAssetReaderVideoCompositionOutput(videoTracks: [track], videoSettings: [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA])
    out.videoComposition = comp
    reader.add(out)

    let writer = try! AVAssetWriter(outputURL: dst, fileType: .mp4)
    writer.shouldOptimizeForNetworkUse = true
    let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: w, AVVideoHeightKey: h,
        AVVideoCompressionPropertiesKey: [
            AVVideoAverageBitRateKey: bps,
            AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
            AVVideoMaxKeyFrameIntervalKey: 90,
            AVVideoExpectedSourceFrameRateKey: 30,
        ],
    ])
    input.expectsMediaDataInRealTime = false
    writer.add(input)
    reader.startReading()
    writer.startWriting()
    writer.startSession(atSourceTime: .zero)
    let offset = CMTime(seconds: start, preferredTimescale: 600)
    let q = DispatchQueue(label: "enc")
    let done = DispatchSemaphore(value: 0)
    var last = CMTime.zero
    input.requestMediaDataWhenReady(on: q) {
        while input.isReadyForMoreMediaData {
            if let sb = out.copyNextSampleBuffer() {
                // Rebase to zero, so the file starts at its first frame.
                var timing = CMSampleTimingInfo()
                CMSampleBufferGetSampleTimingInfo(sb, at: 0, timingInfoOut: &timing)
                timing.presentationTimeStamp = CMTimeSubtract(timing.presentationTimeStamp, offset)
                timing.decodeTimeStamp = .invalid
                var shifted: CMSampleBuffer?
                CMSampleBufferCreateCopyWithNewTiming(allocator: nil, sampleBuffer: sb, sampleTimingEntryCount: 1,
                                                      sampleTimingArray: &timing, sampleBufferOut: &shifted)
                guard let s2 = shifted else { continue }
                if let pb = CMSampleBufferGetImageBuffer(s2) { hideIsland(pb) }
                last = timing.presentationTimeStamp
                input.append(s2)
            } else {
                input.markAsFinished()
                // The simulator writes frames only when the screen changes, so a
                // still hold has none: end at the full duration, and the last
                // frame stays up until then.
                writer.endSession(atSourceTime: CMTimeMaximum(last, CMTime(seconds: duration, preferredTimescale: 600)))
                writer.finishWriting { done.signal() }
                return
            }
        }
    }
    done.wait()
    if writer.status != .completed { fail("writer: \(String(describing: writer.error))") }
    let size = (try? FileManager.default.attributesOfItem(atPath: dst.path)[.size] as? Int) ?? 0
    print("wrote \(dst.lastPathComponent): \(size / 1024) KB")

default:
    fail("unknown command")
}
