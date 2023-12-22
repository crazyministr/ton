# export NIX_PATH=nixpkgs=https://github.com/nixOS/nixpkgs/archive/23.05.tar.gz

{ pkgs ? import <nixpkgs> { system = builtins.currentSystem; }
, lib ? pkgs.lib
, stdenv ? pkgs.stdenv
}:

pkgs.gcc11Stdenv.mkDerivation { # gcc
  pname = "ton";
  version = "x86_64-darwin";

  src = ./.;

  nativeBuildInputs = with pkgs;
    [ cmake ninja git pkg-config ];

  buildInputs = with pkgs;
   lib.forEach [
        secp256k1 libsodium.dev libmicrohttpd.dev gmp.dev nettle.dev libtasn1.dev libidn2.dev libunistring.dev gettext
      ]
      (x: x.overrideAttrs(oldAttrs: rec { configureFlags = (oldAttrs.configureFlags or []) ++ [ "--enable-static" "--disable-shared" "--disable-tests" ]; dontDisableStatic = true; }))
    ++ [
      darwin.apple_sdk.frameworks.CoreFoundation
      (openssl_3.override { static = true; }).dev
      (zlib.override { shared = false; }).dev
      (libiconv.override { enableStatic = true; enableShared = false; })
      ((gnutls.override { withP11-kit = false; }).overrideAttrs(oldAttrs: rec {
        cmakeFlags = (oldAttrs.cmakeFlags or []) ++ [ "-fpermissive" "-Wno-error=implicit-int" ];
        configureFlags = (oldAttrs.configureFlags or []) ++ [ "--enable-static" "--disable-shared" "--disable-tests" ]; dontDisableStatic = true;
       })).dev
   ];


  dontAddStaticConfigureFlags = true;
  doCheck = false;
  makeStatic = true;

  configureFlags = [];

  cmakeFlags = [
    "-DTON_USE_ABSEIL=OFF"
    "-DNIX=ON"
    "-DCMAKE_CROSSCOMPILING=OFF"
    "-DCMAKE_LINK_SEARCH_START_STATIC=ON"
    "-DCMAKE_LINK_SEARCH_END_STATIC=ON"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DCMAKE_CXX_FLAGS=-fpermissive -Wno-error=implicit-int"
    "-DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=11.3"
  ];

  LDFLAGS = [
    "-static-libgcc"
    "-framework CoreFoundation"
  ];

   postInstall = ''
      moveToOutput bin "$bin"
   '';

   preFixup = ''
      for fn in "$bin"/bin/* "$out"/lib/*.dylib; do
        echo Fixing libc++ in "$fn"
        install_name_tool -change "$(otool -L "$fn" | grep libc++.1 | cut -d' ' -f1 | xargs)" libc++.1.dylib "$fn"
        install_name_tool -change "$(otool -L "$fn" | grep libc++abi.1 | cut -d' ' -f1 | xargs)" libc++abi.dylib "$fn"
      done
   '';
   outputs = [ "bin" "out" ];
}
