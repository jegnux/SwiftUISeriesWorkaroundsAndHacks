//
//  SystemFonts
//
//  Created by Jérôme Alves on 23/05/2022.
//

import SwiftUI

struct FontView: View {
    let font: UIFont

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(font.familyName).font(.headline)
            FontAttributesView(attributes: [
                (key: "Font Name",   value: font.fontName),
                (key: "Point Size",  value: String(format: "%.2fpt", font.pointSize)),
                (key: "Ascender",    value: String(format: "%.2fpt", font.ascender)),
                (key: "Descender",   value: String(format: "%.2fpt", font.descender)),
                (key: "Leading",     value: String(format: "%.2fpt", font.leading)),
                (key: "Cap Height",  value: String(format: "%.2fpt", font.capHeight)),
                (key: "x Height",    value: String(format: "%.2fpt", font.xHeight)),
                (key: "Line Height", value: String(format: "%.2fpt", font.lineHeight)),
            ])
        }
        .padding(4)
    }
}
