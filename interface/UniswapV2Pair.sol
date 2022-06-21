pragma solidity ^0.8.10;

interface UniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function DOMAIN_SEPARATOR() view external returns (bytes32);
    function MINIMUM_LIQUIDITY() view external returns (uint256);
    function PERMIT_TYPEHASH() view external returns (bytes32);
    function allowance(address, address) view external returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function balanceOf(address) view external returns (uint256);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function decimals() view external returns (uint8);
    function factory() view external returns (address);
    function getReserves() view external returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function initialize(address _token0, address _token1) external;
    function kLast() view external returns (uint256);
    function mint(address to) external returns (uint256 liquidity);
    function name() view external returns (string memory);
    function nonces(address) view external returns (uint256);
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    function price0CumulativeLast() view external returns (uint256);
    function price1CumulativeLast() view external returns (uint256);
    function skim(address to) external;
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes memory data) external;
    function symbol() view external returns (string memory);
    function sync() external;
    function token0() view external returns (address);
    function token1() view external returns (address);
    function totalSupply() view external returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
