# rtm

rtm is a Swift library for the Remember the Milk API.

## Integration
You can use [The Swift Package Manager](https://swift.org/package-manager) to install `RTM` by adding the proper description to your `Package.swift` file:

```swift
dependencies: [
	.package(url: "https://github.com/Angelmaneuver/rtm", from: "1.0.0"),
],
```

## Usage
#### Initialization
```swift
import RTM
```

```swift
do {
	rtm = try RTM(appKey: appKey, appSecret: appSecret, authToken: authToken, permission: RTM.Permission.read, format: RTM.Format.json)
} catch {
	throw error
}
```

#### Get request url for `rtm.auth.getFrob` method
```swift
rtm.getUrl(method: RTM.Methods.Auth.getFrob)
```

#### Get request url for User authentication
```swift
rtm.getAuthUrl(frob: frob)
```

#### Get request url for `rtm.auth.getToken` method
```swift
rtm.getUrl(method: RTM.Methods.Auth.getToken, ["frob": frob])
```

#### Get request url for `rtm.auth.checkToken` method
```swift
rtm.getUrl(method: RTM.Methods.Auth.getToken)
```

#### Get request url for `rtm.tasks.getList` method
```swift
rtm.getUrl(method: RTM.Methods.Tasks.getList)
```

or

```swift
rtm.getUrl(method: RTM.Methods.Tasks.getList, ["filter": "status:incomplete"])
```

\* Other methods not yet supported

## Reference Repositories
 - [rtm-js](https://github.com/aranel616/rtm-js)
