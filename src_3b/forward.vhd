library IEEE;
use IEEE.std_logic_1164.all;

entity forward is
port(
jump : in std_logic;
branch : in std_logic;
readA : in std_logic_vector(4 downto 0);
readB : in std_logic_vector(4 downto 0);
IDEXdata : in std_logic_vector(6 downto 0);--6:regwrite,5:memtoreg,4to0:write address
MEMWBdata : in std_logic_vector(6 downto 0);
EXMEMdata : in std_logic_vector(6 downto 0);
flush : out std_logic;
jumpFLTR : out std_logic;
branchFLTR : out std_logic;
fwdCondA : out std_logic_vector(1 downto 0);--00:no forwarding, 01: MEMWB, 10: EXMEM
fwdCondB : out std_logic_vector(1 downto 0);
fwdNextA : out std_logic_vector(1 downto 0);
fwdNextB : out std_logic_vector(1 downto 0)
);
end forward;

architecture arch of forward is


signal AMIDEX,AMMEMWB,AMEXMEM,BMIDEX,BMMEMWB,BMEXMEM,f : std_logic;

begin
AMIDEX <= IDEXdata(6) and (readA(4) or readA(3) or readA(2) or readA(1) or readA(0)) and not ((readA(4) xor IDEXdata(4)) or (readA(3) xor IDEXdata(3)) or (readA(2) xor IDEXdata(2)) or (readA(1) xor IDEXdata(1)) or (readA(0) xor IDEXdata(0)));
BMIDEX <= IDEXdata(6) and (readB(4) or readB(3) or readB(2) or readB(1) or readB(0)) and not ((readB(4) xor IDEXdata(4)) or (readB(3) xor IDEXdata(3)) or (readB(2) xor IDEXdata(2)) or (readB(1) xor IDEXdata(1)) or (readB(0) xor IDEXdata(0)));
AMMEMWB <= MEMWBdata(6) and (readA(4) or readA(3) or readA(2) or readA(1) or readA(0)) and not ((readA(4) xor MEMWBdata(4)) or (readA(3) xor MEMWBdata(3)) or (readA(2) xor MEMWBdata(2)) or (readA(1) xor MEMWBdata(1)) or (readA(0) xor MEMWBdata(0)));
BMMEMWB <= MEMWBdata(6) and (readB(4) or readB(3) or readB(2) or readB(1) or readB(0)) and not ((readB(4) xor MEMWBdata(4)) or (readB(3) xor MEMWBdata(3)) or (readB(2) xor MEMWBdata(2)) or (readB(1) xor MEMWBdata(1)) or (readB(0) xor MEMWBdata(0)));
AMEXMEM <= EXMEMdata(6) and (readA(4) or readA(3) or readA(2) or readA(1) or readA(0)) and not ((readA(4) xor EXMEMdata(4)) or (readA(3) xor EXMEMdata(3)) or (readA(2) xor EXMEMdata(2)) or (readA(1) xor EXMEMdata(1)) or (readA(0) xor EXMEMdata(0)));
BMEXMEM <= EXMEMdata(6) and (readB(4) or readB(3) or readB(2) or readB(1) or readB(0)) and not ((readB(4) xor EXMEMdata(4)) or (readB(3) xor EXMEMdata(3)) or (readB(2) xor EXMEMdata(2)) or (readB(1) xor EXMEMdata(1)) or (readB(0) xor EXMEMdata(0)));

fwdCondA <= "00" when (jump = '1') and (branch = '0') else
	"01" when (AMMEMWB = '1') else
	"10" when AMEXMEM = '1' else
	"00";

fwdCondB <= "00" when (jump = '1') and (branch = '0') else
	"01" when (BMMEMWB = '1') else
	"10" when BMEXMEM = '1' else
	"00";

fwdNextA <= "00" when (jump = '1') and (branch = '0') else
	"01" when AMIDEX = '1' else
	"10" when AMMEMWB = '1' else
	"00";

fwdNextB <= "00" when (jump = '1') and (branch = '0') else
	"01" when BMIDEX = '1' else
	"10" when BMMEMWB = '1' else
	"00";

f <= '0' when (jump = '1') and (branch = '0') else
	'1' when (branch = '1') and ((AMIDEX = '1') or (BMIDEX = '1') or ((AMMEMWB = '1') and (MEMWBdata(5) = '1')) or ((BMMEMWB = '1') and (MEMWBdata(5) = '1'))) else
	'1' when (IDEXdata(5) = '1') and ((AMIDEX = '1') or (BMIDEX = '1')) else
	'0';
	
jumpFLTR <= jump and not f;
branchFLTR <= branch and not f;
flush <= f;


end arch;