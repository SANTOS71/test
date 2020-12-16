 #!/bin/bash
version=1.03.02
if [ $# -eq 0 ] || [ $1 != "test" ];then
    exec 2>/dev/null
fi

logfile=`readlink -f $0`
numdots=`echo $logfile|awk 'BEGIN {FS="."};{print NF}'`
numpath=`echo $logfile|awk 'BEGIN {FS="/"};{print NF}'`

let numdots=$numdots-1
let numpath=$numpath
let numpath2=$numpath-1
logfile=`echo $logfile|cut -f1-$numdots -d"."`
logfile=`echo $logfile|cut -f1-$numpath2 -d"/"`"/log_"`echo $logfile|cut -f$numpath -d"/"`.txt

#set the scrit to return in the pipes command a value no equal to 0 if any of the commands in the pipe fails
set -o pipefail

#give value to some read-only variables
function Conf(){
    readonly truemodules="GRT IOT IOD SCR LED TOC"
    readonly compmodules="GRC IOC IOD SCR LED TOC"
    readonly logsize=1048510
    #size of the database
    readonly tam=128
    readonly tam_scrambling=128
    #modules directory
    readonly progdir=/GR
    #data directory
    readonly data=/GR/DATACORE
    #GR's ini file (is used for the location of the databases and for checking that ip's are right one
    readonly fcta=/GR/GRT/grt.a.32.ini
    readonly fctb=/GR/GRT/grt.b.32.ini
    readonly fcca=/GR/GRC/grc.a.64.ini
    readonly fccb=/GR/GRC/grc.b.64.ini
    readonly fich_ip_ta=/GR/IOT/iot.a.32.ini
    readonly fich_ip_tb=/GR/IOT/iot.b.32.ini
    readonly fich_ip_ca=/GR/IOC/ioc.a.64.ini
    readonly fich_ip_cb=/GR/IOC/ioc.b.64.ini
    #log directory
    readonly logdirectory=/tmp
    readonly options="-o StrictHostKeyChecking=no"
}

function Log(){
    local logtype
    local logdate
    local i
    local s
    if [ -f $logfile ] && [ `ls -l $logfile|awk '{print ($5)}'` -ge $logsize ];then
        rm -f $logfile.old >/dev/null 2>/dev/null
        mv $logfile $logfile.old
    fi
    logtype=$1
    shift
    logdate=`date +%d/%m/%y_%H:%M`
    case $logtype in
        text)echo "$logdate  $*" >> $logfile;;
        command)sys=${sist[$1]}
                shift
                echo "$logdate command in $sys:$*" >> $logfile;; 
        Database)sys=${sist[$1]}
                 echo "$logdate ${ndatabases[$1]} databases in $sys" >> $logfile;
                 for i in `seq 1 ${ndatabases[$1]}`;do
                     device=`echo ${bd_device[$1]}|cut -f$i -d"|"`
                     offset=`echo ${bd_offset[$1]}|cut -f$i -d"|"`
                     echo "Device=$device offset=$offset" >> $logfile;
                 done;;
    esac
}

#the script use text variables to show the text to the user
#this function use different functions to asing value to the text variables in spanish or english
#different functions are used for a easier location of the variables if this must be changed
function language(){
    case $1 in
        es)MenuProgrammer_esp
           MenuUtils_esp
           MenuActualizar_esp
           MenuIps_esp
           MenuFicheros_esp
           MenuConfiguracion_esp
           MenuBasededatos_esp
           MenuSistema_esp
           Error_esp
           Entry_esp
           Question_esp
           Selection_esp
           Progress_mod_esp
           Progress_data_esp
           Progress_delete_esp
           Progress_restore_esp
           MenuIp_esp
           MenuDevice_esp
           MenuAddDelIps_esp
           MenuRoutes_esp
           MenuIpBackup_esp
           MenuAutoConfig_esp
           MenuSelectSystem_esp
           MenuDatabaseDevice_esp
           MenuConfig_esp
           MenuForceRollback_esp
           MenuSelectOperator_esp
           Files_esp
           for_text="para";;
        *)MenuProgrammer_eng
          MenuUtils_eng
          MenuActualizar_eng
          MenuIps_eng
          MenuFicheros_eng
          MenuConfiguracion_eng
          MenuBasededatos_eng
          MenuSistema_eng
          Error_eng
          Entry_eng
          Question_eng
          Selection_eng
          Progress_mod_eng
          Progress_data_eng
          Progress_delete_eng
          Progress_restore_eng
          MenuIp_eng
          MenuDevice_eng
          MenuAddDelIps_eng
          MenuRoutes_eng
          MenuIpBackup_eng
          MenuAutoConfig_eng
          MenuSelectSystem_eng
          MenuDatabaseDevice_eng
          MenuConfig_eng
          MenuForceRollback_eng
          MenuSelectOperator_eng
          Files_eng
          for_text="for";;
    esac
}
function MenuProgrammer_esp(){
    optionprogrammer[0]="obtener configuración"
    optionprogrammer[1]="guardar configuracion"
    optionprogrammer[2]="usar configuración guardada"
    optionprogrammer[3]="restaurar base de datos y datos"
    optionprogrammer[4]="borrar la base de datos"
    optionprogrammer[5]="cambiar ip's internas"
    optionprogrammer[6]="gestionar ip's externas"
    optionprogrammer[7]="gestionar rutas"
    optionprogrammer[8]="cambiar ip's de equipo backup"
    optionprogrammer[9]="forzar rollback"
    optionprogrammer[10]="salir"
}
function MenuUtils_esp(){
    optionutils[0]="actualizar"
    optionutils[1]="sistemas"
    optionutils[2]="configuracion"
    optionutils[3]="red"
    optionutils[4]="ficheros"
    optionutils[5]="bases de datos"
    optionutils[6]="borrar cache de scrambling"
    optionutils[7]="comprobar versión"
    optionutils[8]="sincronizar fecha"
    optionutils[9]="captura de red interna"
    mpcol="opción"    
}
function MenuActualizar_esp(){
    optionactualizacion[0]="actualizar módulos"
    optionactualizacion[1]="actualizar datos"
    optionactualizacion[2]="actualizar módulos y datos"
    optionactualizacion[3]="actualizar md5's"
}
function MenuIps_esp(){
    optionips[0]="cambiar ip's internas"
    optionips[1]="gestionar ip's externas"
    optionips[2]="gestionar rutas"
    optionips[3]="cambiar ip's de equipo backup"
}
function MenuFicheros_esp(){
    optionficheros[0]="eliminar log's"
    optionficheros[1]="eliminar TSRDATA"
    optionficheros[2]="obtener archivos de log"
    optionficheros[3]="obtener carpeta de datos"
    optionficheros[4]="archivo de reporte de datos"
    optionficheros[5]="obtener TSRDATA"
    optionficheros[6]="obtener archivos del Programmer"
    optionficheros[7]="salir"
}
function MenuConfiguracion_esp(){
    optionconfiguracion[0]="generar auto-configuración"
    optionconfiguracion[1]="obtener configuración"
    optionconfiguracion[2]="guardar configuracion"
    optionconfiguracion[3]="usar configuración guardada"
}
function MenuBasededatos_esp(){
    optionbasededatos[0]="borrar la base de datos"
    optionbasededatos[1]="obtener base de datos"
    optionbasededatos[2]="copiar base de datos"
    optionbasededatos[3]="borrar bases de datos concretas"
    optionbasededatos[4]="forzar rollback"
}
function MenuSistema_esp(){
    optionsistema[0]="formatear sistemas"
    optionsistema[1]="parar sistemas"
    optionsistema[2]="iniciar sistemas"
    optionsistema[3]="reiniciar sistemas"
}
function MenuProgrammer_eng(){
    optionprogrammer[0]="get configuration"
    optionprogrammer[1]="use stored configuration"
    optionprogrammer[2]="store configuration"
    optionprogrammer[3]="restore database and data"
    optionprogrammer[4]="remove database"
    optionprogrammer[5]="change internal IP addresses"
    optionprogrammer[6]="external IP addresses"
    optionprogrammer[7]="routes"
    optionprogrammer[8]="backup IP addresses"
    optionprogrammer[9]="force rollback"
    optionprogrammer[10]="exit"
}
function MenuUtils_eng(){
    optionutils[0]="update"
    optionutils[1]="systems"
    optionutils[2]="configuration"
    optionutils[3]="net"
    optionutils[4]="files"
    optionutils[5]="databases"
    optionutils[6]="remove scrambling cache"
    optionutils[7]="modules version"
    optionutils[8]="synchro date"
    optionutils[9]="internal network capture"
    mpcol="option"        
}
function MenuActualizar_eng(){
    optionactualizacion[0]="update modules"
    optionactualizacion[1]="update data"
    optionactualizacion[2]="update data and modules"
    optionactualizacion[3]="update module's md5"
}
function MenuIps_eng(){
    optionips[0]="change internal IP addresses"
    optionips[1]="external IP addresses"
    optionips[2]="routes"
    optionips[3]="change backup equipment's IP addresses"
}
function MenuFicheros_eng(){
    optionficheros[0]="remove log files"
    optionficheros[1]="remove TSRDATA"
    optionficheros[2]="get log files"
    optionficheros[3]="get data folder"
    optionficheros[4]="get report data file"
    optionficheros[5]="get TSRDATA"
    optionficheros[6]="get Programmer's files"
}
function MenuConfiguracion_eng(){
    optionconfiguracion[0]="generate modules configuration"
    optionconfiguracion[1]="get configuration"
    optionconfiguracion[2]="store configuration"
    optionconfiguracion[3]="use stored configuration"
}
function MenuBasededatos_eng(){
    optionbasededatos[0]="remove TSR's database"
    optionbasededatos[1]="get database"
    optionbasededatos[2]="copy database"
    optionbasededatos[3]="remove specific databases"
    optionbasededatos[4]="force rollback"
}
function MenuSistema_eng(){
    optionsistema[0]="format systems"
    optionsistema[1]="stop systems"
    optionsistema[2]="start systems"
    optionsistema[3]="restart systems"
}
function Error_eng(){
    error_noins="no valor inserted"
    error_ipval="not valid format for ip"
    error_ipex="already exists"
    error_mask="no valid format for netmask"
    error_nsel="no selection done"
    error_tmips="too many ips"
    error_rtval="not valid format for net"
    error_default="a default route exists yet"
    error_modules_fich="the software file doesn't exist"
    error_data_fich="the data file doesn't exist"
    error_failmod="failre updating modules"
    error_rw="the file system didn't can change to a read-write file system"
    error_bkf="backup file don't exist"
    error_nodir="no directory selected"
    error_faildata="failure updating data"
    error_iniconf="invalid configuration file format"
    error_connection="can't connect to the "
    error_inifiles="failure copying the configuration file"
    error_configuration="invalid configuration file"
    error_syssel="no system selected"
    error_sshpass="the command 'sshpass' is needed"
    error_entrypass="no password introduced"
    error_iniexist="no ini file found"
    error_space_path="a path with spaces can't be used"
    error_file_exists="The file already exists"
    exit_noip="no conection with the new IPs of the "
    error_ini="error whith equipment configuration, the previous status is restored"
    error_filesexists="a file with this name already exists"
    errornotsm="incorrect data directory"
    error_removedd="failure removing database"
    error_nsys="function only for 2 o 4 systems"
}

function Error_esp(){
    error_noins="no se ha introducido un valor"
    error_ipval="formato de ip invalido"
    error_ipex="ip ya existente"
    error_mask="formato de mascara invalido"
    error_nsel="no se ha selecionado nada"
    error_tmips="demasiadas ips"
    error_rtval="formato invalido para red"
    error_default="ya existe ruta por defecto"
    error_modules_fich="no se encuentra fichero de software"
    error_data_fich="no se encuentra fichero de datos"
    error_failmod="fallo actualizando modulos"
    error_rw="no se ha podido poner el sistema en modo escritura"
    error_bkf="no se encuentra fichero de backup"
    error_nodir="no se ha seleccionado directorio"
    error_faildata="fallo actualizando datos"
    error_iniconf="formato del achivo de configuración invalida"
    error_connection="no se puede conectar con el "
    error_inifiles="fallo copiando el archivo de configuración"
    error_configuration="archivo de configuración invalido"
    error_syssel="no se ha seleccionado sistema"
    error_sshpass="se necesita el comando 'sshpass'"
    error_entrypass="no se ha introducido password"
    error_iniexist="no se encontro fichero ini"
    error_space_path="no se pueden usar rutas con espacios"
    error_file_exists="ya existe el archivo"
    exit_noip="no hay conexión con las nuevas IPs del "
    error_ini="error con la configuración del equipo, situación anterior restaurada"
    error_filesexists="ya hay un fichero con este nombre"
    errornotsm="directorio de datos no valido"
    error_removedd="error borrando la base de datos"
    error_nsys="funcion solo para 2 o 4 sistemas"
}

function Entry_eng(){
    entry_newip="insert ip"
    entry_mask="insert netmask"
    entry_ip="insert ip for "
    entry_rt="insert net (* for default route)"
    entry_gw="insert gateaway"
    entry_metric="insert metric"
    entry_options="insert options"
    entry_passwd="insert password for "
    entry_file="insert name for the file"
    entry_size="insert a size for the database (MB)"
    entry_wncip="insert wnc ip"
    entry_wncport="insert wnc port"
    entry_file_compress="entry name for configuration file"
}

function Entry_esp(){
    entry_newip="introduzca ip"
    entry_mask="introduzca mascara de red"
    entry_ip="introduzca ip para "
    entry_rt="introduzca red (* para ruta por defecto)"
    entry_gw="introduzca puerta de enlace"
    entry_metric="introduzca metric"
    entry_options="introduzca opciones"
    entry_passwd="introduzca contraseña del "
    entry_file="introduzca nombre para el archivo"
    entry_size="inserte tamaño para la base de datos (MB)"ç
    entry_wncip="inserte ip wnc"
    entry_wncport="inserte puerto wnc"
    entry_file_compress="introduzca un nombre para el archivo de configuración"
}

function Selection_eng(){
    sel_moddir="select modules directory"
    sel_datdir="select data directory"
    sel_des="select a destination directory"
    sel_database="select a file with the database"
    select_config_file="select configuration file"
}

function Selection_esp(){
    sel_moddir="seleccione el directorio de los modulos"
    sel_datdir="seleccione el directorio de los datos"
    sel_des="selecione directorio de destino"
    sel_database="selecione fichero con la base de datos"
    select_config_file="seleccione archivo de configuración"
}

function Files_eng(){
    equal="is equal to"
    noequal="is not equal to"
    est_texto1="is running in"
    est_texto2="is no running in"
    nomb_ver="version.txt"
    dirbd="database"
    nomb_rep="report"
}

function Files_esp(){
    equal="es igual a"
    noequal="no es igual a"
    est_texto1="esta en ejecución en"
    est_texto2="no esta en ejecución en"
    nomb_ver="version.txt"
    dirbd="b_datos"
    nomb_rep="datos"
}
function MenuForceRollback_esp(){
    mfrollbacktitle="base de datos"
}
function MenuForceRollback_eng(){
    mfrollbacktitle="database"
}
function MenuConfig_eng(){
    mconfilecol="configuration"
    mconfiletitle="seleccione archivo de configuaracion"
}
function MenuConfig_esp(){
    mconfilecol="configuracion"
    mconfiletitle="select configuration file"
}
function MenuIp_eng(){
    mititulo="select an option"
    miptitulo="choose a ip"
    mipcol="ip"
    mipexit="exit"
}

function MenuIp_esp(){
    mititulo="elija una opción"
    miptitulo="elija una ip"
    mipcol="ip"
    mipexit="salir"
}

function MenuDevice_eng(){
    md_titulo="select divice"
    md_col="device"
}

function MenuDevice_esp(){
    md_titulo="seleccione dispositivo"
    md_col="dispositivo"
}

function MenuAddDelIps_eng(){
    mgi_col1="option"
    mgi_col2="ip"
    mgi_opcion1="delete"
    mgi_opcion2="new ip"
    mgi_opcion3="exit"
}

function MenuAddDelIps_esp(){
    mgi_col1="acción"
    mgi_col2="ip"
    mgi_opcion1="eliminar"
    mgi_opcion2="nueva ip"
    mgi_opcion3="salir"
}

function MenuRoutes_eng(){
    mgr_col1="option"
    mgr_col2="net"
    mgr_col3="mask"
    mgr_col4="gateaway"
    mgi_opcion1="delete"
    mgr_opcion2="new route"
    mgr_opcion3="exit"
}

function MenuRoutes_esp(){
    mgr_col1="acción"
    mgr_col2="red"
    mgr_col3="mascara"
    mgr_col4="puerta de enlace"
    mgi_opcion1="eliminar"
    mgr_opcion2="nueva ruta"
    mgr_opcion3="salir"
}

function MenuIpBackup_eng(){
    mipbcktitulo="select ip"
    mipbckcol="ip"
    mipbckopcion="exit"
}

function MenuIpBackup_esp(){
    mipbcktitulo="seleccione ip"
    mipbckcol="ip"
    mipbckopcion="salir"
}

function MenuAutoConfig_eng(){
    mctitulo="generate a modules configuration?"
    mccolumna="option"
    mcopcion1="yes"
    mcopcion2="no"
}

function MenuAutoConfig_esp(){
    mctitulo="¿quiere auto-configurar?"
    mccolumna="opción"
    mcopcion1="si"
    mcopcion2="no"
}

function MenuSelectOperator_eng(){
    moptitulo="select operators"
    mopcol="short id"
}

function MenuSelectOperator_esp(){
    moptitulo="elija un operadores"
    mopcol="identificador"
}

function MenuSelectSystem_eng(){
    mstitulo="select systems"
    mscol="system"
    msopcion1="TRUE"
    msopcion2="COMPLEMENT"
    msopcion3="EXIT"
}

function MenuSelectSystem_esp(){
    mstitulo="elija un sistema"
    mscol="sistema"
    msopcion1="VERDAD"
    msopcion2="COMPLEMENTO"
    msopcion3="SALIR"
}
function MenuDatabaseDevice_eng(){
    mdevtitulo="select database device"
    mdevcol1="device"
    mdevcol2="offset"
    mdevexit="exit"
    mfrollbacktitle="database"
}
function MenuDatabaseDevice_esp(){
    mdevtitulo="select dispositivo de base de datos"
    mdevcol1="dispositivo"
    mdevcol2="offset"
    mdevexit="salir"
    mfrollbacktitle="base de datos"
}

function Question_eng(){
    question_tsm="The tsm file is different than the original. The database will be removed. Are you sure?"
    question_format="with this option a new intallation of system is needed, are you sure?"
    question_database="The database will be removed. Are you sure?"
    question_database2="all the TSRs will be removed, and must be activated again by the operator, are you really sure?"
    versionerror="verion of modules is incorrect ¿continue?"
    versionnodefined="version of modules is no defined ¿continue?"
    question_forcedatabase="a previous database will be used, data of the actual database will be lose. are you sure?"
    stopcapture="Stop Network Capture"
}

