# Rails Application Development Workflow

This document provides step-by-step instructions for developing a Rails application.
When suggest the `Commit the step` and `Test the step` do not group with other commands sequences.

## Rails Setup

All Rails apps will be created under the `src` folder. Replace `<project-folder>` with your desired app name.

- To create a **Standard Rails** app:
  `rails new <project-folder> --skip-test`
- To create a **Minimal Rails** app with minimal configuration:**  
  `rails new <project-folder> --minimal --skip-test`
- To create a **Rails API** app:**  
  `rails new <project-folder> --api --skip-test --skip-active-storage --skip-action-mailbox --skip-action-text --skip-action-cable --skip-sprockets --skip-turbolinks --skip-webpacker --skip-spring --skip-system-test --skip-kamal --skip-solid`
- Navigate to the project directory: `cd <project-folder>`
- Install dependencies: `bundle install`
- Test the step: `bin/dev`
- Commit the step:
  ```sh
    gh repo create enogrob/<project-folder> --private
    git init
    git status
    git add .
    git commit -m "rails-setup"
    git remote add origin git@github.com:enogrob/<project-folder>.git
    git branch -M main
    git push -u origin main
    git --no-pager log --oneline
  ```

## Rspec Setup

- Add `rspec-rails` to Gemfile:
  ```sh
    bundle add rspec-rails --group="development,test"
    bundle install
  ```
- Rspec install:
  ```sh
    rails generate rspec:install
    echo "--format documentation" >> .rspec
  ```
- Test the step:
  ```sh
    bundle exec rspec
  ```
- Commit the step:
  ```sh
   git status
   git add .
   git commit -m "setup-rspec"
   git push
   git --no-pager log --oneline
  ```

## Setup Test Coverage

- Add to Gemfile:
  ```sh
  bundle add simplecov --group="test"
  bundle install
  ```
- Then add to `spec/rails_helper.rb`:
  ```ruby
  require 'simplecov'
  SimpleCov.start
  ```
- Update `.gitignore`:
  ```sh
  echo "coverage/" >> .gitignore
  ```
- Accomplish 100% of test coverage for the unit, functional and integration tests. 
- Test the step:
  ```sh
  bundle exec rspec
  open coverage/index.html
  ```
- Commit the step
  ```sh
  git status
  git add .
  git commit -m "setup-simplecov"
  git push
  git --no-pager log --oneline
  ```

## Add Models
 
 Add or generate the required models. If generate skip the generation of the test files.

**Specification:**
- Models should encapsulate data and business rules related to a single entity.
- Keep models focused on persistence and validation logic.
- Avoid placing complex business logic in models; use service objects for that.
- **Separate business logic from the HTTP transport layer:**  
  Models should not handle HTTP requests or responses. Controllers and routes are responsible for HTTP, while models manage data and validation.
- Example:
  ```ruby
  class User < ApplicationRecord
    validates :email, presence: true, uniqueness: true
    has_secure_password
    # Keep model methods simple and related to data
  end
  ```
- Commit the step:
  ```sh
  git status
  git add .
  git commit -m "add-models"
  git push
  git --no-pager log --oneline
  ```
  
## Setup Services

Use a service object when the action spans multiple models, invokes external APIs or other side effects (emails, jobs, events), involves complex branching logic or a DB transaction that must succeed or roll back as a unit, or must be reused from multiple entry points (controller, job, rake task, console). Keep it out of a service if it is simple, single-model CRUD or a brief query + render. Each service should be cohesive and represent one clear domain action, exposing a simple call interface and centralizing error handling.

**Specification:**
- Implement business logic in service objects (plain Ruby classes).
- Service objects should not depend on controller or HTTP context.
- Example:
  ```ruby
  class UserRegistrationService
    def self.call(params)
      # business logic here
    end
  end
  ```
- Create the file for the underlying services created e.g.
```sh
touchfile app/services/user_registration_service.rb
```
- Commit the step:
  ```sh
  git status
  git add .
  git commit -m "setup-services"
  git push
  git --no-pager log --oneline
  ```

