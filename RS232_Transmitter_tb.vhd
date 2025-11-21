--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:51:21 10/24/2025
-- Design Name:   
-- Module Name:   D:/mohammad/FPGA/ise_project/RS232_FSM_UART/RS232_Transmitter_tb.vhd
-- Project Name:  RS232_FSM_UART
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RS232_Transmitter
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY RS232_Transmitter_tb IS
END RS232_Transmitter_tb;
 
ARCHITECTURE behavior OF RS232_Transmitter_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RS232_Transmitter
    PORT(
         clock_in : IN  std_logic;
         send_in : IN  std_logic;
         busy_out : OUT  std_logic;
         serial_out : OUT  std_logic;
         data_in : IN  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clock_in : std_logic := '0';
   signal send_in : std_logic := '0';
   signal data_in : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal busy_out : std_logic;
   signal serial_out : std_logic;

   -- Clock period definitions
   constant clock_in_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RS232_Transmitter PORT MAP (
          clock_in => clock_in,
          send_in => send_in,
          busy_out => busy_out,
          serial_out => serial_out,
          data_in => data_in
        );

   -- Clock process definitions
   clock_in_process :process
   begin
		clock_in <= '0';
		wait for clock_in_period/2;
		clock_in <= '1';
		wait for clock_in_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clock_in_period*10;

      data_in <= "11110000";
      		wait for clock_in_period*10;
				send_in <= '1';
				wait for clock_in_period;
				send_in <= '0';

      wait;
   end process;

END;
