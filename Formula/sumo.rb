# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://www.rubydoc.info/github/Homebrew/brew/master/Formula
class Sumo < Formula
  desc "SUMO – Simulation of Urban MObility"
  homepage "http://sumo.dlr.de"
  url "https://prdownloads.sourceforge.net/sumo/sumo-src-1.0.1.tar.gz"
  sha256 "6e46a1568b1b3627f06c999c798feceb37f17e92aadb4d517825b01c797ec531"
  head "https://github.com/eclipse/sumo.git"

  depends_on "cmake" => :build
  depends_on "fox"
  depends_on "gdal"
  depends_on "proj"
  depends_on "xerces-c"
  depends_on :x11 # TODO: find convenient way to explicitly define cask dependecy ("xquartz")

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    mkdir "build/cmake-build" do # creates and changes to dir in block
      system "cmake", "../..", *std_cmake_args
      system "make"
      system "make", "install"
    end
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test sumo-src`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
