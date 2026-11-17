{ lib
, stdenv
, fetchurl
, pkg-config
, autoPatchelfHook
, lld
, otr
, luajit
, pkgsStatic
, pipewire
, freetype
, harfbuzz
, fontconfig
, fribidi
, gdk-pixbuf
, cairo
, libxkbcommon
, libdrm
, libgbm
, mesa
, libinput
, seatd
, udev
, libxcb
, libxcb-util
, vulkan-loader
, xwayland
, netcat-openbsd
}:

let
  version = "0.1.49";
in
stdenv.mkDerivation rec {
  pname = "zoolander";
  inherit version;

  srcs = [ ./zoolander-main.tar.gz ./zooland-main.tar.gz ];
  sourceRoot = ".";

  nativeBuildInputs = [ pkg-config autoPatchelfHook lld otr ];
  buildInputs = [
    stdenv.cc.cc.lib
    luajit
    pipewire
    freetype
    harfbuzz
    fontconfig
    fribidi
    gdk-pixbuf
    cairo
    libxkbcommon
    libdrm
    libgbm
    mesa
    libinput
    seatd
    udev
    libxcb
    libxcb-util
    libxcb.dev
    vulkan-loader
  ];

  postUnpack = ''
    [ -d zoolander ] || mv zoolander-* zoolander
    [ -d zooland ] || mv zooland-* zooland
  '';
  
  patchPhase = ''
    runHook prePatch

    grep -rl "/usr/share/glvnd" zooland/ zoolander/ | while read -r f; do
      substituteInPlace "$f" --replace-quiet "/usr/share/glvnd" "/run/opengl-driver/share/glvnd"
    done

    grep -rl "/usr/share/vulkan" zooland/ zoolander/ | while read -r f; do
      substituteInPlace "$f" --replace-quiet "/usr/share/vulkan" "/run/opengl-driver/share/vulkan"
    done
    
    grep -rl "/usr/bin/Xwayland" zoolander/ zooland/ | while read -r f; do
      substituteInPlace "$f" --replace-quiet "/usr/bin/Xwayland" "$out/libexec/Xwayland"
    done

    grep -rl "DRM_PLANE_TYPE_CURSOR" zooland/ | while read -r f; do
      substituteInPlace "$f" --replace-quiet \
        "var cursor_plane = find_plane(host, backend, planes, crtc_index, kms.DRM_PLANE_TYPE_CURSOR, &[0]u32{})" \
        "var cursor_plane: ?u32 = null"
    done
    
    substituteInPlace zoolander/zoolanderctl \
      --replace-quiet "nc " "${netcat-openbsd}/bin/nc "

    runHook postPatch
  '';
  
  buildPhase = ''
    runHook preBuild

     mkdir -p zoolander/vendor/luajit/include zoolander/vendor/luajit/lib zoolander/vendor/luajit/src
     ln -sf ${luajit}/include/luajit-*/* zoolander/vendor/luajit/include/
     ln -sf ${luajit}/lib/libluajit* zoolander/vendor/luajit/lib/
     ln -sf ${pkgsStatic.luajit}/lib/libluajit*.a zoolander/vendor/luajit/src/libluajit.a
    
     INC_FLAGS=""
     LIB_FLAGS=""

     for gcc_dir in ${stdenv.cc.cc}/lib/gcc/*/*; do
       [ -d "$gcc_dir" ] && LIB_FLAGS="$LIB_FLAGS -L $gcc_dir"
     done

     for p in ${lib.concatStringsSep " " (map (pkg: "${lib.getDev pkg}/include") buildInputs)}; do
       [ -d "$p" ] && INC_FLAGS="$INC_FLAGS -I $p"
     done
     for p in ${lib.concatStringsSep " " (map (pkg: "${lib.getLib pkg}/lib") buildInputs)}; do
       [ -d "$p" ] && LIB_FLAGS="$LIB_FLAGS -L $p"
     done

     for pkg in ${lib.concatStringsSep " " buildInputs}; do
       dev_dir=$(echo "$pkg" | sed 's/-bin$//')
       [ -d "$pkg/include" ] && INC_FLAGS="$INC_FLAGS -I $pkg/include"
       [ -d "$pkg/lib" ] && LIB_FLAGS="$LIB_FLAGS -L $pkg/lib"
     done
     for p in ${lib.concatStringsSep " " (map (pkg: "${lib.getLib pkg}/lib") buildInputs)}; do
     [ -d "$p" ] && LIB_FLAGS="$LIB_FLAGS -L $p"
     done

     mkdir -p zoolander/otr-out
     cd zoolander/otr-out

     otr build ../otr/native_main.otr --release --cpu baseline \
       -I ../vendor/luajit/include $INC_FLAGS $LIB_FLAGS \
       -rpath '$ORIGIN/../lib/zoolander' -o zoolander

     otr build ../otr/bell_player.otr ../otr/bell_audio_ffi.c --release --cpu baseline \
       --lib shared --pkg-config libpipewire-0.3 -I ../otr $INC_FLAGS $LIB_FLAGS -o libzoolander_bell.so

     otr build ../otr/audio_visualizer/capture_lib.otr ../otr/bell_audio_ffi.c ../otr/audio_visualizer/capture_ffi.c \
       --release --cpu baseline --lib shared --pkg-config libpipewire-0.3 -I ../otr $INC_FLAGS $LIB_FLAGS -o libzoolander_audio_visualizer.so
       
    runHook postBuild
  '';
  
  installPhase = ''
    runHook preInstall

 mkdir -p $out/bin $out/libexec $out/lib/zoolander $out/share/zoolander $out/share/wayland-sessions
 cp zoolander $out/bin/
 cp ../zoolanderctl $out/bin/
 chmod +x $out/bin/zoolanderctl
 cp libzoolander_bell.so libzoolander_audio_visualizer.so $out/lib/zoolander/
 cp -r ../config $out/share/zoolander/
    
    cat > $out/libexec/Xwayland << EOF
#!/bin/sh
exec ${xwayland}/bin/Xwayland -shm "\$@"
EOF
    chmod +x $out/libexec/Xwayland
    
    cat > $out/share/wayland-sessions/zoolander.desktop << EOF
[Desktop Entry]
Name=Zoolander
Comment=Zoolander Wayland Compositor
Exec=sh -c 'mkdir -p /home/fearless/.local/state && PATH=$out/libexec:\$PATH LD_LIBRARY_PATH=${vulkan-loader}/lib XCURSOR_PATH=/run/current-system/sw/share/icons XCURSOR_THEME=breeze_cursors XCURSOR_SIZE=24 VK_DRIVER_FILES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json exec dbus-run-session $out/bin/zoolander > /home/fearless/.local/state/zoolander.log 2>&1'
Type=Application
DesktopNames=zoolander
EOF
     
    runHook postInstall
  '';

  passthru.providedSessions = [ "zoolander" ];
  
}

