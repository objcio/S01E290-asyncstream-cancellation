//
//  ContentView.swift
//  Crawler
//
//  Created by Chris Eidhof on 21.12.21.
//

import SwiftUI

@MainActor
struct ContentView: View {
    @State var items: [URL: Page] = [:]
    @State var loading = false
    @State var cancelled = false
    var body: some View {
        VStack {
            Button("Cancel") {
                cancelled = true
            }
            List {
                ForEach(Array(items.keys.sorted(by: { $0.absoluteString < $1.absoluteString })), id: \.self) { url in
                    HStack {
                        Text(url.absoluteString)
                        Text(items[url]!.title)
                    }
                    
                }
            }
            .overlay(
                Text("\(items.count) items")
                    .padding()
                    .background(Color.black.opacity(0.8))
                
            )
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .task(id: cancelled) {
                guard !cancelled else { return }
                await withTaskCancellationHandler(handler: {
                    print("The consumer task got cancelled")
                }) {
                    do {
                        let start = Date()
                        let results = crawl(url: URL(string: "http://localhost:8000/")!, numberOfWorkers: 8)
                        for try await page in results {
                            self.add(page)
                        }
                        let end = Date()
                        print(end.timeIntervalSince(start))
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    func add(_ page: Page) {
        items[page.url] = page
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
