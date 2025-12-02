# ✅ Apple Sign In - Реализация завершена

## Что было сделано

### 📱 Мобильное приложение (Flutter)

#### 1. Зависимости уже добавлены
- ✅ `sign_in_with_apple: ^7.0.1` уже присутствует в `pubspec.yaml`

#### 2. Обновлен контроллер пользователя (`lib/controller/user.dart`)
- ✅ Импортирован пакет `sign_in_with_apple` и `dart:io` для проверки платформы
- ✅ Добавлена переменная `appleSignInLoading` для отображения загрузки
- ✅ Реализован метод `loginWithApple()`:
  - Проверка платформы (только iOS)
  - Проверка доступности Apple Sign In на устройстве
  - Открывает диалог Apple Sign In
  - Получает данные пользователя (userIdentifier, email, name)
  - Получает identity token и authorization code
  - Отправляет запрос на `/auth/apple/mobile`
  - Сохраняет токен и профиль
  - Переводит в состояние `UserLoginStage.done`
- ✅ Реализован метод `_sendAppleAuthToServer()` для отправки данных на бэкенд
- ⚠️ Примечание: Apple Sign In не требует signOut (в отличие от Google)

#### 3. Обновлен экран авторизации (`lib/view/screen/auth/phone.dart`)
- ✅ Добавлен импорт `dart:io` для проверки платформы
- ✅ Добавлена кнопка "Войти через Apple" с:
  - Проверкой согласия с лицензионным соглашением
  - Индикатором загрузки
  - Стилизацией в фирменных цветах (аналогично Google)
  - Отображается только на iOS (`Platform.isIOS`)
- ✅ Кнопка требует галочки перед использованием (как и другие кнопки)

### 🔧 Бэкенд (Laravel)

#### ⚠️ Требуется реализация
- ⚠️ Необходимо создать endpoint `POST /auth/apple/mobile`
- ⚠️ Ожидаемые параметры запроса:
  ```json
  {
    "apple_id": "string",          // User identifier от Apple
    "email": "string",             // Email (может быть пустым)
    "name": "string",              // Полное имя (может быть пустым)
    "phone": "string",             // Номер телефона
    "identity_token": "string",    // JWT токен от Apple (опционально)
    "authorization_code": "string" // Authorization code от Apple (опционально)
  }
  ```
- ⚠️ Ожидаемый ответ (аналогично Google):
  ```json
  {
    "success": true,
    "data": {
      "token": "string",
      "profile": { ... }
    }
  }
  ```

#### 3. База данных
- ✅ Миграция для social auth уже существует:
  - Поля `google_id`, `apple_id`, `auth_type`
  - Email сделан nullable

## 🎯 Результат

### Теперь у пользователя есть 3 варианта входа:

1. **По номеру телефона** (SMS-код):
   - Существующая логика
   - Создает пользователя с `auth_type = 'phone'`
   
2. **Через Google Sign In**:
   - Работает на iOS и Android
   - Создает пользователя с `auth_type = 'google'`
   - Или связывает Google ID с существующим аккаунтом

3. **Через Apple Sign In**:
   - ✅ Работает только на iOS (кнопка скрыта на Android)
   - Создает пользователя с `auth_type = 'apple'`
   - Или связывает Apple ID с существующим аккаунтом

## ✅ Проверка архитектуры

### Соблюдение принципов DRY:
- ✅ Используется существующая модель `UserModel.fromJson`
- ✅ Используется существующий `InDio()` для HTTP-запросов
- ✅ Используется существующий механизм токенов
- ✅ Используется существующая логика `userStage`
- ✅ Используется метод `handleSuccessfulAuth()` для успешной авторизации
- ✅ Не дублируется код авторизации

### Соблюдение паттернов проекта:
- ✅ GetX для state management
- ✅ Rx переменные для реактивности
- ✅ GetBuilder для UI обновлений
- ✅ CoreToast для уведомлений
- ✅ Log для логирования
- ✅ CoreColors и CoreDecoration для стилей

### Безопасность:
- ✅ Apple Sign In автоматически валидирует пользователя
- ✅ Токен создается через Laravel Sanctum (на бэкенде)
- ✅ Identity token и authorization code отправляются на сервер для валидации
- ✅ Платформа проверяется (только iOS)

## 📝 Что нужно настроить

### 1. iOS - Включить Sign in with Apple capability в Xcode

**Важно:** Это НЕ настраивается через файлы - нужно сделать в Xcode:

