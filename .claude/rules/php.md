---
paths:
  - "**/*.php"
  - "**/composer.json"
---

# PHP Rules

## Conventions de code (PSR-12)

### Nommage

| Element | Convention | Exemple |
|---------|------------|---------|
| Classes | PascalCase | `UserService` |
| Interfaces | PascalCase + suffix | `UserRepositoryInterface` |
| Methodes | camelCase | `findById` |
| Variables | camelCase | `userName` |
| Constantes | SCREAMING_SNAKE | `MAX_RETRY_COUNT` |
| Fichiers | PascalCase | `UserService.php` |

### Structure

```php
<?php

declare(strict_types=1);

namespace App\Services;

use App\Repositories\UserRepositoryInterface;
use App\Exceptions\UserNotFoundException;

final class UserService
{
    public function __construct(
        private readonly UserRepositoryInterface $userRepository,
        private readonly LoggerInterface $logger,
    ) {
    }

    public function findById(int $id): User
    {
        return $this->userRepository->find($id)
            ?? throw new UserNotFoundException($id);
    }
}
```

## Bonnes pratiques

### Types stricts

```php
<?php

declare(strict_types=1);

// Types de retour
public function findById(int $id): ?User { }
public function getAll(): array { }
public function create(CreateUserDto $dto): User { }

// Union types (PHP 8.0+)
public function process(string|int $id): void { }

// Intersection types (PHP 8.1+)
public function handle(Countable&Iterator $collection): void { }

// Enums (PHP 8.1+)
enum Status: string
{
    case Active = 'active';
    case Inactive = 'inactive';
    case Pending = 'pending';
}
```

### Constructor property promotion

```php
// PHP 8.0+
final class UserService
{
    public function __construct(
        private readonly UserRepositoryInterface $userRepository,
        private readonly LoggerInterface $logger,
    ) {
    }
}
```

### Named arguments

```php
// PHP 8.0+
$user = new User(
    name: 'John',
    email: 'john@example.com',
    role: Role::Admin,
);
```

### Null safety

```php
// Nullsafe operator (PHP 8.0+)
$avatar = $user?->profile?->avatarUrl;

// Null coalescing
$name = $user->nickname ?? $user->name ?? 'Anonymous';

// Null coalescing assignment
$this->cache ??= new Cache();
```

### Match expression

```php
// PHP 8.0+
$message = match ($status) {
    Status::Active => 'User is active',
    Status::Inactive => 'User is inactive',
    Status::Pending => 'Awaiting approval',
    default => throw new InvalidArgumentException('Unknown status'),
};
```

## Laravel

### Controllers

```php
<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Http\Requests\CreateUserRequest;
use App\Http\Resources\UserResource;
use App\Services\UserService;

final class UserController extends Controller
{
    public function __construct(
        private readonly UserService $userService,
    ) {
    }

    public function index(): AnonymousResourceCollection
    {
        return UserResource::collection(
            $this->userService->paginate()
        );
    }

    public function show(int $id): UserResource
    {
        return new UserResource(
            $this->userService->findById($id)
        );
    }

    public function store(CreateUserRequest $request): UserResource
    {
        $user = $this->userService->create($request->validated());

        return new UserResource($user);
    }
}
```

### Form Requests

```php
<?php

declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

final class CreateUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'min:2', 'max:100'],
            'email' => ['required', 'email', 'unique:users'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ];
    }
}
```

### Models

```php
<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

final class User extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    protected $hidden = [
        'password',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'is_active' => 'boolean',
    ];

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function posts(): HasMany
    {
        return $this->hasMany(Post::class);
    }

    // Query scopes
    public function scopeActive(Builder $query): Builder
    {
        return $query->where('is_active', true);
    }
}
```

### Services

```php
<?php

declare(strict_types=1);

namespace App\Services;

use App\DTOs\CreateUserDto;
use App\Events\UserCreated;
use App\Models\User;
use App\Repositories\UserRepositoryInterface;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

final class UserService
{
    public function __construct(
        private readonly UserRepositoryInterface $userRepository,
    ) {
    }

    public function create(array $data): User
    {
        return DB::transaction(function () use ($data) {
            $user = $this->userRepository->create([
                ...$data,
                'password' => Hash::make($data['password']),
            ]);

            event(new UserCreated($user));

            return $user;
        });
    }
}
```

## Tests (PHPUnit)

```php
<?php

declare(strict_types=1);

namespace Tests\Unit\Services;

use App\Models\User;
use App\Repositories\UserRepositoryInterface;
use App\Services\UserService;
use PHPUnit\Framework\TestCase;

final class UserServiceTest extends TestCase
{
    private UserRepositoryInterface $repository;
    private UserService $service;

    protected function setUp(): void
    {
        parent::setUp();

        $this->repository = $this->createMock(UserRepositoryInterface::class);
        $this->service = new UserService($this->repository);
    }

    public function test_find_by_id_returns_user(): void
    {
        // Arrange
        $user = new User(['id' => 1, 'name' => 'John']);
        $this->repository
            ->method('find')
            ->with(1)
            ->willReturn($user);

        // Act
        $result = $this->service->findById(1);

        // Assert
        $this->assertSame($user, $result);
    }

    public function test_find_by_id_throws_when_not_found(): void
    {
        $this->repository
            ->method('find')
            ->willReturn(null);

        $this->expectException(UserNotFoundException::class);

        $this->service->findById(999);
    }
}
```

## A eviter

- Variables globales et `global`
- `@` pour supprimer les erreurs
- `eval()` et `extract()`
- Mixed sans typage
- Fat controllers (utiliser services)
- N+1 queries (utiliser eager loading)
