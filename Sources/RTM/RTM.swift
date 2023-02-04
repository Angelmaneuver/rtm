import Foundation
import CryptoKit

extension Data {
	var md5: String {
		Insecure.MD5
			.hash(data: self)
			.map { String(format: "%02x", $0) }
			.joined()
	}
}

public protocol Method {
	var rawValue: String { get }
}

public struct RTM {
	public enum Permission: String {
		case read, write, delete
	}

	public enum Format: String {
		case xml, json
	}

	public enum Methods {
		public enum Auth: Method {
			case checkToken, getFrob, getToken

			public var rawValue: String {
				switch self {
					case .checkToken: return "rtm.auth.checkToken"
					case .getFrob:    return "rtm.auth.getFrob"
					case .getToken:   return "rtm.auth.getToken"
				}
			}
		}

		public enum Tasks: Method {
			case getList

			public var rawValue: String {
				switch self {
					case .getList: return "rtm.tasks.getList"
				}
			}
		}
	}

	public enum invalidError: Error {
		case appKey, appSecret, appKeyAndAppSecret
	}

	private let AUTH_URL:   String = "https://www.rememberthemilk.com/services/auth/"
	private let BASE_URL:   String = "https://api.rememberthemilk.com/services/rest/"

	private var appKey:     String
	private var appSecret:  String
	private var permission: String
	private var format:     String

	public  var authToken:  String

    public init(appKey: String, appSecret: String, authToken: String = "", permission: Permission = Permission.read, format: Format = Format.json) throws {
		self.appKey     = appKey
		self.appSecret  = appSecret
		self.authToken  = authToken
		self.permission = permission.rawValue
		self.format     = format.rawValue

		if (0 == self.appKey.count && 0 == self.appSecret.count) {
			throw RTM.invalidError.appKeyAndAppSecret
		} else if (0 == self.appKey.count) {
			throw RTM.invalidError.appKey
		} else if (0 == self.appSecret.count) {
			throw RTM.invalidError.appSecret
		}
    }

	public func getUrl(method: Method, _ _params: Dictionary<String, String> = [:]) -> URL {
		var params: Dictionary<String, String> = ["method": method.rawValue]

		if (0 < self.authToken.count) {
			params.updateValue(self.authToken, forKey: "auth_token")
		}

		params.merge(_params, uniquingKeysWith: { (current, _) in current } )

		return URL(string: "\(self.BASE_URL)\(self.encodeUrlPrams(_params: params))")!
	}

	public func getAuthUrl(frob: String) -> URL {
		let params: Dictionary<String, String> = [
			"api_key": self.appKey,
			"perms":   self.permission,
			"frob":    frob,
		]

		return URL(string: "\(self.AUTH_URL)\(self.encodeUrlPrams(_params: params))")!
	}

	private func encodeUrlPrams(_params: Dictionary<String, String>) -> String {
		var params:      Dictionary<String, String> = ["api_key": self.appKey, "format": self.format]
		var paramString: Array<String>              = []

		params.merge(_params, uniquingKeysWith: { (current, _) in current } )

		for (key, value) in params {
			let param:  String = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

			paramString.append("\(key)=\(param)")
		}

		paramString.append(self.generateSig(params: params))

		return "?\(paramString.joined(separator: "&"))"
	}

	private func generateSig(params: Dictionary<String, String>) -> String {
		var signature: Array<String> = []

		for (key, value) in params.sorted(by: < ) {
			signature.append("\(key)\(value)")
		} 

		signature.insert(self.appSecret, at: 0)

		return "api_sig=\(signature.joined().data(using: .utf8)!.md5)"
	}
}
