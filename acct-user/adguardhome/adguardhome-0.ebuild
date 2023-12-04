# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="System user for AdGuardHome"
ACCT_USER_ID="621"
ACCT_USER_HOME=/var/lib/adguardhome
ACCT_USER_GROUPS=( adguardhome )

acct-user_add_deps
