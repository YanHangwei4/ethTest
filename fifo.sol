pragma solidity ^0.4.24;

/**
fifo结构：
队列是一个满足如下条件的数据结构：
（1）数据项一个挨着一个呈线性；
（2）所有的插入操作在一端进行（对头）；
（3）所有删除操作在另一端进行（对尾）；
（4）最先插入的记录是第一个被删除的记录；
（5）队列的根本操作有三个：
①入队，在队尾加入一个元素或记录；
②出队，将队头元素或记录移除；
③读队，取出队头元素或记录。

合约功能：
1. 合约以FIFO的形式接收和处理发送过来的某种token；
2. 变量定义（仅供参考）
  Uint256 total; //当前FIFO接收的token总量；

  struct Item (
   address _from;   //发送者地址
   uint256 _count;  //数量
   )
3. 函数定义（仅供参考）
  function add(address a, uint256 count)  //向FIFO添加一个item
  function get() //从FIFO中取出第一个item
  function withdraw(address a) //从FIFO中剔除某个地址的item
设计约束：
1. 支持存储空间回收，即FIFO占用存储空间与有效item数量成比例
2. 优化gas消耗，并给出简要的预估结果或说明
     通过metamask实际评估gas消耗，根据需要进行调整
*/
contract fifo {
   uint256 total;
   uint256 itemNum = 0;
   /*
    注意：
    需求可能1：(下面设计)这里item 以地址为唯一标准，进来的token,
        直接累加在之前的item地址中。
    需求可能2：(未实现)这里的item，相当于一笔笔记账，没进来一笔
        都是单独的一个数据单位。
   */
   struct Item(
     address fromAddress;
     uint256 tokenNum;
     )
   mapping(uint256 => Item)ItemNToItem;
   mapping(address => uint256)addressToItemN;

   //查询成功，web3.js 通过event
   event getItemEvent(address a, uint256 num);
   /*
     添加成功event，删除成功event，省略
   */

    //添加item
   function addItem(address a, uint256 count) public {
       /*
         判断是否有原来地址，查item，相等的地址，token数累加（），
         没有直接执行下面代码。
       */
       address addUser = msg.sender;
       itemNum= itemNum+1;
       addressToItemN[addUser]= itemNum;
       ItemNToItem[itemNum]= Item(addUser ,count);
   }
   //读item
   function getItem(address a) public {
      uint256 itemN =addressToItemN[a];
      uint256 FtokenNum = ItemNToItem[itemN].tokenNum;
      event getItemEvent(address a, uint256 FtokenNum);
   }
   //删除item
   function deleteItem(address a, uint256 count) public {
      uint256 itemN =addressToItemN[a];
      //需要判断 剩余tokenNum 和 count比较 省略，count = tokenNum 删除key及其值
      ItemNToItem[itemN].tokenNum = ItemNToItem[itemN].tokenNum - count ;
   }

}
