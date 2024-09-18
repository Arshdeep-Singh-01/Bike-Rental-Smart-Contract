pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

contract BikeRental {
    // Bike structure
    struct Bike {
        /* 
        id: unique identifier for each bike
        currentRenter: address of the current renter
        rentalStartTime: time when the bike was rented
        rentalEndTime: time when the bike was returned
        isAvailable: flag to check if the bike is available (rented or not)
        deposit: amount deposited by the renter initially
        */
        uint256 id;
        address currentRenter;
        uint256 rentalStartTime;
        uint256 rentalEndTime;
        bool isAvailable;
        uint256 deposit;
    }

    // Mapping to store bike data
    mapping(uint256 => Bike) public bikes;
    uint256 public totalBikes;
    address public owner;

    event BikeRented(uint256 bikeId, address renter, uint256 startTime);
    event BikeReturned(uint256 bikeId, address renter, uint256 rentalDuration, uint256 avgSpeed,uint deposit, uint256 rentalFee, uint256 amountReturned);

    constructor(uint256 numberOfBikes) {
        /**
        * @dev Constructor to initialize the contract with a given number of bikes
        * @param numberOfBikes: number of bikes to be initialized
         */
        owner = msg.sender;
        for (uint256 i = 0; i < numberOfBikes; i++) {
            // Initialize bikes
            bikes[i] = Bike(i, address(0), 0, 0, true, 0);
        }
        totalBikes = numberOfBikes;
    }

    // Register a new bike
    function registerBike() public payable {
        /**
        * @dev Function to register a new bike
        * @notice Only owner can register bikes
         */
        require(msg.sender == owner, "Only owner can register bikes");
        bikes[totalBikes] = Bike(totalBikes, address(0), 0, 0, true, 0);
        ++totalBikes;
    }

    // Rent a bike
    function rentBike(uint256 bikeId) public payable{
        /**
        * @dev Function to rent a bike
        * @param bikeId: id of the bike to be rented
        * @notice Only available bikes can be rented
        * @notice Deposit should be greater than 3000 wei
         */
        require(bikes[bikeId].isAvailable, "Bike is not available");
        require(msg.value >=3000, "Deposit should be greater than 3000 wei");

        bikes[bikeId].isAvailable = false;
        bikes[bikeId].currentRenter = msg.sender;
        bikes[bikeId].rentalStartTime = block.timestamp;
        bikes[bikeId].deposit = msg.value;

        emit BikeRented(bikeId, msg.sender, block.timestamp);
    }

    function resetBikeData(uint256 bikeId) internal {
        /**
        * @dev Function to reset bike data after returning
        * @param bikeId: id of the bike to be reset
         */
        bikes[bikeId].rentalStartTime = 0;
        bikes[bikeId].rentalEndTime = 0;
        bikes[bikeId].isAvailable = true;
        bikes[bikeId].deposit = 0;
    }

    // Return a bike
    function returnBike(uint256 bikeId) public payable{
        /**
        * @dev Function to return a bike
        * @param bikeId: id of the bike to be returned
        * @notice Only the current renter can return the bike
        * @notice Bike should not have been returned already
         */
        require(bikes[bikeId].currentRenter == msg.sender, "Unauthorized return");
        require(bikes[bikeId].rentalEndTime == 0, "Bike already returned");

        bikes[bikeId].rentalEndTime = block.timestamp;
        bikes[bikeId].isAvailable = true;
        bikes[bikeId].currentRenter = address(0);

        // Calculate and transfer rental fee
        uint256 rentalDuration = bikes[bikeId].rentalEndTime - bikes[bikeId].rentalStartTime;
        uint256 rentalFee = _calculateRentalFee(rentalDuration);
        uint256 returnAmount = bikes[bikeId].deposit - rentalFee;
        uint256 avgSpeed = _calculateBikeSpeed(bikeId);

        // logging data
        emit BikeReturned(bikeId, msg.sender, rentalDuration, avgSpeed, bikes[bikeId].deposit, rentalFee, returnAmount);

        payable(msg.sender).transfer(returnAmount);
        payable(owner).transfer(rentalFee);

        // Reset bike data
        resetBikeData(bikeId);
    }

    // function to return random number in range lower to upper
    function random(uint256 lower, uint256 upper) internal view returns (uint256) {
        /**
        * @dev Function to return random number in range lower to upper
        * @param lower: lower limit of the range
        * @param upper: upper limit of the range
         */
        return uint256(block.timestamp) % (upper - lower) + lower;
    }


    // Calculate bike speed (based on the distance travelled)
    function _calculateBikeSpeed(uint256 bikeId) internal view returns (uint256) {
        /**
        * @dev Function to calculate bike speed
        * @param bikeId: id of the bike
        * internal function, that is used to calculate the speed of the bike
         */
        uint256 distanceTravelled = random(50, 100);
        uint256 time = (block.timestamp - bikes[bikeId].rentalStartTime)/60 + 1;
        return distanceTravelled / time + 1;
    }

    // Calculate rental fee based on duration
    // NOTE: Maximum rental duration is 500 minutes, thus fee can be 1 + 500*5 = 2501
    function _calculateRentalFee(uint256 rentalDuration) internal view returns (uint256) {
        /**
        * @dev Function to calculate rental fee
        * @param rentalDuration: duration for which the bike was rented
        * internal function, that is used to calculate the rental fee based on the duration
         */
        uint256 baseFee = 1;
        uint256 minRate = random(1, 5);
        uint256 min = rentalDuration / 60;
        return baseFee + min * minRate;
    }

    // return id of the available bikes, anyone can call this function
    function getAvailableBikes() public view returns (uint256[] memory) {
        /**
        * @dev Function to get the list of available bikes
        * @notice Anyone can call this function
        * return list of id of the available bikes
         */
        uint256 count = 0;
        for (uint256 i = 0; i < totalBikes; i++) {
            if (bikes[i].isAvailable) {
                count++;
            }
        }
        uint256[] memory result = new uint256[](count);
        count = 0;
        for (uint256 i = 0; i < totalBikes; i++) {
            if (bikes[i].isAvailable) {
                result[count] = bikes[i].id;
                count++;
            }
        }
        return result;
    }

    // return id of the rented bikes, only owner can call this function
    function getAllRentedBikes() public view returns (uint256[] memory) {
        /**
        * @dev Function to get the list of rented bikes
        * @notice Only owner can call this function
        * return list of id of the rented bikes
         */
        require(msg.sender == owner, "Only owner can get rented bikes");
        uint256 count = 0;
        for (uint256 i = 0; i < totalBikes; i++) {
            if (!bikes[i].isAvailable) {
                count++;
            }
        }
        uint256[] memory result = new uint256[](count);
        count = 0;
        for (uint256 i = 0; i < totalBikes; i++) {
            if (!bikes[i].isAvailable) {
                result[count] = bikes[i].id;
                count++;
            }
        }
        return result;
    }

    // return a list of bikes that (given address) has rented
    function getMyrentedBikes() public view returns (uint256[] memory) {
        /**
        * @dev Function to get the list of bikes rented by the caller
        * return list of id of the rented bikes
         */
        uint256 count = 0;
        for (uint256 i = 0; i < totalBikes; i++) {
            if (bikes[i].currentRenter == msg.sender) {
                count++;
            }
        }
        uint256[] memory result = new uint256[](count);
        count = 0;
        for (uint256 i = 0; i < totalBikes; i++) {
            if (bikes[i].currentRenter == msg.sender) {
                result[count] = bikes[i].id;
                count++;
            }
        }
        return result; 
    }
}




