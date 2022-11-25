# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )

inherit cmake flag-o-matic python-single-r1

DESCRIPTION="A library for managing OpenGL display / interaction and abstracting video input"
HOMEPAGE="https://github.com/stevenlovegrove/Pangolin"
SRC_URI="https://github.com/stevenlovegrove/Pangolin/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Pangolin-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 riscv"
IUSE="+python test"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RESTRICT="!test? ( test )"

RDEPEND="
	media-libs/libpng:0=
	media-libs/libjpeg-turbo:=
	media-libs/openexr:0=
	dev-cpp/eigen:3
	media-libs/glew:=
	x11-libs/libxkbcommon
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			dev-python/pybind11[${PYTHON_USEDEP}]
		')
	)
"
DEPEND="${RDEPEND}
	test? ( <dev-cpp/catch-3 )
"

PATCHES=(
    "${FILESDIR}/${PN}-fix-multilib.patch"
    "${FILESDIR}/${PN}-libatomic.patch"
)

DOCS=( README.md )

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	cmake_src_prepare

	pushd components/pango_python > /dev/null || die
		cmake_comment_add_subdirectory pybind11
	popd > /dev/null || die
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTS=$(usex test)
		-DBUILD_PANGOLIN_PYTHON=$(usex python)
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	einstalldocs
}
