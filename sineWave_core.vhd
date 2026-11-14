-- Quartus Prime VHDL Template
-- Four-State Moore State Machine

-- A Moore machine's outputs are dependent only on the current state.
-- The output is written only when the state changes.  (State
-- transitions are synchronous.)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sineWave_core is

	port(
		clk		 : in	std_logic;
		reset	 : in	std_logic;
		period	 : in	unsigned(31 downto 0);
		sine_result	 : out	std_logic_vector(7 downto 0)
	);

end entity;

architecture rtl of sineWave_core is

	signal clock_edge_counter   : unsigned(31 downto 0) := (others => '0');
	signal rom_address : unsigned(7 downto 0) := (others => '0');
	
		type rom_table is array(0 to 255) of std_logic_vector(7 downto 0);
		constant SineLookUpTable : rom_table := (
		  x"80", x"83", x"86", x"89", x"8C", x"90", x"93", x"96", 
        x"99", x"9C", x"9F", x"A2", x"A5", x"A8", x"AB", x"AE", 
        x"B1", x"B3", x"B6", x"B9", x"BC", x"BF", x"C1", x"C4", 
        x"C7", x"C9", x"CC", x"CE", x"D1", x"D3", x"D5", x"D8", 
        x"DA", x"DC", x"DE", x"E0", x"E2", x"E4", x"E6", x"E8", 
        x"EA", x"EB", x"ED", x"EE", x"F0", x"F1", x"F3", x"F4", 
        x"F5", x"F6", x"F8", x"F9", x"FA", x"FA", x"FB", x"FC", 
        x"FD", x"FD", x"FE", x"FE", x"FE", x"FF", x"FF", x"FF", 
        x"FF", x"FF", x"FF", x"FF", x"FE", x"FE", x"FE", x"FD", 
        x"FD", x"FC", x"FB", x"FA", x"FA", x"F9", x"F8", x"F6", 
        x"F5", x"F4", x"F3", x"F1", x"F0", x"EE", x"ED", x"EB", 
        x"EA", x"E8", x"E6", x"E4", x"E2", x"E0", x"DE", x"DC", 
        x"DA", x"D8", x"D5", x"D3", x"D1", x"CE", x"CC", x"C9", 
        x"C7", x"C4", x"C1", x"BF", x"BC", x"B9", x"B6", x"B3", 
        x"B1", x"AE", x"AB", x"A8", x"A5", x"A2", x"9F", x"9C", 
        x"99", x"96", x"93", x"90", x"8C", x"89", x"86", x"83", 
        x"80", x"7D", x"7A", x"77", x"74", x"70", x"6D", x"6A", 
        x"67", x"64", x"61", x"5E", x"5B", x"58", x"55", x"52", 
        x"4F", x"4D", x"4A", x"47", x"44", x"41", x"3F", x"3C", 
        x"39", x"37", x"34", x"32", x"2F", x"2D", x"2B", x"28", 
        x"26", x"24", x"22", x"20", x"1E", x"1C", x"1A", x"18", 
        x"16", x"15", x"13", x"12", x"10", x"0F", x"0D", x"0C", 
        x"0B", x"0A", x"08", x"07", x"06", x"06", x"05", x"04", 
        x"03", x"03", x"02", x"02", x"02", x"01", x"01", x"01", 
        x"01", x"01", x"01", x"01", x"02", x"02", x"02", x"03", 
        x"03", x"04", x"05", x"06", x"06", x"07", x"08", x"0A", 
        x"0B", x"0C", x"0D", x"0F", x"10", x"12", x"13", x"15", 
        x"16", x"18", x"1A", x"1C", x"1E", x"20", x"22", x"24", 
        x"26", x"28", x"2B", x"2D", x"2F", x"32", x"34", x"37", 
        x"39", x"3C", x"3F", x"41", x"44", x"47", x"4A", x"4D", 
        x"4F", x"52", x"55", x"58", x"5B", x"5E", x"61", x"64", 
        x"67", x"6A", x"6D", x"70", x"74", x"77", x"7A", x"7D"
		  
		  );

begin

	-- Logic to advance to the next state
	process (clk, reset)
	begin
	
	if reset = '0' then
	
		clock_edge_counter <= (others => '0');
		rom_address <= (others => '0');
	
	elsif(rising_edge(clk)) then
		
		if clock_edge_counter >= period then
			clock_edge_counter <= (others => '0');
			rom_address <= rom_address + 1;
			
		else clock_edge_counter <= clock_edge_counter + 1;
		end if;
		
	sine_result <= SineLookUpTable(to_integer(rom_address));
	end if;
	
	end process;

end rtl;
