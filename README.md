# Asset Tracker 📈

Tracking assets lots sales and purchases with [FIFO (First-In-First-Out)](https://en.wikipedia.org/wiki/FIFO_and_LIFO_accounting#FIFO_principle) procedure while having gain or loss predictions made easy. 😌👌🏻

## Project Goal

The primary objective of the Asset Tracker project is to provide a robust and efficient system for tracking assets lots, focusing on the FIFO calculation method for purchases and sales of assets. This project is evaluated based on its adherence to best practices, the efficiency of its algorithms, and its usability.

## Installation

For this project you'll need [Elixir](https://elixir-lang.org/install.html), [Phoenix](https://www.phoenixframework.org/) and Postgres on your machine.

PS: *If you don't want to install postgres locally, this project provides a `docker-compose.yml` file for setting up database on docker, all you need to do is type: `docker-composer up -d` in the root dir of the project, and voila!*

To get started with the Asset Tracker, you need to install the project dependencies first.

Clone the repository:

``` bash
git clone https://github.com/your-repo-link/asset-tracker.git
```

Inside the project root dir, install dependencies:

``` bash
mix deps.get
```

Set up the database:

``` bash
mix ecto.setup
````

Since our project is just a microservice, we just need to start the Phoenix server in iteractive mode with the command below to start using it:

``` bash
iex -S mix
```

Easy peasy! ✨

## Highlights

This projects uses he best practices regarding performance and pure functional programming paradigm, such as:

**1. Tail Call Optimization (TCO) 🚀**
To ensure our system's efficiency, we've implemented a TCO approach, especially for the FIFO calculation method. With TCO, our recursive function calls won't exhaust the stack, even for large datasets, making our application scalable and robust.

**2. Functional Paradigm 💻**
Elixir, being a functional language, encourages immutability and stateless operations. We've harnessed the power of functional programming throughout the project, which results in code that's easier to read, test, and maintain.

**3. Side Effect-Free Functions 💊**
We prioritize pure functions, minimizing side effects for predictability and reliability. This makes our code more consistent and easier to test and debug.

**Bonus 🆙**
The tech stack of **Elixir**, **Phoenix** and **Postgres** was used thinking on scalability and maintainability of the codebase in the long run.

**Everything was built using the **TDD** approach and the whole code is 100% covered with tests and cutting edge tech.🔪**

## Running Tests

Our project is not just developed using the Test-Driven Development (TDD) strategy; it also boasts a 100% test coverage.

**To run the tests:**

``` bash
mix test
```

**Test Coverage**

To check the test coverage, use:

``` bash
mix coveralls
```

You'll be presented with a comprehensive report, showcasing the test coverage for each module and function, such as the one bellow:

```bash
.........................
Finished in 0.4 seconds (0.4s async, 0.00s sync)
25 tests, 0 failures

Randomized with seed 987340
----------------
COV    FILE                                        LINES RELEVANT   MISSED
100.0% lib/asset_tracker.ex                          306       54        0
100.0% lib/asset_tracker/assets.ex                   146       10        0
100.0% lib/asset_tracker/assets/asset.ex              24        2        0
100.0% lib/asset_tracker/assets/purchase.ex           22        2        0
100.0% lib/asset_tracker/assets/sale.ex               22        2        0
100.0% lib/asset_tracker/mailer.ex                     3        0        0
100.0% lib/asset_tracker/repo.ex                       5        0        0
[TOTAL] 100.0%
----------------
```
