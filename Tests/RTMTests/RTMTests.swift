import XCTest
@testable import RTM

final class RTMTests: XCTestCase {
	func testEnum() {
		XCTAssertEqual(RTM.Permission.read.rawValue,         "read")
		XCTAssertEqual(RTM.Permission.write.rawValue,        "write")
		XCTAssertEqual(RTM.Permission.delete.rawValue,       "delete")
		XCTAssertEqual(RTM.Format.xml.rawValue,              "xml")
		XCTAssertEqual(RTM.Format.json.rawValue,             "json")
		XCTAssertEqual(RTM.Methods.Auth.checkToken.rawValue, "rtm.auth.checkToken")
		XCTAssertEqual(RTM.Methods.Auth.getFrob.rawValue,    "rtm.auth.getFrob")
		XCTAssertEqual(RTM.Methods.Auth.getToken.rawValue,   "rtm.auth.getToken")
		XCTAssertEqual(RTM.Methods.Tasks.getList.rawValue,   "rtm.tasks.getList")
	}

	func testInit() {
		XCTAssertThrowsError(try RTM(appKey: "", appSecret: "")) { (error) in
			XCTAssertEqual(error as! RTM.invalidError, RTM.invalidError.appKeyAndAppSecret)
		}
		XCTAssertThrowsError(try RTM(appKey: "appKey", appSecret: "")) { (error) in
			XCTAssertEqual(error as! RTM.invalidError, RTM.invalidError.appSecret)
		}
		XCTAssertThrowsError(try RTM(appKey: "", appSecret: "appSecret")) { (error) in
			XCTAssertEqual(error as! RTM.invalidError, RTM.invalidError.appKey)
		}

		XCTAssertNoThrow(try RTM(appKey: "appKey", appSecret: "appSecret"))
	}

	func testGetUrl() {
		var rtm = try! RTM(appKey: "appKey", appSecret: "appSecret")

		let getFrob = URLComponents(url: rtm.getUrl(method: RTM.Methods.Auth.getFrob), resolvingAgainstBaseURL: true)
		XCTAssertEqual(getFrob?.queryItems?.count, 4)
		XCTAssertEqual(getFrob?.queryItems?.first(where: { "api_key" == $0.name } )?.value, "appKey")
		XCTAssertEqual(getFrob?.queryItems?.first(where: { "format"  == $0.name } )?.value, RTM.Format.json.rawValue)
		XCTAssertEqual(getFrob?.queryItems?.first(where: { "method"  == $0.name } )?.value, RTM.Methods.Auth.getFrob.rawValue)
		XCTAssertEqual(getFrob?.queryItems?.first(where: { "api_sig" == $0.name } )?.value, "378ee718358e3fed791e1dddb1f11914")

		let getToken = URLComponents(url: rtm.getUrl(method: RTM.Methods.Auth.getToken, ["frob": "frob"]), resolvingAgainstBaseURL: true)
		XCTAssertEqual(getToken?.queryItems?.count, 5)
		XCTAssertEqual(getToken?.queryItems?.first(where: { "api_key" == $0.name } )?.value, "appKey")
		XCTAssertEqual(getToken?.queryItems?.first(where: { "format"  == $0.name } )?.value, RTM.Format.json.rawValue)
		XCTAssertEqual(getToken?.queryItems?.first(where: { "method"  == $0.name } )?.value, RTM.Methods.Auth.getToken.rawValue)
		XCTAssertEqual(getToken?.queryItems?.first(where: { "frob"    == $0.name } )?.value, "frob")
		XCTAssertEqual(getToken?.queryItems?.first(where: { "api_sig" == $0.name } )?.value, "f69fa207044f8e0fe98b0500fcb5f17c")

		rtm.authToken = "authToken"

		let checkToken = URLComponents(url: rtm.getUrl(method: RTM.Methods.Auth.checkToken), resolvingAgainstBaseURL: true)
		XCTAssertEqual(checkToken?.queryItems?.count, 5)
		XCTAssertEqual(checkToken?.queryItems?.first(where: { "api_key"    == $0.name } )?.value, "appKey")
		XCTAssertEqual(checkToken?.queryItems?.first(where: { "format"     == $0.name } )?.value, RTM.Format.json.rawValue)
		XCTAssertEqual(checkToken?.queryItems?.first(where: { "method"     == $0.name } )?.value, RTM.Methods.Auth.checkToken.rawValue)
		XCTAssertEqual(checkToken?.queryItems?.first(where: { "auth_token" == $0.name } )?.value, "authToken")
		XCTAssertEqual(checkToken?.queryItems?.first(where: { "api_sig"    == $0.name } )?.value, "abc60963488cb7f1c01b0b10d825f080")

		let getList = URLComponents(url: rtm.getUrl(method: RTM.Methods.Tasks.getList, ["filter": "status:incomplete"]), resolvingAgainstBaseURL: true)
		XCTAssertEqual(getList?.queryItems?.count, 6)
		XCTAssertEqual(getList?.queryItems?.first(where: { "api_key"    == $0.name } )?.value, "appKey")
		XCTAssertEqual(getList?.queryItems?.first(where: { "format"     == $0.name } )?.value, RTM.Format.json.rawValue)
		XCTAssertEqual(getList?.queryItems?.first(where: { "method"     == $0.name } )?.value, RTM.Methods.Tasks.getList.rawValue)
		XCTAssertEqual(getList?.queryItems?.first(where: { "filter"     == $0.name } )?.value, "status:incomplete")
		XCTAssertEqual(getList?.queryItems?.first(where: { "auth_token" == $0.name } )?.value, "authToken")
		XCTAssertEqual(getList?.queryItems?.first(where: { "api_sig"    == $0.name } )?.value, "14c86d57028e2ae7dc2fd75799ba2e37")
	}

	func testGetAuthUrl() {
		let rtm = try! RTM(appKey: "appKey", appSecret: "appSecret")

		let getAuthUrl = URLComponents(url: rtm.getAuthUrl(frob: "frob"), resolvingAgainstBaseURL: true)
		XCTAssertEqual(getAuthUrl?.queryItems?.count, 5)
		XCTAssertEqual(getAuthUrl?.queryItems?.first(where: { "api_key" == $0.name } )?.value, "appKey")
		XCTAssertEqual(getAuthUrl?.queryItems?.first(where: { "format"  == $0.name } )?.value, RTM.Format.json.rawValue)
		XCTAssertEqual(getAuthUrl?.queryItems?.first(where: { "perms"   == $0.name } )?.value, RTM.Permission.read.rawValue)
		XCTAssertEqual(getAuthUrl?.queryItems?.first(where: { "frob"    == $0.name } )?.value, "frob")
		XCTAssertEqual(getAuthUrl?.queryItems?.first(where: { "api_sig" == $0.name } )?.value, "3384d6a9dbc0a290933e810ea86c8b33")
	}
}
