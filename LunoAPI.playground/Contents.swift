//
// Author: Manenga Mungandi
// Luno Public API
// Ref: https://www.luno.com/en/developers/api
//

import UIKit
import PlaygroundSupport

enum Pairs { case XBTZAR; case ETHXBT; case XBTETH; case ETHZAR; case all; case XBTZMW; }
enum TimePeriod { case day; case week; case month; case quarter; case year; case allTime }
enum Currency { case ZAR; case ETH; case BTC; case BCH; }

var debug = false

var ETHBalance = "8.40515801"
var BTCBalance = "0.00007222"
var ZARBalance = "69.289726"

var ETHZARAsk = "3382.00"
var XBTZARAsk = "167201.00"
var ETHXBTAsk = "0.0202"

var ETHZARBid = "3375.00"
var XBTZARBid = "167200.00"
var ETHXBTBid = "0.0201"

protocol Mappable: Codable {
    init?(jsonString: String)
}

extension Mappable {
    init?(jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        self = try! JSONDecoder().decode(Self.self, from: data)
        // I used force unwrap for simplicity.
        // It is better to deal with exception using do-catch.
    }
}

// MARK: Market data

struct AllTickers: Codable {
    var tickers: [Ticker]!
}

struct TransactionsGroup: Codable {
    var id: String!
    var isDefault: Bool!
    var transactions: [Transaction]!
}

struct AllBalances: Codable {
    var balance: [Balance]!
}

struct TradesGroup: Codable {
    var trades: [Trade]!
}

struct Balance: Codable {
    var accountId: String!
    var asset: String!
    var balance: String!
    var reserved: String!
    var unconfirmed: String!
    
    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case asset; case balance; case reserved; case unconfirmed;
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        asset = try values.decode(String.self, forKey: .asset)
        balance = try values.decode(String.self, forKey: .balance)
        reserved = try values.decode(String.self, forKey: .reserved)
        accountId = try values.decode(String.self, forKey: .accountId)
        unconfirmed = try values.decode(String.self, forKey: .unconfirmed)
    }
}

struct Transaction: Codable {
    var accountId: String!
    var available: Float!
    var availableDelta: Float?
    var balance: Float!
    var balanceDelta: Float?
    var currency: String!
    var descriptionField: String!
    var rowIndex: Int!
    var timestamp: Date!
    
    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"; case availableDelta = "available_delta";
        case available; case timestamp; case balance; case currency; case rowIndex = "row_index";
        case balanceDelta = "balance_delta"; case descriptionField = "description";
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        accountId = try values.decode(String.self, forKey: .accountId)
        rowIndex = try values.decode(Int.self, forKey: .rowIndex)
        currency = try values.decode(String.self, forKey: .currency)
        balance = try values.decode(Float.self, forKey: .balance)
        available = try values.decode(Float.self, forKey: .available)
        balanceDelta = try values.decode(Float.self, forKey: .balanceDelta)
        availableDelta = try values.decode(Float.self, forKey: .availableDelta)
        descriptionField = try values.decode(String.self, forKey: .descriptionField)
        
        let unixTimestamp = try values.decode(Int.self, forKey: .timestamp)
        let unixTimestampString = String(unixTimestamp)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss dd-MMM-yyyy"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let time = formatter.date(from: unixTimestampString) else { return }
        timestamp = time
    }
}

struct Trade: Codable {
    var base: String?
    var counter: String?
    var feeBase: String?
    var feeCounter: String?
    var isBuy: Bool! = false
    var orderId: String!
    var pair: String!
    var price: String!
    var sequence: Int!
    var timestamp: Date!
    var type: String!
    var volume: String!
    
