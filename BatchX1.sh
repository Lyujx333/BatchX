#!/bin/bash

process_material() {
    local poscar_file=$1
    local temp_dir="temp_$(basename "$poscar_file")"

    echo "Processing POSCAR file: $poscar_file"

    mkdir -p "$temp_dir"
    cd "$temp_dir" || exit 1

    cp -r ../pr .
    cp -r ../plot .
    cp ../"$poscar_file" pr/POSCAR

    cd pr
    vaspkit_output=$(echo 601 | vaspkit)
    vaspkit -task 102 2 0.02
    cd ..

    material_name=$(echo "$vaspkit_output" | grep "Full Formula" | awk '{print $4}' | tr -d '()')
    if [ -z "$material_name" ]; then
        echo "Error: Failed to extract Full Formula Unit for $poscar_file"
        cd ..
        rm -rf "$temp_dir"
        return 1
    fi

    cd ..
    new_dir="calc_$material_name"
    if [ -d "$new_dir" ]; then
        echo "Warning: Directory $new_dir already exists, appending timestamp"
        new_dir="${new_dir}_$(date +%s)"
    fi
    mv "$temp_dir" "$new_dir"
    cd "$new_dir" || exit 1

    echo "Renamed working directory to: $new_dir (Material: $material_name)"

    mkdir 1-yh
    folder_path1=$(readlink -f 1-yh)
    folder_pathpr=$(readlink -f pr)
    folder_pathplot=$(readlink -f plot)
    folder_pathbase=$(pwd)

    cp -r pr/* 1-yh
    cd 1-yh/

    echo "Submitting op1 PBS job for $material_name..."
    job_id=$(qsub vasp40.sh)
    echo "Submitted PBS job with job ID: $job_id"

    echo "Waiting for op1 to complete..."
    while true; do
        job_status=$(qstat -f "$job_id" | grep "job_state" | awk '{print $3}')
        if [ "$job_status" == "C" ]; then
            echo "PBS job completed."
            break
        fi
        sleep 0.1
    done

    echo "Executing optimization in 10E-08."
    mv INCAR INCAR2
    mv INCAR1 INCAR
    mv POSCAR POSCAR1
    mv CONTCAR POSCAR

    echo "Submitting op2 PBS job for $material_name..."
    job_id1=$(qsub vasp40.sh)
    echo "Submitted op2 PBS job with job ID: $job_id1"

    echo "Waiting for op2 to complete..."
    while true; do
        job_status=$(qstat -f "$job_id1" | grep "job_state" | awk '{print $3}')
        if [ "$job_status" == "C" ]; then
            echo "op2 job completed."
            break
        fi
        sleep 0.1
    done

    echo "Executing optimization in 10E-08 x2."

    echo "Submitting op3 for $material_name..."
    job_id2=$(qsub vasp40.sh)
    echo "Submitted op3 PBS job with job ID: $job_id2"

    echo "Waiting for op3 to complete..."
    while true; do
        job_status=$(qstat -f "$job_id2" | grep "job_state" | awk '{print $3}')
        if [ "$job_status" == "C" ]; then
            echo "op3 job completed."
            break
        fi
        sleep 0.1
    done

    echo "Executing Self-Consistent..."

    cd ..
    mkdir 2-zq
    folder_path2=$(readlink -f 2-zq)
    cp "$folder_path1/KPOINTS" 2-zq
    cp "$folder_path1/POSCAR" 2-zq
    cp "$folder_path1/POTCAR" 2-zq
    cp "$folder_path1/INCAR-zq" 2-zq
    cp "$folder_path1/vasp40.sh" 2-zq

    cd 2-zq/
    mv INCAR-zq INCAR

    echo "Submitting sc1 for $material_name..."
    job_id3=$(qsub vasp40.sh)
    echo "Submitted sc1 PBS job with job ID: $job_id3"

    echo "Waiting for sc1 to complete..."
    while true; do
        job_status=$(qstat -f "$job_id3" | grep "job_state" | awk '{print $3}')
        if [ "$job_status" == "C" ]; then
            echo "sc1 job completed."
            break
        fi
        sleep 0.1
    done

    echo "Continuing with DOS, Band, Phonon, and ShengBTE calculations for $material_name..."
    cd ..
    mkdir 3-dos
    folder_path3=$(readlink -f 3-dos)
    cp -r 2-zq/* 3-dos
    cp $folder_pathpr/INCAR-dos 3-dos

    cd 3-dos/
    mv POSCAR POSCAR1
    mv CONTCAR POSCAR
    mv INCAR INCAR-zq
    mv INCAR-dos INCAR

    echo "Submitting dos1..."
    job_id4=$(qsub vasp40.sh)
    echo "Submitted dos1 PBS job with job ID: $job_id4"

    echo " Waiting for dos1 to complete..."
    while true; do
        job_status=$(qstat -f $job_id4 | grep "job_state" | awk '{print $3}')
        if [ "$job_status" == "C" ]; then
            echo "dos1 job completed."
            break
        fi
        sleep 0.1
    done

    cd ..
    mkdir result_dosplot
    cp $folder_path3/vasprun.xml result_dosplot
    cp $folder_pathplot/dp.py result_dosplot
    cd result_dosplot

    cd ..
    mkdir 4-ndt
    folder_path4=$(readlink -f 4-ndt)

    cp $folder_pathpr/KPOINTS-ndt 4-ndt
    cp $folder_path2/CONTCAR 4-ndt
    cp $folder_path2/POTCAR 4-ndt
    cp $folder_path2/INCAR 4-ndt
    cp $folder_path2/vasp40.sh 4-ndt

    cd 4-ndt/
    mv CONTCAR POSCAR
    mv KPOINTS-ndt KPOINTS

    echo "Submitting band1..."
    job_id5=$(qsub vasp40.sh)
    echo "Submitted band1 PBS job with job ID: $job_id5"

    echo " Waiting for band1 to complete..."
    while true; do
        job_status=$(qstat -f $job_id5 | grep "job_state" | awk '{print $3}')
        if [ "$job_status" == "C" ]; then
            echo "band1 job completed."
            break
        fi
        sleep 0.1
    done

    cd ..
    mkdir result_banddos
    cp $folder_path4/vasprun.xml result_banddos
    cp $folder_path4/KPOINTS result_banddos
    cp $folder_pathplot/bdp.py result_banddos
    cd result_banddos

    cd ..
    cd 4-ndt

    output=$(echo 601 | vaspkit)

    LatC_a=$(echo "$output" | grep 'Lattice Constants:' | awk '{print $3}')
    LatC_b=$(echo "$output" | grep 'Lattice Constants:' | awk '{print $4}')
    LatC_c=$(echo "$output" | grep 'Lattice Constants:' | awk '{print $5}')
    ATN=$(echo "$output" | grep 'Total Atoms:' | awk '{print $3}')

    lat_max=$(echo -e "$LatC_a\n$LatC_b\n$LatC_c" | awk 'BEGIN {max = 0} {if ($1 > max) max = $1} END {print max}')

    pr_a=$(awk -v max="$lat_max" -v val="$LatC_a" 'BEGIN {print int((max / val) + 0.999)}')
    pr_b=$(awk -v max="$lat_max" -v val="$LatC_b" 'BEGIN {print int((max / val) + 0.999)}')
    pr_c=$(awk -v max="$lat_max" -v val="$LatC_c" 'BEGIN {print int((max / val) + 0.999)}')

    sup_a=$pr_a
    sup_b=$pr_b
    sup_c=$pr_c

    sup_N=$((ATN * sup_a * sup_b * sup_c))

    while [ $sup_N -le 60 ] || [ $sup_N -gt 150 ]; do
        if [ $sup_N -le 60 ]; then
            sup_a=$((sup_a + 1))
            sup_b=$((sup_b + 1))
            sup_c=$((sup_c + 1))
        elif [ $sup_N -gt 150 ]; then
            if [ $sup_a -gt 1 ]; then
                sup_a=$((sup_a - 1))
            fi
            if [ $sup_b -gt 1 ]; then
                sup_b=$((sup_b - 1))
            fi
            if [ $sup_c -gt 1 ]; then
                sup_c=$((sup_c - 1))
            fi
            sup_N=$((ATN * sup_a * sup_b * sup_c))
            break
        fi
        sup_N=$((ATN * sup_a * sup_b * sup_c))
    done

    cd ..
    new_dir_name="SIFC-q${sup_a}${sup_b}${sup_c}"
    mkdir "$new_dir_name"

    cd "$new_dir_name"

    echo "!!!!!!!!Analyazed a test Scheme,which below"
    echo "LatC_a: $LatC_a"
    echo "LatC_b: $LatC_b"
    echo "LatC_c: $LatC_c"
    echo "ATN: $ATN"
    echo "sup_N: $sup_N"
    echo "lat_max: $lat_max"
    echo "pr_a: $pr_a"
    echo "pr_b: $pr_b"
    echo "pr_c: $pr_c"
    echo "sup_a: $sup_a"
    echo "sup_b: $sup_b"
    echo "sup_c: $sup_c"

    cp ../pr/SIFC.sh .
    cp ../pr/KPOINTS-SIFC .
    cp ../pr/INCAR-IFC .
    cp ../pr/band.conf .
    cp ../pr/band2.conf .
    cp ../4-ndt/POSCAR .
    cp ../4-ndt/POTCAR .

    mv KPOINTS-SIFC KPOINTS
    mv INCAR-IFC INCAR

    phonopy -d --dim="$sup_a $sup_b $sup_c"

    pp_N=$(ls POSCAR-* 2>/dev/null | wc -l)

    echo "Number of POSCAR files generated: $pp_N"

    if [ "$pp_N" -lt 10 ]; then
      sed -i "s/for i in \$(seq -w 01 [0-99]*)/for i in \$(seq -w 01 0$pp_N)/" SIFC.sh
    else
      sed -i "s/for i in \$(seq -w 01 [0-99]*)/for i in \$(seq -w 01 $pp_N)/" SIFC.sh
    fi

    qsub SIFC.sh

    echo "!!!!!!!SFCs were generated and submitted!!!!!!!"

    start_time_SF=$(date +%s)

    while true; do
        running_jobs=$(qstat -u $USER | grep 'vasp-SIFC' | wc -l)
        if [ $running_jobs -eq 0 ]; then
            sleep 30
            echo "SIFC are completed."
            break
        else
            current_time_SF=$(date +%s)
            elapsed_time=$((current_time_SF - start_time_SF))
            elapsed_minutes=$(bc <<< "scale=1; $elapsed_time / 60")
            echo -ne "Waiting for SIFC to finish (LAST for ${elapsed_minutes}min)...\r"
            sleep 60
        fi
    done

    sed -i "2s/.*/DIM = $sup_a $sup_b $sup_c/" band.conf
    sed -i "2s/.*/DIM = $sup_a $sup_b $sup_c/" band2.conf

    if [ "$pp_N" -lt 10 ]; then
      for i in $(seq -f "%02g" 1 "$pp_N"); do
        prun_files+=" structures/$i/vasprun.xml"
      done
    else
      for i in $(seq -f "%02g" 1 "$pp_N"); do
        prun_files+=" structures/$i/vasprun.xml"
      done
    fi
    phonopy -f $prun_files

    phonopy -p -c POSCAR band.conf -s
    phonopy-bandplot --gnuplot > phonon.dat
    phonopy -p -c POSCAR band2.conf
    vaspkit -task 739

    imagfreq_ex=$(awk '{
        for (i=2; i<=NF; i++) {
            value = $i + 0.0
            if (value < -0.1) {
                print 0
                exit
            }
        }
    }
    END {
        if (NR == 0) print 1
    }' phonon_band.dat)

    if [ -z "$imagfreq_ex" ]; then
        imagfreq_ex=1
    fi

    if [ "$imagfreq_ex" -eq 1 ]; then
        echo "!!!!!!!Congrats, No Imaginary Frequency!!!!!!!"
        cd ..
        new_dir_name_th="TIFC-q${sup_a}${sup_b}${sup_c}"
        mkdir "$new_dir_name_th"
        cd "$new_dir_name_th"

        cp ../pr/TIFC.sh .
        cp ../pr/KPOINTS-TIFC .
        cp ../pr/INCAR-IFC .
        cp ../4-ndt/POSCAR .
        cp ../pr/POTCAR .
        mv KPOINTS-TIFC KPOINTS
        mv INCAR-IFC INCAR

        python /home/general/lvjinxi/Software/thirdorder/thirdorder_vasp.py sow $sup_a $sup_b $sup_c -7
        th_N=$(ls 3RD.POSCAR.* 2>/dev/null | wc -l)

        if [ "$th_N" -ge 100 ] && [ "$th_N" -lt 1000 ]; then
            sed -i "s/for i in \$(seq -w 001 [0-999]*)/for i in \$(seq -w 001 $th_N)/" TIFC.sh
            qsub TIFC.sh
        elif [ "$th_N" -lt 100 ]; then
            sed -i "s/for i in \$(seq -w 001 [0-999]*)/for i in \$(seq -w 001 0$th_N)/" TIFC.sh
            qsub TIFC.sh
        elif [ "$th_N" -ge 1000 ]; then
            sed -i "s/for i in \$(seq -w 001 [0-999]*)/for i in \$(seq -w 001 $th_N)/" TIFC.sh
            qsub TIFC.sh
        fi
        echo "!!!!!!!THRs were generated and submitted!!!!!!!"
        while true; do
             running_jobs=$(qstat -u $USER | grep 'vasp-TIFC' | wc -l)
            if [ $running_jobs -eq 0 ]; then
                sleep 30
                echo "TIFC are completed."
                break
            else
                echo "Waiting for TIFC to finish..."
                sleep 1800
            fi
        done
        find structures/3RD* -name vasprun.xml |sort -n | /home/general/anaconda3/bin/python /home/general/lvjinxi/Software/thirdorder/thirdorder_vasp.py reap $sup_a $sup_b $sup_c -7
        echo "!!!!!!!THRs were completed!!!!!!!"
    else
        echo "XXXX--Prob existed Imaginary Frequcy! Reset the detect Prec(0.1) or Redetermine the Cals."
        return 1
    fi

    cd ..
    mkdir shengbte-rd
    cd shengbte-rd
    cp ../pr/CONTROL .
    cp ../pr/shp.sh .
    cp ../pr/sh_ctrl.sh .
    cp ../pr/sh40.sh .
    cp ../plot/gf.py
    cp ../plot/gt.py
    cp ../plot/kp.py
    cp ../plot/kpsg.py
    cp ../"$new_dir_name_th"/POSCAR .
    cp ../"$new_dir_name_th"/FORCE_CONSTANTS_3RD .
    cp ../"$new_dir_name"/FORCE_CONSTANTS .
    mv FORCE_CONSTANTS FORCE_CONSTANTS_2ND
    bash sh_ctrl.sh
    echo "ShengBTE CONTROL have already RESET"
    job_id_sh=$(qsub sh40.sh)
    echo "Submitted sc1 PBS job with job ID: $job_id_sh"
    while true; do
        job_status=$(qstat -f $job_id_sh | grep "job_state" | awk '{print $3}')
        if [ "$job_status" == "C" ]; then
            echo "!!!!!!!ShengBTE Done!!!!!!"
            break
        fi
        sleep 0.1
    done
    bash shp.sh

    echo "LatC_a: $LatC_a"
    echo "LatC_b: $LatC_b"
    echo "LatC_c: $LatC_c"
    echo "ATN: $ATN"
    echo "sup_N: $sup_N"
    echo "lat_max: $lat_max"
    echo "pr_a: $pr_a"
    echo "pr_b: $pr_b"
    echo "pr_c: $pr_c"
    echo "sup_a: $sup_a"
    echo "sup_b: $sup_b"
    echo "sup_c: $sup_c"
    echo "pp_N: $pp_N"
    echo "th_N: $th_N"

    cd "$folder_pathbase"
    echo "Finished processing $material_name"
}

input_dir="POSCARs"
if [ ! -d "$input_dir" ]; then
    echo "Error: Directory $input_dir does not exist. Please create it and place POSCAR files inside."
    exit 1
fi

found_files=false
for poscar in "$input_dir"/POSCAR* "$input_dir"/*.vasp; do
    if [ -f "$poscar" ]; then
        process_material "$poscar"
        found_files=true
    fi
done

if [ "$found_files" = false ]; then
    echo "No POSCAR files found in $input_dir (looked for POSCAR* and *.vasp)"
    exit 1
fi

echo "All materials processed successfully!"