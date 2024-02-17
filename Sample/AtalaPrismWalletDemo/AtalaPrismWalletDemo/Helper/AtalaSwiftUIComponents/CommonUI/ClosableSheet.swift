//
//  ClosableSheet.swift
//  prism-ios-wallet
//
//  Created by Goncalo Frade IOHK on 26/09/2021.
//

import SwiftUI

struct ClosableSheet<SheetContent: View>: View {
    @Environment(\.presentationMode) var presentationMode
    @ViewBuilder let content: () -> SheetContent

    var body: some View {
        VStack(spacing: 16) {
            content()
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Image("ico_close_red")
            })
        }
    }
}

struct ClosableSheet_Previews: PreviewProvider {
    static var previews: some View {
        ClosableSheet(content: {
            Text("")
        })
    }
}
