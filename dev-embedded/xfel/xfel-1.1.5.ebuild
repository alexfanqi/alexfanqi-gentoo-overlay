# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs udev

DESCRIPTION="Tiny FEL tools for allwinner SOC, support RISC-V D1 chip"
HOMEPAGE="https://github.com/xboot/xfel"

LICENSE="MIT"
SLOT="0"

if [[ ${PV} == "9999" ]]; then
	KEYWORDS=""
	EGIT_REPO_URI="https://github.com/xboot/xfel.git"
	inherit git-r3
else
	KEYWORDS="~amd64 ~x86 ~riscv"
	SRC_URI="https://github.com/xboot/xfel/archive/refs/tags/v${PV}.tar.gz -> ${PF}.tar.gz"
fi

DEPEND="
	>=dev-libs/libusb-1.0.0
"

BDEPEND="
	virtual/pkgconfig
	"
src_prepare() {
	# make it respect user CC CFLAGS etc.
	local my_remove=(CC CXX LD AR OC OD ASFLAGS CFLAGS CXXFLAGS LDFLAGS)
	my_remove=$(printf -- "-e /^%s/d " "${my_remove[@]}")
	sed -i -e '/^AS/s/$(CROSS)gcc/$(CC)/' $my_remove Makefile
	eapply_user
}

src_configure() {
	tc-export CC CXX LD AR OBJCOPY OBJDUMP
}

src_compile() {
	emake ASFLAGS=$CFLAGS OC=$OBJCOPY OD=$OBJDUMP
}

src_install() {
	dobin xfel
	udev_dorules 99-xfel.rules 
	dodoc README.md 
}
