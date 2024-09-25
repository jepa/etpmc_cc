---
output:
  pdf_document: default
  html_document: default
---

# Instructions to run the DBEM

Before you run the DBEM make sure you read this document, otherwise things may not function properly and your work will be delayed. Note that as this document date, the DBEM is set to run on Compute Canada's *Cedar* cluster under the *def-wailung* account.

## Folder structure

As a overall suggestion, I recommend you create and sync your GitHub account with Compute Canada and use `git`. That way you can modify everything on your local computer and then simply `push + pull` to Compute Canada.

The way the DBEM is set up, it requires paths to be properly adjusted to read and save data. For that, the easier way is to make sure that your DBEM repository is cloned (or saved) right after your user name in Compute Canada, for example (*NOTE: If you know/want to change the paths to to accommodate your file structure then you don't need to read the following)*:

Navigate to your personal folder, mine is `jepa`:

`[jepa@cedar1 ~]$ cd /home/jepa/projects/def-wailung/jepa/`

once here, you can `git -clone` the DBEM repository and follow the prompts:

`[jepa@cedar1 jepa]$ git -clone git@github.com:coruubc/dbem.git`

if successful, you can type `ls` and should see the `dbem` repository in your environment:

`/home/jepa/projects/def-wailung/jepa/dbem`

Once you have the folder in there, you do not need to have different copies of the DBEM repository for each project (unless you want to have a modify version of the DBEM). Instead, for each project you simply need to have (copy) a `settings.txt` and `run_dbem.sh` scripts (see `./scripts/run_dbem/`) in your project repository. For example, I have a project called `global_mpa` in my account that needs to run the DBEM:

`/home/jepa/projects/def-wailung/jepa/global_mpa`

within my `global_mpa` repository I have a series of sub-folders (`scripts/com_can/)` where I keep the DBEM files:

`/home/jepa/projects/def-wailung/jepa/global_mpa/scripts/com_can/`

and I also have my main DBEM repository that I cloned from github:

`/home/jepa/projects/def-wailung/jepa/dbem`

with this set up, I only need to modify my `sttings` and `run_dbem.sh` files that we use to submit a job to Compute Canada and they will know where to read the DBEM files (see below).

## Compile Code

**NOTE:** This step is only needed if you are running the DBEM for the first time

Before you actually run the DBEM source code **for the first time** from your project's repository, you need to compile the Fortran code (`DBEM_v2_y.f90` or `DBEM_v2_m.f90`) in the DBEM repository. For that, you need to go to the DBEM repository sub folder `run_dbem`:

`[jepa@cedar1 ~]$ cd /home/jepa/projects/def-wailung/jepa/dbem/scripts/run_dbem/`

and run the `compile_dbem.sh` script:

``` bash
# First we give permitions to execute the script
chmod +x compile_dbem.sh

# Now we execute the script
./compile_dbem.sh
```

You should get *no return message* but if you write `ls` in the terminal you should see new files (e.g., *dbem.mod*) and if you navigate to `./dbem/dbem_scripts/` you should now see two versions of the DBEM code (e.g., `DBEM_v2_y.f90` or `DBEM_v2_y`).

Thats it, you will only need to compile the code again if you make a modification to the DBEM source code. Now, you only need to get your `settings.txt` and `run_dbem.sh` files ready and submit a job. Remember that these files do not need to be in the DBEM folder but rather, in your project repository.

## Settings file

The `settings.txt` file contains the main information to run the DBEM. Make sure all the info is correct:

Table 1: Glossary for settings file

| Vector    | Description                                                                                                                                                    | Example         |
|-------------------|----------------------------------|-------------------|
| SppNo     | Number of species to run                                                                                                                                       | 40              |
| CCSc      | Climate change data                                                                                                                                            | C6GFDL26        |
| SSP       | SSP data for fishing effort. Only applicable if fishing effort is activated.                                                                                   | SSP126          |
| rsfile    | Name of file containing the list of species to run                                                                                                             | RunSppList      |
| rpath     | Folders where results will be created in your `scratch` folder (auto. by DBEM)                                                                                 | C6GFDL26F1MPA10 |
| tpath     | Folder containing taxon information                                                                                                                            | TaxonDataC0     |
| ifile     | Number of species list to run. Note this number will automatically increase every time you run the DBEM                                                        | 10              |
| FHS       | Fishing level in the high seas as a proportion of MSY                                                                                                          | 1.00            |
| FEEZ 1.00 | Fishing level in EEZs as a proportion of MSY                                                                                                                   | 1.00            |
| MPApath   | Name of the MPA scenario to run. Note: The name of the vector need to match the file name in the `Data` folder. If you don't have an MPA scenario use `mpa_no` | mpa_30          |

## Running file

You will need to prepare the *slurm* process to run the DBEM using the `run_dbem.sh` script. At the minimum, you need to modify the variables on lines 8 and 10 before running the script:

Table 2 : Minimum information needed to run the DBEM. See [here](https://hpc.nmsu.edu/discovery/slurm/commands/) if you want to know what each vector means and how include more/less.

| Vector      | Description                                                        | Example (standard)                                                                                       |
|-------------------|----------------------|-------------------------------|
| N           | Nodes needed                                                       | 1                                                                                                        |
| mem-per-cpu | Memory needed for the DBEM                                         | 700M                                                                                                     |
| t           | Computing time dd-hh:mm:ss                                         | 01-12:00:00                                                                                              |
| mail-user   | Email account where you will get run notifications                 | youremail[\@oceans.ubc.ca](mailto:mail-user=j.palacios@oceans.ubc.ca)                                    |
| \--array    | number of jobs to be submitted matching the number of species list | 10-36, will submit 27 jobs, in each job the number of the species list will change (eg., 10,11,12... 36) |

**NOTE:** that you do not need to modify anything after line 11. However, if you changed the name or location of your source script, then you will need to update that on line 20. Currently, the file is configured so it will run from the "general" DBEM code. If you have your own DBEM code you ill have to modify this line

``` bash
# This is the path that runs the DBEM 
../../../dbem_scripts/DBEM_v2_y
```

## Run the DBEM

Once you complete all of those steps you are ready to run the DBEM in the *terminal* of Cedar at *Compute Canada* as follows:

``` bash
sbatch run_dbem.sh
```

# Post DBEM runs

The `slurm` job scheduler will produce two files for each submission, a `file.out` and a `file.err` those files will be named as something like `Array-28689414-10.err` and `Array-28689414-10.out`. If the DBEM runs without any problem, `Array-28689414-10.err` should be blank and `Array-28689414-10.out` will look like:

```         
[jepa@cedar1 run_dbem]$ emacs Array-28689414-10.out

Current working directory is /project/6006523/jepa/complete_dbem_runs/scripts/run_dbem
Starting run at:Tue 09 Apr 2024 10:36:02 AM PDT
“Starting task: 10”
 Species list:    10
 MisSppList10.txt
 Initializing, loading files...
          27
 600006
 Results/C6GFDL26F15MISS/600006

 Read Parameters...
 Running Taxon C_hippurus
 Species/Distributions/S600006.csv
   15.7808039090815
 Thread           0  starting...
 600088
 Results/C6GFDL26F15MISS/600088
.
.
.
Read Parameters...
 Running Taxon P_indicus
 Species/Distributions/S600950.csv
   24.5561015660227
 Thread           0  starting...
 Time step =         1951
 Catch=   1225653.41987471
 Abd=   532063.5
 Catch=   370557.382984317
.
.
.
Completed!
Program ADRDisp finished with exit code 0 at: Tue 09 Apr 2024 08:45:00 PM PDT
```

On the other hand, if the DBEM encounters an issue, the `Array-28689414-10.err` file will have an error message indicating the issue. For example, in the run below, the DBEM was not able to read the bottom temperature of 1971 (`bot_temp_1971.txt`) layer because the file was not found. If we look closer to the provided path, we can see that it says `C6IIPSL26`, a typo! as it should read `C6IPSL26`.

```         
forrtl: No such file or directory
forrtl: severe (29): file not found, unit 1, file
/home/jepa/projects/def-wailung/Data/Climate/C6IISPL26/bot_temp_1971.txt
Image              PC                Routine            Line        Source
DBEM_v2_y          000000000043741C  Unknown               Unknown  Unknown
DBEM_v2_y          00000000004145D2  Unknown               Unknown  Unknown
DBEM_v2_y          000000000040957C  Unknown               Unknown  Unknown
DBEM_v2_y          000000000040434D  Unknown               Unknown  Unknown
libc.so.6          00002B288466594A  Unknown               Unknown  Unknown
libc.so.6          00002B2884665A05  __libc_start_main     Unknown  Unknown
DBEM_v2_y          0000000000404261  Unknown               Unknown  Unknown
```