function Question_esp(){
    question_tsm="el fichero tsm es diferente del original. la base de datos sera borrada. ¿quiere continuar?"
    question_format="esta opción hara que el sistema no vuelva a iniciar si no se instala una imagen nueva, ¿quiere continuar?"
    question_database="la base de datos sera borrada. ¿quiere continuar?"
    question_database2="todas las TSRs seran borradas y se tendran que ser activadas otra vez por el operador. ¿seguro que quiere continuar?"
    versionerror="la version de los modulos es incorrecta ¿quiere continuar?"
    versionnodefined="la version de los modulos no esta definida ¿quiere continuar?"
    question_forcedatabase="se cargara una base de datos anterior y se perdera la informacion de la actual, ¿esta seguro de continuar?"
    stopcapture="parar captura de red"
}

function Progress_mod_eng(){
    pmtitulo="updating modules"
    pmtexto1="stopping systems"
    pmtexto2="transfering to"
    pmtexto3="generate configuration (wait to 'finish')"
    pmtexto4="updating md5"
    pmtexto5="starting systems"
    pmtexto6="finish"
}
function Progress_mod_esp(){
    pmtitulo="actualizando modulos"
    pmtexto1="parando los sistemas"
    pmtexto2="copiando modulos de"
    pmtexto3="actualizando configuración (espere a 'finalizado')"
    pmtexto4="actualizando .md5"
    pmtexto5="iniciando los sistemas"
    pmtexto6="finalizado"
}


function Progress_data_eng(){
    pdtitulo="updating data"
    pdtexto1="deleting data from"
    pdtexto2="transfer data to"
    pdtexto3="finish"
}
function Progress_data_esp(){
    pdtitulo="actualizando datos"
    pdtexto1="borrando datos de"
    pdtexto2="copiando datos a"
    pdtexto3="finalizado"
}


function Progress_delete_eng(){
    pbtitulo="removing databases"
    pbtexto1="stopping systems"
    pbtexto2="removing databases"
    pbtexto3="finish"
    pbtexto4="locating database's positions"
}
function Progress_delete_esp(){
    pbtitulo="limpiando la base de datos"
    pbtexto1="parando los sistemas"
    pbtexto2="borrando datos"
    pbtexto3="finalizado"
    pbtexto4="buscando las bases de datos"
}

function Progress_restore_eng(){
    prtitulo="restore"
    prtexto1="restore datacore and database"
}

