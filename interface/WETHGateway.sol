pragma solidity ^0.8.10;

interface WETHGateway {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function authorizeLendingPool(address lendingPool) external;
    function borrowETH(address lendingPool, uint256 amount, uint256 interesRateMode, uint16 referralCode) external;
    function depositETH(address lendingPool, address onBehalfOf, uint16 referralCode) payable external;
    function emergencyEtherTransfer(address to, uint256 amount) external;
    function emergencyTokenTransfer(address token, address to, uint256 amount) external;
    function getWETHAddress() view external returns (address);
    function owner() view external returns (address);
    function renounceOwnership() external;
    function repayETH(address lendingPool, uint256 amount, uint256 rateMode, address onBehalfOf) payable external;
    function transferOwnership(address newOwner) external;
    function withdrawETH(address lendingPool, uint256 amount, address to) external;
}
