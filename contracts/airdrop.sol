pragma solidity ^0.8.18;

interface IERC20 {
    function transfer(address to, uint256 value) external;
    function transferFrom(address from, address to, uint256 value) external;
    function balanceOf(address tokenOwner)  external returns (uint balance);

}
contract Bulksender{
   function bulksendToken(IERC20 _token, address[] calldata _to, uint256[] calldata _values) public  
   {
      for (uint256 i = 0; i < _to.length; i++) {
          _token.transferFrom(msg.sender, _to[i], _values[i] * 10**18);
    }
  }
}