function Progress_restore_esp(){
    prtitulo="restaurar"
    prtexto1="restaurando datacore y base de datos"
}
function CheckFatal(){
    local mod
    local aux
    local nlines
    local nfatallines
    aux=$2
    mod=`$sshcom root@${ip[$1]} "grep DriverName $progdir/${aux^^}/${aux,,}*.ini" 2>/dev/null|cut -f2 -d"="|awk '{print($1)}'`
    nlines=`$sshcom root@${ip[$1]} "cat $logdirectory/*$mod*FATAL.DOC" 2>/dev/null|wc -l`
    nfatallines=`$sshcom root@${ip[$1]} "cat $logdirectory/*$mod*FATAL.DOC" 2>/dev/null|grep -v "LOG Initialised" 2>/dev/null|wc -l`
    if [ $nlines -eq 0 ];then
        return 2
    elif [ $nfatallines -ne 0 ];then
        return 1
    elif [ $nlines -gt 1 ];then
        return 3
    else
        return 0
    fi
}
#this function checks that a value is with a correct ip format
#if is correct return 0
function IpFormat(){
    local format
    format=`echo "$1" | grep -Ec '^(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[0-9]{1}[0-9]{1}|[0-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[0-9]{1}[0-9]{1}|[0-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[0-9]{1}[0-9]{1}|[0-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[0-9]{1}[0-9]{1}|[0-9])$'`
    if [ $format -eq 0 ];then
        return 1
    fi
    return 0
}
function RemoveDD(){
    if [ $1 = "Linux" ];then
        shift
        RemoveDDLinux $*
        return $?
    elif [ $1 = "Fbsd" ];then
        shift
        RemoveDDFbsd $*
        return $?
    fi
}
function GetDD(){
    if [ $1 = "Linux" ];then
        shift
        GetDDLinux $*
        return $?
    elif [ $1 = "Fbsd" ];then
        shift
        GetDDFbsd $*
        return $?
    fi
}
function PutDD(){
    if [ $1 = "Linux" ];then
        shift
        PutDDLinux $*
        return $?
    elif [ $1 = "Fbsd" ];then
        shift
        PutDDFbsd $*
        return $?
    fi
}
function RemoveDDLinux(){
    if [ $# -eq 4 ];then
        local md5_1
        local md5_2
        Log command $1 "dd if=/dev/zero of=$4 bs=1M seek=$3 count=$2"
        md5_1=`dd if=/dev/zero count=$2 bs=1M|md5sum|cut -f1 -d" "`
        $sshcom root@${ip[$1]} "dd if=/dev/zero of=$4 bs=1M seek=$3 count=$2"
        md5_2=`$sshcom root@${ip[$1]} "dd if=$4 bs=1M skip=$3 count=$2"|md5sum|cut -f1 -d" "`
        echo $md5_2|grep -w $md5_1 >/dev/null 2>/dev/null
        return $?
    else
        return 2
    fi
}
function GetDDLinux(){
    local md5_1
    local md5_2
    if [ $1 = "nozip" ];then
        shift
        if [ $# -eq 5 ];then
            Log command $1 "$sshcom root@${ip[$1]} dd if=$4 bs=1M count=$2 skip=$3""|dd of=$5 bs=1M"
            md5_1=`$sshcom root@${ip[$1]} "dd if=$4 bs=1M count=$2 skip=$3"|md5sum|cut -f1 -d" "`
            $sshcom root@${ip[$1]} "dd if=$4 bs=1M count=$2 skip=$3"|dd of=$5 bs=1M
            md5_2=`md5sum $5|cut -f1 -d" "`
        else
            return 2
        fi
    else
        if [ $# -eq 5 ];then
            Log command $1 "$sshcom root@${ip[$1]} dd if=$4 bs=1M count=$2 skip=$3|gzip""|dd of=$5 bs=1M"
            md5_1=`$sshcom root@${ip[$1]} "dd if=$4 bs=1M count=$2 skip=$3|gzip"|md5sum|cut -f1 -d" "`
            $sshcom root@${ip[$1]} "dd if=$4 bs=1M count=$2 skip=$3|gzip"|dd of=$5 bs=1M
            md5_2=`md5sum $5|cut -f1 -d" "`
        else
            return 2
        fi
    fi
    echo $md5_2|grep -w $md5_1 >/dev/null 2>/dev/null
    return $?
}
function PutDDLinux(){
    local md5_1
    local md5_2
    if [ $1 = "nozip" ];then
        shift
        if [ $# -eq 4 ];then
            Log command $1 "dd if=$3 bs=1M|$sshcom root@${ip[$1]} dd of=$4 bs=1M seek=$2"
            #md5_1=`md5sum $3|cut -f1 -d" "`
            dd if=$3 bs=1M|$sshcom root@${ip[$1]} "dd of=$4 bs=1M seek=$2"
            #md5_2=`$sshcom root@${ip[$1]} "dd if=$4 bs=1M skip=$2"|md5sum|cut -f1 -d" "`
        else
            return 2
        fi
    else
        if [ $# -eq 4 ];then
            Log command $1 "dd if=$3 bs=1M|gunzip|$sshcom root@${ip[$1]} dd of=$4 bs=1M seek=$2"
            #md5_1=`dd if=$3 bs=1M|gunzip|md5sum|cut -f1 -d" "`
            dd if=$3 bs=1M|gunzip|$sshcom root@${ip[$1]} "dd of=$4 bs=1M seek=$2"
            #md5_2=`$sshcom root@${ip[$1]} "dd if=$4 bs=1M skip=$2"|md5sum|cut -f1 -d" "`
        else
            return 2
        fi
    fi
    #echo $md5_2|grep -w $md5_1 >/dev/null 2>/dev/null
    return $?
}
function RemoveDDFbsd(){
    local md5_1
    local md5_2
    if [ $# -eq 4 ];then
        Log command $1 "dd if=/dev/zero of=$4 bs=1M oseek=$3 count=$2"
        md5_1=`dd if=/dev/zero count=$2 bs=1M|md5sum|cut -f1 -d" "`
        $sshcom root@${ip[$1]} "dd if=/dev/zero of=$4 bs=1M oseek=$3 count=$2"
        md5_2=`$sshcom root@${ip[$1]} "dd if=$4 bs=1M iseek=$3 count=$2"|md5sum|cut -f1 -d" "`
        echo $md5_2|grep -w $md5_1 >/dev/null 2>/dev/null
        return $?
    else
        return 2
    fi
}
function GetDDFbsd(){
    local md5_1
    local md5_2
    if [ $1 = "nozip" ];then
        shift
        if [ $# -eq 5 ];then
            Log command $1 "$sshcom root@${ip[$1]} dd if=$4 bs=1M count=$2 iseek=$3""|dd of=$5 bs=1M"
            md5_1=`$sshcom root@${ip[$1]} "dd if=$4 bs=1M count=$2 iseek=$3"|md5sum|cut -f1 -d" "`
            $sshcom root@${ip[$1]} "dd if=$4 bs=1M count=$2 iseek=$3"|dd of=$5 bs=1M
            md5_2=`md5sum $5|cut -f1 -d" "`
        else
            return 2
        fi
    else
        if [ $# -eq 5 ];then
            Log command $1 "$sshcom root@${ip[$1]} dd if=$4 bs=1M count=$2 iseek=$3|gzip""|dd of=$5 bs=1M"
            md5_1=`$sshcom root@${ip[$1]} "dd if=$4 bs=1M count=$2 iseek=$3|gzip"|md5sum|cut -f1 -d" "`
            $sshcom root@${ip[$1]} "dd if=$4 bs=1M count=$2 iseek=$3|gzip"|dd of=$5 bs=1M
            md5_2=`md5sum $5|cut -f1 -d" "`
        else
            return 2
        fi
    fi
    echo $md5_2|grep -w $md5_1 >/dev/null 2>/dev/null
    return $?
}
function PutDDFbsd(){
    local md5_1
    local md5_2
    if [ $1 = "nozip" ];then
        shift
        if [ $# -eq 4 ];then
            Log command $1 "dd if=$3 bs=1M|$sshcom root@${ip[$1]} dd of=$4 bs=1M oseek=$2"
            #md5_1=`md5sum $3|cut -f1 -d" "`
            dd if=$3 bs=1M|$sshcom root@${ip[$1]} "dd of=$4 bs=1M oseek=$2"
            #md5_2=`$sshcom root@${ip[$1]} "dd if=$4 bs=1M iseek=$2"|md5sum|cut -f1 -d" "`
        else
            return 2
        fi
    else
        if [ $# -eq 4 ];then
            Log command $1 "dd if=$3 bs=1M|gunzip|$sshcom root@${ip[$1]} dd of=$4 bs=1M oseek=$2"
            #md5_1=`dd if=$3 bs=1M|gunzip|md5sum|cut -f1 -d" "`
            dd if=$3 bs=1M|gunzip|$sshcom root@${ip[$1]} "dd of=$4 bs=1M oseek=$2"
            #md5_2=`$sshcom root@${ip[$1]} "dd if=$4 bs=1M iseek=$2"|md5sum|cut -f1 -d" "`
        else
            return 2
        fi
    fi
    #echo $md5_2|grep -w $md5_1 >/dev/null 2>/dev/null
    return $?
}
function SshCommand(){
    local ipremota
    ipremota=${ip[$1]}
    shift
    $sshcom root@$ipremota "$*"
    return $?
}
function CompareFolder(){
    local resul
    local md5_local
    local md5_remote
    md5_local=`find $1 -type f -exec md5sum {} \;|awk '{print ($1)}'|sort|md5sum|awk '{print ($1)}'`
    if [ ${systype[$3]} = "Linux" ];then
        md5_remote=`$sshcom root@${ip[$3]} "find $2 -type f -exec md5sum {} \;"|awk '{print ($1)}'|sort|md5sum|awk '{print ($1)}'`
    else
        md5_remote=`$sshcom root@${ip[$3]} "find $2 -type f -exec md5 {} \;"|cut -f2 -d=|awk '{print ($1)}'|sort|md5sum|awk '{print ($1)}'`
    fi
    Log text "md5 local folder $1 - $md5_local | md5 $2 folder in system ${sist[$3]^^} - $md5_remote"
    echo $md5_local|grep -w $md5_remote >/dev/null 2>/dev/null
    resul=$?
    if ! [ -z $4 ] && [ $resul -eq 0 ];then
        echo "${sist[$3]^^}: $1 $equal $2" >> $4
    elif ! [ -z $4 ];then
        echo "${sist[$3]^^}:$1 $noequal $2" >> $4
    fi
    return $resul
}
function CompareFile(){
    local resul
    local md5_local
    local md5_remote
    md5_local=`md5sum $1|awk '{print ($1)}'`
    md5_remote=`$sshcom root@${ip[$3]} "cat $2"|md5sum|awk '{print ($1)}'`
    Log text "md5 local file $1 - $md5_local | md5 $2 file in system ${sist[$3]^^} - $md5_remote"
    echo $md5_local|grep -w $md5_remote >/dev/null 2>/dev/null
    resul=$?
    if ! [ -z $4 ] && [ $resul -eq 0 ];then
        echo "${sist[$3]^^}: $1 $equal $2" >> $4
    elif ! [ -z $4 ];then
        echo "${sist[$3]^^}:$1 $noequal $2" >> $4
    fi
    return $resul
}
#this function checks that a value is with a correct mask format (no 1's after the first 0 in binary)
#if a second value is given check that is a net value consistent whith the mask
#if all is correct return 0
function MaskFormat(){
    local int
    local bin_mask
    local bin_ip
    local flag
    local first
    local i
    IpFormat $1    
    if [ $? -ne 0 ]; then
        return 1
    fi
    for i in `seq 1 4`;do
        int=`echo $1|cut -f$i -d.`
        int=`echo "obase=2;$int"|bc|awk '{printf "%.8d\n", $0}'`
        if [ $i -eq 1 ];then
            bin_mask=$int
        else
            bin_mask=$bin_mask$int
        fi
    done
    flag=0
    for i in `seq 1 32`;do
        int=`echo $bin_mask|cut -c$i`
        if [ $int -eq 1 ] && [ $flag -eq 1 ];then
            return 1
        elif [ $int -eq 0 ] && [ $flag -eq 0 ];then
            flag=1
            first=$i
        fi
    done
    if [ $# -eq 2 ];then
        for i in `seq 1 4`;do
            int=`echo $2|cut -f$i -d.`
            int=`echo "obase=2;$int"|bc|awk '{printf "%.8d\n", $0}'`
            if [ $i -eq 1 ];then
                bin_ip=$int
            else
                bin_ip=$bin_ip$int
            fi
        done
        for i in `seq $first 32`;do
            int=`echo $bin_ip|cut -c$i`
            if [ $int -eq 1 ];then
                return 1
            fi
        done
    fi
    return 0
}

function CheckCommandLine(){
    local command
    local count
    local command_i
    local i
    if [ `echo "$1%2"|bc` -eq 0 ];then
        command="Command"
    else
        command="Shell"
    fi
    count=1
    for i in `$sshcom root@${ip[$1]} "grep -n -v \"^ *;\" ${fcip[$1]}"|grep $command|grep -v "Section"|cut -f1 -d:`;do
        command_i=`$sshcom root@${ip[$1]} "awk '{if (NR==$i) print}' ${fcip[$1]}"|cut -f1 -d=|awk '{print ($1)}'`
        if [ $command_i != $command$count ];then
            $sshcom root@${ip[$1]} "awk '{if (NR==$i) gsub(/$command_i/,\"$command$count\");print}' ${fcip[$1]} > /tmp/intermedio"
            $sshcom root@${ip[$1]} "rm ${fcip[$1]}"
            $sshcom root@${ip[$1]} "mv /tmp/intermedio ${fcip[$1]}"
        fi
        count=`echo "$count+1"|bc`
    done
}
#check if a ip value is defined in ECTM yet
#if is not defined return 0
function ExistIp(){
    local i
    for i in ${pos[*]};do
        if [ `echo "$i%2"|bc` -eq 0 ];then
            $sshcom root@${ip[$i]} "grep Command ${fcip[$i]}"|grep -v "^ *;"|grep $1
            if [ $? -eq 0 ];then
                return 1
            fi
        else
            $sshcom root@${ip[$i]} "grep Shell ${fcip[$i]}"|grep -v "^ *;"|grep $1
            if [ $? -eq 0 ];then
                return 1
            fi
        fi
    done
    return 0
}
#show in a menu the ip's defined in a ECTM system
#and change the selected ip for a new one (ip and mask)
#if the old ip is the one asociate for the system for the script it is changed too
function ChangeIps(){
    local pattern
    local old_ip
    local new_ip
    local most
    local old_mask
    local most_mask
    local new_mask
    local tipo
    local prog
    local line
    local i
    local s
    Rewritable
    if [ $? -ne 0 ];then
        $errormesg"$error_rw"
        return 8
    fi
    if [ `echo $1%2|bc` -eq 0 ];then
        pattern="Command"
    else
        pattern="Shell"
    fi
    while [ true ];do
        old_ip=$((for i in `seq 1 3`;do
                most=`$sshcom root@${ip[$1]} "cat ${fcip[$1]}"|grep "$pattern$i[=,\" \"]"|grep -v "^ *;"|cut -f2 -d=|awk '{print ($3)}'`
                most_mask=`$sshcom root@${ip[$1]} "cat ${fcip[$1]}"|grep "$pattern$i[=,\" \"]"|grep -v "^ *;"|cut -f2 -d=|awk '{print ($5)}'`
                echo $most
                echo $most_mask
            done
            echo $mipexit
            echo " "
            )|
            zenity --list --title="$miptitulo" --column="$mipcol" --column="netmask" --hide-column=2 --print-column=1,2 --title=${sist[$1]^^})
        old_mask=`echo $old_ip|cut -f2 -d"|"`
        old_ip=`echo $old_ip|cut -f1 -d"|"`
        if [ $old_ip = $mipexit ] || [ -z $old_ip ];then
            return 0
        fi
        new_ip=`zenity --entry --text="$entry_newip $for_text ${sist[$1]^^}"`
        if [ $? -ne 0 ] || [ -z $new_ip ];then
            $errormesg"$error_noins"
            continue
        fi
        IpFormat $new_ip
        if [ $? -ne 0 ]; then
            $errormesg"$error_ipval"
            continue
        fi   
        if [ $new_ip != $old_ip ];then
            ExistIp $new_IP 
            if [ $? -ne 0 ];then
                $errormesg"$error_ipex"
                continue
            fi
        fi
        new_mask=`zenity --entry --text="$entry_mask $for_text ${sist[$1]^^}"`
        if [ $? -ne 0 ] || [ -z $new_mask ];then
            $errormesg"$error_noins"
            continue
        fi
        MaskFormat $new_mask
        if [ $? -eq 1 ];then
            $errormesg"$error_mask"
            continue
        fi
        for s in ${pos[*]};do
            for i in `$sshcom root@${ip[$s]} "ls $progdir/*/*${sis_t[$s]}"`;do
                l$sshcom root@${ip[$s]} s $i.ini >/dev/null 2>/dev/null
                if [ $? -ne 0 ];then
                    $sshcom root@${ip[$s]} "awk '{gsub(/$old_ip/,\"$new_ip\");print}' $i.ini > /tmp/intermedio"
                    $sshcom root@${ip[$s]} "rm $i.ini"
                    $sshcom root@${ip[$s]} "mv /tmp/intermedio $i.ini"
                    line=`$sshcom root@${ip[$s]} "grep -n -v \"^ *;\" $i.ini"|grep $pattern|grep $new_ip|cut -f1 -d":"`
                    if [ $? -eq 0 ];then
                        if [ $old_mask != $new_mask ];then
                           $sshcom root@${ip[$s]} "awk '{if (NR==$line) gsub(/$old_mask/,\"$new_mask\");print}' $i.ini > /tmp/intermedio"
                           $sshcom root@${ip[$s]} "rm $i.ini"
                           $sshcom root@${ip[$s]} "mv /tmp/intermedio $i.ini"
                        fi
                    fi
                fi
            done
        done
        GenMd5 other
        if [ ${final_ip[$1]} = $old_ip ];then
            final_ip[$1]=$new_ip
        fi
     done
}
#add an extra ip for a device of the system
function NewIp(){
    local dev
    local new_ip
    local new_mask
    local line
    local command
    local flag
    local i
    if [ ${systype[$1]} = "Linux" ];then
        dev=`zenity --list --title="$md_titulo $for_text ${sist[$1]^^}" --column="$md_col"\
            eth1\
            eth2`
    else
        dev=`zenity --list --title="$md_titulo $for_text ${sist[$1]^^}" --column="$md_col"\
            em1\
            em2`
    fi
    if [ -z $dev ];then
        zenity --error="$error_nsel"
        return 0
    fi
    new_ip=`zenity --entry --text="$entry_ip $dev $for_text ${sist[$1]^^}"`
    if [ $? -ne 0 ] || [ -z $new_ip ];then
        zenity --error="$error_noins"
        return 0
    fi
    IpFormat $new_ip
    if [ $? -ne 0 ]; then
        $errormesg"$error_ipval"
        return 0
    fi
    ExistIp $new_ip
    if [ $? -ne 0 ];then
        $errormesg"$new_ip $error_ipex"
        return 0
    fi
    new_mask=`zenity --entry --text="$entry_mask $for_text ${sist[$1]^^}"`
    MaskFormat $new_mask
    if [ $? -eq 1 ];then
        $errormesg"$error_mask"
        return 0
    fi
    flag=1
    if [ ${systype[$1]} = "Linux" ];then
        for i in a b c d e f g h i j k l m n o p q r s t u v w x y z; do
            $sshcom root@${ip[$1]} "grep $dev:$i ${fcip[$1]}|grep -v ';'"
            if [ $?  -ne 0 ];then
                dev=$dev:$i
                flag=0
                break
            fi
        done
        if [ $flag -ne 0 ];then
            zenity --error="$error_tmips"
            return 1
        fi
    fi
    line=`$sshcom root@${ip[$1]} "cat ${fcip[$1]}"|grep -n -v "^ *;"|grep $2|grep ifconfig|tail -1|cut -f1 -d:`
    if [ ${systype[$1]} = "Linux" ];then
        command="$2 = /sbin/ifconfig $dev $new_ip netmask $new_mask"
    else
        command="$2 = /sbin/ifconfig $dev $new_ip netmask $new_mask alias"
    fi
    $sshcom root@${ip[$1]} "awk '{print;if (NR==$line) print \"$command\"}' ${fcip[$1]} > /tmp/fichaux"
    $sshcom root@${ip[$1]} "rm -f ${fcip[$1]}"
    $sshcom root@${ip[$1]} "mv /tmp/fichaux ${fcip[$1]}"
    CheckCommandLine $1
}
#show the extras ip's of a system
#if select a ip extra removes it of the configuration
#if select add new ip uses the function  "NewIp"
function AddDelIps(){
    local pattern
    local action
    local devip
    local dev
    local old_ip
    local i
    Rewritable
    if [ $? -ne 0 ];then
        $errormesg"$error_rw"
        return 8
    fi
    if [ `echo $1%2|bc` -eq 0 ];then
        pattern="Command"
    else
        pattern="Shell"
    fi
    BackupModules
    while [ true ];do
        action=$((for i in `$sshcom root@${ip[$1]} "grep $pattern ${fcip[$1]}"|grep ifconfig|grep -v "^ *;"|cut -f1 -d=|awk '{print ($1)}'`;do
                    if [ $i != $pattern"1" ] && [ $i != $pattern"2" ] && [ $i != $pattern"3" ];then
                        devip=`$sshcom root@${ip[$1]} "cat ${fcip[$1]}"|grep "$i[=,\" \"]"|grep -v "^ *;"|cut -f2 -d=|awk '{print ($3)}'`
                        if [ $devip = ${ip[$1]} ];then
                            continue
                        fi
                        echo "$i"
                        echo "$mgi_opcion1"
                        echo "$devip"
                    fi
                done
                echo "nueva"
                echo "$mgi_opcion2"
                echo " "
                echo "salir"
                echo "$mgi_opcion3"
                echo " "
                )|
                zenity --list --column="opcion" --column="$mgi_col1" --column="$mgi_col2"\
                --hide-column=1  --title=${sist[$1]^^})
        case $action in
            $pattern*)dev=`$sshcom root@${ip[$1]} "cat ${fcip[$1]}"|grep "$action[=,\" \"]"|grep -v "^ *;"|cut -f2 -d=|awk '{print ($2)}'`
                      old_ip=`$sshcom root@${ip[$1]} "cat ${fcip[$1]}"|grep "$action[=,\" \"]"|grep -v "^ *;"|cut -f2 -d=|awk '{print ($3)}'`
                      if [ ${systype[$1]} = "Linux" ];then
                          $sshcom root@${ip[$1]} "sed -i'' '/$action/d' ${fcip[$1]}"
                          CheckCommandLine $1
                          $sshcom root@${ip[$1]} "ifconfig $dev down"
                      else
                          $sshcom root@${ip[$1]} "sed -i'' -E '/$action/d' ${fcip[$1]}"
                          CheckCommandLine $1
                          $sshcom root@${ip[$1]} "ifconfig $dev $old_ip -alias"
                      fi;;
            nueva)NewIp $1 $pattern;;
            *)StopModules ${pos[*]}
              GenMd5 other
              StartModules ${pos[*]}
              return 0;;
        esac
    done
}
#delete a route of the configuration of the ECTM
function DelRoute(){
    local action
    local line
    local i
    for i in ${pos[*]};do
        if [ $1 = "none" ];then
            action=`$sshcom root@${ip[$i]} "grep default ${fcip[$i]}"|grep $2|grep -v "^ *;"|cut -f1 -d"="|awk '{print ($1)}'`
            if [ ${systype[$i]} = "Linux" ];then
                $sshcom root@${ip[$i]} "sed -i'' '/$action/d' ${fcip[$i]}"
            else
                $sshcom root@${ip[$i]} "sed -i'' -E '/$action/d' ${fcip[$i]}"
            fi
            $sshcom root@${ip[$i]} "route del default"
        else
            action=`$sshcom root@${ip[$i]} "grep $1 ${fcip[$i]}"|grep $2|grep -v "^ *;"|cut -f1 -d"="|awk '{print ($1)}'`
            line=`$sshcom root@${ip[$i]} "cat ${fcip[$i]}"|grep "$action[=,\" \"]"|grep -v "^ *;"|cut -f2 -d=|awk '{print ($1),("del"),($3),($4),($5),($6),($7),($8),($9),($10)}'`
            if [ ${systype[$i]} = "Linux" ];then
                $sshcom root@${ip[$i]} "sed -i'' '/$action/d' ${fcip[$i]}"
            else
                $sshcom root@${ip[$i]} "sed -i'' -E '/$action/d' ${fcip[$i]}"
            fi
            $sshcom root@${ip[$i]} "$line"
        fi
        CheckCommandLine $i
    done
}
#add a new route to the configuration of the ECTM
function NewRoute(){
    local net
    local mask
    local maskc
    local gateaway
    local gateawayc
    local pattern
    local command
    local i
    net=`zenity --entry --text="$entry_rt"`
    if [ $? -ne 0 ] || [ -z "$net" ];then
        $errormesg"$error_noins"
        return 0
    fi
    if [ "$net" != "*" ];then
        IpFormat $net
        if [ $? -ne 0 ]; then
            $errormesg"$error_rtval"
            return 0
        fi
        mask=`zenity --entry --text="$entry_mask"`
        if [ $? -ne 0 ] || [ -z "$net" ];then
            $errormesg"$error_noins"
            return 0
        fi
        MaskFormat $mask $net
        if [ $? -ne 0 ];then
            $errormesg"$error_mask"
            return 0
        fi
    else 
        $sshcom root@${ip[0]} "grep -n -v \"^ *;\" ${fcip[0]}"|grep Command|grep default
        if [ $? -eq 0 ];then
            $errormesg"$error_default"
            return 0
        fi
    fi
    gateaway=`zenity --entry --text="$entry_gw"`
    if [ $? -ne 0 ] || [ -z $gateaway ];then
        zenity --error="$error_noins"
        return 0
    fi
    IpFormat $gateaway
    if [ $? -ne 0 ]; then
        $errormesg"$error_ipval"
        return 0
    fi
    for i in ${pos[*]};do
        if [ ${systype[$i]} = "Linux" ];then
            maskc="netmask $mask"
            gateawayc="gw $gateaway"
        else
            maskc="-netmask $mask"
            gateawayc="$gateaway"
        fi
        if [ `echo "$i%2"|bc` -eq 0 ];then
            pattern="Command"
        else
            pattern="Shell"
        fi
        line=`$sshcom root@${ip[$i]} "cat ${fcip[$i]}"|grep -n -v "^ *;"|grep $pattern|tail -1|cut -f1 -d:`
        if [ $net != "*" ];then
            command="$pattern = /sbin/route add -net $net $maskc $gateawayc"
        else
            command="$pattern = /sbin/route add default $gateawayc"
        fi
        $sshcom root@${ip[$i]} "awk '{print;if (NR==$line) print \"$command\"}' ${fcip[$i]} > /tmp/fichaux"
        $sshcom root@${ip[$i]} "rm -f ${fcip[$i]}"
        $sshcom root@${ip[$i]} "mv /tmp/fichaux ${fcip[$i]}"
        CheckCommandLine $i
    done
}
#show the routes configured in the ECTM and use "DelRoute" when one is selected and "NewRoute" when select add new route
function Routes(){
    local action
    local net
    local netmask
    local gateaway
    local line
    local first
    local second
    local third
    local def
    local i
    Rewritable
    BackupModules
    if [ $? -ne 0 ];then
        $errormesg"$error_rw"
        return 1
    fi
    while [ true ];do
        action=$((for i in `$sshcom root@${ip[0]} "grep Command ${fcip[0]}"|grep route|grep -v "^ *;"|cut -f1 -d=|awk '{print ($1)}'`;do
                    def=`$sshcom root@${ip[0]} "cat ${fcip[0]}"|grep "$i[=,\" \"]"|grep -v "^ *;"|cut -f2 -d=|awk '{print ($3)}'`
                    if [ $def = "default" ];then
                        net="*"
                        netmask="0.0.0.0"
                        gateaway=`$sshcom root@${ip[0]} "cat ${fcip[0]}"|grep "$i[=,\" \"]"|grep -v "^ *;"|cut -f2 -d=|awk '{print ($5)}'`
                    else
                        net=`$sshcom root@${ip[0]} "cat ${fcip[0]}"|grep "$i[=,\" \"]"|grep -v "^ *;"|cut -f2 -d=|awk '{print ($4)}'`
                        netmask=`$sshcom root@${ip[0]} "cat ${fcip[0]}"|grep "$i[=,\" \"]"|grep -v "^ *;"|cut -f2 -d=|awk '{print ($6)}'`
                        gateaway=`$sshcom root@${ip[0]} "cat ${fcip[0]}"|grep "$i[=,\" \"]"|grep -v "^ *;"|cut -f2 -d=|awk '{print ($8)}'`
                    fi
                    echo "del"
                    echo "$mgi_opcion1"
                    echo "$net"
                    echo "$netmask"
                    echo "$gateaway"
                done
                echo "new"
                echo "$mgr_opcion2"
                echo " "
                echo " "
                echo " "
                echo "exit"
                echo "$mgr_opcion3"
                echo " "
                echo " "
                echo " "
                )|
                zenity --list  --column="code" --column="$mgr_col1" --column="$mgr_col2"\
                --column="$mgr_col3" --column="$mgr_col4" --hide-column=1 --print-column=1,3,5)
        first=`echo $action|cut -f1 -d"|"`
        second=`echo $action|cut -f2 -d"|"`
        if [ "$second" = "*" ];then
            second="none"
        fi
        third=`echo $action|cut -f3 -d"|"`
        case $first in
            del)DelRoute "$second" $third;; 
            new)NewRoute;;
            *)StopModules ${pos[*]}
              GenMd5 other
              ReadOnly
              StartModules ${pos[*]}
              return 0;;
         esac
    done
}
#check it a ip is configured for the ECTM if is not configured return 0
function FindIp(){
    local i
    touch /tmp/ips_backup
    grep $1 /tmp/ips_backup >/dev/null
    if [ $? -eq 0 ];then
        return 1
    fi
    for i in ${pos[*]};do
        if [ `echo "$i%2"|bc` -eq 0 ];then
            $sshcom root@${ip[$i]} "grep Command ${fcip[$i]}"|grep -v "^ *;"|grep $1 > /dev/null
            if [ $? -eq 0 ];then
                return 1
            fi
        else
            $sshcom root@${ip[$i]} "grep Shell ${fcip[$i]}"|grep -v "^ *;"|grep $1 >/dev/null
            if [ $? -eq 0 ];then
                return 1
            fi
        fi
    done    
    echo $1 >> /tmp/ips_backup
    return 0
}
#show the configured ip's to the backup ECTM in the main ECTM and change the selected for a new one
function BackupIps(){
    local old_ip
    local new_ip
    local update_line
    local nips
    local ippos
    local oldIFS
    local i
    local s
    Rewritable
    BackupModules
    if [ $? -ne 0 ];then
        $errormesg"$error_rw"
        return 1
    fi
    while [ true ];do
        old_ip=$((
            rm /tmp/ips_backup
            for i in ${pos[*]};do
                if [ `echo "$i%2"|bc` -eq 0 ];then
                    update_line=`$sshcom root@${ip[$i]} "grep -n -v \"^ *;\" ${fc[$i]}"|grep UPDATE|cut -f1 -d":"`
                    update_line=`$sshcom root@${ip[$i]} "awk '{if (NR>$update_line) print}' ${fc[$i]}"|grep Connection|head -1`
                    nips=`echo $update_line|awk 'BEGIN{FS=","};{print NF }'`
                    for s in `seq 1 $nips`;do
                        ippos=`echo $update_line|cut -f2 -d"="|cut -f$s -d","|cut -f1 -d":"|awk '{print ($1)}'`
                        FindIp $ippos
                        if [ $? -eq 0 ];then
                            echo $ippos
                        fi
                    done
                else
                    #change IFS in order to get lines in the for structure and no words
                    #the usage of the command variable is not correct with the new IFS so must be change inside
                    oldIFS=$IFS
                    IFS=$'\n'
                    for update_line in `(IFS=$oldIFS
                                 $sshcom root@${ip[$i]} "grep SystemConnections ${fc[$i]}"|grep -v "^ *;"
                                 IFS=$'\n')`;do
                        IFS=$oldIFS
                        nips=`echo $update_line|awk 'BEGIN{FS=","};{print NF }'`
                        for s in `seq 1 $nips`;do
                            ippos=`echo $update_line|cut -f2 -d"="|cut -f$s -d","|cut -f1 -d":"|awk '{print ($1)}'`
                            FindIp $ippos
                            if [ $? -eq 0 ];then
                                echo $ippos
                            fi
                        done
                        IFS=$'\n'
                    done
                    IFS=$oldIFS
                fi
            done
            echo $mipbckopcion
            )|
            zenity --list --title="$mipbcktitulo" --column="$mipbckcol")
        if [ -z $old_ip ] || [ $old_ip = $mipbckopcion ];then
            StopModules ${pos[*]}
            GenMd5 other
            StartModules ${pos[*]}
            ReadOnly
            return 1
        fi
        new_ip=`zenity --entry --text="$entry_newip"`
        if [ $? -eq 0 ] || [ $new_ip ];then
            IpFormat $new_ip
            if [ $? -ne 0 ]; then
                $errormesg"$error_ipval"
            else
                for i in ${pos[*]};do
                    $sshcom root@${ip[$i]} "awk '{gsub(/$old_ip/,\"$new_ip\");print}' ${fc[$i]} > /tmp/intermedio"
                    $sshcom root@${ip[$i]} "rm ${fc[$i]}"
                    $sshcom root@${ip[$i]} "mv /tmp/intermedio ${fc[$i]}"
                done
            fi   
        else
            $errormesg"$error_noins"
        fi
    done
}

function StartModules(){
    local i
    local connection
    local count_fatal
    local init_io
    local resul
    local hostname
    resul=0
    connection=0
    for i in $*;do
        if [ $type = "ectm" ];then
            $sshcom root@${ip[$i]} "rm -f /tmp/STOP"
        else
            $sshcom root@${ip[$i]} "init 3"
        fi
        Log text "${sist[$i]} started"
        if [ ${ip[$i]} != ${final_ip[$i]} ];then
            sleep 4
            ip[$i]=${final_ip[$i]}
            hostname=`$sshcom root@${ip[$i]} hostname`
            if [ ${hostname^^} != ${sist[$i]^^} ];then
                connection=1
            fi
        fi
    done
    if [ $connection -ne 0 ];then
        zenity --info --text="$exit_noip ${type^^}"
        exit 100
    fi
    if [ $check_io -ne 0 ];then
        init_io=0
        if [ $type = "ectm" ];then
            sleep 6
        else
            sleep 25
        fi
        if [ $ini_error -eq 0 ];then
            for i in $*;do
                count_fatal=`$sshcom root@${ip[$i]} "cat $logdirectory/LOG*IO[_T]*FATAL.DOC"|wc -l`
                if [ $? -ne 0 ] || [ $count_fatal -gt 1 ];then
                    init_io=1
                fi
            done
        else
            init_io=1
        fi
        if [ $init_io -ne 0 ];then
            StopModules ${pos[*]}
            RestoreModules
            check_io=0
            ini_error=0
            StartModules ${pos[*]}
            resul=100
        fi
        for i in $*;do
            $sshcom root@${ip[$i]} "rm -r -f /tmp/backupmodules"
        done
    fi
    check_io=0
    return $resul
}
function StopModules(){
    local i
    for i in $*;do
        if [ $type = "ectm" ];then
            $sshcom root@${ip[$i]} "touch /tmp/STOP"
        else
            $sshcom root@${ip[$i]} "init 2"
        fi
        Log text "${sist[$i]} stopped"
    done
    sleep 6
    return 0
}
#reboot the system
function Reset(){
    local i
    for i in $*;do
        $sshcom root@${ip[$i]} "init 6"
    done
    return 0
}
#the next two functions (one for 2 systems and the other to 4 systems configuration) return the positon of the ECTM system
#where a module must be copied
function Destmodule1(){
    if [[ $1 == *.${sis_t[*]}* ]];then
        return ${pos[*]}
    else
        return 4
    fi
}
function DestModule2(){
    case $1 in
        *.${sis_t[0]}*)return 0;;
        *.${sis_t[1]}*)return 1;;
        *)return 4;;
    esac    
}
function DestModule4(){
    case $1 in
        *.a.32*)return 0;;
        *.a.64*)return 1;;
        *.b.32*)return 2;;
        *.b.64*)return 3;;
        *)return 4;;
    esac
}
#this function generate the .md5 files is not value is given also stop and start the ECTM
function GenMd5(){
    local md5
    local file
    local s
    local i
    if [ -z $1 ] || [ $1 != "other" ];then
        StopModules ${pos[*]}
        Rewritable
    fi
    for s in ${pos[*]};do
        if [ $type = "emkp" ];then
            md5=md5
        elif [ `echo "$s%2"|bc` -eq 0 ];then
            md5=md5.32
        else
            md5=md5.64
        fi
        for i in `$sshcom root@${ip[$s]} "ls $progdir/*/*${sis_t[$s]}*.ini"`;do
             file=`echo ${i%.ini}`
             $sshcom root@${ip[$s]} "$md5 $i $file" 
             Log text "md5 file updated for $file in ${sist[$s]^^}"
        done
    done
    if [ -z $1 ] || [ $1 != "other" ];then
        ReadOnly
        StartModules ${pos[*]}
    fi
    return 0
}

