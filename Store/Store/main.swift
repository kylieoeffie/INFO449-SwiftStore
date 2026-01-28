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

    func add(_ sku: SKU) {
        scannedItems.append(sku)
    }

    func items() -> [SKU] {
        return scannedItems
    }

    func total() -> Int {
        var sum = 0
        for sku in scannedItems {
            sum += sku.price()
        }
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

        for sku in scannedItems {
            lines.append("\(sku.name): \(formatPennies(sku.price()))")
        }

        lines.append("------------------")  
        lines.append("TOTAL: \(formatPennies(total()))")

        return lines.joined(separator: "\n")
    }
}

class Register {
    private var receipt: Receipt

    init() {
        receipt = Receipt()
    }

    func scan(_ sku: SKU) {
        receipt.add(sku)
    }

    func subtotal() -> Int {
        return receipt.total()
    }

    func total() -> Receipt {
        let finished = receipt
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