## Add Controllers

Add or generate the required controllers. If generate skip the generation of the test files.

**Specification:**
- Keep controllers focused on handling HTTP requests and responses.
- Delegate business logic to Service objects or models.
- Example:
  ```ruby
  # In controller
  def create
    result = UserRegistrationService.call(user_params)
    if result.success?
      render json: result.user
    else
      render json: result.errors
    end
  end
  ```
- Commit the step:
  ```sh
  git status
  git add .
  git commit -m "add-controllers"
  git push
  git --no-pager log --oneline
  ```

## Add Routes
- Add required routes
- Commit the step:
  ```sh
  git status
  git add .
  git commit -m "add-routes"
  git push
  git --no-pager log --oneline
  ```

## Setup Sidekiq and Redis 

- Add gems to your Gemfile:
  ```sh
  bundle add sidekiq
  bundle add redis
  bundle install
  ```
- Create a Sidekiq configuration file at `config/sidekiq.yml`:
  ```sh
  touchfile config/sidekiq.yml
  ```
  ```yaml
  :concurrency: 5
  :queues:
    - default
  ```
- Update `config/application.rb` to require Sidekiq:
  ```ruby
  require "sidekiq"
  ```
- Configure Sidekiq in `config/routes.rb` (optional, for web UI):
  ```ruby
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  ```
- Set up Redis connection in `config/initializers/sidekiq.rb`:
  ```ruby
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
  end
  Sidekiq.configure_client do |config|
    config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
  end
  ```
- Start Redis server (if not running):
  ```sh
  brew services list
  brew install redis
  brew services start redis
  ```

- Start Sidekiq:
  ```sh
  bundle exec sidekiq
  ```

- Example job (`app/jobs/example_job.rb`):
  ```ruby
  class ExampleJob
    include Sidekiq::Job

    def perform(*args)
      # job logic here
    end
  end
  ```

- Commit the step:
  ```sh
  git status
  git add .
  git commit -m "setup-sidekiq-and-redis"
  git push
  git --no-pager log --oneline
  ```

## Add Unit, Functional and Integration Tests
- Write tests for all new features and bug fixes in order to reach 100% of test coverage.
- Use descriptive test names and keep tests isolated.

### Add Unit Tests
- **Unit Tests:**  
  Focus on testing individual methods or classes in isolation.  
  Example:  
  ```ruby
  # spec/models/user_spec.rb
  describe User do
    it "validates presence of email" do
      user = User.new(email: nil)
      expect(user).not_to be_valid
    end
  end
  ```
- Create the file for the underlying spec created e.g.
```sh
touchfile spec/models/user_spec.rb
```
- Test the step:  
  ```sh
  bundle exec rspec
  ```
- Commit your tests:
  ```sh
  git status
  git add .
  git commit -m "add-unit-tests"
  git push
  git --no-pager log --oneline
  ```

### Add Functional Tests
- **Functional Tests:**  
  Test controller actions and their responses.  
  Example:  
  ```ruby
  # spec/controllers/users_controller_spec.rb
  describe UsersController, type: :controller do
    it "creates a user" do
      post :create, params: { user: { email: "test@example.com", password: "password" } }
      expect(response).to have_http_status(:created)
    end
  end
  ```
- Create the file for the underlying spec created e.g.
```sh
touchfile spec/controllers/users_controller_spec.rb
```
- Test the step:  
  ```sh
  bundle exec rspec
  ```
- Commit your tests:
  ```sh
  git status
  git add .
  git commit -m "add-functional-tests"
  git push
  git --no-pager log --oneline
  ```

### Add Integration Tests
- **Integration Tests:**  
  Test multiple components working together, simulating real user flows.  
  Example:  
  ```ruby
  # spec/requests/user_registration_spec.rb
  describe "User registration", type: :request do
    it "registers a new user" do
      post "/users", params: { user: { email: "test@example.com", password: "password" } }
      expect(response.body).to include("test@example.com")
    end
  end
  ```
