#!/usr/bin/python

# Copyright 2013-present Barefoot Networks, Inc. 
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from scapy.all import sniff, sendp
from scapy.all import Packet
from scapy.all import ShortField, IntField, LongField, BitField

import sys
import struct
import string

def handle_pkt(pkt):
    pkt.show()
    pkt = str(pkt)
    print pkt
    #if len(pkt) < 12: return
    #preamble = pkt[28:36]
    #preamble_exp = "\x00" * 8
    #if preamble != preamble_exp: return
    #num_valid = struct.unpack("<L", pkt[36:40])[0]
    #if num_valid != 0:
    #    print "received incorrect packet"
    timestamp1_1 = struct.unpack("<L", pkt[4:8])[0]
    timestamp1_2 = struct.unpack("<L", pkt[8:12])[0]

    timestamp2_1 = struct.unpack("<L", pkt[12:16])[0]
    timestamp2_2 = struct.unpack("<L", pkt[16:20])[0]

    timestamp3_1 = struct.unpack("<L", pkt[20:24])[0]
    timestamp3_2 = struct.unpack("<L", pkt[24:28])[0]
    msg = pkt[40:]
    print msg
    print "Timestamp1: ", timestamp1_1, timestamp1_2

    print "Timestamp2: ", timestamp2_1, timestamp2_2
    
    print "Timestamp3: ", timestamp3_1, timestamp3_2

    print "------------------------------"
    
    sys.stdout.flush()

def main():
    sniff(iface = "eth0",
          prn = lambda x: handle_pkt(x) )

if __name__ == '__main__':
    main()
