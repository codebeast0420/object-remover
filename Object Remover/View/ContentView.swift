//
//  ContentView.swift
//  Object Remover
//
//  Created by ZhangTong on 2023/9/26.
//

import SwiftUI
import PhotosUI

enum pickerType {
    case photoLibrary, camera
}

struct ContentView: View {
    @ObservedObject var appSettings: AppSettings
    @State var isImagePickerPresented = false
    @State var imagePickerType = pickerType.photoLibrary
    @State var selectedImage: UIImage?
    
    var body: some View {
        NavigationView {
            ZStack{
                NavigationLink(destination: MainView(image: $selectedImage, appSettings: appSettings), isActive: .constant((selectedImage != nil))) {
                        EmptyView()
                    }
                
                VStack{
                    Spacer()
                    
                    HomeContentButton(isImagePickerPresented: $isImagePickerPresented, imagePickerType: $imagePickerType, appSettings: appSettings)
                        .frame(height: 168)
                }
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePickerView(image: $selectedImage, isPresented: $isImagePickerPresented)
            }
            .onAppear{
                NetworkManager.shared.accessBaidu()
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct HomeContentButton: View{
    @Binding var isImagePickerPresented: Bool
    @Binding var imagePickerType: pickerType
    @ObservedObject var appSettings: AppSettings
    
    var body: some View{
        Button(action: {
            isImagePickerPresented = true
            imagePickerType = .photoLibrary
        }) {
            VStack{
                HStack(spacing: 2){
//                    Image("Icons_plus")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 24, height: 24)
                    Text("Selecte Photo")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineSpacing(26)
                }
                .font(.system(size: 18))
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "9221F6"))
            .cornerRadius(.infinity)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let appSettings = AppSettings()
        ContentView(appSettings: appSettings)
    }
}
