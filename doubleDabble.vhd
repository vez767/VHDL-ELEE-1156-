library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity doubleDabble is port
(
	clk      : in  std_logic;
	binaryIn : in  unsigned(13 downto 0);
	bcd      : out std_logic_vector(19 downto 0)
);
end doubleDabble;

architecture rtl of doubleDabble is

begin

process(clk)

	variable i       : integer := 14;
	variable scratch : unsigned(33 downto 0) := (others => '0');

begin
	if rising_edge(clk) then
		
		if i = 14 then
			bcd <= std_logic_vector(scratch(33 downto 14));
			i := 0;
			scratch := "00000000000000000000" & binaryIn;
		else
			i := i + 1;
	 
			if scratch(33 downto 30) > 4 then
				scratch(33 downto 30) := scratch(33 downto 30) + 3;
			end if;
			if scratch(29 downto 26) > 4 then
				scratch(29 downto 26) := scratch(29 downto 26) + 3;
			end if;
			if scratch(25 downto 22) > 4 then
				scratch(25 downto 22) := scratch(25 downto 22) + 3;
			end if;		
			if scratch(21 downto 18) > 4 then
				scratch(21 downto 18) := scratch(21 downto 18) + 3;
			end if;
			if scratch(17 downto 14) > 4 then
				scratch(17 downto 14) := scratch(17 downto 14) + 3;
			end if;
			
			scratch := shift_left(scratch, 1);
		end if;
			
	end if;	
end process;
	
end rtl;