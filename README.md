# apk_iot_gempa_warga

## Backend API

The API base URL is currently set in `lib/services/api_service.dart` to
`http://192.168.56.1:8000/api`. Change the active `baseUrl` line when switching
networks; previous addresses can be kept as commented alternatives. The phone,
ESP32, and Laravel host must be able to reach the active address. Laravel must
listen on that interface (for example,
`php artisan serve --host=0.0.0.0 --port=8000`), and the computer firewall
must allow port `8000`.

The Flutter client currently sends these JSON request bodies:

- `POST /login`: `email_or_phone`, `password`
- `POST /aktivasi`: `kode_aktivasi`
- `POST /respons-warga`: `status` (`AMAN` or `BUTUH_BANTUAN`)

It polls `GET /status-wilayah` every 3 seconds while the home screen is open
and fetches `GET /riwayat-gempa` for the history tab. The status UI reads
`status_wilayah`, vibration (`nilai_getaran`, `nilai_getaran_g`, or related
aliases), magnitude (`magnitudo` or related aliases), and Node A/B status.
Responses wrapped in a `data` object/list and common Indonesian or English
field names are supported. When the status changes to danger, the app opens
the earthquake alert screen; it returns to home when the API reports `AMAN`.
If the Laravel controller uses different request keys or response fields,
update the corresponding methods in `lib/services/api_service.dart`.

The ESP32 ingestion URL should use
`http://192.168.56.1:8000/api/telemetri/kirim` and send JSON with HTTP `POST`.
Opening that ingestion URL directly in a browser sends `GET`, so Laravel's
"HTTP method not allowed" response is expected. Use the ESP32 `HTTPClient::POST`
request to verify ingestion. Flutter reads the separate status and history
endpoints using `GET`.

The Android manifest allows cleartext HTTP for local development. Use an
HTTPS base URL and disable cleartext traffic before publishing a production
build.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
