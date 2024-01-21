//
//  ContentView.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 14/01/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
      ZStack {
        MetalView()
      }.ignoresSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
