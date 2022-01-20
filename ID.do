#
# Design file    : ID.v
# Testbench file : ID_tb.v
# entity of testbench : ID_tb
#
#
# This is a Tcl file which contains ModelSim commands.
# For details on Tcl, refer to https://wikipedia.org/wiki/Tcl
#
# You can use this file by using the following command at Windows Command Prompt
#     vsim -c -do ID.do
# or in transcrpt window of GUI, give the following command
#     do ID.do
#
# Before using the above "do" command at GUI, you have to change directory to
# the directory where this file "ID.do" exists.
#
# This script adds all the signals in the design for waveforms.
# If you want only some specific signals, use 'add wave signal_name' command.
#
# If you need logic value list as a simulation result,
# add 2 command lines, 'add list [-decimal] *' and 'write list ID.lst'.
#
# If you want to view waveforms, use 'vsim -view vsim.wlf', and
# right click design instance and select 'Add->To wave->All items in region'.
#
#
# parameters:
#     runtime :
#         expected time of simulation run, which is around 400 ns.
#     project_name :
#         name of this simulation project
#     testbench_entity :
#         name of testbench module
#     tbench_file_name :
#         name of testbench file
#     design_files :
#         name of design files
#     parameterlist :
#         A list of {name, value} pairs of parameters.
#         Values of parameters at testbench can be overridden by these pairs.
#

# Register script name
set myscript ID.do; list

