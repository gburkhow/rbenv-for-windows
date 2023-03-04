/* --------------------------------------------------------------
* File          : rbenv-rehash.d
* Authors       : Aoran Zeng <ccmywish@qq.com>
* Created on    : <2023-03-04>
* Last modified : <2023-03-04>
*
* rbenv-rehash:
*
*   This D file works normally.
*
* ----------
* Changelog:
*
* ~> v0.1.0
* <2023-03-04> Create file
* -------------------------------------------------------------*/

module rbenv.rehash;

import std.stdio;
import std.process      : environment;
import std.array        : split, array;
import core.stdc.stdlib : exit;
import std.algorithm    : canFind, startsWith;

import rbenv;

// Written in the D programming language.
// --------------------------------------------------------------


string SHIMS_DIR;

enum REHASH_TEMPLATE = `
# Auto generated by 'rbenv rehash'
. $env:RBENV_ROOT\rbenv\lib\version.ps1
$gem = shim_get_gem_executable_location $PSCommandPath
& $gem $args
`
/*
if exists, $gem is
   C:\Ruby-on-Windows\correct_version_dir\bin\'gem_name'.bat
or
   C:\Ruby-on-Windows\correct_version_dir\bin\'gem_name'.cmd
*/


int main(string[] args) {

    auto arg_len = args.length;

    global_version_file = environment["RBENV_ROOT"] ~ "\\shims";

    if(args[0] == "executable") {
        return rehash_single_executable(args[1]);
    } else if (args[0] == "version") {
        return rehash_version(args[1]);
    } else {
        // Internal error
        return -1
    }

    return -1;
}


bool rehash_single_executable(string name) {
    string file = SHIMS_DIR ~ "\\" ~ name ~ ".ps1";
    write(file, REHASH_TEMPLATE);
    return true;
}


/*
# Generate shims for a version
#
# We need shims dir to always have the names that every Ruby has installed
#
# How can we achieve this? Via two steps:
# 1. Every time you install a new Ruby version, call 'rehash_version'
# 2. Every time you install a gem, call 'rehash_single_executable'
#
*/
bool rehash_version (string version) {

    auto ver = auto_fix_version_for_installed(ver);

    auto where = get_ruby_bin_path_for_version(ver);

    auto bats = Get-ChildItem "$where\*.bat" | % { $_.Name};

    // From Ruby 3.1.0-1, all default gems except 'gem.cmd' are xxx.bat
    // So we still should handle cmds before 3.1.0-1 and for 'gem.cmd'
    auto cmds = Get-ChildItem "$where\*.cmd" | % { $_.Name}

    // 'setrbvars.cmd' and 'ridk.cmd' shouldn't be rehashed
    cmds.Remove('setrbvars.cmd');
    cmds.Remove('ridk.cmd');


    // remove .bat suffix
    bats = bats | % { strip_ext $_} ;
    // remove .cmd suffix ;
    cmds = $cmds | % { strip_ext $_} ;

    auto executables = $bats + $cmds ;

    // echo $executables

    foreach (exe ; executables) {
        rehash_single_executable(exe);
    }
    success "rbenv: Rehash all " ~ executables.size ~ " executables in '" ~ version ~ "'"

    return true;
}