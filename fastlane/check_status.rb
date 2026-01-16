require 'spaceship'

# Connect to App Store Connect
Spaceship::ConnectAPI.token = Spaceship::ConnectAPI::Token.create(
  key_id: "22C7AGK59G",
  issuer_id: "a81eb7c9-e210-4c68-bc19-e43b8ddc986c",
  filepath: File.expand_path("~/Downloads/AuthKey_22C7AGK59G.p8")
)

# Find the app
app = Spaceship::ConnectAPI::App.find("com.turnlab.TurnLab")
puts "App: #{app.name}"

# Get the edit version
version = app.get_edit_app_store_version
if version
  puts "Version: #{version.version_string}"
  puts "State: #{version.app_store_state}"
  
  # Can we cancel?
  if version.app_store_state == "WAITING_FOR_REVIEW"
    puts "\nCan cancel submission!"
  elsif version.app_store_state == "IN_REVIEW"
    puts "\nApp is IN_REVIEW - cannot cancel once review has started"
  end
else
  puts "No edit version found"
end
