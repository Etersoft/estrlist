#!/bin/sh

LIST1="field.1 field-2"
LIST2="field.1 field-2 field3 field4"
LIST3="field"

. ./strings

estrlist()
{
        ../bin/estrlist "$@"
}


check()
{
        local result="`$3 "$4" "$5"`"
        [ "$2" != "$result" ] && echo "FATAL with '$1': result '$result' do not match with '$2' (command $3 \"$4\" \"$5\")" || echo "OK for '$1' with '$2' for '$3 \"$4\" \"$5\"'"
}

# exclude
# exclude regexp
# filter 

check 1 "field3 field4" do_exclude_list "$LIST1" "$LIST2"
#check 1.1 "field3 field4" "estrlist wordexclude" "$LIST1" "$LIST2"
check 2 "" do_exclude_list "$LIST2" "$LIST1"
check 2.1 "$LIST2" do_exclude_list "fiel.*" "$LIST2"
check 3 "field" do_exclude_list "$LIST1" "$LIST3"
check 3.1 "field3 field4" do_exclude_list "$LIST1" "$LIST2"
#check 3.1 "field" "estrlist wordexclude" "$LIST1" "$LIST3"
check 4 "field-2 field4" do_exclude_list "field.1 field3" "$LIST2"
#check 4 "" "`do_exclude_list "field3 field[24]" "$LIST2"`"
check 5 "$LIST2" do_exclude_list "fiel" "$LIST2"
check 6 "$LIST2" do_exclude_list "" "$LIST2"
check 7 "$LIST1" do_exclude_list "$LIST3" "$LIST1"
check 8 "lyx ly ly" do_exclude_list "lyx-tex" "lyx lyx-tex ly ly"
check 8.1 "lyx ly ly" do_exclude_list "lyx.tex" "lyx lyx.tex ly ly"

echo
check "reg 1" "field.1 field-2" regexp_exclude_list "field3 field[24]" "$LIST2"
check "reg 2" "$LIST2" "estrlist reg_wordexclude" "fiel" "$LIST2"
check "reg 3" "field.1 field-2 field3" regexp_exclude_list "field[24]" "$LIST2"
check "reg 4" "$LIST1" regexp_exclude_list "field" "$LIST1"
check "reg 4.1" "$LIST1" regexp_exclude_list "fiel" "$LIST1"
check "reg 5" "$LIST1" regexp_exclude_list "el" "$LIST1"
check "reg 6" "list" regexp_exclude_list "fi.*" "$LIST1 list $LIST1"
check "reg 7" "list" regexp_exclude_list ".*el.*" "$LIST1 list $LIST1"
check "reg 8" "lyx ly ly" regexp_exclude_list "lyx-.*" "lyx lyx-tex ly ly"

echo
check "intersection 1" "$LIST1" "estrlist intersection" "$LIST1" "$LIST2"
check "intersection 2" "8 4" "estrlist intersection" "1 4 3 5 8 7" "9 8 6 4 2"

check "difference 1" "1 1 3 7 9 6 2" "estrlist difference" "1 4 5 1 3 5 8 7" "9 8 6 5 4 2"

# FIXME: нужно это?
echo
check "remove 1" "field.1" "estrlist reg_exclude" "field-2" "$LIST1"
check "remove 1.1" "$LIST1" "estrlist reg_exclude" "field2" "$LIST1"
# FIXME: regexp??
check "remove 2" "field.1 field-2" "estrlist reg_exclude" "field." "$LIST2"
check "remove 3" "field.1 field-2 list" "estrlist reg_exclude" "field." "$LIST2 list"
check "remove 3" "field-2 field4" "estrlist reg_exclude" "field.*[13]" "$LIST2"
check "remove 4" "$LIST2" "estrlist reg_exclude" "fiel" "$LIST2"
#check "remove 5" "field4" "`remove_from_list "field2 field[13]" "$LIST2"`"
check "remove 6" "$LIST2" "estrlist reg_exclude" "" "$LIST2"

check "reg_exclude" "coreutils gawk grep sed which" "estrlist reg_exclude" '.*\.so\..* .*/.* .*(.*' '/bin/sh coreutils gawk grep sed which'


echo
check "strip1" "test" strip_spaces " test "
check "strip2" "test" strip_spaces "test "
check "strip3" "test" strip_spaces " test"
check "strip4" "test test" strip_spaces "  test  test  "