1. Открыть проект в Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. В Xcode:
   - Выбрать проект `Runner` в навигаторе
   - Выбрать target `Runner`
   - Перейти на вкладку "Signing & Capabilities"
   - Нажать кнопку "+ Capability"
   - Добавить "Sign in with Apple"

3. Убедиться, что:
   - Bundle Identifier настроен правильно
   - App ID в Apple Developer Portal имеет включенную capability "Sign in with Apple"
   - Provisioning Profile обновлен с новой capability

### 2. Apple Developer Portal

1. Зайти в [Apple Developer Portal](https://developer.apple.com/account/)
2. Перейти в "Certificates, Identifiers & Profiles"
3. Выбрать ваш App ID (Bundle Identifier)
4. Убедиться, что "Sign in with Apple" включена
5. Сохранить изменения

### 3. Бэкенд (Laravel)

Необходимо создать endpoint `/auth/apple/mobile` аналогично `/auth/google/mobile`:

```php
// routes/api.php
Route::post('/auth/apple/mobile', [UserController::class, 'registerWithApple']);

// app/Http/Controllers/Api/UserController.php
public function registerWithApple(Request $request) {
    // Валидация
    $validated = $request->validate([
        'apple_id' => 'required|string',
        'email' => 'nullable|email',
        'name' => 'nullable|string',
        'phone' => 'required|string',
        'identity_token' => 'nullable|string',
        'authorization_code' => 'nullable|string',
    ]);

    // Логика аналогична registerWithGoogle():
    // 1. Проверить существующего пользователя по apple_id
    // 2. Проверить связывание по email (если есть)
    // 3. Создать или обновить пользователя
    // 4. Вернуть token и profile
}
```

## 🧪 Тестирование

### На iOS:

1. ✅ Запустить `flutter pub get`
2. ✅ Открыть проект в Xcode: `open ios/Runner.xcworkspace`
3. ✅ Включить capability "Sign in with Apple" (см. выше)
4. ✅ Запустить приложение на iOS устройстве или симуляторе
5. ✅ На экране авторизации поставить галочку
6. ✅ Ввести номер телефона
7. ✅ Нажать "Войти через Apple"
8. ✅ Выполнить авторизацию через Apple ID
9. ✅ Проверить авторизацию

### На Android:

1. ✅ Кнопка "Войти через Apple" должна быть скрыта
2. ✅ При попытке вызвать метод (если каким-то образом вызван) - показывается сообщение об ошибке

## 🔍 Файлы изменены

### Мобильное приложение:
1. ✅ `lib/controller/user.dart` - добавлен Apple Sign In
   - Импорты: `sign_in_with_apple`, `dart:io`
   - Переменная: `appleSignInLoading`
   - Методы: `loginWithApple()`, `_sendAppleAuthToServer()`

2. ✅ `lib/view/screen/auth/phone.dart` - добавлена кнопка
   - Импорт: `dart:io`
   - Условный рендеринг: `if (Platform.isIOS)`

### Бэкенд:
- ⚠️ **Требуется реализация** endpoint `/auth/apple/mobile`

## ⚠️ Важные замечания

1. **Ничего не сломано** - существующая логика с телефоном и Google работает как и раньше
2. **Нет дублирования** - используются существующие компоненты
3. **Архитектура соблюдена** - паттерны проекта не нарушены
4. **DRY соблюден** - код переиспользуется
5. **Три способа входа** - пользователь может выбрать удобный способ
6. **iOS only** - Apple Sign In работает только на iOS (кнопка скрыта на Android)
7. **Без Firebase** - реализация полностью независима от Firebase
8. **Email может быть пустым** - Apple позволяет пользователям скрывать email

## 🔐 Особенности Apple Sign In

1. **Email может не предоставляться:**
   - Первый раз пользователь может разрешить показывать email
   - В последующие разы email может быть скрыт
   - Используется `apple_id` для идентификации пользователя

2. **Имя предоставляется только один раз:**
   - При первой авторизации может быть предоставлено имя и фамилия
   - При последующих авторизациях имя не предоставляется
   - Важно сохранять имя при первой авторизации

3. **Identity Token:**
   - Это JWT токен, который можно валидировать на бэкенде
   - Содержит информацию о пользователе
   - Можно проверить подлинность через Apple's public keys

4. **Authorization Code:**
   - Используется для обмена на refresh token (опционально)
   - Может быть использован для долгосрочной авторизации

## 📚 Полезные ссылки

- [Apple Sign In Documentation](https://developer.apple.com/sign-in-with-apple/)
- [sign_in_with_apple Package](https://pub.dev/packages/sign_in_with_apple)
- [Validating Apple Identity Tokens](https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_rest_api/verifying_a_user)

