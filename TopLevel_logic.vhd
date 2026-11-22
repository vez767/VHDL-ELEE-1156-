	library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

	entity TopLevel_logic is 

	port (
				clk,reset : in std_logic;
				sw0, sw7, sw9 	: in std_logic;
				key0, key1, key2, key3 : in std_logic;
				
				gpio_out : out std_logic_vector(7 downto 0);
				
				sseg0 : out std_logic_vector(6 downto 0);
				sseg1 : out std_logic_vector(6 downto 0);
				sseg2 : out std_logic_vector(6 downto 0);
				sseg3 : out std_logic_vector(6 downto 0);
				sseg4 : out std_logic_vector(6 downto 0);
				sseg5 : out std_logic_vector(6 downto 0);
				
				
				led0, led7, led9 : out std_logic
				
				
	);
	end entity;

	architecture rtl of TopLevel_logic is 

	component pwm_core is

		port(
			clk	 : in	std_logic;
			reset	 : in std_logic;
			period : in	unsigned(31 downto 0);
			selected_duty_cycle : in integer range 0 to 100;
			pwm_result	 : out std_logic_vector(7 downto 0)
		);
	end component;

	component sineWave_core is

		port(
			clk		 : in	std_logic;
			reset	 : in	std_logic;
			period	 : in	unsigned(31 downto 0);
			sine_result	 : out	std_logic_vector(7 downto 0)
		);
	end component;

	component doubleDabble is 

	port
	(
		clk      : in  std_logic;
		binaryIn : in  unsigned(13 downto 0);
		bcd      : out std_logic_vector(19 downto 0)
	);

	end component;
	
	component ssegDecoder is 
	
		port
		(
			binaryIn : in  std_logic_vector(3 downto 0);
			ssegOut  : out std_logic_vector(6 downto 0)
		);
end component;

	signal target_frequency : unsigned(31 downto 0):= (others => '0');
	signal calculated_period : unsigned(31 downto 0) := (others => '0');
	signal selected_duty_cycle :  integer range 0 to 100 := 0;

	signal internal_reset     : std_logic := '0';
	signal internal_timer : integer range 0 to 250000000 := 0;

	signal key0_prev : std_logic := '1';
	signal key1_prev : std_logic := '1';
	signal key2_prev : std_logic := '1';
	signal key3_prev : std_logic := '1';

	signal key0_current : std_logic := '0';
	signal key1_current : std_logic := '0';
	signal key2_current : std_logic := '0';
	signal key3_current : std_logic := '0';

	signal sine_result :  std_logic_vector(7 downto 0);
	signal pwm_result  :  std_logic_vector(7 downto 0);

	signal bcd_out : std_logic_vector(19 downto 0);

	begin 

		edge_detection: process(clk)
		begin
		if rising_edge(clk) then 
			key0_current <= '0';
			key1_current <= '0';
			key2_current <= '0';
			key3_current <= '0';
			
			if key0_prev = '1' and key0 = '0' then key0_current <= '1'; end if;
			if key1_prev = '1' and key1 = '0' then key1_current <= '1'; end if;
			if key2_prev = '1' and key2 = '0' then key2_current <= '1'; end if;
			if key3_prev = '1' and key3 = '0' then key3_current <= '1'; end if;
			
			key0_prev <= key0;
			key1_prev <= key1;
			key2_prev <= key2;
			key3_prev <= key3;
		end if;
		
		end process;
		
		
		
		main: process(clk)
		begin
		
			if rising_edge(clk) then
			
				if sw0 = '0' then
				internal_reset     <= '0';
				internal_timer     <= 0;
				target_frequency <= (others => '0');
				calculated_period <= (others => '0');
				selected_duty_cycle <= 0;
				
			elsif sw0 = '1' then
			
				if internal_reset = '0' then
					
					if internal_timer >= 250000000 then
						internal_reset <= '1';
						internal_timer <= 0;
						target_frequency <= to_unsigned(10, 32);
						
					else
						internal_timer <= internal_timer + 1;
					end if;
			
				else
				
					if sw7 = '1' then	
					
						if sw9 = '1' and key0_current = '1' and  selected_duty_cycle <= 90 then --pwm mode
							selected_duty_cycle <= selected_duty_cycle + 10;
						end if;
						
						if target_frequency <= 9990  and key1_current = '1' then
							target_frequency  <= target_frequency  + 10;
						end if;
						
						if target_frequency  <= 9900 and key2_current = '1' then 
							target_frequency  <= target_frequency  + 100;
						end if;
						
						if target_frequency  <= 9000 and key3_current = '1' then 
							target_frequency  <= target_frequency  + 1000;
						end if;
						
					else
					
					if sw9 = '1' and key0_current = '1' and  selected_duty_cycle >= 10 then --pwm mode
							selected_duty_cycle <= selected_duty_cycle - 10;
						end if;
						
						if target_frequency  >= 20 and key1_current = '1' then 
							target_frequency  <= target_frequency  - 10;
						end if;
						
						if target_frequency  >= 110 and key2_current = '1' then 
							target_frequency  <= target_frequency  - 100;
						end if;
						
						if target_frequency  >= 1010 and key3_current = '1' then 
							target_frequency  <= target_frequency  - 1000;
						end if;
					end if;
					
						
					
					if target_frequency > 0 then
						calculated_period <= to_unsigned(50000000, 32) / target_frequency;
					elsif target_frequency = 0 then
						calculated_period <= (others => '0');
					end if;
				end if;
			end if;
		end if;
						
		end process;
		
		sineWave_logic : sineWave_core port map(clk => clk, reset => internal_reset, period => calculated_period, sine_result => sine_result);
		pulseWidth_logic: pwm_core port map(clk => clk, reset => internal_reset, period => calculated_period, selected_duty_cycle => selected_duty_cycle, pwm_result => pwm_result);
		dd_logic : doubleDabble port map(clk => clk, binaryIn => target_frequency(13 downto 0), bcd => bcd_out);
		
		
		 ssegDisp0 : ssegDecoder port map(binaryIn => bcd_out(3 downto 0),   ssegOut => sseg0);
		 ssegDisp1 : ssegDecoder port map(binaryIn => bcd_out(7 downto 4),   ssegOut => sseg1);
		 ssegDisp2 : ssegDecoder port map(binaryIn => bcd_out(11 downto 8),  ssegOut => sseg2);
		 ssegDisp3 : ssegDecoder port map(binaryIn => bcd_out(15 downto 12), ssegOut => sseg3);
		 ssegDisp4 : ssegDecoder port map(binaryIn => bcd_out(19 downto 16), ssegOut => sseg4);
		 
		 sseg5 <= "0001100" when sw9 = '1' else "0010010";
		 
		led0 <= sw0;
		led7 <= sw7;
		led9 <= sw9;
		
		gpio_out <= pwm_result when sw9 = '1' else sine_result;
		
	end rtl;