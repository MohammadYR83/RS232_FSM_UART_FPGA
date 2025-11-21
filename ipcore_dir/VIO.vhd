-------------------------------------------------------------------------------
-- Copyright (c) 2025 Xilinx, Inc.
-- All Rights Reserved
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor     : Xilinx
-- \   \   \/     Version    : 14.7
--  \   \         Application: XILINX CORE Generator
--  /   /         Filename   : VIO.vhd
-- /___/   /\     Timestamp  : Thu Oct 30 23:32:40 Iran Standard Time 2025
-- \   \  /  \
--  \___\/\___\
--
-- Design Name: VHDL Synthesis Wrapper
-------------------------------------------------------------------------------
-- This wrapper is used to integrate with Project Navigator and PlanAhead

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY VIO IS
  port (
    CONTROL: inout std_logic_vector(35 downto 0);
    CLK: in std_logic;
    ASYNC_OUT: out std_logic_vector(7 downto 0);
    SYNC_IN: in std_logic_vector(0 to 0);
    SYNC_OUT: out std_logic_vector(0 to 0));
END VIO;

ARCHITECTURE VIO_a OF VIO IS
BEGIN

END VIO_a;