    enum CodingKeys: String, CodingKey {
        case feeBase = "fee_base"; case feeCounter = "fee_counter"; case timestamp;
        case base; case counter; case pair; case price; case sequence; case type;
        case isBuy = "is_buy"; case orderId = "order_id"; case volume;
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        base = try values.decode(String.self, forKey: .base)
        counter = try values.decode(String.self, forKey: .counter)
        feeBase = try values.decode(String.self, forKey: .feeBase)
        feeCounter = try values.decode(String.self, forKey: .feeCounter)
        isBuy = try values.decode(Bool.self, forKey: .isBuy)
        orderId = try values.decode(String.self, forKey: .orderId)
        pair = try values.decode(String.self, forKey: .pair)
        price = try values.decode(String.self, forKey: .price)
        sequence = try values.decode(Int.self, forKey: .sequence)
        type = try values.decode(String.self, forKey: .type)
        volume = try values.decode(String.self, forKey: .volume)
        
        let unixTimestamp = try values.decode(Int.self, forKey: .timestamp)
        let unixTimestampString = String(unixTimestamp)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss dd-MMM-yyyy"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let time = formatter.date(from: unixTimestampString) else { return }
        timestamp = time
    }
}

struct Ticker: Codable {
    var ask: String! = "0.0"
    var bid: String! = "0.0"
    var lastTrade: String! = "0.0"
    var pair: String! = ""
    var rolling24HourVolume : String! = "0.0000"
    var status: String! = "ACTIVE"
    var timestamp: Date! = Date()
    var timestampString: String! = ""
    
    enum CodingKeys: String, CodingKey {
        case ask; case bid; case pair; case status; case timestamp;
        case lastTrade = "last_trade"; case rolling24HourVolume = "rolling_24_hour_volume";
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        ask = try values.decode(String.self, forKey: .ask)
        bid = try values.decode(String.self, forKey: .bid)
        pair = try values.decode(String.self, forKey: .pair)
        lastTrade = try values.decode(String.self, forKey: .lastTrade)
        rolling24HourVolume = try values.decode(String.self, forKey: .rolling24HourVolume)
        
        let unixTimestamp = try values.decode(Int.self, forKey: .timestamp)
        let unixTimestampString = String(unixTimestamp)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss dd-MMM-yyyy"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let time = formatter.date(from: unixTimestampString) else { return }
        timestamp = time
        timestampString = formatter.string(from: time)
    }
    
    mutating func flip() {
        
        guard let askNum = Double(ask) else { return }
        guard let bidNum = Double(bid) else { return }
        guard let lastTradeNum = Double(lastTrade) else { return }
        
        ask = "\(round(1.0 / askNum)) ETH per BTC"
        bid = "\(round(1.0 / bidNum)) ETH per BTC"
        lastTrade = "\(round(1.0 / lastTradeNum)) ETH"
        rolling24HourVolume = "\(rolling24HourVolume!) ETH"
        
    }
}

func printTicker(_ ticker: Ticker) {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss dd-MMM-yyyy"
    
    switch ticker.pair {
    case "ETHXBT":
        ETHXBTBid = ticker.bid
        ETHXBTAsk = ticker.ask
    case "XBTZAR":
        XBTZARBid = ticker.bid
        XBTZARAsk = ticker.ask
    case "ETHZAR":
        ETHZARBid = ticker.bid
        ETHZARAsk = ticker.ask
    default:
        return
    }
    
    print("Pair: \(ticker.pair!) as at \(formatter.string(from: ticker.timestamp))")
    print("Ask: \(ticker.ask!)")
    print("Bid: \(ticker.bid!)")
    print("Last Trade: \(ticker.lastTrade!)")
    print("24hr trading Volume: \(ticker.rolling24HourVolume!)")
    print()
}

func printBalance(_ balance: Balance) {
    print("Account: \(balance.asset!)")
    print("Balance: \(balance.balance!)")
    print("Reserved: \(balance.reserved!)")
    print("Unconfirmed: \(balance.unconfirmed!)")
    print()
}

func printTrade(_ trade: Trade) {
    let formatter = DateFormatter()
    let type = trade.isBuy ? "Bought" : "Sold"
    formatter.dateFormat = "HH:mm:ss dd-MMM-yyyy"
    print("\(type) \(trade.volume ?? "") at \(trade.price ?? "")")
}

func printTransaction(_ trnx: Transaction) {
    print("\(trnx.rowIndex!). Description: \(trnx.descriptionField!)")
}

