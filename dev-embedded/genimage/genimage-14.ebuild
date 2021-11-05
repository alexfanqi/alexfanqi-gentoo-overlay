# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools flag-o-matic

DESCRIPTION="tool to generate multiple filesystem and flash images from a tree"
HOMEPAGE="https://github.com/pengutronix/genimage"

LICENSE="GPL-2"
SLOT="0"

IUSE="static debug test"
RESTRICT="!test? ( test )"

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/pengutronix/genimage"
	inherit git-r3
else
	KEYWORDS="~amd64 ~riscv ~x86"
	SRC_URI="https://github.com/pengutronix/genimage/releases/download/v${PV}/${P}.tar.xz"
fi

RDEPEND="
	static? ( dev-libs/confuse[static-libs(+)] )
	!static? ( dev-libs/confuse )
"

DEPEND="
	${RDEPEND}
	test? (
		sys-apps/fakeroot
	)
"

BDEPEND="virtual/pkgconfig"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	use static && append-ldflags -static
	econf \
		--enable-hide \
		$(use_enable debug)
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc README.rst test.config flash.conf
}

pkg_postinst() {
	elog "Packages for additional image format support:"
	elog
	elog "    sys-fs/squashfs-tools    app-arch/cpio"
	elog "    sys-fs/cramfs            sys-fs/dosfstools"
	elog "    sys-apps/dtc             sys-fs/genext2fs"
	elog "    app-emulation/qemu       sys-fs/mtd-utils"
	#elog "    simg2img"
	#elog "    rauc"
	#elog "    genisoimage"
}
