# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGIT_REPO_URI="https://github.com/tmate-io/tmate-ssh-server"
inherit git-r3 autotools systemd
DESCRIPTION="Tmate server side"
HOMEPAGE="https://github.com/tmate-io/tmate-ssh-server"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="debug static"

DEPEND="
	>=net-libs/libssh-0.7.0[server]
	dev-libs/libbsd
	sys-libs/ncurses
	dev-libs/libevent
	>=dev-libs/msgpack-1.2.0
	"

RDEPEND="
	${DEPEND}
	"

BDEPEND="
	virtual/pkgconfig
	"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable static) \
		$(use_enable debug)
}

src_install(){
	emake DESTDIR="${D}" install
	einstalldocs
	newinitd "${FILESDIR}/tmate-ssh-server.initd" tmate-ssh-server
	doconfd "${FILESDIR}/tmate-ssh-server.confd"
	systemd_newunit "${FILESDIR}/tmate-ssh-server.service" tmate-ssh-server.service
	systemd_install_serviced "${FILESDIR}/tmate-ssh-server.service.conf"
	einfo "You need to configure proper variables for systemd or openRC services to work"
	einfo "run create_keys.sh to generate ssh key in server config directory if you haven't"
}
