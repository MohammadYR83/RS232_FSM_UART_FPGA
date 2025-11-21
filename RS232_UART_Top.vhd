----------------------------------------------------------------------------------
-- Engineer      : Mohammad Goodarzi
-- Module Name   : RS232_UART_Top
-- Project Name  : RS232_FSM_UART
-- Target Device : Generic FPGA
-- Tool Version  : Tested on Xilinx ISE
--
-- Description   :
-- This top-level module integrates RS232 UART transmitter and receiver modules
-- with debugging and monitoring cores (ILA, VIO, ICON) and clock management (DCM).
-- The design allows simulation of a full industrial FPGA UART communication system.
--
-- Features:
--   - 8-bit RS232 UART communication (TX & RX)
--   - FSM-based transmitter and receiver
--   - ILA core for real-time RX monitoring
--   - VIO core for real-time TX data input and send trigger
--   - ICON core for debug interface
--   - Clock management via DCM
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

----------------------------------------------------------------------------------
-- ENTITY DECLARATION
-- Defines the I/O ports of the top-level UART module.
----------------------------------------------------------------------------------
ENTITY RS232_UART_Top IS
    PORT (
        clock_in : IN STD_LOGIC; -- System clock input (e.g., 50 MHz)
        serial_in : IN STD_LOGIC; -- UART RX line input
        serial_out : OUT STD_LOGIC -- UART TX line output
    );
END ENTITY RS232_UART_Top;

----------------------------------------------------------------------------------
-- ARCHITECTURE DEFINITION
-- Integration of UART modules and debug cores.
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF RS232_UART_Top IS

    -------------------------------------------------------------------------------
    -- ILA Core for RX monitoring
    -------------------------------------------------------------------------------
    COMPONENT ILA
        PORT (
            CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
            CLK : IN STD_LOGIC;
            DATA : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            TRIG0 : IN STD_LOGIC_VECTOR(0 TO 0)
        );
    END COMPONENT;
    SIGNAL data_ila_net : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL valid_ila_net : STD_LOGIC_VECTOR(0 DOWNTO 0);

    -------------------------------------------------------------------------------
    -- ICON Core for debug interface
    -------------------------------------------------------------------------------
    COMPONENT ICON
        PORT (
            CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
            CONTROL1 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0)
        );
    END COMPONENT;
    SIGNAL control0_net : STD_LOGIC_VECTOR(35 DOWNTO 0);
    SIGNAL control1_net : STD_LOGIC_VECTOR(35 DOWNTO 0);

    -------------------------------------------------------------------------------
    -- Clock Management (DCM)
    -------------------------------------------------------------------------------
    COMPONENT DCM
        PORT (
            clock_in : IN STD_LOGIC;
            clock_out : OUT STD_LOGIC
        );
    END COMPONENT;
    SIGNAL clock_net : STD_LOGIC;

    -------------------------------------------------------------------------------
    -- RS232 Receiver Module
    -------------------------------------------------------------------------------
    COMPONENT RS232_Receiver
        PORT (
            clock_in : IN STD_LOGIC;
            serial_in : IN STD_LOGIC;
            valid_out : OUT STD_LOGIC;
            data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    -------------------------------------------------------------------------------
    -- RS232 Transmitter Module
    -------------------------------------------------------------------------------
    COMPONENT RS232_Transmitter
        PORT (
            clock_in : IN STD_LOGIC;
            send_in : IN STD_LOGIC;
            data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            busy_out : OUT STD_LOGIC;
            serial_out : OUT STD_LOGIC
        );
    END COMPONENT;
    SIGNAL send_net : STD_LOGIC_VECTOR(0 DOWNTO 0);
    SIGNAL busy_net : STD_LOGIC_VECTOR(0 DOWNTO 0);
    SIGNAL data_vio_net : STD_LOGIC_VECTOR(7 DOWNTO 0);

    -------------------------------------------------------------------------------
    -- VIO Core for TX data input and send trigger
    -------------------------------------------------------------------------------
    COMPONENT VIO
        PORT (
            CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
            CLK : IN STD_LOGIC;
            ASYNC_OUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            SYNC_IN : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            SYNC_OUT : OUT STD_LOGIC_VECTOR(0 TO 0)
        );
    END COMPONENT;

BEGIN

    -------------------------------------------------------------------------------
    -- Instantiate ILA for monitoring received data
    -------------------------------------------------------------------------------
    Inst_ILA : ILA
    PORT MAP(
        CONTROL => control0_net,
        CLK => clock_net,
        DATA => data_ila_net,
        TRIG0 => valid_ila_net
    );

    -------------------------------------------------------------------------------
    -- Instantiate ICON for debug interface
    -------------------------------------------------------------------------------
    Inst_ICON : ICON
    PORT MAP(
        CONTROL0 => control0_net,
        CONTROL1 => control1_net
    );

    -------------------------------------------------------------------------------
    -- Instantiate DCM for clock generation
    -------------------------------------------------------------------------------
    inst_DCM : DCM
    PORT MAP(
        clock_in => clock_in,
        clock_out => clock_net
    );

    -------------------------------------------------------------------------------
    -- Instantiate RS232 Receiver
    -------------------------------------------------------------------------------
    Inst_RS232_Receiver : RS232_Receiver
    PORT MAP(
        clock_in => clock_net,
        serial_in => serial_in,
        valid_out => valid_ila_net(0),
        data_out => data_ila_net
    );

    -------------------------------------------------------------------------------
    -- Instantiate RS232 Transmitter
    -------------------------------------------------------------------------------
    Inst_RS232_Transmitter : RS232_Transmitter
    PORT MAP(
        clock_in => clock_net,
        send_in => send_net(0),
        busy_out => busy_net(0),
        serial_out => serial_out,
        data_in => data_vio_net
    );

    -------------------------------------------------------------------------------
    -- Instantiate VIO for inputting TX data and sending trigger
    -------------------------------------------------------------------------------
    Inst_VIO : VIO
    PORT MAP(
        CONTROL => control1_net,
        CLK => clock_net,
        ASYNC_OUT => data_vio_net,
        SYNC_IN => busy_net,
        SYNC_OUT => send_net
    );

END ARCHITECTURE Behavioral;