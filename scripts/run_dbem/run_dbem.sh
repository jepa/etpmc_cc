#!/bin/bash
#SBATCH --job-name=ADRDisp
#SBATCH --account=def-wailung
#SBATCH -N 1 	#Nodes
#SBATCH -N 1	#CPU count
#SBATCH --mem-per-cpu=700M
#SBATCH -t 02-10:00:00
#SBATCH --mail-user=jepa88@gmail.com
#SBATCH --mail-type=ALL
#SBATCH --array=10-10
#SBATCH --output=/home/jepa/projects/def-wailung/jepa/etpmc_cc/scripts/run_dbem/slurm_out/Array-%A-%a.out
#SBATCH --output=/home/jepa/projects/def-wailung/jepa/etpmc_cc/scripts/run_dbem/slurm_out/Array-%A-%a.err

cd $SLURM_SUBMIT_DIR
echo "Current working directory is `pwd`"
echo "Starting run at:$(date)"
echo “Starting task: $SLURM_ARRAY_TASK_ID”
sleep ${SLURM_ARRAY_TASK_ID}5s

export OMP_NUM_THREADS=1
~/projects/def-wailung/jepa/dbem/dbem_scripts/DBEM_v2_y
echo "Program $SLURM_JOB_NAME finished with exit code $? at: $(date)"
