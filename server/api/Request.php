<?php

declare(strict_types=1);

namespace BedrockStarter;

class Request
{
    /**
     * Get data from POST body (supports both JSON and form data)
     */
    public static function getData(): array
    {
        if (!empty($_POST)) {
            return $_POST;
        }

        $rawInput = file_get_contents('php://input');
        if ($rawInput === false || $rawInput === '') {
            return [];
        }

        $decoded = json_decode($rawInput, true);
        return is_array($decoded) ? $decoded : [];
    }

    /**
     * Get a string parameter from GET/POST, with optional default
     */
    public static function getString(string $key, string $default = ''): string
    {
        $data = self::getData();
        return trim((string) ($_GET[$key] ?? $data[$key] ?? $default));
    }

    /**
     * Get an integer parameter from GET/POST, with optional default and bounds
     */
    public static function getInt(string $key, ?int $default = null, ?int $min = null, ?int $max = null): ?int
    {
        $data = self::getData();
        $value = $_GET[$key] ?? $data[$key] ?? null;

        if ($value === null) {
            return $default;
        }

        $intValue = (int) $value;

        if ($min !== null) {
            $intValue = max($min, $intValue);
        }

        if ($max !== null) {
            $intValue = min($max, $intValue);
        }

        return $intValue;
    }

    /**
     * Require a string parameter (throws 400 if missing or empty)
     */
    public static function requireString(string $key): string
    {
        $value = self::getString($key);
        if ($value === '') {
            http_response_code(400);
            echo json_encode(['error' => "Missing required parameter: {$key}"]);
            exit;
        }
        return $value;
    }

    /**
     * Get request method
     */
    public static function getMethod(): string
    {
        return $_SERVER['REQUEST_METHOD'];
    }

    /**
     * Get request path
     */
    public static function getPath(): string
    {
        return parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?? '/';
    }
}

