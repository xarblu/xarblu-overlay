# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="System user for Crafty Controller"
ACCT_USER_ID="654"
ACCT_USER_GROUPS=( crafty )

acct-user_add_deps
