library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is 
port(
a : in std_logic_vector(31 downto 0);
b : in std_logic_vector(31 downto 0);
shamt : in std_logic_vector(4 downto 0);
op : in std_logic_vector(5 downto 0);
f : out std_logic_vector(31 downto 0);
co : out std_logic;
ovf : out std_logic;
z : out std_logic);

end alu;

architecture arch of alu is

component mux6bs is 
port(
input : in std_logic_vector(2047 downto 0);
sel : in std_logic_vector(5 downto 0);
output : out std_logic_vector(31 downto 0));

end component;

component adder is
port(
i_A	: in std_logic;
i_B	: in std_logic;
i_Cin	: in std_logic;
o_S	: out std_logic;
o_Cout	: out std_logic);
end component;

component ushift is
port(
data : in std_logic_vector(31 downto 0);
shift : in std_logic_vector(4 downto 0);
log_arith : in std_logic;
right_left : in std_logic;
output : out std_logic_vector(31 downto 0));
end component;

component mux_gen is
  generic(n : positive := 32);
  port(i_A  : in std_logic_vector(n-1 downto 0);
       i_B  : in std_logic_vector(n-1 downto 0);
       sel  : in std_logic;
       o_F  : out std_logic_vector(n-1 downto 0));
end component;

signal mout : std_logic_vector(2047 downto 0);
signal add_carry : std_logic_vector(32 downto 0);
signal sltu,lui,notb, bb, addout, abor, abnor, aband, abxor, shifter, slt32, la, lb, m54, m76, m74, m70, mba, mb8, mb0: std_logic_vector(31 downto 0);
signal rop : std_logic_vector(5 downto 0);
signal raw_ovf, setbit : std_logic;

begin

with op select
rop <= "000000" when "100001", -- addu
	"000001" when "100000", -- add
	"000010" when "100011", -- subu
	"000011" when "100010", -- sub
	"000100" when "100101", -- or
	"000101" when "100111", -- nor
	"000110" when "100100", -- and
	"000111" when "100110", -- xor
	"001000" when "000010", -- srl
	"001001" when "000011", -- sra
	"001010" when "000000", -- sll
	"001011" when "101010", -- slt
	"001100" when "010101", -- B
	"001101" when "000001", -- lui
	"001110" when "010100", -- A
	"001111" when "101011", -- sltu
	op when others;

notb <= not b; 

binv : mux_gen
generic map (n => 32)
port map (
i_A => b,
i_B => notb,
sel => rop(1),
o_F => bb);

add_carry(0) <= rop(1);

gen: for i in 0 to 31 generate
adderi : adder
port map(
i_A => a(i),
i_B => bb(i),
i_Cin => add_carry(i),
o_S => addout(i),
o_Cout => add_carry(i+1));
end generate;

raw_ovf <= add_carry(32) xor add_carry(31);
ovf <= (raw_ovf and (not rop(3))) and ((not rop(2)) and rop(0));
co <= add_carry(32);

abor <= a or b;

abnor <= a nor b;

aband <= a and b;

abxor <= a xor b;

sft: ushift
port map (
data => b,
shift => shamt,
log_arith => rop(0),
right_left => rop(1),
output => shifter);

setbit <= (addout(31) and (not raw_ovf)) or (raw_ovf and a(31));
slt32(31 downto 1) <= "0000000000000000000000000000000";
slt32(0) <= setbit;

lui <= b(15 downto 0) & "0000000000000000";

sltu(31 downto 1) <= "0000000000000000000000000000000";
sltu(0) <= b(31) when ((a(31) xor b(31)) = '1') else
	slt32(0);

mout(31 downto 0) <= addout;
mout(63 downto 32) <= addout;
mout(95 downto 64) <= addout;
mout(127 downto 96) <= addout;
mout(159 downto 128) <= abor;
mout(191 downto 160) <= abnor;
mout(223 downto 192) <= aband;
mout(255 downto 224) <= abxor;
mout(287 downto 256) <= shifter;
mout(319 downto 288) <= shifter;
mout(351 downto 320) <= shifter;
mout(383 downto 352) <= slt32;
mout(415 downto 384) <= b;
mout(447 downto 416) <= lui;
mout(479 downto 448) <= a;
mout(511 downto 480) <= sltu;


genm: for i in 512 to 2047 generate
mout(i) <= '0';
end generate;



m6: mux6bs
port map(
input => mout,
sel => rop,
output => mb0);

f <= mb0;

z <= not (mb0(0) or mb0(1) or mb0(2) or mb0(3) or mb0(4) or mb0(5) or mb0(6) or mb0(7) or mb0(8) or mb0(9) or mb0(10) or mb0(11) or mb0(12) or mb0(13) or mb0(14) or mb0(15) or mb0(16) or mb0(17) or mb0(18) or mb0(19) or mb0(20) or mb0(21) or mb0(22) or mb0(23) or mb0(24) or mb0(25) or mb0(26) or mb0(27) or mb0(28) or mb0(29) or mb0(30) or mb0(31));



end arch;