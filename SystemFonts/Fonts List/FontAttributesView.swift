//
//  SystemFonts
//
//  Created by Jérôme Alves on 23/05/2022.
//

import SwiftUI

struct FontAttributesView: View {
    
    let attributes: [(key: String, value: String)]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(attributes, id: \.key) { key, value in
                    VStack(alignment: .leading) {
                        Text(key)
                            .font(.footnote.weight(.semibold))
                        Text(value)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .syncWidth(key: key)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                }
            }
            .syncContentOffset()
        }
    }
}


