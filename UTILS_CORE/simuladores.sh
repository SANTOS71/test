#!/bin/bash
#versión 0.8 (+TOC)
#esta funcion define las rutas para el archivo .tsm, los .kp2
#el nombre del ejecutable que se copiara para los nuevos
#y la ubicacionde los .ini dentro del gestor
function conf(){
	tsmf=/GR/DATACORE/TSM
	tocf=/GR/DATACORE/TOC
	kp=/GR/DATACORE/KP2
	dc=/GR/DATACORE/DC1
	ficha32=/GR/GRT/grt.a.32.ini
	fichb32=/GR/GRT/grt.b.32.ini
	ficha64=/GR/GRC/grc.a.64.ini
	fichb64=/GR/GRC/grc.b.64.ini	
	exe=qtATS
	leuexe=leu.a.64
	dir=/tmp
	puerto=8590
	puertoa32=60132
	puertoa64=60264
	puertob32=60133
	puertob64=60265
	poll_serie=1500
	poll_paralelo=999
	update=md5
}

#esta funcion saca las 8 ip's del gestor
function ips(){
	ip_a32_a=`grep ip_a32 $1|cut -f2 -d:`
	ip_a32_b=`grep ipb_a32 $1|cut -f2 -d:` 
	ip_a64_a=`grep ip_a64 $1|cut -f2 -d:` 
	ip_a64_b=`grep ipb_a64 $1|cut -f2 -d:`
	ip_b32_a=`grep ip_b32 $1|cut -f2 -d:` 
	ip_b32_b=`grep ipb_b32 $1|cut -f2 -d:`
	ip_b64_a=`grep ip_b64 $1|cut -f2 -d:` 
	ip_b64_b=`grep ipb_b64 $1|cut -f2 -d:`
	band=0
	#se utiliza un for por si alguna ip no esta definida ya que de esa manera el for no lo usa
	#y si se hiciera por declaración directa podrian aparecer comas consecutivas
	for i in $ip_a32_a $ip_a32_b $ip_b32_a $ip_b32_b $ip_a64_a $ip_a64_b $ip_b64_a $ip_b64_b;do
		if [ $band -eq 0 ];then
			ips=$i
			ipsl=$i:$puerto
			band=1
		else
			ips=$ips","$i
			ipsl=$ipsl","$i:$puerto
		fi
	done
}

#esta funcion busca una ip que permita acceder al .ini del gr del sitema
#cuando encuentra una esa ip y ese .ini seran los que se usen
function ipf(){
	band=0
	for i in $ip_a64_a $ip_a64_b $ip_b64_a $ip_b64_b $ip_a32_a $ip_a32_b $ip_b32_a $ip_b32_b;do
		ip=$i
		case $ip in
			$ip_a32_a|$ip_a32_b)fich=$ficha32;;
			$ip_b32_a|$ip_b32_b)fich=$fichb32;;
			$ip_a64_a|$ip_a64_b)fich=$ficha64;;
			$ip_b64_a|$ip_b64_b)fich=$fichb64;;
		esac
		ssh root@$ip ls $fich >/dev/null
		if [ $? -eq 0 ];then
			band=1
			break
		fi
	done
	if [ $band -eq 0 ];then
		echo "no se pudo conectar con el gestor"
		exit 1
	fi
}

