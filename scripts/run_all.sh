#!/bin/bash

. CONFIG

mkdir -p ${RESULTSDIR}
TIMESTAMP=$(date +%s)

# stop unnecessary services
sudo systemctl stop ${SERVICES}

# Unmount all the snap loop devices
for mount in $(df -h | grep loop.*snap | awk '{print $6}'); do sudo umount $mount; done

cd ${SCRIPTSDIR}/../configs

cp HPL.dat.xhpl HPL.dat

COMMAND="${WORKDIR}/hpl-2.3/bin/rpi4-mpich/xhpl"

if [ ${WRITE_OUT_FILE} -eq 1 ] ; then
  ${COMMAND} | tee -a ${RESULTSDIR}/HPL.out.${TIMESTAMP}

  echo
  echo Results ...
  echo

  grep WR11.*28 ${RESULTSDIR}/HPL.out.${TIMESTAMP} | tee -a ${RESULTSDIR}/HPL.out.${TIMESTAMP}
  vcgencmd measure_temp | tee -a ${RESULTSDIR}/HPL.out.${TIMESTAMP}
  vcgencmd get_throttled | tee -a ${RESULTSDIR}/HPL.out.${TIMESTAMP}

else
  ${COMMAND}
fi

COMMAND="/opt/mpich/3.4.1/bin/mpiexec -n 1 ${WORKDIR}/hpl-2.3/bin/rpi4-mpich/xhpl"

if [ ${WRITE_OUT_FILE} -eq 1 ] ; then
  ${COMMAND} | tee -a ${RESULTSDIR}/HPL.out.${TIMESTAMP}

  echo
  echo Results ...
  echo

  grep WR11.*28 ${RESULTSDIR}/HPL.out.${TIMESTAMP} | tee -a ${RESULTSDIR}/HPL.out.${TIMESTAMP}
  vcgencmd measure_temp | tee -a ${RESULTSDIR}/HPL.out.${TIMESTAMP}
  vcgencmd get_throttled | tee -a ${RESULTSDIR}/HPL.out.${TIMESTAMP}

else
  ${COMMAND}
fi

cp HPL.dat.mpiexec HPL.dat

COMMAND="/opt/mpich/3.4.1/bin/mpiexec -n 4 ${WORKDIR}/hpl-2.3/bin/rpi4-mpich/xhpl"

if [ ${WRITE_OUT_FILE} -eq 1 ] ; then
  ${COMMAND} | tee -a ${RESULTSDIR}/HPL.out.${TIMESTAMP}

  echo
  echo Results ...
  echo

  grep WR11.*28 ${RESULTSDIR}/HPL.out.${TIMESTAMP} | tee -a ${RESULTSDIR}/HPL.out.${TIMESTAMP}
  vcgencmd measure_temp | tee -a ${RESULTSDIR}/HPL.out.${TIMESTAMP}
  vcgencmd get_throttled | tee -a ${RESULTSDIR}/HPL.out.${TIMESTAMP}

else
  ${COMMAND}
fi

