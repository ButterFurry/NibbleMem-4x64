#!/usr/bin/tcsh -f
#-------------------------------------------
# qflow exec script for project /home/Amity/asic/first_chip/nibble_mem
#-------------------------------------------

# /usr/lib/qflow/scripts/synthesize.sh /home/Amity/asic/first_chip/nibble_mem nibble_mem /home/Amity/asic/first_chip/nibble_mem/source/nibble_mem.rtlnopwr.v || exit 1
# /usr/lib/qflow/scripts/placement.sh -d /home/Amity/asic/first_chip/nibble_mem nibble_mem || exit 1
# /usr/lib/qflow/scripts/opensta.sh  /home/Amity/asic/first_chip/nibble_mem nibble_mem || exit 1
# /usr/lib/qflow/scripts/vesta.sh -a /home/Amity/asic/first_chip/nibble_mem nibble_mem || exit 1
# /usr/lib/qflow/scripts/router.sh /home/Amity/asic/first_chip/nibble_mem nibble_mem || exit 1
# /usr/lib/qflow/scripts/opensta.sh  -d /home/Amity/asic/first_chip/nibble_mem nibble_mem || exit 1
# /usr/lib/qflow/scripts/vesta.sh -a -d /home/Amity/asic/first_chip/nibble_mem nibble_mem || exit 1
# /usr/lib/qflow/scripts/migrate.sh /home/Amity/asic/first_chip/nibble_mem nibble_mem || exit 1
# /usr/lib/qflow/scripts/drc.sh /home/Amity/asic/first_chip/nibble_mem nibble_mem || exit 1
# /usr/lib/qflow/scripts/lvs.sh /home/Amity/asic/first_chip/nibble_mem nibble_mem || exit 1
/usr/lib/qflow/scripts/gdsii.sh /home/Amity/asic/first_chip/nibble_mem nibble_mem || exit 1
# /usr/lib/qflow/scripts/cleanup.sh /home/Amity/asic/first_chip/nibble_mem nibble_mem || exit 1
# /usr/lib/qflow/scripts/display.sh /home/Amity/asic/first_chip/nibble_mem nibble_mem || exit 1