function IpAutoConfig(){
    local i
    local dev
    for i in ${pos[*]};do
        dev=`$sshcom  root@${ip[$i]} "grep ${ip[$i]} ${fcip[$i]}"|grep -v "^ *;"|cut -f2 -d"="|awk '{print ($2)}'`
        case $dev in
            em1|eth1*)dev=1;;
            em2|eth2*)dev=2;;
            *)return 3;;
        esac
        final_ip[$i]="10.$1.$dev.${term_ip[$i]}"
    done
}
function WNCOptions(){
   local i
   local wncip
   local wncpor
   wncip=`zenity --entry --text="$entry_wncip"`
   IpFormat $wncip
   if [ $? -ne 0 ];then
       return 1
   fi
   wncport=`zenity --entry --text="$entry_wncport"`
   if [ $wncport -gt 0 ] && [ $wncport -lt 65536 ];then
      echo
   else
      return 1
   fi
   for i in ${pos[*]};do
       if [ `echo "$i%2"|bc` -ne 0 ];then
           $sshcom root@${ip[$i]} "awk '{gsub(/DEFINE HERE OUTPUT WNC CONNECTIONS/,\"$wncip:$wncport\");print}' ${fcip[$i]} > /tmp/intermedio"
           $sshcom root@${ip[$i]} "rm -f ${fcip[$i]}"
           $sshcom root@${ip[$i]} "mv /tmp/intermedio ${fcip[$i]}"
       fi    
   done
}
#this function execute the modules with the option -config to generate the .ini files
function AutoConfig(){
    local ide
    local short_id
    local tipo
    local ind
    local identifier
    local default
    local fichkp2
    local s
    local i
    local t
    local u
    local resul
    local count
    local back
    local dest
    locar resulini
    local dir
    local configmodules
    local op
    local count2
    resul=0
    if [ -z $1 ] || [ $commandline -eq 1 ];then
        StopModules ${pos[*]}
        Rewritable
        BackupModules
        if [ $? -ne 0 ];then
            $errormesg"$error_rw"
            return 1
        fi
    fi
    if [ $commandline -eq 1 ];then
        ide=$*
        is2conf="n"
    else
        if [ -z ${ip[0]} ];then
            ind=0
        else
            ind=1
        fi
        if [ $is2conf = "y" ];then
           op=$((for i in `$sshcom root@${ip[$ind]} "grep 'OP_' $data/TSM/*"|cut -f2 -d=|cut -f1 -d,`;do
                     echo 1
                     echo 0x$i
                     echo 0x$i
                  done
              )|zenity --list --title="$moptitulo" --height=210\
              --column="check" --column="$mopcol" --column="$mopcol"\
              --checklist --multiple\
              --hide-column=2 --separator=",")
        fi
        $sshcom root@${ip[$ind]} "ls $data/KP2/*"
        if [ $?  -eq 0 ];then
            fichkp2=`$sshcom root@${ip[$ind]} "ls $data/KP2"|head -1`
            identifier=`$sshcom root@${ip[$ind]} "grep SLAVE_ID $data/KP2/$fichkp2"|cut -f2 -d=|awk '{print ($1)}'|tr -d $'\r'`
            identifier=0x$identifier
        else
            identifier="0x400"
        fi
        default="$identifier $default_autoconfig_options"
        ide=`zenity --entry --text="$entry_options" --entry-text="-identifier=$default"`
    fi
    let short_id=`echo $ide|awk '{for (k=1;k<=NF;k++){if ($k ~ /-id=/) print ($k)}}'|cut -f2 -d"="`
    if [ $? -ne 0 ] || [ -z $short_id ];then
        short_id=1
    fi
    IpAutoConfig $short_id
    for s in ${pos[*]};do
        if [ `echo "$s%2"|bc` -eq 0 ];then
            configmodules=$truemodules
        else
            configmodules=$compmodules
        fi
        for t in $configmodules;do
            for i in `$sshcom root@${ip[$s]} "ls $progdir/$t/*${sis_t[$s]}"`;do
                resulini=0
                count=0
                while [ $resulini -eq 0 ] && [ $count -lt 3 ];do
                    $sshcom root@${ip[$s]} "$i -config $ide > $i.ini"
                    resulini=`$sshcom root@${ip[$s]} "cat $i.ini"|wc -l`
                    let count=$count+1
                done
                if [ $resulini -eq 0 ];then
                    $sshcom root@${ip[$s]} rm $i.ini
                    dir=`echo $progdir|tr -d "/"`
                    back=`echo $i.ini |awk "{gsub(/$dir/,\"tmp/backupmodules\");print}"`
                    $sshcom root@${ip[$s]} ls $back >/dev/null 2>/dev/null
                    if [ $? -eq 0 ];then
                        dest=`echo $i |awk 'BEGIN {FS="/"};{for (k=2;k<=NF-1;k++) printf "/" $(k)}'`
                        $sshcom root@${ip[$s]} cp $back $dest
                    fi
                fi
            done
        done
        $sshcom root@${ip[$s]} "rm -f $progdir/IS2/*.ini"
        $sshcom root@${ip[$s]} "rm -f $progdir/MUX/*${sis_t[$s]}.*"
        $sshcom root@${ip[$s]} "echo '' > $progdir/MUX/mux"
        if [ $is2conf = "y" ];then
           resulini=0
           count=0
           while [ $resulini -eq 0 ] && [ $count -lt 3 ];do
              $sshcom root@${ip[$s]} "$progdir/IS2/is2.${sis_t[$s]} -config $ide -operators=$op > $progdir/IS2/is2.${sis_t[$s]}.ini"
              resulini=`$sshcom root@${ip[$s]} "cat $progdir/IS2/is2.${sis_t[$s]}.ini"|wc -l`
              let count=$count+1
           done
           if [ $resulini -eq 0 ];then
               $sshcom root@${ip[$s]} rm $progdir/IS2/is2.${sis_t[$s]}.ini
               $sshcom root@${ip[$s]} ls /tmp/backupmodules/IS2/is2.${sis_t[$s]}.ini >/dev/null 2>/dev/null
               if [ $? -eq 0 ];then
                   $sshcom root@${ip[$s]} cp $progdir/IS2/is2.${sis_t[$s]}.ini $progdir/IS2/
               fi
           fi
           $sshcom root@${ip[$s]} "rm -f $progdir/MUX/*${sis_t[$s]}.*"
           count2=0
           for u in `echo $op|tr "," " "`;do
               $sshcom root@${ip[$s]} "cp $progdir/MUX/mux.${sis_t[$s]} $progdir/MUX/mux.${sis_t[$s]}.$count2"
               resulini=0
               count=0
               while [ $resulini -eq 0 ] && [ $count -lt 3 ];do
                   $sshcom root@${ip[$s]} "$progdir/MUX/mux.${sis_t[$s]}.$count2 -config -instance=$count2 > $progdir/MUX/mux.${sis_t[$s]}.$count2.ini"
                   resulini=`$sshcom root@${ip[$s]} "cat $progdir/MUX/mux.${sis_t[$s]}.$count2.ini"|wc -l`
                   let count=$count+1
               done
               if [ $resulini -eq 0 ];then
                   $sshcom root@${ip[$s]} rm $progdir/MUX/mux.${sis_t[$s]}.$count2.ini
                   $sshcom root@${ip[$s]} ls /tmp/backupmodules/MUX/mux.${sis_t[$s]}.$count2.ini >/dev/null 2>/dev/null
                   if [ $? -eq 0 ];then
                       $sshcom root@${ip[$s]} cp $progdir/MUX/mux.${sis_t[$s]}.$count2.ini $progdir/MUX/
                   fi
               fi
               if [ `echo $s%2|bc` -eq 0 ];then
                   $sshcom root@${ip[$s]} "echo 'runforever.32 $progdir/MUX/mux.${sis_t[$s]}.$count2 /dev/null &' >> $progdir/MUX/mux"
               else
                   $sshcom root@${ip[$s]} "echo 'runforever.64 $progdir/MUX/mux.${sis_t[$s]}.$count2 /dev/null &' >> $progdir/MUX/mux"
               fi
               let count2=$count2+1
           done
           
        fi
    done
    
    echo $ide |grep '\-wnc' 2>/dev/null
    if [ $? -eq 0 ];then
        WNCOptions
    fi
    Log text "configuration generated with options \"$ide\""
    GenMd5 other
    if [ -z $1 ] || [ $commandline -eq 1 ];then
        ReadOnly
        StartModules ${pos[*]}
        resul=$?
    fi
    return $resul
}

#this funcition copy the new modules in the ECTM
function Modules(){
    local dir
    local fecha
    local op
    local mod
    local fich
    local nmod
    local per
    local nper
    local fallo
    local dest
    local script
    local i
    local s
    if [ $commandline -eq 1 ];then
        dir=$1
        ls $dir >/dev/null 2>/dev/null
        if [ $? -ne 0 ];then
            $errormesg"$error_nodir"
            return 100
        fi
    elif [ $programmer -eq 0 ];then
        dir=`zenity --file-selection --directory --title="$sel_moddir"`
        if [ $? -ne 0 ] || [ $dir = $PWD ];then
            $errormesg"$error_nodir"
            return 100
        fi
        echo $dir|grep " "
        if [ $? -eq 0 ];then
            $errormesg"$error_space_path"
            return 100
        fi
    elif [ -f Modules.tar.gz ];then
        fecha=`date +%d_%m_%Y.%H_%M`
        mkdir programmer$fecha 
        dir=$PWD/programmer$fecha/RELEASE
        cd programmer$fecha
        tar xzf ../Modules.tar.gz
    else
        $errormesg"$error_modules_fich"
    fi
    if [ $commandline -eq 1 ];then
        script=$PWD
        StopModules ${pos[*]}
        BackupModules
        Rewritable
        if [ $? -eq 0 ];then
            cd $dir
            fallo=0
            for i in ${pos[*]};do
                for s in `ls */*${sis_t[$i]}*`;do
                    mod=`echo $s|cut -f1 -d"/"`
                    fich=`echo $s|cut -f2 -d"/"`
                    $sshcom root@${ip[$i]} "mkdir $progdir/$mod" 2>/dev/null
                    $scpcom $s root@${ip[$i]}:$progdir/$mod
                    $sshcom root@${ip[$i]} "chmod +x $progdir/$s"
                    CompareFile $s $progdir/$s $i
                    if [ $? -ne 0 ];then
                        fallo=`echo "$fallo+1"|bc`
                    fi
                done
            done
            cd ..
            if [ $fallo -ne 0 ];then
                $errormesg"$error_failmod"
                resul=100
            else
                GenMd5 other
            fi 
        else
            $errormesg"$error_rw"
            return 100
        fi
        Log text "modules update with \"$dir\""
        ReadOnly
        StartModules ${pos[*]}
        return $?
    else
        (
        echo "1"
        script=$PWD
        echo "# $pmtexto1"
        StopModules ${pos[*]}
        Rewritable
        BackupModules
        if [ $? -eq 0 ];then
            echo "2"
            cd $dir
            nper=$[84/$n_systems]
            per=2
            fallo=0
            for i in ${pos[*]};do
                echo "# $pmtexto2 ${sist[$i]^^}"
                per=$[$per+$nper]
                for s in `ls */*${sis_t[$i]}*`;do
                    mod=`echo $s|cut -f1 -d"/"`
                    fich=`echo $s|cut -f2 -d"/"`
                    $sshcom root@${ip[$i]} "mkdir $progdir/$mod" 2>/dev/null
                    $scpcom $s root@${ip[$i]}:$progdir/$mod
                    $sshcom root@${ip[$i]} "chmod +x $progdir/$s"
                    CompareFile $s $progdir/$s $i
                    if [ $? -ne 0 ];then
                        fallo=$[$fallo+1]
                    fi
                done
                echo "$per"
            done
            if [ $fallo -ne 0 ];then
                $errormesg"$error_failmod"
            else
                if [ $programmer -eq 0 ];then
                    op=`zenity --list --title="$mctitulo" \
                    --column="codigo" --column="$mccolumna" \
                    1 "$mcopcion1" \
                    2 "$mcopcion2" \
                    --hide-column=1`
                else
                    op=2
                fi
                if [ -z $op ];then
                    op=2
                fi
                if [ $op -eq 1 ];then
                    echo "# $pmtexto3"
                    AutoConfig other
                else
                    echo "# $pmtexto4"
                    GenMd5 other
                fi
            fi 
        else
            $errormesg"$error_rw"
            return 100 
        fi
        echo "98"
        echo "# $pmtexto5"
        Log text "modules update with \"$dir\""
        if [ -z $1 ];then
            ReadOnly
            StartModules ${pos[*]}
        fi
        echo "100"
        echo "# $pmtexto6"
        ) |
        zenity --progress --title="$pmtitulo"\
        --percentage=0
    fi 
    return 0
}
#this function compare the md5 of the datacore in the system with the md5 of the original datacore copied.
function CompareData(){
    local dest
    for dest in ${pos[*]};do
        CompareFolder $1 $data $dest
        if [ $? -ne 0 ];then
            return 1
        fi
    done
    return 0
}
#this funciton check if the identifier of the new datacore is equal to the identifier of the ECTM
#if is different changes the identifier of the ECTM
function CompareId(){
    local idtsm
    local idtsm2
    local fichkp2
    local idkp2
    local ind
    local a
    local b
    local s
    local i
    if [ -z ${ip[0]} ];then
        ind=1
    else
        ind=0
    fi
    $sshcom root@${ip[$ind]} "ls $data/KP2/*"
    if [ $? -eq 0 ];then
        idtsm=`$sshcom root@${ip[$ind]} "grep  -v \"^ *;\" ${fc[$ind]}"|grep Identifier|cut -f2 -d=|awk '{print ($1)}'`
        let idtsm2=$idtsm
        fichkp2=`$sshcom root@${ip[$ind]} "ls $data/KP2"|head -1`
        idkp2=`$sshcom root@${ip[$ind]} "grep SLAVE_ID $data/KP2/$fichkp2"|cut -f2 -d=|awk '{print ($1)}'|tr -d $'\r'`
        let idkp2=0x$idkp2
        for s in ${pos[*]};do
            for i in `$sshcom root@${ip[$s]} "ls $progdir/*/*${sis_t[$s]}"`;do
                $sshcom root@${ip[$s]} ls $i.ini >/dev/null 2>/dev/null
                if [ $? -eq 0 ];then
                    idtsm=`$sshcom root@${ip[$s]} "grep  -v \"^ *;\" $i.ini"|grep -i -w  Identifier|cut -f2 -d=|awk '{print ($1)}'`
                    if [ $? -eq 0 ];then
                        let idtsm2=$idtsm
                        if [ $idtsm2 -ne $idkp2 ];then
                            a=`$sshcom root@${ip[$s]} "grep -n -v \"^ *;\" $i.ini"|grep -i Identifier|grep $idtsm    |cut -f1 -d:`
                            $sshcom root@${ip[$s]} "awk '{if (NR==$a) gsub(/$idtsm/,\"$idkp2\");print}' $i.ini > /tmp/intermedio"
                            if [ $? -ne 0 ];then
                                return 100
                            fi
                            $sshcom root@${ip[$s]} "rm $i.ini"
                            $sshcom root@${ip[$s]} "mv /tmp/intermedio $i.ini"
                        fi
                    fi
                    for b in `$sshcom root@${ip[$s]} "grep -v \"^ *;\" $i.ini"|grep -i Manager[0-9]`;do
                        idtsm=`echo $i|cut -f1 -d","|cut -f2 -d=|awk '{print ($1)}'`
                        let idtsm2=$idtsm
                        if [ $idtsm2 -ne $idkp2 ];then
                            b=`$sshcom root@${ip[$s]} "grep -n -v \"^ *;\" $i.ini"|grep -i Manager[0-9] |grep $idtsm|head -1|cut -f1 -d:`
                            $sshcom root@${ip[$s]} "awk '{if (NR==$b) gsub(/$idtsm/,\"$idkp2\");print}' $i.ini > /tmp/intermedio"
                            if [ $? -ne 0 ];then
                                return 100
                            fi
                        fi
                    done
                    idtsm=`$sshcom root@${ip[$s]} "grep  -v \"^ *;\" $i.ini"|grep -i -w ManagerId|cut -f2 -d=|awk '{print ($1)}'`
                    if [ $? -eq 0 ];then
                        let idtsm2=$idtsm
                        if [ $idtsm2 -ne $idkp2 ];then
                            a=`$sshcom root@${ip[$s]} "grep -n -v \"^ *;\" $i.ini"|grep -i ManagerId|grep $idtsm    |cut -f1 -d:`
                            $sshcom root@${ip[$s]} "awk '{if (NR==$a) gsub(/$idtsm/,\"$idkp2\");print}' $i.ini > /tmp/intermedio"
                            if [ $? -ne 0 ];then
                                return 100
                            fi
                            $sshcom root@${ip[$s]} "rm $i.ini"
                            $sshcom root@${ip[$s]} "mv /tmp/intermedio $i.ini"
                        fi
                    fi
                fi
            done
        done
        GenMd5 other
    fi
    return 0
}
#this function copy the database and DATACORE of a ECTM (only programmer)
#this function is called when the new DATACORE has a different TSM
function BackupData(){
    local bd
    local lug
    local ndd
    local i
    rm -f ../backup.tar
    mkdir Backup
    mkdir Backup/DATACORE
    if [ -z ${ip[0]} ];then
        $scprcom root@${ip[1]}:$data/* Backup/DATACORE
    else
        $scprcom root@${ip[0]}:$data/* Backup/DATACORE
    fi
    mkdir Backup/DATABASE
    DatabaseVarUpdate ${pos[*]}
    for i in ${pos[*]};do
        mkdir Backup/DATABASE/${sist[$i]}
        bd=`echo ${bd_device[$i]}|cut -f1 -d"|"`
        lug=`echo ${bd_offset[$i]}|cut -f1 -d"|"`
        if [ $bd != "0" ];then
            GetDD ${systype[$i]} $i $tam $lug $bd Backup/DATABASE/${sist[$i]}/bd.gz
        fi
    done
    ndd=`ps ax|grep ssh|grep dd|wc -l`
    while [ $ndd -ne 0 ];do
         ndd=`ps ax|grep ssh|grep dd|wc -l`
    done
    tar cf ../Backup.tar Backup
    rm -r -f Backup
}

#this function restore the copy of the DATACORE and the database of the function "BackupData"
function Restore(){
    local fecha
    local autodevice
    local ndd
    local i
    local s
    local bd
    local lug
    StopModules ${pos[*]}
    Rewritable
    if [ $? -ne 0 ];then
        $errormesg"$error_rw"
        return 1
    fi
    fecha=`date +%d_%m_%Y.%H_%M`
    mkdir programmer$fecha
    cd programmer$fecha
    tar xf ../Backup.tar
    if [ $? -ne 0 ];then
        $errormesg"$error_bkf"
        return 1
    fi    
    DatabaseVarUpdate ${pos[*]}
    (
    for i in ${pos[*]};do
        $sshcom root@${ip[$i]} "rm -r -f $data/*"
        $scprcom Backup/DATACORE/* root@${ip[$i]}:$data
        for s in `seq 1 ${ndatabases[$i]}`;do
            bd=`echo ${bd_device[$i]}|cut -f$s -d"|"`
            lug=`echo ${bd_offset[$i]}|cut -f$s -d"|"`
            PutDD ${systype[$1]} $i $lug Backup/DATABASE/${sist[$i]}/bd.gz $bd &
        done
    done
    ndd=`ps ax|grep ssh|grep dd|wc -l`
    while [ $ndd -ne 0 ];do
        case $ndd in
           [25-28])echo "19";;
           [20-24])echo "35";;
           [13-16)echo "47";;
           [9-12])echo "63";;
           [5-8])echo "83";;
           [1-4])echo "91";;
         esac
         ndd=`ps ax|grep ssh|grep dd|wc -l`
    done
    #CompareId
    echo "100"
    )|
    zenity --progress --title="$prtitulo"\
    --text="$prtexto1"\
    --percentage=0
    cd ..
    rm -r -f programmer$fecha
    ReadOnly
    StartModules ${pos[*]}
}
#this function update de DATACORE
function Data(){
    local dir
    local res
    local per
    local dest
    local fecha
    local newtsm
    local oldtsm
    local numtsm
    local resul
    resul=0
    if [ $commandline -eq 1 ];then
        dir=$1
        ls $dir >/dev/null 2>/dev/null
        if [ $? -ne 0 ];then
            $errormesg$error_nodir
            return 100
        fi
    elif [ $programmer -eq 0 ];then
        dir=`zenity --file-selection --directory --title="$sel_datdir"`
        if [ $? -ne 0 ] || [ $dir = $PWD ];then
            $errormesg"$error_nodir"
            return 1
        fi
        echo $dir|grep " "
        if [ $? -eq 0 ];then
            $errormesg"$error_space_path"
            return 1
        fi
    elif [ -f Data.tar.gz ];then
        fecha=`date +%d_%m_%Y.%H_%M`
        mkdir programmer$fecha 
        dir=$PWD/programmer$fecha/DATACORE
        cd programmer$fecha
        tar xzf ../Data.tar.gz
        newtsm=`ls DATACORE/TSM|cut -f1 -d"."|cut -f2 -d"_"`
        oldtsm=`$sshcom root@${ip[0]} "ls $data/TSM"|cut -f1 -d"."|cut -f2 -d"_"`
        if [ $newtsm != oldtsm ];then
            zenity --question --text="$question_tsm"
            if [ $? -eq 0 ];then
                BackupData
                RemoveDataBase
            else
                return 1
            fi
        fi
        cd ..
    else
        $errormesg"$error_data_fich"
        return 100
    fi
    res=0
    numtsm=`ls $dir/TSM/*.tsm|wc -l`
    if [ $numtsm -ne 1 ];then
        $errormesg"$errornotsm"
        return 1
    fi
    rm -f $dir/.directory > /dev/null 2>/dev/null
    rm -f $dir/*/.directory >/dev/null 2>/dev/null
    if [ -z $1 ] || [ $1 != "other" ];then
        StopModules ${pos[*]}
        Rewritable
        res=$?
    fi
    if [ $res -eq 0 ];then
        if [ $commandline -eq 1 ];then
            for dest in ${ip[*]};do
                $sshcom root@$dest "mkdir $data" 2>/dev/null
                $sshcom root@$dest "rm -f -r $data/*"
                $scprcom $dir/* root@$dest:$data
            done
            Log text "DATACORE update with \"$dir\""
        else
            (
            per=3
            for dest in ${ip[*]};do
                echo "$per"
                per=$[$per+9]
                $sshcom root@$dest "mkdir $data" 2>/dev/null
                echo "# $pdtexto1 $dest"
                $sshcom root@$dest "rm -f -r $data/*"
                echo "$per"
                per=$[$per+10]
                echo "# $pdtexto2 $dest"
                $scprcom $dir/* root@$dest:$data
                echo "$per"
                per=$[$per+6]
            done
            Log text "DATACORE update with \"$dir\""
            echo "# $pdtexto3"
            echo "100"
            ) |
            zenity --progress --title="$pdtitulo"\
            --percentage=0
        fi
        CompareData $dir
        if [ $? -ne 0 ];then
            $errormesg"$error_faildata"
            resul=100
        fi
        for dest in ${ip[*]};do
            $sshcom root@$dest "rm -f $data/*/*.gr"
            $sshcom root@$dest "rm -f $data/*.gr"
        done
    else
        $errormesg"$error_rw"
        return 100
    fi
    #CompareId
    DeleteTSRDATA
    ReadOnly
    StartModules ${pos[*]}
    if [ $? -ne 0 ];then
       resul=100
    fi
    return $resul
}

