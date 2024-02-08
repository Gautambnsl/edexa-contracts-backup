




contract A{
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked("5"));
}

interface IUniswapV2Factory {

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);

}

library B{
     function pairFor(address factory) internal view returns (bytes32 pair) {
        bytes32 init_hash = IUniswapV2Factory(factory).INIT_CODE_PAIR_HASH();
        return init_hash;
    }
}

contract C{
    function test(address to) public view returns(bytes32){
        bytes32 value = B.pairFor(to);
        return  value;
    }
}