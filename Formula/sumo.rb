# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://www.rubydoc.info/github/Homebrew/brew/master/Formula
class Sumo < Formula
  desc "Simulation of Urban MObility"
  homepage "http://sumo.dlr.de"
  url "https://downloads.sourceforge.net/project/sumo/sumo/version%201.0.1/sumo-src-1.0.1.tar.gz"
  sha256 "6e46a1568b1b3627f06c999c798feceb37f17e92aadb4d517825b01c797ec531"
  head "https://github.com/eclipse/sumo.git"

  depends_on "cmake" => :build
  depends_on "fox"
  depends_on "gdal"
  depends_on "proj"
  depends_on :x11 # TODO: find convenient way to explicitly define cask dependecy ("xquartz")
  depends_on "xerces-c"

  # workaround due to dependency gdal -> numpy -> openblas -> gcc (originally gfortran)
  # (use 'brew deps --tree sumo' to see dependencies of higher levels)
  # also see: https://github.com/davidchall/homebrew-hep/issues/28
  cxxstdlib_check :skip

  def install
    ENV["SUMO_HOME"] = prefix

    mkdir "build/cmake-build" do # creates and changes to dir in block
      system "cmake", "../..", *std_cmake_args
      system "make"
      system "make", "install"
    end
  end

  def caveats; <<~EOS
    In order to let X11 start automatically whenever a GUI-based SUMO application
    (e.g., "sumo-gui") is called, you need to log out and in again.
    Alternatively, start X11 manually by pressing cmd-space and entering "XQuartz".

    Don't forget to set your SUMO_HOME environment variable:
      export SUMO_HOME="#{prefix}"

  EOS
  end

  test do # will create, run in and delete a temporary directory
    # This small test verifies the functionality of SUMO.
    # Run with 'brew test sumo'.
    # Options passed to 'brew install' such as '--HEAD' also need to be provided to 'brew test'.

    ENV["SUMO_HOME"] = prefix

    (testpath/"nodes.xml").write <<~EOS
      <nodes>
        <node id="0" x="0.0" y="0.0"/>
        <node id="1" x="500.0" y="0.0"/>
      </nodes>
    EOS

    (testpath/"edges.xml").write <<~EOS
      <edges>
        <edge id="0to1" from="0" to="1" numLanes="2" speed="30"/>
      </edges>
    EOS

    system "#{bin}/netconvert", "-n", "#{testpath}/nodes.xml", "-e", "#{testpath}/edges.xml", "-o", "#{testpath}/net.xml"

    (testpath/"flows.xml").write <<~EOS
      <routes>
        <flow id="0to1" from="0to1" to="0to1" end="3600" vehsPerHour="1000"/>
      </routes>
    EOS

    system "#{bin}/sumo", "-n", "#{testpath}/net.xml", "-r", "#{testpath}/flows.xml"
  end
end
