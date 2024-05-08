class SumoAT1170 < Formula
  desc "Simulation of Urban MObility"
  homepage "https://www.eclipse.org/sumo"
  url "https://sumo.dlr.de/releases/1.17.0/sumo-src-1.17.0.tar.gz"
  sha256 "9985732cfb51f1b40f0dc8dc46772e684947d84a6c79fc61cf137fa08ec0988b"
  license "EPL-2.0"
  head "https://github.com/eclipse/sumo.git", branch: "main"

  bottle do
    root_url "https://github.com/DLR-TS/homebrew-sumo/releases/download/sumo-1.17.0"
    sha256 cellar: :any, arm64_ventura:  "c031bda20afd2021d6b8cf9902ff4ec10f5c5d0e3d41af77b69b3b6e264ae0e5"
    sha256 cellar: :any, arm64_monterey: "dbc5e8f145b948756a75445d73dad7c3e625b40bcde81acd0874d4844443ec5b"
    sha256 cellar: :any, monterey:       "75214f1ba0187b53aacec83cc39820ed02bf313e1cd2504bf89d9af5952378ab"
    sha256 cellar: :any, big_sur:        "daf9e52345cf3fdc36a794642fc1d08bfc18c2828cbec68d9f102afddf0454bb"
  end

  option "with-examples", "Install docs/examples and docs/tutorial folder"

  depends_on "cmake" => :build
  depends_on "fox"
  depends_on "libice"
  depends_on "libx11"
  depends_on "libxcursor"
  depends_on "libxext"
  depends_on "libxfixes"
  depends_on "libxft"
  depends_on "libxi"
  depends_on "libxrandr"
  depends_on "libxrender"
  depends_on "proj"
  depends_on "python" if build.head? && build.with?("examples")
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
    # cf. https://rubydoc.brew.sh/Formula.html#std_cmake_args-instance_method
    cmake_args = *std_cmake_args(find_framework: "LAST")

    # bottling uses default formula options and we want minimal requirement bottles,
    # therefore, by default, do not check for optional libs
    if build.with?("ffmpeg") ||
       build.with?("gdal") ||
       build.with?("gl2ps") ||
       build.with?("open-scene-graph")
      ohai "Enabling check for optional libraries..."
      cmake_args << "-DCHECK_OPTIONAL_LIBS=ON"
    else
      cmake_args << "-DCHECK_OPTIONAL_LIBS=OFF"
    end

    # If found, SWIG is enabled by default by sumo cmake config step
    # but Java/Python library paths found by cmake might still be broken,
    # so we disable SWIG by default here.
    cmake_args << "-DSWIG_EXECUTABLE=\"\"" if build.without?("swig")
    # XXX: pointers for getting '--with-swig' to work:
    # cmake_args << "-DJAVA_HOME=#{Formula["openjdk"].opt_prefix}/libexec/openjdk.jdk/Contents/Home"
    # cmake_args << "-DPython_ROOT_DIR=#{Formula["python"].opt_prefix}"

    mkdir "build/cmake-build" do # creates and changes to dir in block
      system "cmake", "../..", *cmake_args
      system "make"
      system "make", "install"
      system "make", "examples" if build.head? && build.with?("examples")
    end

    if build.with?("examples")
      (pkgshare/"docs").install "docs/examples"
      (pkgshare/"docs").install "docs/tutorial"
    end
  end

  def caveats
    <<~EOS
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

    system "#{bin}/netconvert", "-n", "#{testpath}/nodes.xml", "-e", "#{testpath}/edges.xml", "-o",
           "#{testpath}/net.xml"

    (testpath/"flows.xml").write <<~EOS
      <routes>
        <flow id="0to1" from="0to1" to="0to1" end="3600" vehsPerHour="1000"/>
      </routes>
    EOS

    system "#{bin}/sumo", "-n", "#{testpath}/net.xml", "-r", "#{testpath}/flows.xml"
  end
end
