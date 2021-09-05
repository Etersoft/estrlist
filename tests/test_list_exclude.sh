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
check "remove 1" "field.1" "estrlist reg_remove" "field-2" "$LIST1"
check "remove 1.1" "$LIST1" "estrlist reg_remove" "field2" "$LIST1"
# FIXME: regexp??
check "remove 2" "field.1 field-2" "estrlist reg_remove" "field." "$LIST2"
check "remove 3" "field.1 field-2 list" "estrlist reg_remove" "field." "$LIST2 list"
check "remove 3" "field-2 field4" "estrlist reg_remove" "field.*[13]" "$LIST2"
check "remove 4" "$LIST2" "estrlist reg_remove" "fiel" "$LIST2"
#check "remove 5" "field4" "`remove_from_list "field2 field[13]" "$LIST2"`"
check "remove 6" "$LIST2" "estrlist reg_remove" "" "$LIST2"

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

#REQCONVLIST="$(do_exclude_list "$REALPKGNAMELIST" "$REQLIST")"
#check "convlist" "libasound.so.2 libcrypto.so.10 libX11.so.6 libXcomposite.so.1 libXdamage.so.1 libXfixes.so.3 libXmuu.so.1 libXpm.so.4 libXrandr.so.2 libXtst.so.6 libz.so.1 libdl.so.2" "$REQCONVLIST"
