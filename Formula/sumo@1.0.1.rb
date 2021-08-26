class SumoAT101 < Formula
  desc "Simulation of Urban MObility"
  homepage "http://sumo.dlr.de"
  head "https://github.com/eclipse/sumo.git", branch: "main"

  stable do
    url "https://downloads.sourceforge.net/project/sumo/sumo/version%201.0.1/sumo-src-1.0.1.tar.gz"
    sha256 "6e46a1568b1b3627f06c999c798feceb37f17e92aadb4d517825b01c797ec531"

    if version == "1.0.1" # only for stable v1.0.1
      # required due to some unforeseen macOS linker option incomaptibilites
      # cf. https://github.com/eclipse/sumo/issues/4850
      patch :DATA # patch code with diff after '__END__'
    end
  end

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
    end
  end

  def caveats
    <<~EOS
      In order to let X11 start automatically whenever a GUI-based SUMO application
      (e.g., "sumo-gui") is called, you need to log out and in again.
      Alternatively, start X11 manually by pressing cmd-space and entering "XQuartz".

      Don't forget to set your SUMO_HOME environment variable:
        export SUMO_HOME="#{prefix}"

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
diff --git a/src/libsumo/CMakeLists.txt b/src/libsumo/CMakeLists.txt
index 0e95f7f..23e4caa 100644
--- a/src/libsumo/CMakeLists.txt
+++ b/src/libsumo/CMakeLists.txt
@@ -55,7 +55,7 @@ if(SWIG_FOUND)
             else()
                 SWIG_ADD_MODULE(libsumojni java libsumo.i)
             endif()
-            if (MSVC)
+            if (MSVC OR APPLE)
                 swig_link_libraries(libsumojni ${sumolibs})
             else()
                 set_source_files_properties(${swig_generated_file_fullname} PROPERTIES COMPILE_FLAGS "-Wno-strict-aliasing")
@@ -99,7 +99,7 @@ if(SWIG_FOUND)
             else()
                 SWIG_ADD_MODULE(libsumo python libsumo.i)
             endif()
-            if (MSVC)
+            if (MSVC OR APPLE)
                 # disable python module for the debug build because virtually no one has a python debug dll to link against
                 set_property(TARGET ${SWIG_MODULE_libsumo_REAL_NAME} PROPERTY EXCLUDE_FROM_DEFAULT_BUILD_DEBUG TRUE)
                 swig_link_libraries(libsumo ${sumolibs} ${PYTHON_LIBRARIES})
diff --git a/unittest/src/microsim/CMakeLists.txt b/unittest/src/microsim/CMakeLists.txt
index 5273e06..a18b5ed 100644
--- a/unittest/src/microsim/CMakeLists.txt
+++ b/unittest/src/microsim/CMakeLists.txt
@@ -6,7 +6,7 @@ add_executable(testmicrosim
 add_test(NAME testmicrosim COMMAND $<TARGET_FILE:testmicrosim>)
 set_target_properties(testmicrosim PROPERTIES OUTPUT_NAME_DEBUG testmicrosimD)
 
-if (MSVC)
+if (MSVC OR APPLE)
     target_link_libraries(testmicrosim microsim microsim_actions microsim_devices microsim_cfmodels microsim_lcmodels microsim_pedestrians microsim_trigger microsim_traffic_lights mesosim traciserver libsumostatic netload microsim_output mesosim ${commonvehiclelibs} ${GTEST_BOTH_LIBRARIES} ${GRPC_LIBS})
 else ()
     target_link_libraries(testmicrosim -Wl,--start-group microsim microsim_actions microsim_devices microsim_cfmodels microsim_lcmodels microsim_pedestrians microsim_trigger microsim_traffic_lights mesosim traciserver libsumostatic netload microsim_output mesosim ${commonvehiclelibs} -Wl,--end-group ${GTEST_BOTH_LIBRARIES} ${GRPC_LIBS})
diff --git a/unittest/src/utils/common/CMakeLists.txt b/unittest/src/utils/common/CMakeLists.txt
index aff01dd..6920767 100644
--- a/unittest/src/utils/common/CMakeLists.txt
+++ b/unittest/src/utils/common/CMakeLists.txt
@@ -1,6 +1,5 @@
 add_executable(testcommon
         StringTokenizerTest.cpp
-        FileHelpersTest.cpp
         StringUtilsTest.cpp
         TplConvertTest.cpp
         RGBColorTest.cpp
@@ -9,7 +8,7 @@ add_executable(testcommon
 add_test(NAME testcommon COMMAND $<TARGET_FILE:testcommon>)
 set_target_properties(testcommon PROPERTIES OUTPUT_NAME_DEBUG testcommonD)
 
-if (MSVC)
+if (MSVC OR APPLE)
     target_link_libraries(testcommon ${commonlibs} ${GTEST_BOTH_LIBRARIES})
 else ()
     target_link_libraries(testcommon -Wl,--start-group ${commonlibs} -Wl,--end-group ${GTEST_BOTH_LIBRARIES})
diff --git a/unittest/src/utils/geom/CMakeLists.txt b/unittest/src/utils/geom/CMakeLists.txt
index 76c1e8b..f65a210 100644
--- a/unittest/src/utils/geom/CMakeLists.txt
+++ b/unittest/src/utils/geom/CMakeLists.txt
@@ -7,7 +7,7 @@ add_executable(testgeom
 add_test(NAME testgeom COMMAND $<TARGET_FILE:testgeom>)
 set_target_properties(testgeom PROPERTIES OUTPUT_NAME_DEBUG testgeomD)
 
-if (MSVC)
+if (MSVC OR APPLE)
     target_link_libraries(testgeom ${commonlibs} ${GTEST_BOTH_LIBRARIES})
 else ()
     target_link_libraries(testgeom -Wl,--start-group ${commonlibs} -Wl,--end-group ${GTEST_BOTH_LIBRARIES})

