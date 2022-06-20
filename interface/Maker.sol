pragma solidity ^0.8.10;

interface Maker {
    event BuyGem(address indexed owner, uint256 value, uint256 fee);
    event Deny(address user);
    event File(bytes32 indexed what, uint256 data);
    event Rely(address user);
    event SellGem(address indexed owner, uint256 value, uint256 fee);

    function buyGem(address usr, uint256 gemAmt) external;
    function dai() view external returns (address);
    function daiJoin() view external returns (address);
    function deny(address usr) external;
    function file(bytes32 what, uint256 data) external;
    function gemJoin() view external returns (address);
    function hope(address usr) external;
    function ilk() view external returns (bytes32);
    function nope(address usr) external;
    function rely(address usr) external;
    function sellGem(address usr, uint256 gemAmt) external;
    function tin() view external returns (uint256);
    function tout() view external returns (uint256);
    function vat() view external returns (address);
    function vow() view external returns (address);
    function wards(address) view external returns (uint256);
}
