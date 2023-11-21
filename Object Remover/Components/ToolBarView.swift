import SwiftUI
import Combine


struct ToolBarView: View {
    @Binding var selectedTab: Tab
    @EnvironmentObject var vm: CZImageEditorViewModel
    // Inpaint function
    @Binding var strokeWidth: CGFloat
    @Binding var startInpainting: Bool
    @Binding var didChange: PassthroughSubject<String, Never>
    
    // Crop function
    @Binding var imageCropperShow: Bool
    
    // Adjust funtion
    @Binding var selectedOption: EditOption?
    var fetchOptionPercentValue: (EditOption) -> Double
    
    // Face Mask
    @State private var facesArray: [(image: UIImage, frame: CGRect)] = []
    @State private var faceNotFoundAlert = false
    
    // photo filters

    var body: some View {
        ZStack {
            HStack {

                Button(action: {
                    selectedTab = .crop
                    imageCropperShow = true
                }) {
                    Text("Crop&Roate")
                }
                .foregroundColor(selectedTab == .crop ? .blue : .black)

//                Button(action: {
//                    selectedTab = .rotate
//                }) {
//                    Text("Rotate")
//                }
//                .foregroundColor(selectedTab == .rotate ? .blue : .black)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(.white)
            .offset(y: selectedTab != .none ? 100 : 0)
            .animation(.easeInOut)
            
            CropView(selectedTab: $selectedTab, imageCropperShow: $imageCropperShow)
                .frame(height: 160)
                .background(.orange)
                .offset(y: selectedTab == .crop ? 0 : 160)
                .animation(.easeInOut)
            
        }
        .alert(isPresented: $faceNotFoundAlert) {
            Alert(title: Text("Alert"), message: Text("No face detected inside the image."), dismissButton: .default(Text("OK")))
        }
    }
}



struct CropView: View {
    @Binding var selectedTab: Tab
    @Binding var imageCropperShow: Bool
    @EnvironmentObject var vm: CZImageEditorViewModel
    @State private var selectedTabCrop = "crop"
    var body: some View {
        VStack(spacing: 10){
            HStack{
                Button(action: {
                    vm.targetImage = vm.originImage
                    selectedTab = .none
                }, label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                })
                
                Spacer()
                
                HStack (spacing: 30){
                    Button(action: {
                        selectedTabCrop = "crop"
                    }, label: {
                        Image(systemName: "crop")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    })
                    
                    Button(action: {
                        selectedTabCrop = "rotate"
                    }, label: {
                        Image(systemName: "rectangle.portrait.rotate")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    })
                }
                
                
                Spacer()
                
                Button(action: {
                    vm.originImage = vm.targetImage
                    selectedTab = .none
                }, label: {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                })
            }
            
            
            if selectedTabCrop == "crop" {
                ScrollView(.horizontal) {
                    HStack(spacing: 30){
                        ForEach(cropOptions.allCases, id: \.self){
                            selectedRatio in
                            VStack{
                                Image(systemName: "rectangle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                
                                Text(selectedRatio.rawValue)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                }
            }
            
            else {
                ScrollView(.horizontal) {
                    HStack(spacing: 30){
                        ForEach(rotateOptions.allCases, id: \.self){
                            selectedRotation in
                            VStack{
                                Image(systemName: selectedRotation.systemImageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                
                                Text(selectedRotation.rawValue)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                }
            }
            
        }
    }
}


enum cropOptions: String,  CaseIterable{
    case original = "original" // Keep aspect ratio
    case customize = "customize"  // no ratio restrition
    case rectangle = "rectangle"  // width：height = 1:1
    case ratio23  = "2:3"  // 2:3
    case ratio32 = "3:2" // 3:2
    case ratio34 = "3:4" // 3:4
    case ratio43 = "4:3"  // 4:3
    case ratio916 = "9:16"  // 9:16
    case ratio169 = "16:9" // 16:9
}


enum rotateOptions: String,  CaseIterable{
    case flipV = "Vertical" // Flip Vertically
    case flipH = "Horiztonal"  // Flip Horizontal
    case rotateL = "Rotate Left"  // rotate 90 degree left
    case rotateR  = "Rotate Right"  // rotate 90 degree right
    
    var systemImageName: String {
        switch self {
        case .flipV:
            return "arrow.up.and.down.righttriangle.up.righttriangle.down"
        case .flipH:
            return "arrow.left.and.right.righttriangle.left.righttriangle.right"
        case .rotateL:
            return "rotate.left"
        case .rotateR:
            return "rotate.right"
        }
    }
}
