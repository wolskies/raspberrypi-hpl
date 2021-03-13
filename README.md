# HPL Test 

The intent of this project is to build on existing work to provide a fast and repeatable process  to configure and run the HPL benchmark on a single Raspberry Pi 4

**Resources & Credits**:

1. Setting up Ubuntu on Raspberry Pi: 
	-  <https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#1-overview>
2. PWM Fan Control for Raspberry Pi:
	- <https://www.instructables.com/PWM-Regulated-Fan-Based-on-CPU-Temperature-for-Ras/>
3. Scripts for compiling & running mpich, OpenBLAS and HPL on Raspberry Pi 4:
	- <https://github.com/arif-ali/raspberrypi-hpl>
4. Tuning the HPL.dat file:
	- <https://www.advancedclustering.com/act_kb/tune-hpl-dat-file/>
	
### Basic Configuration 1 
- Raspberry Pi 4 8GB
- Ubuntu 20.04 server (64GB)
- 256GB SD card
- Ethernet
- Flirc case (passive cooling)
- No overclock

### Basic Configuration 2 
- Raspberry Pi 4 8GB
- Ubuntu 20.04 server (64GB)
- 256GB SD card
- Ethernet
- Flirc case (passive cooling)
- Overclocked

### Basic Configuration 3 
- Raspberry Pi 4 8GB
- Ubuntu 20.04 server (64GB)
- 256GB SD card
- Ethernet
- TBD case
- Overclocked


## Set-Up and Testing

### Configuring the Raspberry Pi
See Resource #1 for additional information

- Download OS and burn to  SD card (Raspberry Pi Imager and/or Etcher)
  
- Boot the Pi and initial configuration
	- Login as ubuntu/ubuntu
	- System will require change of default password on first boot
- Create user and give sudo access
	
            sudo adduser username
            sudo usermod -aG sudo username
         
- Update the system.  *(Note: no harm if you skip this, the `compile_all` script will update the system when it is launched)*
	
            sudo apt update && sudo apt upgrade -y
         
- Install libraspberrypi in order to be able to check throttled state. This requires the user to be added to the 'video' group to work
	
	        sudo apt install -y libraspberrypi-bin
            sudo usermod -aG video ed

### Compile HPL and Libraries

This section based on scripts from Resource #2:

- Clone the repository

        git clone https://github.com/wolskies/raspberrypi-hpl.git
    
- Make the appropriate configuration changes (per preference) in the file `scripts/CONFIG`. Current settings are:
	
	    export DOWNLOADS=~/Downloads
	    export WORKDIR=~/rpi-hpl-workdir
	    export RESULTSDIR=${WORKDIR}/results
	    export SCRIPTSDIR=${PWD}
	    export SERVICES="snap.lxd.daemon snap.lxd.daemon.unix.socket postfix systemd-timesyncd wpa_supplicant snapd snapd.apparmor.service systemd-resolved snapd.service snapd.socket"
	    export COMMON_FLAGS="-mtune=cortex-a72"
	    WRITE_OUT_FILE=0

- Compile mpich, OpenBLAS and hpl with the install script

	- Enter the `scripts` directory and configure as required

            cd raspberrypi-hpl/scripts

		- Each individual "make" script can be configured for a specific version. Currently specified versions are:
		
			- make_mpich.sh: version 3.3.2
			- make_openblas.sh: version: develop
			- make_hpl.sh: version 2.3
	
	- Use nano to edit these scripts if a different version is required
	- Launch the install script
	
            ./install.sh
        
	- You may be required to enter the sudo password one or more times
	- When the script finishes mpich, OpenBLAS and HPL will be installed in the `~/rpi-hpl-workdir` directory

### Run the Tests

- Before you begin:
	- HPL.dat is located in the `~/raspberrypi-hpl/configs` directory
	- Scripts must be run from the `~/raspberrypi-hpl/scripts` directory
	- To record results, the modify the `CONFIG` file in the `scripts` directory
		- Results get stored in the `~/rpi-hpl-workdir/results` directory
	- All of these folders can be changed in the CONFIG file (see previous section)

#### Test #1: Calling xhpl
This method calls `xhpl` directly via the `run_xhpl.sh` script.  For the test to run, the `HPL.dat` file must be configured such that the P x Q = 1.  That is, P=1 and Q=1.  Sample HPL.dat files are found in the configs directory with the ending ".xhpl". This script copies the `HPL.dat.xhpl` to `HPL.dat` to run the test.  Make any modifications to `HPL.dat.xhpl`

- To run the test, type:

        ./run_xhpl.sh
    
- Notes:

	- The raspberry pi throttles at 80deg temperature.  If results are slow, check for throttling (after the fact) with the following command:
	  
	        vcgencmd get_throttled
	
	- A result other than '0x0' means the CPU throttled due to temperature
	- With the Flirc case, my RPi4 didn't exceed 71 deg on a test

- The included `HPL.dat.hxpl` specifies 2 problem sizes (N) and 5 NBs.  This will result in the test running 10 times.  An alternate way to run it to modify the `HPL.dat.xhpl` to specify 1 N and 1 NB, and run the test 10 times with the following:

        for i in {1..10}; do ./run_xhpl.sh; done

    - Downside of this method is that you may have to type in the sudo password multiple times as it repeats the entire script - including disabling unnecessary services

