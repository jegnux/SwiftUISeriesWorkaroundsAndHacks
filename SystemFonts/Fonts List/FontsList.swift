//
//  SystemFonts
//
//  Created by Jérôme Alves on 23/05/2022.
//

import SwiftUI

struct FontsList: View {
    
    static let fonts: [UIFont] = UIFont.familyNames.compactMap { familyName in
        UIFont.fontNames(forFamilyName: familyName).first.flatMap { fontName in
            UIFont(name: fontName, size: 16)
        }
    }
    
    @State var query = ""
    @StateObject var contentOffsetSynchronizer = ContentOffsetSynchronizer()
    @StateObject var widthStore = WidthsStore()

    var fonts: [UIFont] {
        guard query.isEmpty == false else {
            return Self.fonts
        }
        return Self.fonts.filter { $0.familyName.localizedCaseInsensitiveContains(query) || $0.fontName.localizedCaseInsensitiveContains(query) }
    }
    var body: some View {
        List {
            ForEach(fonts, id: \.familyName) { font in
                FontView(font: font)
            }
        }
        .searchable(text: $query)
        .listStyle(.plain)
        .navigationTitle("System Fonts")
        .environmentObject(contentOffsetSynchronizer)
        .environmentObject(widthStore)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FontsList()
        }
    }
}
