package("arrayfire")

    set_homepage("https://arrayfire.com")
    set_description("A general-purpose library that simplifies the process of developing software that targets parallel and massively-parallel architectures")

    set_urls("https://github.com/arrayfire/arrayfire/archive/v$(version).zip")
    add_versions("3.7.3", "6f59c73e4b4452481e4fd9257dccd8c5435dbb870d4b51fc9bcb0f41cce93f17")

    add_configs("build_cpu",             {description = "Build ArrayFire with a CPU backend", default = true, type = "boolean"})
    -- Currently deactivated needs CUDA library in xmake-repo
    -- add_configs("build_cuda",         {description = "Build ArrayFire with a CUDA backend", default = true, type = "boolean"})
    -- Currently deactivated needs OpenCL library in xmake-repo
    -- add_configs("build_opencl",          {description = "Build ArrayFire with a OpenCL backend", default = true, type = "boolean"})
    add_configs("build_unified",         {description = "Build Backend-Independent ArrayFire API", default = true, type = "boolean"})
    -- Currently deactivated needs cuDNN library in xmake-repo
    -- add_configs("build_cudnn",        {description = "Use cuDNN for convolveNN functions", default = true, type = "boolean"})
    add_configs("build_forge",           {description = "Forge libs are not built by default as it is not link time dependency", default = false, type = "boolean"})
    add_configs("with_nonfree",          {description = "Build ArrayFire nonfree algorithms", default = false, type = "boolean"})
    add_configs("with_logging",          {description = "Build ArrayFire with logging support", default = true, type = "boolean"})
    add_configs("with_stacktrace",       {description = "Add stacktraces to the error messages", default = true, type = "boolean"})
    add_configs("cache_kernels_to_disk", {description = "Enable caching kernels to disk", default = true, type = "boolean"})
    -- Currently deactivated requires MKL libary in xmake-repo
    -- add_configs("with_static_mkl",    {description = "Link against static Intel MKL libraries", default = false, type = "boolean"})
    if is_plat("windows") then
        add_configs("stacktrace_type",   {description = "The type of backtrace features. Windbg(simple), None", default = "Windbg", type = "string"})
    else
        add_configs("stacktrace_type",   {description = "The type of backtrace features. Basic(simple), libbacktrace(fancy), addr2line(fancy), None", default = "Basic", type = "string"})
    end
    -- Currently deactivated needs FreeImage library in xmake-repo
    -- add_configs("with_imageio",       {description = "Build ArrayFire with Image IO support", default = true, type = "boolean"})
    if is_plat("macos", "iphoneos") then
        add_configs("build_framework",   {description = "Build an ArrayFire framework for Apple platforms.(Experimental)", default = false, type = "boolean"})
    end
    add_configs("with_cpuid",            {description = "Build with CPUID integration", default = true, type = "boolean"})

    -- Following libraries need to be added to xmake-repo: lapack, openmp, mkl
    add_deps("cmake", "lapack", "openmp", "mkl", "boost >=1.66", "openblas")

    on_load(function (package)
        local function add_deps_if(conf, dep)
            if package:config(conf) then
                package:add("deps", dep)
            end
        end
        -- Should be updated when the respective libraries are added to xmake-repo
        -- add_deps_if("build_cuda", "cuda >= 9.0")
        -- add_deps_if("build_opencl", "opencl >=1.2")
        -- add_deps_if("build_cudnn", "cudnn >=4.0")
    end)

    on_install(function (package)
        local config = {}
        local function set_cmake_arg(cmake_name, val)
            local cmake_val = type(val) == "boolean" and (val and "ON" or "OFF") or val
            table.insert(config, "-D" .. cmake_name .. "=" .. cmake_val)
        end
        local function add_config_arg(config_name, cmake_name)
            set_cmake_arg(cmake_name, package:config(config_name))
        end


        add_config_arg("shared", "BUILD_SHARED_LIBS")
        add_config_arg("build_cpu", "AF_BUILD_CPU")
        -- Should be updated when CUDA is added to xmake-repo
        set_cmake_arg("AF_BUILD_CUDA", false)
        -- Should be updated when OpenCL is added to xmake-repo
        set_cmake_arg("AF_BUILD_OPENCL", false)
        add_config_arg("build_unified", "AF_BUILD_UNIFIED")
        set_cmake_arg("AF_BUILD_DOCS", false)
        set_cmake_arg("AF_BUILD_EXAMPLES", false)
        -- Should be updated when cuDNN is added to xmake-repo
        set_cmake_arg("AF_WITH_CUDNN", false)
        add_config_arg("build_forge", "AF_BUILD_FORGE")
        add_config_arg("with_nonfree", "AF_WITH_NONFREE")
        add_config_arg("with_logging", "AF_WITH_LOGGING")
        add_config_arg("with_stacktrace", "AF_WITH_STACKTRACE")
        add_config_arg("cache_kernels_to_disk", "AF_CACHE_KERNELS_TO_DISK")
        -- Should be updated when MKL is added to xmake-repo
        set_cmake_arg("AF_WITH_STATIC_MKL", false)
        add_config_arg("stacktrace_type", "AF_STACKTRACE_TYPE")
        set_cmake_arg("AF_INSTALL_STANDALONE", false)
        if package:is_plat("macos", "iphoneos") then
            add_config_arg("build_framework", "AF_BUILD_FRAMEWORK")
        end
        add_config_arg("with_cpuid", "AF_WITH_CPUID")

        import("package.tools.cmake").install(package, config)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char** argv) {
                array A = randu(5, 3, f32);
                array B = sin(A) + 1.5;
                array C = fft(B);
            }
        ]]}, {includes = "arrayfire.h"}))
    end)