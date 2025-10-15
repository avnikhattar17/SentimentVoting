// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Sentiment-influenced Voting (no imports, no constructor, no input fields)
/// @notice Three hardcoded candidates. Sentiment is updated by owner (acting as an oracle) via parameterless calls.
///         Vote weight = baseWeight + sentimentBonus where sentimentBonus depends on the sentiment score at vote time.
///         Sentiment decays over time to keep influence "real-time".
contract SentimentVoting {
    // --- Basic config / state ---
    address public owner = msg.sender;         // set at declaration (no constructor)
    bytes32[] public candidates;               // hardcoded candidate names
    mapping(bytes32 => uint256) public votes;  // raw sum of weighted votes per candidate
    mapping(address => bool) public hasVoted;  // one vote per address (across all candidates)

    // --- Sentiment state ---
    int256 public sentimentScore = 0;          // can be negative/positive
    uint256 public lastSentimentUpdate = block.timestamp;
    int256 public constant MAX_SENTIMENT = 100;   // saturation
    int256 public constant MIN_SENTIMENT = -100;  // saturation
    uint256 public constant DECAY_PER_SECOND = 1; // amount sentiment decays per second (as integer units)

    // --- Events ---
    event VoteCasted(address indexed voter, bytes32 indexed candidate, uint256 weight, int256 sentimentAtVote);
    event SentimentIncreased(int256 newSentiment);
    event SentimentDecreased(int256 newSentiment);
    event SentimentReset(int256 newSentiment);

    // --- Modifiers ---
    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    modifier notVoted() {
        require(!hasVoted[msg.sender], "already voted");
        _;
    }

    // --- Initialize candidates without constructor by using a deployment-time constant block ---
    // Hardcode three candidates
    // Note: writing directly to storage at declaration of dynamic arrays isn't allowed,
    // so we push in an initialization function that anyone can call once. To avoid external inputs,
    // we rely on a one-time `initialize()` call without parameters.
    bool public initialized = false;
    function initialize() public {
        require(!initialized, "already initialized");
        // candidate names (bytes32 to keep gas low)
        candidates.push("Alice");
        candidates.push("Bob");
        candidates.push("Carol");
        initialized = true;
    }

    // --- Sentiment helpers (all parameterless as requested) ---
    // These simulate an oracle updating sentiment in realtime by calling increment/decrement steps.
    function increaseSentiment() external onlyOwner {
        _applyDecay();
        if (sentimentScore < MAX_SENTIMENT) {
            sentimentScore += 1;
            if (sentimentScore > MAX_SENTIMENT) sentimentScore = MAX_SENTIMENT;
        }
        lastSentimentUpdate = block.timestamp;
        emit SentimentIncreased(sentimentScore);
    }

    function decreaseSentiment() external onlyOwner {
        _applyDecay();
        if (sentimentScore > MIN_SENTIMENT) {
            sentimentScore -= 1;
            if (sentimentScore < MIN_SENTIMENT) sentimentScore = MIN_SENTIMENT;
        }
        lastSentimentUpdate = block.timestamp;
        emit SentimentDecreased(sentimentScore);
    }

    function resetSentiment() external onlyOwner {
        sentimentScore = 0;
        lastSentimentUpdate = block.timestamp;
        emit SentimentReset(sentimentScore);
    }

    // Internals: apply simple time-based decay towards zero to keep sentiment "fresh"
    function _applyDecay() internal {
        uint256 nowTs = block.timestamp;
        uint256 elapsed = nowTs - lastSentimentUpdate;
        if (elapsed == 0) return;

        // total decay amount (as integer)
        uint256 totalDecay = elapsed * DECAY_PER_SECOND;

        if (sentimentScore > 0) {
            int256 dec = int256(totalDecay);
            if (dec >= sentimentScore) sentimentScore = 0;
            else sentimentScore -= dec;
        } else if (sentimentScore < 0) {
            int256 dec = int256(totalDecay);
            if (dec >= -sentimentScore) sentimentScore = 0;
            else sentimentScore += dec;
        }
        lastSentimentUpdate = nowTs;
    }

    // --- Voting (parameterless per your requirement) ---
    // One vote total per address. Each vote has a dynamic weight derived from sentimentScore at vote time.
    // Separate functions for each candidate to avoid input parameters.
    function voteAlice() external notVoted {
        _internalVote(0);
    }

    function voteBob() external notVoted {
        _internalVote(1);
    }

    function voteCarol() external notVoted {
        _internalVote(2);
    }

    // Internal vote logic
    function _internalVote(uint256 candidateIndex) internal {
        require(initialized, "not initialized");
        require(candidateIndex < candidates.length, "invalid candidate");

        _applyDecay(); // ensure sentiment reflects up-to-date state
        uint256 weight = _computeWeight(sentimentScore);
        bytes32 name = candidates[candidateIndex];

        votes[name] += weight;
        hasVoted[msg.sender] = true;

        emit VoteCasted(msg.sender, name, weight, sentimentScore);
    }

    // Compute vote weight (no external inputs). Design: baseWeight 1, positive sentiment gives bonus,
    // negative sentiment reduces bonus but never below 1. We also cap bonus.
    function _computeWeight(int256 sentiment) internal pure returns (uint256) {
        uint256 base = 1;
        uint256 bonus = 0;

        if (sentiment > 0) {
            // for every 5 sentiment units => +1 bonus, capped
            bonus = uint256(sentiment) / 5;
            if (bonus > 10) bonus = 10; // cap bonus to avoid extreme weights
        } else if (sentiment < 0) {
            // negative sentiment reduces bonus (but voting weight remains at least base)
            uint256 neg = uint256(-sentiment);
            uint256 reduction = neg / 10; // every 10 negative units reduces bonus by 1
            if (reduction > 0) {
                // reduce base + bonus accordingly but never drop below 1
                if (reduction >= base) return 1;
                // if reduction < base, we leave base 1 (so effectively no change)
            }
        }

        return base + bonus;
    }

    // --- Read helpers (no-input getters) ---
    function getCandidateCount() external view returns (uint256) {
        return candidates.length;
    }

    function getCandidateName(uint256 idx) external view returns (bytes32) {
        require(idx < candidates.length, "idx OOB");
        return candidates[idx];
    }

    function getVotesForAlice() external view returns (uint256) {
        return votes["Alice"];
    }

    function getVotesForBob() external view returns (uint256) {
        return votes["Bob"];
    }

    function getVotesForCarol() external view returns (uint256) {
        return votes["Carol"];
    }

    // Helper to peek current effective vote weight if caller were to vote now
    function currentVoteWeight() external view returns (uint256) {
        // Note: view cannot change state; we do not apply decay here to state, but approximate decay
        // by calculating a decayed sentiment locally based on elapsed time since last update.
        uint256 elapsed = block.timestamp - lastSentimentUpdate;
        int256 dec = int256(elapsed * DECAY_PER_SECOND);

        int256 s = sentimentScore;
        if (s > 0) {
            if (dec >= s) s = 0;
            else s = s - dec;
        } else if (s < 0) {
            if (dec >= -s) s = 0;
            else s = s + dec;
        }

        return _computeWeight(s);
    }

    // --- Administrative: transfer ownership (parameterless) ---
    // Because we cannot accept inputs, transfer of ownership is done through a two-step pattern:
    // owner calls proposeNewOwner() -> sets pendingOwner to msg.sender of the call (must be the future owner),
    // then the future owner calls acceptOwnership() to accept. But propose normally needs an address input.
    // To avoid parameters, we provide an owner-only `nominateCallerAsOwner()` which sets pendingOwner to tx.origin.
    // This is unusual but fits the "no input fields" constraint.
    address public pendingOwner;

    function nominateCallerAsOwner() external onlyOwner {
        // nominate the transaction origin as pending owner (careful: tx.origin used intentionally)
        pendingOwner = tx.origin;
    }

    function acceptOwnership() external {
        require(msg.sender == pendingOwner, "not nominated");
        owner = pendingOwner;
        pendingOwner = address(0);
    }

    // --- Fallback / receive (explicitly disabled to avoid accidental ETH deposits) ---
    receive() external payable {
        revert("no payments accepted");
    }

    fallback() external payable {
        revert("fallback not supported");
    }
}
