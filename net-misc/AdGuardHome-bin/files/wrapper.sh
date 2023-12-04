#!/bin/sh

# small AdGuardHome wrapper so users don't mess up their /usr/bin/

# check if opts set config and work-dir
_check_opts() {
    local opt has_config has_workdir
    for opt in "${@}"; do
        case "${opt}" in
            -c|--config)
                has_config=yes
                ;;
            -w|--work-dir) 
                has_workdir=yes
                ;;
        esac
    done
    [ -n "${has_config}" ] && [ -n "${has_workdir}" ] && return 0
    return 1
}

# source ADGUARDHOME_OPTS from conf.d, if unset print warning and set defaults
[ -f /etc/conf.d/adguardhome ] && . /etc/conf.d/adguardhome

if [ -z "${ADGUARDHOME_OPTS}" ]; then
    echo "[warn] ADGUARDHOME_OPTS unset"
    echo "[warn] Defaulting to \"-c /etc/adguardhome/AdGuardHome.yaml -w /var/lib/adguardhome\""
    echo "[warn] Set in /etc/conf.d/adguardhome"
    ADGUARDHOME_OPTS="-c /etc/adguardhome/AdGuardHome.yaml -w /var/lib/adguardhome"
fi

if ! _check_opts ${ADGUARDHOME_OPTS} "${@}"; then
    echo "[err] -c|--config and -w|--work-dir are required"
    echo "[err] Either set via ADGUARDHOME_OPTS in /etc/conf.d/adguardhome or on CLI"
    exit 1
fi

# check both install dirs, then run if found
ADGUARDHOME_BIN="/opt/adguardhome/AdGuardHome"
[ ! -f "${ADGUARDHOME_BIN}" ] && echo "[err] AdGuardHome binary not found" && exit 1
exec "${ADGUARDHOME_BIN}" --no-check-update ${ADGUARDHOME_OPTS} "$@"
