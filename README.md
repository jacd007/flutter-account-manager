# Microsoft Account Manager - Galaxy One Auth

Este proyecto es una implementación avanzada de autenticación con Microsoft (Azure AD) para Flutter, diseñada específicamente para eliminar la fricción del usuario al utilizar el **Android Account Manager** para la persistencia de cuentas y **MSAL (Microsoft Authentication Library)** para la seguridad de grado empresarial, incluyendo el manejo de MFA (Multi-Factor Authentication).

## 🚀 Concepto Principal
A diferencia de otras apps que abren el navegador cada vez que intentas iniciar sesión, esta solución:
1. **Registra** la cuenta directamente en el sistema operativo Android.
2. **Persiste** el nombre de usuario localmente.
3. **Verifica SILENCIOSAMENTE** la sesión con Microsoft siempre que sea posible.
4. **Maneja MFA** de forma nativa sin perder el contexto de la aplicación.

---

## 🛠 Instalación Paso a Paso (Para Desarrolladores)

### 1. Requisitos Previos
- Flutter SDK instalado.
- Un proyecto registrado en **Azure Portal** (App Registration).
- La firma de tu app (SHA-1) registrada en la configuración de Android en Azure.

### 2. Configuración de Credenciales
Edita el archivo `assets/auth_config.json`:
```json
{
  "client_id" : "TU_CLIENT_ID",
  "tenant_id" : "TU_TENANT_ID",
  "redirect_uri" : "msauth://TU_PACKAGE_NAME/TU_SIGNATURE_HASH"
}
```

### 3. Configuración del Manifiesto Android
En `android/app/src/main/AndroidManifest.xml`, asegúrate de que el `intent-filter` de la actividad de MSAL coincida exactamente con tu `redirect_uri`.

### 4. Compilación
```bash
flutter pub get
flutter run
```

---

## 🔍 Guía de Errores y Soluciones (Troubleshooting)

Aquí se detallan los errores más comunes divididos por su origen técnico.

### 1. Errores de Configuración (Config Error)
| Error | Por qué sucede | Cómo solucionarlo |
| :--- | :--- | :--- |
| `Msal Error: configuration_error` | El `auth_config.json` tiene un formato inválido o faltan campos. | Revisa que no haya comas de más y que el `client_id` sea correcto. |
| `Msal Error: redirect_uri_mismatch` | El URI de redirección definido en Azure Portal no coincide con el de `AndroidManifest.xml`. | Copia el URI de Azure Portal y pégalo en el archivo JSON y en el Manifiesto. |

### 2. Errores de Autenticación (Auth Flow)
| Error | Por qué sucede | Cómo solucionarlo |
| :--- | :--- | :--- |
| `TIMEOUT` (En pantalla de carga) | El usuario tardó más de 1 minuto en resolver el MFA o la ventana se quedó bloqueada. | El sistema cancela la operación automáticamente por seguridad. Reintenta la acción con una conexión estable. |
| `user_cancelled` | El usuario cerró la ventana de Microsoft antes de terminar de poner su clave. | Esto es un comportamiento esperado. El log mostrará el error en rojo, pero para el usuario solo se cerrará el loading. |

### 3. Errores del Sistema de Cuentas (Android Account Manager)
| Error | Por qué sucede | Cómo solucionarlo |
| :--- | :--- | :--- |
| `Error al registrar en el sistema local` | Intentas registrar una cuenta que ya existe dentro de la configuración de "Cuentas" del teléfono Android. | Ve a Ajustes > Cuentas > Galaxy One Auth y elimina la cuenta manualmente antes de re-registrar. |
| `account_type_not_found` | El sistema no reconoce el tipo de cuenta `com.galaxy.one.auth`. | Revisa que el servicio `AuthenticatorService` esté correctamente registrado en el `AndroidManifest.xml`. |

---

## 🏗 Arquitectura del Proyecto

Para los desarrolladores que quieran profundizar:

- **`lib/services/account_manager_service.dart`**: El puente (MethodChannel) que pide favores al código nativo (Kotlin).
- **`android/app/src/main/kotlin/.../Authenticator.kt`**: La clase que implementa la interfaz `AbstractAccountAuthenticator` requerida por Android.
- **`lib/screens/login_screen.dart`**: Contiene la lógica del "Timed Auth Result". Si la operación de Microsoft no responde en 60s, corta la ejecución para evitar que la UI se quede colgada para siempre.

### ¿Cómo se ven los errores en desarrollo?
Hemos implementado un sistema de logs en color:
- **Rojo (`\x1B[31m`)**: Errores críticos de plataforma o red.
- **Normal**: Flujo de información exitosa.

Si ves un error rojo en tu consola de VS Code o Android Studio, revisa los `technicalDetails` que imprimimos antes de reportar un bug.