# this function select the .ini file for the script
# and read the functional variables
function FichIni(){
    local drc
    drc=`echo $0|awk 'BEGIN {FS="/"};{print NF}'`
    ini=`echo $0|cut -f$drc -d"/"|cut -f1 -d.`
    ls $ini.ini >/dev/null 2>/dev/null
    if [ $? -eq 0 ];then
        ini=$ini.ini
    else
        ini=`ls $ini*.ini|head -1`
        if [ $? -ne 0 ];then
            $errormesg"$error_iniexist"
            exit 100
        fi
    fi
    dos2unix $ini >/dev/null
}

# read the functional variables
function Variables(){
    local i
    local onesystem
    check_io=0
    ini_error=0
    type=`grep type $ini|grep -v "^ *;"|cut -f2 -d"="|awk '{print tolower($1)}'`
    if [ $? -ne 0 ];then
        type="ectm"
    fi
    checkversion=`grep check_version $ini|grep -v "^ *;"|cut -f2 -d"="|awk '{print tolower($1)}'|cut -c1`
    if [ $? -ne 0 ];then
        checkversion="n"
    fi
    n_systems=`grep n_systems $ini|grep -v "^ *;"|cut -f2 -d"="|awk '{print ($1)}'`
    if [ $? -ne 0 ];then
        n_systems=4
    fi
    sim_folder=`grep sim_folder $ini|grep -v "^ *;"|cut -f2 -d"="|awk '{print ($1)}'`
    if [ $? -ne 0 ];then
        sim_folder="none"
    fi
    default_autoconfig_options=`grep default_autoconfig_options $ini|grep -v "^ *;"|cut -f2- -d"="|tr -d '"'`
    if [ $n_systems -eq 2 ];then
        if [ $type = "ectm" ];then
            systype=(Linux Fbsd)
        elif [ $type = "emkp" ];then
            systype=(Linux Linux)
        else
            $errormesg"$error_iniconf"
            exit 100
        fi
        pos=(0 1)
        sist[0]=`grep true_system $ini|grep -v "^ *;"|cut -f2 -d"="|awk '{print tolower($1)}'`
        sist[1]=`grep complement_system $ini|grep -v "^ *;"|cut -f2 -d"="|awk '{print tolower($1)}'`
        if [ ${sist[0]} = a32 ];then
            fc[0]=$fcta
            fcip[0]=$fich_ip_ta
            term_ip[0]="32"
        elif [ ${sist[0]} = b32 ];then
            fc[0]=$fctb
            fcip[0]=$fich_ip_tb
            term_ip[0]="33"
        else
            $errormesg"$error_iniconf"
            exit 100
        fi
        if [ ${sist[1]} = a64 ];then
            fc[1]=$fcca
            fcip[1]=$fich_ip_ca
            term_ip[1]="64"
        elif [ ${sist[1]} = b64 ];then
            fc[1]=$fccb
            fcip[1]=$fich_ip_cb
            term_ip[1]="65"
        else
            $errormesg"$error_iniconf"
            exit 100
        fi
    elif [ $n_systems -eq 4 ];then
        if [ $type = "ectm" ];then
            systype=(Linux Fbsd Linux Fbsd)
        elif [ $type = "emkp" ];then
            systype=(Linux Linux Linux Linux)
        else
            $errormesg"$error_iniconf"
            exit 100
        fi
        pos=(0 1 2 3)
        sist=("a32" "a64" "b32" "b64")
        fc=("$fcta" "$fcca" "$fctb" "$fccb")
        fcip=("$fich_ip_ta" "$fich_ip_ca" "$fich_ip_tb" "$fich_ip_cb")
        term_ip=("32" "64" "33" "65")
    elif [ $n_systems -eq 1 ];then
        onesystem=`grep unique_system $ini|grep -v "^ *;"|cut -f2 -d"="|awk '{print tolower($1)}'`
        case $onesystem in
            a32)pos[0]=0
                systype[0]="Linux"
                sist[0]=$onesystem
                fc[0]=$fcta
                fcip[0]=$fich_ip_ta
                term_ip[0]="32";;
            a64)pos[1]=1
                if [ $type = "ectm" ];then
                    systype[1]="Fbsd"
                elif [ $type = "emkp" ];then
                    systype[1]="Linux"
                else
                    $errormesg"$error_iniconf"
                    exit 2
                fi
                sist[1]=$onesystem
                fc[1]=$fcca
                fcip[1]=$fich_ip_ca
                term_ip[1]="64";;
            b32)pos[0]=0
                systype[0]="Linux"
                sist[0]=$onesystem
                fc[0]=$fctb
                fcip[0]=$fich_ip_tb
                term_ip[0]="33";;
            b64)pos[1]=1
                if [ $type = "ectm" ];then
                    systype[1]="Fbsd"
                elif [ $type = "emkp" ];then
                    systype[1]="Linux"
                else
                    $errormesg"$error_iniconf"
                    exit 2
                fi
                sist[1]=$onesystem
                fc[1]=$fccb
                fcip[1]=$fich_ip_cb
                term_ip[1]="65";;
            *)$errormesg"$error_iniconf"
              exit 2;;
        esac
    else
        $errormesg"$error_iniconf"
        exit 100
    fi
    for i in ${pos[*]};do
        md5bdfich[$i]="none"
        md5fc[$i]="none"
        sis_t[$i]=`echo ${sist[$i]}|cut -c1`.`echo ${sist[$i]}|cut -c2,3`
        fcip_short[$i]=`echo ${fcip[$i]}|awk 'BEGIN {FS="/"};{print ($NF)}'`
    done
    if [ $programmer -eq 0 ];then
        keys=`grep keys $ini|grep -v "^ *;"|cut -f2 -d"="|awk '{print tolower($1)}'|cut -c1`
        if [ $? -ne 0 ] || [ $keys = "n" ];then
            keys="n"
        fi 
        inittab=`grep inittab $ini|grep -v "^ *;"|cut -f2 -d"="|awk '{print tolower($1)}'|cut -c1`
        if [ $? -ne 0 ] || [ $inittab != "n" ];then
            inittab="y"
        fi
    else
        keys=n
        inittab=y        
    fi
    is2conf=`grep is2_conf $ini|grep -v "^ *;"|cut -f2 -d"="|awk '{print tolower($1)}'|cut -c1`
    if [ $? -ne 0 ] || [ $is2conf = "n" ];then
        is2conf="n"
    fi 
}
function SynchroDate(){
    local i
    for i in ${pos[*]};do
        if [ ${systype[$i]} = "Linux" ];then
            $sshcom root@${ip[$i]} "date -s" @`echo $(($(date +%s%N)/1000000))` >/dev/null 2>/dev/null
            #$sshcom root@${ip[$i]} "date -s" `date +%m/%d/%y` >/dev/null 2>/dev/null
            #$sshcom root@${ip[$i]} "date -s" `date +%H:%M:%S` >/dev/null 2>/dev/null
        else
            $sshcom root@${ip[$i]} "date" `date +%y%m%d%H%M.%S` >/dev/null 2>/dev/null
        fi
    done
}

#this function change the filesystem to rewritable
function Rewritable(){
    local flag1
    local flag2
    local i
    flag1=0
    for i in ${pos[*]};do
        flag2=1
        while [ $flag1 -lt 10 ] && [ $flag2 -ne 0 ];do
            if [ ${systype[$i]} = "Linux" ];then
                $sshcom root@${ip[$i]} "mount -n -o remount,rw /"
                flag2=$?
            else
                $sshcom root@${ip[$i]} "mount -rw /"
                flag2=$?
            fi
            flag1=$[$flag1+1]
        done
        if [ $flag2 -ne 0 ];then
            return 1
        fi
    done
    return 0
}
#this function change the filesystem to read-only
function ReadOnly(){
    local i
    for i in ${pos[*]};do
        if [ ${systype[$i]} = "Linux" ];then
            $sshcom root@${ip[$i]} "mount -n -o remount,ro /"
        else
            $sshcom root@${ip[$i]} "mount -ur /"
        fi
    done
}


#this function read the ips fron the ini file and test them
function Ips(){
    local i
    local s
    local connect
    local cping
    local hostname
    for i in ${pos[*]};do
        ip[$i]=`grep ip_${sist[$i]} $ini|grep -v "^ *;"|cut -f2 -d"="|awk '{print ($1)}'`
        IpFormat ${ip[$i]}
        if [ $? -ne 0 ]; then
            $errormesg"$error_iniconf"
            exit 100
        fi
        ssh-keygen -R ${ip[$i]} >/dev/null 2>/dev/null
        if [ $keys = "y" ];then
            $sshcom root@${ip[$i]} -o "PreferredAuthentications publickey" "ls" >/dev/null 2>/dev/null
            connect=$?
        else
            $sshcom root@${ip[$i]} "ls" >/dev/null 2>/dev/null
            connect=$?
        fi
        if [ $connect -ne 0 ] && [ $keys = "y" ];then
            cping=`ping -c 4 ${ip[$i]}|grep 'received'|awk -F',' '{print $2}'|awk '{print $1}'`
            if [ $cping -ne 0 ];then
                ls $HOME/.ssh/*.pub >/dev/null 2>/dev/null
                if [ $? -ne 0 ];then
                    mkdir $HOME/.ssh >/dev/null 2>/dev/null
                    ssh-keygen -t dsa -N "" -f $HOME/.ssh/id_dsa 
                fi
                if [ ${systype[$i]} = "Linux" ];then
                    ssh $options root@${ip[$i]} mount -n -o remount,rw /
                else
                    ssh $options root@${ip[$i]} mount -rw /
                fi
                for s in `ls $HOME/.ssh/*.pub`;do
                    ssh-copy-id -i $s root@${ip[$i]}
                done
                $sshcom root@${ip[$i]} -o "PreferredAuthentications publickey" "ls" >/dev/null 2>/dev/null
                connect=$?
            fi
        fi
        if [ $connect -ne 0 ];then
            $errormesg"$error_connection ${type^^}"
            exit 100
        fi
        hostname=`$sshcom root@${ip[$i]} hostname`
        if [ ${hostname^^} != ${sist[$i]^^} ];then
           $errormesg"$error_connection ${type^^}"
           exit 100
        fi
        final_ip[$i]=${ip[$i]}
    done
}
#this funciton erase the MBR of a system
function Format(){    
    local root_device
    local devices
    local i
    local s
    for s in $*;do
        root_device=`$sshcom root@${ip[$s]} "df"|grep -v rootfs|awk '{if($NF=="/") print($1)}'`
        if [ ${systype[$s]} = "Linux" ];then
            devices=`$sshcom root@${ip[$s]} "fdisk -l"|grep dev|grep bytes|awk '{print ($2)}'|cut -f1 -d:`
        else
            devices=`$sshcom root@${ip[$s]} "ls -1 /dev/ada? /dev/da?"`
        fi
        for i in $devices;do
            echo $root_device|grep $i
            if [ $? -eq 0 ];then
                RemoveDD ${systype[$s]} $s 1 0 $i 
            fi
        done
    done
}
#this function delete the log files of the ECTM
function DeleteLogs(){
    local i
    for i in ${ip[*]};do
        $sshcom root@$i "rm -f $logdirectory/*.DOC" >/dev/null 2>/dev/null
        $sshcom root@$i "rm -f $logdirectory/*.OLD" >/dev/null 2>/dev/null
        $sshcom root@$i "rm -f $logdirectory/*.tsm" >/dev/null 2>/dev/null
        $sshcom root@$i "rm -f $logdirectory/*.toc" >/dev/null 2>/dev/null
        $sshcom root@$i "rm -f $logdirectory/*.kp2" >/dev/null 2>/dev/null
        $sshcom root@$i "rm -f $logdirectory/*.kp1" >/dev/null 2>/dev/null
        $sshcom root@$i "rm -f $logdirectory/*.pcap" >/dev/null 2>/dev/null
        $sshcom root@$i "rm -f $logdirectory/*.log" >/dev/null 2>/dev/null
        $sshcom root@$i "rm -f $logdirectory/*.dc" >/dev/null 2>/dev/null
        $sshcom root@$i "rm -f $logdirectory/*.OLD.gz" >/dev/null 2>/dev/null
        $sshcom root@$i "rm -f $logdirectory/*.dump" >/dev/null 2>/dev/null
    done
    Log text "logs removed"
    return 0
}
function DeleteTSRDATA(){
    local i
    for i in ${ip[*]};do
        $sshcom root@$i "rm -f $logdirectory/IOD/*" >/dev/null 2>/dev/null
    done
    return 0
}
#this function execute the modules with the option "-version" and store the output in a auxiliary file
function Version(){
    local tipo
    local rok
    local prog
    local mod
    local resul
    local finalresul
    local modversion
    local i
    local s
    finalresul=0
    for s in $*;do
            resul=0
        for i in `$sshcom root@${ip[$s]} "ls $progdir/*/*${sis_t[$s]}"`;do
            $sshcom root@${ip[$s]} ls $i.ini >/dev/null 2>/dev/null
            if [ $? -eq 0 ];then
                if [ $checkversion = "y" ];then
                    mod=`echo $i|awk 'BEGIN {FS="/"};{print $(NF-1)}'`
                    modversion=`grep $mod $ini|grep -v "^ *;"|cut -f2 -d"="|awk '{print ($1)}'`
                    if [ $? -ne 0 ];then
                        resul=1
                        Log text "no version defined for $mod module"
                    else
                        rok=`$sshcom root@${ip[$s]} "$i -version" |grep $modversion|wc -l`
                        if [ $rok -gt 0 ];then
                            resul=0
                            Log text "version of $mod module is correct in ${sis_t[$s]}"
                        else
                            resul=2
                            Log text "version of $mod module is no correct in ${sis_t[$s]}"
                        fi
                    fi
                    if [ $resul -gt $finalresul ];then
                        finalresul=$resul
                    fi
                fi
            fi
            $sshcom root@${ip[$s]} "$i -version" >> $PWD/$nomb_ver
        done
    done
    return $finalresul
}

