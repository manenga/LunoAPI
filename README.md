# LunoAPI

## Purpose
A Swift playground on the Public Luno API - still very much a work in progress

## Features
* Get Market Summary for all pairs
* Get All your balances.
* View the order book.
* View public trades.
* View trading history.

## Usage
Some requests require authentication while other do not. 
Make sure to fill in the **username** and **password** in `getRequest` below attempting the functions below.

Get a current prices
```swift
getCurrentPrice(pair: .all)
getCurrentPrice(pair: .ETHZAR)
getCurrentPrice(pair: .XBTZAR)
```

Check your wallet balance
```swift
checkBalance()
```

Other
```swift
viewPublicTrades(pair: .XBTZAR)
viewTransactions(currency: .BTC)
viewTransactions(currency: .ZAR)
viewMyTradingHistory(pair: .ETHZAR)
```

## Author
[LinkedIn](https://linkedin.com/in/mungandi/)
