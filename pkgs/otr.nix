{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, zlib
, ncurses
, libxml2
}:

stdenv.mkDerivation rec {
  pname = "otr";
  version = "0.2.6";

  src = fetchurl {
    url = "https://pika-os.com{version}/otr-x86_64-linux.tar.xz";
    hash = "sha256-UdzS4yqkmEqvUYK9dw2XlsDwq55jVf1XHBVCzclp36M=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib zlib ncurses libxml2 ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r ./* $out/

    mv "$out/lib/otr/llvm/bin/clang" "$out/lib/otr/llvm/bin/clang.real"
    cat > "$out/lib/otr/llvm/bin/clang" << 'EOF'
#!/bin/sh
first=1
for arg in "$@"; do
  if [ "$first" = 1 ]; then
    set --
    first=0
  fi
  case "$arg" in
    -flto|-flto=*) ;;
    *) set -- "$@" "$arg" ;;
  esac
done
exec "$(dirname "$0")/clang.real" "$@"
EOF
    chmod +x "$out/lib/otr/llvm/bin/clang"

    runHook postInstall
  '';  
}

