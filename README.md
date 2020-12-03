# MLM_test
Test task for Roman

## Setup Flow
- clone the proj
- npm i
- Remix + remixd is the easiest to test

## Usage Flow
- deploy MLM_Contract (array with percentages)
- deploy MLM_Token (MLM_Contract address, tokens to mint to sender)
- updateMLMToken (MLM_Token address)
- test

## Tasks
- [x] Create the simple referral smart contract to reward users with referral commission in ERC-20 token.
- [x] - fee can receive only 3 parents in the top from the referee.
- [x] - there could be provided exact referral percent for each referral level.
- [x] - each parent receives the reward according to the percentage rate for his level.
- [ ] - referral doesn't receive the reward if his level is less than referrer's.
- [x] The maximum level amount is 7.
- [x] Address to the levels can be set manually by permitted address.
- [x] Basically, if I invite you, I am your parent.

## Important
- no unit tests
- I did smoke testing (few minutes to test)
