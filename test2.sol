
pragma solidity ^0.4.24;
//题目二：实现一种最简单的含重入攻击漏洞的演示合约

contract IDMoney {
    address owner;
    mapping (address => uint256) balances;  // 记录每个打币者存入的资产情况

    event withdrawLog(address, uint256);

    function IDMoney() { owner = msg.sender; }
    function deposit() payable { balances[msg.sender] += msg.value; }
    function withdraw(address to, uint256 amount) {
        require(balances[msg.sender] > amount);
        require(this.balance > amount);

        withdrawLog(to, amount);  // 打印日志，方便观察 reentrancy

        to.call.value(amount)();  // 使用 call.value()() 进行 ether 转币时，默认会发所有的 Gas 给外部
        balances[msg.sender] -= amount;
    }
    function balanceOf() returns (uint256) { return balances[msg.sender]; }
    function balanceOf(address addr) returns (uint256) { return balances[addr]; }
}
