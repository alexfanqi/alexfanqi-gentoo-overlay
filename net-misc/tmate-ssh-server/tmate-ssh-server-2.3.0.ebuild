# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools systemd
DESCRIPTION="Server for tmate, an instant terminal sharing tool"
HOMEPAGE="https://github.com/tmate-io/tmate-ssh-server"

LICENSE="MIT"
SLOT="0"

KEYWORDS="~amd64 ~riscv ~x86 "
SRC_URI="https://github.com/tmate-io/tmate-ssh-server/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

IUSE="debug static"

DEPEND="
	>=net-libs/libssh-0.7.0[server]
	dev-libs/libbsd
	sys-libs/ncurses
	dev-libs/libevent
	>=dev-libs/msgpack-1.2.0
	sys-libs/libutempter
	"

RDEPEND="
	virtual/ssh
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
}

pkg_postinst() {
	local KEY_DIR="etc/tmate-ssh-server"
	einfo "You need to modify certain variables for systemd or OpenRC services to work"
	einfo "See ${EROOT}/etc/conf.d/tmate-ssh-server.confd for OpenRC users"
	einfo "See ${EROOT}/etc/systemd/system/tmate-ssh-server.service.d/ for systemd users"
	einfo "If you want to generate a server ssh key, use emerge --config, or alternatively,"
	einfo "run ${EROOT}/usr/bin/ssh-keygen -t rsa -f ${EROOT}/${KEY_DIR}/ssh_host_rsa_key"
	einfo "and ${EROOT}/usr/bin/ssh-keygen -t ed25519 -f ${EROOT}/${KEY_DIR}/ssh_host_ed25519_key"
}

pkg_config() {
	local KEY_DIR="etc/tmate-ssh-server"
	if [[ -n "$(ls -A ${EROOT}/${KEY_DIR} 2> /dev/null)" ]] ; then
		einfo "The server key directory, ${EROOT}/${KEY_DIR} is not empty"
		einfo 'No key will be generated'
	else
		mkdir -p "${EROOT}/${KEY_DIR}"/ || die
		elog "Generating ssh key for tmate server in ${EROOT}/${KEY_DIR}"
		for keytype in rsa ed25519; do
			"${EROOT}"/usr/bin/ssh-keygen -t $keytype -f "${EROOT}/${KEY_DIR}"/ssh_host_${keytype}_key -N ''
		done
	fi
}
