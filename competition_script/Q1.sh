#!/bin/bash
# @wxian2016Aug14
# show detailed job information for user

h=0
u=0

while [[ $# > 0 ]]; do
	key="$1"
	case $key in 
		-h) h=1
			;;
		-u) u=1
			USER="$2"
			shift; ;;
	esac
	shift
done
	
if [[ $h == 1 ]]; then
	cat <<EOF
Usage: sh $0 [option]

Option:
		-h	show help information
		-u STRING	show information for the user

EOF
exit 0
fi

if [[ $u == 0 ]]; then
	USER=$(whoami)
fi

echo -e "Job_Name\tJob_ID\tStatus\tCPU_Time\tRAM/VF\tExe_Host\tExe_info\tError"
for j in $(qstat -u $USER | tail -n +3 | awk '{print $1}')
do
	job_name=$(qstat -j ${j} | grep "job_name" | cut -d ":" -f 2)
	jobname=$(echo $job_name)
	job_status=$(qstat -u $USER | grep "$j" | awk '{print $5}')	
	cpu_time=$(qstat -j ${j} | grep "usage    1:" | cut -d "," -f 1 | cut -d "=" -f 2)
	ram=$(qstat -j ${j} | grep "usage    1:" | cut -d "," -f 4 | cut -d "=" -f 2) 
	vf=$(qstat -j ${j} | grep "hard resource_list:" | cut -d "," -f 2 | cut -d "=" -f 2)
	host=$(qstat -u $USER | grep "$j" | awk '{print $8}' | cut -d "@" -f 1)
	host_com=$(qstat -u $USER | grep "$j" | awk '{print $8}' | cut -d "@" -f 2 | cut -d "." -f 1)
	host_mem=$(qhost -h $host_com | grep "$host_com" | awk '{print $5}')
	host_cpu=$(qhost -h $host_com | grep "$host_com" | awk '{print $3}')
	if [[ $job_status == "Eqw" ]]; then
		error="Error for STH"
	else
		error="NA"
	fi
	echo -e "${jobname}\t${j}\t${job_status}\t${cpu_time}\t${ram}/${vf}\t${host}\t${host_mem}/${host_cpu}\t${error}"
done





