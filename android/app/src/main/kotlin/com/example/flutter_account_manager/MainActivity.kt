package com.example.flutter_account_manager

import android.accounts.Account
import android.accounts.AccountManager
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.flutter_account_manager/auth"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "addAccount") {
                val username = call.argument<String>("username")
                val password = call.argument<String>("password")

                if (username != null && password != null) {
                    val added = addAccount(username, password)
                    if (added) {
                        result.success(true)
                    } else {
                        result.error("AUTH_ERROR", "No se pudo crear la cuenta o ya existe.", null)
                    }
                } else {
                    result.error("INVALID_ARGS", "Faltan argumentos: usuario o contraseña.", null)
                }
            } else if (call.method == "getAccounts") {
                val accounts = getAccounts()
                result.success(accounts)
            } else if (call.method == "getPassword") {
                val username = call.argument<String>("username")
                if (username != null) {
                    val password = getAccountPassword(username)
                    result.success(password)
                } else {
                    result.error("INVALID_ARGS", "Falta el nombre de usuario.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getAccounts(): List<String> {
        val accountManager = AccountManager.get(this)
        val accounts = accountManager.getAccountsByType("com.example.flutter_account_manager")
        return accounts.map { it.name }
    }

    private fun getAccountPassword(username: String): String? {
        val accountManager = AccountManager.get(this)
        val accounts = accountManager.getAccountsByType("com.example.flutter_account_manager")
        val account = accounts.find { it.name == username }
        return if (account != null) {
            accountManager.getPassword(account)
        } else {
            null
        }
    }

    private fun addAccount(username: String, password: String): Boolean {
        val accountManager = AccountManager.get(this)
        val account = Account(username, "com.example.flutter_account_manager")
        
        val dummyBundle = Bundle()
        return accountManager.addAccountExplicitly(account, password, dummyBundle)
    }
}
