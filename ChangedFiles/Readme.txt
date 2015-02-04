You will need to build Unicon with the patterns option after 
replacing the following files for the current pattern implementation.

src\h\fdefs.h
src\h\rproto.h
src\runtime\fscan.r
src\runtime\fxpattrn.ri
src\runtime\omisc.r
src\uni\unicon\unilex.icn
src\uni\unicon\unigram.y

This update makes the following changes: 

- the pattern function names have been revised to be more like Unicon.
- the pattern fucntions which are dependent on the index or cursor 
	position in a string have been revised to use the Unicon index
	system.
- allows the user to use the tabmat operator in the string scanning 
	environment on a pattern to perform a pattern match in the 
	anchored mode.
- the pattern assignment operators were changed to be more lexically
	consistent.
	
