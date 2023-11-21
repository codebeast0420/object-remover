//
//  Utils.swift
//  Avatarly
//
//  Created by ZhangTong on 2023/8/27.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(red: Double(r) / 0xff, green: Double(g) / 0xff, blue: Double(b) / 0xff)
    }
}

extension View {
    
    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }
    
    func shadowedStyle() -> some View {
        self
            .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 0)
            .shadow(color: .black.opacity(0.16), radius: 24, x: 0, y: 0)
    }
    
    func customButtonStyle(
        foreground: Color = .black,
        background: Color = .white
    ) -> some View {
        self.buttonStyle(
            ExampleButtonStyle(
                foreground: foreground,
                background: background
            )
        )
    }

#if os(iOS)
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
#endif
}

private struct ExampleButtonStyle: ButtonStyle {
    let foreground: Color
    let background: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.45 : 1)
            .foregroundColor(configuration.isPressed ? foreground.opacity(0.55) : foreground)
            .background(configuration.isPressed ? background.opacity(0.55) : background)
    }
}

#if os(iOS)
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
#endif

func actionSheet(shareLink: String) {
    guard let urlShare = URL(string: shareLink) else { return }
    let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
    UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
}



func RedirectWebURL(_URL: String) {
    guard let url = URL(string: _URL), UIApplication.shared.canOpenURL(url) else{
        return
    }
    UIApplication.shared.open(url as URL)
}

enum ImgUploadStatus: String {
    case uploading
    case failed
    case fetching
    case imageNotFound
    case success
    case none
    case timeout

    var stringVal: String {
        switch self {
        case .uploading: return "Uploading your image"
        case .failed: return "Can not access the network. Please check it and restart the app."
        case .fetching: return "Preparing your avatars"
        case .success: return "Your avatars are ready"
        case .imageNotFound: return "Sorry but it could not generate the results again. Please reupload your photos"
        case .none: return ""
        case .timeout: return "Sorry but it takes more time for generating avatars than before. Please try our services later."
        }
    }
    
    var colorVal: String {
        switch self {
        case .uploading: return "3441BE"
        case .failed: return "FFB93D"
        case .success: return "3441BE"
        case .none: return "3441BE"
        case .imageNotFound: return "3441BE"
        case .fetching: return "3441BE"
        case .timeout: return "3441BE"
        }
    }
    
    var iconVal: String {
        switch self {
        case .uploading: return "checkmark"
        case .failed: return "wifi.slash"
        case .success: return "checkmark"
        case .none: return "checkmark"
        case .imageNotFound: return "checkmark"
        case .fetching: return "checkmark"
        case .timeout: return "rays"
        }
    }
}


enum ImgDownloadStatus: String {
    case downloading
    case failed
    case downloaded
    case none
    case hdprocessing
    case timeout

    var stringVal: String {
        switch self {
        case .downloading: return "Downloading your avatar picture"
        case .failed: return "There are some issues when downloading, please check your network."
        case .downloaded: return "Download your avatar successfully."
        case .none: return ""
        case .hdprocessing: return "Preparing HD avatar picture"
        case .timeout: return "Sorry but it takes more time for generating avatars than before. Please try our services later."
        }
    }
    
    var colorVal: String {
        switch self {
        case .downloading: return "3441BE"
        case .failed: return "FFB93D"
        case .downloaded: return "3441BE"
        case .none: return "3441BE"
        case .hdprocessing: return "3441BE"
        case .timeout: return "3441BE"
        }
    }
    
    var iconVal: String {
        switch self {
        case .downloading: return "checkmark"
        case .failed: return "wifi.slash"
        case .downloaded: return "checkmark"
        case .none: return "checkmark"
        case .hdprocessing: return ""
        case .timeout: return ""
        }
    }
}

struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
}

extension View {
    func pressAction(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressActions(onPress: {
            onPress()
        }, onRelease: {
            onRelease()
        }))
    }
}