#esta funcion crea los ejecutables ats y sus .ini asociados
function ats(){
	mkdir ATS
	mkdir ATS/A32 ATS/A64 ATS/B32 ATS/B64
	
	#copia archivo toc al directorio ATS
	if [ -n "$toc" ];then
	  echo $toc
	  scp root@$ip:$tocf/$toc "ATS/$toc"	  
	  cp "ATS/$toc" ATS/A32/
	  cp "ATS/$toc" ATS/A64/
	  cp "ATS/$toc" ATS/B32/
	  cp "ATS/$toc" ATS/B64/
	fi
	
	#se ejecuta para todos los operadores definidos en el .tsm
	for i in `ssh root@$ip "grep OP_ $tsmf/*.tsm"`;do
		 for s in ATS ATS/A32 ATS/A64 ATS/B32 ATS/B64;do
			case $s in
				ATS/A32)list=$ip_a32_a
						destport=$puertoa32
						protocol=0;;
				ATS/A64)list=$ip_a64_a
						destport=$puertoa64
						protocol=1;;
				ATS/B32)list=$ip_b32_a
						destport=$puertob32
						protocol=0;;
				ATS/B64)list=$ip_b64_a
						destport=$puertob64
						protocol=1;;
				*)list=$ips
				  destport=$puerto
				  protocol=2;;
			esac
			num=`echo $i|cut -f1 -d=|cut -c4-`
			cp $exe $s/ats$num
			chmod +x $s/ats$num
			echo "[DTSRP]" > $s/ats$num.ini
			echo "Polling = 999" >> $s/ats$num.ini
			ide=`ssh root@$ip "grep Identifier $fich"|awk '{print ($3)}'|head -1`
			echo "Destination = $ide" >> $s/ats$num.ini
			id=`echo $i|cut -f1 -d,|cut -f2 -d=`
			pdv=`ssh root@$ip "grep PDV $dir/PDV.$id.log"|awk '{print ($2)}'`
			echo "PDV = 0x$pdv" >> $s/ats$num.ini
			source=`echo $i|cut -f2 -d,`
			source=`echo "ibase=16; $source"|bc`
			sourceA=$source
			echo "SourceA = $source" >> $s/ats$num.ini
			source=`echo $i|cut -f3 -d,`
			source=`echo "ibase=16; $source"|bc`			
			
			if [ "$sourceA" == "$source" ];then			  
			  echo "SourceB =" >> $s/ats$num.ini
			  echo "IPListA = $list" >> $s/ats$num.ini
			  echo "IPListB =" >> $s/ats$num.ini
			  echo "DisableActivation = 1" >> $s/ats$num.ini
			else			  
			  echo "SourceB = $source" >> $s/ats$num.ini
			  echo "IPListA = $list" >> $s/ats$num.ini
			  echo "IPListB = $list" >> $s/ats$num.ini
			  echo "DisableActivation = 0" >> $s/ats$num.ini
			fi
			echo "UDPPort = $destport" >> $s/ats$num.ini
			TSM=`ssh root@$ip "ls $tsmf"|cut -f$pos -d_|cut -f1 -d.`
			TSM=`echo "ibase=16; $TSM"|bc`
			echo "TSM = $TSM" >> $s/ats$num.ini
			
			echo "SynchroPort = $port" >> $s/ats$num.ini
			echo "Protocol = $protocol" >> $s/ats$num.ini
			
			if [ -n "$toc" ];then		 
			  echo "[TOC]" >> $s/ats$num.ini
			  echo "TOCFolder = ." >> $s/ats$num.ini		 
			  echo "Source = $sourceA" >> $s/ats$num.ini
			  shortId=`echo $i|cut -f1 -d,|cut -f2 -d=`		 
			  shortId=`echo "ibase=16; $shortId"|bc`
			  echo "OperatorID = $shortId" >> $s/ats$num.ini
			fi
			port=$[$port+1]
		done
	done
}

