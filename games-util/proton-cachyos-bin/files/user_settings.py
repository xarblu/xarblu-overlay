# The user_settings below is generated from proton-cachyos README.md file using:
# curl --silent https://raw.githubusercontent.com/CachyOS/proton-cachyos/refs/heads/cachyos_main/README.md | perl -e 'print "user_settings = {\n    # Available options for Proton CachyOS\n"; while (<>) { chomp; last if /^Retired/; print "\n    # $2\n    #\"$1\": \"\",\n" if /^\|.*\|\s*`(\S+)`\s*\|\s*(.*?)\s*\|$/ }; print "}\n"'
#
# There may be additional options available that are not mentioned in the README.
# Feel free to add these here using the same `"<OPTION>": "<VALUE>",` syntax.

user_settings = {
    ### Options for Proton CachyOS ###

    # Convenience method for dumping a useful debug log to `$PROTON_LOG_DIR/steam-$APPID.log`. Set to `1` to enable default logging, or set to a string to be appended to the default `WINEDEBUG` channels.
    #"PROTON_LOG": "",

    # Output log files into the directory specified. Defaults to your home directory.
    #"PROTON_LOG_DIR": "",

    # Wait for a debugger to attach to steam.exe before launching the game process. To attach to the game process at startup, debuggers should be set to follow child processes.
    #"PROTON_WAIT_ATTACH": "",

    # Write crash logs into this directory. Does not clean up old logs, so may eat all your disk space eventually.
    #"PROTON_CRASH_REPORT_DIR": "",

    # Use OpenGL-based wined3d instead of Vulkan-based DXVK for d3d11, d3d10, and d3d9.
    #"PROTON_USE_WINED3D": "",

    # Disable `d3d11.dll`, for d3d11 games which can fall back to and run better with d3d9.
    #"PROTON_NO_D3D11": "",

    # Disable `d3d10.dll` and `dxgi.dll`, for d3d10 games which can fall back to and run better with d3d9.
    #"PROTON_NO_D3D10": "",

    # Use DXVK's `d3d8.dll`.
    #"PROTON_DXVK_D3D8": "",

    # Do not use futex-based in-process synchronization primitives. (Automatically disabled on systems with no `FUTEX_WAIT_MULTIPLE` support.)
    #"PROTON_NO_FSYNC": "",

    # Set value to a locale to override all other system locale settings for a game.  This variable should be used instead of `LC_ALL`.
    #"HOST_LC_ALL": "",

    # Disable NVIDIA's NVAPI GPU support library.
    #"PROTON_DISABLE_NVAPI": "",

    # Force Wine to enable the LARGE_ADDRESS_AWARE flag for all executables. Enabled by default.
    #"PROTON_FORCE_LARGE_ADDRESS_AWARE": "",

    # Delay freeing some memory, to work around application use-after-free bugs.
    #"PROTON_HEAP_DELAY_FREE": "",

    # Create an S: drive which points to the Steam Library which contains the game.
    #"PROTON_SET_GAME_DRIVE": "",

    # Set some driver overrides to limit the length of the GL extension string, for old games that crash on very long extension strings.
    #"PROTON_OLD_GL_STRING": "",

    # Enable hack to work around video issues in some games due to incomplete IMFDXGIDeviceManager support.
    #"WINE_DO_NOT_CREATE_DXGI_DEVICE_MANAGER": "",

    # Enable hack to disable Vulkan other process window rendering which sometimes causes issues on Wayland due to blit being one frame behind.
    #"WINE_DISABLE_VULKAN_OPWR": "",

    # Force Nvidia GPUs to always be reported as AMD GPUs. Some games require this if they depend on Windows-only Nvidia driver functionality. See also DXVK's nvapiHack config, which only affects reporting from Direct3D.
    #"PROTON_HIDE_NVIDIA_GPU": "",

    # Enable integer scaling mode, to give sharp pixels when upscaling.
    #"WINE_FULLSCREEN_INTEGER_SCALING": "",

    # Enable KDE-specific windowing hacks that may improve experience with KDE older than 6.4 on Wayland and KDE older than 6.6 on X11.
    #"WINE_USE_KWIN_HACKS": "",

    # Enable Xalia, a program that can add a gamepad UI for some keyboard/mouse interfaces, or set to 0 to disable. The default is to enable it dynamically based on window contents.
    #"PROTON_USE_XALIA": "",

    # Force FNA to use D3D11 for rendering.
    #"FNA3D_FORCE_DRIVER=D3D11": "",

    # **Note: Obsoleted in Proton 5.13.** In older versions, enable seccomp-bpf filter to emulate native syscalls, required for some DRM protections to work.
    #"PROTON_USE_SECCOMP": "",

    # **Note: Obsoleted in Proton 5.0.** In older versions, use Vulkan-based DXVK instead of OpenGL-based wined3d for d3d9.
    #"PROTON_USE_D9VK": "",

    # In case of videos/audio not playing or being replaced by the [SMPTE color bars](https://en.wikipedia.org/wiki/SMPTE_color_bars), use`"+mfplat,+quartz,+wmvcore,+wmadec,+dmo"` instead of `1`.
    #"PROTON_LOG": "",

    # Use the [dxvk-sarek](https://github.com/pythonlover02/DXVK-Sarek) fork as DXVK replacement for older GPUs that don't properly support Vulkan 1.3 (supported Vulkan 1.1.x to 1.2.x). It is using the `async` branch, so it **SHOULD NOT** to be used with games using anti-cheat or multiplayer games in general. You have been warned.
    #"PROTON_DXVK_SAREK": "",

    # Enable the alternative [dxvk-low-latency](https://github.com/netborg-afps/dxvk-low-latency) fork, which enhances the original dxvk with low-latency frame pacing capabilities to improve game responsiveness and input lag. It also improves latency stability over time, usually resulting in a more accurate playback speed of the generated video. Refer to the project's [documentation](https://github.com/netborg-afps/dxvk-low-latency#options) for in-depth configuration.
    #"PROTON_DXVK_LOWLATENCY": "",

    # Use `ddraw.dll` from the [D7VK project](https://github.com/WinterSnowfall/d7vk) for DirectX 7-or-lower games.
    #"PROTON_D7VK_DDRAW": "",

    # Automatically download `amdxcffx64.dll` and upgrade games with FSR 3.1 to use FSR 4. Version to download can be specified by supplying it as a value, like so `PROTON_FSR4_UPGRADE="4.0.1"`, instead of `1`. Downloads the latest available and known-good version of the required DLL by default.
    #"PROTON_FSR4_UPGRADE": "",

    # Enable the FSR4 watermark at the top left portion of the screen. This is a shorthand option for setting `FSR_WATERMARK=1` and `FSR_FG_WATERMARK=1`.
    #"PROTON_FSR4_INDICATOR": "",

    # Enables the use of MLFG with FSR4 >= `4.0.3`.
    #"PROTON_MLFG_UPGRADE": "",

    # Automatically download and use newer versions of `nvngx_dlss(d\|g).dll` DLLs. Version to download can be specified by supplying it as a value, like so `PROTON_DLSS_UPGRADE="310.2"`, instead of `1`, to download version `310.2.1.0`. This option also sets `DXVK_NVAPI_DRS_SETTINGS` to use the latest preset. If you provide your own configuration through this environment variable, your configuration will override the defaults.
    #"PROTON_DLSS_UPGRADE": "",

    # Enable the DLSS overlay at the bottom left portion of the screen.
    #"PROTON_DLSS_INDICATOR": "",

    # 
    #"PROTON_XESS_UPGRADE": "",

    # 
    #"PROTON_FFX3_UPGRADE": "",

    # 
    #"PROTON_FFX4_UPGRADE": "",

    # Enable [alternative implementations of Nvidia libraries](https://github.com/SveSop/nvidia-libs) missing from Proton. Allows things like hardware-accelerated PhysX to function and should be use **only when needed**. This option enables all of `nvcuda`, `nvenc`, `nvml` and `nvoptix`. These are incompatible with `wow64` and thus disabled when `PROTON_USE_WOW64=1` is set.
    #"PROTON_NVIDIA_LIBS": "",

    # Use with the previous option, to enable only the 64bit nvidia libraries. Useful if you are using RTX series 4000 or 5000 GPUs and you had bad performance or crashes when enabling these with 32bit games.
    #"PROTON_NVIDIA_LIBS_NO_32BIT": "",

    # Enable alternative `nvcuda.dll` [from nvidia-libs](https://github.com/SveSop/nvcuda) only.
    #"PROTON_NVIDIA_NVCUDA": "",

    # Enable alternative `nvcencodeapi(64).dll` [from nvidia-libs](https://github.com/SveSop/nvenc) only.
    #"PROTON_NVIDIA_NVENC": "",

    # Enable alternative `nvml.dll` [from nvidia-libs](https://github.com/Saancreed/wine-nvml) only. This option is enabled by default.
    #"PROTON_NVIDIA_NVML": "",

    # Enable alternative `nvoptix.dll` [from nvidia-libs](https://github.com/SveSop/wine-nvoptix) only.
    #"PROTON_NVIDIA_NVOPTIX": "",

    # Disable window decorations by the the window manager, use wine's own window decorations.
    #"PROTON_NO_WM_DECORATION": "",

    # Enable Wayland support. `winewayland` is experimental and work-in-progress, expect issues. When reporting issues ALWAYS mention if you using this environment variable, and make sure the issue still happens without it. Valve's Protons do not include `winewayland.drv`, they always use `winex11.drv`. For more information refer to [this section](https://github.com/CachyOS/proton-cachyos?tab=readme-ov-file#proton-wayland-quirks)
    #"PROTON_ENABLE_WAYLAND": "",

    # Alias of `PROTON_ENABLE_WAYLAND`
    #"PROTON_USE_WAYLAND": "",

    # Enable the `winepipewire.drv` audio driver. This audio driver is enabled by default and can be disabled with `PROTON_USE_PIPEWIRE=0`. For more information and further configuration refer to [this section](https://github.com/CachyOS/proton-cachyos?tab=readme-ov-file#pipewire-audio-driver)
    #"PROTON_USE_PIPEWIRE": "",

    # Enables HDR when set to `DXVK_HDR=1`, optionally combined with `ENABLE_HDR_WSI=1` if required, on Nvidia driver versions older than `595.x.x`.
    #"DXVK_HDR": "",

    # The opposite of `DXVK_HDR=1`, forcefully disables HDR if it is automatically enabled. **NOTE**: Presently Gnome does **not** support enough color management features to expose HDR automatically.
    #"DXVK_NO_HDR": "",

    # Uses SDL input instead of HIDRAW/Steam Input
    #"PROTON_PREFER_SDL": "",

    # Alias of `PROTON_PREFER_SDL`
    #"PROTON_USE_SDL": "",

    # 
    #"PROTON_NO_STEAMINPUT": "",

    # Enable per-game shader cache even if "Shader Pre-caching" is disabled. Any configuration set by this option can be overriden, i.e. if one of the environment variables is already set, the user-set value will be used. The default configuration is set up to mimic Steam's "Shader Pre-Caching", with shaders being cached under `<steamlibrary>/shadercache/<appid>` for each game.
    #"PROTON_LOCAL_SHADER_CACHE": "",

    # For debugging purposes, do not use.
    #"PROTON_ENABLE_MEDIACONV": "",

    # Fixes video/audio playback in cutscenes in some cases.
    #"PROTON_MEDIA_FORCE_GST": "",

    # Change the orientation (rotation) of videos rendered using gstreamer. The accepted values are [the same as gstreamer's `videoflip` plugin](https://gstreamer.freedesktop.org/documentation/videofilter/videoflip.html?gi-language=c#named-constant)
    #"PROTON_GST_VIDEO_ORIENTATION": "",

    # Enables [DXVK-NVAPI's Vulkan Reflex layer](https://github.com/jp7677/dxvk-nvapi?tab=readme-ov-file#vulkan-reflex-layer) to support [Reflex in Vulkan](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/gaming.html#reflex-for-vulkan-steam-play-proton) games. It's meant to enable Reflex in games such as Portal RTX, Path of Exile 1 and 2 and Doom TDA, etc.
    #"DXVK_NVAPI_VKREFLEX": "",

    # Enables [`low_latency_layer`](https://github.com/Korthos-Software/low_latency_layer), for more information and and configuration options refer to the projects README.
    #"LOW_LATENCY_LAYER": "",

    # Enables automatic [OptiScaler](https://github.com/optiscaler/OptiScaler) injection. For more information refer to [this section](https://github.com/CachyOS/proton-cachyos?tab=readme-ov-file#optiscaler-integration)
    #"PROTON_USE_OPTISCALER": "",

    # Enables [`rpc-bridge`](https://github.com/enderice2/rpc-bridge) to allow games running in Proton to set Discord's Rich Presence.
    #"PROTON_DISCORD_BRIDGE": "",

    # Provides a list of hosts for Wine to not connect to. The list can be either comma (`,`) or semicolon (`;`) separated, i.e `WINE_BLOCK_HOSTS=host1.org,host2.net`. The maximum number of hosts is 16 and the maximum length of each host is 256 characters.
    #"WINE_BLOCK_HOSTS": "",

    # Allows to select more than two channels with the winealsa driver as well as force disable spatial audio in games. Can be useful with surround setups or when the sounds come out wrong positionally (like dialogue coming out only from the left speaker). Possible values is the number of speakers, such as `2` (to disable spatial audio), such as `4` (2 front, 2 rear), `6` (5.1) or `8` (7.1).
    #"WINEALSA_CHANNELS": "",

    # Properly downmixes spatial with `winealsa` and includes the height channels. Use `1` to enable, `0` to disable (default). Recommended only if there are spatial audio errors with the `WINEALSA_CHANNELS` variable
    #"WINEALSA_SPATIAL": "",

    # Comma-separated list of audio drivers for wine to choose from. The default list is `pipewire,pulse,alsa`. For example `WINE_AUDIO_DRIVER=pulse` will use `winepulse.drv` exclusively.
    #"WINE_AUDIO_DRIVER": "",

    # 
    #"GST_GL_WINDOW": "",
}