- Create the file for the underlying spec created e.g.
```sh
touchfile spec/requests/user_registration_spec.rb
```
- Test the step:  
  ```sh
  bundle exec rspec
  ```
- Commit your tests:
  ```sh
  git status
  git add .
  git commit -m "add-integration-tests"
  git push
  git --no-pager log --oneline
  ```


## Setup Rubocop

- Add rubocop gems to Gemfile:
  ```sh
  bundle add rubocop --group="development"
  bundle add rubocop-rails --group="development"
  bundle add rubocop-rspec --group="development"
  bundle install
  ```
- Generate rubocop configuration:
  ```sh
  bundle exec rubocop --init
  ```
- Update `.rubocop.yml` with basic configuration:
  ```yaml
  require:
    - rubocop-rails
    - rubocop-rspec
  
  AllCops:
    NewCops: enable
    TargetRubyVersion: 3.1
    Exclude:
      - 'bin/**/*'
      - 'db/schema.rb'
      - 'db/migrate/**/*'
      - 'vendor/**/*'
      - 'node_modules/**/*'
  
  Style/Documentation:
    Enabled: false
  
  Metrics/BlockLength:
    Exclude:
      - 'spec/**/*'
      - 'config/routes.rb'
  ```
- Run rubocop to check code style:
  ```sh
  bundle exec rubocop
  ```
- Auto-correct safe offenses:
  ```sh
  bundle exec rubocop -a
  ```
- Test the step:
  ```sh
  bundle exec rubocop
  ```
- Commit the step:
  ```sh
  git status
  git add .
  git commit -m "setup-rubocop"
  git push
  git --no-pager log --oneline
  ```

## Setup OpenAPI/Swagger

- Add swagger gems to Gemfile:
  ```sh
  bundle add rswag --group="development"
  bundle add rswag-api --group="development"
  bundle add rswag-ui --group="development"
  bundle add rswag-specs --group="development,test"
  bundle install
  ```
- Generate rswag configuration:
  ```sh
  rails generate rswag:install
  ```
- Update `config/initializers/rswag_api.rb`:
  ```ruby
  Rswag::Api.configure do |c|
    c.swagger_root = Rails.root.to_s + '/swagger'
  end
  ```
- Update `config/initializers/rswag_ui.rb`:
  ```ruby
  Rswag::Ui.configure do |c|
    c.swagger_endpoint '/api-docs/v1/swagger.yaml', 'API V1 Docs'
  end
  ```
- Update `spec/swagger_helper.rb` with basic configuration:
  ```ruby
  RSpec.configure do |config|
    config.swagger_root = Rails.root.join('swagger').to_s
    config.swagger_docs = {
      'v1/swagger.yaml' => {
        openapi: '3.0.1',
        info: {
          title: 'API V1',
          version: 'v1'
        },
        paths: {},
        servers: [
          {
            url: 'http://localhost:3000',
            description: 'Development server'
          }
        ]
      }
    }
    config.swagger_format = :yaml
  end
  ```
- Add routes to `config/routes.rb`:
  ```ruby
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  ```
- Create swagger directory:
  ```sh
  mkdir -p swagger/v1
  ```
- Generate swagger documentation:
  ```sh
  bundle exec rake rswag:specs:swaggerize
  ```
- Test the step:
  ```sh
  rails server
  open http://localhost:3000/api-docs
  ```
- Commit the step:
  ```sh
  git status
  git add .
  git commit -m "setup-openapi-swagger"
  git push
  git --no-pager log --oneline
  ```

## Setup Docker and Docker Compose

- Create Dockerfile in the root directory:
  ```sh
  touch Dockerfile
  ```
- Create docker-compose.yml with Rails and database services:
  ```sh
  touch docker-compose.yml
  ```
- Create .dockerignore to exclude unnecessary files:
  ```sh
  touch .dockerignore
  ```
- Update database.yml for Docker environment configuration
- Build and start containers:
  ```sh
  docker-compose build
  docker-compose up -d
  ```
- Setup database in containers:
  ```sh
  docker-compose exec web rails db:create
  docker-compose exec web rails db:migrate
  ```
