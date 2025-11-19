# Composite Palindrome

## 🎯 Objective
The goal of this task is to identify the longest palindrome that can be formed by concatenating a **subsequence** of strings from a given input array. If multiple composite palindromes share the maximum length, the solution must return the one that is **lexicographically smallest**.

## ⚙️ Task Breakdown

The problem is divided into two specific subtasks:

### Subtask 1: Palindrome Check
* **Function Signature:** `int check_palindrome(const char * const str, const int len)`
* **Description:** Implement a utility function that verifies if a given string is a palindrome (reads the same forwards and backwards).
* **Return:** `1` if true, `0` otherwise.

### Subtask 2: Composite Palindrome Finder
* **Function Signature:** `char * const composite_palindrome(const char * const * const strs, const int len)`
* **Description:** Implement the main logic to generate the target palindrome. The function receives an array of strings (words). It must select a subsequence of these words (maintaining their relative order from the original array) such that their concatenation forms a palindrome.
* **Criteria:**
    1.  **Maximize Length:** The resulting string must be the longest possible palindrome.
    2.  **Minimize Lexicographical Order:** In case of length ties, the alphabetically smallest string is chosen.
* **Memory Management:** The returned string must be dynamically allocated on the **heap**.

## 🚀 Constraints & Logic
* **Input Size:** The input array contains up to 15 words (`len = 15`).
* **Word Length:** Each word has a maximum length of 10 characters.
* **Alphabet:** For Subtask 2, words consist only of characters `'a'` and `'b'`.
* **Subsequence Definition:** Elements selected for the palindrome do not need to be consecutive in the original array, but their relative indices must be strictly increasing ($i_0 < i_1 < ... < i_k$).
