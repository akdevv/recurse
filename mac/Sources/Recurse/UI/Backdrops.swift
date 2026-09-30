import CoreImage.CIFilterBuiltins
import SwiftUI

/// The glow at the top of a page: the family's colour washing down from just under the header, with a soft top
/// light, easing out into the canvas. No grain here: the header's blur would smooth it into a visible band.
struct Backdrop: View {
    let family: GradientFamily

    var body: some View {
        ZStack {
            LinearGradient(colors: [family.mid.opacity(0.17), family.mid.opacity(0.04)], startPoint: .top, endPoint: .bottom)
            EllipticalGradient(stops: [
                .init(color: family.light.opacity(0.1), location: 0),
                .init(color: family.mid.opacity(0.14), location: 0.3),
                .init(color: .clear, location: 0.9),
            ], center: UnitPoint(x: 0.35, y: -0.15))
            EllipticalGradient(stops: [
                .init(color: family.mid.opacity(0.1), location: 0),
                .init(color: .clear, location: 0.7),
            ], center: UnitPoint(x: 1, y: -0.05))
        }
        .id(family)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.5), value: family)
        // soft under the header, strongest just below it, then a long eased fall-off
        .mask(LinearGradient(stops: [
            .init(color: .black.opacity(0.6), location: 0),
            .init(color: .black, location: 0.12),
            .init(color: .black.opacity(0.8), location: 0.3),
            .init(color: .black.opacity(0.45), location: 0.52),
            .init(color: .black.opacity(0.18), location: 0.74),
            .init(color: .black.opacity(0.05), location: 0.9),
            .init(color: .clear, location: 1),
        ], startPoint: .top, endPoint: .bottom))
        .allowsHitTesting(false)
    }
}

/// A colour family: pale highlight, saturated middle, deep shade (from Gradient Studio's families).
struct GradientFamily: Hashable {
    let light, mid, deep: Color

    static let ember = GradientFamily(light: Color(hex: 0xffd194), mid: Color(hex: 0xd04b3c), deep: Color(hex: 0x4b1010))
    static let ocean = GradientFamily(light: Color(hex: 0xcaf0f8), mid: Color(hex: 0x00b4d8), deep: Color(hex: 0x03045e))
    static let gold = GradientFamily(light: Color(hex: 0xfff7cc), mid: Color(hex: 0xf9c74f), deep: Color(hex: 0xa0522d))
    static let meadow = GradientFamily(light: Color(hex: 0xd8f3dc), mid: Color(hex: 0x52b788), deep: Color(hex: 0x184e77))
    static let cobalt = GradientFamily(light: Color(hex: 0xb8c6ff), mid: Color(hex: 0x4361ee), deep: Color(hex: 0x10002b))
}

/// Full-window background for the welcome screen and the tour, layered like an editorial gradient: a deep base,
/// a soft top light, an accent glow, a vignette and film grain, slowly drifting. A new family cross-fades in.
struct AmbientBackdrop: View {
    let family: GradientFamily

    var body: some View {
        ZStack {
            layers(family).id(family).transition(.opacity)
            Image(nsImage: Grain.tile).resizable(resizingMode: .tile)
                .blendMode(.softLight).opacity(0.55)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func layers(_ f: GradientFamily) -> some View {
        ZStack {
            LinearGradient(stops: [
                .init(color: f.deep.mix(with: .black, by: 0.35), location: 0),
                .init(color: f.deep.mix(with: .black, by: 0.7), location: 0.55),
                .init(color: Color(hex: 0x050505), location: 1),
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
            ZStack {
                EllipticalGradient(stops: [
                    .init(color: f.light.opacity(0.26), location: 0),
                    .init(color: f.mid.opacity(0.26), location: 0.22),
                    .init(color: f.mid.opacity(0.08), location: 0.48),
                    .init(color: .clear, location: 0.8),
                ], center: UnitPoint(x: 0.5, y: -0.05))
                EllipticalGradient(stops: [
                    .init(color: f.mid.opacity(0.22), location: 0),
                    .init(color: .clear, location: 0.6),
                ], center: UnitPoint(x: 0.12, y: 1.05))
            }
            .phaseAnimator([false, true]) { v, far in
                v.scaleEffect(far ? 1.07 : 1.02).offset(x: far ? 18 : -18, y: far ? 10 : -10)
            } animation: { _ in .easeInOut(duration: 16) }
            RadialGradient(colors: [.clear, .black.opacity(0.5)], center: .center, startRadius: 280, endRadius: 1000)
        }
    }
}

/// Film grain: a tile of grey noise, blended soft-light over the gradient so it doesn't look digitally flat.
@MainActor
enum Grain {
    static let tile: NSImage = {
        let px = 256
        let noise = CIFilter.randomGenerator().outputImage?
            .applyingFilter("CIColorControls", parameters: [kCIInputSaturationKey: 0])
            .applyingFilter("CIColorMatrix", parameters: ["inputAVector": CIVector(x: 0, y: 0, z: 0, w: 0),
                                                          "inputBiasVector": CIVector(x: 0, y: 0, z: 0, w: 1)])
            .cropped(to: CGRect(x: 0, y: 0, width: px, height: px)) // after the filters: the alpha bias makes the extent infinite
        guard let noise, let cg = CIContext().createCGImage(noise, from: noise.extent) else { return NSImage() }
        return NSImage(cgImage: cg, size: NSSize(width: px / 2, height: px / 2))
    }()
}
