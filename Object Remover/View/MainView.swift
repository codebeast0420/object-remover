//
//  MainView.swift
//  Object Remover
//
//  Created by ZhangTong on 2023/10/14.
//

import SwiftUI
import Combine

enum Tab {
    case inpaint, crop, rotate, adjust, enhance, effect, mask, filters, none
}


struct MainView: View {
    
    @Binding var selectedImage: UIImage?
    @State var parameters = ImageEditorParameters()
    @ObservedObject var appSettings: AppSettings
    
    @State var selectedTab: Tab = .none
    // inpaint mask
    @State var strokeWidth = CGFloat(20)
    @State var startInpainting = false
    @State var didChange = PassthroughSubject<String, Never>()
    
    // cropping feature
    @State var cropperShown = false
    
    // filters and adjust
    @State private var savedImageEditorParameters = ImageEditorParameters()
    @State private var yourOwnFilters: [CIFilter] = []
    @StateObject private var vm = CZImageEditorViewModel()
    let filters: [CIFilter]
    let filterNameFont: Font
    let thumbnailMaxSize: CGFloat
    let localizationPrefix: String
    let actionWhenConfirm: (() -> Void)?
    @State private var selectedEditOption: EditOption? = .brightness
    @State private var showOriginalImage = false  // show original image to compare
    
    
    
    init(image: Binding<UIImage?>, appSettings: AppSettings,
         filters: [CIFilter] = [],
         filterNameFont: Font = .caption2,
         thumbnailMaxSize: CGFloat = 5000,
         localizationPrefix: String = "",
         actionWhenConfirm: (() -> Void)? = nil )
    {
        self._selectedImage = image
        self.appSettings = appSettings
        
        self.filters = filters
        self.filterNameFont = filterNameFont
        self.thumbnailMaxSize = thumbnailMaxSize
        self.localizationPrefix = localizationPrefix
        self.actionWhenConfirm = actionWhenConfirm
    }
    
    var body: some View {
        ZStack{
            if changesWereMade || vm.CompareFlag {
                Color.clear
                    .overlay { Image(uiImage: (selectedImage ?? vm.originImage)!)
                            .resizable()
                            .scaledToFit()
                            .opacity(showOriginalImage ? 1 : 0) }
            }
            
            Color.clear
                .overlay { Image(uiImage: (vm.targetImage ?? selectedImage)!)
                        .resizable()
                        .scaledToFit()
                        .opacity(showOriginalImage ? 0 : 1) }
            
            
            
            VStack{
                if selectedImage != nil {
                    Text("\(Int((vm.targetImage ?? selectedImage)!.size.width)) * \(Int((vm.targetImage ?? selectedImage)!.size.height))")
                }
               
                Spacer()
                ToolBarView(selectedTab: $selectedTab, strokeWidth: $strokeWidth, startInpainting: $startInpainting, didChange: $didChange, imageCropperShow: $cropperShown, selectedOption: $selectedEditOption, fetchOptionPercentValue: fetchOptionPercentValue)
//                    .frame(height: 100)
                    .background(.black.opacity(0.4))
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .environmentObject(vm)
        .fullScreenCover(isPresented: $cropperShown){
            ImageCropperView(isShowing: $cropperShown, image: $vm.targetImage, cropShapeType: .rect, presetFixedRatioType: .canUseMultiplePresetFixedRatio())
                .ignoresSafeArea(edges: .bottom)
            ToolBarView(selectedTab: $selectedTab, strokeWidth: $strokeWidth, startInpainting: $startInpainting, didChange: $didChange, imageCropperShow: $cropperShown, selectedOption: $selectedEditOption, fetchOptionPercentValue: fetchOptionPercentValue)
        }
        .onDisappear {
            print("DetailView disappeared!")
            self.selectedImage = nil
            vm.CompareFlag = false
        }
        .onChange(of: vm.editingValue) { newValue in
            setValueToOption(value: newValue, option: selectedEditOption ?? .brightness)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing){
                HStack(spacing: 24){
                    Text("Discard")
                    
                   Text("Compare")
                        .opacity((changesWereMade || vm.CompareFlag) ? 1 : 0)
                    .pressAction {
                        showOriginalImage = true
                    } onRelease: {
                        showOriginalImage = false
                    }
                    
                    Button(action: {
                        // Save
                        saveToPhotoLibrary(image: vm.targetImage)
                    }, label: {
                        Text("Save")
                    })
                }
            }
        }
        .task {
            await vm.initializeVM(fullImage: (parameters.fullOriginalImage ?? selectedImage)!, parameters: parameters,filters: filters,thumbnailMaxSize: thumbnailMaxSize)
        }
    }
    
    private func saveToPhotoLibrary(image: UIImage?) {
        guard let image = image else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    
    private func setValueToOption(value: Double, option: EditOption) {
        switch option {
        case .rotation:
            vm.rotationPercent = (value * 2 + 180)/360
        case .brightness:
            vm.brightnessPercent = (value + 100)/200
        case .contrast:
            vm.contrastPercent = (value + 100)/200
        case .saturation:
            vm.saturationPercent = (value + 100)/200
        case .sharpen:
            vm.sharpenPercent = (value + 100)/200
        case .warmth:
            vm.warmthPercent = (value + 100)/200
        case .vignette:
            vm.vignettePercent = value / 100
        case .vibrance:
            vm.vibrancePercent = (value + 100)/200
        case .exposure:
            vm.exposurePercent = (value + 100)/200
        case .clarity:
            vm.clarityPercent = (value + 100)/200
        }
        vm.applyFiltersToTarget()
    }
    
    
    private func fetchOptionPercentValue(option: EditOption) -> Double {
        switch option {
        case .rotation: return vm.rotationPercent
        case .brightness: return vm.brightnessPercent
        case .contrast: return vm.contrastPercent
        case .saturation: return vm.saturationPercent
        case .sharpen: return vm.sharpenPercent
        case .warmth: return vm.warmthPercent
        case .vignette: return vm.vignettePercent
        case .vibrance:  return vm.vibrancePercent
        case .exposure: return vm.exposurePercent
        case .clarity:return vm.clarityPercent
        }
    }
    
    private var changesWereMade: Bool {
        return vm.outputAttributes() != ImageEditorParameters.Attributes.init()
    }
    private var changesWereMadeThisTime: Bool {
        return vm.outputAttributes() != parameters.attributes
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let appSettings = AppSettings()
        MainView(image:.constant(UIImage(contentsOfFile: "intro-image")), appSettings: appSettings)
    }
}

