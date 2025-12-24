# Microsoft Account Manager - TU APP NAME

Este proyecto es una implementación avanzada de autenticación con Microsoft (Azure AD) para Flutter, diseñada específicamente para eliminar la fricción del usuario al utilizar el **Android Account Manager** para la persistencia de cuentas y **MSAL (Microsoft Authentication Library)** para la seguridad de grado empresarial, incluyendo el manejo de MFA (Multi-Factor Authentication).

## 🚀 Funcionalidades Principales

1. **Autenticación Browserless**: Utiliza MSAL para validar identidades de Microsoft de forma nativa.
2. **Persistencia en el Sistema**: Registra las cuentas directamente en el gestor de cuentas de Android (Ajustes > Cuentas).
3. **Arquitectura Modos**: Código altamente organizado separando la lógica (Controller) de la interfaz (Screens/Widgets).
4. **Eliminación Segura**: Flujo de borrado de cuentas con doble confirmación y conteo regresivo de 5 segundos para evitar accidentes.
5. **Manejo de Errores Profesional**: Logs en color para desarrolladores y mensajes simplificados para el usuario.

---

## 🛠 Guía de Implementación Paso a Paso

Si deseas replicar este sistema en otro proyecto, sigue este orden:

### 1. Configuración de Credenciales
**Archivo:** `assets/auth_config.json` [CREAR]
```json
{
  "client_id" : "TU_CLIENT_ID",
  "tenant_id" : "TU_TENANT_ID",
  "redirect_uri" : "msauth://TU_PACKAGE_NAME/TU_SIGNATURE_HASH"
}
```

### 2. Configuración Android Nativa
**Archivo:** `android/app/src/main/AndroidManifest.xml` [EDITAR]
- **Línea ~10**: Agrega permisos: `GET_ACCOUNTS`, `AUTHENTICATE_ACCOUNTS`, `MANAGE_ACCOUNTS`.
- **Dentro de `<application>`**: Registra el `AuthenticatorService`.
- **Callback MSAL**: Asegúrate de que el `intent-filter` de la actividad de MSAL tenga el `scheme` y `host` que coincidan con tu `redirect_uri`.

**Archivo:** `android/app/src/main/res/xml/authenticator.xml` [CREAR]
- Define el `accountType` como `TU_PACKAGE_NAME`.

**Archivo:** `android/app/src/main/kotlin/.../MainActivity.kt` [EDITAR]
- Implementa el `MethodChannel` con los casos: `addAccount`, `getAccounts`, `getPassword`, `removeAccount`.

### 3. Estructura de Archivos Flutter (lib/)

#### Capa de Datos y Servicios
- **`lib/services/account_manager_service.dart`**: El puente directo con el código nativo de Android.
- **`lib/utils/snackbar_utils.dart`**: Gestiona las notificaciones visuales y los logs en rojo.

#### Capa de Lógica (Controllers)
- **`lib/controllers/login_controller.dart`**: Orquestador de la autenticación. No tiene UI, solo lógica y estado (`ChangeNotifier`).

#### Capa de Interfaz (UI)
- **`lib/widgets/sheets/account_selection_sheet.dart`**: El modal que lista las cuentas guardadas.
- **`lib/widgets/dialogs/delete_account_dialog.dart`**: Diálogo con el contador de 5 segundos y validación irreversible.
- **`lib/screens/login_screen.dart`**: Vista principal simplificada que utiliza el controlador.

---

## 🔍 Troubleshooting (Solución de Problemas)

### 1. Errores de Configuración
| Error | Por qué sucede | Cómo solucionarlo |
| :--- | :--- | :--- |
| `Msal Error: configuration_error` | El `auth_config.json` tiene un error de sintaxis. | Revisa comas y comillas en el JSON. |
| `redirect_uri_mismatch` | Azure no reconoce el URI enviado. | Verifica que el HASH de la firma en Azure sea idéntico al del JSON. |

### 2. Errores del Sistema
| Error | Por qué sucede | Cómo solucionarlo |
| :--- | :--- | :--- |
| `Error al registrar local` | La cuenta ya existe en el teléfono. | Usa el nuevo flujo de **Eliminación Segura** para borrarla antes de re-intentar. |
| `TIMEOUT` | El usuario no completó el inicio de sesión en < 1 min. | Reintenta la operación con una conexión más estable. |

---

## 🏗 Arquitectura de Limpieza
Hemos reducido `LoginScreen.dart` de 450 a 130 líneas delegando la responsabilidad a:
- **`LoginController`**: Maneja el `isLoading` y llama a MSAL.
- **`DeleteAccountDialog`**: Se encarga de la lógica del cronómetro de 5 segundos.

### Logs de Desarrollo
- **Rojo (`\x1B[31m`)**: Errores críticos. Revisa la consola si algo falla silenciosamente.
- **Mensaje**: El usuario verá una SnackBar amigable mientras tú ves el error real.