echo
REQLIST='foomatic-db foomatic-db-engine nx rpm-build  fonts-bitmap-misc libasound.so.2 libcrypto.so.10 libX11.so.6  libXcomposite.so.1 libXdamage.so.1 libXfixes.so.3 libXmuu.so.1 libXpm.so.4 libXrandr.so.2 libXtst.so.6 libz.so.1 xkeyboard-config libdl.so.2 bc'
REALPKGNAMELIST="$(estrlist reg_exclude ".*\..* .*\.\..* .*/.* .*(.*" "$REQLIST")"
check "rpmreqs" "foomatic-db foomatic-db-engine nx rpm-build fonts-bitmap-misc xkeyboard-config bc " echo "$REALPKGNAMELIST"

echo
EXLIST='desktop-file-utils fontconfig glibc-nss glibc-pthread libalsa libcairo libcups libfreetype libGL libgnutls30 libgtk+3 libICE libkrb5 libldap libopenal1 libpulseaudio libsane libssl libtxc_dxtn libudev1 libusb libva libvulkan1 libX11 libXcomposite libXcursor libXext libXi libXinerama libXpm libXrandr libXrender'
estrlist exclude "$EXLIST" 'desktop-file-utils fontconfig glibc-nss glibc-pthread /lib64/ld-linux-x86-64.so.2 libalsa libasound.so.2()(64bit) libasound.so.2(64bit) libcairo libcups libfreetype libGL libgnutls30 libgphoto2_port.so.12()(64bit) libgphoto2_port.so.12(64bit) libgphoto2.so.6()(64bit) libgtk+3 libICE libkrb5 liblber-2.4.so.2()(64bit) libldap libldap-2.4.so.2()(64bit) libopenal1 libopenal.so.1()(64bit) libpcap.so.0.8()(64bit) libpulseaudio libpulse.so.0()(64bit) libpulse.so.0(64bit) libsane libsane.so.1()(64bit) libssl libtxc_dxtn libudev1 libudev.so.1()(64bit) libudev.so.1(64bit) libunwind.so.8()(64bit) libusb libusb-1.0.so.0()(64bit) libva libvulkan1 libX11 libX11.so.6()(64bit) libXcomposite libXcursor libXext libXext.so.6()(64bit) libXi libXinerama libXpm libXpm.so.4()(64bit) libXrandr libXrender'

filter_multiple_provides()
{
        estrlist list - |
        sed -e "s|/usr/bin/lpstat|cups|g
                s|libldap_r-2.4.so.*|libldap|g
                s|liblber-2.4.so.*|libldap|g
                s|libudev.so.*|libudev1|g
                s|/usr/bin/wineboot||g
                s|/usr/bin/winetricks||g
                s|/usr/bin/wine||g
                s|/usr/bin/jconsole|java-1.7.0-openjdk-devel|g
                s|/sbin/modprobe||g
                s|gcc-c++|gcc9-c++|g
                s|libltdl-devel|libltdl7-devel|g
                s|liblua5-devel|liblua5.3-devel|g
                s|clang-devel|clang10.0-devel|g
                s|libXcomp.so.3.*|nx-libs|g
                s|libwine.so.1.*||g"
}

echo
echo 'libasound.so.2()(64bit) libasound.so.2.*(64bit) libgphoto2_port.so.12()(64bit) libgphoto2_port.so.12.*(64bit) libgphoto2.so.6()(64bit) liblber-2.4.so.2()(64bit) libldap-2.4.so.2()(64bit) libopenal.so.1()(64bit) libpcap.so.0.8()(64bit) libpulse.so.0()(64bit) libpulse.so.0.*(64bit) libsane.so.1()(64bit) libudev.so.1()(64bit) libudev.so.1.*(64bit) libunwind.so.8()(64bit) libusb-1.0.so.0()(64bit) libX11.so.6()(64bit) libXext.so.6()(64bit) libXpm.so.4()(64bit)' | filter_multiple_provides

#REQCONVLIST="$(do_exclude_list "$REALPKGNAMELIST" "$REQLIST")"
#check "convlist" "libasound.so.2 libcrypto.so.10 libX11.so.6 libXcomposite.so.1 libXdamage.so.1 libXfixes.so.3 libXmuu.so.1 libXpm.so.4 libXrandr.so.2 libXtst.so.6 libz.so.1 libdl.so.2" "$REQCONVLIST"

checkw()
{
    ok="$1"
    shift

    if estrlist contains "$1" "$2" ; then
        [ "OK" = "$ok" ]
        res=$?
    else
        [ "OK" != "$ok" ]
        res=$?
    fi
    [ "$res" = 0 ] && res="OK" || res="NOTOK"
    echo "contains '$1' '$2' $res"
}

echo
checkw NOTOK "lib12" "lib123 lib"
checkw OK "lib123" "lib123 lib"
checkw NOTOK "lib12" "lib1 lib"
checkw OK "lib" "lib1 lib"
checkw OK "lib1" "lib1 lib"
checkw NOTOK "lib1" "lib2 lib"
checkw NOTOK "lib" "lib1 lib2"
checkw NOTOK "1 2" "1 2 3"
checkw OK "lib123" "lib123"
