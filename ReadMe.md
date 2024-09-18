## 🚴‍♂️ Bike Rental Smart Contract

This is a decentralized smart contract for renting bikes using Ethereum blockchain technology. It allows users to rent bikes by paying a deposit, automatically calculates rental fees based on time, and returns the remaining deposit upon the bike's return. Perfect for a decentralized bike-sharing system!

### Key Features

- **Register New Bikes**: Only the owner can register new bikes.
- **Rent a Bike**: Users can rent any available bike with a deposit (minimum 3000 wei).
- **Return the Bike**: Renters can return bikes and get their deposit back minus the rental fee.
- **Track Bike Availability**: View all available bikes that can be rented.
- **Check Rented Bikes**: Renters can see which bikes they've rented, and the owner can view all rented bikes.

### How It Works

- [x] **Deposit**: To rent a bike, users need to deposit at least 3000 wei.
- [x] **Distance Calculation**: The contract generates a random distance between 50 to 100 units when the bike is returned.
- [x] **Rental Fee**: The rental fee is calculated based on time, using a randomly determined rate per minute (between 1 to 5 wei), plus a base fee of 1 wei.
- **Speed Calculation**: The average speed of the bike is also calculated after return, adding a fun element to the rental experience.

### Testing

- [x] Tested on the **Sepolia Test Network** using **Remix IDE** for contract deployment and **MetaMask** for transactions.

### Core Functions

| Function              | How It Works                                                                                                                                                         |
|-----------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `rentBike(bikeId)`    | Rent a bike by providing its `bikeId`. A deposit of at least 3000 wei is required.                                                                                     |
| `returnBike(bikeId)`  | Return the bike with the given `bikeId`. The contract deducts the rental fee and refunds the remaining deposit. It also calculates the average speed of the bike.     |
| `getAvailableBikes()` | Returns a list of all bikes that are available for rent.                                                                                                              |
| `getMyrentedBikes()`  | Allows the current user to view the list of bikes they've rented.                                                                                                      |
| `getAllRentedBikes()` | Allows the owner to view a list of all rented bikes.                                                                                                                  |
| `registerBike()`      | Registers a new bike in the system. This function can only be called by the owner.                                                                                     |

## Usage Example

- Deploy the contract with an initial number of bikes (e.g., `constructor(numberOfBikes)`).
- Rent a bike using `rentBike(bikeId)` and deposit the required amount.
- Return the bike with `returnBike(bikeId)` to receive the remaining deposit minus the rental fee.

