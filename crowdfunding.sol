// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 < 0.9.0;

contract CrowdFunding{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public deadline;
    uint public target;
    uint public minContribution;
    uint public raisedAmount;
    uint public noOfContributors;

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }
    mapping(uint=>Request) public requests;
    uint public numRequests;

    constructor(uint t,uint _deadline){
        target=t;
        deadline=block.timestamp + _deadline;
        minContribution=100 wei;
        manager=msg.sender;
    }

    receive() external  payable{
        require(block.timestamp < deadline, "Deadline has passed");
        require(msg.value>=minContribution,"Minimum contribution is not met");

        if(contributors[msg.sender]==0){
            noOfContributors++;
        }

        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function refund() public{
        require(block.timestamp>deadline && raisedAmount<target,"Not eligible for refund");
        require(contributors[msg.sender]>0);

        address payable user=payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }

    modifier onlyManager(){
        require(msg.sender==manager,"Only manager can access this function");
        _;
    }

    function createRequests(string memory des,address payable reci,uint val) onlyManager public {
        Request storage newRequest= requests[numRequests];
        numRequests++;
        newRequest.description=des;
        newRequest.recipient=reci;
        newRequest.noOfVoters=0;
        newRequest.value=val;
        newRequest.completed=false;
    }

    function voteRequest(uint requestNo) public{
        require(contributors[msg.sender]>0,"You must be contributor");
        Request storage r=requests[requestNo];

        require(r.voters[msg.sender]==false,"You  have already voted");
        r.noOfVoters++;
        r.voters[msg.sender]=true;
    }

    function makePayment(uint requestNo) onlyManager public{
        require(raisedAmount>=target);
        Request storage r=requests[requestNo];

        require(r.completed==false,"this request is already completed");
        require(r.noOfVoters> noOfContributors/2,"Majority does not support");
        r.recipient.transfer(r.value);
        r.completed=true;
    } 
}