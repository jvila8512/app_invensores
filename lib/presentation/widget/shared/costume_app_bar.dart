import 'package:flutter/material.dart';

/// App bar compartida de la aplicacion.
class CostumeAppBar extends StatelessWidget {
  const CostumeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final estiloTitulo = Theme.of(context).textTheme.titleMedium;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Icon(Icons.solar_power_outlined, color: color.primary),
              const SizedBox(width: 5),
              Text("Supervisión", style: estiloTitulo),
              Spacer(),
              IconButton(onPressed: () {}, icon: Icon(Icons.refresh)),
            ],
          ),
        ),
      ),
    );
  }
}
