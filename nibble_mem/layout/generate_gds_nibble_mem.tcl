drc off
box 0 0 0 0
gds readonly true
gds rescale false
gds read /usr/share/qflow/tech/osu035/osu035_stdcells.gds2
load nibble_mem
select top cell
expand
gds write nibble_mem
quit
