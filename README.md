# Word Recovery and Credibility Management Module

## Description
This hardware module, implemented in VHDL, updates a sequence of words stored in memory, starting from a given address, every two bytes. It replaces words with an unspecified value (i.e., 0) with the last valid word read (i.e., greater than 0). Additionally, it assigns a credibility value (ranging from 31 to 0) to each element in the sequence, stored in the byte following the element. The credibility value decreases by 1 each time an invalid word is replaced and resets to 31 when a valid word is encountered.
