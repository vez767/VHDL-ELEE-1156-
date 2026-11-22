-- Quartus Prime VHDL Template
-- Four-State Moore State Machine

-- Requirement: Generate an 8-bit adjustable PWM signal for the TLC7524CN DAC.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_core is

	port(
		clk	 : in	std_logic;
		reset	 : in std_logic;
		period : in	unsigned(31 downto 0);
		selected_duty_cycle : in integer range 0 to 100; -- range from 0 to 100
		pwm_result	 : out std_logic_vector(7 downto 0)
	);

end entity;

architecture rtl of pwm_core is

	signal counter : unsigned(31 downto 0) := (others => '0');
	signal duty_cycle_threshold : unsigned(31 downto 0);
	

begin

	-- Logic to advance to the next state
	process (clk, reset)
	begin
	
		if reset = '0' then
		
			counter <= x"00000000";
			pwm_result <= x"00";
			duty_cycle_threshold <= (others => '0');
			
		elsif (rising_edge(clk)) then
		
		 duty_cycle_threshold <= resize((period/100) * to_unsigned(selected_duty_cycle, 32) ,32);
			
			if counter >= period then
				counter <= (others => '0');
				
			else counter <= counter + 1;
			end if;
			
				if counter < duty_cycle_threshold then
				pwm_result <= x"FF"; -- "1111 1111"
				
				else pwm_result <= x"00";
				end if;
			
		end if;
	end process;

end rtl;