func displayTicker(data: Data, pair: Pairs) {
    do {
        let multiple: Bool = pair == .all ? true : false
        let showInverse = pair == .XBTETH ? true : false
        
        if (multiple) {
            let root = try JSONDecoder().decode(AllTickers.self, from: data)
            let tickers: [Ticker] = root.tickers
            
            if (debug) { print(tickers) }
            for ticker in tickers {
                printTicker(ticker)
            }
        } else {
            var ticker = try JSONDecoder().decode(Ticker.self, from: data)
            
            if showInverse {
                ticker.flip()
                ticker.pair = "XBTETH"
            }
            
            if (debug) { print(ticker) }
            printTicker(ticker)
        }
    } catch { print(error) }
}

func getCurrentPrice(pair: Pairs) {
    var url = URL(string: "https://api.mybitx.com/api/1/ticker?pair=\(pair)")!
    
    if (pair == .all) {
        url = URL(string: "https://api.mybitx.com/api/1/tickers")!
    } else if (pair == .XBTETH) {
        url = URL(string: "https://api.mybitx.com/api/1/ticker?pair=ETHXBT")!
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print(error ?? "Unknown error")
            return
        }
        
        if (debug) {
            guard let contents = String(data: data, encoding: .utf8) else { return }
            print(contents)
        }
        
        displayTicker(data: data, pair: pair)
        }.resume()
    
    PlaygroundPage.current.needsIndefiniteExecution = true
}

// MARK: Orders

func viewOrderbookTop(pair: Pairs) {
    let url = URL(string: "https://api.mybitx.com/api/1/orderbook_top?pair=\(pair)")!
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print(error ?? "Unknown error")
            return
        }
        
        guard let contents = String(data: data, encoding: .utf8) else { return }
        print(contents)
        }.resume()
    
    PlaygroundPage.current.needsIndefiniteExecution = true
}

func viewOrderbook(pair: Pairs) {
    let url = URL(string: "https://api.mybitx.com/api/1/orderbook?pair=\(pair)")!
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print(error ?? "Unknown error")
            return
        }
        
        guard let contents = String(data: data, encoding: .utf8) else { return }
        print(contents)
        }.resume()
    
    PlaygroundPage.current.needsIndefiniteExecution = true
}

// MARK: Trades

func viewPublicTrades(pair: Pairs) {
    let url = URL(string: "https://api.mybitx.com/api/1/trades?pair=\(pair)")!
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print(error ?? "Unknown error")
            return
        }
        
        guard let contents = String(data: data, encoding: .utf8) else { return }
        if debug { print(contents) }
        }.resume()
    
    PlaygroundPage.current.needsIndefiniteExecution = true
}

func getRequest(_ myUrl: URL) -> URLRequest {
    let username = ""
    let password = ""
    let loginString = String(format: "%@:%@", username, password)
    let loginData = loginString.data(using: String.Encoding.utf8)!
    let base64LoginString = loginData.base64EncodedString()
    
    var request = URLRequest(url: myUrl)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
    
    return request
}

func checkBalance() {
    print("==== ACCOUNT BALANCE SUMMARY ====\n\n")
    let url = URL(string: "https://api.mybitx.com/api/1/balance")!
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let task = session.dataTask(with: getRequest(url), completionHandler: {data, response, error -> Void in
        guard let data = data, error == nil else {
            print(error ?? "Unknown error")
            return
        }
        
        guard let contents = String(data: data, encoding: .utf8) else { return }
        do {
            let root = try JSONDecoder().decode(AllBalances.self, from: data)
            let balances: [Balance] = root.balance
            
            if (debug) { print(contents); print(balances) }
            
            for item in balances {
                printBalance(item)
            }
        } catch { print(error) }
        
    })
    task.resume()
    
    PlaygroundPage.current.needsIndefiniteExecution = true
}

