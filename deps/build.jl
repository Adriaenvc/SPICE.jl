using BinaryProvider

# This is where all binaries will get installed
#= const prefix = Prefix(!isempty(ARGS) ? ARGS[1] : joinpath(@__DIR__,"usr")) =#
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))

libcspice = LibraryProduct(prefix, "libcspice", :libcspice)

products = [libcspice]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaAstro/SPICEBuilder/releases/download/N0066"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    BinaryProvider.Linux(:aarch64, :glibc)     => ("$bin_prefix/cspice.aarch64-linux-gnu.tar.gz", "c99e1caca42d47650e832e47d9206e4667f548cbad1b863aaa03387b9cd93723"),
    BinaryProvider.Linux(:armv7l, :glibc)      => ("$bin_prefix/cspice.arm-linux-gnueabihf.tar.gz", "4454057c1fa433d375a0d7148403741a4d7cf40e1e7065bd0d5a0ad329a69cba"),
    BinaryProvider.Linux(:i686, :glibc)        => ("$bin_prefix/cspice.i686-linux-gnu.tar.gz", "5a8bbf8f307fb96e60c2089edf94e209e7af3db604e10f9f934ee1298455f220"),
    BinaryProvider.Windows(:i686)              => ("$bin_prefix/cspice.i686-w64-mingw32.tar.gz", "4706e18e1f8d41aa99a2e73f5e283eb0344ee7ccff1b59999c101810cba2b492"),
    BinaryProvider.Linux(:powerpc64le, :glibc) => ("$bin_prefix/cspice.powerpc64le-linux-gnu.tar.gz", "72597db2801735c5786690edc5a5cc25af5e218e91dd740d4c2f777ad41000c1"),
    BinaryProvider.MacOS()                     => ("$bin_prefix/cspice.x86_64-apple-darwin14.tar.gz", "d1f9e1c9e17c94669d0f5f5e9a353c3deb74cd4adc6cf74e204c54dd267b27a5"),
    BinaryProvider.Linux(:x86_64, :glibc)      => ("$bin_prefix/cspice.x86_64-linux-gnu.tar.gz", "0991482dab3eee10d56ac75e4eba6b1fdacd18532f554f31ab321b5d664b9827"),
    BinaryProvider.Windows(:x86_64)            => ("$bin_prefix/cspice.x86_64-w64-mingw32.tar.gz", "fb27fe7616b72c71fba1e74fec4ddd25d09fd5ef5c11df0d0fc9f5ddef7a9152"),
)

if any(!satisfied(p; verbose=verbose) for p in products)
    if platform_key() in keys(download_info)
	# Download and install binaries
	url, tarball_hash = download_info[platform_key()]
	install(url, tarball_hash; prefix=prefix, force=true, verbose=true)
    else
	error("Your platform $(Sys.MACHINE) is not supported by this package!")
    end

    # Finally, write out a deps.jl file
    write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
end
