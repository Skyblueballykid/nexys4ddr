library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity datapath is
   port (
      clk_i   : in  std_logic;
      wait_i  : in  std_logic;

      addr_o  : out std_logic_vector(15 downto 0);
      data_i  : in  std_logic_vector(7 downto 0);
      data_o  : out std_logic_vector(7 downto 0);
      wren_o  : out std_logic;

      a_sel_i : in  std_logic;

      debug_o : out std_logic_vector(31 downto 0)
   );
end entity datapath;

architecture structural of datapath is

   -- Program Counter
   signal pc : std_logic_vector(15 downto 0) := (others => '0');

   -- 'A' register
   signal ar : std_logic_vector(7 downto 0);
   
begin

   -- Program Counter
   p_pc : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if wait_i = '0' then
            pc <= pc + 1;                 -- Increment program counter every clock cycle
         end if;
      end if;
   end process p_pc;

   -- 'A' register
   p_ar : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if wait_i = '0' then
            if a_sel_i = '1' then
               ar <= data_i;
            end if;
         end if;
      end if;
   end process p_ar;


   -----------------
   -- Drive output signals
   -----------------

   addr_o <= pc;
   wren_o <= '0';
   data_o <= (others => '0');

   debug_o(15 downto  0) <= pc;     -- Two bytes
   debug_o(23 downto 16) <= ar;     -- One byte
   debug_o(31 downto 24) <= data_i; -- One byte

end architecture structural;

