# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DOCS_AUTODOC=0
DOCS_BUILDER="sphinx"
DOCS_DIR="doc/sphinx/source"
PYTHON_COMPAT=( python3_{8..10} pypy3 )
LLVM_MAX_SLOT=13

inherit cmake llvm python-any-r1 docs git-r3

DESCRIPTION="Portable Computing Language (an implementation of OpenCL)"
HOMEPAGE="http://portablecl.org https://github.com/pocl/pocl"

EGIT_REPO_URI="https://github.com/vortexgpgpu/pocl.git"

LICENSE="GPL-2"
SLOT="0"
# TODO: hsa tce
IUSE="accel cl20 +conformance cuda debug examples float-conversion hardening +hwloc memmanager test"
# Tests not yet passing, fragile in Portage environment(?)
RESTRICT="!test? ( test ) test"

# TODO: add dependencies for cuda
# Note: No := on LLVM because it pulls in Clang
# see llvm.eclass for why
CLANG_DEPS="!cuda? ( <sys-devel/clang-$((${LLVM_MAX_SLOT} + 1)):= )
	cuda? ( <sys-devel/clang-$((${LLVM_MAX_SLOT} + 1)):=[llvm_targets_NVPTX] )"
RDEPEND="
	dev-libs/libltdl
	<sys-devel/llvm-$((${LLVM_MAX_SLOT} + 1)):*
	virtual/opencl

	${CLANG_DEPS}
	debug? ( dev-util/lttng-ust:= )
	hwloc? ( sys-apps/hwloc:=[cuda?] )
"
DEPEND="${RDEPEND}"
BDEPEND="${CLANG_DEPS}
	virtual/pkgconfig
	doc? (
		$(python_gen_any_dep '<dev-python/markupsafe-2.0[${PYTHON_USEDEP}]')
	)"

PATCHES=(
	"${FILESDIR}/vendor_opencl_libs_location.patch"
	"${FILESDIR}/assert_fail_in_cpu_setup_vector_widths.patch"
	"${FILESDIR}/link_against_libclang-cpp.patch"
	"${FILESDIR}/llvm11-support.patch"
	"${FILESDIR}/fix_llvm11_changes.patch"
	"${FILESDIR}/llvm12-support.patch"
	"${FILESDIR}/llvm13-support.patch"
	"${FILESDIR}/fix_invalid_werror.patch"
	"${FILESDIR}/workaround_undefined_reserve_id_t_in_llvm13.patch"
)

python_check_deps() {
	has_version -b "<dev-python/markupsafe-2.0[${PYTHON_USEDEP}]"
}

llvm_check_deps() {
	local usedep=$(usex cuda "[llvm_targets_NVPTX]" '')

	# Clang is used at both build time (executed) and runtime
	has_version -r "sys-devel/llvm:${LLVM_SLOT}${usedep}" && \
		has_version -r "sys-devel/clang:${LLVM_SLOT}${usedep}" && \
		has_version -b "sys-devel/clang:${LLVM_SLOT}${usedep}"
}

pkg_setup() {
	use doc && python-any-r1_pkg_setup

	llvm_pkg_setup
}

src_unpack() {
	if use riscv ; then
		EGIT_REPO_URI="https://github.com/vortexgpgpu/pocl.git"
	else
		EGIT_REPO_URI="https://github.com/pocl/pocl.git"
	fi
	git-r3_src_unpack
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DENABLE_HSA=OFF
		-DENABLE_ICD=ON
		-DENABLE_POCL_BUILDING=ON
		-DKERNELLIB_HOST_CPU_VARIANTS=native
		-DPOCL_ICD_ABSOLUTE_PATH=ON
		-DSTATIC_LLVM=OFF
		-DWITH_LLVM_CONFIG=$(get_llvm_prefix -d "${LLVM_MAX_SLOT}")/bin/llvm-config

		-DENABLE_ACCEL_DEVICE=$(usex accel)
		-DENABLE_CONFORMANCE=$(usex conformance)
		-DENABLE_CUDA=$(usex cuda)
		-DENABLE_HOST_CPU_DEVICE_CL20=$(usex cl20)
		-DENABLE_HWLOC=$(usex hwloc)
		-DENABLE_POCL_FLOAT_CONVERSION=$(usex float-conversion)
		-DHARDENING_ENABLE=$(usex hardening)
		-DPOCL_DEBUG_MESSAGES=$(usex debug)
		-DUSE_POCL_MEMMANAGER=$(usex memmanager)
		-DENABLE_TESTS=$(usex test)
	)

	if use riscv ; then
		mycmakeargs+=(
			-DLLC_HOST_CPU=sifive-u74
			#-DDHOST_DEVICE_BUILD_HASH=riscv64-unknown-linux-gnu-rv64gc
		)
	fi

	cmake_src_configure
}

src_compile() {
	cmake_src_compile
	docs_compile
}

src_test() {
	export POCL_BUILDING=1
	export POCL_DEVICES=basic
	export CTEST_OUTPUT_ON_FAILURE=1
	export TEST_VERBOSE=1

	# Referenced https://github.com/pocl/pocl/blob/master/.drone.yml
	# But couldn't seem to get tests working yet
	cmake_src_test
}

src_install() {
	cmake_src_install

	dodoc CREDITS README CHANGES

	if use doc; then
		dodoc -r _build/html
		docompress -x /usr/share/doc/${P}/html
	fi

	if use examples; then
		dodoc -r examples
		docompress -x /usr/share/doc/${P}/examples
	fi
}
