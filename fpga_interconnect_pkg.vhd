library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package fpga_interconnect_pkg is

    type fpga_interconnect_record is record
        data                           : std_logic_vector(15 downto 0);
        address                        : std_logic_vector(15 downto 0);
        data_write_is_requested_with_0 : std_logic;
        data_read_is_requested_with_0  : std_logic;
    end record;

    constant init_fpga_interconnect : fpga_interconnect_record := ((others => '1'), (others => '1'), '1', '1');

------------------------------------------------------------------------
    function "and" ( left, right : fpga_interconnect_record)
        return fpga_interconnect_record;
------------------------------------------------------------------------
    procedure init_bus (
        signal bus_out : out fpga_interconnect_record);
------------------------------------------------------------------------
    procedure write_data_to_address (
        signal bus_out : out fpga_interconnect_record;
        address : integer;
        data : integer);
------------------------------------------------------------------------
    function write_to_address_is_requested (
        bus_in : fpga_interconnect_record;
        address : integer)
    return boolean;
------------------------------------------------------------------------
    function get_data ( bus_in : fpga_interconnect_record)
        return integer;
------------------------------------------------------------------------
    procedure request_data_from_address (
        signal bus_out : out fpga_interconnect_record;
        address : integer);
------------------------------------------------------------------------
    function data_is_requested_from_address (
        bus_in : fpga_interconnect_record;
        address : integer)
        return boolean;
------------------------------------------------------------------------
    procedure connect_data_to_address (
        bus_in         : in fpga_interconnect_record  ;
        signal bus_out : out fpga_interconnect_record ;
        address        : in integer                   ;
        signal data    : inout integer);
------------------------------------------------------------------------
    procedure connect_read_only_data_to_address (
        bus_in         : in fpga_interconnect_record  ;
        signal bus_out : out fpga_interconnect_record ;
        address        : in integer                   ;
        data           : in integer);
------------------------------------------------------------------------

end package fpga_interconnect_pkg;

package body fpga_interconnect_pkg is

------------------------------------------------------------------------
    function "and"
    (
        left, right : fpga_interconnect_record
    )
    return fpga_interconnect_record
    is
    begin
    return (left.data                           and right.data                          ,
            left.address                        and right.address                       ,
            left.data_write_is_requested_with_0 and right.data_write_is_requested_with_0,
            left.data_read_is_requested_with_0  and right.data_read_is_requested_with_0 );
        
    end "and";
------------------------------------------------------------------------
    function to_integer
    (
        data : std_logic_vector 
    )
    return integer
    is
    begin
        return to_integer(unsigned(data));
    end to_integer;
------------------------------------------------------------------------
    function to_std_logic_vector
    (
        data : integer
    )
    return std_logic_vector
    is
    begin
        return std_logic_vector(to_unsigned(data, 16));
        
    end to_std_logic_vector;
------------------------------------------------------------------------
    procedure init_bus
    (
        signal bus_out : out fpga_interconnect_record
    ) is
    begin
        bus_out <= init_fpga_interconnect;
    end init_bus;
------------------------------------------------------------------------
    procedure write_data_to_address
    (
        signal bus_out : out fpga_interconnect_record;
        address : integer;
        data : integer
    ) is
    begin
        bus_out.address <= to_std_logic_vector(address);
        bus_out.data    <= to_std_logic_vector(data);
        bus_out.data_write_is_requested_with_0 <= '0';
    end write_data_to_address;
------------------------------------------------------------------------
    function write_to_address_is_requested
    (
        bus_in : fpga_interconnect_record;
        address : integer
    )
    return boolean
    is
    begin
        
        return bus_in.data_write_is_requested_with_0 = '0' and
            to_integer(bus_in.address) = address;
    end write_to_address_is_requested;
------------------------------------------------------------------------
    function get_data
    (
        bus_in : fpga_interconnect_record
    )
    return integer
    is
    begin
        return to_integer(bus_in.data);
    end get_data;
------------------------------------------------------------------------
    procedure request_data_from_address
    (
        signal bus_out : out fpga_interconnect_record;
        address : integer
    ) is
    begin
        bus_out.data_read_is_requested_with_0 <= '0';
        bus_out.address <= to_std_logic_vector(address);
    end request_data_from_address;
------------------------------------------------------------------------
    function data_is_requested_from_address
    (
        bus_in : fpga_interconnect_record;
        address : integer
    )
    return boolean
    is
    begin
        return bus_in.data_read_is_requested_with_0 = '0' and
            to_integer(bus_in.address) = address;
    end data_is_requested_from_address;
------------------------------------------------------------------------
    procedure connect_data_to_address
    (
        bus_in         : in fpga_interconnect_record  ;
        signal bus_out : out fpga_interconnect_record ;
        address        : in integer                   ;
        signal data    : inout integer
    ) is
    begin
        if write_to_address_is_requested(bus_in, address) then
            data <= get_data(bus_in);
        end if;

        if data_is_requested_from_address(bus_in, address) then
            write_data_to_address(bus_out, 0, data);
        end if;
        
    end connect_data_to_address;
------------------------------------------------------------------------
    procedure connect_read_only_data_to_address
    (
        bus_in         : in fpga_interconnect_record  ;
        signal bus_out : out fpga_interconnect_record ;
        address        : in integer                   ;
        data           : in integer
    ) is
    begin
        if data_is_requested_from_address(bus_in, address) then
            write_data_to_address(bus_out, 0, data);
        end if;
        
    end connect_read_only_data_to_address;
------------------------------------------------------------------------


end package body fpga_interconnect_pkg;
