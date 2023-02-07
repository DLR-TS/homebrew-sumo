class Sumo < Formula
  desc "Simulation of Urban MObility"
  homepage "https://www.eclipse.org/sumo"
  license "EPL-2.0"
  head "https://github.com/eclipse/sumo.git", branch: "main"

  stable do
    url "https://sumo.dlr.de/releases/1.16.0/sumo-src-1.16.0.tar.gz"
    sha256 "33694b554a8c661ec407d04cc7c6534c473ccb2fbe7bf2ea97e1faddc70654fa"
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
