//
//  MarqueeView.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 05/02/2024.
//

import SwiftUI

struct SizeCalculator: ViewModifier {
    
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear // we just want the reader to get triggered, so let's use an empty color
                        .onAppear {
                            size = proxy.size
                        }
                }
            )
    }
}

extension View {
    func saveSize(in size: Binding<CGSize>) -> some View {
        modifier(SizeCalculator(size: size))
    }
}

struct MarqueeView: View {
    @State var angle = 0.0
    @State var size: CGSize = .zero
    
    
    var body: some View {
        HStack {
            Button("L") {
                angle -= size.width
            }
            Button("R") {
                angle += size.width
            }
        }
        Text("This is some text that is too long to fit within the view!")
            .padding()
        //            .rotationEffect(.degrees(angle))
            .offset(x: angle, y: 0)
            .animation(.easeIn, value: angle)
//            .fixedSize(horizontal: true, vertical: true)
            .lineLimit(2)

        Text(size.debugDescription)
            .saveSize(in: $size)
    }
}

#Preview {
    MarqueeView()
        .frame(width: 200, height: 50, alignment: .center)
}