#----------------------------------
# parameters
#----------------------------------
set runtime          "100 ns"
set project_name     ID_project
set testbench_entity ID_tb
set tbench_file_name ID_tb.v
set design_files     { ID.v }; list
set parameterlist    {{TEST_INS 32'b010000001000001100000001000110011}}
#

# Revision   : 2.9

set netlist_sim_libs {}
# For post-synthesis timing simulation, we need cell libraries, e.g.,
# maxii_ver, cyclonev_ver, cycloneiv_ver, etc.
# Please change name of cell library if necessary at the following line, and
# uncomment the following line to specify the cell libraries.
# set netlist_sim_libs {-L cycloneiv_ver -L altera_ver}
#----------------------------------------------------------------------


#
# Check edition and version of Modelsim
#
set expected_auth "- INTEL FPGA STARTER EDITION"; list
set expected_id "2020.1"; list
set vsim_auth [vsimAuth]; list
set vsim_id [vsimId]; list
if { $vsim_auth != $expected_auth || $vsim_id != $expected_id } {
    echo "DO:Warning: Wrong Modelsim $vsim_auth version $vsim_id"
    echo "DO:Note: You shall use Modelsim $expected_auth version $expected_id"
}
if { $tcl_version < 8.6 } {
    echo "DO:Warning: Tcl version $tcl_version is old, and may break script."
}
echo "ModelSim $vsim_auth version $vsim_id, Tcl version [info patchlevel]"

#
# Get names of Tcl shell, working directory, and operating system.
# fyi: echo [exec grep -e ^NAME= -e ^VERSION= /etc/os-release]
#
if { [string compare -nocase $tcl_platform(platform) "windows"] == 0 } {
    set rawosname [exec wmic os get caption | findstr /I /C:win]; list
    set rawosver [exec cmd /c ver | findstr /I /C:win]; list
    set osname [string trim $rawosname]; list
    set osveronly [string map -nocase {"microsoft windows" ""} $rawosver]; list
    set osver [string trim $osveronly]; list
    echo "$osname $osver"
} elseif { [string compare -nocase $tcl_platform(os) "Linux"] == 0 } {
    set osname [exec grep -e ^PRETTY_NAME= /etc/os-release]; list
    set osver [exec uname -r]; list
    echo "$osname $osver"
} else {
    echo "OS: $tcl_platform(os) $tcl_platform(osVersion)"
}

# Check if name of executable contains East Asian characters.
set exename [info nameofexecutable]; list
echo $exename
set len [string length $exename]; list
set blen [string bytelength $exename]; list
if { $len != $blen } {
    echo "DO:Warning: Bad characters in full path name of executable."
    echo "DO:Note: Path name of executable shall not include east Asian characters."
    echo "DO:Note: The above problem may invoke an error at later stage of simulation."
}

# Check if working directory contains East Asian characters.
set wd [pwd]; list
echo $wd
set len [string length $wd]; list
set blen [string bytelength $wd]; list
if { $len != $blen } {
    echo "DO:Warning: Bad characters in full path name of working directory."
    echo "DO:Note: Path name of working directory shall not include east Asian characters."
    echo "DO:Note: The above problem may invoke an error at later stage of simulation."
}

#
# Count the number of design files, and
# Register testbench as the last item of the list of design files.
#
set number_of_designs [llength $design_files]; list
lappend design_files $tbench_file_name; list


#
# Return "ok" if all of the following conditions are met,
#   (a) 2 args 'number' and 'base' are positive number, 
#   (b) the 1st arg 'number' is a multiples of 2nd arg 'base',
#       where this checking is not performed if 'minimum' is less than 10,
#   (c) 'number' is less than or equal to 'maximum',
#   (d) 'number' is larger than or equal to 'minimum',
# Otherwise, return an error message string.
#
proc multiples_of {number base {maximum 100} {minimum 1}} {
    if ![ regexp {^([0-9]+)$} $number ] {
        return "$number is not a positive integer."
    }
    if ![ regexp {^([0-9]+)$} $base ] {
        return "$base is not a positive integer."
    }
    if { $number < $minimum } {
        return "$number too small, and must be larger than or equal to $minimum."
    }
    if { $number > $maximum } {
        return "$number too large, and must be less than or equal to $maximum."
    }
    if { $minimum >= 10 } {
        set div_base [expr ($number/$base)*$base]
        if { $div_base != $number } {
            return "$number is not a multiples of $base."
        }
    }
    return "ok"
}

if { [info exists clock_period_ps] } {
    # check this number, clock_period_ps
    set result [multiples_of $clock_period_ps 10 1000000 10]
    if { $result != "ok" } {
        echo "DO:BATERR: clock_period_ps ($clock_period_ps) is an invalid parameter."
        echo "NOTE: $result"
        echo "DO: Terminated without simulation."
        exit
    }
}

if { [info exists clocks4second] } {
    # check this number, clocks4second
    set result [multiples_of $clocks4second 10 100 3]
    if { $result != "ok" } {
        echo "DO:BATERR: clocks4second ($clocks4second) is an invalid parameter."
        echo "NOTE: $result"
        echo "DO: Terminated without simulation."
        exit
    }
}

#
# Return regex pattern of the given 'file_name'.
# Literals of the 'file_name' should be a combination of ASCII letters,
# decimal numbers, underscores, and dots.
#
proc get_pattern {file_name} {
    set length [string length $file_name]; list
    set pattern ^
    for { set k 0 } { $k < $length } { incr k } {
        set char [string index $file_name $k]
        scan $char %c ascii
        if { $ascii >= 65 && $ascii <= 90 } {
            # char is an uppercase letter
            set lower [string tolower $char]
            append pattern \[ $char $lower \]
        } elseif { $ascii >= 97 && $ascii <= 122 } {
            # char is a lowercase letter
            set upper [string toupper $char]
            append pattern \[ $upper $char \]
        } elseif { $ascii == 46 } {
            # char is a dot
            append pattern \\ $char
        } else {
            append pattern $char
        }
    }
    append pattern $
    return $pattern
}

#
# Get real file names that matches the above patterns
# from current working directory.
#
set hdlfiles [glob -nocomplain *.\[Vv\] *.\[Vv\]\[Pp\]]; list
set key 0; list
foreach filename $design_files {
    set value [get_pattern $filename]; list
    set found [lsearch -all -inline -regexp $hdlfiles $value]; list
    set num [llength $found]; list
    if { $num < 1 } {
        echo "Searching for file '$filename', this file does not exist."
        set designfile($key) $filename; list
    } elseif { $num > 1 } {
        puts "Searching for file '$filename':"
        if { [info exists warning_multiple_files] } {
            set firstmatch [lindex $found 0]; list
            set designfile($key) $firstmatch; list
            puts -nonewline "DO:Warning: There are $num files "
            puts "whose name matches {$value}. The files are '$found'"
            puts "DO: We choose the 1st match, '$firstmatch'."
        } else {
            puts -nonewline "DO:BATERR: There are $num files "
            puts "whose name matches {$value}. The files are '$found'"
            puts "DO: Terminated without simulation."
            exit
        }
    } else {
        if { $filename == $found } {
            echo "Searching for file '$filename', found."
        } else {
            echo "Searching for file '$filename', Physical file name is '$found'."
        }
        set designfile($key) $found; list
    }
    incr key
}
incr key -1; list
if { $key != $number_of_designs } {
    puts -nonewline "DO:BATERR: design file counts do not match "
    puts "($key, $number_of_designs)."
    puts "DO: Terminated without simulation."
    exit
}
set tbenchfile $designfile($number_of_designs); list

#
# Check modelsim.ini if requested.
#
set model_error 0; list
set modelsim_ini "modelsim.ini"; list
set check_ini [lsearch $argv -Gcheck_ini=false]; list
if {$check_ini == -1 && [file exists $modelsim_ini] != 1} {
    set wd [pwd]; list
    echo DO: $modelsim_ini does not exist at working directory.
    echo DO: Please download $modelsim_ini to $wd for your own setttings.
    # exit -code 199
    set model_error 1; list
}


#====================================
#
#   Now, begin simulation.
#
#====================================
#
# If error occurs during simulation, simply exits.
# At GUI, this does not work.
#
if { [lsearch $argv -do] >= 0 } {
    onerror { quit -f }; list
    onElabError { quit -f }; list
}

# Create a new project.
echo "DO: Creating project '$project_name' at working directory."
project new . $project_name

# Add design files to the project.
echo "DO: Adding $number_of_designs design file(s) to project."
for {set key 0} {$key < $number_of_designs} {incr key} {
    project addfile $designfile($key)
}
echo "DO: Adding testbench file '$tbenchfile' to project."
project addfile $tbenchfile

# Compile design files
for {set key 0} {$key < $number_of_designs} {incr key} {
    echo "DO: Compiling design file '$designfile($key)'."
    vlog $designfile($key)
}
# use +define+ if you need to override defined value
# vlog $tbenchfile +define+NAME=value
echo "DO: Compiling testbench file '$tbenchfile'."
vlog $tbenchfile

# Elaboration
set args ""; list
if { [info exists clock_period_ps] } {
    append args " -GCLOCK_PS=$clock_period_ps"; list
}
if { [info exists clocks4second] } {
    append args " -GCLOCKS4SEC=$clocks4second"; list
}
if { [info exists netlist_sim_libs] } {
    append args " $netlist_sim_libs"; list
}
# Add parameters which are defined as follows as an example:
# set parameterlist {{BITS 10}  {N 100}}
if { [info exists parameterlist] } {
    foreach parampair $parameterlist {
        set paramname [lindex $parampair 0]
        set paramval  [lindex $parampair 1]
        append args " -G$paramname=$paramval"
    }
}
# Add the other vsim options if exists.
# set vsimopts {opt1 opt2 ...}
if { [info exists vsimopts] } {
    foreach option $vsimopts {
        append args " $option"
    }
}

echo "DO: Preparing simulation: Elaboration."
vsim work.$testbench_entity {*}[split $args]

# Add objects for waveform viewing.
echo "DO: Preparing simulation: Add objects for waveform data collection."
add wave -r "/*"

# Run simulation.
echo "DO: Simulation run begins."
run {*}[split $runtime]

# Give warning on modelsim.ini if needed
if {$model_error == 1} {
    echo DO: ===============================================================
    echo DO: $modelsim_ini does not exist at working directory.
    echo DO: Default settings of Modelsim has been used for this simulation.
    echo DO: ===============================================================
}

# Finish
if { [lsearch $argv -do] >= 0 } {
    # If this script is invoked by "vsim -c -do" command, $argv is as follows:
    #     -- -c -do script_name.do
    quit -sim
    project close
	# echo [info library]
    exit
} elseif { $argc < 1 } {
    # If this script is invoked by "do do-file" at GUI, $argc == 0.
    quit -sim
    project close
    if { ![info exists myscript] } {
        set myscript do-file-name; list
    }
    echo "---------------------------------------------------------"
    echo " If you want to view waveforms, run simulation by using:"
    echo "     do $myscript -noquit"
    echo "---------------------------------------------------------"
} else {
    # If this script is invoked by "do do-file any-arg(s)" at GUI,
    # $argc > 0, and do nothing to view waveforms, etc.
    echo "------------------------------------------------------------"
    echo " If you want to terminate simulation, enter the followings:"
    echo "     quit -sim"
    echo "     project close"
    echo "------------------------------------------------------------"
}

