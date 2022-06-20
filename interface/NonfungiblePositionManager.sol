pragma solidity ^0.8.10;

interface NonfungiblePositionManager {
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event Collect(uint256 indexed tokenId, address recipient, uint256 amount0, uint256 amount1);
    event DecreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    event IncreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    struct CollectParams { uint256 tokenId; address recipient; uint128 amount0Max; uint128 amount1Max; }
    struct MintParams { address token0; address token1; uint24 fee; int24 tickLower; int24 tickUpper; uint256 amount0Desired; uint256 amount1Desired; uint256 amount0Min; uint256 amount1Min; address recipient; uint256 deadline; }
    struct DecreaseLiquidityParams { uint256 tokenId; uint128 liquidity; uint256 amount0Min; uint256 amount1Min; uint256 deadline; }
    struct IncreaseLiquidityParams { uint256 a; uint256 b; uint256 c; uint256 d; uint256 e; uint256 f; }

    function DOMAIN_SEPARATOR() view external returns (bytes32);
    function PERMIT_TYPEHASH() view external returns (bytes32);
    function WETH9() view external returns (address);
    function approve(address to, uint256 tokenId) external;
    function balanceOf(address owner) view external returns (uint256);
    function baseURI() pure external returns (string memory);
    function burn(uint256 tokenId) payable external;
    function collect(CollectParams memory params) payable external returns (uint256 amount0, uint256 amount1);
    function createAndInitializePoolIfNecessary(address token0, address token1, uint24 fee, uint160 sqrtPriceX96) payable external returns (address pool);
    function decreaseLiquidity(DecreaseLiquidityParams memory params) payable external returns (uint256 amount0, uint256 amount1);
    function factory() view external returns (address);
    function getApproved(uint256 tokenId) view external returns (address);
    function increaseLiquidity(IncreaseLiquidityParams memory params) payable external returns (uint128 liquidity, uint256 amount0, uint256 amount1);
    function isApprovedForAll(address owner, address operator) view external returns (bool);
    function mint(MintParams memory params) payable external returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    function multicall(bytes[] memory data) payable external returns (bytes[] memory results);
    function name() view external returns (string memory);
    function ownerOf(uint256 tokenId) view external returns (address);
    function permit(address spender, uint256 tokenId, uint256 deadline, uint8 v, bytes32 r, bytes32 s) payable external;
    function positions(uint256 tokenId) view external returns (uint96 nonce, address operator, address token0, address token1, uint24 fee, int24 tickLower, int24 tickUpper, uint128 liquidity, uint256 feeGrowthInside0LastX128, uint256 feeGrowthInside1LastX128, uint128 tokensOwed0, uint128 tokensOwed1);
    function refundETH() payable external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) external;
    function selfPermit(address token, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) payable external;
    function selfPermitAllowed(address token, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) payable external;
    function selfPermitAllowedIfNecessary(address token, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) payable external;
    function selfPermitIfNecessary(address token, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) payable external;
    function setApprovalForAll(address operator, bool approved) external;
    function supportsInterface(bytes4 interfaceId) view external returns (bool);
    function sweepToken(address token, uint256 amountMinimum, address recipient) payable external;
    function symbol() view external returns (string memory);
    function tokenByIndex(uint256 index) view external returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) view external returns (uint256);
    function tokenURI(uint256 tokenId) view external returns (string memory);
    function totalSupply() view external returns (uint256);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function uniswapV3MintCallback(uint256 amount0Owed, uint256 amount1Owed, bytes memory data) external;
    function unwrapWETH9(uint256 amountMinimum, address recipient) payable external;
}
