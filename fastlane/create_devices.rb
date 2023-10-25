# Import devices from Snapfile
# Retrieve list of existing devices via `xcrun simctl list`
# Create missing devices via `xcrun simctl create`

devices = [
    ["iPhone 14 Pro Max", "iPhone-14-Pro-Max"],
    ["iPhone 14 Pro", "iPhone-14-Pro"],
    ["iPhone 14 Plus", "iPhone-14-Plus"],
    ["iPhone 14", "iPhone-14"],
    ["iPad Pro (12.9-inch) (6th generation)", "iPad-Pro-12-9-inch-6th-generation-8GB"],
    ["iPad Pro (12.9-inch) (2nd generation)", "iPad-Pro--12-9-inch---2nd-generation-"],
    ["iPad Pro (11-inch) (4th generation)", "iPad-Pro-11-inch-4th-generation-8GB"]
]
runtime = "com.apple.CoreSimulator.SimRuntime.iOS-17-0"
existing_devices = %x(xcrun simctl list devices available)

for device in devices do
    if existing_devices.include?("#{device[0]} (")
        puts "Device #{device[0]} already exists"
    else
        puts "Creating device #{device[0]}"
        %x(xcrun simctl create "#{device[0]}" com.apple.CoreSimulator.SimDeviceType.#{device[1]} #{runtime})
    end
end