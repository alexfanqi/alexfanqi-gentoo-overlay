# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="An Accurate Open-Source Library for Visual, Visual-Inertial and Multi-Map SLAM"
HOMEPAGE="https://github.com/UZ-SLAMLab/ORB_SLAM3"
SRC_URI="https://github.com/UZ-SLAMLab/ORB_SLAM3/archive/refs/tags/v${PV}-release.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN^^}-${PV}-release"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 riscv"
IUSE=""
REQUIRED_USE=""

# no test exists upstream
RESTRICT="test"

RDEPEND="
	media-libs/pangolin
	>media-libs/opencv-4.4
	dev-cpp/eigen:3
	dev-libs/boost:=
	dev-libs/openssl:0=
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-cmake-fix.patch"
	"${FILESDIR}/${PN}-remove-march-native.patch"
)

DOCS=( README.md Changelog.md )

src_install() {
	cmake_src_install
	einstalldocs
}
