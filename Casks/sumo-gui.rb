cask "sumo-gui" do
  version :latest
  sha256 :no_check

  url "https://sumo.dlr.de/daily/sumo-gui-macos-git.zip",
      verified: "sumo.dlr.de/daily/"
  name "sumo-gui-macos"
  desc "Simulation of Urban MObility GUI"
  homepage "https://www.eclipse.org/sumo"

  app "sumo-git/sumo-gui-macos/sumo-gui.app", target: "SUMO GUI.app"
  app "sumo-git/sumo-gui-macos/netedit.app", target: "Netedit.app"
  app "sumo-git/sumo-gui-macos/OSM Web Wizard.app", target: "OSM Web Wizard.app"

  caveats do
    puts "Before running the apps, please verify that your SUMO_HOME environment variable is set correctly.\n"
    unsigned_accessibility
  end
end
