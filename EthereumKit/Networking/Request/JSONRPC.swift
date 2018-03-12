import JSONRPCKit

public final class JSONRPC {
    public struct GetGasPrice: Request {
        public typealias Response = Wei
        
        public var method: String {
            return "eth_gasPrice"
        }
        
        public func response(from resultObject: Any) throws -> Wei {
            guard let response = resultObject as? String, let wei = Wei(hex: response.hex.lowercased()) else {
                throw JSONRPCError.unexpectedTypeObject(resultObject)
            }
            return wei
        }
    }
    
    public struct GetBalance: Request {
        public typealias Response = Balance
        
        public let address: Address
        public let blockParameter: BlockParameter
        
        public var method: String {
            return "eth_getBalance"
        }
        
        public var parameters: Any? {
            return [address.string, blockParameter.rawValue]
        }
        
        public func response(from resultObject: Any) throws -> Balance {
            guard let response = resultObject as? String, let wei = Wei(hex: response.hex.lowercased()) else {
                throw JSONRPCError.unexpectedTypeObject(resultObject)
            }
            return Balance(wei: wei)
        }
    }
    
    public struct GetTransactionCount: Request {
        public typealias Response = Int
        
        public let address: Address
        public let blockParameter: BlockParameter
        
        public var method: String {
            return "eth_getTransactionCount"
        }
        
        public var parameters: Any? {
            return [address.string, blockParameter.rawValue]
        }
        
        public func response(from resultObject: Any) throws -> Response {
            guard let response = resultObject as? String else {
                throw JSONRPCError.unexpectedTypeObject(resultObject)
            }
            return Int(response.hex, radix: 16) ?? 0
        }
    }
    
    public struct SendRawTransaction: Request {
        public typealias Response = SentTransaction
        
        public let rawTransaction: String
        
        public var method: String {
            return "eth_sendRawTransaction"
        }
        
        public var parameters: Any? {
            return [rawTransaction]
        }
        
        public func response(from resultObject: Any) throws -> Response {
            guard let transactionID = resultObject as? String else {
                throw JSONRPCError.unexpectedTypeObject(resultObject)
            }
            return Response(id: transactionID)
        }
    }
    
    public struct Call: JSONRPCKit.Request {
        public typealias Response = String
        
        public let from: Address?
        public let to: Address
        public let gas: Int?
        public let gasPrice: Int?
        public let value: Int?
        public let data: String?
        public let blockParameter: BlockParameter
        
        public var method: String {
            return "eth_call"
        }
        
        public var parameters: Any? {
            // NOTE: This is to remove key/value if the value is nil.
            let txParams: [String: Any] = [
                "from": from?.string as Any?,
                "to": to.string,
                "gas": gas,
                "gasPrice": gasPrice,
                "value": value,
                "data": data
                ].reduce([String: Any]()){ (d, e) in
                    guard let value = e.value else { return d }
                    var d = d
                    d[e.key] = value
                    return d
            }
            return [txParams, blockParameter.rawValue]
        }
        
        public func response(from resultObject: Any) throws -> Response {
            guard let response = resultObject as? Response else {
                throw JSONRPCError.unexpectedTypeObject(resultObject)
            }
            return response
        }
    }
}
