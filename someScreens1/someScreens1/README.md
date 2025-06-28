# SomeScreens1

iOS app with network monitoring and display of the screen when there is no internet.

## Functionality

### Network Monitoring
- Uses `NetworkManager` with `NWPathMonitor` to monitor network status
- Automatically displays `NoInternetConnectionViewController` screen when connection is lost
- Automatically closes the no internet screen when connection is restored
- Supports different connection types: Wi-Fi, Cellular, Ethernet

### Main components

#### NetworkManager
- Singleton class for network monitoring
- Uses `NWPathMonitor` to track changes
- Sends notifications when network status changes
- Logs all changes via SwiftyBeaver

#### UsersViewController
- Main screen with a list of users
- Automatically checks network status on boot
- Shows no internet screen when connection is lost
- Automatically loads data when connection is restored

#### NoInternetConnectionViewController
- Screen displayed when there is no internet
- Automatically closes when connection is restored
- Has a "Try" button again" to manually check the connection
- Uses both NetworkManager and URL validation

## Usage

### Starting the application
1. Open the project in Xcode
2. Run the application on the simulator or device
3. NetworkManager is automatically initialized on startup

### Network monitoring testing
1. **Disable internet**: Turn off Wi-Fi or Cellular on the device/simulator
2. **Show screen**: The `NoInternetConnectionViewController` screen should appear automatically
3. **Enable internet**: Turn on Wi-Fi or Cellular
4. **Autoclose**: The screen should close automatically

### Logging
All network events are logged via SwiftyBeaver:
- 🌐 Network state changes
- 📱 Events in UsersViewController
- ✅ Successful operations
- ❌ Errors
- 🔄 User actions

## Architecture

```
AppDelegate
├── NetworkManager (Singleton)
│ ├── NWPathMonitor
│ └── NotificationCenter
│
UsersViewController
├── NetworkManager.shared
├── NotificationCenter observer
└── Segue to NoInternetConnectionViewController
│
NoInternetConnectionViewController
├── NetworkManager.shared
├── NotificationCenter observer
└── Auto-dismiss on network restore
```

## Technologies

- **NWPathMonitor**: Native iOS API for network monitoring
- **NotificationCenter**: For network change notifications
- **SwiftyBeaver**: For logging
- **Core Data**: For storing user data
- **Kingfisher**: For loading images

## Settings

### Storyboard
- `users.storyboard`: Main screen with user table
- `noInternetConnection.storyboard`: No internet screen
- `noInternetConnection` segue configured between screens

### NetworkManager
- Automatically initialized in `AppDelegate`
- Monitoring starts immediately at startup application
- Sends notifications on the main thread

## Notes

- NetworkManager uses the singleton pattern for global access
- All UI updates are performed on the main thread
- Logging helps track network monitoring
- The offline screen automatically closes when the connection is restored
