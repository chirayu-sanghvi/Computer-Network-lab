#crearte the simulator object
set ns [new Simulator]


#setup trace file
set traceFile [open 3.tr w]
$ns trace-all $traceFile
set namFile [ open 3.nam w]
$ns namtrace-all $namFile

proc finish {} {
	global ns namFile traceFile
	$ns flush-trace
	#close the trace files
	close $traceFile
	close $namFile
	      exec awk -f third.awk 3.tr &
	      exec nam 3.nam &
	exit 0
}



#create four nodes
for {set i 0} {$i < 4} {incr i} {
	set n($i) [$ns node]
}

#create links between teh nodes
$ns duplex-link $n(0) $n(2) 2Mb 10ms DropTail
$ns duplex-link $n(1) $n(2) 2Mb 10ms DropTail
$ns duplex-link $n(2) $n(3) 900kb 10ms DropTail


#set queue size
$ns queue-limit $n(0) $n(2) 10


#set tcp connection between n(0) and n(3)
set tcp [new Agent/TCP]
$ns attach-agent $n(0) $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n(3) $sink
$ns connect $tcp $sink

#attach ftp application over tcp
#attach telnet application over tcp
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

#set udp connection between n(1) and n(3)
set udp [new Agent/UDP]
$ns attach-agent $n(1)  $udp
set null [new Agent/Null]
$ns attach-agent $n(3) $null
$ns connect $udp $null

#attach CBR traffic over udp
set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 500
$cbr set interval_ 0.005
$cbr attach-agent $udp
#Schedule events 
$ns at 0.5 "$ftp start"
$ns at 1.0 "$cbr start"
$ns at 9.0 "$cbr stop"
$ns at 9.5 "$ftp stop"
$ns at 10.0 "finish"

#Run Simulation
$ns run
