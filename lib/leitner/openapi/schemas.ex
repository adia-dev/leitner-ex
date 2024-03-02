defmodule LeitnerWeb.Schemas do
  alias OpenApiSpex.Schema

  defmodule User do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "User",
      description: "A user of the Leitner system",
      type: :object,
      properties: %{
        id: %Schema{type: :string, description: "User ID", format: :uuid},
        email: %Schema{type: :string, description: "Email address", format: :email},
        firstname: %Schema{type: :string, description: "First name"},
        lastname: %Schema{type: :string, description: "Last name"},
        username: %Schema{
          type: :string,
          description: "Username",
          pattern: ~r/^[^\s]+$/ |> Regex.source(),
          maxLength: 24
        },
        private: %Schema{type: :boolean, description: "Privacy setting"},
        confirmed_at: %Schema{
          type: :string,
          description: "Confirmation timestamp",
          format: :"date-time"
        },
        inserted_at: %Schema{
          type: :string,
          description: "Creation timestamp",
          format: :"date-time"
        },
        updated_at: %Schema{
          type: :string,
          description: "Update timestamp",
          format: :"date-time"
        }
      },
      required: [:email, :firstname, :lastname, :username],
      example: %{
        "id" => "123e4567-e89b-12d3-a456-426614174000",
        "email" => "jane.doe@example.com",
        "firstname" => "Jane",
        "lastname" => "Doe",
        "username" => "jane_doe",
        "private" => false,
        "confirmed_at" => "2021-01-01T12:00:00Z",
        "inserted_at" => "2021-01-01T12:00:00Z",
        "updated_at" => "2021-01-02T12:00:00Z"
      }
    })
  end

  defmodule UserResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "UserResponse",
      description: "Response schema for a single user",
      type: :object,
      properties: %{
        data: User
      },
      example: %{
        "data" => %{
          "id" => "123e4567-e89b-12d3-a456-426614174000",
          "email" => "jane.doe@example.com",
          "firstname" => "Jane",
          "lastname" => "Doe",
          "username" => "jane_doe",
          "private" => false,
          "confirmed_at" => "2021-01-01T12:00:00Z",
          "inserted_at" => "2021-01-01T12:00:00Z",
          "updated_at" => "2021-01-02T12:00:00Z"
        }
      }
    })
  end

  defmodule UserCreateRequest do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "UserCreateRequest",
      description: "Schema for user creation request",
      type: :object,
      properties: %{
        email: %Schema{type: :string, description: "Email address", format: :email},
        firstname: %Schema{type: :string, description: "First name"},
        lastname: %Schema{type: :string, description: "Last name"},
        username: %Schema{
          type: :string,
          description: "Username",
          pattern: ~r/^[^\s]+$/ |> Regex.source(),
          maxLength: 24
        },
        private: %Schema{type: :boolean, description: "Privacy setting"},
        password: %Schema{type: :string, description: "Password"}
      },
      required: [:email, :firstname, :lastname, :username, :password]
    })
  end

  defmodule UserUpdateRequest do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "UserUpdateRequest",
      description: "Schema for user update request",
      type: :object,
      properties: %{
        email: %Schema{
          type: :string,
          description: "Email address",
          format: :email,
          nullable: true
        },
        firstname: %Schema{type: :string, description: "First name", nullable: true},
        lastname: %Schema{type: :string, description: "Last name", nullable: true},
        username: %Schema{
          type: :string,
          description: "Username",
          pattern: ~r/^[^\s]+$/ |> Regex.source(),
          maxLength: 24,
          nullable: true
        },
        private: %Schema{type: :boolean, description: "Privacy setting", nullable: true}
      }
    })
  end

  defmodule Card do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Card",
      description:
        "A flashcard representing a question and answer pair along with categorization.",
      type: :object,
      properties: %{
        id: %Schema{type: :string, description: "Card ID", format: :uuid},
        tag: %Schema{type: :string, description: "Tag associated with the card"},
        category: %Schema{
          type: :string,
          description: "Category of the card",
          enum: ["first", "second", "third", "fourth", "fifth", "sixth", "seventh", "done"]
        },
        question: %Schema{type: :string, description: "The question posed by the card"},
        answer: %Schema{type: :string, description: "The answer to the card's question"},
        inserted_at: %Schema{
          type: :string,
          description: "Creation timestamp",
          format: :"date-time"
        },
        updated_at: %Schema{
          type: :string,
          description: "Update timestamp",
          format: :"date-time"
        }
      },
      required: [:tag, :category, :question, :answer],
      example: %{
        "id" => "456f7890-e89b-12d3-a456-426655440000",
        "tag" => "science",
        "category" => "first",
        "question" => "What is the chemical formula for water?",
        "answer" => "H2O",
        "inserted_at" => "2021-02-01T12:00:00Z",
        "updated_at" => "2021-02-02T12:00:00Z"
      }
    })
  end

  defmodule CardResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "CardResponse",
      description: "Response schema for a single card",
      type: :object,
      properties: %{
        data: Card
      },
      example: %{
        "id" => "456f7890-e89b-12d3-a456-426655440000",
        "tag" => "science",
        "category" => "first",
        "question" => "What is the chemical formula for water?",
        "answer" => "H2O",
        "inserted_at" => "2021-02-01T12:00:00Z",
        "updated_at" => "2021-02-02T12:00:00Z"
      }
    })
  end

  defmodule CardCreateRequest do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "CardCreateRequest",
      description: "Schema for card creation request",
      type: :object,
      properties: %{
        tag: %Schema{type: :string, description: "Tag associated with the card"},
        category: %Schema{
          title: "Category",
          type: :string,
          description: "Initial category of the card",
          enum: ["first", "second", "third", "fourth", "fifth", "sixth", "seventh", "done"]
        },
        question: %Schema{type: :string, description: "The question posed by the card"},
        answer: %Schema{type: :string, description: "The answer to the card's question"}
      },
      required: [:tag, :category, :question, :answer]
    })
  end

  defmodule CardUpdateRequest do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "CardUpdateRequest",
      description: "Schema for card update request",
      type: :object,
      properties: %{
        tag: %Schema{type: :string, description: "Tag associated with the card", nullable: true},
        category: %Schema{
          title: "Category",
          type: :string,
          description: "Category of the card",
          enum: ["first", "second", "third", "fourth", "fifth", "sixth", "seventh", "done"],
          nullable: true
        },
        question: %Schema{
          type: :string,
          description: "The question posed by the card",
          nullable: true
        },
        answer: %Schema{
          type: :string,
          description: "The answer to the card's question",
          nullable: true
        }
      }
    })
  end

  defmodule CardAnswerRequest do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "CardAnswerRequest",
      description: "Schema for card answer request",
      type: :object,
      properties: %{
        isValid: %Schema{type: :boolean, description: "Validity of the answer"}
      }
    })
  end
end
