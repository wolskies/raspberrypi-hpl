# HPL Test 
---
The intent of this project is to build on existing work to provide a fast and repeatable process  to configure and run the HPL benchmark on single and clustered Raspberry Pi 4's 
### Basic Configuration #1 (Single Node)
- Raspberry Pi 4 8GB
- Ubuntu 20.04 server (64GB)
- 256GB SD card
- Ethernet
- *For convenience, I may try powering via POE hat, will provide details if successful*

### Basic Configuration #2 (8 X Raspberry Pi 4 Cluster)

- 8 x Raspberry Pi 4 4GB
- 

## Setup
Basic setup instructions can be found at:
 <https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#1-overview>

- Burn OS on SD card
- Enable WiFi
	- Locate "systemboot partition" on SD card
	- edit "network-config" file
	
            wifis
                wlan0:
                dhcp4: true
                optional: true
                access-points:
                'accesspointname':
                password: "<wifi password>"
		      
      - Save file and remove from laptop
      
- Boot the Pi and finish configuration normally
	- Login as ubuntu/ubuntu
. System will require change of default password on first boot
	- Create user and give sudo access
	
             sudo adduser username
             sudo usermod -aG sudo username
             
	- Update the system.  *(Note: no harm if you skip this, the compile_all script will update the system when it is launched)*
	
             sudo apt update && sudo apt upgrade -y
             
	- Install libraspberrypi in order to be able to check throttled state. This requires the user to be added to the 'video' group to work.
	
	        sudo apt install -y libraspberrypi-bin
            sudo usermod -aG video ed
   
## Compile HPL and Libraries

*Note:  instructions for this section use scripts found at:
<https://github.com/arif-ali/raspberrypi-hpl>

- Clone the repository

        git clone https://github.com/arif-ali/raspberrypi-hpl.git
        
- Make the appropriate configuration changes (per preference) in the file scripts/CONFIG. *(Note:  I removed wpa_supplicant from SERVICES because my Pi was on WiFi and postfix because it's not installed)*. Current settings are:
	
	    export DOWNLOADS=~/Downloads
	    export WORKDIR=~/rpi-hpl-workdir
	    export RESULTSDIR=${WORKDIR}/results
	    export SCRIPTSDIR=${PWD}
	    export SERVICES="snap.lxd.daemon snap.lxd.daemon.unix.socket postfix systemd-timesyncd wpa_supplicant snapd snapd.apparmor.service systemd-resolved snapd.service snapd.socket"
	    export COMMON_FLAGS="-mtune=cortex-a72"
	    WRITE_OUT_FILE=0

- Compile mpich, OpenBLAS and hpl with the install script

        cd raspberrypi-hpl/scripts
        ./compile_all.sh
        
- You may be required to enter the sudo password one or more times

Need to remove 'wpa_supplicant' from CONFIG

## Run
- To run the test, type:

        ./run_job.sh
        
- Notes:
	- The default 'run_job.sh' script, does not use 'mpiexec' to launch hpl.  In this mode, the PxQ=1 in HPL.dat.  (P=1 Q=1)
	- The raspberry pi throttles at 80deg temperature.  If results are slow, check for throttling (after the fact) with the following command:
	    
	        vcgencmd get_throttled
	      
	- For tuning HPL.dat, a place to start is: <https://www.advancedclustering.com/act_kb/tune-hpl-dat-file/>.  The following resulted in XX Gflops:
        
            HPLinpack benchmark input file
            Innovative Computing Laboratory, University of TennesseHPL.out      output file name (if any) 
		6            device out (6=stdout,7=stderr,file)
		1            # of problems sizes (N)
		28800         Ns
		1            # of NBs
		192           NBs
		0            PMAP process mapping (0=Row-,1=Column-major)
		1            # of process grids (P x Q)
		1            Ps
		2 1          Qs
		16.0         threshold
		1            # of panel fact
		2            PFACTs (0=left, 1=Crout, 2=Right)
		1            # of recursive stopping criterium
		4            NBMINs (>= 1)
		1            # of panels in recursion
		2            NDIVs
		1            # of recursive panel fact.
		1            RFACTs (0=left, 1=Crout, 2=Right)
		1            # of broadcast
		1            BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
		1            # of lookahead depth
		1            DEPTHs (>=0)
		2            SWAP (0=bin-exch,1=long,2=mix)
		64           swapping threshold
		0            L1 in (0=transposed,1=no-transposed) form
		0            U  in (0=transposed,1=no-transposed) form
		1            Equilibration (0=no,1=yes)
		8            memory alignment in double (> 0)
		##### This line (no. 32) is ignored (it serves as a separator). ######
		0                               Number of additional problem sizes for PTRANS
		1200 10000 30000                values of N
		0                               number of additional blocking sizes for PTRANS
		40 9 8 13 13 20 16 32 64        values of NB

   
- Run with mpiexec

        mpiexec -n <# of processes> -ppn <# of processes per node> -f <hostfile> myprog.exe

