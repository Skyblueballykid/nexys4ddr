library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu_module_tb is
end cpu_module_tb;

architecture Structural of cpu_module_tb is

   signal clk   : std_logic;                      -- 10 MHz
   signal rstn  : std_logic;                      -- Active low

   signal ia    : std_logic_vector(  31 downto 0);  -- Instruction Address
   signal id    : std_logic_vector(  31 downto 0);  -- Instruction Data
   signal ma    : std_logic_vector(  31 downto 0);  -- Memory Address
   signal moe   : std_logic;                        -- Memory Output Enable
   signal mrd   : std_logic_vector(  31 downto 0);  -- Memory Read Data
   signal wr    : std_logic;                        -- Write
   signal mwd   : std_logic_vector(  31 downto 0);  -- Memory Write Data
   signal regs  : std_logic_vector(1023 downto 0);

   signal test_running : boolean := true;

   -- Clock divider
   signal clken   : std_logic := '0';
   signal counter : std_logic_vector(0 downto 0) := (others => '0');

begin

   -- Generate reset
   rstn <= '0', '1' after 450 ns;

   -- Generate clock
   clk_gen : process
   begin
      if not test_running then
         wait;
      end if;

      clk <= '1', '0' after 50 ns; -- 10 MHz
      wait for 100 ns;
   end process clk_gen;

   -- Generate clock divider
   p_divider : process (clk)
   begin
      if rising_edge(clk) then
         clken <= '0';
         if counter = 0 then
            clken <= '1';
         end if;
         counter <= counter + 1;
      end if;
   end process p_divider;

   -- Instantiate the DUT
   i_dut : entity work.cpu_module
   port map (
      clk_i   => clk,
      clken_i => clken,
      rstn_i  => rstn,
      ia_o    => ia,
      id_i    => id,
      ma_o    => ma,
      moe_o   => moe,
      mrd_i   => mrd,
      wr_o    => wr,
      mwd_o   => mwd,
      regs_o  => regs
   );

   -- Instantiate Memory (Data and instruction)
   i_mem : entity work.mem
   port map (
      clk_i   => clk,
      clken_i => clken,
      ma_i    => ma,
      moe_i   => moe,
      mrd_o   => mrd,
      wr_i    => wr,
      mwd_i   => mwd,
      ia_i    => ia,
      id_o    => id
   );


   -- This is the main test
   p_main : process
      type t_entry_res is record
         val : std_logic_vector(31 downto 0);
         ia  : std_logic_vector(31 downto 0);
      end record;

      type t_res_vector is array (natural range <>) of t_entry_res;
      constant res_vector : t_res_vector := (
         (X"00000002", X"00000034"),
         (X"0000011A", X"000000A0"),
         (X"00011F12", X"00000110"),
         (X"047C7B8C", X"000001BC"),
         (X"C7B8C7A7", X"000001F4"),
         (X"A17A11C7", X"00000274"),
         (X"A1638E2C", X"000002EC"),
         (X"871C71C7", X"000003A8"),
         (X"47A2B9C0", X"000003C4"));

      variable i : integer := 0;
   begin
      for i in 0 to res_vector'length-1 loop
         while wr /= '1' loop
            wait until clk = '0';
            wait until clk = '1';
         end loop;
         assert ma = X"000003FC";
         assert ia = res_vector(i).ia;
         assert mwd = res_vector(i).val;

         wait until wr = '0';
      end loop;

      report "Test PASSED";
      test_running <= false;
      wait;
   end process p_main;

end Structural;
