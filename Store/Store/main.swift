import Foundation

protocol SKU {
    var name: String { get }
    func price() -> Int
}

class Item: SKU {
    let name: String
    private let priceEach: Int

    init(name: String, priceEach: Int) {
        self.name = name
        self.priceEach = priceEach
    }

    func price() -> Int {
        return priceEach
    }
}

class Receipt {
    private var scannedItems: [SKU] = []
    private var twoForOneNames: Set<String> = []
    private var couponNames: [String: Int] = [:] // name -> number of coupons

    func add(_ sku: SKU) {
        scannedItems.append(sku)
    }

    func items() -> [SKU] {
        return scannedItems
    }

    func setTwoForOne(names: Set<String>) {
        self.twoForOneNames = names
    }

    func addCoupon(forName name: String) {
        couponNames[name, default: 0] += 1
    }

    private func adjustedPrices() -> [Int] {
        var prices = scannedItems.map { $0.price() }
        var indicesByName: [String: [Int]] = [:]
        for (idx, sku) in scannedItems.enumerated() {
            indicesByName[sku.name, default: []].append(idx)
        }
        for name in twoForOneNames {
            if let indices = indicesByName[name] {
                var freeCount = indices.count / 3
                if freeCount > 0 {
                    for (i, idx) in indices.enumerated() {
                        if (i + 1) % 3 == 0 && freeCount > 0 {
                            prices[idx] = 0
                            freeCount -= 1
                        }
                    }
                }
            }
        }
        for (name, count) in couponNames {
            if let indices = indicesByName[name], count > 0 {
                var remaining = count
                for idx in indices {
                    if remaining == 0 { break }
                    let p = prices[idx]
                    let discount = Int((Double(p) * 0.15).rounded())
                    prices[idx] = p - discount
                    remaining -= 1
                }
            }
        }
        return prices
    }

    func total() -> Int {
        let prices = adjustedPrices()
        var sum = 0
        for p in prices { sum += p }
        return sum
    }

    private func formatPennies(_ pennies: Int) -> String {
        let dollars = pennies / 100
        let cents = pennies % 100
        return String(format: "$%d.%02d", dollars, cents)
    }

    func output() -> String {
        var lines: [String] = []
        lines.append("Receipt:")
        let prices = adjustedPrices()
        for (idx, sku) in scannedItems.enumerated() {
            lines.append("\(sku.name): \(formatPennies(prices[idx]))")
        }
        lines.append("------------------")  
        lines.append("TOTAL: \(formatPennies(total()))")
        return lines.joined(separator: "\n")
    }
}

class Register {
    private var receipt: Receipt
    private var twoForOne: Set<String> = []

    init() {
        receipt = Receipt()
    }

    func scan(_ sku: SKU) {
        receipt.add(sku)
    }

    func enableTwoForOne(forName name: String) {
        twoForOne.insert(name)
    }

    func applyCoupon(forName name: String) {
        receipt.addCoupon(forName: name)
    }

    func subtotal() -> Int {
        receipt.setTwoForOne(names: twoForOne)
        return receipt.total()
    }

    func total() -> Receipt {
        let finished = receipt
        finished.setTwoForOne(names: twoForOne)
        receipt = Receipt()
        return finished
    }
}

class Store {
    let version = "0.1"
    func helloWorld() -> String {
        return "Hello world"
    }
}

