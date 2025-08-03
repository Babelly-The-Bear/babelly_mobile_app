import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' hide LinearGradient;

class AnimationScreen extends StatefulWidget {
  const AnimationScreen({super.key});

  @override
  State<AnimationScreen> createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen> {
  Artboard? riveArtboard;
  SMIBool? isHearing;
  SMIBool? talk;

  @override
  void initState() {
    print('animation screen init state');
    super.initState();

    rootBundle.load('assets/bear_character.riv').then(
      (data) async {
        try {
          final file = RiveFile.import(data);
          final artboard = file.mainArtboard;
          final controller =
              StateMachineController.fromArtboard(artboard, 'State Machine 1');
          if (controller != null) {
            artboard.addController(controller);
            isHearing = controller.findSMI('Hear');
            talk = controller.findSMI('Talk');
            setState(
              () {
                riveArtboard = artboard;
              },
            );
          }
        } catch (e) {
          print(e);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    print('Built animation screen');
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF9F6F0), // Vanilla
            Color(0xFFF5F1EB), // Cream
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: riveArtboard == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA0724C).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pets,
                      size: 40,
                      color: Color(0xFF8B5A3C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading Bear...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5A3C),
                    ),
                  ),
                ],
              )
            : Rive(
                artboard: riveArtboard!,
                alignment: Alignment.center,
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}
