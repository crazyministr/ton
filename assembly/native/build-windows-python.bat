REM execute this script inside elevated (Run as Administrator) console "x64 Native Tools Command Prompt for VS 2022"

echo off

call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"

echo Installing ninja...
choco install -y ninja
IF errorlevel 1 (
  echo Can't install ninja
  exit /b %errorlevel%
)

if not exist "zlib" (
git clone https://github.com/madler/zlib.git
cd zlib\contrib\vstudio\vc14
msbuild zlibstat.vcxproj /p:Configuration=ReleaseWithoutAsm /p:platform=x64 -p:PlatformToolset=v143

IF errorlevel 1 (
  echo Can't install zlib
  exit /b %errorlevel%
)
cd ..\..\..\..
) else (
echo Using zlib...
)

if not exist "secp256k1" (
git clone https://github.com/libbitcoin/secp256k1.git
cd secp256k1\builds\msvc\vs2017
msbuild /p:Configuration=StaticRelease -p:PlatformToolset=v143 -p:Platform=x64
IF errorlevel 1 (
  echo Can't install secp256k1
  exit /b %errorlevel%
)
cd ..\..\..\..
) else (
echo Using secp256k1...
)


if not exist "libsodium" (
curl  -Lo libsodium-1.0.18-stable-msvc.zip https://download.libsodium.org/libsodium/releases/libsodium-1.0.18-stable-msvc.zip
IF errorlevel 1 (
  echo Can't download libsodium
  exit /b %errorlevel%
)
unzip libsodium-1.0.18-stable-msvc.zip
) else (
echo Using libsodium...
)

if not exist "openssl-3.1.4" (
curl  -Lo openssl-3.1.4.zip https://github.com/neodiX42/precompiled-openssl-win64/raw/main/openssl-3.1.4.zip
IF errorlevel 1 (
  echo Can't download OpenSSL
  exit /b %errorlevel%
)
unzip -q openssl-3.1.4.zip
) else (
echo Using openssl...
)

if not exist "libmicrohttpd-0.9.77-w32-bin" (
curl  -Lo libmicrohttpd-0.9.77-w32-bin.zip https://github.com/neodiX42/precompiled-openssl-win64/raw/main/libmicrohttpd-0.9.77-w32-bin.zip
IF errorlevel 1 (
  echo Can't download libmicrohttpd
  exit /b %errorlevel%
)
unzip -q libmicrohttpd-0.9.77-w32-bin.zip
) else (
echo Using libmicrohttpd...
)

if not exist "readline-5.0-1-lib" (
curl  -Lo readline-5.0-1-lib.zip https://github.com/neodiX42/precompiled-openssl-win64/raw/main/readline-5.0-1-lib.zip
IF errorlevel 1 (
  echo Can't download readline
  exit /b %errorlevel%
)
unzip -q -d readline-5.0-1-lib readline-5.0-1-lib.zip
) else (
echo Using readline...
)


set root=%cd%
echo %root%
set SODIUM_DIR=%root%\libsodium

mkdir build
cd build
cmake -GNinja  -DCMAKE_BUILD_TYPE=Release ^
-DTON_USE_PYTHON=1 ^
-DTON_USE_ABSEIL=0 ^
-DPORTABLE=1 ^
-DSODIUM_USE_STATIC_LIBS=1 ^
-DSECP256K1_FOUND=1 ^
-DSECP256K1_INCLUDE_DIR=%root%\secp256k1\include ^
-DSECP256K1_LIBRARY=%root%\secp256k1\bin\x64\Release\v143\static\secp256k1.lib ^
-DMHD_FOUND=1 ^
-DMHD_LIBRARY=%root%\libmicrohttpd-0.9.77-w32-bin\x86_64\VS2019\Release-static\libmicrohttpd.lib ^
-DMHD_INCLUDE_DIR=%root%\libmicrohttpd-0.9.77-w32-bin\x86_64\VS2019\Release-static ^
-DZLIB_FOUND=1 ^
-DZLIB_INCLUDE_DIR=%root%\zlib ^
-DZLIB_LIBRARIES=%root%\zlib\contrib\vstudio\vc14\x64\ZlibStatReleaseWithoutAsm\zlibstat.lib ^
-DOPENSSL_FOUND=1 ^
-DOPENSSL_INCLUDE_DIR=%root%/openssl-3.1.4/x64/include ^
-DOPENSSL_CRYPTO_LIBRARY=%root%/openssl-3.1.4/x64/lib/libcrypto_static.lib ^
-DCMAKE_CXX_FLAGS="/DTD_WINDOWS=1 /EHsc /bigobj" ..
IF errorlevel 1 (
  echo Can't configure TON
  exit /b %errorlevel%
)

cmake --build . --config Release -j %NUMBER_OF_PROCESSORS% --target python_ton python_func
IF errorlevel 1 (
  echo Can't compile TON
  exit /b %errorlevel%
)