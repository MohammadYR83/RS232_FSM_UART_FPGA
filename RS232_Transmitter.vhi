
-- VHDL Instantiation Created from source file RS232_Transmitter.vhd -- 17:17:25 10/30/2025
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT RS232_Transmitter
	PORT(
		clock_in : IN std_logic;
		send_in : IN std_logic;
		data_in : IN std_logic_vector(7 downto 0);          
		busy_out : OUT std_logic;
		serial_out : OUT std_logic
		);
	END COMPONENT;

	Inst_RS232_Transmitter: RS232_Transmitter PORT MAP(
		clock_in => ,
		send_in => ,
		busy_out => ,
		serial_out => ,
		data_in => 
	);