func viewTransactions(currency: Currency) {
    let min = 1; let max = 1000
    var accountId = ""
    
    switch currency {
    case .ZAR:
        accountId = "6984086266635340069"
    case .ETH:
        accountId = "5308627079239984697"
    case .BTC:
        accountId = "8871588127069506905"
    case .BCH:
        accountId = "6501574460433221823"
    }
    
    let urlStr = "https://api.mybitx.com/api/1/accounts/\(accountId)/transactions?min_row=\(min)&max_row=\(max)"
    let url = URL(string: urlStr)!
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let task = session.dataTask(with: getRequest(url), completionHandler: {data, response, error -> Void in
        guard let data = data, error == nil else {
            print(error ?? "Unknown error")
            return
        }
        
        guard let contents = String(data: data, encoding: .utf8) else { return }
        do {
            let root = try JSONDecoder().decode(TransactionsGroup.self, from: data)
            var transactions: [Transaction] = root.transactions
            transactions = transactions.sorted(by: { $0.rowIndex < $1.rowIndex })
            
            if (debug) { print(contents); print(transactions) }

            var totalCoins = Float(0)
            print("Transactions for \(currency) account")
            for item in transactions {
                printTransaction(item)
                
                let coins = item.balanceDelta ?? 0.00
                totalCoins += coins
                
                if coins > 0.00 {
                    print("Added \(coins) total is now \(totalCoins)")
                } else if coins < 0.00 {
                    print("Subtracted \(coins) total is now \(totalCoins)")
                } else {
                    print("Did nothing total is still \(totalCoins) transaction below")
                    print(item)
                    print()
                }
            }
            print("Net coins \(round(totalCoins))")
            
        } catch { print(error) }
        
    })
    task.resume()
    
    PlaygroundPage.current.needsIndefiniteExecution = true
}

func viewMyTrades(pair: Pairs) {
    let url = URL(string: "https://api.mybitx.com/api/1/listtrades?pair=\(pair)")!
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let task = session.dataTask(with: getRequest(url), completionHandler: {data, response, error -> Void in
        guard let data = data, error == nil else {
            print(error ?? "Unknown error")
            return
        }
        guard let contents = String(data: data, encoding: .utf8) else { return }
        
        do {
            let root = try JSONDecoder().decode(TradesGroup.self, from: data)
            let trades: [Trade] = root.trades

            if (debug) { print(contents); print(trades); print("My trades for \(pair)") }
            
            for item in trades {
                if (debug) { printTrade(item) }
            }
        } catch { print(error) }
        
    })
    task.resume()
    
    PlaygroundPage.current.needsIndefiniteExecution = true
}

func viewMyTradingHistory(pair: Pairs) {
    let url = URL(string: "https://api.mybitx.com/api/1/listtrades?pair=\(pair)")!
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let task = session.dataTask(with: getRequest(url), completionHandler: {data, response, error -> Void in
        guard let data = data, error == nil else {
            print(error ?? "Unknown error")
            return
        }
        
        guard let contents = String(data: data, encoding: .utf8) else { return }
        
        do {
            let root = try JSONDecoder().decode(TradesGroup.self, from: data)
            let trades: [Trade] = root.trades
            
            if (debug) { print(contents); print(trades); print("My trade history for \(pair)") }
            
            var totalNet = 0.0
            
            for item in trades {
                if (debug) { printTrade(item) }
                let value = (Double(item.volume) ?? 0.00) * (Double(item.price) ?? 0.00)
                
                if item.isBuy {
                    totalNet -= value
                } else {
                    totalNet += value
                }
            }
            
            let totalBuyTally = trades.filter({$0.isBuy}).count
            let totalFees = trades.map({ Double($0.feeBase ?? "0") ?? 0.00 }).reduce(0, { $0 + $1 })
            let totalBuys = trades.filter({ $0.isBuy }).map({ Double($0.volume) ?? 0.00 }).reduce(0, { $0 + $1 })
            let totalSells = trades.filter({ !$0.isBuy }).map({ Double($0.volume) ?? 0.00 }).reduce(0, { $0 + $1 })
            
            print("\n==== TRADING SUMMARY FOR \(pair) ====")
            if pair == .ETHXBT {
                print("You bought \(totalBuyTally) times. At a value of R\(round(totalBuys))")
                print("You sold \(trades.count - totalBuyTally) times. At a value of R\(round(totalSells))")
                print("Net outcome \(round(totalNet))")
                print("You paid a total of R\(totalFees) in fees.")
            } else {
                print("You bought \(totalBuyTally) times.")
                print("You sold \(trades.count - totalBuyTally) times.")
            }
            
        } catch { print(error) }
        
    })
    task.resume()
    
    PlaygroundPage.current.needsIndefiniteExecution = true
}