#### Test #2: Launching with mpiexec (n=1)

This method calls `xhpl` via `mpiexec` using the `run_mpi.sh` script.  To get an 'apples to apples' comparison with the previous method, I first launched `mpiexec` specifying `-n 1`:

- Use the `HPL.dat` from the previous test:

        cd ~/raspberrypi-hpl/configs
        cp HPL.dat.xhpl HPL.dat
        cd ..
        cd scripts
        
- Edit the `run_mpi.sh` script change the execute line to read:

        COMMAND="/opt/mpich/3.3.2/bin/mpiexec -n 1 ${WORKDIR}/hpl-2.3/bin/rpi4-mpich/xhpl"

- Run with `mpiexec` (# processes = 1)

        ./run_mpi.sh
        
- This will run 10 times, just as it did in Test #1

#### Test #3: Launching with mpiexec (n=4)

This method calls `xhpl` via `mpiexec` using the `run_mpi.sh` script.  In this case, we tell `mpiexec` to launch 4 processes specifying `-n 4` :

- Use the HPL.dat.mpiexec:

        cd ~/raspberrypi-hpl/configs
        cp HPL.dat.mpiexec HPL.dat
        cd ..
        cd scripts
        
- Edit the `run_mpi.sh` script change the execute line to read:

        COMMAND="/opt/mpich/3.3.2/bin/mpiexec -n 4 ${WORKDIR}/hpl-2.3/bin/rpi4-mpich/xhpl"
        
- Run with `mpiexec`

        ./run_mpi.sh
        
- This will run 10 times, just as it did in Test #1 and #2

## Test Results

### Basic Configuration #1 (8GB, No Overclocking)

#### Test #1: Calling xhpl


#### Test #2: Launching with mpiexec (n=1)
This method, surprisingly, gave the fastest and most consistent results.  

	Finished     10 tests with the following results:
       	  	     10 tests completed and passed residual checks,
       	  	      0 tests completed and failed residual checks,
       	 	      0 tests skipped because of illegal input values.
	--------------------------------------------------------------------------------

	End of Tests.
	================================================================================
	WR11C2R4       28800   192     1     1            1121.38             1.4203e+01
	WR11C2R4       28800   192     1     1            1121.43             1.4202e+01
	WR11C2R4       28800   192     1     1            1120.90             1.4209e+01
	WR11C2R4       28800   192     1     1            1121.84             1.4197e+01
	WR11C2R4       28800   192     1     1            1120.86             1.4209e+01
	WR11C2R4       28800   192     1     1            1120.95             1.4208e+01
	WR11C2R4       28800   192     1     1            1119.99             1.4220e+01
	WR11C2R4       28800   192     1     1            1120.16             1.4218e+01
	WR11C2R4       28800   192     1     1            1122.01             1.4195e+01
	WR11C2R4       28800   192     1     1            1121.38             1.4203e+01
	temp=67.2'C
	throttled=0x0
	
#### Test #3: Launching with mpiexec (n=4)
Results were disappointing. Launching with 4 processes was significantly slower than all of the previous results (but fairly consistent).  Note that the flatter `P * Q` matrix of `1 * 4` performed best:

	Finished     10 tests with the following results:
       	  	     10 tests completed and passed residual checks,
       	  	      0 tests completed and failed residual checks,
       	 	      0 tests skipped because of illegal input values.
	--------------------------------------------------------------------------------

	End of Tests.
	================================================================================
	WR11C2R4       28800   192     1     4            1436.93             1.1084e+01
	WR11C2R4       28800   192     1     4            1433.23             1.1112e+01
	WR11C2R4       28800   192     1     4            1429.94             1.1138e+01
	WR11C2R4       28800   192     1     4            1439.51             1.1064e+01
	WR11C2R4       28800   192     1     4            1432.11             1.1121e+01
	WR11C2R4       28800   192     2     2            1515.98             1.0506e+01
	WR11C2R4       28800   192     2     2            1519.89             1.0479e+01
	WR11C2R4       28800   192     2     2            1514.62             1.0515e+01
	WR11C2R4       28800   192     2     2            1511.62             1.0536e+01
	WR11C2R4       28800   192     2     2            1514.13             1.0519e+01
	temp=67.6'C
	throttled=0x0 

### Basic Configuration #2 (8GB, Overclocked)

- Configure Raspberry Pi as follows:

        sudo nano /boot/firmware/config.txt
	
	Enter the following settings at the end of the file:
	
	    over_voltage=5
	    arm_freq=2000
	   
####Test #1: Calling xhpl

Overclocking at this point turned out to be a dismal failure.  On the first run, after seeing eye-popping numbers over 17Gflops, performance dropped off rapidly.  A quick check of `vcgencmd get_throttled` showed the RPi was throttling.  Off to the drawing board to get a better cooling solution for overclocking:

	WR11C2R4       28800   192     1     1            1032.38             1.5427e+01
	temp=78.8'C
	throttled=0x60000
	
Still, 15.4 Gflops **throttled** isn't bad performance.