#esta funcion copia el ejecutable para los bp's y generas los .ini asociados
function bp(){
	mkdir BP
	mkdir BP/A32 BP/A64 BP/B32 BP/B64
	num=1
	for i in `ssh root@$ip "ls $kp/*"|awk 'BEGIN {FS="/"};{print $NF}'`;do
		for s in BP BP/A32 BP/A64 BP/B32 BP/B64;do
			case $s in
				BP/A32)list=$ip_a32_a
						destport=$puertoa32
						protocol=0;;
				BP/A64)list=$ip_a64_a
						destport=$puertoa64
						protocol=1;;
				BP/B32)list=$ip_b32_a
						destport=$puertob32
						protocol=0;;
				BP/B64)list=$ip_b64_a
						destport=$puertob64
						protocol=1;;
				*)list=$ips
				  destport=$puerto
				  protocol=2;;
			esac
			cp $exe $s/bp$num
			chmod +x $s/bp$num
			echo "[DTSRP]" > $s/bp$num.ini
			echo "Polling = 333" >> $s/bp$num.ini
			ide=`ssh root@$ip "grep Identifier $fich"|awk '{print ($3)}'|head -1`
			echo "Destination = $ide" >> $s/bp$num.ini
			PDV=`echo $i|cut -f2 -d_|cut -f1 -d.`
			PDV=`echo "ibase=16; $PDV"|bc`
			echo "PDV = $PDV" >> $s/bp$num.ini
			source=`echo $i|cut -f1 -d_`
			source=`echo "ibase=16; $source"|bc`
			echo "SourceA = $source" >> $s/bp$num.ini
			echo "SourceB = " >> $s/bp$num.ini
			echo "IPListA = $list" >> $s/bp$num.ini
			echo "IPListB = $list" >> $s/bp$num.ini
			echo "UDPPort = $destport" >> $s/bp$num.ini
			TSM=`ssh root@$ip "ls $tsmf"|cut -f$pos -d_|cut -f1 -d.`
			TSM=`echo "ibase=16; $TSM"|bc`
			echo "TSM = $TSM" >> $s/bp$num.ini
			echo "DisableLog = 1" >> $s/bp$num.ini
			echo "DisableActivation = 1" >> $s/bp$num.ini
			echo "SynchroPort = $port" >> $s/bp$num.ini
			echo "Protocol = $protocol" >> $s/bp$num.ini
			port=$[$port+1]
		done
		num=$[$num+1]
	done
}

function leu(){
	if [ $# -eq 1 ];then
		case $1 in
			serie|SERIE|SER|ser|Serie|Ser)tipo=SER
			 poll=$poll_serie;;
			*)echo "el parametro no es valido se configurara en paralelo"
			  tipo=PAR
			  poll=$poll_paralelo;;
		esac
	else
		tipo=PAR
		poll=$poll_paralelo
	fi
	mkdir LEU
	mkdir LEU/LOG
	cp $leuexe LEU/leu
	cp $update LEU/
	chmod +x LEU/leu LEU/$update
	touch LEU/leu.md5
	mkdir LEU/DATOS
	scp root@$ip:$dc/* LEU/DATOS >/dev/null
	leus=`ls LEU/DATOS/*.dc|wc -l`
	if [ $tipo = "SER" ];then
		poll=`echo "$poll/$leus"|bc`
	fi
	echo "[LEUCORE_DRIVER]" > LEU/leu.ini
	echo " DriverType 	= LEUCORE" >> LEU/leu.ini
	echo " DriverName		= LEU DATACORE Simulator" >> LEU/leu.ini
	echo " Directory		= LOG/" >> LEU/leu.ini
	echo " Identifier		= 0x10101010" >> LEU/leu.ini
	echo " LogSize		= 5" >> LEU/leu.ini
	echo " NetSection		= NET" >> LEU/leu.ini
	echo " PollingMethod			= $tipo" >> LEU/leu.ini
	echo " PollingMilliseconds	= $poll" >> LEU/leu.ini
	echo " ConnectionList			= $ipsl" >> LEU/leu.ini
	ide=`ssh root@$ip "grep Identifier $fich"|awk '{print ($3)}'|head -1`
	echo " Destination			= $ide" >> LEU/leu.ini
	echo " DataCorePath			= DATOS/" >> LEU/leu.ini
	echo "[NET]" >> LEU/leu.ini
	echo " PortIn  	= 60110" >> LEU/leu.ini
	cd LEU
	./$update leu.ini leu 2>/dev/null >/dev/null
	cd ..
}

#empieza el cuerpo del script
if [ $# -eq 1 ] || [ $# -eq 2 ];then
	rm -r ATS 2>/dev/null
	rm -r BP 2>/dev/null
	rm -r LEU 2>/dev/null
	conf
	ips $1
	ipf
	pos=`ssh root@$ip "ls $tsmf"|awk 'BEGIN{FS="_"};{print NF}'`
	port=5501
	toc=$(ssh root@$ip "ls $tocf" 2>/dev/null)	
	ats
	ssh root@$ip "ls $kp" 2>/dev/null >/dev/null
	if [ $? -eq 0 ];then
		bp
	fi
	ssh root@$ip "ls $dc" 2>/dev/null >/dev/null
	if [ $? -eq 0 ];then
		leu $2
	fi
else
	echo "se ha de facilitar el archivo de configuracion como parametro"
fi
