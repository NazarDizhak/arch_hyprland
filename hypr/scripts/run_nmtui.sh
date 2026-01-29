#!/bin/bash
# This script launches nmtui with a custom color theme.

export NEWT_COLORS='root=,#1e1e2e:roottext=#cdd6f4,#1e1e2e:border=#89b4fa,#1e1e2e:window=#cdd6f4,#1e1e2e:title=#89b4fa,#1e1e2e:button=#cdd6f4,#1e1e2e:actbutton=#1e1e2e,#a6adc8:listbox=#cdd6f4,#1e1e2e:actlistbox=#1e1e2e,#a6adc8:entry=#cdd6f4,#1e1e2e:label=#cdd6f4,#1e1e2e:actsellistbox=#1e1e2e,#cdd6f4'

kitty --class nmtui --title nmtui nmtui
