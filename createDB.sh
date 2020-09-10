export PATH
export TB_HOME=/opt/tmaxsoft/tibero6
export TB_SID=tibero
export LD_LIBRARY_PATH=$TB_HOME/lib:$TB_HOME/client/lib
export JAVA_HOME=/usr/java/latest
export PATH=$PATH:$TB_HOME/bin:$TB_HOME/client/bin:$JAVA_HOME/bin
ulimit -c 0
if [ ! -f $TB_HOME/config/$TB_SID.tip ]; then
$TB_HOME/config/gen_tip.sh
MEMORY_TARGET=2048
TOTAL_SHM_SIZE=$(( $MEMORY_TARGET / 2 ))
sed -i "s/TOTAL_SHM_SIZE=/&`echo $TOTAL_SHM_SIZE`M#/" $TB_HOME/config/tibero.tip
sed -i "s/MEMORY_TARGET=/&`echo $MEMORY_TARGET`M#/" $TB_HOME/config/tibero.tip
echo _PSM_BOOT_JEPA=Y >> $TB_HOME/config/tibero.tip
echo BOOT_WITH_AUTO_DOWN_CLEAN=Y >> $TB_HOME/config/tibero.tip
cat $TB_HOME/config/tibero.tip
echo "epa=((EXTPROC=(LANG=JAVA)(LISTENER=(HOST=localhost)(PORT=9390))))" >> $TB_HOME/client/config/tbdsn.tbr
tbboot nomount
tbsql sys/tibero @$TB_HOME/scripts/create_database.sql
tbboot
$TB_HOME/scripts/system.sh -p1 tibero -p2 syscat -a1 Y -a2 Y -a3 Y -a4 Y
fi
sleep 5
tbsql sys/tibero << EOF
alter system checkpoint;
alter system checkpoint;
EOF
tbdown -t IMMEDIATE
