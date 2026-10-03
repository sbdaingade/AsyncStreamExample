//
//  ContentView.swift
//  AsyncStreamExample
//
//  Created by Sachin Daingade on 03/10/26.
//

import SwiftUI
import Combine

class DataProvider {
    
    func getDataAsyncStream() -> AsyncStream<Double> {
        AsyncStream { continuation in
            getDataOldStyle { price in
                continuation.yield(price)
                
              //  continuation.yield(with: .failure(<#T##Failure#>))
              //  continuation.yield(with: .success(<#T##Success#>))
                
                continuation.onTermination = { _  in
                    debugPrint("Handle tear down")
                }
            }
        }
    }
    
   private func getDataOldStyle(completion: @escaping (Double) -> Void) {
        let prices = [1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0]
        for i in 0...prices.count - 1 {
            let price = prices[i]
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(i * 2)) {
                completion(price)
            }
        }
    }
}

@MainActor
class AsyncStreamViewModel: ObservableObject {
    @Published var currentPrice: Double = 0.0
    private let dataProvider = DataProvider()
    
    func getData() async {
        for await price in dataProvider.getDataAsyncStream() {
            self.currentPrice = price
        }
    }
}

struct ContentView: View {
    @StateObject var viewModel = AsyncStreamViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Text("Product Name")
                Spacer()
                Text("Price: $\(viewModel.currentPrice)")
            }
        }.padding(.horizontal, 16)
        
            .task {
                await viewModel.getData()
            }
    }
}

#Preview {
    ContentView()
}
