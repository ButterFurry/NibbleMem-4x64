lef read /usr/share/qflow/tech/osu035/osu035_stdcells.lef
load nibble_mem
drc on
select top cell
expand
drc check
drc catchup
set dcount [drc list count total]
puts stdout "drc = $dcount"
quit
