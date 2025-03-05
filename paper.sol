// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract DecentralizedResearchPublishing {

// general structure of a research paper
    struct Paper {
        uint id;
        string title;
        string ipfsHash;
        address author;
        bool reviewed;
    }

// role can be only one of the following
    enum Role { Spectator, Author, Reviewer }

// roles and the properties associated with that role
    mapping(address => Role) public roles;
    mapping(address => uint) public papersSubmitted;
    mapping(address => uint) public papersReviewed;

// thresholds and paper counter
    uint public authorThreshold = 2;
    uint public reviewerThreshold = 5;
    uint public paperCounter = 0;
    
    mapping(uint => Paper) public papers;
    mapping(address => uint[]) public authorPapers;
    mapping(address => uint[]) public reviewerPapers;

// modifier for author permission
    modifier onlyAuthor() {
        require(roles[msg.sender] == Role.Author, "Only authors can perform this action.");
        _;
    }

// modifier for reviewer permission
    modifier onlyReviewer() {
        require(roles[msg.sender] == Role.Reviewer, "Only reviewers can perform this action.");
        _;
    }

// modifier for spectator permission
    modifier onlySpectator() {
        require(roles[msg.sender] == Role.Spectator, "Only spectators can perform this action.");
        _;
    }





// function to login as author
    function loginAsAuthor() public {
// condition to check if the sender is already a author or reviewer
        require(roles[msg.sender] == Role.Spectator, "Already registered as an author or reviewer.");
// check if the author satisfies the threshold
        require(papersSubmitted[msg.sender] >= authorThreshold, "You must submit more papers to become an author.");
// if conditions satisfied, login as author
        roles[msg.sender] = Role.Author;
    }



// function to login as reviewer
    function loginAsReviewer() public {
// condition to check if the sender is already a author or reviewer
        require(roles[msg.sender] == Role.Spectator, "Already registered as an author or reviewer.");
// check if the reviewer satisfies the threshold
        require(papersReviewed[msg.sender] >= reviewerThreshold, "You must review more papers to become a reviewer.");
// if conditions satisfied, login as reviewer
        roles[msg.sender] = Role.Reviewer;
    }




// function to upload paper
    function uploadPaper(string memory _title, string memory _ipfsHash) public onlyAuthor {
// add paper counter which is now the paper id of the uploaded paper
        paperCounter++;
// append the paper in the blockchain
        papers[paperCounter] = Paper(paperCounter, _title, _ipfsHash, msg.sender, false);
// add the paper id of the uploaded paper to the list of papers submitted by our authors
        authorPapers[msg.sender].push(paperCounter);
// increment the no of papers submitted by the author
        papersSubmitted[msg.sender]++;
    }





// function to review paper
    function reviewPaper(uint _paperId) public onlyReviewer {
// condition to check whether paper id is not out of bounds
        require(_paperId > 0 && _paperId <= paperCounter, "Invalid paper ID.");
// fetch the paper from paper id
        Paper storage paper = papers[_paperId];
// condition to check if paper is already reviewed
        require(!paper.reviewed, "This paper has already been reviewed.");
// if not, it is reviewed now
        paper.reviewed = true;
// add the paper to the papers reviewed by the reviewer
        reviewerPapers[msg.sender].push(_paperId);
// increment the no of paper reviewed by the reviewer
        papersReviewed[msg.sender]++;
    }






// function to view paper
    function viewPaper(uint _paperId) public onlySpectator view returns (string memory title, string memory ipfsHash, address author, bool reviewed) {
// condition to check whether paper id is not out of bounds
        require(_paperId > 0 && _paperId <= paperCounter, "Invalid paper ID.");
// fetch the paper to be viewed   
        Paper storage paper = papers[_paperId];
// return paper
        return (paper.title, paper.ipfsHash, paper.author, paper.reviewed);
    }

// function to check and retrieve roles
    function getMyRole() public view returns (string memory) { 
        if (roles[msg.sender] == Role.Author) {
            return "Author";
        } else if (roles[msg.sender] == Role.Reviewer) {
            return "Reviewer";
        } else {
            return "Spectator";
        }
    }
}
