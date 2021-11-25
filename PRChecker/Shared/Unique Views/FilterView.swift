//
//  FilterView.swift
//  PRChecker
//
//  Created by Chen Yuhan on 2021/11/06.
//

import SwiftUI

struct FilterView: View {
    var body: some View {
        VStack {
            Header()
                .padding(.horizontal, 8)
            Divider()
                .background(Color.gray5)
            FilterContentView()
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 0))
            Spacer()
        }
    }
}

private struct Header: View {
    
    @EnvironmentObject var filterViewModel: FilterViewModel

    var body: some View {
        HStack {
            Label {
                Text("Filter by")
                    .fontWeight(.bold)
            } icon: {
                Image(systemName: "line.3.horizontal.decrease")
                    .scaledToFit()
            }
            .font(.title)
            Spacer()
            Button("Reset") {
                filterViewModel.sections.map(\.filters).flatMap { $0 }.forEach {
                    $0.isEnabled = false
                }
                filterViewModel.sections.forEach { $0.updateFilters() }
                filterViewModel.updateFilters()
            }
            .font(.title3)
            .foregroundColor(.blue)
            .buttonStyle(PlainButtonStyle())
        }
    }
}

private struct FilterContentView: View {
    
    @EnvironmentObject var filterViewModel: FilterViewModel
    
    struct Section: View {
        
        @ObservedObject var filterSection: FilterSection
        let toggleAction: (() -> Void)?
        
        init(filterSection: FilterSection, toggleAction: (() -> Void)? = nil) {
            self.filterSection = filterSection
            self.toggleAction = toggleAction
        }

        var body: some View {
            VStack(alignment: .leading) {
                Label {
                    Text(filterSection.name)
                        .fontWeight(.semibold)
                } icon: {
                    filterSection.type.image
                        .scaledToFit()
                }
                .font(.title2)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(filterSection.filters, id: \.name) { filter in
                        CheckBox(filter: filter) { _ in
                            filterSection.updateFilters()
                            toggleAction?()
                        }
                    }
                }
                .padding(8)
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(filterViewModel.sections, id: \.name) { section in
                    Section(filterSection: section) {
                        filterViewModel.updateFilters()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
    }
}