#this funcion get the log directory ("/tmp") and put in a file
function GetLogs(){
    local fecha
    local rel
    local data2
    local i
    data2=`echo $data|awk 'BEGIN {FS="/"};{print ($NF)}'`
    if [ $dirlog = "0" ];then
        dirlog=`zenity --file-selection --directory --title="$sel_des"`
        rel=$?
        echo $dirlog|grep " "
        if [ $? -eq 0 ];then
            $errormesg"$error_space_path"
            return 1
        fi
        for i in $*;do
            $sshcom root@${ip[$i]} "cp -r $data $logdirectory"
        done
    else
        rel=0
    fi
    fecha=`date +%m_%d.%H_%M`
    if [ $rel -eq 0 ];then
        for i in $*;do
            $sshcom root@${ip[$i]} "tar czf - $logdirectory/*" > $dirlog/LOG.${sist[$i]^^}.$fecha.tar.gz
            log[$i]=LOG.${sist[$i]^^}.$fecha.tar.gz
            $sshcom root@${ip[$i]} "rm -r -f $logdirectory/$data2"
        done
    else
        $errormesg"$error_nodir"
    fi
    return 0
}
function GetTSRDATA(){
    local i
    local fecha
    fecha=`date +%d_%m.%H_%M`
    mkdir TSRDATA_$fecha
    for i in ${pos[*]};do
        mkdir TSRDATA_$fecha/${sist[$i]}
        $scpcom root@${ip[$i]}:$logdirectory/IOD/* TSRDATA_$fecha/${sist[$i]}
    done
    tar czf TSRDATA_$fecha.tar.gz TSRDATA_$fecha
    rm -r TSRDATA_$fecha
    return 0
}
#this funciton get the DATACORE of the ECTM
function GetDatacore(){
    local destino
    local rel
    local syst
    local fecha
    if [ -z $1 ];then
        destino=`zenity --file-selection --directory --title="$sel_des"`
        rel=$?
        echo $destino|grep " "
        if [ $? -eq 0 ];then
            $errormesg"$error_space_path"
            return 1
        fi
        fecha=`date +%d_%m.%H_%M`
        syst=0
    else
        destino=$PWD/$2
        rel=0
        fecha=${sist[$1]^^}
        syst=$1
    fi
    if [ $rel -eq 0 ];then
        mkdir $destino/DATACORE_$fecha
        $scprcom root@${ip[$syst]}:$data/* $destino/DATACORE_$fecha
    else
        $errormesg"$error_nodir"
        return 100
    fi
    return 0
}
function NetworkCapture(){
    local i 
    for i in ${pos[*]};do
        if [ ${systype[$i]} = "Linux" ];then
            $sshcom root@${ip[$i]} "tcpdump -i any -s 65535 -w /tmp/network_capture.pcap" &
        else
            $sshcom root@${ip[$i]} "tcpdump -i em0 -s 65535 -w /tmp/network_capture_em0.pcap" &
            $sshcom root@${ip[$i]} "tcpdump -i em1 -s 65535 -w /tmp/network_capture_em1.pcap" &
            $sshcom root@${ip[$i]} "tcpdump -i em2 -s 65535 -w /tmp/network_capture_em2.pcap" &
        fi
    done
    zenity --info --text="$stopcapture"
    for i in ${pos[*]};do
        $sshcom root@${ip[$i]} killall tcpdump
    done
    for i in `ps ax|grep ssh|grep tcpdump|awk '{print ($1)}'`;do
        kill -9 $i
    done
}
function CheckPartitionFreeBSD(){
    local i
    local s
    for i in `$sshcom root@${ip[$1]} "ls /dev/ada? /dev/da?"`;do
        if [ `echo $2|grep -Ec $i` -eq 1 ] && [ $($sshcom root@${ip[$1]} "gpart show -p $i"|grep -Ec $(echo $2|awk 'BEGIN {FS="/"};{print $NF}')) -eq 1 ];then
            echo $2
            return 0
        elif [ `echo $2|grep -Ec $i` -eq 1 ];then
            for s in $($sshcom root@${ip[$1]} "gpart show -p $i"|grep -v "$(echo $i|awk 'BEGIN {FS="/"};{print $NF}') "|grep -v "free "|grep -v "^ *$"|awk '{print $3}');do
                if [ $($sshcom root@${ip[$1]} "gpart show -p $s"|grep -Ec $(echo $2|awk 'BEGIN {FS="/"};{print $NF}')) -eq 1 ];then
                    echo /dev/$s
                    return 0
                fi
            done
        fi
    done
    echo $2
    return 0
}
function CheckStorageDevice(){
    local root_device
    local cfg_device
    local root_disk
    local devices
    local device
    local test
    local i
    root_device=`$sshcom root@${ip[$1]} "df"|grep -v rootfs|awk '{if($NF=="/") print($1)}'`
    if [ ${systype[$1]} = "Linux" ];then
        devices=`$sshcom root@${ip[$1]} "fdisk -l"|grep dev|grep bytes|awk '{print ($2)}'|cut -f1 -d:`
    else
        devices=`$sshcom root@${ip[$1]} "ls -1 /dev/ada? /dev/da?"`
    fi
    for i in $devices;do
        echo $root_device|grep $i
        if [ $? -eq 0 ];then
            root_disk=$i
            break
        fi
    done
    echo $2|grep $root_disk
    if [ $? -ne 0 ];then
        return 0
    fi
    if [ ${systype[$1]} = "Linux" ];then
        device=$2
        cfg_device="none"
    else
        device=$(CheckPartitionFreeBSD $1 $2)
        ssh root@${ip[$1]} "mount /cfg"
        cfg_device=`$sshcom root@${ip[$1]} "df" |grep -v rootfs|awk '{if($NF=="/cfg") print($1)}'`
        if [ $? -ne 0 ] || [ -z $cfg_device ];then
            cfg_device="none"
        else
            cfg_device=$(CheckPartitionFreeBSD $1 $cfg_device)
            root_device=$(CheckPartitionFreeBSD $1 $root_device)
        fi
        ssh root@${ip[$1]} "umount /cfg"
    fi
    if [ $cfg_device = $device ] || [ $root_device = $device ];then
        return 1
    fi
    for i in `$sshcom root@${ip[$1]} "ls $root_disk*"`;do
        if [ ${systype[$1]} = "Linux" ];then
            test=$i
        else
            test=$(CheckPartitionFreeBSD $1 $i)
        fi
        if [ $test = $device ];then
            return 1
        elif [ $test = $root_device ];then
            return 0
        fi
    done
}
function RemoveScrambling(){
    local device
    local offset
    local partition
    local autodevice
    local root_partition
    local cfg_partition
    local devices
    local num_char
    local flag
    local flag2
    local test
    local count
    local i
    local s
    for i in ${pos[*]};do
        flag=0
        if [ `echo $i%2|bc` -eq 0 ];then
            autodevice=`$sshcom root@${ip[$i]} "grep AutoDetectDevices ${fc[$i]}"|grep -v "^ *;"|cut -f2 -d"="|awk '{print ($1)}'`    
            if [ $? -ne 0 ] || [ $autodevice = "FALSE" ];then
                device=`$sshcom root@${ip[$i]} "grep CacheDevice ${fc[$i]}"|grep -v "^ *;"|cut -f2 -d=|awk '{print ($1)}'`
                if [ -z $device ];then
                    device="/dev/sdb"
                fi
                offset=`$sshcom root@${ip[$i]} "grep CacheOffsetMB ${fc[$i]}"|grep -v "^ *;"|cut -f2 -d=|awk '{print ($1)}'`
                if [ -z $offset ];then
                    offset=1024
                fi
                CheckStorageDevice $i $device
                flag=$?
            else
                device=`$sshcom root@${ip[$i]} "grep 'Cache Device' /tmp/dynamic_database.config"|awk '{print ($3)}'`
                offset=`$sshcom root@${ip[$i]} "grep 'Cache Offset' /tmp/dynamic_database.config"|awk '{print ($3)}'`
            fi    
        else
            autodevice=`$sshcom root@${ip[$i]} "grep DynamicCacheConfiguration ${fc[$i]}"|grep -v "^ *;"|cut -f2 -d"="|awk '{print ($1)}'`
            if [ $? -ne 0 ] || [ $autodevice = "FALSE" ];then
                device=`$sshcom root@${ip[$i]} "grep CacheDevice ${fc[$i]}"|grep -v "^ *;"|cut -f2 -d=|awk '{print ($1)}'|cut -f2 -d,`
                offset=`$sshcom root@${ip[$i]} "grep CacheDevice ${fc[$i]}"|grep -v "^ *;"|cut -f2 -d=|awk '{print ($1)}'|cut -f1 -d,`
                CheckStorageDevice $i $device
                flag=$?
            else
                device=`$sshcom root@${ip[$i]} "grep 'Cache Device' /tmp/dynamic_database.config"|awk '{print ($2)}'|cut -f2 -d"["|tr -d "]"`
                offset=`$sshcom root@${ip[$i]} "grep 'Cache Device' /tmp/dynamic_database.config"|awk '{print ($3)}'|cut -f2 -d"["|tr -d "]"`
                offset=`echo "$offset/1024/1024"|bc`
            fi
        fi
        if [ $flag -eq 0 ] && [ -n $device ];then
            RemoveDD ${systype[$i]} $i $tam_scrambling $offset $device
        fi
    done
    return 0
}

function GetDatabase(){
    local root_device
    local root_disk
    local devices
    local op
    local device
    local offset
    local dir
    local file
    local size
    local norootdevice
    local count
    local i
    if [ $commandline -eq 0 ];then
        DatabaseVarUpdate $*
        for s in $*;do
            op=$((for i in `seq 1 ${ndatabases[$s]}`;do
                    echo $i
                    echo "${bd_device[$s]}"|cut -f$i -d"|"
                    echo "${bd_offset[$s]}"|cut -f$i -d"|"
                done
                echo 99
                echo "$mdevexit"
                echo " "
            )|
            zenity --list --title="$mdevtitulo" --column="id" --column="$mdevcol1" --column="$mdevcol2" --hide-column=1)
            if [ -z $op ] || [ $op -eq 99 ];then
                return 100
            fi
            device=`echo ${bd_device[$s]}|cut -f$op -d"|"`
            offset=`echo ${bd_offset[$s]}|cut -f$op -d"|"`
            dir=`zenity --file-selection --directory --title="$sel_des"`
            if [ -z $dir ];then
                return 100
            fi
            echo $dir|grep " "
            if [ $? -eq 0 ];then
                $errormesg"$error_space_path"
                return 100
            fi
            file=`zenity --entry --text="$entry_file"`
            if [ -z $file ];then
                return 100
            fi
            echo $file|grep " "
            if [ $? -eq 0 ];then
                $errormesg"$error_space_path"
                return 1
            fi
            file=$dir/$file
            if [ -f $file ];then
                $errormesg"$error_file_exists"
                return 100
            fi
            size=`zenity --entry --text="$entry_size" --entry-text="$tam"`
            #in this case use if (nothing) else (exit) for prevent no numeric values
            if [ $size -gt 0 ];then
                echo
            else
                return 100
            fi
            GetDD ${systype[$s]} nozip $s $size $offset $device $file
        done
    else
        DatabaseVarUpdate $1
        root_device=`$sshcom root@${ip[$1]} "df"|grep -v rootfs|awk '{if($NF=="/") print($1)}'`
        if [ ${systype[$1]} = "Linux" ];then
            devices=`$sshcom root@${ip[$1]} "fdisk -l"|grep dev|grep bytes|awk '{print ($2)}'|cut -f1 -d:`
        else
            devices=`$sshcom root@${ip[$1]} "ls -1 /dev/ada? /dev/da?"`
        fi
        for i in $devices;do
            echo $root_device|grep $i
            if [ $? -eq 0 ];then
                root_disk=$i
                break
            fi
        done
        if [ $2 = "root" ];then
            for i in `seq 1 ${ndatabases[$1]}`;do
                device=`echo ${bd_device[$1]}|cut -f$i -d"|"`
                echo $device|grep $root_disk
                if [ $? -eq 0 ];then
                    offset=`echo ${bd_offset[$1]}|cut -f$i -d"|"`
                    break
                fi
            done
            size=$3
            file=$4
        elif [ $2 = "noroot" ];then
            count=0
            for i in $devices;do
                echo $root_device|grep $i
                if [ $? -ne 0 ];then
                    fdisk $i
                    if [ $? -eq 0 ];then
                        count=`echo "$count+1"|bc`
                        if [ $count -eq $3 ];then
                            norootdevice=$i
                            break
                        fi
                    fi
                fi
            done
            count=0
            for i in `seq 0 ${ndatabases[$1]}`;do
                if [ `echo ${bd_device[$1]|cut -f$i -d"|"}` = $norootdevice ];then
                    count=`echo "$count+1"|bc`
                    if [ $count -eq $4 ];then
                        device=`echo ${bd_device[$1]}|cut -f$i -d"|"`
                        offset=`echo ${bd_offset[$1]}|cut -f$i -d"|"`
                        break
                    fi
                fi
            done
            size=$5
            file=$6
        fi
        GetDD ${systype[$1]} nozip $1 $size $offset $device $file
    fi
    return 0
}
function RemoveSpecDataBase(){
    local count
    local root_device
    local root_disk
    local devices
    local op
    local device
    local offset
    local norootdevice
    local i
    local s
    checkremovedd=0
    if [ $commandline -eq 0 ];then
        DatabaseVarUpdate $*
        for s in $*;do
            op=$((for i in `seq 1 ${ndatabases[$s]}`;do
                    echo $i
                    echo $i
                    echo "${bd_device[$s]}"|cut -f$i -d"|"
                    echo "${bd_offset[$s]}"|cut -f$i -d"|"
                  done
                  echo 99
                  echo 99
                  echo "$mdevexit"
                  echo " "
                )|
                zenity --list --title="$mdevtitulo" --column="check" --column="id" --column="$mdevcol1" --column="$mdevcol2" --hide-column=2 --checklist --multiple)
            if [ -z $op ] || [ $op -eq 99 ];then
                continue
            fi
            for i in `echo "$op"|tr '|' ' '`;do
                if [ $i -eq 99 ];then
                    continue
                fi
                device=`echo ${bd_device[$s]}|cut -f$i -d"|"`
                offset=`echo ${bd_offset[$s]}|cut -f$i -d"|"`
                RemoveDD ${systype[$s]} $s 1 $offset $device
            done
        done
    else
        DatabaseVarUpdate $1
        root_device=`$sshcom root@${ip[$1]} "df"|grep -v rootfs|awk '{if($NF=="/") print($1)}'`
        if [ ${systype[$1]} = "Linux" ];then
            devices=`$sshcom root@${ip[$1]} "fdisk -l"|grep dev|grep bytes|awk '{print ($2)}'|cut -f1 -d:`
        else
            devices=`$sshcom root@${ip[$1]} "ls -1 /dev/ada? /dev/da?"`
        fi
            for i in $devices;do
            echo $root_device|grep $i
            if [ $? -eq 0 ];then
                root_disk=$i
                break
            fi
        done
        if [ $2 = "root" ];then
            for i in `seq 1 ${ndatabases[$1]}`;do
            device=`echo ${bd_device[$1]}|cut -f$i -d"|"`
                echo $device|grep $root_disk
                if [ $? -eq 0 ];then
                    op=$i
                    break
                fi
            done
            file=$3
        elif [ $2 = "noroot" ];then
            count=0
            for i in $devices;do
                echo $root_device|grep $i
                if [ $? -ne 0 ];then
                    fdisk $i
                    if [ $? -eq 0 ];then
                        count=`echo "$count+1"|bc`
                        if [ $count -eq $3 ];then
                            norootdevice=$i
                            break
                        fi
                    fi
                fi
            done
            count=0
            for i in `seq 0 ${ndatabases[$1]}`;do
                if [ `echo ${bd_device[$1]}|cut -f$i -d"|"` = $norootdevice ];then
                    count=`echo "$count+1"|bc`
                    if [ $count -eq $4 ];then
                        op=$i
                        break
                    fi
                fi
            done
        fi
        device=`echo ${bd_device[$1]}|cut -f$op -d"|"`
        offset=`echo ${bd_offset[$1]}|cut -f$op -d"|"`
        RemoveDD ${systype[$1]} $1 128 $offset $device
    fi
    if [ $checkremovedd -ne 0 ];then
        $errormesg"$error_removedd"
        return 100
    fi
    return 0
}
function PutDatabase(){
    local count
    local root_device
    local root_disk
    local devices
    local op
    local device
    local offset
    local file
    local norootdevice
    local i
    local s
    if [ $commandline -eq 0 ];then
        DatabaseVarUpdate $*
        for s in $*;do
            op=$((for i in `seq 1 ${ndatabases[$s]}`;do
                    echo 1
                    echo $i
                    echo "${bd_device[$s]}"|cut -f$i -d"|"
                    echo "${bd_offset[$s]}"|cut -f$i -d"|"
                done
                echo 1
                echo 99
                echo "$mdevexit"
                echo " "
               )|
               zenity --list --title="$mdevtitulo" --column="check" --column="id" --column="$mdevcol1" --column="$mdevcol2" --checklist --multiple --hide-column=2 --separator=" ")
            if [ -z $op ];then
                return 1
            fi
            file=`zenity --file-selection --title="$sel_database"`
            if [ -z $file ];then
                return 1
            fi
            echo $file|grep " "
            if [ $? -eq 0 ];then
                $errormesg"$error_space_path"
                return 1
            fi
            for i in $op;do
                if [ $i -ne 99 ];then
	            device=`echo ${bd_device[$s]}|cut -f$i -d"|"`
                    offset=`echo ${bd_offset[$s]}|cut -f$i -d"|"`
                    PutDD ${systype[$s]} nozip $s $offset $file $device
                fi
            done
        done
    else
        DatabaseVarUpdate $1
        root_device=`$sshcom root@${ip[$1]} "df"|grep -v rootfs|awk '{if($NF=="/") print($1)}'`
        if [ ${systype[$1]} = "Linux" ];then
            devices=`$sshcom root@${ip[$1]} "fdisk -l"|grep dev|grep bytes|awk '{print ($2)}'|cut -f1 -d:`
        else
            devices=`$sshcom root@${ip[$1]} "ls -1 /dev/ada? /dev/da?"`
        fi
        for i in $devices;do
            echo $root_device|grep $i
            if [ $? -eq 0 ];then
                root_disk=$i
                break
            fi
        done
        if [ $2 = "root" ];then
            for i in `seq 1 ${ndatabases[$1]}`;do
                device=`echo ${bd_device[$1]}|cut -f$i -d"|"`
                echo $device|grep $root_disk
                if [ $? -eq 0 ];then
                    offset=`echo ${bd_offset[$1]}|cut -f$i -d"|"`
                    break
                fi
            done
            file=$3
        elif [ $2 = "noroot" ];then
            count=0
            for i in $devices;do
                echo $root_device|grep $i
                if [ $? -ne 0 ];then
                    fdisk $i
                    if [ $? -eq 0 ];then
                        count=`echo "$count+1"|bc`
                        if [ $count -eq $3 ];then
                            norootdevice=$i
                            break
                        fi
                    fi
                fi
            done
            count=0
            for i in `seq 0 ${ndatabases[$1]}`;do
                if [ `echo ${bd_device[$1]|cut -f$i -d"|"}` = $norootdevice ];then
                    count=`echo "$count+1"|bc`
                    if [ $count -eq $4 ];then
                        device=`echo ${bd_device[$1]}|cut -f$i -d"|"`
                        offset=`echo ${bd_offset[$1]}|cut -f$i -d"|"`
                        break
                    fi
                fi
            done
            file=$5
        fi
        PutDD ${systype[$1]} nozip $1 $offset $5 $device
    fi
    return 0
}


#this function control the process to remove the databases of the ECTM
function RemoveDataBase(){
    local ndd
    local progress
    local device
    local offset
    local i
    local s
    local checkremovedd
    DatabaseVarUpdate ${pos[*]}
    checkremovedd=0
    if [ $commandline -eq 0 ];then
        (
        echo "2"
        if [ $programmer -ne 0 ];then
            echo "# $pbtexto1"
            StopModules ${pos[*]}
        fi
        echo "# $pbtexto4"
        echo "3"
        echo "# $pbtexto2"
        percentage=3
        let percentageincrement=92/$n_systems
        for i in ${pos[*]};do
            for s in `seq 1 ${ndatabases[$i]}`;do
                device=`echo ${bd_device[$i]}|cut -f$s -d"|"`
                offset=`echo ${bd_offset[$i]}|cut -f$s -d"|"`
                RemoveDD ${systype[$i]} $i 1 $offset $device
                if [ $? -ne 0 ];then
                    checkremovedd=1
                fi                
            done
            let percentage=$percentage+$percentageincrement
            echo $percentage
        done
        ndd=`ps ax|grep ssh|grep dd|wc -l`
        if [ $programmer -ne 0 ];then
            StartModules ${pos[*]}
        fi
        if [ $checkremovedd -ne 0 ];then
            $errormesg"$error_removedd"
        fi
        echo "100"
        echo "# $pbtexto3"
        ) |
        zenity --progress --title="$pbtitulo"\
        --percentage=0    
    else
        if [ $programmer -ne 0 ];then
            StopModules ${pos[*]}
        fi
        for i in ${pos[*]};do
            for s in `seq 1 ${ndatabases[$i]}`;do
                device=`echo ${bd_device[$i]}|cut -f$s -d"|"`
                offset=`echo ${bd_offset[$i]}|cut -f$s -d"|"`
                RemoveDD ${systype[$i]} $i 1 $offset $device
                 if [ $? -ne 0 ];then
                    checkremovedd=1
                fi
            done
        done
        ndd=`ps ax|grep ssh|grep dd|wc -l`
        while [ $ndd -ne 0 ];do
            ndd=`ps ax|grep ssh|grep dd|wc -l`
        done
        sleep 4
        if [ $programmer -ne 0 ];then
            StartModules ${pos[*]}
        fi
        if [ $checkremovedd -ne 0 ];then
            $errormesg"$error_removedd"
            return 100
        fi
    fi
    return 0
}
#this funciton get the modules and DATACORE of a ECTM and store in the correct format for the programmer
function GetProgrammerFiles(){
    local fecha
    local mod
    local i
    local s
    fecha=`date +%d_%m_%Y.%H_%M`
    mkdir /tmp/Programmerfiles$fecha
    cd /tmp/Programmerfiles$fecha
    mkdir RELEASE
    $scprcom root@${ip[0]}:$data .
    for i in ${pos[*]};do
        for s in `$sshcom root@${ip[$i]} "ls $progdir/*/*${sis_t[$i]}"`;do
            mod=`echo $s|awk 'BEGIN {FS="/"};{print $(NF-1)}'`
            mkdir RELEASE/$mod
            $scpcom root@${ip[$i]}:$s RELEASE/$mod 
        done
    done
    tar -czf Data.tar.gz DATACORE
    tar -czf Modules.tar.gz RELEASE
    cd $OLDPWD
    cp /tmp/Programmerfiles$fecha/Data.tar.gz .
    cp /tmp/Programmerfiles$fecha/Modules.tar.gz .
    rm -r -f /tmp/Programmerfiles$fecha
}
#this funciton get the log directory, the status of the modules, the version of the modules,
#the ini files of the modules, the datacore and the database of the ECTM and store all in a file.
function ReportFile(){
    local fecha
    local dirrep
    local bd
    local lug
    local resulversion
    local i
    dirlog=$PWD
    rm -f $PWD/$nomb_est 2>/dev/null
    rm -f $PWD/$nomb_ver 2>/dev/null
    fecha=`date +%Y_%m_%d.%H_%M`
    if [ $commandline -eq 1 ];then
        dirrep=$1
        if [ -f $dirrep ];then
            echo "error"
            return 100
        else
            mkdir -p $dirrep 2>/dev/null
        fi
    else
        dirrep=`zenity --file-selection --directory --title="$sel_des"`
        #echo $dirrep|grep " "
        #if [ $? -eq 0 ];then
        #    $errormesg"$error_space_path"
        #    return 1
        #fi
    fi
    mkdir $PWD/$dirbd
    if [ $? -ne 0 ] || [ -z $dirrep ];then
        dirrep=$PWD
    fi
    Version ${pos[*]}
    resulversion=$?
    if [ $resulversion -eq 2 ] && [ $commandline -ne 1 ];then
       zenity --question --text="$versionerror"
       if [ $? -ne 0 ];then
           return 1
       fi
    elif [ $resulversion -eq 1 ] && [ $commandline -ne 1 ];then
       zenity --question --text="$versionnodefined"
       if [ $? -ne 0 ];then
           return 1
       fi
    fi
    DatabaseVarUpdate ${pos[*]}
        GetLogs ${pos[*]}
    for i in ${pos[*]};do
        $sshcom root@${ip[$i]} "tar czf - $progdir" > GR.${sist[$i]^^}.$fecha.tar.gz
        mkdir $PWD/$dirbd/${sist[$i]^^}
        bd=`echo ${bd_device[$i]}|cut -f1 -d"|"`
        lug=`echo ${bd_offset[$i]}|cut -f1 -d"|"`
        GetDD ${systype[$i]} $i $tam $lug $bd $PWD/$dirbd/${sist[$i]^^}/bd.gz
    done
    if [ $sim_folder != "none" ];then
        mkdir simulators_$fecha
        cp -r $sim_folder/* simulators_$fecha
    fi
    tar cf $nomb_rep.$fecha.tar ${log[0]} ${log[1]} ${log[2]} ${log[3]} GR.${sist[0]^^}.$fecha.tar.gz GR.${sist[1]^^}.$fecha.tar.gz GR.${sist[2]^^}.$fecha.tar.gz GR.${sist[3]^^}.$fecha.tar.gz $nomb_ver $nomb_est $dirbd simulators_$fecha
    mv $nomb_rep.$fecha.tar "$dirrep"
    rm -r -f ${log[0]} ${log[1]} ${log[2]} ${log[3]} $nomb_ver $nomb_est $dirbd GR.${sist[0]^^}.$fecha.tar.gz GR.${sist[1]^^}.$fecha.tar.gz GR.${sist[2]^^}.$fecha.tar.gz GR.${sist[3]^^}.$fecha.tar.gz simulators_$fecha
    Log text "report file \"$nomb_rep.$fecha.tar\" generated in \"$dirrep\""
    return 0
}
#this function get the ini files of a main ECTM
function GetConfiguration(){
    local mod
    local date
    local i
    local s
    local t
    local filename
    local file
    local resul
    filename=`zenity --entry --text="$entry_file_compress"`
    if [ $? -ne 0 ] || [ -f "$filename" ];then
        $errormesg"$error_filesexists"
        return 12
    fi
    for i in ${pos[*]};do
        for s in `$sshcom root@${ip[$i]} "ls $progdir/*/*${sis_t[$i]}"`;do
            $sshcom root@${ip[$i]} ls $s*.ini >/dev/null 2>/dev/null
            if [ $? -eq 0 ];then
                mod=`echo $s|awk 'BEGIN {FS="/"};{print $(NF-1)}'`
                mkdir -p ${sist[$i]^^}/$mod
                for t in `$sshcom root@${ip[$i]} "ls $s*.ini"`;do
                   $scpcom root@${ip[$i]}:$t ${sist[$i]^^}/$mod
                   file=`echo $t|awk 'BEGIN {FS="/"};{print $NF}'`
                   CompareFile ${sist[$i]^^}/$mod/$file $t $i
                   resul=$?
                   if [ $resul -ne 0 ];then
                       $errormesg"$error_inifiles"
                       return 1
                   fi
                done
            fi
        done
    done
    tar czf "$filename" A32 B32 A64 B64
    rm -r -f A32 B32 A64 B64
}
function PutConfiguration(){
    local mod
    local i
    local s
    local device
    local configurationfile
    local configurationfilename
    local fich
    Rewritable
    configurationfile=`zenity --file-selection --title="$select_config_file"`
    if [ $? -eq 0 ];then
        configurationfilename=`echo $configurationfile|awk 'BEGIN {FS="/"};{print $NF}'`
        tar xzf $configurationfile -C .
        if [ $? -ne 0 ];then
            $errormesg"$error_configuration"
            return 12
        fi
        for i in ${pos[*]};do
            cd ${sist[$i]^^}
            tar -czf "$configurationfilename" *
            $sshcom root@${ip[$i]} "mkdir /GR.Main" >/dev/null 2>/dev/null
            $sshcom root@${ip[$i]} "rm -f /GR.Main/$configurationfilename" >/dev/null 2>/dev/null
            $scpcom "$configurationfilename" root@${ip[$i]}:/GR.Main
            CompareFile $configurationfilename /GR.Main/$configurationfilename $i
            if [ $? -ne 0 ];then
                $errormesg"$error_inifiles"
                return 12
            fi
            cd ..
        done
        rm -r -f A32 B32 A64 B64 
    else
        $errormesg"$error_configuration"
    fi
}
#this function put the ini files obtained with the function "GetConfiguration" in a backup ECTM
function ConfigureBackup(){
    local mod
    local i
    local s
    local device
    local file
    local configurationfile
    local resul
    configurationfile=`(for i in $($sshcom root@${ip[${pos[0]}]} "ls /GR.Main");do
                            resul=0
                            for s in ${pos[*]};do
                                $sshcom root@${ip[$s]} "ls /GR.Main/$i" >/dev/null 2>/dev/null
                                if [ $? -ne 0 ];then
                                    resul=1
                                fi
                            done
                            if [ $resul -eq 0 ];then
                                echo $i
                            fi
                        done
                        )| zenity --list --title="$mconfiletitle" --column="$mconfilecol"`
    if [ $? -ne 0 ];then
       return 1
    fi
    Rewritable
    StopModules ${pos[*]}
    for i in ${pos[*]};do
        $sshcom root@${ip[$i]} "rm -f $progdir/IS2/*.ini"
        $sshcom root@${ip[$i]} "rm -f $progdir/MUX/*${sis_t[$i]}.*"
        $sshcom root@${ip[$i]} "echo '' > $progdir/MUX/mux"
        $sshcom root@${ip[$i]} "mkdir /tmp/GR.Configuration"
        $sshcom root@${ip[$i]} "tar xzf /GR.Main/$configurationfile -C /tmp/GR.Configuration"
        $sshcom root@${ip[$i]} "cp -r  /tmp/GR.Configuration/* $progdir"
        $sshcom root@${ip[$i]} "ls $progdir/MUX/*.ini" >/dev/null 2>/dev/null
        if [ $? -eq 0 ];then
            for s in `$sshcom root@${ip[$i]} "ls $progdir/MUX/*.ini"`;do
                file=`echo ${s%.ini}`
                $sshcom root@${ip[$i]} "cp $progdir/MUX/mux.${sis_t[$i]} $file"
                if [ `echo $i%2|bc` -eq 0 ];then
                    $sshcom root@${ip[$i]} "echo 'runforever.32 $file /dev/null &' >> $progdir/MUX/mux"
                else
                    $sshcom root@${ip[$i]} "echo 'runforever.64 $file /dev/null &' >> $progdir/MUX/mux"
                fi
            done
        fi
    done
    GenMd5
}
function BackupModules(){
    local i
    local s
    DeleteLogs
    for i in ${pos[*]};do
        $sshcom root@${ip[$i]} "mkdir /tmp/backupmodules" 2>/dev/null
        $sshcom root@${ip[$i]} "rm -r -f /tmp/backupmodules"/* 2>/dev/null
        for s in `$sshcom root@${ip[$i]} "ls -d $progdir/*"|grep -v $data`;do
            $sshcom root@${ip[$i]} "cp -r $s /tmp/backupmodules"
        done
    done
    check_io=1
}
function RestoreModules(){
    local i
    local s
    Rewritable
    Log text "failure in module IO restoring previous status"
    for i in ${pos[*]};do
        for s in `$sshcom root@${ip[$i]} "ls -d /tmp/backupmodules/*"`;do
            $sshcom root@${ip[$i]} "cp -r $s $progdir"
        done
    done
    $errormesg"$error_ini"
    ReadOnly
}
function CheckMd5Vars(){
    local fich
    local md5bdfichact
    local md5fcatc
    fich="/tmp/dynamic_database.config"
    if [ ${systype[$1]} = "Linux" ];then
        md5bdfichact=`$sshcom root@${ip[$1]} "md5sum $fich"|awk '{print ($1)}'`
        if [ $? -ne 0 ];then
            md5bdfichact=none
        fi
        md5fcatc=`$sshcom root@${ip[$1]} "md5sum ${fc[$i]}"|awk '{print ($1)}'`
    else
        md5bdfichact=`$sshcom root@${ip[$1]} "md5 $fich"|awk '{print ($4)}'`
        if [ $? -ne 0 ];then
            md5bdfichact=none
        fi
        md5fcatc=`$sshcom root@${ip[$1]} "md5 ${fc[$i]}"|awk '{print ($4)}'`
    fi
    echo ${md5bdfich[$1]}|grep -w $md5bdfichact >/dev/null 2>/dev/null
    if [ $? -ne 0 ];then
        Log text "the database file of ${sist[$1]} [$md5bdfichact] is different to the previous [${md5bdfich[$1]}] updating the database positions"
        return 1
    fi
    echo ${md5fc[$1]}|grep -w $md5fcatc >/dev/null 2>/dev/null
    if [ $? -ne 0 ];then
        Log text "the GR configuration file of ${sist[$1]} [$md5fcatc] is different to the previous [${md5fc[$1]}] updating the database positions"
        return 1
    fi
    Log text "the configuration of ${sist[$1]} is the same of the previous using previous database positions"
    return 0
}


function ForceRollback(){
    local i
    local s
    local database
    local bok
    zenity --question --text="$question_forcedatabase"
    if [ $? -eq 0 ];then
        if [ $n_systems -eq 2 ];then
            database=$((for i in `$sshcom root@${ip[0]} ls /tmp/BCK32/*.bck|sort|awk 'BEGIN {FS="/"};{print $NF}'`;do
                            $sshcom root@${ip[1]} ls /tmp/BCK64/$i >/dev/null 2>/dev/null
                            if [ $? -eq 0 ];then
                                echo $i
                            fi
                        done
                     )|zenity --list --title="$mfrollbacktitle" --column="$mfrollbacktitle")
            if [ $? -ne 0 ] || [ -z $database ];then
                return 1
            fi
        elif [ $n_systems -eq 4 ];then
            database=$((for i in `echo $($sshcom root@${ip[0]} ls /tmp/BCK32/*.bck;$sshcom root@${ip[2]} ls /tmp/BCK32/*.bck)|tr " " "\n"|sort -u|awk 'BEGIN {FS="/"};{print $NF}'`;do
                            bok=0
                            $sshcom root@${ip[1]} ls /tmp/BCK64/$i >/dev/null 2>/dev/null
                            if [ $? -eq 0 ];then
                                bok=1
                            fi
                            $sshcom root@${ip[3]} ls /tmp/BCK64/$i >/dev/null 2>/dev/null
                            if [ $? -eq 0 ];then
                                bok=1
                            fi
                            if [ $bok -eq 1 ];then
                                echo $i
                            fi
                        done
                     )|zenity --list --title="$mfrollbacktitle" --column="$mfrollbacktitle")
            if [ $? -ne 0 ] || [ -z $database ];then
                return 1
            fi
        else
            $errormesg"$error_nsys" 
            return 1
        fi
        for i in ${pos[*]};do
            if [ `echo "$i%2"|bc` -eq 0 ];then
                $sshcom root@${ip[$i]} "touch /tmp/hot.report.enabled"
            fi
            $sshcom root@${ip[$i]} "echo $database|cut -f1 -d. >/tmp/rollback"
        done
        sleep 8
        for i in ${pos[*]};do
            if [ `echo "$i%2"|bc` -eq 0 ];then
                $sshcom root@${ip[$i]} "rm /tmp/hot.report.enabled"
            fi
        done
    fi
}

function UpdateMd5Vars(){
    local fich
    fich="/tmp/dynamic_database.config"
    if [ ${systype[$1]} = "Linux" ];then
        md5bdfich[$1]=`$sshcom root@${ip[$1]} "md5sum $fich"|awk '{print ($1)}'`
        if [ $? -ne 0 ];then
            md5bdfich[$1]="none"
        fi
        md5fc[$1]=`$sshcom root@${ip[$1]} "md5sum ${fc[$1]}"|awk '{print ($1)}'`
    else
        md5bdfich[$1]=`$sshcom root@${ip[$1]} "md5 $fich"|awk '{print ($4)}'`
        if [ $? -ne 0 ];then
            md5bdfich[$1]=none
        fi
        md5fc[$1]=`$sshcom root@${ip[$1]} "md5 ${fc[$1]}"|awk '{print ($4)}'`
    fi
}
function DatabaseVarUpdate(){
    local i
    local s
    local autodevice
    local lug
    local bd
    local bdi
    local num
    local oldIFS
    for i in $*;do
        CheckMd5Vars $i
        if [ $? -ne 0 ];then
            bd_device[$i]=""
            bd_offset[$i]=""
            if [ `echo "$i%2"|bc` -eq 0 ];then
                autodevice=`$sshcom root@${ip[$i]} "grep AutoDetectDevices ${fc[$i]}"|grep -v "^ *;"|cut -f2 -d"="|awk '{print ($1)}'`
                if [ $? -ne 0 ] || [ $autodevice = "FALSE" ];then
                    coment=`$sshcom root@${ip[$i]} "grep CompleteDeviceList ${fc[$i]}"|grep -v "^ *;"|wc -l`
                    if [ $coment -ne 0 ];then
                        num=`$sshcom root@${ip[$i]} "grep CompleteDeviceList ${fc[$i]}"|grep -v "^ *;"|cut -f2 -d=|awk 'BEGIN {FS=","};{print NF}'`
                    else
                        num=0
                    fi
                    for s in `seq 0 $num`;do
                        if [ $s -eq 0 ];then
                            bd=`$sshcom root@${ip[$i]} "grep SystemTSRPartition ${fc[$i]}"|grep -v "^ *;"|cut -f2 -d=|awk '{print ($1)}'`
                            CheckStorageDevice $i $bd
                            if [ $? -eq 0 ];then
                                bd_device[$i]="${bd_device[$i]} $bd"
                                bd_offset[$i]="${bd_offset[$i]} 0"
                            fi
                        else
                            bdi=`$sshcom root@${ip[$i]} "grep CompleteDeviceList ${fc[$i]}"|grep -v "^ *;"|cut -f2 -d=|cut -f$s -d,`
                            bd=`echo $bdi|cut -f1 -d@|awk '{print ($1)}'`
                            lug=`echo $bdi|cut -f2 -d@|awk '{print ($1)}'`
                            CheckStorageDevice $i $bd
                            if [ $? -eq 0 ];then
                                bd_device[$i]="${bd_device[$i]} $bd"
                                bd_offset[$i]="${bd_offset[$i]} $lug"
                            fi
                        fi
                    done
                elif [ $autodevice = "TRUE" ];then
                    coment=`$sshcom root@${ip[$i]} "grep 'TSR Devices' /tmp/dynamic_database.config"|grep -v "^ *;"|wc -l`
                    if [ $coment -ne 0 ];then
                        num=`$sshcom root@${ip[$i]} "grep 'TSR Devices' /tmp/dynamic_database.config"|grep -v "^ *;"|cut -f1 -d"("|cut -f2 -d":"|awk '{print ($1)}'|awk 'BEGIN {FS=","};{print NF}'`
                    else
                        num=0
                    fi
                    for s in `seq 0 $num`;do
                        if [ $s -eq 0 ];then
                            bd=`$sshcom root@${ip[$i]} "grep 'TSR Partition' /tmp/dynamic_database.config"|grep -v "^ *;"|cut -f2 -d":"|awk '{print ($1)}'`
                            if [ $? -eq 0 ];then
                                bd_device[$i]="${bd_device[$i]} $bd"
                                bd_offset[$i]="${bd_offset[$i]} 0"
                            fi
                        else
                            bdi=`$sshcom root@${ip[$i]} "grep 'TSR Devices' /tmp/dynamic_database.config"|grep -v "^ *;"|cut -f2 -d":"|awk '{print ($1)}'|cut -f$s -d,`
                            bd=`echo $bdi|cut -f1 -d@|awk '{print ($1)}'`
                            lug=`echo $bdi|cut -f2 -d@|awk '{print ($1)}'`
                            if [ $? -eq 0 ];then
                                bd_device[$i]="${bd_device[$i]} $bd"
                                bd_offset[$i]="${bd_offset[$i]} $lug"
                            fi
                        fi
                    done
                fi
            else
                autodevice=`$sshcom root@${ip[$i]} "grep DynamicDatabaseConfiguration ${fc[$i]}"|grep -v "^ *;"|cut -f2 -d"="|awk '{print ($1)}'`
                if [ $? -ne 0 ] || [ $autodevice = "FALSE" ];then
                    num=`$sshcom root@${ip[$i]} "grep -i Database ${fc[$i]}"|grep -v Section|grep -v Dynamic|grep -v Back|grep -v "^ *;"|wc -l`
                    for s in `seq 1 $num`;do
                        lug=`$sshcom root@${ip[$i]} "grep -i Database$s ${fc[$i]}"|grep -v "^ *;"|cut -f2 -d=|cut -f1 -d,|awk '{print ($1)}'`
                        bd=`$sshcom root@${ip[$i]} "grep -i Database$s ${fc[$i]}"|grep -v "^ *;"|cut -f2 -d=|cut -f2 -d,|awk '{print ($1)}'`
                        CheckStorageDevice $i $bd
                        if [ $? -eq 0 ];then
                            bd_device[$i]="${bd_device[$i]} $bd"
                            bd_offset[$i]="${bd_offset[$i]} $lug"
                        fi
                    done
                elif [ $autodevice = "TRUE" ];then
                    oldIFS=$IFS
                    IFS=$'\n'
                    for s in `(IFS=$oldIFS
                               $sshcom root@${ip[$i]} "grep DB /tmp/dynamic_database.config"|grep -v "^ *;"
                               IFS=$'\n')`;do
                        IFS=$oldIFS
                        bd=`echo $s|awk '{print ($2)}'|cut -f2 -d"["|tr -d "]"`
                        lug=`echo $s|awk '{print ($3)}'|cut -f2 -d"["|tr -d "]"`
                        lug=`echo "$lug/1024/1024"|bc`
                        if [ $? -eq 0 ];then
                            bd_device[$i]="${bd_device[$i]} $bd"
                            bd_offset[$i]="${bd_offset[$i]} $lug"
                        fi
                        IFS=$'\n'
                    done
                    IFS=$oldIFS
                fi
            fi
            UpdateMd5Vars $i
            ndatabases[$i]=`echo "${bd_device[$i]}"|awk '{print NF}'`
            bd_device[$i]=`echo "${bd_device[$i]}"|awk '{for (i=1;i<NF;i++) printf $i"|";printf $NF}'`
            bd_offset[$i]=`echo "${bd_offset[$i]}"|awk '{for (i=1;i<NF;i++) printf $i"|";printf $NF}'`
        fi
        Log Database $i
    done    
}
function SelMultiSys(){
    case $1 in
        1)echo ${pos[*]};;
        2)SelMultiSys2;;
        4)SelMultiSys4;;
    esac
}

#this function show a menu to select a system with multiple selections when the systems are 2
function SelMultiSys2(){
    local op
    local sys
    local num
    local i
    dirlog=0
    op=`zenity --list --title="$mstitulo" --height=210\
          --column="check" --column="$mscol" --column="$mscol"\
          --checklist --multiple\
          1 0 "$msopcion1"\
          1 1 "$msopcion2"\
          --hide-column=2 --separator=" "`
    date=`date +%d_%m_%Y.%H_%M`
    echo $op
}
#this function show a menu to select a system with multiple selections when the systems are 4
function SelMultiSys4(){
    local op
    local sys
    local num
    local i
    op=`zenity --list --title="$mstitulo" --height=210\
          --column="check" --column="$mscol" --column="$mscol"\
          --checklist --multiple\
          1 0 "A32"\
          1 1 "A64"\
          1 2 "B32"\
          1 3 "B64"\
          --hide-column=2 --separator=" "`
    date=`date +%d_%m_%Y.%H_%M`
    echo $op
}
function SelSys(){
   local op
   case $1 in
       1)SelSys1
         op=${pos[*]};;
       2)SelSys2
         op=$?;;
       4)SelSys4
         op=$?;;
   esac
   return $op
}

#this function show a menu to select a system without multiple selections when the systems are 2
function SelSys2(){
    local op
    while [ true ];do
        op=`zenity --list --title="$mstitulo" --height=210\
           --column="$mscol" --column="$mscol"\
            0 "$msopcion1"\
            1 "$msopcion2"\
            4 "$msopcion3" \
            --hide-column=1`
        if [ -z $op ] || [ $op -eq 2 ];then
            ReadOnly
            StopModules ${pos[*]}
            StartModules ${pos[*]}
            return 4
        fi
        return $op
    done
}
#this function show a menu to select a system without multiple selections when the systems are 4
function SelSys4(){
    local op
    while [ true ];do
        op=`zenity --list --title="$mstitulo" --height=210\
            --column="$mscol" --column="$mscol"\
            0 "A32"\
            1 "A64"\
            2 "B32"\
            3 "B64"\
            4 "$msopcion3" \
            --hide-column=1`
        if [ -z $op ] || [ $op -eq 4 ];then
            ReadOnly
            StopModules ${pos[*]}
            StartModules ${pos[*]}
            return 4
        fi
        return $op
    done
}
function MenuActualizar(){
    local fin
    local op
    local i
    fin=$[${#optionactualizacion[*]}-1]
    op=$((for i in `seq 0 $fin`;do
                echo $i
                echo ${optionactualizacion[$i]}
            done
            )|
            zenity --list --title="${type^^} utils version:$version" --height=220\
            --column="code" --column="$mpcol" --hide-column=1|cut -f1 -d'|')
    if [ $? -ne 0 ] || [ -z $op ];then
        op=99
    fi
    case $op in
        0)Modules;;
        1)Data;;
        2)Modules other
          if [ $? -eq 0 ];then        
              Data other
          fi;;
        3)GenMd5;;
    esac
}
function MenuIps(){
    local fin
    local op
    local i
    fin=$[${#optionips[*]}-1]
    op=$((for i in `seq 0 $fin`;do
                echo $i
                echo ${optionips[$i]}
            done
            )|
            zenity --list --title="${type^^} utils version:$version" --height=220\
            --column="code" --column="$mpcol" --hide-column=1|cut -f1 -d'|')
    if [ $? -ne 0 ] || [ -z $op ];then
        op=99
    fi
    case $op in
        0)fin=0
          while [ $fin -eq 0 ];do
              SelSys $n_systems
              op=$?
              if [ $op -ne 4 ];then 
                  ChangeIps $op
              fi
              if [ $op -eq 4 ] || [ $n_systems -eq 1 ];then
                  fin=1
              fi
          done;;
        1)fin=0
          while [ $fin -eq 0 ];do
              SelSys $n_systems
              op=$?
              if [ $op -ne 4 ];then
                  AddDelIps $op
              fi
              if [ $op -eq 4 ] || [ $n_systems -eq 1 ];then
                  fin=1
              fi
          done;;
        2)Routes;;
        3)BackupIps;;
    esac
}
function MenuFicheros(){
    local fin
    local op
    local i
    local selsystems
    fin=$[${#optionficheros[*]}-1]
    op=$((for i in `seq 0 $fin`;do
                echo $i
                echo ${optionficheros[$i]}
            done
            )|
            zenity --list --title="${type^^} utils version:$version" --height=280\
            --column="code" --column="$mpcol" --hide-column=1|cut -f1 -d'|')
    if [ $? -ne 0 ] || [ -z $op ];then
        op=99
    fi
    case $op in
        0)DeleteLogs;;
        1)DeleteTSRDATA;;
        2)dirlog=0
           selsystems=`SelMultiSys $n_systems`
           GetLogs $selsystems;;
        3)GetDatacore;;
        4)ReportFile;;
        5)GetTSRDATA;;
        6)GetProgrammerFiles;;
    esac
}
function MenuConfiguracion(){
    local fin
    local op
    local i
    fin=$[${#optionconfiguracion[*]}-1]
    op=$((for i in `seq 0 $fin`;do
                echo $i
                echo ${optionconfiguracion[$i]}
            done
            )|
            zenity --list --title="${type^^} utils version:$version" --height=250\
            --column="code" --column="$mpcol" --hide-column=1|cut -f1 -d'|')
    if [ $? -ne 0 ] || [ -z $op ];then
        op=99
    fi
    case $op in
        0)AutoConfig;;
        1)GetConfiguration;;
        2)PutConfiguration;;
        3)ConfigureBackup;;
    esac
}
function MenuBasededatos(){
    local fin
    local op
    local i
    local selsystems
    fin=$[${#optionbasededatos[*]}-1]
    op=$((for i in `seq 0 $fin`;do
                echo $i
                echo ${optionbasededatos[$i]}
            done
            )|
            zenity --list --title="${type^^} utils version:$version" --height=220\
            --column="code" --column="$mpcol" --hide-column=1|cut -f1 -d'|')
    if [ $? -ne 0 ] || [ -z $op ];then
        op=99
    fi
    case $op in
        0)zenity --question --text="$question_database"
           if [ $? -eq 0 ];then
                RemoveDataBase
           fi;;
        1)selsystems=`SelMultiSys $n_systems`
           GetDatabase $selsystems;;
        2)selsystems=`SelMultiSys $n_systems`
           PutDatabase $selsystems;;
        3)selsystems=`SelMultiSys $n_systems`
           RemoveSpecDataBase $selsystems;;
        4)ForceRollback;;
    esac
}
function MenuSistema(){
    local fin
    local op
    local i
    local selsystems
    fin=$[${#optionsistema[*]}-1]
    op=$((for i in `seq 0 $fin`;do
                echo $i
                echo ${optionsistema[$i]}
            done
            )|
            zenity --list --title="${type^^} utils version:$version" --height=220\
            --column="code" --column="$mpcol" --hide-column=1|cut -f1 -d'|')
    if [ $? -ne 0 ] || [ -z $op ];then
        op=99
    fi
    case $op in
        0)zenity --question --text="$question_format"
          if [ $? -eq 0 ];then
            selsystems=`SelMultiSys $n_systems`
            Format $selsystems
          fi;;
        1)selsystems=`SelMultiSys $n_systems`
           StopModules $selsystems;;
        2)selsystems=`SelMultiSys $n_systems`
           StartModules $selsystems;;
        3)selsystems=`SelMultiSys $n_systems`
           Reset $selsystems;;
    esac
}
#this function show the menu for utils
function MenuUtils(){
    local fin
    local op
    local i
    local selsystems
    fin=$[${#optionutils[*]}-1]
    op=$((for i in `seq 0 $fin`;do
                echo $i
                echo ${optionutils[$i]}
            done
            )|
            zenity --list --title="${type^^} utils version:$version" --height=330 --width=100\
            --column="code" --column="$mpcol" --hide-column=1|cut -f1 -d'|')
    if [ $? -ne 0 ] || [ -z $op ];then
        op=99
    fi
    case $op in
        0)MenuActualizar;;
        1)MenuSistema;;
        2)MenuConfiguracion;;
        3)MenuIps;;
        4)MenuFicheros;;
        5)MenuBasededatos;;
        6)RemoveScrambling;;
        7)rm -f $PWD/$nomb_ver 2>/dev/null
          selsystems=`SelMultiSys $n_systems`
          Version $selsystems
          zenity --text-info \
                 --title=$PWD/$nomb_ver\
                 --filename=$PWD/$nomb_ver;;
        8)SynchroDate;;
        9)NetworkCapture;;
        *)ReadOnly
          StartModules ${pos[*]}
          exit 0;;
    esac
}

#this function show the menu for programmer
function MenuProgrammer(){
    local fin
    local op
    local i
    fin=$[${#optionprogrammer[*]}-1]
    op=$((for i in `seq 0 $fin`;do
                 echo $i
                 echo ${optionprogrammer[$i]}
             done
            )|
            zenity --list --title="${type^^} Programmer version:$version" --height=370 --width=450\
            --column="code" --column="$mpcol" --hide-column=1)
    if [ -z $op ];then
        op=99
    fi
    return $op    
}

#this function call the function for the menu programmer
function SelFunctProgrammer(){
    local op
    local fin
    case $1 in
        0)GetConfiguration;;
        1)PutConfiguration;;
        2)ConfigureBackup;;
        3)Restore;;
        4)zenity --question --text="$question_database"
          if [ $? -eq 0 ];then
            zenity --question --text="$question_database2"
            if [ $? -eq 0 ];then
                  RemoveDataBase
            fi
          fi;;
        5)fin=0
          while [ $fin -eq 0 ];do
              SelSys $n_systems
              op=$?
              if [ $op -ne 4 ];then 
                  ChangeIps $op
              fi
              if [ $op -eq 4 ] || [ $n_systems -eq 1 ];then
                  fin=1
              fi
          done;;
        6)fin=0
          while [ $fin -eq 0 ];do
              SelSys $n_systems
              op=$?
              if [ $op -ne 4 ];then
                  AddDelIps $op
              fi
              if [ $op -eq 4 ] || [ $n_systems -eq 1 ];then
                  fin=1
              fi
          done;;
        7)Routes;;
        8)BackupIps;;
        9)ForceRollback;;
        *)ReadOnly
          StartModules ${pos[*]}
          exit 0;;
    esac
}
#this function ask for the password for the ECTM and store in variables the command ssh
function GetPasswd(){
    local passwd
    if [ $keys != "y" ];then
        if [ $commandline -eq 1 ];then
            exit 100
        fi
        sshpass
        if [ $? -ne 0 ];then
            $errormesg"$error_sshpass"
            exit 100    
        fi
        passwd=`zenity --entry --text="$entry_passwd ${type^^}" --hide-text`
        if [ $? -ne 0 ] || [ -z $passwd ];then
            $errormesg"$error_entrypass"
            exit 100
        fi
        readonly sshcom="sshpass -p $passwd ssh $options"
        readonly scpcom="sshpass -p $passwd scp $options"
        readonly scprcom="sshpass -p $passwd scp -r $options"
    else
        readonly sshcom="ssh $options"
        readonly scpcom="scp $options"
        readonly scprcom="scp -r $options"
    fi
}
#begin of the script
#this commad is to check if the script is binary (programmer $? != 0) or no (utils $? = 0)


if [ `echo $0|awk 'BEGIN {FS="/"};{print NF}'` -gt 2 ];then
   let nfields=`echo $0|awk 'BEGIN {FS="/"};{print NF}'`-1
   cd `echo $0|cut -f1-$nfields -d'/'`
   
fi
Conf
Log text start $0
end=0
grep function $0 >/dev/null
programmer=$?
len=`echo $LANG|cut -f1 -d"_"|awk '{print tolower($1)}'`
language $len
if [ $# -gt 0 ] && [ $1 != "test" ];then
    commandline=1
    errormesg="echo "
else
    debug="set -x"
    shift
    commandline=0
    errormesg="zenity --error --text="
fi
FichIni
Variables
GetPasswd
Ips
SynchroDate
if [ $programmer -eq 0 ];then
    if [ $# -gt 0 ] && [ $programmer -eq 0 ];then
        $debug
        $*
        exit $?
    fi
    while [ true ];do
        if [ $end -ne 0 ];then
            break
        fi
        MenuUtils
    done
else
    MenuProgrammer 
    SelFunctProgrammer $?
fi
ReadOnly
StartModules ${pos[*]}
exit 0