- Test the step:
  ```sh
  docker-compose ps
  curl http://localhost:3000
  ```
- Commit the step:
  ```sh
  git status
  git add .
  git commit -m "setup-docker-and-docker-compose"
  git push
  git --no-pager log --oneline
  ```

## Setup Ngrok
- Install ngrok (if not already installed):
```sh
   brew install ngrok
```
- Allow all ngrok domains in `config/development.rb`:
```ruby
require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.hosts << /[a-z0-9-]+\.ngrok(-free)?\.app/
```
- Expose your local server with ngrok:
```sh
  ngrok http 3000
```
- Commit the step
```sh
git status
git add .
git commit -m "setup-ngrok"
git push
git --no-pager log --oneline
```

## Architectural Guidelines (from "Layered Design for Ruby on Rails")

- Structure your Rails app using layers: Controllers (HTTP), Services (business logic), Models (data), Presenters/Decorators (view logic).
- Keep controllers thin; delegate business logic to service objects e.g. make use of Service patterns if applied.
- Use policies for authorization logic.
- Use presenters/decorators for formatting data for views.
- Organize code for clarity, maintainability, and testability.
- Use the Repository pattern (if applied) to centralize complex querying/persistence concerns behind a small interface, reduce ActiveRecord coupling in services, improve testability (mock repositories), and prepare for alternative data sources.
- Use Value Objects for immutable domain concepts (money, distance, dates range) instead of primitive types scattered across code.
- Use Form Objects (or Command Objects) to handle complex multi-attribute validation spanning multiple models.
- Use Query Objects (or repository/query classes) for complex, composable read queries to keep models skinny.
- Encapsulate transactions inside services; expose a clear success/failure Result object (success?, value, errors).
- Prefer dependency injection (pass collaborators) over hard-coded constants to ease testing and decouple layers.
- Keep domain logic free of framework dependencies (plain POROs) to enable easier refactoring and testing.
- Use domain events (publish/subscribe) for decoupled side effects (notifications, analytics, projections).
- Apply consistent error handling strategy: raise domain-specific errors, map to HTTP codes at controller/presenter layer.
- Enforce idempotency for operations triggered by retries, webhooks, or background jobs (idempotency keys, locks).
- Define clear module namespaces (e.g., Billing::, Auth::) to group related services, models, and policies.
- Centralize authorization checks (e.g., Pundit/Policy objects) and never duplicate permission logic in views/controllers.
- Define caching strategy (object caching, fragment caching, query caching) with explicit invalidation rules.
- Apply configuration management: ENV-backed settings, no secrets in code, use Rails credentials for sensitive data.
- Establish observability: structured logging, metrics (timings, counts), tracing for external calls, correlation IDs.
- Standardize input validation layers: transport (strong params), domain (models/services), persistence (DB constraints).
- Secure by default: parameter whitelisting, output escaping, avoid dynamic constantization, audit mass-assignment.
- Plan API versioning early (namespaced controllers or Accept header negotiation) to allow backward-compatible evolution.
- Use feature flags for gradual rollout and experiment gating; remove stale flags promptly.
- Support internationalization (I18n) for user-facing strings; avoid hard-coded text in models/services.
- Document architectural decisions (ADRs) for significant trade-offs (storage choice, background processing, patterns).
- Maintain a testing strategy: unit (fast, isolated), service/integration (critical flows), request/API, system/end-to-end.
- Track performance budgets (DB queries per request, response time SLOs) and profile hotspots proactively.
- Avoid premature generalization: extract abstractions only after duplication is clear (rule of three).
- Keep migrations reversible and small; avoid locking tables for long-running data changes (use batched migrations).
- Use background jobs for non-blocking, latency-tolerant work; ensure retries and dead-letter handling.
- Prefer explicit serialization (serializers/presenters) over rendering ActiveRecord objects directly in APIs.
- Define consistent naming conventions for services (VerbNounService or Noun::Action) and result objects.
- Periodically prune unused code (dead services, queries, feature flags) to reduce cognitive load.


