# Leitner Learning System

This project was developed in Elixir and Phoenix.

The baseUrl of the api is http://localhost:4000/api

You can generate a openapi.json file by running the following command:

```bash
mix openapi.spec.json --spec LeitnerWeb.ApiSpec
```

Or you can use the one provided in the root of the project, it should be the up to date.

## Installation and Setup

### Prerequisites

- [Elixir](https://elixir-lang.org/install.html)
- [Phoenix](https://hexdocs.pm/phoenix/installation.html)
- [PostgreSQL](https://www.postgresql.org/download/)
- [Node.js](https://nodejs.org/en/download/)

Follow these steps to set up the Leitner Learning System locally:

1. **Clone the repository:**

   ```bash
   git clone https://github.com/adia-dev/leitner-ex.git
   ```

2. **Install dependencies:**

   ```bash
   mix deps.get
   ```

3. **Set up the database:**

   ```bash
   mix ecto.reset
   ```

4. **Start the server:**
   ```bash
   mix phx.server
   ```
   You can now access the system at [`localhost:4000`](http://localhost:4000).

## Features

- **Authentication**: Login to access personalized flashcards.
- **Flashcard Creation**: Users can create flashcards that enter the system at category 1.
- **Spaced Repetition**: Flashcards move between categories based on user's self-assessment, implementing spaced repetition for efficient learning.
- **Daily Quizzes**: Limit of one quiz per day to ensure effective learning pace.
- **Response Comparison**: Users can compare their answers to the correct ones for incorrect responses.
- **Override Validation**: Option to force validation of a flashcard to account for minor discrepancies in wording.
- **Tagging System**: Users can tag flashcards for organized study topics and easier retrieval.

## Running Tests

To run tests and view test coverage:

```bash
mix test
```

## Architecture

This project is designed with Hexagonal Architecture to separate core logic from external concerns like UI and database. It adheres to DDD principles for modeling complex business domains. The architecture schema included in the repository outlines the structure and interaction between components.

The important modules are:

- **LeitnerWeb**: Contains the Phoenix web server and API endpoints.
- **LeitnerWeb.Clients.Cards.ApiClient**: Handles communication with the Cards API.
- **Leitner.Cards**: Core logic for flashcard management and spaced repetition.

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the project.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -am 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

## Bonus Features

- **Adaptive Spaced Repetition**: Adjusts flashcard repetition schedule based on the last response date to optimize memory retention.
- **End-to-End Testing**: Includes a scenario for creating flashcards, detailed in Gherkin syntax, with instructions for running tests using technologies like Playwright.

## License

Distributed under the MIT License. See `LICENSE` for more information.
