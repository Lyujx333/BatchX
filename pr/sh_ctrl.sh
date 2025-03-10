#!/bin/bash

poscar_file="POSCAR"
control_file="CONTROL"

lattvec_1=$(awk 'NR==3 {print $1, $2, $3}' $poscar_file)
lattvec_2=$(awk 'NR==4 {print $1, $2, $3}' $poscar_file)
lattvec_3=$(awk 'NR==5 {print $1, $2, $3}' $poscar_file)

elements=$(awk 'NR==6 {print $1, $2, $3}' $poscar_file)
atoms_count=$(awk 'NR==7 {print $1, $2, $3}' $poscar_file)

total_atoms=0
elements_number=0
for count in $atoms_count; do
    total_atoms=$((total_atoms + count))
    ((elements_number++))
done

positions=$(awk '/Direct/,/^[ \t]*$/ {if (NR > 8) print $1, $2, $3}' $poscar_file)

formatted_lattvec_1=$(echo $lattvec_1 | sed 's/ /    /g')
formatted_lattvec_2=$(echo $lattvec_2 | sed 's/ /    /g')
formatted_lattvec_3=$(echo $lattvec_3 | sed 's/ /    /g')

sed -i "s|lattvec(:,1)=.*|lattvec(:,1)=      $formatted_lattvec_1|" $control_file
sed -i "s|lattvec(:,2)=.*|lattvec(:,2)=      $formatted_lattvec_2|" $control_file
sed -i "s|lattvec(:,3)=.*|lattvec(:,3)=      $formatted_lattvec_3|" $control_file

sed -i "s|natoms=.*|natoms=$total_atoms,|" $control_file

element_list=$(echo $elements | sed 's/ /" "/g')
sed -i "s|elements=.*|elements=\"$element_list\"|" $control_file

sed -i "s|nelements=.*|nelements=$elements_number,|" $control_file

types_list=""
count=1
for atom_count in $atoms_count; do
    for ((i = 1; i <= atom_count; i++)); do
        types_list+="$count "
    done
    types_list=${types_list%" "},
    ((count++))
done

sed -i "s|types=.*|types=$types_list|" $control_file

types_line_num=$(grep -n "types=" $control_file | cut -d: -f1)

formatted_positions=""
counter=2
line_number=1
for position in $positions; do
    if ((counter % 3 == 2));then
        formatted_positions+="positions(:,${line_number})=    $position"
    elif ((counter % 3 == 1));then
        formatted_positions+="  $position"
        formatted_positions+="\n"
        line_number=$((line_number + 1))
    elif ((counter % 3 == 0)); then
        formatted_positions+="  $position"
    else
        formatted_positions+=" "
    fi
    counter=$((counter + 1))
done

awk -v positions="$formatted_positions" -v types_line_num="$types_line_num" '
NR==types_line_num {print $0; print positions} 
NR!=types_line_num {print $0}' $control_file > temp_control && mv temp_control $control_file

echo "CONTROL file has been updated successfully."