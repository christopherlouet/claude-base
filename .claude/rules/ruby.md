---
paths:
  - "**/*.rb"
  - "**/Gemfile"
  - "**/Rakefile"
  - "**/*.rake"
---

# Ruby Rules

## Conventions de code

### Nommage

| Element | Convention | Exemple |
|---------|------------|---------|
| Classes/Modules | PascalCase | `UserService` |
| Methodes | snake_case | `find_by_id` |
| Variables | snake_case | `user_name` |
| Constantes | SCREAMING_SNAKE | `MAX_RETRY_COUNT` |
| Fichiers | snake_case | `user_service.rb` |
| Predicats | avec `?` | `active?`, `valid?` |
| Mutateurs | avec `!` | `save!`, `update!` |

### Style

```ruby
# Indentation: 2 espaces
class UserService
  def find_by_id(id)
    User.find(id)
  end
end

# Pas de parentheses si pas d'arguments
def full_name
  "#{first_name} #{last_name}"
end

# Parentheses pour les appels avec arguments
user.update!(name: 'John', email: 'john@example.com')

# Symboles pour les cles de hash
{ name: 'John', email: 'john@example.com' }

# Blocs: do/end pour multi-ligne, {} pour une ligne
users.each { |user| puts user.name }

users.each do |user|
  puts user.name
  puts user.email
end
```

## Bonnes pratiques

### Classes et modules

```ruby
module Users
  class Service
    def initialize(repository:, mailer:)
      @repository = repository
      @mailer = mailer
    end

    def find(id)
      @repository.find(id)
    end

    private

    attr_reader :repository, :mailer

    def notify(user)
      mailer.send_welcome(user)
    end
  end
end
```

### Methodes

```ruby
# Arguments avec valeurs par defaut
def paginate(page: 1, per_page: 20)
  offset = (page - 1) * per_page
  limit(per_page).offset(offset)
end

# Guard clauses
def process(user)
  return unless user
  return if user.blocked?

  # Logic principale
end

# Safe navigation operator
user&.profile&.avatar_url
```

### Enumerable

```ruby
# Map
names = users.map(&:name)

# Select/Reject
active_users = users.select(&:active?)
inactive_users = users.reject(&:active?)

# Find
admin = users.find { |u| u.role == 'admin' }

# Reduce
total = orders.sum(&:amount)

# Chaining
users
  .select(&:active?)
  .sort_by(&:created_at)
  .first(10)
```

### Error handling

```ruby
# Exceptions personnalisees
module Users
  class NotFoundError < StandardError
    def initialize(id)
      super("User not found: #{id}")
    end
  end
end

# Rescue specifique
def find!(id)
  User.find(id)
rescue ActiveRecord::RecordNotFound
  raise Users::NotFoundError, id
end

# Ensure pour cleanup
def process_file(path)
  file = File.open(path)
  # process
ensure
  file&.close
end
```

## Rails

### Models

```ruby
class User < ApplicationRecord
  # 1. Associations
  belongs_to :organization
  has_many :posts, dependent: :destroy
  has_one :profile

  # 2. Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }

  # 3. Callbacks (avec parcimonie)
  before_validation :normalize_email

  # 4. Scopes
  scope :active, -> { where(active: true) }
  scope :recent, -> { order(created_at: :desc) }

  # 5. Class methods
  def self.find_by_email!(email)
    find_by!(email: email.downcase)
  end

  # 6. Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def normalize_email
    self.email = email&.downcase&.strip
  end
end
```

### Controllers

```ruby
class Api::UsersController < ApplicationController
  before_action :set_user, only: %i[show update destroy]

  def index
    @users = User.active.page(params[:page])
    render json: @users
  end

  def show
    render json: @user
  end

  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end
end
```

### Services

```ruby
# app/services/users/create_service.rb
module Users
  class CreateService
    def initialize(user_params:, mailer: UserMailer)
      @user_params = user_params
      @mailer = mailer
    end

    def call
      user = User.new(user_params)

      if user.save
        mailer.welcome(user).deliver_later
        Success.new(user)
      else
        Failure.new(user.errors)
      end
    end

    private

    attr_reader :user_params, :mailer
  end
end
```

## Tests (RSpec)

```ruby
RSpec.describe Users::CreateService do
  subject(:service) { described_class.new(user_params: params) }

  let(:params) { { name: 'John', email: 'john@example.com' } }

  describe '#call' do
    context 'with valid params' do
      it 'creates a user' do
        expect { service.call }.to change(User, :count).by(1)
      end

      it 'returns success' do
        result = service.call
        expect(result).to be_a(Success)
        expect(result.value.name).to eq('John')
      end
    end

    context 'with invalid params' do
      let(:params) { { name: '', email: 'invalid' } }

      it 'does not create a user' do
        expect { service.call }.not_to change(User, :count)
      end

      it 'returns failure with errors' do
        result = service.call
        expect(result).to be_a(Failure)
      end
    end
  end
end
```

## A eviter

- `eval`, `instance_eval` sauf vraiment necessaire
- Monkey patching en production
- Callbacks complexes (preferer services)
- N+1 queries
- Fat controllers (extraire en services)
