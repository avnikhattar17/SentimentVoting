# SentimentVoting- .sol
This project implements a decentralized voting system in Solidity where real-time sentiment analysis influences the weight of each vote. Unlike traditional voting where every vote carries equal value, this system adjusts vote weight dynamically based on a continuously updated sentiment score that reflects public mood or market trends.

The sentiment score acts as a real-time parameter that changes through oracle-like updates — simulating how collective public sentiment can amplify or diminish the impact of votes. For instance, during positive sentiment, votes carry higher weight, while negative sentiment reduces their influence.

0xA6aB8F707006ef5385802D890D1e0C0C732DABe6

# 🗳️ Sentiment-Influenced Voting System (Flow Blockchain)

A **decentralized sentiment-based voting system** built on the **Flow Blockchain**, where **real-time sentiment analysis** influences the weight of each vote.  
Each vote’s impact dynamically adjusts according to changing public sentiment — simulating real-world social influence in decision-making.

---

## 🚀 Overview

This smart contract introduces a unique concept:  
> **Voting influenced by sentiment rather than equality.**

Each voter can cast a single vote for a candidate, but the *weight* of that vote changes in real time depending on the current **sentiment score**, which can be updated by the contract owner (or an off-chain sentiment oracle).

Positive sentiment increases vote weight, while negative sentiment reduces it.  
Sentiment automatically decays over time to ensure the voting system reflects *real-time mood*.

---

## 🧱 Built On

- **Blockchain:** [Flow Testnet](https://testnet.flow.com/)
- **Smart Contract Language:** Solidity (Flow-compatible wrapper or hybrid deployment)
- **Sentiment Mechanism:** On-chain weighted scoring logic  
- **Interaction Mode:** No imports, no constructors, no input fields — parameterless and self-contained design.

---

## 📜 Testnet Contract

> **Deployed Contract Address:**  
> `0xA6aB8F707006ef5385802D890D1e0C0C732DABe6`

You can view and interact with the contract using the Flow Testnet explorer.

---

## 🔗 Contract Addresses (Deployed / Used)

| Contract / Component          | Purpose                              | Network | Address |
|-------------------------------|--------------------------------------|----------|---------------------------------------------|
| `SentimentVoting`             | Core voting logic (sentiment-based)  | Flow Testnet | `0xA6aB8F707006ef5385802D890D1e0C0C732DABe6` |
| `VotingOracle` *(optional)*   | Simulates real-time sentiment updates | Flow Testnet | `0xCF34B01A2179bBaB074D46Ea53f9D2eC584bD7A1` |
| `VoteDataFeed` *(optional)*   | External feed mock for testing        | Flow Testnet | `0xE1D76bE479C2374FdF10486Df6Bb40395e08A2C5` |

> 💡 *Note: Secondary contract addresses are for mock or test integration — may vary across redeployments.*

---

## ⚙️ Features

- ✅ **Dynamic Vote Weight:** Vote strength adapts to sentiment score.  
- 🕒 **Real-Time Decay:** Sentiment influence weakens automatically over time.  
- 🧍 **Single-Vote Enforcement:** Prevents multiple votes by the same address.  
- 🔐 **Oracle-Controlled Updates:** Only owner can adjust sentiment levels.  
- ⚡ **Parameterless Design:** No function requires input fields, constructors, or imports.

---

## 📘 Core Functions

| Function | Description |
|-----------|--------------|
| `increaseSentiment()` | Increases global sentiment score by +1 |
| `decreaseSentiment()` | Decreases global sentiment score by -1 |
| `resetSentiment()` | Resets sentiment score to neutral (0) |
| `voteAlice()` / `voteBob()` / `voteCarol()` | Parameterless vote functions for each candidate |
| `getVotesForAlice()` / `getVotesForBob()` / `getVotesForCarol()` | View total votes for each candidate |
| `currentVoteWeight()` | Check what your vote weight would be if you voted now |

---

## 🧩 Use Cases

- **DAO Governance Systems** – sentiment-weighted community decisions  
- **Social Platforms** – integrating public emotion into polls  
- **Market or Trend Predictions** – reflecting collective confidence dynamically  

---

## 🧠 Future Enhancements

- Integration with real-time **AI sentiment APIs** (e.g., Twitter, news, or token data)  
- Multi-round or category-based voting sessions  
- Off-chain to on-chain sentiment oracle using Flow Cadence script  

---

## 👩‍💻 Author

**Avni Khattar**  
B.Tech CSE | Blockchain & Smart Contract Developer  
*Project built for learning and experimentation with Flow Testnet deployments.*

---

## 🪪 License

This project is licensed under the **MIT License**.  
Feel free to use, modify, and build upon it with proper attribution.

---
