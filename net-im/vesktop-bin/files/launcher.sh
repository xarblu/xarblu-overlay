#!/usr/bin/env bash

EBUILD_WAYLAND_DEFAULT=%WL_DEF%

CMD=( "/opt/vesktop-bin/vesktop" )

if (( EBUILD_WAYLAND_DEFAULT )) && [[ -n "${WAYLAND_DISPLAY}" ]]; then
	CMD+=(
		"--enable-features=UseOzonePlatform,WaylandWindowDecorations,VaapiVideoDecodeLinuxGL"
		"--ozone-platform=wayland"
	)
fi

exec "${CMD[@]}" "${@}"
