
-- VHDL Instantiation Created from source file RS232_Receiver.vhd -- 17:10:16 10/30/2025
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT RS232_Receiver
	PORT(
		clock_in : IN std_logic;
		serial_in : IN std_logic;          
		valid_out : OUT std_logic;
		data_out : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	Inst_RS232_Receiver: RS232_Receiver PORT MAP(
		clock_in => ,
		serial_in => ,
		valid_out => ,
		data_out => 
	);


