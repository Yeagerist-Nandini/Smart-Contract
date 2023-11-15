// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 < 0.9.0;

contract EventContract{
    struct Event{
        address organizer;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }

    mapping(uint=>Event) public events;
    mapping(address=>mapping(uint=>uint)) public tickets;
    uint public nextId=0;

    function createEvent(string memory name,uint date,uint price,uint ticketCount) external {
        require(date>block.timestamp,"You can organize event only for future data");
        require(ticketCount>0,"You can organize the event only if you create more than 0 tickets");

        events[nextId]=Event(msg.sender,name,date,price,ticketCount,ticketCount);
        nextId++;
    }  

    function buyTicket(uint id,uint quantity) external payable {
        require(events[id].date!=0,"This event doesn't exist");
        require(events[id].date>block.timestamp,"Event already occured");

        Event storage e = events[id];
        require(msg.value==(e.price*quantity),"Ethers is not enough");
        require(e.ticketRemain>=quantity,"Not enough tickets");
        e.ticketRemain-=quantity;
        tickets[msg.sender][id]+=quantity;
    }

    function transferTicket(address to,uint id,uint quantity) external{
        require(events[id].date!=0,"This event doesn't exist");
        require(events[id].date>block.timestamp,"Event already occured");
        require(tickets[msg.sender][id]>=quantity,"You don't have enough tickets");

        tickets[msg.sender][id]-=quantity;
        tickets[to][id]+=quantity;
    }
}