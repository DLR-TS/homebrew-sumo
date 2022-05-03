class SumoAT1120 < Formula
  desc "Simulation of Urban MObility"
  homepage "https://www.eclipse.org/sumo"
  license "EPL-2.0"
  head "https://github.com/eclipse/sumo.git", branch: "main"

  stable do
    url "https://sumo.dlr.de/releases/1.12.0/sumo-src-1.12.0.tar.gz"
    sha256 "163dd6f7ed718e2a30630be3d2ac2ddfc4abce24750ed7f4efce879a3ae9447e"

    if version == "1.12.0" # only for stable v1.12.0
      # commit 0e3f12c0ab2d9fc41f8cabc9b2492274ec9aef86
      patch :DATA # patch code with diff after '__END__'
    end
  end

  bottle do
    root_url "https://github.com/DLR-TS/homebrew-sumo/releases/download/sumo-1.12.0"
    sha256 cellar: :any, big_sur:  "a97d2f1957bb1feeba9d104cc2d3c69e8edd5a08ea0823ef4309a6d4f983f73c"
    sha256 cellar: :any, catalina: "6888fb14466c8333a0eae3802cac554ea71714e8ba7f9d5195ce28083368805e"
  end

  option "with-examples", "Install docs/examples and docs/tutorial folder"

  depends_on "cmake" => :build
  depends_on "fox"
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
    cmake_args = *std_cmake_args

    # bottling uses default formula options and we want minimal requirement bottles,
    # therefore, by default, do not check for optional libs
    if build.with?("ffmpeg") ||
       build.with?("gdal") ||
       build.with?("gl2ps") ||
       build.with?("open-scene-graph") ||
       build.with?("swig")
      ohai "Enabling check for optional libraries..."
      cmake_args << "-DCHECK_OPTIONAL_LIBS=ON"
    else
      cmake_args << "-DCHECK_OPTIONAL_LIBS=OFF"
    end

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

__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 48ad25cbee2..6600ab20099 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -414,6 +414,13 @@ if (MSVC)
     if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
         set(CMAKE_INSTALL_PREFIX "sumo-${PACKAGE_VERSION}")
     endif()
+    install(DIRECTORY bin/ DESTINATION bin
+            FILES_MATCHING
+            PATTERN "*.bat"
+            PATTERN "*.dll"
+            PATTERN "*d.dll" EXCLUDE
+            PATTERN "gtest*.dll" EXCLUDE
+            PATTERN "FOXDLLD-1.6.dll" EXCLUDE)
 else ()
     include(GNUInstallDirs)
 endif ()
@@ -426,13 +433,6 @@ if (SKBUILD)
     set(EXCLUDE_LIBSUMO "libsumo")
     set(EXCLUDE_LIBTRACI "libtraci")
 endif ()
-install(DIRECTORY bin/ DESTINATION bin
-        FILES_MATCHING
-        PATTERN "*.bat"
-        PATTERN "*.dll"
-        PATTERN "*d.dll" EXCLUDE
-        PATTERN "gtest*.dll" EXCLUDE
-        PATTERN "FOXDLLD-1.6.dll" EXCLUDE)
 install(DIRECTORY data/ DESTINATION ${DATA_PATH}data)
 install(DIRECTORY tools/ DESTINATION ${DATA_PATH}tools
         USE_SOURCE_PERMISSIONS

