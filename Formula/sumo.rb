class Sumo < Formula
  desc "Simulation of Urban MObility"
  homepage "https://projects.eclipse.org/projects/technology.sumo"
  head "https://github.com/eclipse/sumo.git"

  stable do
    url "https://github.com/eclipse/sumo/archive/v1_5_0.tar.gz"
    sha256 "be6ba0361b487a5e71c81e60b4c07a67826d5e170500c10c37374c1086ac2cb6"
  end

  bottle do
    root_url "https://dl.bintray.com/dlr-ts/bottles-sumo"
    cellar :any
    sha256 "c3432beb8fb74b6d5939d750985623280bf9a4f70aa0aeaf7d5e299a9b293914" => :mojave
    sha256 "1aa74d45cefb21e08f750c0f032ca122e85f9cfc0e03accb5d5bc7eba00b42df" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on "fox"
  depends_on "proj"
  depends_on :x11 # TODO: find convenient way to explicitly define cask dependecy ("xquartz")
  depends_on "xerces-c"
  depends_on "ffmpeg" => :optional
  depends_on "gdal" => :optional
  depends_on "gl2ps" => :optional
  depends_on "open-scene-graph" => :optional
  depends_on "swig" => :optional

  # workaround due to dependency gdal -> numpy -> openblas -> gcc (originally gfortran)
  # (use 'brew deps --tree sumo' to see dependencies of higher levels)
  # also see: https://github.com/davidchall/homebrew-hep/issues/28
  cxxstdlib_check :skip

  def install
    ENV["SUMO_HOME"] = prefix
    cmake_args = *std_cmake_args

    # bottling uses default formula options and we want minimal requirement bottles,
    # therefore, by default, do not check for optional libs
    if build.with?("ffmpeg") || build.with?("gdal") || build.with?("gl2ps") || build.with?("open-scene-graph") || build.with?("swig")
      ohai "Enabling check for optional libraries..."
      cmake_args << "-DCHECK_OPTIONAL_LIBS=ON"
    else
      cmake_args << "-DCHECK_OPTIONAL_LIBS=OFF"
    end

    mkdir "build/cmake-build" do # creates and changes to dir in block
      system "cmake", "../..", *cmake_args
      system "make"
      system "make", "install"
    end
  end

  def caveats; <<~EOS
    In order to let X11 start automatically whenever a GUI-based SUMO application
    (e.g., "sumo-gui") is called, you need to log out and in again.
    Alternatively, start X11 manually by pressing cmd-space and entering "XQuartz".

    Don't forget to set your SUMO_HOME environment variable:
      export SUMO_HOME="#{prefix}/share/sumo"

    Please report any problems with this formula directly to the eclipse/sumo issue tracker:
    https://github.com/eclipse/sumo/issues

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
