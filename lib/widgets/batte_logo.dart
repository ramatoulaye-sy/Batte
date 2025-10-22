import 'package:flutter/material.dart';

class BatteLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit? fit;

  const BatteLogo({
    Key? key,
    this.width,
    this.height,
    this.fit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.jpeg',
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width ?? 100,
          height: height ?? 100,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.recycling,
            size: (width ?? 100) * 0.6,
            color: Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }
}

class BatteLogoSmall extends StatelessWidget {
  const BatteLogoSmall({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BatteLogo(
      width: 40,
      height: 40,
    );
  }
}

class BatteLogoMedium extends StatelessWidget {
  const BatteLogoMedium({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BatteLogo(
      width: 80,
      height: 80,
    );
  }
}

class BatteLogoLarge extends StatelessWidget {
  const BatteLogoLarge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BatteLogo(
      width: 120,
      height: 120,
    );
  }
}
