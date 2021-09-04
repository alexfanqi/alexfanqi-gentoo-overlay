# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

MY_PN="${PN%-bin}"
MY_P=${MY_PN}-${PV}

abi_uri() {
	local os=linux
	echo "${2-$1}? (
			https://github.com/screego/server/releases/download/v${PV}/${MY_PN}_${PV}_linux_${1}.tar.gz
		)"
}

DESCRIPTION="Screego is a screen sharing tool for developers"
HOMEPAGE="https://github.com/screego/server/blob/master/README.md"
SRC_URI="
	$(abi_uri arm64)
	$(abi_uri ppc64le ppc64)
	$(abi_uri amd64)
	$(abi_uri i386 x86)
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="nginx"

RDEPEND="
	nginx? ( www-servers/nginx )
"

# Do not complain about CFLAGS etc since we don't use them
QA_FLAGS_IGNORED='.*'
QA_PRESTRIPPED="opt/screego/screego"

src_unpack() {
	# upstream tar ball doesn't contain top level dir
	mkdir -p $S || die
	cd $S || die
	unpack ${A}
}

src_install() {
	insinto /etc/${MY_PN}
	newins screego.config.example screego.config

	newinitd "${FILESDIR}"/${MY_PN}.initd ${MY_PN}
	systemd_dounit "${FILESDIR}"/${MY_PN}.service

	insinto /opt/${MY_PN}
	doins screego
	fperms -R +x /opt/${MY_PN}/

	dodoc README.md
	dodoc LICENSE
}

pkg_postinst() {
	elog "Please set SCREEGO_EXTERNAL_IP or SCREEGO_TURN_EXTERNAL_IP in /etc/${MY_PN}/screego.config"
}
