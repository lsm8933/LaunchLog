//
//  SeeMoreTextView.swift
//  LaunchLog
//
//  Created by Jing Li on 1/30/25.
//

import SwiftUI

struct SeeMoreTextView: View {
    let text: String
    @State var truncatedText: String
    
    @State var isTruncationNeeded = false
    @State var isExpanded = false
    
    let linelimit: Int
    // use UIFont for NSAttributedString.
    let font: UIFont
    
    init(text: String, linelimit: Int, font: UIFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body) ) {
        self.text = text
        self.truncatedText = text
        self.linelimit = linelimit
        self.font = font
    }
    
    var moreLessText: String {
        if !isTruncationNeeded {
            return ""
        } else if isExpanded {
            return " see less"
        } else {
            return " ... see more"
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                Text(!isTruncationNeeded ? text : isExpanded ? text: truncatedText) +
                Text(moreLessText)
                    .foregroundStyle(Color.blue)
                    .bold()
            }.font(Font(font))
                .background {
                    Text(text)
                        .font(Font(font))
                        .lineLimit(linelimit)
                        .hidden()
                        .background {
                            GeometryReader { proxy in
                                Color.clear.onAppear {
                                    let attributes = [NSAttributedString.Key.font: font]
                                    
                                    // Binary search to decide truncatedText.
                                    var st = 0
                                    var ed = truncatedText.count
                                    
                                    while st + 1 < ed {
                                        let md = (st + ed) / 2
                                        truncatedText = String(text.prefix(md))
                                        
                                        let attributedString = NSAttributedString(string: truncatedText + moreLessText, attributes: attributes)
                                        let boundingRect = attributedString.boundingRect(with: CGSize(width: proxy.size.width, height: .greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
                                        
                                        if boundingRect.height > proxy.size.height {
                                            isTruncationNeeded = true
                                            ed = md
                                        } else { // find the last position that matches target height
                                            st = md
                                        }
                                    }
                                    
                                    // even though we are binary searching for the last position of target, given the estimated (not accurate) nature of NSAttributedString.boundingRect, there is no need to compare st and ed (st + 1), because they give very similiar estimated results.
                                    if st >= 2 {
                                        truncatedText = String(text.prefix(st - 4))
                                    } else {
                                        truncatedText = ""
                                    }
                                }
                            }
                        }
                }
            
            // tapping on the last line will toggle isExpanded.
            Button {
                self.isExpanded.toggle()
            } label: {
                HStack {
                    Spacer()
                    Text("")
                }
            }
        }
    }
}

#Preview {
    SeeMoreTextView(text: "The National Aeronautics and Space Administration is an independent agency of the executive branch of the United States federal government responsible for the civilian space program, as well as aeronautics and aerospace research. NASA have many launch facilities but most are inactive. The most commonly used pad will be LC-39B at Kennedy Space Center in Florida.", linelimit: 4, font: UIFont.systemFont(ofSize: 26))
}