// MARK: Insigths

func howProfitableAmI(sinceWhen: TimePeriod) {
    print("Hello. Nice to see you, please take a seat")
}

func seeProjectedBuyLowSellHighProfits(randAmount: Float, pair: Pairs) {
    var price = Float(0.00)
    var crypto = "BTC"
    print("Buy Low and Selling projections: \(pair)")
    
    switch pair {
    case .ETHZAR:
        crypto = "ETH"
        price = Float(ETHZARBid)!
    case .XBTZAR:
        crypto = "BTC"
        price = Float(XBTZARBid)!
    case .ETHXBT:
        crypto = "ETH"
        price = Float(ETHXBTBid)!
    default:
        price = Float(0.00)
        crypto = "404"
    }
    
    let volume = randAmount / price
    print("If you buy \(volume) \(crypto) at R\(price)")
    print("And sell at R\(price) you make a profit of R1430 (21% profit)")
    print("Or...sell at R\(price) you make a profit of R3210 (48% profit)")
}

func seeProjectedSellHighBuyLowProfits(volume: Float, pair: Pairs) {
    var price = Float(0.00)
    var crypto = "BTC"
    print("Sell High and Buy low projections: \(pair)")
    
    switch pair {
    case .ETHZAR:
        crypto = "ETH"
        price = Float(ETHZARAsk)!
    case .XBTZAR:
        crypto = "BTC"
        price = Float(XBTZARAsk)!
    case .ETHXBT:
        crypto = "ETH"
        price = Float(ETHXBTAsk)!
    default:
        price = Float(0.00)
        crypto = "404"
    }
    
    let value = volume * price
    print("If you sell \(volume) \(crypto) at R\(price)")
    print("And buy it all back at R\(price + 10000) you make a profit of R1430 (+0.041 ETH)")
    print("Or...buy it all back at R\(price + 25000) you make a profit of R4130 (+0.121 ETH)")
}

func getCoinOdds(pair: Pairs){
    var price = Float(0.00)
    var crypto = "BTC"
    print("Coin odds for \(pair)")
    
    switch pair {
    case .ETHZAR:
        crypto = "ETH"
        price = Float(ETHZARAsk)!
    case .XBTZAR:
        crypto = "BTC"
        price = Float(XBTZARAsk)!
    default:
        price = Float(0.00)
        crypto = "404"
    }
    
    print("0.00001 \(crypto) = R\(price * 0.00001)")
    print("0.0001 \(crypto) = R\(price * 0.0001)")
    print("0.001 \(crypto) = R\(price * 0.001)")
    print("0.01 \(crypto) = R\(price * 0.01)")
    print("0.1 \(crypto) = R\(price * 0.1)")
    print("1 \(crypto) = R\(price * 1)")
    print()
}


// MARK: Testing

if (debug) {
    getCurrentPrice(pair: .ETHZAR)
    getCurrentPrice(pair: .XBTZAR)
    getCurrentPrice(pair: .ETHXBT)
}

debug = true
getCurrentPrice(pair: .all)
//checkBalance()

//viewTransactions(currency: .BTC)
//viewTransactions(currency: .ETH)
//viewTransactions(currency: .ZAR)

//viewMyTradingHistory(pair: .XBTZAR)
//viewMyTradingHistory(pair: .ETHZAR)
//viewMyTradingHistory(pair: .ETHXBT)
//3916.0 + 316970.0

//seeProjectedBuyLowSellHighProfits(randAmount: 5000.00, pair: .XBTZAR)
//getCoinOdds(pair: .XBTZAR)

//viewPublicTrades(pair: .XBTZAR)
