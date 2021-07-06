package("azure-kinect-sensor-sdk")

    set_homepage("https://azure.microsoft.com/en-us/services/kinect-dk/")
    set_description("A cross platform (Linux and Windows) user mode SDK to read data from your Azure Kinect device")

    set_urls("https://github.com/microsoft/Azure-Kinect-Sensor-SDK.git")
    add_versions("1.4.1", "3cfe362dacc4ad9b2206af3f28d62e1eb7be99c2")

    add_deps("cmake", "ninja", "python 3.x", {kind = "binary"})

    on_install("windows|x64", "linux", function (package)
        import("package.tools.cmake").install(package, {}, {buildir = os.tmpdir(), cmake_generator = "Ninja"})
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test(int argc, char** argv) {
                k4a_device_t device = NULL;
                k4a_device_open(K4A_DEVICE_DEFAULT, &device);
                if (device != NULL)
                    k4a_device_close(device);
            }
        ]]}, {includes = "k4a/k4a.h"}))
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char** argv) {
                k4a::device dev = k4a::device::open(K4A_DEVICE_DEFAULT);
            }
        ]]}, {includes = "k4a/k4a.hpp"}))
    end)