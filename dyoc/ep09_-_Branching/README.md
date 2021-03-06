# Design Your Own Computer - Episode 9 - "Branching"

Welcome to the ninth episode of "Design Your Own Computer". In this episode
we will perform the following three tasks:
* Add control of individual bits in the status register
* Conditional jumps
* Add support for simulation

Instructions implemented in total : 31/151.

## Controlling individual status bits
The 6502 has a number of instructions to manipulate the
status register:
* 18 CLC    (bit 0)
* 38 SEC    (bit 0)
* 58 CLI    (bit 2)
* 78 SET    (bit 2)
* 98    Not related
* B8 CLV    (bit 6)
* D8 CLD    (bit 3)
* F8 SED    (bit 3)

To implement these we need to build upon the multiplexer connected to
the status register. And we need to correspondingly expand the selector signal
sr\_sel. This is done in lines 130-149 of cpu/datapath.vhd.

## Conditional jumps
All conditional jumps (branches) on the 6502 are relative to the current
value of the Program Counter. We expand the selector pc\_sel for the Program
Counter and use it in lines 90-116 of cpu/datapath.vhd.

This takes care of the following instructions:
* 10 BPL
* 30 BMI
* 50 BVC
* 70 BVS
* 90 BCC
* B0 BCS
* D0 BNE
* F0 BEQ
 
With these instructions the CPU is now Turing Complete and is essentially
just as capable as the complete 6502 processor. However, with the limited
instructions available it quickly becomes very tedious. We definitely need
more instructions. In the coming episodes we'll add Zero page addressing,
Stack Pointer, and subroutine calls.

However, more urgent is to have an assembler, which will be the topic of the
next episode.

## Simulation support
By now it is becoming increasingly time consuming to build a bit file every
time you want to test it. In the Makefile in lines 13-16 I've added a new
target "sim" that will simulate the behaviour of the CPU and display a waveform.
In order to use this feature, you need to install GHDL. If you're running Linux
it may already be available in your distribution, otherwise it can be found
here: <https://github.com/ghdl/ghdl>.

Furthermore, in order to display the waveform, you need the tool GTKWAVE found
here <http://gtkwave.sourceforge.net/>. It too may already be available in your
favourite Linux distribution.

