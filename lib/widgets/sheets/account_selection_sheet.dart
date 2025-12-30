import 'package:flutter/material.dart';
import '../../controllers/login_controller.dart';
import '../dialogs/delete_account_dialog.dart';

class AccountSelectionSheet extends StatelessWidget {
  final LoginController controller;
  final bool showDeleteButton;

  const AccountSelectionSheet({
    super.key,
    required this.controller,
    this.showDeleteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          _buildTitle(context),
          const Divider(),
          // List of accounts
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: controller.savedAccounts.isEmpty
                    ? [
                        const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('No hay cuentas registradas.'),
                        ),
                      ]
                    : controller.savedAccounts.map((account) {
                        return _buildItem(account, context);
                      }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Build title widget
  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Cuentas Registradas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// Build item widget
  Widget _buildItem(String account, BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.account_circle, color: Colors.blue),
      title: Text(account),
      trailing: showDeleteButton
          ? IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => DeleteAccountDialog.show(
                context,
                account,
                controller.removeAccount,
              ),
            )
          : null,
      onTap: () {
        Navigator.pop(context); // Close sheet
        controller.loginWithMSAL(loginHint: account);
      },
    );
  }
}
